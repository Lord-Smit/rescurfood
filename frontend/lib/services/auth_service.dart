import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _api = ApiService();

  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_json';

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _api.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      final data = response.data['data'];
      final user = UserModel.fromMap({
        ...data['user'],
        'token': data['token'],
      });

      await _persistSession(user);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'Server URL not found (404). Please ensure backend is running.';
      } else if (e.response?.statusCode == 401) {
        throw 'Invalid credentials. Please check your email/phone and password.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw 'Connection timeout. Cannot reach server.';
      }
      final msg = e.response?.data?['message'];
      throw msg ?? 'Login failed. Please try again.';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> applyForRegistration({
    required String type,
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _api.post(ApiConstants.applyRegistration, data: {
        'type': type,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      return response.data['message'] ?? 'Registration request submitted';
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'Registration endpoint not found (404). Check backend configuration.';
      }
      final msg = e.response?.data?['message'];
      throw msg ?? 'Registration failed. Please try again.';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> getSavedToken() => _storage.read(key: _tokenKey);

  Future<UserModel?> getSavedUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistSession(UserModel user) async {
    await _storage.write(key: _tokenKey, value: user.token ?? '');
    await _storage.write(key: _userKey, value: jsonEncode(user.toMap()));
  }
}
