import '../../../../core/utils/result.dart';
import '../entities/seat_lock_entity.dart';

abstract class SeatLockRepository {
  Future<Result<SeatLockEntity>> lockSeat(String busId, int seatNumber);
  Future<Result<List<SeatLockEntity>>> lockMultipleSeats(String busId, List<int> seatNumbers);
  Future<Result<void>> unlockSeat(String busId, int seatNumber);
  Future<Result<List<SeatLockEntity>>> getBusLocks(String busId);
  Future<Result<List<SeatLockEntity>>> getMyLocks();
}

