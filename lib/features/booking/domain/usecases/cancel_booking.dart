import '../../../../core/utils/result.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CancelBooking {
  final BookingRepository repository;
  
  CancelBooking(this.repository);
  
  Future<Result<BookingEntity>> call(String bookingId) async {
    return await repository.cancelBooking(bookingId);
  }
}
