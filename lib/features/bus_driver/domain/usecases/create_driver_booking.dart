import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class CreateDriverBooking {
  final DriverRepository repository;
  
  CreateDriverBooking(this.repository);
  
  Future<Result<Map<String, dynamic>>> call({
    required String busId,
    required List<dynamic> seatNumbers,
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
  }) async {
    return await repository.createDriverBooking(
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
