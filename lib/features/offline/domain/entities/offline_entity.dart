class OfflineQueueItemEntity {
  final String id;
  final Map<String, dynamic> bookingData;
  final String status; // pending, synced, failed
  final DateTime createdAt;
  final String? errorMessage;

  OfflineQueueItemEntity({
    required this.id,
    required this.bookingData,
    required this.status,
    required this.createdAt,
    this.errorMessage,
  });
}

class OfflineSyncResultEntity {
  final int synced;
  final int failed;
  final List<Map<String, dynamic>> conflicts;

  OfflineSyncResultEntity({
    required this.synced,
    required this.failed,
    required this.conflicts,
  });
}
