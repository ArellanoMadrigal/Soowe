import 'dart:convert';

class ServiceModel {
  int serviciosId;
  String nombre;
  String precioEstimado;
  String descripcion;
  int categoriaId;

  ServiceModel({
    required this.serviciosId,
    required this.nombre,
    required this.precioEstimado,
    required this.descripcion,
    required this.categoriaId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviciosId: json['servicios_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      precioEstimado: json['precio_estimado'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoriaId: json['categoria_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'servicios_id': serviciosId,
      'nombre': nombre,
      'precio_estimado': precioEstimado,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
