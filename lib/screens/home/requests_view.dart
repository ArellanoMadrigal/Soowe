import 'package:flutter/material.dart';
import '../../models/solicitud.dart';
import 'medical_request_card.dart';
import '../../services/auth_service.dart';
import '../../models/patient.dart';
import '../../services/request_service.dart';
import '../../services/patient_service.dart';
import '../../models/full_solicitud.dart';

class RequestsView extends StatefulWidget {
  final List<RequestModel> requests;

  const RequestsView({super.key, required this.requests});

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  bool _isLoading = true;
  List<RequestModel> _requests = [];
  List<RequestModel> _filteredRequests = [];
  String _selectedFilter = 'todos';
  final RequestService _requestService = RequestService();
  final AuthService _authService = AuthService();
  final PatientService _patientService = PatientService();

  @override
  void initState() {
    super.initState();
    _loadUserRequests();
  }

  Future<void> _loadUserRequests() async {
    setState(() => _isLoading = true);

    final userId = _authService.getCurrentUserId();
    if (userId != null) {
      final fetchedRequests = await _requestService.getAllUserRequests(userId);
      setState(() {
        _requests = fetchedRequests.cast<RequestModel>();
        _filteredRequests = _requests;
        _isLoading = false;
      });
    } else {
      setState(() {
        _requests = [];
        _filteredRequests = [];
        _isLoading = false;
      });
    }
  }

  void _filterRequests(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'pendientes':
          _filteredRequests =
              _requests.where((r) => r.estado == 'pendiente').toList();
          break;
        case 'asignados':
          _filteredRequests =
              _requests.where((r) => r.estado == 'asignado').toList();
          break;
        case 'completados':
          _filteredRequests =
              _requests.where((r) => r.estado == 'completado').toList();
          break;
        default:
          _filteredRequests = _requests;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                    label: 'Todos',
                    selected: _selectedFilter == 'todos',
                    onSelected: () => _filterRequests('todos')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'Pendientes',
                    selected: _selectedFilter == 'pendientes',
                    onSelected: () => _filterRequests('pendientes')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'Asignados',
                    selected: _selectedFilter == 'asignados',
                    onSelected: () => _filterRequests('asignados')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'Completados',
                    selected: _selectedFilter == 'completados',
                    onSelected: () => _filterRequests('completados')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRequests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline),
                            const SizedBox(height: 16),
                            Text(
                              'No hay solicitudes ${_selectedFilter != "todos" ? "con este filtro" : ""}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUserRequests,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredRequests.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final request = _filteredRequests[index];
                            return FutureBuilder(
                              future: Future.wait([
                                _requestService.getRequestById(request.pgSolicitudId),
                                _patientService.getPatientById(request.pacienteId),
                              ]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text("Error: ${snapshot.error}"));
                                } else if (snapshot.hasData) {
                                  // Asegúrate de acceder a los datos correctamente
                                  final fullRequest = snapshot.data?[0] as RequestCompleteModel;
                                  final patientData = snapshot.data?[1] as PatientModel;

                                  return MedicalRequestCard(
                                    request: fullRequest,
                                    patient: patientData,
                                    service: fullRequest.servicio,  // Accede directamente al servicio
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RequestDetailScreen(request: request),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return const Center(child: Text("No se encontró la solicitud"));
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary.withOpacity(0.12),
      side: BorderSide(
          color: selected
              ? Colors.transparent
              : colorScheme.outline.withOpacity(0.12)),
      labelStyle: TextStyle(
          color: selected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w500 : FontWeight.normal),
      showCheckmark: false,
    );
  }
}

// Pantalla de detalle de la solicitud
class RequestDetailScreen extends StatelessWidget {
  final RequestModel request;
  final RequestService _requestService = RequestService();
  final PatientService _patientService = PatientService();

  RequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _requestService.getRequestById(request.pgSolicitudId),
        _patientService.getPatientById(request.pacienteId),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text("Detalle de la Solicitud")),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Detalle de la Solicitud")),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else {
          final fullRequest = snapshot.data?[0] as RequestCompleteModel;
          final patientData = snapshot.data?[1] as PatientModel;

          // Asegúrate de acceder a los valores del Map y no a índices como en una lista
          return Scaffold(
            appBar: AppBar(title: Text("Detalle de la Solicitud")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Servicio: ${fullRequest.servicio.nombre}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Estado: ${fullRequest.estado}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Paciente: ${patientData.nombre}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ubicación: ${fullRequest.ubicacion}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fecha: ${fullRequest.fechaSolicitud.toString()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // Precio del servicio con estilo destacado
                  Row(
                    children: [
                      Text("Precio: ",
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        fullRequest.servicio.precioEstimado,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
