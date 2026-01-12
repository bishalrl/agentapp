import '../../../../core/utils/result.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Result<List<NotificationEntity>>> getNotifications({
    bool? read,
    String? type,
    int? page,
    int? limit,
  });
  Future<Result<int>> markAsRead({required List<String> notificationIds});
  Future<Result<int>> markAllAsRead();
  Future<Result<void>> deleteNotification(String notificationId);
  Future<Result<int>> deleteAllNotifications();
}
