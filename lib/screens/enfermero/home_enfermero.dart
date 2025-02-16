import 'package:flutter/material.dart';

class HomeEnfermero extends StatefulWidget {
  const HomeEnfermero({super.key});

  @override
  State<HomeEnfermero> createState() => _HomeEnfermeroState();
}

class _HomeEnfermeroState extends State<HomeEnfermero> {
  int _selectedIndex = 0;
  bool _hasNotifications = true;
  bool _showNotifications = false;
  
  // Lista de notificaciones de ejemplo
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Nuevo servicio asignado',
      'message': 'Se te ha asignado un nuevo servicio de cuidado intensivo',
      'read': false,
      'time': '10:30 AM',
    },
    {
      'id': '2',
      'title': 'Recordatorio de servicio',
      'message': 'Tienes un servicio programado para mañana a las 9:00 AM',
      'read': false,
      'time': 'Ayer',
    },
    {
      'id': '3',
      'title': 'Pago recibido',
      'message': 'Se ha procesado el pago del servicio #0145',
      'read': true,
      'time': '23 Nov',
    },
  ];

  void _toggleNotifications() {
    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              toolbarHeight: 80,
              backgroundColor: colorScheme.surface,
              elevation: 0,
              title: Row(
                children: [
                  Hero(
                    tag: 'profile_image',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage: const AssetImage('assets/profile_image.jpg'),
                        radius: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fernanda Arellano',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enfermera de urgencias',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      iconSize: 28,
                      tooltip: 'Notificaciones',
                      onPressed: _toggleNotifications,
                    ),
                    if (_hasNotifications)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '¡Bienvenida de nuevo!',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      delegate: SliverChildListDelegate([
                        _MenuCard(
                          icon: Icons.calendar_month_rounded,
                          title: 'Citas',
                          subtitle: 'Ver agenda',
                          color: colorScheme.primary,
                        ),
                        _MenuCard(
                          icon: Icons.insert_chart_rounded,
                          title: 'Estadísticas',
                          subtitle: 'Análisis y reportes',
                          color: colorScheme.secondary,
                        ),
                        _MenuCard(
                          icon: Icons.payments_rounded,
                          title: 'Seguimiento',
                          subtitle: 'Estado de pagos',
                          color: colorScheme.tertiary,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              height: 72,
              elevation: 4,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              selectedIndex: _selectedIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 600),
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color: _selectedIndex == 0 ? colorScheme.primary : null,
                  ),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: colorScheme.primary,
                  ),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.description_outlined,
                    color: _selectedIndex == 1 ? colorScheme.primary : null,
                  ),
                  selectedIcon: Icon(
                    Icons.description_rounded,
                    color: colorScheme.primary,
                  ),
                  label: 'Solicitudes',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.person_outline_rounded,
                    color: _selectedIndex == 2 ? colorScheme.primary : null,
                  ),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: colorScheme.primary,
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
          if (_showNotifications)
            GestureDetector(
              onTap: _toggleNotifications,
              child: Container(
                color: Colors.black54,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + kToolbarHeight,
                      right: 8,
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  'Notificaciones',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _toggleNotifications,
                                  tooltip: 'Cerrar notificaciones',
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          if (_notifications.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 48,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tienes notificaciones',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.6,
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _notifications.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final notification = _notifications[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: notification['read']
                                          ? colorScheme.surfaceVariant
                                          : colorScheme.primary.withOpacity(0.1),
                                      child: Icon(
                                        Icons.notifications,
                                        color: notification['read']
                                            ? colorScheme.onSurfaceVariant
                                            : colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      notification['title'],
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: notification['read']
                                            ? FontWeight.normal
                                            : FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          notification['message'],
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification['time'],
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        notification['read'] = true;
                                        _hasNotifications = _notifications.any((n) => !n['read']);
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}