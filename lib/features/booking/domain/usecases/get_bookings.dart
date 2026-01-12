import '../../../../core/utils/result.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookings {
  final BookingRepository repository;
  
  GetBookings(this.repository);
  
  Future<Result<List<BookingEntity>>> call({
    String? date,
    String? busId,
    String? status,
    String? paymentMethod,
  }) async {
    return await repository.getBookings(
      date: date,
      busId: busId,
      status: status,
      paymentMethod: paymentMethod,
    );
  }
}
