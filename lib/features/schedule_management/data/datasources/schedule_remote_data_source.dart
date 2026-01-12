import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<ScheduleModel> createSchedule({
    required String routeId,
    String? busId,
    required String departureTime,
    required String arrivalTime,
    required List<String> daysOfWeek,
    bool? isActive,
    required String token,
  });
  Future<List<ScheduleModel>> getSchedules({
    String? routeId,
    String? busId,
    bool? isActive,
    required String token,
  });
  Future<ScheduleModel> getScheduleById(String scheduleId, String token);
  Future<ScheduleModel> updateSchedule({
    required String scheduleId,
    String? departureTime,
    String? arrivalTime,
    List<String>? daysOfWeek,
    bool? isActive,
    required String token,
  });
  Future<void> deleteSchedule(String scheduleId, String token);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final ApiClient apiClient;

  ScheduleRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ScheduleModel> createSchedule({
    required String routeId,
    String? busId,
    required String departureTime,
    required String arrivalTime,
    required List<String> daysOfWeek,
    bool? isActive,
    required String token,
  }) async {
    try {
      final body = <String, dynamic>{
        'routeId': routeId,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'daysOfWeek': daysOfWeek,
      };
      if (busId != null) body['busId'] = busId;
      if (isActive != null) body['isActive'] = isActive;

      final response = await apiClient.post(
        ApiConstants.counterScheduleCreate,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );

      if (response['success'] == true && response['data'] != null) {
        return ScheduleModel.fromJson(
            response['data']['schedule'] ?? response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to create schedule');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to create schedule: ${e.toString()}');
    }
  }

  @override
  Future<List<ScheduleModel>> getSchedules({
    String? routeId,
    String? busId,
    bool? isActive,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (routeId != null) queryParams['routeId'] = routeId;
      if (busId != null) queryParams['busId'] = busId;
      if (isActive != null) queryParams['isActive'] = isActive;

      final response = await apiClient.get(
        ApiConstants.counterSchedules,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final schedules = response['data']['schedules'] as List<dynamic>;
        return schedules
            .map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to get schedules');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get schedules: ${e.toString()}');
    }
  }

  @override
  Future<ScheduleModel> getScheduleById(String scheduleId, String token) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.counterScheduleDetails}/$scheduleId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return ScheduleModel.fromJson(
            response['data']['schedule'] ?? response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to get schedule');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get schedule: ${e.toString()}');
    }
  }

  @override
  Future<ScheduleModel> updateSchedule({
    required String scheduleId,
    String? departureTime,
    String? arrivalTime,
    List<String>? daysOfWeek,
    bool? isActive,
    required String token,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (departureTime != null) body['departureTime'] = departureTime;
      if (arrivalTime != null) body['arrivalTime'] = arrivalTime;
      if (daysOfWeek != null) body['daysOfWeek'] = daysOfWeek;
      if (isActive != null) body['isActive'] = isActive;

      final response = await apiClient.put(
        '${ApiConstants.counterScheduleUpdate}/$scheduleId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );

      if (response['success'] == true && response['data'] != null) {
        return ScheduleModel.fromJson(
            response['data']['schedule'] ?? response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to update schedule');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update schedule: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId, String token) async {
    try {
      final response = await apiClient.delete(
        '${ApiConstants.counterScheduleDelete}/$scheduleId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] != true) {
        throw ServerException(
            response['message'] as String? ?? 'Failed to delete schedule');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete schedule: ${e.toString()}');
    }
  }
}
