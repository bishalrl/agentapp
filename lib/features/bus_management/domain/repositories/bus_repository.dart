import '../../../../core/utils/result.dart';
import '../entities/bus_entity.dart';

abstract class BusRepository {
  Future<Result<BusEntity>> createBus({
    required String name,
    required String vehicleNumber,
    required String from,
    required String to,
    required DateTime date,
    required String time,
    String? arrival,
    String? timeFormat, // '12h' or '24h' (default: '12h')
    String? arrivalFormat, // '12h' or '24h' (default: '12h')
    String? tripDirection, // 'going' or 'returning' (default: 'going')
    required double price,
    required int totalSeats,
    String? busType,
    String? driverContact,
    String? driverEmail, // Driver email for invitation system
    String? driverName, // Driver name (required if driverEmail provided)
    String? driverLicenseNumber, // Driver license number (required if driverEmail provided)
    String? driverId, // Existing driver ID
    double? commissionRate,
    List<int>? allowedSeats,
    List<String>? seatConfiguration, // Custom seat identifiers (Nepal standard: A/B only, e.g., ["A1", "A4", "B6"])
    List<String>? amenities, // Bus amenities (e.g., ["WiFi", "AC", "TV"])
    List<Map<String, String>>? boardingPoints, // Boarding points with location and time
    List<Map<String, String>>? droppingPoints, // Dropping points with location and time
    String? routeId, // Route ID reference
    String? scheduleId, // Schedule ID reference
    double? distance, // Distance in kilometers
    int? estimatedDuration, // Estimated duration in minutes
    // Recurring Schedule Fields
    bool? isRecurring, // Enable recurring schedule
    List<int>? recurringDays, // Days of week [0=Sun, 6=Sat]
    DateTime? recurringStartDate, // Recurring start date
    DateTime? recurringEndDate, // Recurring end date
    String? recurringFrequency, // 'daily' | 'weekly' | 'monthly'
    // Auto-Activation Fields
    bool? autoActivate, // Enable date-based auto activation
    DateTime? activeFromDate, // Auto-activation start date
    DateTime? activeToDate, // Auto-activation end date
  });
  
  Future<Result<BusEntity>> updateBus({
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
  });
  
  Future<Result<void>> deleteBus(String busId);
  
  Future<Result<List<BusEntity>>> getMyBuses({
    String? date,
    String? route,
    String? status,
  });
  
  Future<Result<List<BusEntity>>> getAssignedBuses({
    String? date,
    String? from,
    String? to,
  });
  
  Future<Result<BusEntity>> searchBusByNumber({
    required String busNumber,
  });
  
  Future<Result<BusEntity>> activateBus(String busId);
  Future<Result<BusEntity>> deactivateBus(String busId);
}

