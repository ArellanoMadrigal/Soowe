import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;


class RequestsView extends StatelessWidget {
  
  
  final List<Map<String, dynamic>> requests;

  const RequestsView({
    super.key, 
    required this.requests
  });

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
        body: TabBarView(
          children: [
            _RequestList(
              requests: requests.where((r) => r['status'] == 'active').toList(),
              isActive: true,
            ),
            _RequestList(
              requests: requests.where((r) => r['status'] != 'active').toList(),
              isActive: false,
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

  const _RequestList({
    required this.requests,
    required this.isActive,
  });

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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = requests[index];
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
                      backgroundColor: isActive
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        isActive
                            ? Icons.medical_services_outlined
                            : Icons.check_circle_outline,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['service']['title'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isActive ? Icons.timer_outlined : Icons.check_circle,
                                size: 16,
                                color: isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'En progreso' : 'Completada',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isActive
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.secondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
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
                ],
              ],
            ),
          ),
        );
      },
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
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.pending_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Pendiente de Asignación',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildSection(
                  context,
                  'Detalles del Servicio',
                  Icons.medical_services_outlined,
                  [
                    _buildDetailRow('Servicio', request['service']['title']),
                    _buildDetailRow('Fecha', request['date']),
                    _buildDetailRow('Hora', request['time']),
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

                _buildSection(
                  context,
                  'Información del Paciente',
                  Icons.person_outline,
                  [
                    _buildDetailRow('Nombre', request['patient']['name']),
                    _buildDetailRow('Edad', '${request['patient']['age']} años'),
                    _buildDetailRow('Teléfono', request['patient']['phone']),
                    _buildDetailRow('Condición', request['patient']['condition']),
                  ],
                ),

                const SizedBox(height: 16),

                _buildSection(
                  context,
                  'Ubicación del Servicio',
                  Icons.location_on_outlined,
                  [
                    _buildDetailRow('Dirección', request['location']['address']),
                  ],
                ),

                const SizedBox(height: 16),

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
}