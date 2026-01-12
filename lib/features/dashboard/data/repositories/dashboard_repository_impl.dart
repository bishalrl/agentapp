import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;

  DashboardRepositoryImpl(this.remoteDataSource, {required this.getStoredToken});

  @override
  Future<Result<DashboardEntity>> getDashboard() async {
    print('📦 DashboardRepositoryImpl.getDashboard: Starting');
    
    // Get token from storage
    print('   Getting stored token...');
    final tokenResult = await getStoredToken();
    
    String? token;
    if (tokenResult is Error<String?>) {
      print('   ❌ Failed to get token: ${tokenResult.failure.message}');
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      print('   ❌ Token is null or empty');
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    print('   ✅ Token retrieved, fetching dashboard data');

    try {
      final dashboard = await remoteDataSource.getDashboard(token);
      print('   ✅ Dashboard data retrieved successfully');
      return Success(dashboard);
    } on AuthenticationException catch (e) {
      print('   ❌ AuthenticationException: ${e.message}');
      // Session manager will handle logout and navigation
      // Don't trigger it again if already handling
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      print('   ❌ NetworkException: ${e.message}');
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e, stackTrace) {
      print('   ❌ Unexpected error: $e');
      print('   StackTrace: $stackTrace');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

