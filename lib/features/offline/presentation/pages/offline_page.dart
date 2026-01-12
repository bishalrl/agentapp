import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/offline_bloc.dart';
import '../bloc/events/offline_event.dart';
import '../bloc/states/offline_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<OfflineBloc>()..add(GetOfflineQueueEvent()),
      child: const _OfflineView(),
    );
  }
}

class _OfflineView extends StatelessWidget {
  const _OfflineView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Queue'),
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
          BlocBuilder<OfflineBloc, OfflineState>(
            builder: (context, state) {
              if (state is OfflineQueueLoaded && state.totalPending > 0) {
                return IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Sync offline bookings',
                  onPressed: () {
                    context.read<OfflineBloc>().add(SyncOfflineBookingsEvent());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<OfflineBloc, OfflineState>(
        listener: (context, state) {
          if (state is OfflineError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Offline',
              ),
            );
          } else if (state is AddedToOfflineQueue || state is OfflineBookingsSynced) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Operation successful'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<OfflineBloc>().add(GetOfflineQueueEvent());
          }
        },
        builder: (context, state) {
          if (state is OfflineLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OfflineError) {
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
                      context.read<OfflineBloc>().add(GetOfflineQueueEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is OfflineQueueLoaded) {
            if (state.queue.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_done, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No offline bookings',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OfflineBloc>().add(GetOfflineQueueEvent());
              },
              child: Column(
                children: [
                  if (state.totalPending > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.orange.withOpacity(0.1),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            '${state.totalPending} pending booking(s) to sync',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.queue.length,
                      itemBuilder: (context, index) {
                        final item = state.queue[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(item.status)
                                  .withOpacity(0.1),
                              child: Icon(
                                _getStatusIcon(item.status),
                                color: _getStatusColor(item.status),
                              ),
                            ),
                            title: Text(
                              'Booking Data',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${item.status}'),
                                Text(
                                  DateFormat('MMM dd, yyyy • HH:mm')
                                      .format(item.createdAt),
                                ),
                                if (item.errorMessage != null)
                                  Text(
                                    'Error: ${item.errorMessage}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                item.status.toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: _getStatusColor(item.status)
                                  .withOpacity(0.2),
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'synced':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.pending;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'synced':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
