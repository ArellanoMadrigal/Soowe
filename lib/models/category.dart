import 'dart:convert';

class CategoryModel {
  final int id;
  final String nombre;
  final String descripcion;

  CategoryModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['categoria_id'] ?? 0,
      nombre: json['nombre_categoria'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria_id': id,
      'nombre_categoria': nombre,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
