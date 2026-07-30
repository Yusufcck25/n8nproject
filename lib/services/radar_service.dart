import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../models/radar_opportunity.dart';
import 'api_service.dart';

class RadarService {
  RadarService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<RadarPageResult> getOpportunities({
    required int page,
    required int pageSize,
    String? country,
    String? category,
    String? searchTerm,
    double? minOpportunityScore,
  }) async {
    final queryParameters = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (country != null && country.trim().isNotEmpty) {
      queryParameters['Country'] = country.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      queryParameters['Category'] = category.trim();
    }
    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      queryParameters['SearchTerm'] = searchTerm.trim();
    }
    if (minOpportunityScore != null) {
      queryParameters['MinOpportunityScore'] = minOpportunityScore.toString();
    }

    final uri = Uri.parse(ApiConstants.radarData).replace(queryParameters: queryParameters);
    final response = await _apiService.get(uri.toString());
    if (response.statusCode != 200) {
      throw Exception('Fırsatlar alınamadı (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] is! Map) {
      throw Exception(body['message'] as String? ?? 'Fırsatlar alınamadı.');
    }

    return RadarPageResult.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<RadarOpportunity> getOpportunityById(int id) async {
    final response = await _apiService.get('${ApiConstants.radarData}/$id');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true || body['data'] is! Map) {
      throw Exception(body['message'] as String? ?? 'Fırsat detayı alınamadı.');
    }

    return RadarOpportunity.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }
}
