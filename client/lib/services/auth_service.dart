import 'package:recruitment_frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';

  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (response['access_token'] != null) {
        await _saveAuthData(response['access_token'], response['user']);
        _api.setToken(response['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String role,
  ) async {
    try {
      final response = await _api.post('auth/register', {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      });

      return response['user_id'] != null;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    try {
      final response = await _api.post('auth/verify', {
        'email': email,
        'code': code,
      });

      if (response['access_token'] != null) {
        await _saveAuthData(response['access_token'], response['user']);
        _api.setToken(response['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _api.post('auth/forgot-password', {
        'email': email,
      });
      return response['message'] != null;
    } catch (e) {
      throw Exception('Password reset request failed: $e');
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _api.post('auth/reset-password', {
        'token': token,
        'new_password': newPassword,
      });
      return response['message'] != null;
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    _api.setToken('');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) ?? '';  
  }

  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return Map<String, dynamic>.from(jsonDecode(userJson));
    }
    return {};
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user));
  }
}
