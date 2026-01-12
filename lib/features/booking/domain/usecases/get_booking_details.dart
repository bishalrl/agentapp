import '../../../../core/utils/result.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingDetails {
  final BookingRepository repository;
  
  GetBookingDetails(this.repository);
  
  Future<Result<BookingEntity>> call(String bookingId) async {
    return await repository.getBookingDetails(bookingId);
  }
}
