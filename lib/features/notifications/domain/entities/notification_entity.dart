class NotificationEntity {
  final String id;
  final String type; // booking, cancellation, system
  final String message;
  final bool read;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.type,
    required this.message,
    required this.read,
    required this.createdAt,
  });
}
