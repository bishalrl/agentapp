import '../../../../core/utils/result.dart';
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Result<List<BusInfoEntity>>> getAvailableBuses({
    String? date,
    String? route,
    String? status,
  });
  Future<Result<BusInfoEntity>> getBusDetails(String busId);
  Future<Result<BookingEntity>> createBooking({
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
    String? holdId, // Optional wallet hold ID
  });
  Future<Result<List<BookingEntity>>> getBookings({
    String? date,
    String? busId,
    String? status,
    String? paymentMethod,
  });
  Future<Result<BookingEntity>> getBookingDetails(String bookingId);
  Future<Result<BookingEntity>> cancelBooking(String bookingId);
  Future<Result<Map<String, dynamic>>> cancelMultipleBookings({
    required List<String> bookingIds,
  });
  Future<Result<BookingEntity>> updateBookingStatus({
    required String bookingId,
    required String status,
  });
  Future<Result<void>> lockSeats(String busId, List<dynamic> seatNumbers); // Supports both int and String
  Future<Result<void>> unlockSeats(String busId, List<dynamic> seatNumbers); // Supports both int and String
}

