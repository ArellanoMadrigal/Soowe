import 'package:appdesarrollo/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:appdesarrollo/services/auth_service.dart';
import '../../services/api_service.dart';
import '../../transitions/search_page_transition.dart';
import 'models.dart';
import 'profile_view.dart';
import 'requests_view.dart';
import 'categories_screen.dart';
import 'list_service.dart';
import '../../services/request_service.dart';
import '../../models/category.dart';
import '../../models/service.dart';
import 'category_service_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? initialIndex;
  final Map<String, dynamic>? newRequest;

  const HomeScreen({
    super.key,
    this.initialIndex,
    this.newRequest,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  final RequestService _requestService = RequestService();
  final CategoryService _categoryService = CategoryService();
  late Future<List<CategoryModel>> _categoriesFuture;

  bool _showNotifications = false;
  bool _isLoading = true;

  List<MedicalRequest> requests = [];
  List<Map<String, dynamic>> _notifications = [];
  List<CategoryModel> _categories = [];

  String _userName = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;

    _categoriesFuture = _categoryService.getAllCategories();
    _categoriesFuture.then((categories) {
      debugPrint("Categorías obtenidas: ${categories.length}");
    }).catchError((error) {
      debugPrint("Error obteniendo categorías: $error");
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint("Llamando a _loadData...");
      await _loadData();

      if (widget.newRequest != null) {
        await _handleNewRequest(widget.newRequest!);
      }
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final userId = authService.getCurrentUserId();

      if (userId == null) {
        await _handleLogout();
        return;
      }

      try {
        final userData = await authService.getUserProfile();
        if (!mounted) return;

        setState(() {
          _userName = '${userData['nombre']} ${userData['apellido']}'.trim();
          _profileImageUrl = userData['foto_perfil']?['url'];
        });

        final futures = await Future.wait([
          _requestService.getAllRequests(
            usuarioId: userId,
            organizacionId: 0,
          ),
          _apiService.fetchNotifications(),
          CategoryService().getAllCategories(),
        ]);

        if (!mounted) return;

        setState(() {
          requests = (futures[0] as List<dynamic>)
              .map((item) =>
                  MedicalRequest.fromJson(item as Map<String, dynamic>))
              .toList();
          _notifications = (futures[1] as List<Map<String, dynamic>>)
              .where((n) => !n['read'])
              .toList();
          _categories = (futures[2] as List<dynamic>).map((item) {
            debugPrint("Item: $item");
            return CategoryModel.fromJson(item as Map<String, dynamic>);
          }).toList();
          debugPrint("Categorías actualizadas: ${_categories.length}");
          debugPrint("Contenido de futures[2]: ${futures[2]}");
        });
      } catch (e) {
        debugPrint('Error cargando datos: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los datos: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error crítico: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Error de autenticación. Por favor, inicie sesión nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      await _handleLogout();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleNewRequest(Map<String, dynamic> newRequest) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = AuthService();
      final userId = authService.getCurrentUserId();

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await _requestService.createRequest(
        usuarioId: userId, // Ya no necesitamos convertir a int
        pacienteId: newRequest['paciente_id'].toString(),
        metodoPago:
            newRequest['metodo_pago']?.toString().toLowerCase() ?? 'efectivo',
        organizacionId: newRequest['organizacion_id']?.toString(),
        fechaServicio: DateTime.parse('2025-02-20 05:00:47'),
        comentarios: newRequest['comentarios'] ?? '',
      );

      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud creada exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _selectedIndex = 1;
      });
    } catch (e) {
      debugPrint('Error al crear la solicitud: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('Exception:')
              ? e.toString().split('Exception:')[1].trim()
              : 'Error al crear la solicitud: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService().logout();
      if (!mounted) return;
      await Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      debugPrint("Error durante logout: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cerrar sesión.')),
      );
    }
  }

  void _toggleNotifications() {
    if (!mounted) return;
    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  void _navigateToProfile() {
    if (!mounted) return;
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _navigateToCategories() async {
    if (!mounted) return;
    await Navigator.push(
      context,
      SearchPageTransition(
        page: const CategoriesScreen(),
      ),
    );
  }

  void _navigateToListService(CategoryModel category) async {
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListServiceScreen(
          categoryId: category.id, // Usamos el ID de CategoryModel
          categoryTitle: category.nombre,
          categoryDescription: category.descripcion,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      if (result['action'] == 'new_request' && mounted) {
        await _handleNewRequest(result['data'] ?? result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: [
                _ServicesView(
                  userName: _userName,
                  profileImageUrl: _profileImageUrl,
                  onProfileTap: _navigateToProfile,
                  onNotificationTap: _toggleNotifications,
                  onCategoryTap: _navigateToCategories,
                  onServiceTap: _navigateToListService,
                  onRefresh: _loadData,
                  categories: _categories,
                ),
                RequestsView(
                  key: ValueKey(_selectedIndex),
                  requests: requests,
                ),
                ProfileView(
                  onLogout: _handleLogout,
                ),
              ],
            ),
            if (_showNotifications)
              _NotificationsOverlay(
                notifications: _notifications,
                onDismiss: _toggleNotifications,
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          elevation: 0,
          height: 65,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (!mounted) return;
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services),
              label: 'Servicios',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'Solicitudes',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesView extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onCategoryTap;
  final Function(CategoryModel) onServiceTap;
  final Future<void> Function() onRefresh;
  final List<CategoryModel> categories;

  const _ServicesView({
    required this.userName,
    this.profileImageUrl,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onCategoryTap,
    required this.onServiceTap,
    required this.onRefresh,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    debugPrint("Categorías en _ServicesView: ${categories.length}");
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: GestureDetector(
              onTap: onProfileTap,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? const Icon(Icons.person_outline)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    userName.isEmpty ? 'Usuario' : userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onNotificationTap,
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Notificaciones',
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué servicio necesitas?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    onTap: onCategoryTap,
                    decoration: InputDecoration(
                      hintText: 'Buscar servicios',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          // Aquí agregamos un GridView para mostrar las categorías
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                debugPrint("Construyendo categoría: ${category.nombre}");
                return GestureDetector(
                  onTap: () {
                    onServiceTap(category); // Pasar la categoría al servicio
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category.nombre, // Muestra el nombre de la categoría
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                );
              },
              childCount: categories.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Puedes ajustar la cantidad de columnas
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.12),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                category.nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                category.descripcion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final VoidCallback onDismiss;

  const _NotificationsOverlay({
    required this.notifications,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              right: 8,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notificaciones',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: onDismiss,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      if (notifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay notificaciones nuevas'),
                        )
                      else
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.notifications_none,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(notification['title'] ?? ''),
                                subtitle: Text(notification['message'] ?? ''),
                                trailing: Text(
                                  notification['time'] ??
                                      DateTime.parse('2025-02-20 04:37:49')
                                          .toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
