import 'package:flutter/material.dart';
import 'package:appdesarrollo/services/auth_service.dart';
import '../../services/api_service.dart';
import '../../transitions/search_page_transition.dart';
import 'profile_view.dart';
import 'requests_view.dart';
import 'categories_screen.dart';
import 'list_service.dart';
import '../../services/request_service.dart';

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
  
  bool _showNotifications = false;
  bool _isLoading = true;
  
  List<Request> requests = [];
  List<Map<String, dynamic>> _notifications = [];
  
  String _userName = '';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
        // Cargar datos del usuario
        final userData = await authService.getUserProfile();
        if (!mounted) return;
        
        setState(() {
          _userName = '${userData['nombre']} ${userData['apellido']}'.trim();
          _profileImageUrl = userData['foto_perfil']?['url'];
        });

        // Cargar solicitudes y notificaciones
        final userIdInt = int.parse(userId);
        final futures = await Future.wait([
          _requestService.getAllRequests(
            usuarioId: userIdInt,
            organizacionId: 0,
          ),
          _apiService.fetchNotifications(),
        ]);

        if (!mounted) return;

        setState(() {
          requests = (futures[0] as List<Request>);
          _notifications = (futures[1] as List<Map<String, dynamic>>)
            .where((n) => !n['read']).toList();
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
          content: Text('Error de autenticación. Por favor, inicie sesión nuevamente.'),
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
        usuarioId: int.parse(userId),
        pacienteId: int.parse(newRequest['paciente_id'].toString()),
        metodoPago: newRequest['metodo_pago'] ?? 'efectivo',
        organizacionId: newRequest['organizacion_id'] != null 
            ? int.parse(newRequest['organizacion_id'].toString()) 
            : null,
        fechaServicio: DateTime.now().add(const Duration(hours: 1)),
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
          content: Text(
            e.toString().contains('Exception:') 
                ? e.toString().split('Exception:')[1].trim()
                : 'Error al crear la solicitud: $e'
          ),
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

  void _navigateToListService(ServiceModel service) async {
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListServiceScreen(
          categoryId: service.id,
          categoryTitle: service.title,
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
                ),
                RequestsView(
                  key: ValueKey(_selectedIndex),
                  requests: requests, // Pasando las solicitudes
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

class ServiceModel {
  final String id;
  final String title;
  final int nurses;
  final IconData icon;

  ServiceModel({
    required this.id,
    required this.title,
    required this.nurses,
    required this.icon,
  });
}

class _ServicesView extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onCategoryTap;
  final Function(ServiceModel) onServiceTap;
  final Future<void> Function() onRefresh;

  const _ServicesView({
    required this.userName,
    this.profileImageUrl,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onCategoryTap,
    required this.onServiceTap,
    required this.onRefresh,
  });
    @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final services = [
      ServiceModel(
        id: '1',
        title: 'Cuidados Básicos del Paciente',
        nurses: 1265,
        icon: Icons.medical_services_outlined,
      ),
      ServiceModel(
        id: '2',
        title: 'Atención Postoperatoria',
        nurses: 523,
        icon: Icons.healing_outlined,
      ),
      ServiceModel(
        id: '3',
        title: 'Suturas y Retiro de Suturas',
        nurses: 223,
        icon: Icons.cut_outlined,
      ),
      ServiceModel(
        id: '4',
        title: 'Limpieza y Curación de Heridas',
        nurses: 223,
        icon: Icons.cleaning_services_outlined,
      ),
      ServiceModel(
        id: '5',
        title: 'Control de Enfermedades Crónicas',
        nurses: 223,
        icon: Icons.monitor_heart_outlined,
      ),
      ServiceModel(
        id: '6',
        title: 'Vacunación',
        nurses: 223,
        icon: Icons.vaccines_outlined,
      ),
    ];

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
                    'Servicios populares',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ServiceCard(
                  service: services[index],
                  onTap: () => onServiceTap(services[index]),
                ),
                childCount: services.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
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
                  service.icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                service.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${service.nurses} enfermeros',
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
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.notifications_none,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(notification['title'] ?? ''),
                                subtitle: Text(notification['message'] ?? ''),
                                trailing: Text(
                                  notification['time'] ?? '',
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