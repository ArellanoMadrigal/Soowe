import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class HomeEnfermero extends StatefulWidget {
  const HomeEnfermero({super.key});

  @override
  State<HomeEnfermero> createState() => _HomeEnfermeroState();
}

class _HomeEnfermeroState extends State<HomeEnfermero> {
  final _apiService = ApiService();
  final _authService = AuthService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _solicitudes = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSolicitudes();
  }

  Future<void> _loadSolicitudes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final solicitudes = await _apiService.getEnfermeroAssignedRequests();
      
      if (mounted) {
        setState(() {
          _solicitudes = solicitudes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        _showErrorSnackBar('Error al cargar solicitudes: $e');
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _showErrorSnackBar('Error al cerrar sesión: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatFecha(String? fechaStr) {
    if (fechaStr == null) return 'Fecha no disponible';
    try {
      final fecha = DateTime.parse(fechaStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
    } catch (e) {
      return fechaStr;
    }
  }

  Color _getStatusColor(String? status) {
    return switch (status?.toLowerCase()) {
      'pendiente' => Colors.orange,
      'en_proceso' => Colors.blue,
      'completado' => Colors.green,
      'cancelado' => Colors.red,
      _ => Colors.grey,
    };
  }

  String _getStatusText(String? status) {
    return switch (status?.toLowerCase()) {
      'pendiente' => 'Pendiente',
      'en_proceso' => 'En Proceso',
      'completado' => 'Completado',
      'cancelado' => 'Cancelado',
      _ => 'Estado Desconocido',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Panel de Enfermero'),
            Text(
              'Bienvenido, ${_authService.getUserName() ?? "Enfermero"}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton.filledTonal(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSolicitudes,
            tooltip: 'Actualizar',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Cerrar sesión',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar las solicitudes',
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadSolicitudes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSolicitudes,
                  child: _solicitudes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay solicitudes asignadas',
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                onPressed: _loadSolicitudes,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Actualizar'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _solicitudes.length,
                          itemBuilder: (context, index) {
                            final solicitud = _solicitudes[index];
                            final status = solicitud['estado'] as String?;

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Aquí puedes agregar la navegación al detalle
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Solicitud #${solicitud['id'] ?? 'N/A'}',
                                              style: textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(status)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _getStatusText(status),
                                              style: textTheme.bodySmall?.copyWith(
                                                color: _getStatusColor(status),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        context,
                                        Icons.person_outline,
                                        'Paciente',
                                        solicitud['paciente_nombre'] ??
                                            'No disponible',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        context,
                                        Icons.calendar_today_outlined,
                                        'Fecha',
                                        _formatFecha(solicitud['fecha_solicitud']),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        context,
                                        Icons.location_on_outlined,
                                        'Dirección',
                                        solicitud['direccion'] ?? 'No disponible',
                                      ),
                                      if (solicitud['notas'] != null) ...[
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          context,
                                          Icons.note_outlined,
                                          'Notas',
                                          solicitud['notas'],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}