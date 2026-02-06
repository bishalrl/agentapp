import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;
  final GetStoredToken getStoredToken;

  DashboardRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource, {
    required this.getStoredToken,
  });

  @override
  Future<Result<DashboardEntity>> getDashboard() async {
    print('📦 DashboardRepositoryImpl.getDashboard: Starting');
    
    // Try to get cached dashboard first
    DashboardEntity? cachedDashboard;
    try {
      cachedDashboard = await localDataSource.getCachedDashboard();
      if (cachedDashboard != null) {
        print('   ✅ Found cached dashboard data');
      }
    } catch (e) {
      print('   ⚠️ Failed to get cached dashboard: $e');
    }
    
    // Get token from storage
    print('   Getting stored token...');
    final tokenResult = await getStoredToken();
    
    String? token;
    if (tokenResult is Error<String?>) {
      print('   ❌ Failed to get token: ${tokenResult.failure.message}');
      // Return cached data if available
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      print('   ❌ Token is null or empty');
      // Return cached data if available
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    print('   ✅ Token retrieved, fetching dashboard data from API');

    try {
      final dashboard = await remoteDataSource.getDashboard(token);
      print('   ✅ Dashboard data retrieved successfully');
      
      // Cache the dashboard
      try {
        await localDataSource.cacheDashboard(dashboard);
        print('   ✅ Dashboard cached successfully');
      } catch (e) {
        print('   ⚠️ Failed to cache dashboard: $e');
      }
      
      return Success(dashboard);
    } on AuthenticationException catch (e) {
      print('   ❌ AuthenticationException: ${e.message}');
      // Return cached data if available
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      // Session manager will handle logout and navigation
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      print('   ❌ NetworkException: ${e.message}');
      // Return cached data if available
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      // Return cached data if available
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e, stackTrace) {
      print('   ❌ Unexpected error: $e');
      print('   StackTrace: $stackTrace');
      // Return cached data if available
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }
}

