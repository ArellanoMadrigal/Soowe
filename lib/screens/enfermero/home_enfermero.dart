import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

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
  String _nombreCompleto = 'Enfermero';
  double _totalRevenue = 0.0;
  double _enfermeroRevenue = 0.0;

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

      final userId = await _authService.getCurrentUserId();
      if (userId == null) {
        debugPrint('ID de usuario no disponible.');
        throw Exception("ID de usuario no disponible");
      }

      final enfermeroId = await _apiService.fetchEnfermeroId(userId);
      if (enfermeroId == null) {
        debugPrint('ID de enfermero no disponible.');
        throw Exception("ID de enfermero no disponible");
      }

      final solicitudes = await _apiService.getEnfermeroAssignedRequests(enfermeroId);

      if (solicitudes.isNotEmpty) {
        final enfermero = solicitudes[0]['enfermero'] as Map<String, dynamic>?;
        if (enfermero != null) {
          final nombre = enfermero['nombre'] as String?;
          final apellido = enfermero['apellido'] as String?;
          if (nombre != null && apellido != null) {
            setState(() {
              _nombreCompleto = '$nombre $apellido';
            });
          }
        }

        // Calcular el total de ingresos y la ganancia del enfermero
        double total = 0.0;
        for (var solicitud in solicitudes) {
          final servicio = solicitud['servicio'] as Map<String, dynamic>?;
          if (servicio != null && servicio['precio_estimado'] != null) {
            total += double.parse(servicio['precio_estimado'].toString());
          }
        }

        setState(() {
          _totalRevenue = total;
          _enfermeroRevenue = total * 0.6; // 60% para el enfermero
        });
      }

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
      'asignado' => Colors.blue,
      'pendiente' => Colors.orange,
      'en_proceso' => Colors.blue,
      'completado' => Colors.green,
      'cancelado' => Colors.red,
      _ => Colors.grey,
    };
  }

  String _getStatusText(String? status) {
    return switch (status?.toLowerCase()) {
      'asignado' => 'Asignado',
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
        automaticallyImplyLeading: false, // Elimina la flecha de regreso
        title: Text(
          'Hola, $_nombreCompleto',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
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
              : _solicitudes.isEmpty
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
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Sección de Gráficos
                        _buildRevenueChartSection(context),
                        const SizedBox(height: 24),
                        // Sección de Solicitudes Asignadas
                        _buildAssignedRequestsSection(context),
                      ],
                    ),
    );
  }

  Widget _buildRevenueChartSection(BuildContext context) {
    final data = [
      _RevenueData('Total Generado', _totalRevenue, Colors.blue),
      _RevenueData('Tu Ganancia', _enfermeroRevenue, Colors.green),
    ];

    final series = [
      charts.Series<_RevenueData, String>(
        id: 'Revenue',
        domainFn: (data, _) => data.category,
        measureFn: (data, _) => data.value,
        colorFn: (data, _) => charts.ColorUtil.fromDartColor(data.color),
        data: data,
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: charts.BarChart(
                series,
                animate: true,
                vertical: false,
                barRendererDecorator: charts.BarLabelDecorator<String>(),
                domainAxis: const charts.OrdinalAxisSpec(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedRequestsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Solicitudes Asignadas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ..._solicitudes.map((solicitud) {
          final status = solicitud['estado'] as String?;
          final servicio = solicitud['servicio'] as Map<String, dynamic>?;
          final organizacion = solicitud['organizacion'] as Map<String, dynamic>?;
          final ubicacion = solicitud['ubicacion'] as String?;
          final metodoPago = solicitud['metodo_pago'] as String?;
          final fechaServicio = solicitud['fecha_servicio'] as String?;
          final comentarios = solicitud['comentarios'] as String?;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showSolicitudDetails(
                  context,
                  servicio,
                  organizacion,
                  ubicacion,
                  metodoPago,
                  fechaServicio,
                  comentarios,
                );
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
                            'Solicitud #${solicitud['solicitud_id'] ?? 'N/A'}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      Icons.medical_services_outlined,
                      'Servicio',
                      servicio?['nombre'] ?? 'No disponible',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Icons.business_outlined,
                      'Organización',
                      organizacion?['nombre'] ?? 'No disponible',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today_outlined,
                      'Fecha de Solicitud',
                      _formatFecha(solicitud['fecha_solicitud']),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Icons.attach_money_outlined,
                      'Precio Estimado',
                      '\$${servicio?['precio_estimado'] ?? '0.00'}',
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showSolicitudDetails(
    BuildContext context,
    Map<String, dynamic>? servicio,
    Map<String, dynamic>? organizacion,
    String? ubicacion,
    String? metodoPago,
    String? fechaServicio,
    String? comentarios,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Detalles de la Solicitud',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Servicio', servicio?['nombre'] ?? 'No disponible'),
                _buildDetailRow('Organización', organizacion?['nombre'] ?? 'No disponible'),
                _buildDetailRow('Ubicación', ubicacion ?? 'No disponible'),
                _buildDetailRow('Método de Pago', metodoPago ?? 'No disponible'),
                _buildDetailRow('Fecha de Servicio', _formatFecha(fechaServicio)),
                _buildDetailRow('Comentarios', comentarios ?? 'No hay comentarios'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
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

class _RevenueData {
  final String category;
  final double value;
  final Color color;

  _RevenueData(this.category, this.value, this.color);
}