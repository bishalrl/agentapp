abstract class AuditLogEvent {}

class GetAuditLogsEvent extends AuditLogEvent {
  final String? action;
  final String? startDate;
  final String? endDate;
  final int? page;
  final int? limit;

  GetAuditLogsEvent({
    this.action,
    this.startDate,
    this.endDate,
    this.page,
    this.limit,
  });
}
