import '../../../../core/utils/result.dart';
import '../../../../core/utils/network_info.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/smart_api_client.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_model.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';

/// Optimized Dashboard Repository with:
/// - Cache-first strategy
/// - Smart API client usage
/// - Error recovery with stale cache
class OptimizedDashboardRepository implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SmartApiClient smartApiClient;

  OptimizedDashboardRepository({
    DashboardRemoteDataSource? remoteDataSource,
    DashboardLocalDataSource? localDataSource,
    NetworkInfo? networkInfo,
    SmartApiClient? smartApiClient,
  })  : remoteDataSource = remoteDataSource ?? di.sl(),
        localDataSource = localDataSource ?? di.sl(),
        networkInfo = networkInfo ?? di.sl(),
        smartApiClient = smartApiClient ?? di.sl();

  @override
  Future<Result<DashboardEntity>> getDashboard() async {
    // Step 1: Try cache first (instant)
    final cached = CacheManager.get<Map<String, dynamic>>(
      CacheKeys.dashboard,
      ttl: CacheTTL.dashboard,
    );
    
    if (cached != null) {
      try {
        final dashboard = DashboardModel.fromJson(cached);
        print('✅ Dashboard cache hit');
        return Success(dashboard);
      } catch (e) {
        print('⚠️ Cache deserialization error: $e');
        // Continue to fetch fresh data
      }
    }

    // Step 2: Check network
    if (!await networkInfo.isConnected) {
      // Offline: try stale cache
      final staleCache = CacheManager.get<Map<String, dynamic>>(CacheKeys.dashboard);
      if (staleCache != null) {
        try {
          final dashboard = DashboardModel.fromJson(staleCache);
          print('⚠️ Using stale cache (offline)');
          return Success(dashboard);
        } catch (e) {
          return const Error(NetworkFailure('No internet connection and no cached data'));
        }
      }
      return const Error(NetworkFailure('No internet connection'));
    }

    // Step 3: Fetch from API (with smart client)
    try {
      final tokenResult = await di.sl<GetStoredToken>()();
      String? token;
      if (tokenResult is Error<String?>) {
        return Error(AuthenticationFailure('Authentication required'));
      } else if (tokenResult is Success<String?>) {
        token = tokenResult.data;
      }
      
      if (token == null || token.isEmpty) {
        return const Error(AuthenticationFailure('No authentication token'));
      }

      // Use smart API client (deduplication, retry built-in)
      final response = await smartApiClient.get(
        '/counter/dashboard',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final dashboard = DashboardModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        
        // Cache the result
        await CacheManager.set(
          CacheKeys.dashboard,
          response['data'],
          ttl: CacheTTL.dashboard,
        );
        
        // Also cache in local data source (for compatibility)
        try {
          await localDataSource.cacheDashboard(dashboard);
        } catch (e) {
          // Cache error is not critical
          print('⚠️ Failed to cache in local data source: $e');
        }
        
        return Success(dashboard);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get dashboard');
      }
    } on AuthenticationException catch (e) {
      // Try stale cache on auth error
      final staleCache = CacheManager.get<Map<String, dynamic>>(CacheKeys.dashboard);
      if (staleCache != null) {
        try {
          final dashboard = DashboardModel.fromJson(staleCache);
          return Success(dashboard);
        } catch (_) {}
      }
      return Error(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      // Try stale cache on network error
      final staleCache = CacheManager.get<Map<String, dynamic>>(CacheKeys.dashboard);
      if (staleCache != null) {
        try {
          final dashboard = DashboardModel.fromJson(staleCache);
          print('⚠️ Using stale cache (network error)');
          return Success(dashboard);
        } catch (_) {}
      }
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      // Try stale cache on server error
      final staleCache = CacheManager.get<Map<String, dynamic>>(CacheKeys.dashboard);
      if (staleCache != null) {
        try {
          final dashboard = DashboardModel.fromJson(staleCache);
          print('⚠️ Using stale cache (server error)');
          return Success(dashboard);
        } catch (_) {}
      }
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
