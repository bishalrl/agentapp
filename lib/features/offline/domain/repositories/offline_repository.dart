import '../../../../core/utils/result.dart';
import '../entities/offline_entity.dart';

abstract class OfflineRepository {
  Future<Result<List<OfflineQueueItemEntity>>> getOfflineQueue();
  Future<Result<OfflineQueueItemEntity>> addToOfflineQueue({
    required Map<String, dynamic> bookingData,
  });
  Future<Result<OfflineSyncResultEntity>> syncOfflineBookings();
}
