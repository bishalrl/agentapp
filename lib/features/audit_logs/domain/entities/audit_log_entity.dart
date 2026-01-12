class AuditLogEntity {
  final String id;
  final String action; // booking_created, bus_created, driver_invited, etc.
  final Map<String, dynamic> details;
  final String? busId;
  final String? bookingId;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  AuditLogEntity({
    required this.id,
    required this.action,
    required this.details,
    this.busId,
    this.bookingId,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });
}
