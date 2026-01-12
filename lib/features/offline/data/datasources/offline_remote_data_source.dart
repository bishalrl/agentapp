import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/offline_model.dart';

abstract class OfflineRemoteDataSource {
  Future<List<OfflineQueueItemModel>> getOfflineQueue(String token);
  Future<OfflineQueueItemModel> addToOfflineQueue({
    required Map<String, dynamic> bookingData,
    required String token,
  });
  Future<OfflineSyncResultModel> syncOfflineBookings(String token);
}

class OfflineRemoteDataSourceImpl implements OfflineRemoteDataSource {
  final ApiClient apiClient;

  OfflineRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<OfflineQueueItemModel>> getOfflineQueue(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.counterOfflineQueue,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final queue = response['data']['queue'] as List<dynamic>;
        return queue
            .map((q) => OfflineQueueItemModel.fromJson(q as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to get offline queue');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get offline queue: ${e.toString()}');
    }
  }

  @override
  Future<OfflineQueueItemModel> addToOfflineQueue({
    required Map<String, dynamic> bookingData,
    required String token,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.counterOfflineQueue,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {'bookingData': bookingData},
      );

      if (response['success'] == true && response['data'] != null) {
        return OfflineQueueItemModel.fromJson(
            response['data']['queueItem'] ?? response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to add to offline queue');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to add to offline queue: ${e.toString()}');
    }
  }

  @override
  Future<OfflineSyncResultModel> syncOfflineBookings(String token) async {
    try {
      final response = await apiClient.post(
        ApiConstants.counterOfflineSync,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return OfflineSyncResultModel.fromJson(response['data']);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to sync offline bookings');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sync offline bookings: ${e.toString()}');
    }
  }
}
