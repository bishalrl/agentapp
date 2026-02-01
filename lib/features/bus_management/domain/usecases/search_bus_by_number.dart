import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';
import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class SearchBusByNumber {
  final BusRepository repository;
  final GetStoredToken getStoredToken;

  SearchBusByNumber(this.repository, this.getStoredToken);

  Future<Result<BusEntity>> call({
    required String busNumber,
  }) async {
    print('🎯 SearchBusByNumber UseCase.call: Starting');
    print('   BusNumber: $busNumber');
    
    if (busNumber.trim().isEmpty) {
      return const Error(ServerFailure('Bus number cannot be empty'));
    }
    
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
      final result = await repository.searchBusByNumber(
        busNumber: busNumber.trim(),
      );
      
      if (result is Success<BusEntity>) {
        print('   ✅ SearchBusByNumber UseCase: Success - Bus found: ${result.data.name}');
      } else if (result is Error<BusEntity>) {
        print('   ❌ SearchBusByNumber UseCase: Error - ${result.failure.message}');
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
