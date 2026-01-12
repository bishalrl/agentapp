import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';

class DeleteNotification {
  final NotificationRepository repository;

  DeleteNotification(this.repository);

  Future<Result<void>> call(String notificationId) async {
    return await repository.deleteNotification(notificationId);
  }
}
