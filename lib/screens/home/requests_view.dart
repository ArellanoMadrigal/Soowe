import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../../services/api_service.dart';

// Clase principal
class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

// Estado de la clase principal
class _RequestsViewState extends State<RequestsView> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final requests = await _apiService.getAllRequests();
      
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Mis Solicitudes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRequests,
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.healing_outlined),
                text: 'Activas',
              ),
              Tab(
                icon: Icon(Icons.history_outlined),
                text: 'Historial',
              ),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.outline,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar las solicitudes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRequests,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    children: [
                      _RequestList(
                        requests: _requests.where((r) => 
                          r['status'] == 'pending_assignment' || 
                          r['status'] == 'assigned' || 
                          r['status'] == 'in_progress'
                        ).toList(),
                        isActive: true,
                        onRefresh: _loadRequests,
                      ),
                      _RequestList(
                        requests: _requests.where((r) => 
                          r['status'] == 'completed' || 
                          r['status'] == 'cancelled'
                        ).toList(),
                        isActive: false,
                        onRefresh: _loadRequests,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final bool isActive;
  final VoidCallback onRefresh;

  const _RequestList({
    required this.requests,
    required this.isActive,
    required this.onRefresh,
  });

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_assignment':
        return 'Pendiente de asignar';
      case 'assigned':
        return 'Enfermero asignado';
      case 'in_progress':
        return 'En proceso';
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Estado desconocido';
    }
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'pending_assignment':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending_assignment':
        return Icons.pending_outlined;
      case 'assigned':
        return Icons.person_outline;
      case 'in_progress':
        return Icons.healing_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.healing_outlined : Icons.history_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? 'No tienes solicitudes activas'
                  : 'No tienes solicitudes en tu historial',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'Las solicitudes aparecerán aquí cuando las crees'
                  : 'El historial de solicitudes aparecerá aquí',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = requests[index];
          final status = request['status'] as String;
          final statusColor = _getStatusColor(status, context);

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: statusColor.withOpacity(0.2),
                        child: Icon(
                          _getStatusIcon(status),
                          color: statusColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request['service']['title'] ?? 'Servicio médico',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 16,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusText(status),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: statusColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fecha: ${request['date']} - ${request['time']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              _showRequestDetails(context, request);
                            },
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('Ver detalles'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (status == 'pending_assignment') ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              _showCancelDialog(context, request);
                            },
                            icon: const Icon(Icons.cancel_outlined),
                            color: Colors.red,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  // Continuación de la clase _RequestList
  void _showCancelDialog(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Solicitud'),
        content: const Text('¿Estás seguro que deseas cancelar esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final apiService = ApiService();
                await apiService.updateRequest(
                  request['id'].toString(),
                  {'status': 'cancelled'},
                );
                onRefresh(); // Actualizar la lista
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalles de la Solicitud',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Estado de la solicitud
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request['status'], context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(request['status']),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _getStatusText(request['status']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  'Detalles del Servicio',
                  Icons.medical_services_outlined,
                  [
                    _buildDetailRow('Servicio', request['service']['title'] ?? ''),
                    _buildDetailRow('Fecha', request['date'] ?? ''),
                    _buildDetailRow('Hora', request['time'] ?? ''),
                    if (request['service']['price'] != null)
                      _buildDetailRow(
                        'Precio', 
                        NumberFormat.currency(
                          symbol: '\$', 
                          decimalDigits: 2
                        ).format(request['service']['price'])
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),

                // Información del paciente
                _buildSection(
                  context,
                  'Información del Paciente',
                  Icons.person_outline,
                  [
                    _buildDetailRow('Nombre', request['patient']['name'] ?? ''),
                    _buildDetailRow('Edad', '${request['patient']['age'] ?? ''} años'),
                    _buildDetailRow('Teléfono', request['patient']['phone'] ?? ''),
                    _buildDetailRow('Condición', request['patient']['condition'] ?? ''),
                  ],
                ),

                const SizedBox(height: 16),

                // Ubicación del servicio
                _buildSection(
                  context,
                  'Ubicación del Servicio',
                  Icons.location_on_outlined,
                  [
                    _buildDetailRow('Dirección', request['location']['address'] ?? ''),
                  ],
                ),

                const SizedBox(height: 16),

                // Información de pago
                _buildSection(
                  context,
                  'Información de Pago',
                  Icons.payment_outlined,
                  [
                    _buildDetailRow(
                      'Método', 
                      request['payment']['method'] == 'card' 
                        ? 'Tarjeta de Crédito/Débito' 
                        : 'Efectivo'
                    ),
                    _buildDetailRow('Estado', 'Pago Procesado'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} // Fin de la clase _RequestList