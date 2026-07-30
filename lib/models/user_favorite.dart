import 'radar_opportunity.dart';

class UserFavorite {
  const UserFavorite({
    required this.id,
    required this.radarDataId,
    required this.note,
    required this.createdAt,
    this.radarData,
  });

  final int id;
  final int radarDataId;
  final String? note;
  final DateTime createdAt;
  final RadarOpportunity? radarData;

  factory UserFavorite.fromJson(Map<String, dynamic> json) {
    final rawRadarData = json['radarData'];
    return UserFavorite(
      id: (json['id'] as num?)?.toInt() ?? 0,
      radarDataId: (json['radarDataId'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      radarData: rawRadarData is Map
          ? RadarOpportunity.fromJson(Map<String, dynamic>.from(rawRadarData))
          : null,
    );
  }
}
