import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/network_info.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/route_remote_data_source.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';

class RouteRepositoryImpl implements RouteRepository {
  final RouteRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;
  final NetworkInfo networkInfo;

  RouteRepositoryImpl({
    required this.remoteDataSource,
    required this.getStoredToken,
    required this.networkInfo,
  });

  @override
  Future<Result<RouteEntity>> createRoute({
    required String from,
    required String to,
    double? distance,
    int? estimatedDuration,
    String? description,
  }) async {
    print('📦 RouteRepositoryImpl.createRoute: Starting');
    
    if (await networkInfo.isConnected) {
      print('   ✅ Network connected');
      try {
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
        
        print('   ✅ Token retrieved, calling remoteDataSource');
        final route = await remoteDataSource.createRoute(
          from: from,
          to: to,
          distance: distance,
          estimatedDuration: estimatedDuration,
          description: description,
          token: token,
        );
        print('   ✅ Route created successfully: ${route.id}');
        return Success(route);
      } on AuthenticationException catch (e) {
        if (!SessionManager().isLoggingOut) {
          SessionManager().handleAuthenticationError();
        }
        return Error(AuthenticationFailure('Session expired. Please login again.'));
      } on NetworkException catch (e) {
        return Error(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Error(ServerFailure(e.message));
      } catch (e, stackTrace) {
        print('   ❌ Unexpected error: $e');
        print('   StackTrace: $stackTrace');
        return Error(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Error(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Result<RouteEntity>> updateRoute({
    required String routeId,
    String? from,
    String? to,
    double? distance,
    int? estimatedDuration,
    String? description,
  }) async {
    if (await networkInfo.isConnected) {
      try {
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
        
        final route = await remoteDataSource.updateRoute(
          routeId: routeId,
          from: from,
          to: to,
          distance: distance,
          estimatedDuration: estimatedDuration,
          description: description,
          token: token,
        );
        return Success(route);
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
    } else {
      return const Error(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Result<void>> deleteRoute(String routeId) async {
    if (await networkInfo.isConnected) {
      try {
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
        
        await remoteDataSource.deleteRoute(routeId, token);
        return const Success(null);
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
    } else {
      return const Error(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Result<List<RouteEntity>>> getRoutes({
    String? search,
  }) async {
    if (await networkInfo.isConnected) {
      try {
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
        
        final routes = await remoteDataSource.getRoutes(
          search: search,
          token: token,
        );
        return Success(routes);
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
    } else {
      return const Error(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Result<RouteEntity>> getRouteById(String routeId) async {
    if (await networkInfo.isConnected) {
      try {
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
        
        final route = await remoteDataSource.getRouteById(routeId, token);
        return Success(route);
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
    } else {
      return const Error(NetworkFailure('No internet connection'));
    }
  }
}

