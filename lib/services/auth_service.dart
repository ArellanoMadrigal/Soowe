import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final ApiService _apiService = ApiService();
  SharedPreferences? _prefs;
  String? _currentUserId;
  String? _userName;
  String? _userRole;
  bool _isInitialized = false;

  AuthService._internal() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _currentUserId = _prefs?.getString('userId');
      _userName = _prefs?.getString('userName');
      _userRole = _prefs?.getString('userRole');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando SharedPreferences: $e');
    }
  }

  Future<bool> registerUser({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String confirmarContrasena,
    String telefono = '',
    String direccion = '',
  }) async {
    try {
      if (contrasena != confirmarContrasena) {
        throw Exception('Las contraseñas no coinciden');
      }

      final response = await _apiService.dio.post(
        'registerMobile',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'contrasena': contrasena,
          'telefono': telefono,
          'direccion': direccion,
        },
      );

      debugPrint('Respuesta registro: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en registro: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error general en registro: $e');
      throw Exception('Error inesperado en registro');
    }
  }

  Future<bool> loginUser({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _initPrefs();

      final response = await _apiService.dio.post(
        'loginMobile',
        data: {
          'correo': correo,
          'contrasena': contrasena,
        },
      );

      debugPrint('Respuesta login: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'] as String?;
        final role = response.data['role'] as String?;

        if (token == null || role == null) {
          throw Exception('Token o rol no recibido');
        }

        // Decodificar el token para obtener el ID
        final parts = token.split('.');
        if (parts.length != 3) throw Exception('Token inválido');

        String payload = parts[1];
        while (payload.length % 4 != 0) payload += '=';
        
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final Map<String, dynamic> tokenData = json.decode(decoded);

        final userId = tokenData['id'] as String?;
        final userEmail = tokenData['correo'] as String?;
        if (userId == null) throw Exception('ID no encontrado en el token');

        // Establecer token para autorización
        _apiService.setAuthToken(token);

        // Intentar obtener datos del perfil, pero no fallar si no se puede
        String userName = 'Usuario';
        try {
          final userData = await _apiService.getUserProfile(userId);
          userName = '${userData['nombre']} ${userData['apellido']}'.trim();
        } catch (e) {
          debugPrint("No se pudo obtener el perfil completo: $e");
          // Usar el correo como nombre de usuario alternativo
          userName = userEmail ?? 'Usuario';
        }

        // Guardar todos los datos
        _currentUserId = userId;
        _userRole = role;
        _userName = userName;

        // Guardar en SharedPreferences
        await Future.wait([
          _prefs?.setString('userId', userId) ?? Future.value(),
          _prefs?.setString('userRole', role) ?? Future.value(),
          _prefs?.setString('userName', userName) ?? Future.value(),
        ]);

        debugPrint('Login exitoso. Usuario: $userName, Rol: $role');
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint('Error DioException en login: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error general en login: $e');
      throw Exception('Error inesperado al iniciar sesión');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      try {
        final userData = await _apiService.getUserProfile(userId);
        
        _userName = userData['nombre'] != null && userData['apellido'] != null
            ? '${userData['nombre']} ${userData['apellido']}'.trim()
            : (userData['correo'] ?? 'Usuario');
        
        await _prefs?.setString('userName', _userName ?? '');
      } catch (e) {
        debugPrint('Error cargando perfil: $e');
        // Mantener el nombre de usuario existente o usar un valor predeterminado
        _userName ??= 'Usuario';
      }
    } catch (e) {
      debugPrint('Error en loadUserProfile: $e');
      _userName ??= 'Usuario';
    }
  }

  Future<bool> updateUserProfile({
    String? telefono,
    String? direccion,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      final data = <String, dynamic>{};
      if (telefono != null) data['telefono'] = telefono;
      if (direccion != null) data['direccion'] = direccion;

      final success = await _apiService.updateUserProfile(userId, data);
      if (success) {
        await loadUserProfile();
      }
      return success;
    } catch (e) {
      debugPrint('Error en actualización de perfil: $e');
      throw Exception('Error al actualizar perfil');
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        throw Exception('Las nuevas contraseñas no coinciden');
      }

      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _apiService.dio.put(
        'changePassword/$userId',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      throw Exception('Error inesperado al cambiar contraseña');
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.dio.post(
        'requestPasswordReset',
        data: {'correo': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al solicitar reset de contraseña');
    }
  }

  String? getCurrentUserId() => _currentUserId;
  String? getUserName() => _userName;
  String? getUserRole() => _userRole;

  Future<void> logout() async {
    try {
      await _initPrefs();
      await _prefs?.clear();
      _currentUserId = null;
      _userName = null;
      _userRole = null;
      _apiService.clearAuthToken();
    } catch (e) {
      debugPrint('Error en logout: $e');
      throw Exception('Error al cerrar sesión');
    }
  }

  bool isLoggedIn() {
    return _currentUserId != null && _apiService.getAuthToken() != null;
  }

  Future<void> checkAuthStatus() async {
    try {
      await _initPrefs();
      
      // Si no hay userId, no hay sesión activa
      if (_currentUserId == null) return;

      try {
        await loadUserProfile();
      } catch (e) {
        debugPrint('Error verificando sesión: $e');
        await logout();
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      throw Exception('Error al verificar estado de autenticación');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      final userData = await _apiService.getUserProfile(userId);
      
      // Usar datos del perfil o valores predeterminados
      _userName = userData['nombre'] != null && userData['apellido'] != null
          ? '${userData['nombre']} ${userData['apellido']}'.trim()
          : (userData['correo'] ?? 'Usuario');
      
      await _prefs?.setString('userName', _userName ?? '');
      
      return userData;
    } catch (e) {
      debugPrint('Error obteniendo perfil: $e');
      throw Exception('Error al obtener perfil de usuario');
    }
  }
}