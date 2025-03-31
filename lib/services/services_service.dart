import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/service.dart';

class ServicesService {
  final ApiService _apiService = ApiService();

  Future<List<ServiceModel>> getServicesFromCategory(categoryId) async {
    try {
      final List<Map<String, dynamic>> rawServices =
          await _apiService.getServicesFromCategory(categoryId);

      return rawServices.map((data) => ServiceModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en getServicesFromCategory: $e');
      return [];
    }
  }

  Future<List<ServiceModel>> getServices() async {
    try {
      final List<Map<String, dynamic>> rawServices =
          await _apiService.getServices();

      return rawServices.map((data) => ServiceModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en getServices: $e');
      return [];
    }
  }
}
