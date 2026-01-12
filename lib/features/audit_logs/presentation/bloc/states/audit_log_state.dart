import '../../../domain/entities/audit_log_entity.dart';

abstract class AuditLogState {}

class AuditLogInitial extends AuditLogState {}

class AuditLogLoading extends AuditLogState {}

class AuditLogsLoaded extends AuditLogState {
  final List<AuditLogEntity> logs;

  AuditLogsLoaded(this.logs);
}

class AuditLogError extends AuditLogState {
  final String message;

  AuditLogError(this.message);
}
