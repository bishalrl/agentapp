import 'dart:io';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_data_source.dart';
import '../datasources/driver_local_data_source.dart';
import '../models/driver_model.dart';
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';

/// Implementation of [DriverRepository] that handles driver-related data operations.
/// 
/// This repository acts as a bridge between the domain layer and the data layer,
/// providing a clean abstraction for driver-related operations including:
/// - Driver authentication (OTP verification, login, registration)
/// - Driver profile management (get, update)
/// - Bus assignment operations (get assigned buses, mark as reached)
/// - Request management (get pending requests, accept/reject requests)
/// - Location sharing and tracking
/// 
/// The repository handles:
/// - Token management and authentication
/// - Error handling and exception mapping to failures
/// - Session management for authentication errors
/// - Data transformation between models and entities
/// 
/// All methods return [Result<T>] which can be either [Success<T>] or [Error<T>],
/// allowing the domain layer to handle success and failure cases cleanly.
class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remoteDataSource;
  final DriverLocalDataSource localDataSource;
  final GetStoredToken getStoredToken;
  
  DriverRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.getStoredToken,
  });
  
  @override
  Future<Result<Map<String, dynamic>>> verifyOtp(String phoneNumber, String otp) async {
    try {
      print('📦 DriverRepositoryImpl.verifyOtp: Starting');
      final data = await remoteDataSource.verifyOtp(phoneNumber, otp);
      print('   ✅ OTP verified successfully');
      return Success(data);
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<Map<String, dynamic>>> register({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String licenseNumber,
    File? licensePhoto,
    File? driverPhoto,
    bool? hasOTP,
    String? otp,
  }) async {
    try {
      print('📦 DriverRepositoryImpl.register: Starting (Independent Registration)');
      print('   Name: $name, PhoneNumber: $phoneNumber, Email: $email');
      print('   LicenseNumber: $licenseNumber');
      print('   HasOTP: $hasOTP, OTP: ${otp != null ? "***" : null}');
      final data = await remoteDataSource.register(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        licenseNumber: licenseNumber,
        licensePhoto: licensePhoto,
        driverPhoto: driverPhoto,
        hasOTP: hasOTP,
        otp: otp,
      );
      print('   ✅ Driver registered successfully (independent)');
      return Success(data);
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> registerWithInvitation({
    required String invitationCode,
    required String email,
    required String phoneNumber,
    required String password,
    required String name,
    required String licenseNumber,
    File? licensePhoto,
    File? driverPhoto,
  }) async {
    try {
      print('📦 DriverRepositoryImpl.registerWithInvitation: Starting');
      final data = await remoteDataSource.registerWithInvitation(
        invitationCode: invitationCode,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        name: name,
        licenseNumber: licenseNumber,
        licensePhoto: licensePhoto,
        driverPhoto: driverPhoto,
      );
      print('   ✅ Driver registered successfully');
      return Success(data);
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<Map<String, dynamic>>> login({
    String? email,
    String? phoneNumber,
    required String password,
    bool? hasOTP,
    String? otp,
  }) async {
    try {
      print('📦 DriverRepositoryImpl.login: Starting');
      print('   HasOTP: $hasOTP, OTP: ${otp != null ? "***" : null}');
      final data = await remoteDataSource.login(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        hasOTP: hasOTP,
        otp: otp,
      );
      print('   ✅ Driver login successful');
      return Success(data);
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<Map<String, dynamic>>> getDriverDashboard() async {
    // Try to get cached dashboard first
    Map<String, dynamic>? cachedDashboard;
    try {
      cachedDashboard = await localDataSource.getCachedDriverDashboard();
    } catch (e) {
      // Cache error is not critical
    }

    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      print('📦 DriverRepositoryImpl.getDriverDashboard: Starting');
      final data = await remoteDataSource.getDriverDashboard(token);
      print('   ✅ Driver dashboard retrieved successfully');
      
      // Cache the dashboard
      try {
        await localDataSource.cacheDriverDashboard(data);
      } catch (e) {
        // Cache error is not critical
      }
      
      return Success(data);
    } on AuthenticationException catch (e) {
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      if (cachedDashboard != null) {
        return Success(cachedDashboard);
      }
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<DriverEntity>> getDriverProfile() async {
    // Try to get cached profile first
    DriverEntity? cachedProfile;
    try {
      cachedProfile = await localDataSource.getCachedDriverProfile();
    } catch (e) {
      // Cache error is not critical
    }

    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      print('📦 DriverRepositoryImpl.getDriverProfile: Starting');
      // Get full profile data including inviter
      final profileData = await remoteDataSource.getDriverProfileWithInviter(token);
      final driver = DriverModel.fromJson(profileData);
      
      // Cache the profile
      try {
        await localDataSource.cacheDriverProfile(driver);
      } catch (e) {
        // Cache error is not critical
      }
      
      print('   ✅ Driver profile retrieved successfully');
      if (profileData['inviter'] != null) {
        print('   ✅ Inviter information found in profile response');
      }
      return Success(driver);
    } on AuthenticationException catch (e) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on NetworkException catch (e) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  // Helper method to get full profile data including inviter
  Future<Result<Map<String, dynamic>>> getDriverProfileWithInviter() async {
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
      print('📦 DriverRepositoryImpl.getDriverProfileWithInviter: Starting');
      final profileData = await remoteDataSource.getDriverProfileWithInviter(token);
      print('   ✅ Full profile data retrieved successfully');
      return Success(profileData);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<DriverEntity>> updateDriverProfile({
    String? name,
    String? email,
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
      print('📦 DriverRepositoryImpl.updateDriverProfile: Starting');
      print('   Name: $name, Email: $email');
      final driver = await remoteDataSource.updateDriverProfile(
        token: token,
        name: name,
        email: email,
      );
      print('   ✅ Driver profile updated successfully');
      return Success(driver);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<BusEntity>>> getAssignedBuses() async {
    // Try to get cached assigned buses first
    List<BusEntity> cachedBuses = [];
    try {
      cachedBuses = await localDataSource.getCachedAssignedBuses();
    } catch (e) {
      // Cache error is not critical
    }

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
    
    try {
      final buses = await remoteDataSource.getAssignedBuses(token);
      
      // Cache the assigned buses
      try {
        await localDataSource.cacheAssignedBuses(buses);
      } catch (e) {
        // Cache error is not critical
      }
      
      return Success(buses);
    } on AuthenticationException catch (e) {
      if (cachedBuses.isNotEmpty) {
        return Success(cachedBuses);
      }
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
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
  }
  
  @override
  Future<Result<void>> startLocationSharing(String busId) async {
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
      await remoteDataSource.startLocationSharing(token, busId);
      return const Success(null);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> stopLocationSharing() async {
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
      await remoteDataSource.stopLocationSharing(token);
      return const Success(null);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
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
      await remoteDataSource.updateLocation(
        token,
        busId: busId,
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        heading: heading,
        accuracy: accuracy,
      );
      return const Success(null);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<TripStatusEntity>> getTripStatus(String busId) async {
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
      final data = await remoteDataSource.getTripStatus(token, busId);
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
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> markBusAsReached(String busId) async {
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
      print('📦 DriverRepositoryImpl.markBusAsReached: Starting');
      print('   BusId: $busId');
      await remoteDataSource.markBusAsReached(token, busId);
      print('   ✅ Bus marked as reached successfully');
      return const Success(null);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPendingRequests() async {
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
      print('📦 DriverRepositoryImpl.getPendingRequests: Starting');
      final data = await remoteDataSource.getPendingRequests(token);
      print('   ✅ Pending requests retrieved successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> acceptRequest(String requestId) async {
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
      print('📦 DriverRepositoryImpl.acceptRequest: Starting');
      print('   RequestId: $requestId');
      final data = await remoteDataSource.acceptRequest(token, requestId);
      print('   ✅ Request accepted successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> rejectRequest(String requestId) async {
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
      print('📦 DriverRepositoryImpl.rejectRequest: Starting');
      print('   RequestId: $requestId');
      final data = await remoteDataSource.rejectRequest(token, requestId);
      print('   ✅ Request rejected successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getBusDetails(String busId) async {
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
      print('📦 DriverRepositoryImpl.getBusDetails: Starting');
      print('   BusId: $busId');
      final data = await remoteDataSource.getBusDetails(token, busId);
      print('   ✅ Bus details retrieved successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      print('   ❌ AuthenticationException: ${e.message}');
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e) {
      print('   ❌ Unexpected error: ${e.toString()}');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> initiateRide(String busId) async {
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
      print('📦 DriverRepositoryImpl.initiateRide: Starting');
      print('   BusId: $busId');
      final data = await remoteDataSource.initiateRide(token, busId);
      print('   ✅ Ride initiated successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> updateDriverLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
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
      print('📦 DriverRepositoryImpl.updateDriverLocation: Starting');
      print('   BusId: $busId, Lat: $latitude, Lng: $longitude');
      final data = await remoteDataSource.updateDriverLocation(
        token,
        busId: busId,
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        heading: heading,
        accuracy: accuracy,
      );
      print('   ✅ Location updated successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> createDriverBooking({
    required String busId,
    required List<dynamic> seatNumbers,
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
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
      print('📦 DriverRepositoryImpl.createDriverBooking: Starting');
      print('   BusId: $busId, Seats: $seatNumbers, Passenger: $passengerName');
      final data = await remoteDataSource.createDriverBooking(
        token,
        busId: busId,
        seatNumbers: seatNumbers,
        passengerName: passengerName,
        contactNumber: contactNumber,
        passengerEmail: passengerEmail,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        luggage: luggage,
        bagCount: bagCount,
        paymentMethod: paymentMethod,
      );
      print('   ✅ Booking created successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getBusPassengers(String busId) async {
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
      print('📦 DriverRepositoryImpl.getBusPassengers: Starting');
      print('   BusId: $busId');
      final data = await remoteDataSource.getBusPassengers(token, busId);
      print('   ✅ Passengers retrieved successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> verifyTicket({
    required String qrCode,
    required String busId,
    int? seatNumber,
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
      print('📦 DriverRepositoryImpl.verifyTicket: Starting');
      print('   QRCode: $qrCode, BusId: $busId, SeatNumber: $seatNumber');
      final data = await remoteDataSource.verifyTicket(
        token,
        qrCode: qrCode,
        busId: busId,
        seatNumber: seatNumber,
      );
      print('   ✅ Ticket verification completed');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> requestPermission({
    required String permissionType,
    String? busId,
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
      print('📦 DriverRepositoryImpl.requestPermission: Starting');
      print('   PermissionType: $permissionType, BusId: $busId');
      final data = await remoteDataSource.requestPermission(
        token,
        permissionType: permissionType,
        busId: busId,
        message: message,
      );
      print('   ✅ Permission request sent successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPermissionRequests() async {
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
      print('📦 DriverRepositoryImpl.getPermissionRequests: Starting');
      final data = await remoteDataSource.getPermissionRequests(token);
      print('   ✅ Permission requests retrieved successfully');
      return Success(data);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

