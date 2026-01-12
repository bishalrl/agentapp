import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/audit_log_model.dart';

abstract class AuditLogRemoteDataSource {
  Future<List<AuditLogModel>> getAuditLogs({
    String? action,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
    required String token,
  });
}

class AuditLogRemoteDataSourceImpl implements AuditLogRemoteDataSource {
  final ApiClient apiClient;

  AuditLogRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<AuditLogModel>> getAuditLogs({
    String? action,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (action != null) queryParams['action'] = action;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        ApiConstants.counterAuditLogs,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final logs = response['data']['logs'] as List<dynamic>;
        return logs
            .map((l) => AuditLogModel.fromJson(l as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to get audit logs');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get audit logs: ${e.toString()}');
    }
  }
}
