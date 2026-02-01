import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/network_info.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/bus_entity.dart';
import '../../domain/repositories/bus_repository.dart';
import '../datasources/bus_remote_data_source.dart';
import '../datasources/bus_local_data_source.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';

class BusRepositoryImpl implements BusRepository {
  final BusRemoteDataSource remoteDataSource;
  final BusLocalDataSource localDataSource;
  final GetStoredToken getStoredToken;
  final NetworkInfo networkInfo;

  BusRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
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
    String? timeFormat, // '12h' or '24h' (default: '12h')
    String? arrivalFormat, // '12h' or '24h' (default: '12h')
    String? tripDirection, // 'going' or 'returning' (default: 'going')
    required double price,
    required int totalSeats,
    String? busType,
    String? driverContact,
    String? driverEmail, // Driver email for invitation system
    String? driverName, // Driver name (required if driverEmail provided)
    String? driverLicenseNumber, // Driver license number (required if driverEmail provided)
    String? driverId, // Existing driver ID
    double? commissionRate,
    List<int>? allowedSeats,
    List<String>? seatConfiguration, // Custom seat identifiers (Nepal standard: A/B only, e.g., ["A1", "A4", "B6"])
    List<String>? amenities, // Bus amenities (e.g., ["WiFi", "AC", "TV"])
    List<Map<String, String>>? boardingPoints, // Boarding points with location and time
    List<Map<String, String>>? droppingPoints, // Dropping points with location and time
    String? routeId, // Route ID reference
    String? scheduleId, // Schedule ID reference
    double? distance, // Distance in kilometers
    int? estimatedDuration, // Estimated duration in minutes
    // Recurring Schedule Fields
    bool? isRecurring, // Enable recurring schedule
    List<int>? recurringDays, // Days of week [0=Sun, 6=Sat]
    DateTime? recurringStartDate, // Recurring start date
    DateTime? recurringEndDate, // Recurring end date
    String? recurringFrequency, // 'daily' | 'weekly' | 'monthly'
    // Auto-Activation Fields
    bool? autoActivate, // Enable date-based auto activation
    DateTime? activeFromDate, // Auto-activation start date
    DateTime? activeToDate, // Auto-activation end date
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
          timeFormat: timeFormat,
          arrivalFormat: arrivalFormat,
          tripDirection: tripDirection,
          price: price,
          totalSeats: totalSeats,
          busType: busType,
          driverContact: driverContact,
          driverEmail: driverEmail,
          driverName: driverName,
          driverLicenseNumber: driverLicenseNumber,
          driverId: driverId,
          commissionRate: commissionRate,
          allowedSeats: allowedSeats,
          seatConfiguration: seatConfiguration,
          amenities: amenities,
          boardingPoints: boardingPoints,
          droppingPoints: droppingPoints,
          routeId: routeId,
          scheduleId: scheduleId,
          distance: distance,
          estimatedDuration: estimatedDuration,
          mainImage: null, // TODO: Add file picker support
          galleryImages: null, // TODO: Add file picker support
          driverPhoto: null, // TODO: Add file picker support
          driverLicensePhoto: null, // TODO: Add file picker support
          isRecurring: isRecurring,
          recurringDays: recurringDays,
          recurringStartDate: recurringStartDate,
          recurringEndDate: recurringEndDate,
          recurringFrequency: recurringFrequency,
          autoActivate: autoActivate,
          activeFromDate: activeFromDate,
          activeToDate: activeToDate,
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
    String? driverEmail, // Driver email for invitation system
    String? driverName, // Driver name (required if driverEmail provided)
    String? driverLicenseNumber, // Driver license number (required if driverEmail provided)
    String? driverId, // Existing driver ID
    double? commissionRate,
    List<int>? allowedSeats,
    List<String>? seatConfiguration, // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
    List<String>? amenities, // Bus amenities (e.g., ["WiFi", "AC", "TV"])
    List<Map<String, String>>? boardingPoints, // Boarding points with location and time
    List<Map<String, String>>? droppingPoints, // Dropping points with location and time
    String? routeId, // Route ID reference
    String? scheduleId, // Schedule ID reference
    double? distance, // Distance in kilometers
    int? estimatedDuration, // Estimated duration in minutes
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
          driverEmail: driverEmail,
          driverName: driverName,
          driverLicenseNumber: driverLicenseNumber,
          driverId: driverId,
          commissionRate: commissionRate,
          allowedSeats: allowedSeats,
          seatConfiguration: seatConfiguration,
          amenities: amenities,
          boardingPoints: boardingPoints,
          droppingPoints: droppingPoints,
          routeId: routeId,
          scheduleId: scheduleId,
          distance: distance,
          estimatedDuration: estimatedDuration,
          mainImage: null, // TODO: Add file picker support
          galleryImages: null, // TODO: Add file picker support
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
  Future<Result<List<BusEntity>>> getAssignedBuses({
    String? date,
    String? from,
    String? to,
  }) async {
    print('📦 BusRepositoryImpl.getAssignedBuses: Starting');
    
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
        
        final buses = await remoteDataSource.getAssignedBuses(
          date: date,
          from: from,
          to: to,
          token: token,
        );
        
        print('   ✅ Assigned buses retrieved successfully: ${buses.length} buses');
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
        print('   ❌ Unexpected error: $e');
        return Error(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Error(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Result<BusEntity>> searchBusByNumber({
    required String busNumber,
  }) async {
    print('📦 BusRepositoryImpl.searchBusByNumber: Starting');
    print('   BusNumber: $busNumber');
    
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
        
        final bus = await remoteDataSource.searchBusByNumber(
          busNumber: busNumber,
          token: token,
        );
        
        print('   ✅ Bus found: ${bus.name} (${bus.vehicleNumber})');
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
        print('   ❌ Unexpected error: $e');
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
    // Try to get cached buses first (only if no filters applied)
    List<BusEntity> cachedBuses = [];
    if (date == null && route == null && status == null) {
      try {
        cachedBuses = await localDataSource.getCachedBuses();
      } catch (e) {
        // Cache error is not critical
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final tokenResult = await getStoredToken();
        String? token;
        if (tokenResult is Error<String?>) {
          if (cachedBuses.isNotEmpty) {
            return Success(cachedBuses);
          }
          return Error(AuthenticationFailure('Authentication required. Please login again.'));
        } else if (tokenResult is Success<String?>) {
          token = tokenResult.data;
        }
        
        if (token == null || token.isEmpty) {
          if (cachedBuses.isNotEmpty) {
            return Success(cachedBuses);
          }
          return const Error(AuthenticationFailure('No authentication token. Please login again.'));
        }
        
        final buses = await remoteDataSource.getMyBuses(
          date: date,
          route: route,
          status: status,
          token: token,
        );
        
        // Cache buses only when fetching all (no filters)
        if (date == null && route == null && status == null) {
          try {
            await localDataSource.cacheBuses(buses);
          } catch (e) {
            // Cache error is not critical
          }
        }
        
        return Success(buses);
      } on AuthenticationException catch (e) {
        if (cachedBuses.isNotEmpty) {
          return Success(cachedBuses);
        }
        if (!SessionManager().isLoggingOut) {
          SessionManager().handleAuthenticationError();
        }
        return Error(AuthenticationFailure('Session expired. Please login again.'));
      } on NetworkException catch (e) {
        if (cachedBuses.isNotEmpty) {
          return Success(cachedBuses);
        }
        return Error(NetworkFailure(e.message));
      } on ServerException catch (e) {
        if (cachedBuses.isNotEmpty) {
          return Success(cachedBuses);
        }
        return Error(ServerFailure(e.message));
      } catch (e) {
        if (cachedBuses.isNotEmpty) {
          return Success(cachedBuses);
        }
        return Error(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      // Offline: return cached buses if available
      if (cachedBuses.isNotEmpty) {
        return Success(cachedBuses);
      }
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

