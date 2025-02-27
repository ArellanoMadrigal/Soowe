import 'package:flutter/material.dart';
import '../../services/services_service.dart';
import '../../models/service.dart';
import 'request_medical.dart';

class ListServiceScreen extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;
  final String categoryDescription;

  const ListServiceScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryDescription,
  });

  @override
  State<ListServiceScreen> createState() => _ListServiceScreenState();
}

class _ListServiceScreenState extends State<ListServiceScreen> {
  final ServicesService _servicesService = ServicesService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services =
          await _servicesService.getServicesFromCategory(widget.categoryId);
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text(
            'No se pudieron cargar los servicios. Por favor, intenta de nuevo más tarde.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _navigateToRequestMedical(ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestMedicalScreen(
            service: service,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.categoryTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                SliverToBoxAdapter(
                  child: _CategorySection(
                    categoryDescription: widget.categoryDescription,
                    services: _services,
                    onServiceTap: _navigateToRequestMedical,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String categoryDescription;
  final List<ServiceModel> services;
  final Function(ServiceModel) onServiceTap;

  const _CategorySection({
    required this.categoryDescription,
    required this.services,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección de descripción de la categoría
        Container(
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline, // Ícono relacionado con la descripción
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  categoryDescription,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 3, // Limita el número de líneas
                  overflow: TextOverflow.ellipsis, // Añade puntos suspensivos si el texto es muy largo
                ),
              ),
            ],
          ),
        ),
        // Lista de servicios
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return _ServiceCard(
              service: services[index],
              onTap: () => onServiceTap(services[index]),
            );
          },
        ),
      ],
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