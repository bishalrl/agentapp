class DriverEntity {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String licenseNumber;
  final DateTime? licenseExpiry;
  final String? address;
  final String status; // pending, verified, active
  final String? assignedBusId;
  final List<String> assignedBusIds;
  final String invitedBy;
  final String invitedByType;

  DriverEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.licenseNumber,
    this.licenseExpiry,
    this.address,
    required this.status,
    this.assignedBusId,
    required this.assignedBusIds,
    required this.invitedBy,
    required this.invitedByType,
  });
}
