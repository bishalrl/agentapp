import '../../../../core/utils/result.dart';
import '../entities/audit_log_entity.dart';
import '../repositories/audit_log_repository.dart';

class GetAuditLogs {
  final AuditLogRepository repository;

  GetAuditLogs(this.repository);

  Future<Result<List<AuditLogEntity>>> call({
    String? action,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    return await repository.getAuditLogs(
      action: action,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }
}
