import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/events/notification_event.dart';
import '../bloc/states/notification_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<NotificationBloc>()..add(GetNotificationsEvent()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      enableDoubleBackToExit: false,
      child: Scaffold(
      appBar: AppAppBar(
        title: 'Notifications',
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    context.read<NotificationBloc>().add(MarkAllAsReadEvent());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('Delete All'),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete_all') {
                context.read<NotificationBloc>().add(DeleteAllNotificationsEvent());
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Notifications',
              ),
            );
          } else if (state is NotificationsMarkedAsRead ||
              state is AllNotificationsMarkedAsRead ||
              state is NotificationDeleted ||
              state is AllNotificationsDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SuccessSnackBar(message: 'Operation successful'),
            );
            context.read<NotificationBloc>().add(GetNotificationsEvent());
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const SkeletonList(itemCount: 6, itemHeight: 80);
          }

          if (state is NotificationError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<NotificationBloc>().add(GetNotificationsEvent()),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.notifications_none,
                title: 'No notifications',
                description: 'You are all caught up.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(GetNotificationsEvent());
              },
              child: Column(
                children: [
                  if (state.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${state.unreadCount} unread notification(s)',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: notification.read
                              ? null
                              : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getTypeColor(notification.type)
                                  .withOpacity(0.1),
                              child: Icon(
                                _getTypeIcon(notification.type),
                                color: _getTypeColor(notification.type),
                              ),
                            ),
                            title: Text(
                              notification.message,
                              style: TextStyle(
                                fontWeight: notification.read
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('MMM dd, yyyy • HH:mm')
                                  .format(notification.createdAt),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!notification.read)
                                  IconButton(
                                    icon: const Icon(Icons.mark_email_read),
                                    onPressed: () {
                                      context.read<NotificationBloc>().add(
                                            MarkAsReadEvent([notification.id]),
                                          );
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    context.read<NotificationBloc>().add(
                                          DeleteNotificationEvent(notification.id),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
        ),
      
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return Icons.confirmation_number;
      case 'cancellation':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return AppTheme.statusInfo;
      case 'cancellation':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}
