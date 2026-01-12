import 'package:agentapp/features/notifications/presentation/bloc/events/notification_event.dart';
import 'package:agentapp/features/notifications/presentation/bloc/states/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notifications_read.dart';
import '../../domain/usecases/mark_all_read.dart';
import '../../domain/usecases/delete_notification.dart';
import '../../domain/usecases/delete_all_notifications.dart';


class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final MarkNotificationsRead markAsRead;
  final MarkAllRead markAllAsRead;
  final DeleteNotification deleteNotification;
  final DeleteAllNotifications deleteAllNotifications;

  NotificationBloc({
    required this.getNotifications,
    required this.markAsRead,
    required this.markAllAsRead,
    required this.deleteNotification,
    required this.deleteAllNotifications,
  }) : super(NotificationInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<DeleteAllNotificationsEvent>(_onDeleteAllNotifications);
  }

  Future<void> _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await getNotifications(
      read: event.read,
      type: event.type,
      page: event.page,
      limit: event.limit,
    );
    if (result is Error<List<NotificationEntity>>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(NotificationError(errorMessage));
    } else if (result is Success<List<NotificationEntity>>) {
      final notifications = result.data;
      final unreadCount = notifications.where((n) => !n.read).length;
      emit(NotificationsLoaded(notifications, unreadCount));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await markAsRead(notificationIds: event.notificationIds);
    if (result is Error<int>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(NotificationError(errorMessage));
    } else if (result is Success<int>) {
      emit(NotificationsMarkedAsRead(result.data));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await markAllAsRead();
    if (result is Error<int>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(NotificationError(errorMessage));
    } else if (result is Success<int>) {
      emit(AllNotificationsMarkedAsRead(result.data));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await deleteNotification(event.notificationId);
    if (result is Error<void>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(NotificationError(errorMessage));
    } else if (result is Success<void>) {
      emit(NotificationDeleted());
    }
  }

  Future<void> _onDeleteAllNotifications(
    DeleteAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await deleteAllNotifications();
    if (result is Error<int>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(NotificationError(errorMessage));
    } else if (result is Success<int>) {
      emit(AllNotificationsDeleted(result.data));
    }
  }
}
