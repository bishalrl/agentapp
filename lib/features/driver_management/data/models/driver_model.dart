import '../../domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  DriverModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    super.email,
    required super.licenseNumber,
    super.licenseExpiry,
    super.address,
    required super.status,
    super.assignedBusId,
    required super.assignedBusIds,
    required super.invitedBy,
    required super.invitedByType,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      licenseNumber: json['licenseNumber'] ?? '',
      licenseExpiry: json['licenseExpiry'] != null
          ? DateTime.parse(json['licenseExpiry'])
          : null,
      address: json['address'],
      status: json['status'] ?? 'pending',
      assignedBusId: json['assignedBusId'],
      assignedBusIds: json['assignedBusIds'] != null
          ? List<String>.from(json['assignedBusIds'])
          : [],
      invitedBy: json['invitedBy'] ?? '',
      invitedByType: json['invitedByType'] ?? 'BusAgent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      'licenseNumber': licenseNumber,
      if (licenseExpiry != null)
        'licenseExpiry': licenseExpiry!.toIso8601String().split('T')[0],
      if (address != null) 'address': address,
    };
  }
}
