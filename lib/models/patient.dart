import 'dart:convert';

class PatientModel {
  final String? id;
  final String nombre;
  final String descripcion;
  final List<String> alergias;
  final String? estado;
  final String? cuidadosNecesarios;
  final String usuarioId;

  PatientModel({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.alergias,
    this.estado,
    this.cuidadosNecesarios,
    required this.usuarioId,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      alergias: List<String>.from(json['alergias'] ?? ['Ninguna']),
      estado: json['estado'] ?? 'En espera',
      cuidadosNecesarios: json['cuidados_necesarios'] ?? 'Ninguno',
      usuarioId: json['usuario_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'alergias': alergias,
      'estado': estado,
      'cuidados_necesarios': cuidadosNecesarios,
      'usuario_id': usuarioId,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
