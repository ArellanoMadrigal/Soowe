import 'package:flutter/material.dart';
import '../../services/services_service.dart';
import '../../models/service.dart';
import 'request_medical.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ServicesService _serviceService = ServicesService();
  final ScrollController _scrollController = ScrollController();

  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadServices() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    final services = await _serviceService.getServices();
    if (services.isEmpty) {
      setState(() => _hasMore = false);
    } else {
      setState(() {
        _allServices.addAll(services);
        _filteredServices = _allServices.take((_currentPage + 1) * _itemsPerPage).toList();
        _currentPage++;
      });
    }

    setState(() => _isLoading = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadServices();
    }
  }

  void _filterServices(String query) {
    setState(() {
      _filteredServices = _allServices
          .where((service) =>
              service.nombre.toLowerCase().contains(query.toLowerCase()) ||
              service.descripcion.toLowerCase().contains(query.toLowerCase()))
          .take((_currentPage + 1) * _itemsPerPage)
          .toList();
    });
  }

  void _navigateToRequestMedical(ServiceModel service) {
    debugPrint("Servicio seleccionado: ${service.toJson()}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestMedicalScreen(service: service),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _filterServices,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar servicios...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredServices.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _filteredServices.length) {
            final service = _filteredServices[index];
            return _ServiceCard(
              service: service,
              onTap: () => _navigateToRequestMedical(service),
            );
          } else {
            return const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ));
          }
        },
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2, // Añade una sombra sutil
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del servicio
              Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.nombre,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Descripción del servicio
              Text(
                service.descripcion,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Precio del servicio
              Row(
                children: [
                  const Spacer(),
                  Text(
                    '\$${double.parse(service.precioEstimado).toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
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
}
