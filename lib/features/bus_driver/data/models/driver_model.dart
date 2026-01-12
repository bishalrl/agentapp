import '../../domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    super.licenseNumber,
    super.email,
    required super.assignedBusIds,
    required super.isLocationSharing,
    super.lastLocation,
  });
  
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      licenseNumber: json['licenseNumber'] as String?,
      email: json['email'] as String?,
      assignedBusIds: (json['assignedBusIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      isLocationSharing: json['isLocationSharing'] as bool? ?? false,
      lastLocation: json['lastLocation'] != null
          ? LocationModel.fromJson(json['lastLocation'] as Map<String, dynamic>)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      'email': email,
      'assignedBusIds': assignedBusIds,
      'isLocationSharing': isLocationSharing,
      'lastLocation': lastLocation != null
          ? (lastLocation as LocationModel).toJson()
          : null,
    };
  }
}

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    required super.timestamp,
    super.speed,
    super.heading,
    super.accuracy,
  });
  
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      accuracy: json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'heading': heading,
      'accuracy': accuracy,
    };
  }
}

class BusModel extends BusEntity {
  const BusModel({
    required super.id,
    required super.name,
    required super.vehicleNumber,
    required super.from,
    required super.to,
    required super.date,
    required super.time,
    super.arrival,
    required super.price,
    required super.totalSeats,
    super.busType,
  });
  
  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      arrival: json['arrival'] as String?,
      price: (json['price'] as num).toDouble(),
      totalSeats: json['totalSeats'] as int,
      busType: json['busType'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicleNumber': vehicleNumber,
      'from': from,
      'to': to,
      'date': date.toIso8601String(),
      'time': time,
      'arrival': arrival,
      'price': price,
      'totalSeats': totalSeats,
      'busType': busType,
    };
  }
}

