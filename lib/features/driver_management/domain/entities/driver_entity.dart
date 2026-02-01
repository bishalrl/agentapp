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
  // Driver Invitation System Fields
  final String? invitationCode; // Unique 6-character alphanumeric code
  final DateTime? invitationExpiresAt; // 7 days expiration
  final DateTime? invitationSentAt; // Tracking when invitation was sent
  final String? password; // For authentication after registration

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
    this.invitationCode,
    this.invitationExpiresAt,
    this.invitationSentAt,
    this.password,
  });
}
