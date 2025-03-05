import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/solicitud.dart';

class RequestService {
  final ApiService _apiService = ApiService();

  Future<List<RequestModel>> getAllRequests({
    required String usuarioId,
    required int organizacionId,
  }) async {
    try {
      final requestsData = await _apiService.getAllRequests();

      return requestsData.map((data) => RequestModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en getAllRequests: $e');
      rethrow;
    }
  }

  Future<RequestModel> createRequest({
    required String usuarioId,
    required String pacienteId,
    required int serviciosId,
    required String metodoPago,
    required String estado,
    required String ubicacion,
    required DateTime fechaSolicitud,
    String? enfermeroId,
    DateTime? fechaServicio,
    String? comentarios,
  }) async {
    try {
      debugPrint('servicios_id en request_service: $serviciosId');
      final requestData = {
        'usuario_id': usuarioId,
        'paciente_id': pacienteId,
        'servicios_id': serviciosId,
        'estado': estado.toLowerCase(),
        'enfermero_id': enfermeroId,
        'metodo_pago': metodoPago.toLowerCase(),
        'fecha_solicitud': fechaSolicitud.toIso8601String(),
        'fecha_servicio': fechaServicio?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'comentarios': comentarios ?? '',
        'ubicacion': ubicacion,
      };

      final response = await _apiService.createMedicalRequest(requestData);

      if (response['solicitud_id'] == null) {
        throw Exception('Respuesta inesperada del servidor: ${response.toString()}');
      }

      debugPrint('Solicitud creada con ID: ${response['solicitud_id']}');
      return RequestModel.fromJson(response);
    } catch (e) {
      debugPrint('Error en createRequest: $e');
      rethrow;
    }
  }

  Future<RequestModel> updateRequest(
      int solicitudId, Map<String, dynamic> data) async {
    try {
      final success =
          await _apiService.updateRequest(solicitudId.toString(), data);
      if (success) {
        // Obtener los datos actualizados
        final requestDetails =
            await _apiService.getRequestDetails(solicitudId.toString());
        return RequestModel.fromJson(requestDetails);
      }
      throw Exception('Error al actualizar la solicitud');
    } catch (e) {
      debugPrint('Error en updateRequest: $e');
      rethrow;
    }
  }
}