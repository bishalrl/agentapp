import '../../../../core/utils/result.dart';
import '../entities/seat_lock_entity.dart';
import '../repositories/seat_lock_repository.dart';

class LockMultipleSeats {
  final SeatLockRepository repository;

  LockMultipleSeats(this.repository);

  Future<Result<List<SeatLockEntity>>> call(String busId, List<int> seatNumbers) async {
    return await repository.lockMultipleSeats(busId, seatNumbers);
  }
}

