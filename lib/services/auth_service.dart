import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/utils/storage_service.dart';
import 'api_service.dart';

class AuthService {
  AuthService({StorageService? storageService, ApiService? apiService})
      : _storageService = storageService ?? StorageService(),
        _apiService = apiService ?? ApiService(storageService: storageService);

  final StorageService _storageService;
  final ApiService _apiService;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);
      final token = data['data']?['accessToken'];
      if (data['success'] != true || token is! String || token.isEmpty) {
        return false;
      }

      await _storageService.saveToken(token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.register),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'fullName': fullName,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConstants.currentUser);
      if (response.statusCode == 401) {
        await logout();
        return null;
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data']);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> logout() => _storageService.deleteToken();
}
