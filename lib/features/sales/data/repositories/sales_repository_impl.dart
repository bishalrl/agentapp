import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_data_source.dart';
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;

  SalesRepositoryImpl({
    required this.remoteDataSource,
    required this.getStoredToken,
  });

  @override
  Future<Result<Map<String, dynamic>>> getSalesSummary({
    String? startDate,
    String? endDate,
    String? busId,
    String? paymentMethod,
    String? groupBy,
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
      final data = await remoteDataSource.getSalesSummary(
        startDate: startDate,
        endDate: endDate,
        busId: busId,
        paymentMethod: paymentMethod,
        groupBy: groupBy,
        token: token,
      );
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }
}
