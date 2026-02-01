class CounterRequestEntity {
  final String id;
  final String counterId;
  final BusRequestEntity bus;
  final List<String> requestedSeats;
  final List<int>? approvedSeats; // Seats approved by owner (null if not approved yet)
  final String status; // PENDING, APPROVED, REJECTED, EXPIRED
  final String? message;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;

  const CounterRequestEntity({
    required this.id,
    required this.counterId,
    required this.bus,
    required this.requestedSeats,
    this.approvedSeats,
    required this.status,
    this.message,
    required this.createdAt,
    this.expiresAt,
    this.respondedAt,
  });
}

class BusRequestEntity {
  final String id;
  final String name;
  final String vehicleNumber;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final int totalSeats;
  final List<String>? seatConfiguration;

  const BusRequestEntity({
    required this.id,
    required this.name,
    required this.vehicleNumber,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.totalSeats,
    this.seatConfiguration,
  });
}
