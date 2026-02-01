import '../../../../core/utils/result.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;
  
  CreateBooking(this.repository);
  
  Future<Result<BookingEntity>> call({
    required String busId,
    required List<dynamic> seatNumbers, // Supports both int (legacy) and String (new format)
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
  }) async {
    return await repository.createBooking(
      busId: busId,
      seatNumbers: seatNumbers,
      passengerName: passengerName,
      contactNumber: contactNumber,
      passengerEmail: passengerEmail,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      luggage: luggage,
      bagCount: bagCount,
      paymentMethod: paymentMethod,
    );
  }
}

