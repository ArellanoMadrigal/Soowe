import 'package:dio/dio.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Update user
  Future<bool> updateUser({
    required String id,
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String telefono,
    required String direccion,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/usuarios/$id',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'contrasena': contrasena,
          'telefono': telefono,
          'direccion': direccion,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar el usuario');
      } else {
        return true;
      }
    } on DioException catch (e) {
      throw Exception('Error en actualización: ${e.message}');
    }
  }
}
