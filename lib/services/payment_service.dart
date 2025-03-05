import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/payment.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  Future<Payment> createPayment({
    required double amount,
    required String paymentMethod,
    required DateTime paymentDate,
    required String status,
    required int requestId,
    String? details,
  }) async {
    try {
      final payment = Payment(
        amount: amount,
        paymentMethod: paymentMethod,
        paymentDate: paymentDate,
        status: status,
        details: details ?? '',
        requestId: requestId,
      );
      final Map<String, dynamic> rawPayment = await _apiService.createPayment(payment.toJson());

      final solicitudId = rawPayment['solicitud_id'];
      debugPrint('Pago creado con ID de solicitud: $solicitudId');

      if (solicitudId == null) {
        throw Exception('Respuesta inesperada del servidor: ${rawPayment.toString()}');
      }

      final paymentWithId = Payment.fromJson(rawPayment);
      return paymentWithId;
    } catch (e) {
      debugPrint('Error al crear el pago: $e');
      if (e is DioException) {
        debugPrint('Detalles del error: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
