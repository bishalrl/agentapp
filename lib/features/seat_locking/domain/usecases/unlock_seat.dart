import '../../../../core/utils/result.dart';
import '../repositories/seat_lock_repository.dart';

class UnlockSeat {
  final SeatLockRepository repository;

  UnlockSeat(this.repository);

  Future<Result<void>> call(String busId, int seatNumber) async {
    return await repository.unlockSeat(busId, seatNumber);
  }
}

