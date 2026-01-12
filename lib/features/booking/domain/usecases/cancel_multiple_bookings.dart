import '../../../../core/utils/result.dart';
import '../repositories/booking_repository.dart';

class CancelMultipleBookings {
  final BookingRepository repository;

  CancelMultipleBookings(this.repository);

  Future<Result<Map<String, dynamic>>> call({
    required List<String> bookingIds,
  }) async {
    return await repository.cancelMultipleBookings(bookingIds: bookingIds);
  }
}
