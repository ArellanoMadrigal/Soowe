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
      id: json['categoria_id'],
      nombre: json['nombre_categoria'],
      descripcion: json['descripcion'],
    );
  }
}