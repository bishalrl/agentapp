import '../../../../core/utils/result.dart';
import '../entities/offline_entity.dart';
import '../repositories/offline_repository.dart';

class GetOfflineQueue {
  final OfflineRepository repository;

  GetOfflineQueue(this.repository);

  Future<Result<List<OfflineQueueItemEntity>>> call() async {
    return await repository.getOfflineQueue();
  }
}
