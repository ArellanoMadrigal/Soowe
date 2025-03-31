import 'dart:convert';

class NotificationModel {
  String receptorId;
  String tipoReceptor;
  String titulo;
  String contenido;
  DateTime fechaCreacion;
  bool leida;
  String? estadoAsignacion;
  bool activo;

  NotificationModel({
    required this.receptorId,
    required this.tipoReceptor,
    required this.titulo,
    required this.contenido,
    required this.fechaCreacion,
    required this.leida,
    this.estadoAsignacion,
    required this.activo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      receptorId: json['receptorId'] ?? '',
      tipoReceptor: json['tipoReceptor'] ?? '',
      titulo: json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      fechaCreacion: DateTime.parse(json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      leida: json['leida'] ?? false,
      estadoAsignacion: json['estadoAsignacion'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receptorId': receptorId,
      'tipoReceptor': tipoReceptor,
      'titulo': titulo,
      'contenido': contenido,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'leida': leida,
      'estadoAsignacion': estadoAsignacion,
      'activo': activo,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
