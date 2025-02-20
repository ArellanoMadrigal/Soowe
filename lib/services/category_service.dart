import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/category.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final List<Map<String, dynamic>> rawCategories =
          await _apiService.getAllCategories();

      return rawCategories.map((data) => CategoryModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en getAllCategories: $e');
      return [];
    }
  }
}
