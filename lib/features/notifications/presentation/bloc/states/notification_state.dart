import '../../../domain/entities/notification_entity.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  NotificationsLoaded(this.notifications, this.unreadCount);
}

class NotificationsMarkedAsRead extends NotificationState {
  final int updatedCount;

  NotificationsMarkedAsRead(this.updatedCount);
}

class AllNotificationsMarkedAsRead extends NotificationState {
  final int updatedCount;

  AllNotificationsMarkedAsRead(this.updatedCount);
}

class NotificationDeleted extends NotificationState {}

class AllNotificationsDeleted extends NotificationState {
  final int deletedCount;

  AllNotificationsDeleted(this.deletedCount);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}
