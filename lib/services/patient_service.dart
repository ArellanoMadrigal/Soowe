import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/patient.dart';

class PatientService {
  final ApiService _apiService = ApiService();

  Future<List<PatientModel>> getAllPatientsFromUser(userId) async {
    try {
      final List<Map<String, dynamic>> rawPatients =
          await _apiService.getAllPatientsFromUser(userId);

      return rawPatients.map((data) => PatientModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en getServicesFromCategory: $e');
      return [];
    }
  }

  Future<bool> createNewPatient(PatientModel patientData) async {
    try {
      final success = await _apiService.createPatient(patientData.toJson());
      if (success) {
        return true;
      } else {
        throw Exception('Error al crear paciente en patient_service');
      }
    } catch (e) {
      debugPrint('Error en createNewPatient: $e');
      return false;
    }
  }

  Future<bool> updatePatient(String patientId, PatientModel patientData) async {
    try {
      final success = await _apiService.updatePatient(patientId, patientData.toJson());
      if (success) {
        return true;
      } else {
        throw Exception('Error al actualizar paciente en patient_service');
      }
    } catch (e) {
      debugPrint('Error en updatePatient: $e');
      return false;
    }
  }
}
