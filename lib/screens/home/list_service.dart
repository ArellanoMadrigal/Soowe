import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'solicit_medical.dart';

class ServiceCategory {
  final String id;
  final String title;
  final List<Service> services;

  ServiceCategory({
    required this.id,
    required this.title,
    required this.services,
  });
}

class Service {
  final String id;
  final String title;
  final String description;
  final double price;
  

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    
  });
}

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
  final ApiService _apiService = ApiService();
  List<ServiceCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

Future<void> _loadServices() async {
  try {
    // Simular carga de datos de la API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _categories = [
        ServiceCategory(
          id: '1',
          title: 'Servicios de Sutura',
          services: [
            Service(
              id: '1',
              title: 'Sutura de heridas',
              description: 'Sutura profesional de heridas para una cicatrización adecuada.',
              price: 400.00,
            ),
            Service(
              id: '2',
              title: 'Retiro de Suturas',
              description: 'Retiro seguro y profesional de suturas después de la cicatrización.',
              price: 200.00,
            ),
            Service(
              id: '3',
              title: 'Sutura de Laceraciones Profundas',
              description: 'Tratamiento especializado para heridas profundas que requieren múltiples capas de sutura.',
              price: 600.00,
            ),
            Service(
              id: '4',
              title: 'Sutura Estética',
              description: 'Técnica especial de sutura para minimizar cicatrices en zonas visibles.',
              price: 800.00,
            ),
            Service(
              id: '5',
              title: 'Sutura de Emergencia',
              description: 'Servicio urgente de sutura disponible 24/7 para casos que requieren atención inmediata.',
              price: 750.00,
            ),
            Service(
              id: '6',
              title: 'Revisión y Seguimiento de Suturas',
              description: 'Evaluación del proceso de cicatrización y estado de las suturas con recomendaciones de cuidado.',
              price: 150.00,
            ),
            Service(
              id: '7',
              title: 'Sutura Pediátrica',
              description: 'Servicio especializado de suturas para niños con técnicas y materiales adaptados.',
              price: 500.00,
            ),
            Service(
              id: '8',
              title: 'Limpieza y Sutura',
              description: 'Servicio completo que incluye limpieza profunda de la herida antes de la sutura.',
              price: 550.00,
            ),
            Service(
              id: '9',
              title: 'Sutura con Técnicas Especiales',
              description: 'Aplicación de técnicas avanzadas de sutura para casos complejos o específicos.',
              price: 700.00,
            ),
            Service(
              id: '10',
              title: 'Sutura Post-Quirúrgica',
              description: 'Servicio de sutura especializado para heridas post-operatorias.',
              price: 650.00,
            ),
          ],
        ),
      ];
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
        content: const Text('No se pudieron cargar los servicios. Por favor, intenta de nuevo más tarde.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _navigateToSolicitMedical(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolicitMedicalScreen(
          
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
                ...List.generate(_categories.length, (index) {
                  final category = _categories[index];
                  return SliverToBoxAdapter(
                    child: _CategorySection(
                      category: category,
                      onServiceTap: _navigateToSolicitMedical,
                    ),
                  );
                }),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final ServiceCategory category;
  final Function(Service) onServiceTap;

  const _CategorySection({
    required this.category,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Text(
            category.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: category.services.length,
          itemBuilder: (context, index) {
            return _ServiceCard(
              service: category.services[index],
              onTap: () => onServiceTap(category.services[index]),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
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
              Text(
                service.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    '\$${service.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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