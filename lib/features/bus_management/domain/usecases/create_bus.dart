import '../../../../core/utils/result.dart';
import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class CreateBus {
  final BusRepository repository;

  CreateBus(this.repository);

  Future<Result<BusEntity>> call({
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
  }) async {
    print('🎯 CreateBus UseCase.call: Starting');
    print('   Name: $name, From: $from, To: $to, Date: $date');
    print('   Time: $time, Arrival: $arrival');
    print('   TimeFormat: $timeFormat, ArrivalFormat: $arrivalFormat');
    print('   TripDirection: $tripDirection');
    print('   SeatConfiguration: $seatConfiguration');
    print('   DriverEmail: $driverEmail, DriverName: $driverName');
    print('   IsRecurring: $isRecurring, AutoActivate: $autoActivate');
    final result = await repository.createBus(
      name: name,
      vehicleNumber: vehicleNumber,
      from: from,
      to: to,
      date: date,
      time: time,
      arrival: arrival,
      timeFormat: timeFormat,
      arrivalFormat: arrivalFormat,
      tripDirection: tripDirection,
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
      isRecurring: isRecurring,
      recurringDays: recurringDays,
      recurringStartDate: recurringStartDate,
      recurringEndDate: recurringEndDate,
      recurringFrequency: recurringFrequency,
      autoActivate: autoActivate,
      activeFromDate: activeFromDate,
      activeToDate: activeToDate,
    );
    if (result is Success<BusEntity>) {
      print('   ✅ CreateBus UseCase: Success');
    } else if (result is Error<BusEntity>) {
      print('   ❌ CreateBus UseCase: Error - ${result.failure.message}');
    }
    return result;
  }
}

