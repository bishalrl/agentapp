import '../../../../core/utils/result.dart';
import '../entities/seat_lock_entity.dart';
import '../repositories/seat_lock_repository.dart';

class LockSeat {
  final SeatLockRepository repository;

  LockSeat(this.repository);

  Future<Result<SeatLockEntity>> call(String busId, int seatNumber) async {
    return await repository.lockSeat(busId, seatNumber);
  }
}

