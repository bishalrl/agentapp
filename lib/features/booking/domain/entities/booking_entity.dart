class BookingEntity {
  final String id;
  final String ticketNumber;
  final String busId;
  final BusInfoEntity bus;
  final List<dynamic> seatNumbers; // Supports both int (legacy) and String (new format)
  final String passengerName;
  final String contactNumber;
  final String? passengerEmail;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? luggage;
  final int? bagCount;
  final double price;
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  
  const BookingEntity({
    required this.id,
    required this.ticketNumber,
    required this.busId,
    required this.bus,
    required this.seatNumbers,
    required this.passengerName,
    required this.contactNumber,
    this.passengerEmail,
    this.pickupLocation,
    this.dropoffLocation,
    this.luggage,
    this.bagCount,
    required this.price,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });
}

class BusInfoEntity {
  final String id;
  final String name;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final String? arrival;
  final double price;
  final int totalSeats;
  final int filledSeats;
  final int availableSeats;
  final List<dynamic> bookedSeats; // Supports both int (legacy) and String (new format)
  final List<SeatLockEntity> lockedSeats;
  final List<String>? seatConfiguration; // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
  final String? accessId; // Counter bus access ID (if counter has access)
  final List<int>? allowedSeats; // Seats counter is allowed to book (null = all seats, empty = no access)
  final bool? hasAccess; // Whether counter has access to this bus (from API response)
  
  // New backend fields for enhanced seat access management
  final int? allowedSeatsCount; // Number of allowed seats
  final bool? hasRestrictedAccess; // true if counter has limited seats
  final bool? requiresWallet; // true if wallet pre-funding is required for booking
  final bool? hasNoAccess; // true if counter has no access
  final List<int>? availableAllowedSeats; // Seats that are BOTH allowed AND available
  final int? availableAllowedSeatsCount; // Count of available allowed seats
  
  const BusInfoEntity({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    this.arrival,
    required this.price,
    required this.totalSeats,
    required this.filledSeats,
    required this.availableSeats,
    required this.bookedSeats,
    required this.lockedSeats,
    this.seatConfiguration,
    this.accessId,
    this.allowedSeats,
    this.hasAccess,
    this.allowedSeatsCount,
    this.hasRestrictedAccess,
    this.requiresWallet,
    this.hasNoAccess,
    this.availableAllowedSeats,
    this.availableAllowedSeatsCount,
  });
}

class SeatLockEntity {
  final dynamic seatNumber; // Supports both int (legacy) and String (new format)
  final String lockedBy;
  final String lockedByType;
  final DateTime expiresAt;
  
  const SeatLockEntity({
    required this.seatNumber,
    required this.lockedBy,
    required this.lockedByType,
    required this.expiresAt,
  });
}

