import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';
import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class GetAssignedBuses {
  final BusRepository repository;
  final GetStoredToken getStoredToken;

  GetAssignedBuses(this.repository, this.getStoredToken);

  Future<Result<List<BusEntity>>> call({
    String? date,
    String? from,
    String? to,
  }) async {
    print('🎯 GetAssignedBuses UseCase.call: Starting');
    
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
      final result = await repository.getAssignedBuses(
        date: date,
        from: from,
        to: to,
      );
      
      if (result is Success<List<BusEntity>>) {
        print('   ✅ GetAssignedBuses UseCase: Success - ${result.data.length} buses');
      } else if (result is Error<List<BusEntity>>) {
        print('   ❌ GetAssignedBuses UseCase: Error - ${result.failure.message}');
      }
      
      return result;
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
