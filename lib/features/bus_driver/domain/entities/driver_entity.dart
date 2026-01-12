class DriverEntity {
  final String id;
  final String name;
  final String phoneNumber;
  final String? licenseNumber;
  final String? email;
  final List<String> assignedBusIds;
  final bool isLocationSharing;
  final LocationEntity? lastLocation;
  
  const DriverEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.licenseNumber,
    this.email,
    required this.assignedBusIds,
    required this.isLocationSharing,
    this.lastLocation,
  });
}

class LocationEntity {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? heading;
  final double? accuracy;
  
  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.heading,
    this.accuracy,
  });
}

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
  });
}

