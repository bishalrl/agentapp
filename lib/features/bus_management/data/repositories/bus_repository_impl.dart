import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/network_info.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/repositories/bus_repository.dart';
import '../datasources/bus_remote_data_source.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';

class BusRepositoryImpl implements BusRepository {
  final BusRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;
  final NetworkInfo networkInfo;

  BusRepositoryImpl({
    required this.remoteDataSource,
    required this.getStoredToken,
    required this.networkInfo,
  });

  @override
  Future<Result<BusEntity>> createBus({
    required String name,
    required String vehicleNumber,
    required String from,
    required String to,
    required DateTime date,
    required String time,
    String? arrival,
    required double price,
    required int totalSeats,
    String? busType,
    String? driverContact,
    double? commissionRate,
    List<int>? allowedSeats,
  }) async {
    print('📦 BusRepositoryImpl.createBus: Starting');
    
    if (await networkInfo.isConnected) {
      print('   ✅ Network connected');
      try {
        // Get token
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
        final bus = await remoteDataSource.createBus(
          name: name,
          vehicleNumber: vehicleNumber,
          from: from,
          to: to,
          date: date,
          time: time,
          arrival: arrival,
          price: price,
          totalSeats: totalSeats,
          busType: busType,
          driverContact: driverContact,
          commissionRate: commissionRate,
          allowedSeats: allowedSeats,
          token: token,
        );
        print('   ✅ Bus created successfully: ${bus.id}');
        return Success(bus);
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
  Future<Result<BusEntity>> updateBus({
    required String busId,
    String? name,
    String? vehicleNumber,
    String? from,
    String? to,
    DateTime? date,
    String? time,
    String? arrival,
    double? price,
    int? totalSeats,
    String? busType,
    String? driverContact,
    double? commissionRate,
    List<int>? allowedSeats,
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
        
        final bus = await remoteDataSource.updateBus(
          busId: busId,
          name: name,
          vehicleNumber: vehicleNumber,
          from: from,
          to: to,
          date: date,
          time: time,
          arrival: arrival,
          price: price,
          totalSeats: totalSeats,
          busType: busType,
          driverContact: driverContact,
          commissionRate: commissionRate,
          allowedSeats: allowedSeats,
          token: token,
        );
        return Success(bus);
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
  Future<Result<void>> deleteBus(String busId) async {
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
        
        await remoteDataSource.deleteBus(busId, token);
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
  Future<Result<List<BusEntity>>> getMyBuses({
    String? date,
    String? route,
    String? status,
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
        
        final buses = await remoteDataSource.getMyBuses(
          date: date,
          route: route,
          status: status,
          token: token,
        );
        return Success(buses);
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
  Future<Result<BusEntity>> activateBus(String busId) async {
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
        
        final bus = await remoteDataSource.activateBus(busId, token);
        return Success(bus);
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
  Future<Result<BusEntity>> deactivateBus(String busId) async {
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
        
        final bus = await remoteDataSource.deactivateBus(busId, token);
        return Success(bus);
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

