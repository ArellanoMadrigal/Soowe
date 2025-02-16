import 'package:flutter/material.dart';
import 'solicit_medical.dart';


class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _showSuggestions = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Lista de servicios populares
  final List<_CategoryData> _popularServices = [
    _CategoryData('Administración de Medicamentos', 890),
    _CategoryData('Curaciones y Vendajes', 856),
    _CategoryData('Control de Signos Vitales', 832),
    _CategoryData('Cuidados Post-Operatorios', 815),
  ];

  // Lista de servicios destacados
  final List<_CategoryData> _featuredServices = [
    _CategoryData('Aplicación de Inyecciones', 798),
    _CategoryData('Toma de Muestras', 765),
    _CategoryData('Cuidados de Sonda Vesical', 743),
    _CategoryData('Cuidados de Úlceras', 721),
    _CategoryData('Sonda Nasogástrica', 698),
    _CategoryData('Rehabilitación Básica', 676),
    _CategoryData('Cuidados de Ostomías', 654),
    _CategoryData('Control de Diabetes', 632),
    _CategoryData('Terapia de Oxígeno', 610),
    _CategoryData('Aspiración de Secreciones', 589),
    _CategoryData('Cuidados Paliativos', 567),
    _CategoryData('Nutrición Enteral', 545),
    _CategoryData('Cuidados Geriátricos', 523),
    _CategoryData('Terapia Física', 501),
    _CategoryData('Bombas de Infusión', 478),
    _CategoryData('Heridas Crónicas', 456),
    _CategoryData('Control de Presión', 434),
    _CategoryData('Cuidados Neonatales', 412),
    _CategoryData('Electrocardiogramas', 390),
    _CategoryData('Terapia Respiratoria', 368),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<_CategoryData> get _allServices => [..._popularServices, ..._featuredServices];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search Header with integrated back button
          SafeArea(
            bottom: false,
            child: Hero(
              tag: 'searchBar',
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Icon(Icons.search, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Buscar servicio...',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (value) {
                              setState(() => _showSuggestions = value.length >= 3);
                            },
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Material(
                            type: MaterialType.transparency,
                            child: IconButton(
                              icon: const Icon(Icons.clear, size: 22),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _showSuggestions = false);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content with Animations
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showSuggestions
                  ? _buildSuggestions()
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Servicios Populares',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _PopularServicesGrid(services: _popularServices),
                              const SizedBox(height: 32),
                              Text(
                                'Servicios Destacados',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _FeaturedServicesGrid(services: _featuredServices),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = _allServices
        .where((service) =>
            service.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.medical_services_outlined, size: 20),
          title: Text(suggestion.name),
          subtitle: Text('${suggestion.nursesCount} enfermeros disponibles'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SolicitMedicalScreen(),
              ),
            );
          },
        );
      },
    );
  }
}

class _PopularServicesGrid extends StatelessWidget {
  final List<_CategoryData> services;

  const _PopularServicesGrid({required this.services});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return _ServiceCard(
              category: services[index],
              isPopular: true,
            );
          },
        );
      },
    );
  }
}

class _FeaturedServicesGrid extends StatelessWidget {
  final List<_CategoryData> services;

  const _FeaturedServicesGrid({required this.services});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return _ServiceCard(
              category: services[index],
              isPopular: false,
            );
          },
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _CategoryData category;
  final bool isPopular;

  const _ServiceCard({
    required this.category,
    required this.isPopular,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: isPopular 
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SolicitMedicalScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.nursesCount} enfermeros',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPopular 
                      ? colorScheme.onPrimaryContainer 
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final int nursesCount;

  _CategoryData(this.name, this.nursesCount);
}