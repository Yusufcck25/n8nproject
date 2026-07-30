import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../models/saved_search.dart';
import 'api_service.dart';

class SavedSearchService {
  SavedSearchService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<SavedSearch>> getSavedSearches() async {
    final response = await _apiService.get('${ApiConstants.baseUrl}/SavedSearches');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true || body['data'] is! List) {
      throw Exception(body['message'] as String? ?? 'Kayıtlı aramalar alınamadı.');
    }

    return (body['data'] as List<dynamic>)
        .whereType<Map>()
        .map((item) => SavedSearch.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<bool> saveSearch(String name, Map<String, dynamic> filters) async {
    final response = await _apiService.post(
      '${ApiConstants.baseUrl}/SavedSearches',
      body: jsonEncode({'name': name, 'searchQueryJson': jsonEncode(filters)}),
    );
    if (response.statusCode != 200) return false;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['success'] == true;
  }

  Future<bool> deleteSavedSearch(int id) async {
    final response = await _apiService.delete('${ApiConstants.baseUrl}/SavedSearches/$id');
    if (response.statusCode != 200) return false;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['success'] == true;
  }
}
