import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';

abstract class DriverRepository {
  Future<Result<DriverEntity>> verifyOtp(String phoneNumber, String otp);
  Future<Result<DriverEntity>> getDriverProfile();
  Future<Result<List<BusEntity>>> getAssignedBuses();
  Future<Result<void>> startLocationSharing(String busId);
  Future<Result<void>> stopLocationSharing();
  Future<Result<void>> updateLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  });
  Future<Result<TripStatusEntity>> getTripStatus(String busId);
}

class TripStatusEntity {
  final BusEntity bus;
  final int passengerCount;
  final int totalSeats;
  final int availableSeats;
  final bool isLocationSharing;
  
  const TripStatusEntity({
    required this.bus,
    required this.passengerCount,
    required this.totalSeats,
    required this.availableSeats,
    required this.isLocationSharing,
  });
}

