import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio;
  String? _authToken;
  final Logger _logger = Logger();

  ApiService._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: "https://soowe-apidata.onrender.com/",
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        ) {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _logger.e(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            error: e,
          );
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _logger.i('Token de autenticación establecido');
  }

  String? getAuthToken() => _authToken;

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
    _logger.i('Token de autenticación eliminado');
  }

  void checkAuthToken() {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String? userId) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    if (userId == null || userId.isEmpty) {
      throw Exception("ID de usuario no disponible");
    }

    try {
      final response = await _dio.get(
        "api/mobile/usuarios/$userId",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Perfil de usuario obtenido para ID: $userId');
      debugPrint('Respuesta getUserProfile: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return {
          'nombre': response.data['nombre'] ?? 'Usuario',
          'apellido': response.data['apellido'] ?? '',
          'correo': response.data['correo'] ?? '',
          'telefono': response.data['telefono'] ?? '',
          'direccion': response.data['direccion'] ?? '',
          'foto_perfil': response.data['foto_perfil'] ?? {},
          ...response.data
        };
      }

      return {
        'nombre': 'Usuario',
        'apellido': '',
        'correo': '',
        'telefono': '',
        'direccion': '',
        'foto_perfil': {}
      };
    } on DioException catch (e) {
      _logger.e('Error obteniendo perfil de usuario', error: e);
      debugPrint('Error en getUserProfile: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        return {
          'nombre': 'Usuario',
          'apellido': '',
          'correo': '',
          'telefono': '',
          'direccion': '',
          'foto_perfil': {}
        };
      }

      throw Exception(handleError(e));
    } catch (e) {
      _logger.e('Error inesperado en getUserProfile', error: e);
      debugPrint('Error inesperado en getUserProfile: $e');

      return {
        'nombre': 'Usuario',
        'apellido': '',
        'correo': '',
        'telefono': '',
        'direccion': '',
        'foto_perfil': {}
      };
    }
  }

  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      // Obtener extensión y tipo MIME
      final extension = path.extension(imageFile.path).toLowerCase();
      String mimeType;

      switch (extension) {
        case '.jpg':
        case '.jpeg':
          mimeType = 'jpeg';
          break;
        case '.png':
          mimeType = 'png';
          break;
        case '.gif':
          mimeType = 'gif';
          break;
        default:
          throw Exception('Formato no soportado. Use JPG, PNG o GIF');
      }

      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception("Usuario no encontrado");
      }

      // Verificar tamaño del archivo
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('El archivo es demasiado grande (máximo 5MB)');
      }

      // Crear FormData
      final formData = FormData.fromMap({
        'foto_perfil': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_picture$extension',
          contentType: MediaType('image', mimeType),
        ),
      });

      _logger.d('Iniciando subida de imagen para usuario: $userId');
      _logger.d('Tipo MIME: image/$mimeType');
      _logger.d(
          'Tamaño del archivo: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');

      final response = await _dio.put(
        "api/mobile/usuarios/$userId/profile/upload-picture",
        data: formData,
        options: Options(
          headers: {
            'Authorization': "Bearer $_authToken",
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      _logger.i('Imagen de perfil subida exitosamente');
      debugPrint('Respuesta uploadProfilePicture: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['foto_perfil'] != null) {
          return response.data['foto_perfil'];
        } else if (response.data['url'] != null) {
          return {'url': response.data['url']};
        } else {
          return response.data;
        }
      }

      throw Exception("Error al subir imagen de perfil");
    } on DioException catch (e) {
      _logger.e('Error subiendo imagen de perfil', error: e);
      debugPrint('Error en uploadProfilePicture: ${e.response?.data}');

      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }

      throw Exception(handleError(e));
    } catch (e) {
      _logger.e('Error inesperado en uploadProfilePicture', error: e);
      debugPrint('Error inesperado en uploadProfilePicture: $e');
      throw Exception('Error al subir imagen de perfil: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "api/mobile/notifications",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Notificaciones obtenidas exitosamente');
      debugPrint('Respuesta fetchNotifications: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['notifications'] != null) {
          return List<Map<String, dynamic>>.from(
              response.data['notifications']);
        }
        return <Map<String, dynamic>>[];
      }
      return <Map<String, dynamic>>[];
    } on DioException catch (e) {
      _logger.e('Error obteniendo notificaciones', error: e);
      debugPrint('Error en fetchNotifications: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception("Sesión expirada");
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      _logger.e('Error inesperado en fetchNotifications', error: e);
      debugPrint('Error inesperado en fetchNotifications: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.put(
        "api/mobile/usuarios/$userId",
        data: data,
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Perfil de usuario actualizado para ID: $userId');
      debugPrint('Respuesta updateUserProfile: ${response.data}');

      return response.statusCode == 200;
    } on DioException catch (e) {
      _logger.e('Error actualizando perfil de usuario', error: e);
      debugPrint('Error en updateUserProfile: ${e.response?.data}');
      throw Exception(handleError(e));
    } catch (e) {
      _logger.e('Error inesperado en updateUserProfile', error: e);
      debugPrint('Error inesperado en updateUserProfile: $e');
      throw Exception('Error al actualizar perfil de usuario');
    }
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "/services",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Servicios obtenidos exitosamente');
      debugPrint('Respuesta getServices: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data is List
            ? List<Map<String, dynamic>>.from(response.data)
            : <Map<String, dynamic>>[];
      }
      return <Map<String, dynamic>>[];
    } on DioException catch (e) {
      _logger.e('Error obteniendo servicios', error: e);
      debugPrint('Error en getServices: ${e.response?.data}');
      return <Map<String, dynamic>>[];
    } catch (e) {
      _logger.e('Error inesperado en getServices', error: e);
      debugPrint('Error inesperado en getServices: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<Map<String, dynamic>> getServiceDetails(String serviceId) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "/services/$serviceId",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Detalles del servicio obtenidos para ID: $serviceId');
      debugPrint('Respuesta getServiceDetails: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data is Map
            ? Map<String, dynamic>.from(response.data)
            : <String, dynamic>{};
      }
      return <String, dynamic>{};
    } on DioException catch (e) {
      _logger.e('Error obteniendo detalles del servicio', error: e);
      debugPrint('Error en getServiceDetails: ${e.response?.data}');
      return <String, dynamic>{};
    } catch (e) {
      _logger.e('Error inesperado en getServiceDetails', error: e);
      debugPrint('Error inesperado en getServiceDetails: $e');
      return <String, dynamic>{};
    }
  }

  Future<String?> _getCurrentUserId() async {
    final authService = AuthService();
    return authService.getCurrentUserId();
  }

  // Crear una nueva solicitud médica
  Future<Map<String, dynamic>> createMedicalRequest(
      Map<String, dynamic> requestData) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      if (requestData['usuario_id'] == null) {
        throw Exception("El campo 'usuario_id' es requerido");
      }
      if (requestData['paciente_id'] == null) {
        throw Exception("El campo 'paciente_id' es requerido");
      }

      // Asegurarse de que los campos requeridos estén en el formato correcto
      final formattedData = {
        ...requestData,
        'usuario_id': requestData['usuario_id'].toString(),
        'paciente_id': requestData['paciente_id'].toString(),
        'estado': 'pending_assignment', // Valor válido para el estado
        'metodo_pago':
            requestData['metodo_pago']?.toString().toLowerCase() ?? 'efectivo',
        'fecha_solicitud': DateTime.now().toIso8601String(),
      };

      // Enviar la solicitud al endpoint correcto
      final response = await _dio.post(
        "api/mobile/solicitudes", // Ruta correcta
        data: formattedData, // Datos de la solicitud en el cuerpo
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Solicitud médica creada exitosamente');
      debugPrint('Respuesta createMedicalRequest: ${response.data}');

      if (response.statusCode == 201 && response.data != null) {
        return response.data;
      }
      throw Exception("Error al crear la solicitud médica");
    } on DioException catch (e) {
      _logger.e('Error creando solicitud médica', error: e);
      debugPrint('Error en createMedicalRequest: ${e.response?.data}');
      throw Exception(handleError(e));
    }
  }

// Obtener todas las solicitudes
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "api/mobile/solicitudes", // Ruta corregida
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Solicitudes obtenidas exitosamente');
      debugPrint('Respuesta getAllRequests: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error obteniendo solicitudes', error: e);
      debugPrint('Error en getAllRequests: ${e.response?.data}');
      return [];
    }
  }

// Obtener detalles de una solicitud específica
  Future<Map<String, dynamic>> getRequestDetails(String requestId) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "api/mobile/solicitudes/$requestId", // Ruta corregida
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Detalles de solicitud obtenidos para ID: $requestId');
      debugPrint('Respuesta getRequestDetails: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      throw Exception("Solicitud no encontrada");
    } on DioException catch (e) {
      _logger.e('Error obteniendo detalles de solicitud', error: e);
      debugPrint('Error en getRequestDetails: ${e.response?.data}');
      throw Exception(handleError(e));
    }
  }

// Actualizar una solicitud
  Future<bool> updateRequest(
      String requestId, Map<String, dynamic> updateData) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.put(
        "api/mobile/solicitudes/$requestId", // Ruta corregida
        data: updateData,
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Solicitud actualizada para ID: $requestId');
      debugPrint('Respuesta updateRequest: ${response.data}');

      return response.statusCode == 200;
    } on DioException catch (e) {
      _logger.e('Error actualizando solicitud', error: e);
      debugPrint('Error en updateRequest: ${e.response?.data}');
      throw Exception(handleError(e));
    }
  }

// Eliminar una solicitud
  Future<bool> deleteRequest(String requestId) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.delete(
        "api/mobile/solicitudes/$requestId", // Ruta corregida
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Solicitud eliminada para ID: $requestId');
      debugPrint('Respuesta deleteRequest: ${response.data}');

      return response.statusCode == 200;
    } on DioException catch (e) {
      _logger.e('Error eliminando solicitud', error: e);
      debugPrint('Error en deleteRequest: ${e.response?.data}');
      throw Exception(handleError(e));
    }
  }

// Obtener pacientes
  Future<List<Map<String, dynamic>>> getPacientes() async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "api/mobile/pacientes",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Pacientes obtenidos exitosamente');
      debugPrint('Respuesta getPacientes: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error obteniendo pacientes', error: e);
      debugPrint('Error en getPacientes: ${e.response?.data}');
      return [];
    }
  }

  String handleError(DioException e) {
    final message = switch (e.type) {
      DioExceptionType.connectionTimeout =>
        "El servidor no responde. Intenta nuevamente más tarde",
      DioExceptionType.receiveTimeout =>
        "La respuesta del servidor es muy lenta. Verifica tu conexión",
      DioExceptionType.badResponse when e.response?.statusCode == 401 =>
        "Sesión expirada - Vuelve a iniciar sesión",
      DioExceptionType.badResponse when e.response?.statusCode == 404 =>
        "Recurso no encontrado",
      DioExceptionType.badResponse when e.response?.statusCode == 500 =>
        "Error interno del servidor",
      DioExceptionType.connectionError =>
        "Error de conexión - Verifica tu internet",
      _ => "Error inesperado: ${e.message}"
    };

    _logger.e('Error DioException: $message');
    return message;
  }

  // obtener categorias de la base de datos
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "api/admin/categorias",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Categorías obtenidas exitosamente');

      if (response.statusCode == 200 && response.data != null) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error obteniendo categorías', error: e);
      debugPrint('Error en getCategories: ${e.response?.data}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getServicesFromCategory(
      int categoryId) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "api/admin/categorias/$categoryId/servicios",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger
          .i('Servicios obtenidos exitosamente para la categoría $categoryId');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map &&
            response.data.containsKey('servicios')) {
          final data = response.data['servicios'];
          if (data is List) {
            return List<Map<String, dynamic>>.from(data);
          }
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error obteniendo servicios de la categoría', error: e);
      debugPrint('Error en getServicesFromCategory: ${e.response?.data}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllPatientsFromUser(
      String userId) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "api/mobile/usuarios/$userId/pacientes",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Pacientes obtenidos exitosamente para el usuario $userId');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map &&
          response.data.containsKey('pacientes')) {
            final data = response.data['pacientes'];
            if (data is List) {
              return List<Map<String, dynamic>>.from(data);
            }
        }
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error obteniendo pacientes del usuario', error: e);
      debugPrint('Error en getAllPatientsFromUser: ${e.response?.data}');
      return [];
    }
  }

  Future<bool> createPatient(Map<String, dynamic> patientData) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.post(
        "api/mobile/pacientes",
        data: patientData,
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Paciente creado exitosamente');

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Error al crear paciente. Código de estado: ${response.statusCode}, Respuesta: ${response.data}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Error creando paciente', error: e);
      debugPrint(
          'Error en createPatient: ${e.message}, Respuesta: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> updatePatient(
      String patientId, Map<String, dynamic> updateData) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.put(
        "api/mobile/pacientes/$patientId",
        data: updateData,
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      _logger.i('Paciente actualizado exitosamente para ID: $patientId');
      debugPrint('Respuesta updatePatient: ${response.data}');

      return response.statusCode == 200;
    } on DioException catch (e) {
      _logger.e('Error actualizando paciente', error: e);
      debugPrint('Error en updatePatient: ${e.response?.data}');
      throw Exception(handleError(e));
    }
  }
}
