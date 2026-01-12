import '../../../../core/utils/result.dart';
import '../repositories/notification_repository.dart';

class MarkAllRead {
  final NotificationRepository repository;

  MarkAllRead(this.repository);

  Future<Result<int>> call() async {
    return await repository.markAllAsRead();
  }
}
