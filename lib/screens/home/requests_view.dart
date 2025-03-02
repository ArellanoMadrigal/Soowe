import 'package:flutter/material.dart';
import 'models.dart';
import 'medical_request_card.dart';

class RequestsView extends StatefulWidget {
  final List<MedicalRequest> requests;

  const RequestsView({
    Key? key,
    required this.requests,
  }) : super(key: key);

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  bool _isLoading = false;
  List<MedicalRequest> _filteredRequests = [];
  String _selectedFilter = 'todos';

  @override
  void initState() {
    super.initState();
    _filteredRequests = widget.requests;
  }

  @override
  void didUpdateWidget(RequestsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requests != widget.requests) {
      _filterRequests(_selectedFilter);
    }
  }

  void _filterRequests(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'activos':
          _filteredRequests = widget.requests
              .where((r) => r.status == 'active')
              .toList();
          break;
        case 'pendientes':
          _filteredRequests = widget.requests
              .where((r) => r.status == 'pending')
              .toList();
          break;
        case 'en_progreso':
          _filteredRequests = widget.requests
              .where((r) => r.status == 'in_progress')
              .toList();
          break;
        case 'completados':
          _filteredRequests = widget.requests
              .where((r) => r.status == 'completed')
              .toList();
          break;
        default:
          _filteredRequests = widget.requests;
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
                  onSelected: (selected) => _filterRequests('todos'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Activos',
                  selected: _selectedFilter == 'activos',
                  onSelected: (selected) => _filterRequests('activos'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pendientes',
                  selected: _selectedFilter == 'pendientes',
                  onSelected: (selected) => _filterRequests('pendientes'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'En Progreso',
                  selected: _selectedFilter == 'en_progreso',
                  onSelected: (selected) => _filterRequests('en_progreso'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completados',
                  selected: _selectedFilter == 'completados',
                  onSelected: (selected) => _filterRequests('completados'),
                ),
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
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay solicitudes ${_selectedFilter != "todos" ? "con este filtro" : ""}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          // La actualización se maneja desde el HomeScreen
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredRequests.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final request = _filteredRequests[index];
                            return MedicalRequestCard(
                              request: request,
                              onTap: () {
                                // Navegar al detalle de la solicitud
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
  final Function(bool) onSelected;

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
      onSelected: onSelected,
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary.withOpacity(0.12),
      side: BorderSide(
        color: selected ? Colors.transparent : colorScheme.outline.withOpacity(0.12),
      ),
      labelStyle: TextStyle(
        color: selected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
      ),
      showCheckmark: false,
    );
  }
}