class BusEntity {
  final String id;
  final String name;
  final String vehicleNumber;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final String? arrival;
  final double price;
  final int totalSeats;
  final String? busType;
  final String? driverContact;
  final String? driverId;
  final double? commissionRate;
  final String? ownerId;
  final String? ownerEmail;
  final List<int>? allowedSeats;
  final bool isActive;
  
  const BusEntity({
    required this.id,
    required this.name,
    required this.vehicleNumber,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    this.arrival,
    required this.price,
    required this.totalSeats,
    this.busType,
    this.driverContact,
    this.driverId,
    this.commissionRate,
    this.ownerId,
    this.ownerEmail,
    this.allowedSeats,
    this.isActive = true,
  });
}

