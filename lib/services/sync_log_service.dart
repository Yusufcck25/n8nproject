import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../models/sync_log.dart';
import 'api_service.dart';

class SyncLogService {
  SyncLogService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<SyncLog>> getLogs(int count) async {
    final uri = Uri.parse(ApiConstants.syncLogs).replace(queryParameters: {'count': '$count'});
    final response = await _apiService.get(uri.toString());
    if (response.statusCode == 403) throw const AdminAccessDenied();

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true || body['data'] is! List) {
      throw Exception(body['message'] as String? ?? 'Senkronizasyon logları alınamadı.');
    }

    return (body['data'] as List<dynamic>)
        .whereType<Map>()
        .map((item) => SyncLog.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
