import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class RequestService {
  final ApiService _apiService = ApiService();

  // Obtener todas las solicitudes
  Future<List<Request>> getAllRequests({
    required int usuarioId,
    required int organizacionId,
  }) async {
    try {
      final response = await _apiService.dio.get(
        'api/mobile/solicitudes', // Corregido para usar la ruta correcta
        queryParameters: {
          'usuario_id': usuarioId,
          'organizacion_id': organizacionId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${_apiService.getAuthToken()}'},
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('Respuesta getAllRequests: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> solicitudes = response.data is List 
            ? response.data 
            : response.data['solicitudes'] ?? [];
            
        return solicitudes.map((data) => Request.fromJson(data)).toList();
      }
      throw Exception('Error al obtener las solicitudes');
    } on DioException catch (e) {
      debugPrint('Error en getAllRequests: ${e.response?.data}');
      throw _handleRequestError(e);
    } catch (e) {
      debugPrint('Error inesperado en getAllRequests: $e');
      throw Exception('Error al obtener las solicitudes: $e');
    }
  }

  // Crear una nueva solicitud
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
      final response = await _apiService.dio.post(
        'api/mobile/solicitudes',
        data: {
          'usuario_id': usuarioId,
          'paciente_id': pacienteId,
          'organizacion_id': organizacionId,
          'enfermero_id': enfermeroId,
          'metodo_pago': metodoPago,
          'fecha_solicitud': DateTime.now().toIso8601String(),
          'fecha_servicio': fechaServicio?.toIso8601String(),
          'estado': 'pending_assignment',
          'comentarios': comentarios ?? '',
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${_apiService.getAuthToken()}'},
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('Respuesta createRequest: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Request.fromJson(response.data);
      }

      throw Exception(response.data['message'] ?? 'Error al crear la solicitud');
    } on DioException catch (e) {
      debugPrint('Error en createRequest: ${e.response?.data}');
      throw _handleRequestError(e);
    }
  }

  // Actualizar una solicitud existente
  Future<Request> updateRequest(int solicitudId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.put(
        'api/mobile/solicitudes/$solicitudId',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${_apiService.getAuthToken()}'},
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('Respuesta updateRequest: ${response.data}');

      if (response.statusCode == 200) {
        return Request.fromJson(response.data);
      }

      throw Exception(response.data['message'] ?? 'Error al actualizar la solicitud');
    } on DioException catch (e) {
      debugPrint('Error en updateRequest: ${e.response?.data}');
      throw _handleRequestError(e);
    }
  }

  Exception _handleRequestError(DioException e) {
    final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Error desconocido';
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Error de conexión: Tiempo de espera agotado');
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
        }
        if (e.response?.statusCode == 422) {
          return Exception('Datos inválidos: $errorMessage');
        }
        return Exception('Error del servidor: $errorMessage');
      default:
        return Exception('Error de conexión: $errorMessage');
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
        estado: json['estado'] ?? 'pending_assignment',
        metodoPago: json['metodo_pago'] ?? '',
        fechaSolicitud: json['fecha_solicitud'] != null 
            ? DateTime.parse(json['fecha_solicitud']) 
            : DateTime.now(),
        fechaServicio: json['fecha_servicio'] != null 
            ? DateTime.parse(json['fecha_servicio'])
            : null,
        solicitudId: json['solicitud_id'] ?? json['id'] ?? 0,
        comentarios: json['comentarios'] ?? '',
      );
    } catch (e) {
      debugPrint('Error parseando Request: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
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