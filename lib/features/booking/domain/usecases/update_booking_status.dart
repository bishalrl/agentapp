import '../../../../core/utils/result.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class UpdateBookingStatus {
  final BookingRepository repository;

  UpdateBookingStatus(this.repository);

  Future<Result<BookingEntity>> call({
    required String bookingId,
    required String status,
  }) async {
    return await repository.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );
  }
}
