import 'package:http/http.dart' as http;

import '../core/utils/storage_service.dart';

class ApiService {
  ApiService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  final StorageService _storageService;

  Future<http.Response> get(String url) async {
    return http
        .get(Uri.parse(url), headers: await _authorizedHeaders())
        .timeout(const Duration(seconds: 15));
  }

  Future<http.Response> post(String url, {String? body}) async {
    return http
        .post(Uri.parse(url), headers: await _authorizedHeaders(), body: body)
        .timeout(const Duration(seconds: 15));
  }

  Future<http.Response> delete(String url) async {
    return http
        .delete(Uri.parse(url), headers: await _authorizedHeaders())
        .timeout(const Duration(seconds: 15));
  }

  Future<Map<String, String>> _authorizedHeaders() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('Oturum tokenı bulunamadı.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
