import '../../../../core/utils/result.dart';
import '../entities/offline_entity.dart';
import '../repositories/offline_repository.dart';

class SyncOfflineBookings {
  final OfflineRepository repository;

  SyncOfflineBookings(this.repository);

  Future<Result<OfflineSyncResultEntity>> call() async {
    return await repository.syncOfflineBookings();
  }
}
