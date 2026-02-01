class BusEntity {
  final String id;
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
  final String? tripStatus; // 'scheduled' | 'in_transit' | 'reached' | 'completed'
  final DateTime? reachedAt; // Timestamp when driver marked as reached
  final double price;
  final int totalSeats;
  final String? busType;
  final String? driverContact;
  final String? driverId;
  final String? driverEmail; // Driver email for invitation system
  final String? driverName; // Driver name (required if driverEmail provided)
  final double? commissionRate;
  final String? ownerId;
  final String? ownerEmail;
  final String? accessId; // Counter bus access ID (if counter has access to this bus)
  final List<int>? allowedSeats;
  final List<String>? seatConfiguration; // Custom seat identifiers (Nepal standard: A/B only, e.g., ["A1", "A4", "B6"])
  final List<String>? amenities; // Bus amenities (e.g., ["WiFi", "AC", "TV"])
  final List<Map<String, String>>? boardingPoints; // Boarding points with location and time
  final List<Map<String, String>>? droppingPoints; // Dropping points with location and time
  final String? routeId; // Route ID reference
  final String? scheduleId; // Schedule ID reference
  final String? parentBusId; // Parent bus ID (for round trips)
  final String? recurringScheduleId; // Recurring schedule ID
  final double? distance; // Distance in kilometers
  final int? estimatedDuration; // Estimated duration in minutes
  final String? mainImageUrl; // Main bus image URL
  final List<String>? galleryImages; // Gallery image URLs
  final bool isActive;
  
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
  
  const BusEntity({
    required this.id,
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
    this.tripStatus,
    this.reachedAt,
    required this.price,
    required this.totalSeats,
    this.busType,
    this.driverContact,
    this.driverId,
    this.driverEmail,
    this.driverName,
    this.commissionRate,
    this.ownerId,
    this.ownerEmail,
    this.accessId,
    this.allowedSeats,
    this.seatConfiguration,
    this.amenities,
    this.boardingPoints,
    this.droppingPoints,
    this.routeId,
    this.scheduleId,
    this.parentBusId,
    this.recurringScheduleId,
    this.distance,
    this.estimatedDuration,
    this.mainImageUrl,
    this.galleryImages,
    this.isActive = true,
    this.isRecurring,
    this.recurringDays,
    this.recurringStartDate,
    this.recurringEndDate,
    this.recurringFrequency,
    this.autoActivate,
    this.activeFromDate,
    this.activeToDate,
  });
}

