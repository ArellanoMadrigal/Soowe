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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.medical_services_outlined, color: Colors.blue),
                  title: Text(service.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.descripcion),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('${service.precioEstimado} MXN', style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
