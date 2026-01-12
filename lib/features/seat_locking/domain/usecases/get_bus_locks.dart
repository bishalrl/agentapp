import '../../../../core/utils/result.dart';
import '../entities/seat_lock_entity.dart';
import '../repositories/seat_lock_repository.dart';

class GetBusLocks {
  final SeatLockRepository repository;

  GetBusLocks(this.repository);

  Future<Result<List<SeatLockEntity>>> call(String busId) async {
    return await repository.getBusLocks(busId);
  }
}

