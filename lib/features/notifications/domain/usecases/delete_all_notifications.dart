import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';

class DeleteAllNotifications {
  final NotificationRepository repository;

  DeleteAllNotifications(this.repository);

  Future<Result<int>> call() async {
    return await repository.deleteAllNotifications();
  }
}
