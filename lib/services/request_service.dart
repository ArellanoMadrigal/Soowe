import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class RequestService {
  final ApiService _apiService = ApiService();

  Future<List<Request>> getAllRequests({
    required int usuarioId,
    required int organizacionId,
  }) async {
    try {
      final requestsData = await _apiService.getAllRequests();
      
      return requestsData.map((data) => Request.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en getAllRequests: $e');
      rethrow;
    }
  }

  Future<Request> createRequest({
  required int usuarioId,
  required int pacienteId,
  required String metodoPago,
  int? organizacionId,
  int? enfermeroId,
  DateTime? fechaServicio,
  String? comentarios,
}) async {
  try {
    final requestData = {
      'usuario_id': usuarioId,
      'paciente_id': pacienteId,
      'organizacion_id': organizacionId,
      'enfermero_id': enfermeroId,
      'metodo_pago': metodoPago.toLowerCase(),
      'fecha_solicitud': DateTime.now().toIso8601String(),
      'fecha_servicio': fechaServicio?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'comentarios': comentarios ?? '',
      'estado': 'pending_assignment',
      'created_at': '2025-02-20 04:56:32',
      'created_by': 'ArellanoMadrigal'
    };

    final response = await _apiService.createMedicalRequest(requestData);
    return Request.fromJson(response);
  } catch (e) {
    debugPrint('Error en createRequest: $e');
    rethrow;
  }
}

  Future<Request> updateRequest(int solicitudId, Map<String, dynamic> data) async {
    try {
      final success = await _apiService.updateRequest(solicitudId.toString(), data);
      if (success) {
        // Obtener los datos actualizados
        final requestDetails = await _apiService.getRequestDetails(solicitudId.toString());
        return Request.fromJson(requestDetails);
      }
      throw Exception('Error al actualizar la solicitud');
    } catch (e) {
      debugPrint('Error en updateRequest: $e');
      rethrow;
    }
  }
}

class Request {
  final String id; // Cambiado de int a String
  final String usuarioId; // Cambiado de int a String
  final String pacienteId; // Cambiado de int a String
  final String? organizacionId; // Cambiado de int a String
  final String? enfermeroId; // Cambiado de int a String
  final String estado;
  final String metodoPago;
  final DateTime fechaSolicitud;
  final DateTime? fechaServicio;
  final String solicitudId; // Cambiado de int a String
  final String comentarios;

  Request({
    required this.id,
    required this.usuarioId,
    required this.pacienteId,
    this.organizacionId,
    this.enfermeroId,
    required this.estado,
    required this.metodoPago,
    required this.fechaSolicitud,
    this.fechaServicio,
    required this.solicitudId,
    this.comentarios = '',
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    try {
      return Request(
        id: json['id'].toString(),
        usuarioId: json['usuario_id'].toString(),
        pacienteId: json['paciente_id'].toString(),
        organizacionId: json['organizacion_id']?.toString(),
        enfermeroId: json['enfermero_id']?.toString(),
        estado: json['status'] ?? json['estado'] ?? 'pending_assignment',
        metodoPago: json['metodo_pago'] ?? '',
        fechaSolicitud: json['fecha_solicitud'] != null 
            ? DateTime.parse(json['fecha_solicitud']) 
            : DateTime.now(),
        fechaServicio: json['fecha_servicio'] != null 
            ? DateTime.parse(json['fecha_servicio'])
            : null,
        solicitudId: json['solicitud_id']?.toString() ?? json['id'].toString(),
        comentarios: json['comentarios'] ?? '',
      );
    } catch (e) {
      debugPrint('Error parseando Request: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'paciente_id': pacienteId,
    'organizacion_id': organizacionId,
    'enfermero_id': enfermeroId,
    'estado': estado,
    'metodo_pago': metodoPago,
    'fecha_solicitud': fechaSolicitud.toIso8601String(),
    'fecha_servicio': fechaServicio?.toIso8601String(),
    'solicitud_id': solicitudId,
    'comentarios': comentarios,
  };
}