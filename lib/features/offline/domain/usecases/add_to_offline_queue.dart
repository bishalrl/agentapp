import '../../../../core/utils/result.dart';
import '../entities/offline_entity.dart';
import '../repositories/offline_repository.dart';

class AddToOfflineQueue {
  final OfflineRepository repository;

  AddToOfflineQueue(this.repository);

  Future<Result<OfflineQueueItemEntity>> call({
    required Map<String, dynamic> bookingData,
  }) async {
    return await repository.addToOfflineQueue(bookingData: bookingData);
  }
}
