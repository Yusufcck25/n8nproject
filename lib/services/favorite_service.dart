import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../models/user_favorite.dart';
import 'api_service.dart';

class FavoriteService {
  FavoriteService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<UserFavorite>> getFavorites() async {
    final response = await _apiService.get('${ApiConstants.baseUrl}/UserFavorites');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true || body['data'] is! List) {
      throw Exception(body['message'] as String? ?? 'Favoriler alınamadı.');
    }

    return (body['data'] as List<dynamic>)
        .whereType<Map>()
        .map((item) => UserFavorite.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<bool> addFavorite(int radarDataId, {String? note}) async {
    final response = await _apiService.post(
      '${ApiConstants.baseUrl}/UserFavorites',
      body: jsonEncode({'radarDataId': radarDataId, if (note != null && note.isNotEmpty) 'note': note}),
    );
    if (response.statusCode != 200) return false;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['success'] == true;
  }

  Future<bool> removeFavorite(int id) async {
    final response = await _apiService.delete('${ApiConstants.baseUrl}/UserFavorites/$id');
    if (response.statusCode != 200) return false;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['success'] == true;
  }
}
