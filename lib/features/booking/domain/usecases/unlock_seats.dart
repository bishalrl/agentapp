import '../../../../core/utils/result.dart';
import '../repositories/booking_repository.dart';

class UnlockSeats {
  final BookingRepository repository;
  
  UnlockSeats(this.repository);
  
  Future<Result<void>> call({
    required String busId,
    required List<dynamic> seatNumbers, // Supports both int (legacy) and String (new format)
  }) async {
    return await repository.unlockSeats(busId, seatNumbers);
  }
}
