import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    bool? read,
    String? type,
    int? page,
    int? limit,
    required String token,
  });
  Future<int> markAsRead({
    required List<String> notificationIds,
    required String token,
  });
  Future<int> markAllAsRead({required String token});
  Future<void> deleteNotification(String notificationId, String token);
  Future<int> deleteAllNotifications(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<NotificationModel>> getNotifications({
    bool? read,
    String? type,
    int? page,
    int? limit,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (read != null) queryParams['read'] = read;
      if (type != null) queryParams['type'] = type;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        ApiConstants.counterNotifications,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );

      if (response['success'] == true) {
        if (response['data'] == null) {
          return [];
        }
        final data = response['data'] as Map<String, dynamic>?;
        if (data == null) {
          return [];
        }
        final notifications = data['notifications'];
        if (notifications == null || notifications is! List || notifications.isEmpty) {
          return [];
        }
        return notifications
            .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to get notifications');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get notifications: ${e.toString()}');
    }
  }

  @override
  Future<int> markAsRead({
    required List<String> notificationIds,
    required String token,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.counterNotificationsMarkRead,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {'notificationIds': notificationIds},
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['updatedCount'] ?? 0;
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to mark as read');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to mark as read: ${e.toString()}');
    }
  }

  @override
  Future<int> markAllAsRead({required String token}) async {
    try {
      final response = await apiClient.post(
        ApiConstants.counterNotificationsMarkAllRead,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['updatedCount'] ?? 0;
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to mark all as read');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to mark all as read: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId, String token) async {
    try {
      final response = await apiClient.delete(
        '${ApiConstants.counterNotificationDelete}/$notificationId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] != true) {
        throw ServerException(
            response['message'] as String? ?? 'Failed to delete notification');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete notification: ${e.toString()}');
    }
  }

  @override
  Future<int> deleteAllNotifications(String token) async {
    try {
      final response = await apiClient.delete(
        ApiConstants.counterNotificationsDeleteAll,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['deletedCount'] ?? 0;
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to delete all notifications');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete all notifications: ${e.toString()}');
    }
  }
}
