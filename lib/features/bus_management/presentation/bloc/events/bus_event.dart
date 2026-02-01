import '../../../../../core/bloc/base_bloc_event.dart';

abstract class BusEvent extends BaseBlocEvent {
  const BusEvent();
}

class CreateBusEvent extends BusEvent {
  final String name;
  final String vehicleNumber;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final String? arrival;
  final String? timeFormat; // '12h' or '24h' (default: '12h')
  final String? arrivalFormat; // '12h' or '24h' (default: '12h')
  final String? tripDirection; // 'going' or 'returning' (default: 'going')
  final double price;
  final int totalSeats;
  final String? busType;
  final String? driverContact;
  final String? driverEmail; // Driver email for invitation system
  final String? driverName; // Driver name (required if driverEmail provided)
  final String? driverLicenseNumber; // Driver license number (required if driverEmail provided)
  final String? driverId; // Existing driver ID
  final double? commissionRate;
  final List<int>? allowedSeats;
  final List<String>? seatConfiguration; // Custom seat identifiers (Nepal standard: A/B only, e.g., ["A1", "A4", "B6"])
  final List<String>? amenities; // Bus amenities (e.g., ["WiFi", "AC", "TV"])
  final List<Map<String, String>>? boardingPoints; // Boarding points with location and time
  final List<Map<String, String>>? droppingPoints; // Dropping points with location and time
  final String? routeId; // Route ID reference
  final String? scheduleId; // Schedule ID reference
  final double? distance; // Distance in kilometers
  final int? estimatedDuration; // Estimated duration in minutes
  
  // Recurring Schedule Fields
  final bool? isRecurring; // Enable recurring schedule
  final List<int>? recurringDays; // Days of week [0=Sun, 6=Sat]
  final DateTime? recurringStartDate; // Recurring start date
  final DateTime? recurringEndDate; // Recurring end date
  final String? recurringFrequency; // 'daily' | 'weekly' | 'monthly'
  
  // Auto-Activation Fields
  final bool? autoActivate; // Enable date-based auto activation
  final DateTime? activeFromDate; // Auto-activation start date
  final DateTime? activeToDate; // Auto-activation end date

  const CreateBusEvent({
    required this.name,
    required this.vehicleNumber,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    this.arrival,
    this.timeFormat,
    this.arrivalFormat,
    this.tripDirection,
    required this.price,
    required this.totalSeats,
    this.busType,
    this.driverContact,
    this.driverEmail,
    this.driverName,
    this.driverLicenseNumber,
    this.driverId,
    this.commissionRate,
    this.allowedSeats,
    this.seatConfiguration,
    this.amenities,
    this.boardingPoints,
    this.droppingPoints,
    this.routeId,
    this.scheduleId,
    this.distance,
    this.estimatedDuration,
    this.isRecurring,
    this.recurringDays,
    this.recurringStartDate,
    this.recurringEndDate,
    this.recurringFrequency,
    this.autoActivate,
    this.activeFromDate,
    this.activeToDate,
  });

  @override
  List<Object?> get props => [
        name,
        vehicleNumber,
        from,
        to,
        date,
        time,
        arrival,
        timeFormat,
        arrivalFormat,
        tripDirection,
        price,
        totalSeats,
        busType,
        driverContact,
        driverEmail,
        driverName,
        driverLicenseNumber,
        driverId,
        commissionRate,
        allowedSeats,
        seatConfiguration,
        amenities,
        boardingPoints,
        droppingPoints,
        routeId,
        scheduleId,
        distance,
        estimatedDuration,
        isRecurring,
        recurringDays,
        recurringStartDate,
        recurringEndDate,
        recurringFrequency,
        autoActivate,
        activeFromDate,
        activeToDate,
      ];
}

class UpdateBusEvent extends BusEvent {
  final String busId;
  final String? name;
  final String? vehicleNumber;
  final String? from;
  final String? to;
  final DateTime? date;
  final String? time;
  final String? arrival;
  final double? price;
  final int? totalSeats;
  final String? busType;
  final String? driverContact;
  final String? driverEmail; // Driver email for invitation system
  final String? driverName; // Driver name (required if driverEmail provided)
  final String? driverLicenseNumber; // Driver license number (required if driverEmail provided)
  final String? driverId; // Existing driver ID
  final double? commissionRate;
  final List<int>? allowedSeats;
  final List<String>? seatConfiguration; // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
  final List<String>? amenities; // Bus amenities (e.g., ["WiFi", "AC", "TV"])
  final List<Map<String, String>>? boardingPoints; // Boarding points with location and time
  final List<Map<String, String>>? droppingPoints; // Dropping points with location and time
  final String? routeId; // Route ID reference
  final String? scheduleId; // Schedule ID reference
  final double? distance; // Distance in kilometers
  final int? estimatedDuration; // Estimated duration in minutes

  const UpdateBusEvent({
    required this.busId,
    this.name,
    this.vehicleNumber,
    this.from,
    this.to,
    this.date,
    this.time,
    this.arrival,
    this.price,
    this.totalSeats,
    this.busType,
    this.driverContact,
    this.driverEmail,
    this.driverName,
    this.driverLicenseNumber,
    this.driverId,
    this.commissionRate,
    this.allowedSeats,
    this.seatConfiguration,
    this.amenities,
    this.boardingPoints,
    this.droppingPoints,
    this.routeId,
    this.scheduleId,
    this.distance,
    this.estimatedDuration,
  });

  @override
  List<Object?> get props => [
        busId,
        name,
        vehicleNumber,
        from,
        to,
        date,
        time,
        arrival,
        price,
        totalSeats,
        busType,
        driverContact,
        driverEmail,
        driverName,
        driverLicenseNumber,
        driverId,
        commissionRate,
        allowedSeats,
        seatConfiguration,
        amenities,
        boardingPoints,
        droppingPoints,
        routeId,
        scheduleId,
        distance,
        estimatedDuration,
      ];
}

class DeleteBusEvent extends BusEvent {
  final String busId;

  const DeleteBusEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class GetMyBusesEvent extends BusEvent {
  final String? date;
  final String? route;
  final String? status;

  const GetMyBusesEvent({
    this.date,
    this.route,
    this.status,
  });

  @override
  List<Object?> get props => [date, route, status];
}

class GetAssignedBusesEvent extends BusEvent {
  final String? date;
  final String? from;
  final String? to;

  const GetAssignedBusesEvent({
    this.date,
    this.from,
    this.to,
  });

  @override
  List<Object?> get props => [date, from, to];
}

/// Fetches all buses available to the user: assigned buses + own (my) buses, merged and deduplicated.
class GetAllAvailableBusesEvent extends BusEvent {
  final String? date;
  final String? from;
  final String? to;

  const GetAllAvailableBusesEvent({
    this.date,
    this.from,
    this.to,
  });

  @override
  List<Object?> get props => [date, from, to];
}

class SearchBusByNumberEvent extends BusEvent {
  final String busNumber;

  const SearchBusByNumberEvent({required this.busNumber});

  @override
  List<Object?> get props => [busNumber];
}

class ActivateBusEvent extends BusEvent {
  final String busId;

  const ActivateBusEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class DeactivateBusEvent extends BusEvent {
  final String busId;

  const DeactivateBusEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

