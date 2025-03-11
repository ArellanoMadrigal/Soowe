import 'package:appdesarrollo/models/full_solicitud.dart';
import 'package:flutter/material.dart';
import '../../models/patient.dart';

class MedicalRequestCard extends StatelessWidget {
  final RequestCompleteModel request;
  final PatientModel patient;
  final Servicio service;
  final VoidCallback onTap;

  const MedicalRequestCard({
    super.key,
    required this.request,
    required this.patient,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Verificar si la solicitud está pendiente
    bool isPending = request.estado.toLowerCase() == 'pendiente';

    debugPrint("Organización: ${request.organizacion?.nombre}");
    debugPrint("Enfermero: ${request.enfermero?.nombre}");

    return Card(
      elevation: 4,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.estado).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(request.estado),
                      style: TextStyle(
                        color: _getStatusColor(request.estado),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(context, request.fechaSolicitud),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                service.nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    patient.nombre,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.ubicacion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Mostrar solo si no es una solicitud pendiente
              if (!isPending) ...[
                Row(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.organizacion?.nombre ?? "No asignado",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.enfermero?.nombre ?? "No asignado",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ] else ...[
                // Mostrar algo diferente si la solicitud está pendiente
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Pendiente - Sin asignar",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getPaymentIcon(request.metodoPago),
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    service.precioEstimado,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w200,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'asignado':
        return Colors.blue;
      case 'completado':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return 'Activo';
      case 'pendiente':
        return 'Pendiente';
      case 'asignado':
        return 'Asignado';
      case 'completado':
        return 'Completado';
      default:
        return 'Desconocido';
    }
  }

  String _formatDateTime(BuildContext context, DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${TimeOfDay.fromDateTime(date).format(context)}';
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'tarjeta':
        return Icons.credit_card;
      case 'efectivo':
        return Icons.attach_money;
      default:
        return Icons.payment;
    }
  }
}
