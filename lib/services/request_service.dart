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
      final response = await _apiService.dio.get(
        '/solicitudes',
        queryParameters: {
          'usuario_id': usuarioId,
          'organizacion_id': organizacionId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${_apiService.getAuthToken()}'},
        ),
      );

      debugPrint('Respuesta getAllRequests: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // Asegurarse de que response.data sea una lista
        final List<dynamic> solicitudes = response.data is List 
            ? response.data 
            : response.data['solicitudes'] ?? [];
            
        return solicitudes.map((data) => Request.fromJson(data)).toList();
      }
      throw Exception('Error al obtener las solicitudes');
    } on DioException catch (e) {
      debugPrint('Error en getAllRequests: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error inesperado en getAllRequests: $e');
      throw Exception('Error al obtener las solicitudes: $e');
    }
  }
}

class Request {
  final int id;
  final int usuarioId;
  final int pacienteId;
  final int? organizacionId;
  final int? enfermeroId;
  final String estado;
  final String metodoPago;
  final DateTime fechaSolicitud;
  final DateTime? fechaServicio;
  final int solicitudId;
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
        id: json['id'] ?? 0,
        usuarioId: json['usuario_id'] ?? 0,
        pacienteId: json['paciente_id'] ?? 0,
        organizacionId: json['organizacion_id'],
        enfermeroId: json['enfermero_id'],
        estado: json['estado'] ?? '',
        metodoPago: json['metodo_pago'] ?? '',
        fechaSolicitud: json['fecha_solicitud'] != null 
            ? DateTime.parse(json['fecha_solicitud']) 
            : DateTime.now(),
        fechaServicio: json['fecha_servicio'] != null 
            ? DateTime.parse(json['fecha_servicio'])
            : null,
        solicitudId: json['solicitud_id'] ?? 0,
        comentarios: json['comentarios'] ?? '',
      );
    } catch (e) {
      debugPrint('Error parseando Request: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
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
}