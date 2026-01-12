import '../../../../core/utils/result.dart';
import '../entities/audit_log_entity.dart';

abstract class AuditLogRepository {
  Future<Result<List<AuditLogEntity>>> getAuditLogs({
    String? action,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  });
}
