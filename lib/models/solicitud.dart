import 'dart:convert';
import 'package:flutter/material.dart';

class RequestModel {
  final dynamic solicitudId;
  final String usuarioId;
  final String pacienteId;
  final int? organizacionId;
  final int? enfermeroId;
  final String estado;
  final String metodoPago;
  final DateTime? fechaSolicitud;
  final DateTime? fechaServicio;
  final DateTime? fechaRespuesta;
  final String comentarios;
  final String ubicacion;
  final int pgSolicitudId;

  RequestModel({
    this.solicitudId,
    required this.usuarioId,
    required this.pacienteId,
    this.organizacionId,
    this.enfermeroId,
    required this.estado,
    required this.metodoPago,
    this.fechaSolicitud,
    this.fechaServicio,
    this.fechaRespuesta,
    String? comentarios,
    required this.ubicacion,
    required this.pgSolicitudId,

  }) : comentarios = comentarios ?? '';

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      solicitudId: json['_id'] ?? json['solicitud_id']?.toString(),
      usuarioId: json['usuario_id'] ?? '',
      pacienteId: json['paciente_id'] ?? '',
      organizacionId: json['organizacion_id'] ?? 0,
      enfermeroId: json['enfermero_id'] ?? 0,
      estado: json['estado'] ?? '',
      metodoPago: json['metodo_pago'] ?? '',
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.tryParse(json['fecha_solicitud'])
          : null,
      fechaServicio: json['fecha_servicio'] != null
          ? DateTime.tryParse(json['fecha_servicio'])
          : null,
      fechaRespuesta: json['fecha_respuesta'] != null
          ? DateTime.tryParse(json['fecha_respuesta'])
          : null,
      comentarios: json['comentarios'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      pgSolicitudId: json['pg_solicitud_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'paciente_id': pacienteId,
      'organizacion_id': organizacionId,
      'enfermero_id': enfermeroId,
      'estado': estado,
      'metodo_pago': metodoPago,
      'fecha_solicitud': fechaSolicitud?.toIso8601String(),
      'fecha_servicio': fechaServicio?.toIso8601String(),
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
