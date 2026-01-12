import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationsRead {
  final NotificationRepository repository;

  MarkNotificationsRead(this.repository);

  Future<Result<int>> call({required List<String> notificationIds}) async {
    return await repository.markAsRead(notificationIds: notificationIds);
  }
}
