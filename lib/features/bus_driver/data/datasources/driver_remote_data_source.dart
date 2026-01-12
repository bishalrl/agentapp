import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_model.dart';

abstract class DriverRemoteDataSource {
  Future<DriverModel> verifyOtp(String phoneNumber, String otp);
  Future<DriverModel> getDriverProfile(String token);
  Future<List<BusModel>> getAssignedBuses(String token);
  Future<void> startLocationSharing(String token, String busId);
  Future<void> stopLocationSharing(String token);
  Future<void> updateLocation(String token, {
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  });
  Future<Map<String, dynamic>> getTripStatus(String token, String busId);
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final ApiClient apiClient;
  
  DriverRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<DriverModel> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await apiClient.post(
        ApiConstants.driverVerifyOtp,
        body: {
          'phoneNumber': phoneNumber,
          'otp': otp,
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        return DriverModel.fromJson(response['data']['driver'] as Map<String, dynamic>);
      } else {
        throw ServerException(response['message'] as String? ?? 'OTP verification failed');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }
  
  @override
  Future<DriverModel> getDriverProfile(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.driverProfile,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        return DriverModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get profile');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get driver profile: ${e.toString()}');
    }
  }
  
  @override
  Future<List<BusModel>> getAssignedBuses(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.driverAssignedBuses,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        final buses = response['data'] as List<dynamic>;
        return buses.map((bus) => BusModel.fromJson(bus as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get buses');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get assigned buses: ${e.toString()}');
    }
  }
  
  @override
  Future<void> startLocationSharing(String token, String busId) async {
    try {
      final response = await apiClient.post(
        ApiConstants.driverLocationStart,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {'busId': busId},
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to start location sharing');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to start location sharing: ${e.toString()}');
    }
  }
  
  @override
  Future<void> stopLocationSharing(String token) async {
    try {
      final response = await apiClient.post(
        ApiConstants.driverLocationStop,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to stop location sharing');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to stop location sharing: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateLocation(String token, {
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    try {
      final body = <String, dynamic>{
        'busId': busId,
        'latitude': latitude,
        'longitude': longitude,
      };
      
      if (speed != null) body['speed'] = speed;
      if (heading != null) body['heading'] = heading;
      if (accuracy != null) body['accuracy'] = accuracy;
      
      final response = await apiClient.post(
        ApiConstants.locationUpdate,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to update location');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update location: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getTripStatus(String token, String busId) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.driverTripStatus}?busId=$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get trip status');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get trip status: ${e.toString()}');
    }
  }
}

