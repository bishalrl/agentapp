import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/driver_model.dart';

abstract class DriverManagementRemoteDataSource {
  Future<DriverModel> inviteDriver({
    required String name,
    required String phoneNumber,
    String? email,
    required String licenseNumber,
    required DateTime licenseExpiry,
    String? address,
    String? busId,
    required String token,
  });
  Future<List<DriverModel>> getDrivers({
    String? status,
    String? busId,
    required String token,
  });
  Future<DriverModel> getDriverById(String driverId, String token);
  Future<DriverModel> assignDriverToBus({
    required String driverId,
    required String busId,
    required String token,
  });
  Future<DriverModel> updateDriver({
    required String driverId,
    String? name,
    String? email,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? address,
    required String token,
  });
  Future<void> deleteDriver(String driverId, String token);
}

class DriverManagementRemoteDataSourceImpl
    implements DriverManagementRemoteDataSource {
  final ApiClient apiClient;

  DriverManagementRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DriverModel> inviteDriver({
    required String name,
    required String phoneNumber,
    String? email,
    required String licenseNumber,
    required DateTime licenseExpiry,
    String? address,
    String? busId,
    required String token,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'phoneNumber': phoneNumber,
        'licenseNumber': licenseNumber,
        'licenseExpiry': licenseExpiry.toIso8601String().split('T')[0],
      };
      if (email != null) body['email'] = email;
      if (address != null) body['address'] = address;
      if (busId != null) body['busId'] = busId;

      final response = await apiClient.post(
        ApiConstants.counterDriversInvite,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );

      if (response['success'] == true && response['data'] != null) {
        return DriverModel.fromJson(response['data']['driver'] ?? response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to invite driver');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to invite driver: ${e.toString()}');
    }
  }

  @override
  Future<List<DriverModel>> getDrivers({
    String? status,
    String? busId,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (busId != null) queryParams['busId'] = busId;

      final response = await apiClient.get(
        ApiConstants.counterDrivers,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final drivers = response['data']['drivers'] as List<dynamic>;
        return drivers
            .map((d) => DriverModel.fromJson(d as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to get drivers');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get drivers: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> getDriverById(String driverId, String token) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.counterDriverDetails}/$driverId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return DriverModel.fromJson(
            response['data']['driver'] ?? response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to get driver');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get driver: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> assignDriverToBus({
    required String driverId,
    required String busId,
    required String token,
  }) async {
    try {
      final response = await apiClient.put(
        '${ApiConstants.counterDriverAssignBus}/$driverId/assign-bus',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {'busId': busId},
      );

      if (response['success'] == true && response['data'] != null) {
        return DriverModel.fromJson(
            response['data']['driver'] ?? response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to assign driver');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to assign driver: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> updateDriver({
    required String driverId,
    String? name,
    String? email,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? address,
    required String token,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (licenseNumber != null) body['licenseNumber'] = licenseNumber;
      if (licenseExpiry != null)
        body['licenseExpiry'] = licenseExpiry.toIso8601String().split('T')[0];
      if (address != null) body['address'] = address;

      final response = await apiClient.put(
        '${ApiConstants.counterDriverUpdate}/$driverId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );

      if (response['success'] == true && response['data'] != null) {
        return DriverModel.fromJson(
            response['data']['driver'] ?? response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to update driver');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update driver: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDriver(String driverId, String token) async {
    try {
      final response = await apiClient.delete(
        '${ApiConstants.counterDriverDelete}/$driverId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] != true) {
        throw ServerException(
            response['message'] as String? ?? 'Failed to delete driver');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete driver: ${e.toString()}');
    }
  }
}
