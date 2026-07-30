class SyncLog {
  const SyncLog({
    required this.id,
    required this.workflowName,
    required this.status,
    required this.processedCount,
    required this.errorMessage,
    required this.loggedAt,
  });

  final int id;
  final String workflowName;
  final String status;
  final int processedCount;
  final String? errorMessage;
  final DateTime loggedAt;

  factory SyncLog.fromJson(Map<String, dynamic> json) {
    return SyncLog(
      id: (json['id'] as num?)?.toInt() ?? 0,
      workflowName: json['workflowName'] as String? ?? 'Bilinmeyen iş akışı',
      status: json['status'] as String? ?? 'Unknown',
      processedCount: (json['processedCount'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      loggedAt: DateTime.tryParse(json['loggedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class AdminAccessDenied implements Exception {
  const AdminAccessDenied();
}
