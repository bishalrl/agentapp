import '../../../../core/utils/result.dart';
import '../repositories/booking_repository.dart';

class LockSeats {
  final BookingRepository repository;
  
  LockSeats(this.repository);
  
  Future<Result<void>> call({
    required String busId,
    required List<int> seatNumbers,
  }) async {
    return await repository.lockSeats(busId, seatNumbers);
  }
}
