import '../../../../core/utils/result.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  Future<Result<List<NotificationEntity>>> call({
    bool? read,
    String? type,
    int? page,
    int? limit,
  }) async {
    return await repository.getNotifications(
      read: read,
      type: type,
      page: page,
      limit: limit,
    );
  }
}
