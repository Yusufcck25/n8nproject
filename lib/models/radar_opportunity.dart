class RadarOpportunity {
  const RadarOpportunity({
    required this.id,
    required this.sourceName,
    required this.title,
    required this.country,
    required this.category,
    required this.opportunityScore,
    required this.rawData,
    required this.createdAt,
  });

  final int id;
  final String sourceName;
  final String title;
  final String country;
  final String category;
  final double? opportunityScore;
  final String rawData;
  final DateTime createdAt;

  factory RadarOpportunity.fromJson(Map<String, dynamic> json) {
    return RadarOpportunity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      sourceName: json['sourceName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      country: json['country'] as String? ?? '',
      category: json['category'] as String? ?? '',
      opportunityScore: (json['opportunityScore'] as num?)?.toDouble(),
      rawData: json['rawData'] as String? ?? '{}',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class RadarPageResult {
  const RadarPageResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<RadarOpportunity> items;
  final int totalCount;
  final int page;
  final int pageSize;

  factory RadarPageResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return RadarPageResult(
      items: rawItems
          .whereType<Map>()
          .map((item) => RadarOpportunity.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );
  }
}
