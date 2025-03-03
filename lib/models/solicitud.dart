import 'dart:convert';
import 'package:flutter/material.dart';

class RequestModel {
  final int? solicitudId;
  final String usuarioId;
  final String pacienteId;
  final int? organizacionId;
  final int? enfermeroId;
  final String estado;
  final String metodoPago;
  final DateTime fechaSolicitud;
  final DateTime fechaServicio;
  final DateTime? fechaRespuesta;
  final String? comentarios;
  final String ubicacion;

  RequestModel({
    this.solicitudId,
    required this.usuarioId,
    required this.pacienteId,
    this.organizacionId,
    this.enfermeroId,
    required this.estado,
    required this.metodoPago,
    required this.fechaSolicitud,
    required this.fechaServicio,
    this.fechaRespuesta,
    this.comentarios,
    required this.ubicacion,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      usuarioId: json['usuario_id'],
      pacienteId: json['paciente_id'],
      organizacionId: json['organizacion_id'],
      enfermeroId: json['enfermero_id'],
      estado: json['estado'],
      metodoPago: json['metodo_pago'],
      fechaSolicitud: DateTime.parse(json['fecha_solicitud']),
      fechaServicio: DateTime.parse(json['fecha_servicio']),
      fechaRespuesta: _parseFechaRespuesta(json['fecha_respuesta']),
      comentarios: json['comentarios'],
      ubicacion: json['ubicacion'],
    );
  }

  static DateTime? _parseFechaRespuesta(dynamic fechaServicio) {
    if (fechaServicio == null || fechaServicio.toString().isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(fechaServicio.toString());
    } catch (e) {
      debugPrint('Error parsing fecha_servicio: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'paciente_id': pacienteId,
      'organizacion_id': organizacionId,
      'enfermero_id': enfermeroId,
      'estado': estado,
      'metodo_pago': metodoPago,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'fecha_servicio': fechaServicio.toIso8601String(),
      'fecha_respuesta': fechaRespuesta?.toIso8601String(),
      'comentarios': comentarios,
      'ubicacion': ubicacion,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
