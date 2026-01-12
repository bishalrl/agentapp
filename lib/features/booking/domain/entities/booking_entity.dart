class BookingEntity {
  final String id;
  final String ticketNumber;
  final String busId;
  final BusInfoEntity bus;
  final List<int> seatNumbers;
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
  final List<int> bookedSeats;
  final List<SeatLockEntity> lockedSeats;
  
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
  });
}

class SeatLockEntity {
  final int seatNumber;
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

