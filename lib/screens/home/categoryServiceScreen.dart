import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/service.dart';
import '../../services/services_service.dart';

class CategoryServicesScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryServicesScreen({super.key, required this.category});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryServicesScreenState createState() => _CategoryServicesScreenState();
}

class _CategoryServicesScreenState extends State<CategoryServicesScreen> {
  final ServicesService _serviceService = ServicesService();
  late Future<List<ServiceModel>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _serviceService.getServicesFromCategory(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.nombre)),
      body: FutureBuilder<List<ServiceModel>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay servicios disponibles.'));
          }

          final services = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(service.nombre),
                subtitle: Text('${service.descripcion} enfermeros disponibles'),
                // agregar precio estimado
                leading: const Icon(Icons.medical_services_outlined),
                onTap: () {
                  // Acción al seleccionar un servicio
                },
              );
            },
          );
        },
      ),
    );
  }
}
