import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_data_source.dart';
import '../models/driver_model.dart';

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;
  final String? token; // In production, get from secure storage
  
  DriverRepositoryImpl(this.remoteDataSource, {this.token});
  
  @override
  Future<Result<DriverEntity>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final driver = await remoteDataSource.verifyOtp(phoneNumber, otp);
      return Success(driver);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<DriverEntity>> getDriverProfile() async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }
    
    try {
      final driver = await remoteDataSource.getDriverProfile(token!);
      return Success(driver);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<BusEntity>>> getAssignedBuses() async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }
    
    try {
      final buses = await remoteDataSource.getAssignedBuses(token!);
      return Success(buses);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> startLocationSharing(String busId) async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }
    
    try {
      await remoteDataSource.startLocationSharing(token!, busId);
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> stopLocationSharing() async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }
    
    try {
      await remoteDataSource.stopLocationSharing(token!);
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> updateLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }
    
    try {
      await remoteDataSource.updateLocation(
        token!,
        busId: busId,
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        heading: heading,
        accuracy: accuracy,
      );
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<TripStatusEntity>> getTripStatus(String busId) async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }
    
    try {
      final data = await remoteDataSource.getTripStatus(token!, busId);
      final bus = BusModel.fromJson(data['bus'] as Map<String, dynamic>);
      final tripStatus = TripStatusEntity(
        bus: bus,
        passengerCount: data['passengerCount'] as int,
        totalSeats: data['totalSeats'] as int,
        availableSeats: data['availableSeats'] as int,
        isLocationSharing: data['isLocationSharing'] as bool? ?? false,
      );
      return Success(tripStatus);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

