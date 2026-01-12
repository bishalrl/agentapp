import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/events/notification_event.dart';
import '../bloc/states/notification_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
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
              const SnackBar(
                content: Text('Operation successful'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<NotificationBloc>().add(GetNotificationsEvent());
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(GetNotificationsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
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
        return Colors.blue;
      case 'cancellation':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
