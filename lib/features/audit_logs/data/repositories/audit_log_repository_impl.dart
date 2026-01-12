import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/repositories/audit_log_repository.dart';
import '../datasources/audit_log_remote_data_source.dart';
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final AuditLogRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;

  AuditLogRepositoryImpl({
    required this.remoteDataSource,
    required this.getStoredToken,
  });

  @override
  Future<Result<List<AuditLogEntity>>> getAuditLogs({
    String? action,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final logs = await remoteDataSource.getAuditLogs(
        action: action,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
        token: token,
      );
      return Success(logs);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
