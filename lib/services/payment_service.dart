import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/payment.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  Future<Payment> createPayment(Payment payment) async {
    try {
      final Map<String, dynamic> rawPayment = await _apiService.createPayment(payment.toJson());

      return Payment.fromJson(rawPayment);
    } catch (e) {
      debugPrint('Error en createPayment: $e');
      rethrow;
    }
  }
}
