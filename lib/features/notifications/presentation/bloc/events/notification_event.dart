abstract class NotificationEvent {}

class GetNotificationsEvent extends NotificationEvent {
  final bool? read;
  final String? type;
  final int? page;
  final int? limit;

  GetNotificationsEvent({this.read, this.type, this.page, this.limit});
}

class MarkAsReadEvent extends NotificationEvent {
  final List<String> notificationIds;

  MarkAsReadEvent(this.notificationIds);
}

class MarkAllAsReadEvent extends NotificationEvent {}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  DeleteNotificationEvent(this.notificationId);
}

class DeleteAllNotificationsEvent extends NotificationEvent {}
