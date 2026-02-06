import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';
import '../../domain/entities/counter_request_entity.dart';
import '../../domain/repositories/counter_request_repository.dart';
import '../datasources/counter_request_remote_data_source.dart';

/// Implementation of [CounterRequestRepository] that handles counter request-related data operations.
/// 
/// This repository acts as a bridge between the domain layer and the data layer,
/// providing a clean abstraction for counter request operations including:
/// - Requesting bus access with specific seat numbers
/// - Getting all requests made by the counter
/// 
/// The repository handles:
/// - Token management and authentication
/// - Error handling and exception mapping to failures
/// - Session management for authentication errors
/// - Data transformation between models and entities
class CounterRequestRepositoryImpl implements CounterRequestRepository {
  final CounterRequestRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;

  CounterRequestRepositoryImpl({
    required this.remoteDataSource,
    required this.getStoredToken,
  });

  @override
  Future<Result<CounterRequestEntity>> requestBusAccess({
    required String busId,
    required List<String> requestedSeats,
    String? message,
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
      print('📦 CounterRequestRepositoryImpl.requestBusAccess: Starting');
      final request = await remoteDataSource.requestBusAccess(
        token: token,
        busId: busId,
        requestedSeats: requestedSeats,
        message: message,
      );
      print('   ✅ Bus access request created successfully');
      return Success(request);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      print('   ❌ NetworkException: ${e.message}');
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<List<CounterRequestEntity>>> getCounterRequests() async {
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
      print('📦 CounterRequestRepositoryImpl.getCounterRequests: Starting');
      final requests = await remoteDataSource.getCounterRequests(token);
      print('   ✅ Counter requests retrieved successfully: ${requests.length} requests');
      return Success(requests);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      print('   ❌ NetworkException: ${e.message}');
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }
}
