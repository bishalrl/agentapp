import '../../../../core/utils/result.dart';
import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class UpdateBus {
  final BusRepository repository;

  UpdateBus(this.repository);

  Future<Result<BusEntity>> call({
    required String busId,
    String? name,
    String? vehicleNumber,
    String? from,
    String? to,
    DateTime? date,
    String? time,
    String? arrival,
    double? price,
    int? totalSeats,
    String? busType,
    String? driverContact,
    String? driverEmail, // Driver email for invitation system
    String? driverName, // Driver name (required if driverEmail provided)
    String? driverLicenseNumber, // Driver license number (required if driverEmail provided)
    String? driverId, // Existing driver ID
    double? commissionRate,
    List<int>? allowedSeats,
    List<String>? seatConfiguration, // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
    List<String>? amenities, // Bus amenities (e.g., ["WiFi", "AC", "TV"])
    List<Map<String, String>>? boardingPoints, // Boarding points with location and time
    List<Map<String, String>>? droppingPoints, // Dropping points with location and time
    String? routeId, // Route ID reference
    String? scheduleId, // Schedule ID reference
    double? distance, // Distance in kilometers
    int? estimatedDuration, // Estimated duration in minutes
  }) async {
    return await repository.updateBus(
      busId: busId,
      name: name,
      vehicleNumber: vehicleNumber,
      from: from,
      to: to,
      date: date,
      time: time,
      arrival: arrival,
      price: price,
      totalSeats: totalSeats,
      busType: busType,
      driverContact: driverContact,
      driverEmail: driverEmail,
      driverName: driverName,
      driverLicenseNumber: driverLicenseNumber,
      driverId: driverId,
      commissionRate: commissionRate,
      allowedSeats: allowedSeats,
      seatConfiguration: seatConfiguration,
      amenities: amenities,
      boardingPoints: boardingPoints,
      droppingPoints: droppingPoints,
      routeId: routeId,
      scheduleId: scheduleId,
      distance: distance,
      estimatedDuration: estimatedDuration,
    );
  }
}

