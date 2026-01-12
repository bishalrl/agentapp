import '../../domain/entities/offline_entity.dart';

class OfflineQueueItemModel extends OfflineQueueItemEntity {
  OfflineQueueItemModel({
    required super.id,
    required super.bookingData,
    required super.status,
    required super.createdAt,
    super.errorMessage,
  });

  factory OfflineQueueItemModel.fromJson(Map<String, dynamic> json) {
    return OfflineQueueItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookingData: json['bookingData'] as Map<String, dynamic>? ?? {},
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      errorMessage: json['errorMessage'],
    );
  }
}

class OfflineSyncResultModel extends OfflineSyncResultEntity {
  OfflineSyncResultModel({
    required super.synced,
    required super.failed,
    required super.conflicts,
  });

  factory OfflineSyncResultModel.fromJson(Map<String, dynamic> json) {
    return OfflineSyncResultModel(
      synced: json['synced'] ?? 0,
      failed: json['failed'] ?? 0,
      conflicts: json['conflicts'] != null
          ? List<Map<String, dynamic>>.from(json['conflicts'])
          : [],
    );
  }
}
