import '../../domain/entities/audit_log_entity.dart';

class AuditLogModel extends AuditLogEntity {
  AuditLogModel({
    required super.id,
    required super.action,
    required super.details,
    super.busId,
    super.bookingId,
    super.ipAddress,
    super.userAgent,
    required super.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['_id'] ?? json['id'] ?? '',
      action: json['action'] ?? '',
      details: json['details'] as Map<String, dynamic>? ?? {},
      busId: json['busId'],
      bookingId: json['bookingId'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
