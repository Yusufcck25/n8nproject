import 'dart:convert';

class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.name,
    required this.searchQueryJson,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String searchQueryJson;
  final DateTime createdAt;

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Adsız arama',
      searchQueryJson: json['searchQueryJson'] as String? ?? '{}',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> get filters {
    try {
      final decoded = jsonDecode(searchQueryJson);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
