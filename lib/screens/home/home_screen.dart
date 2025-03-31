import 'package:appdesarrollo/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:appdesarrollo/services/auth_service.dart';
import '../../services/api_service.dart';
import 'profile_view.dart';
import 'requests_view.dart';
import 'list_service.dart';
import '../../services/request_service.dart';
import '../../models/category.dart';
import '../../models/solicitud.dart';
import 'search_screen.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import 'dart:async';

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
  final NotificationService _notificationService = NotificationService();

  bool _showNotifications = false;
  bool _isLoading = true;

  List<RequestModel> requests = [];
  final ValueNotifier<List<NotificationModel>> _notificationsNotifier =
      ValueNotifier<List<NotificationModel>>([]);
  List<CategoryModel> _categories = [];

  String _userName = '';
  String? _profileImageUrl;

  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
    requests = widget.newRequest != null
        ? [RequestModel.fromJson(widget.newRequest!)]
        : [];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });

    _startNotificationLoop();
  }

  void _startNotificationLoop() {
    _notificationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final authService = AuthService();
        final receptorId = authService.getCurrentUserId();
        if (receptorId == null) return;

        final notifications = await _notificationService.getNotificationsFromUser(receptorId);
        _notificationsNotifier.value = notifications;
      } catch (e) {
        debugPrint("Error al actualizar notificaciones: $e");
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _notificationsNotifier.dispose();
    super.dispose();
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
        _categoryService.getAllCategories(),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = (futures[2] as List<CategoryModel>).toList();
      });

      // Cargar notificaciones iniciales
      final notifications = await _notificationService.getNotificationsFromUser(userId);
      _notificationsNotifier.value = notifications;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los datos: $e'),
          backgroundColor: Colors.orange,
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

  void _navigateToCategoryServices(CategoryModel category) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListServiceScreen(
          categoryId: category.id ?? 0,
          categoryTitle: category.nombre,
          categoryDescription: category.descripcion,
        ),
      ),
    );
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
                _categories.isEmpty
                    ? const Center(child: Text("No hay categorias disponibles"))
                    : _CategoriesView(
                        userName: _userName,
                        profileImageUrl: _profileImageUrl,
                        onProfileTap: _navigateToProfile,
                        onNotificationTap: _toggleNotifications,
                        onCategoryTap: _navigateToCategoryServices,
                        onRefresh: _loadData,
                        categories: _categories,
                        notificationsNotifier: _notificationsNotifier,
                      ),
                RequestsView(
                  key: ValueKey(_selectedIndex),
                  requests: requests.map((request) => RequestModel.fromJson(request.toJson())).toList(),
                ),
                ProfileView(
                  onLogout: _handleLogout,
                ),
              ],
            ),
            if (_showNotifications)
              _NotificationsOverlay(
                notifications: _notificationsNotifier.value,
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

class _CategoriesView extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final Function(CategoryModel) onCategoryTap;
  final Future<void> Function() onRefresh;
  final List<CategoryModel> categories;
  final ValueNotifier<List<NotificationModel>> notificationsNotifier;

  const _CategoriesView({
    required this.userName,
    this.profileImageUrl,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onCategoryTap,
    required this.onRefresh,
    required this.categories,
    required this.notificationsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: ValueNotifier<List<Map<String, dynamic>>>(
        notificationsNotifier.value.map((notification) => notification.toJson()).toList(),
      ),
      builder: (context, notifications, child) {
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
                  Stack(
                    children: [
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
                      if (notifications.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              notifications.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchScreen()),
                          );
                        },
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
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      return _CategoryCard(
                        category: category,
                        onTap: () {
                          onCategoryTap(category);
                        },
                      );
                    },
                    childCount: categories.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.9,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 8),
              Text(
                category.nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  category.descripcion,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                        fontSize: 12,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
  final List<NotificationModel> notifications;
  final VoidCallback onDismiss;

  const _NotificationsOverlay({
    required this.notifications,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notificaciones',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 22),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onDismiss,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      if (notifications.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No hay notificaciones nuevas',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                                        child: Icon(
                                          Icons.notifications_none,
                                          size: 20,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification.titulo,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          const Divider(height: 2, thickness: 0.5),
                                          const SizedBox(height: 4),
                                          Text(
                                            notification.contenido,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(notification.fechaCreacion),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.hintColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Ahora mismo';
    if (difference.inHours < 1) return 'Hace ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Hace ${difference.inHours} h';
    if (difference.inDays == 1) return 'Ayer';
    return 'Hace ${difference.inDays} días';
  }
}