import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/audit_log_bloc.dart';
import '../bloc/events/audit_log_event.dart';
import '../bloc/states/audit_log_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';

class AuditLogsPage extends StatelessWidget {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuditLogBloc>()..add(GetAuditLogsEvent()),
      child: const _AuditLogsView(),
    );
  }
}

class _AuditLogsView extends StatelessWidget {
  const _AuditLogsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<AuditLogBloc, AuditLogState>(
        listener: (context, state) {
          if (state is AuditLogError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Audit Logs',
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuditLogLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuditLogError) {
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
                      context.read<AuditLogBloc>().add(GetAuditLogsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AuditLogsLoaded) {
            if (state.logs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No audit logs found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AuditLogBloc>().add(GetAuditLogsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.logs.length,
                itemBuilder: (context, index) {
                  final log = state.logs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getActionColor(log.action)
                            .withOpacity(0.1),
                        child: Icon(
                          _getActionIcon(log.action),
                          color: _getActionColor(log.action),
                        ),
                      ),
                      title: Text(
                        log.action.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy • HH:mm')
                            .format(log.createdAt),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (log.busId != null)
                                _DetailRow(label: 'Bus ID', value: log.busId!),
                              if (log.bookingId != null)
                                _DetailRow(
                                    label: 'Booking ID', value: log.bookingId!),
                              if (log.ipAddress != null)
                                _DetailRow(
                                    label: 'IP Address', value: log.ipAddress!),
                              const SizedBox(height: 8),
                              const Text(
                                'Details:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.details.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final actionController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Audit Logs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: actionController,
              decoration: const InputDecoration(
                labelText: 'Action (Optional)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: startDateController,
              decoration: const InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endDateController,
              decoration: const InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuditLogBloc>().add(
                    GetAuditLogsEvent(
                      action: actionController.text.isEmpty
                          ? null
                          : actionController.text,
                      startDate: startDateController.text.isEmpty
                          ? null
                          : startDateController.text,
                      endDate: endDateController.text.isEmpty
                          ? null
                          : endDateController.text,
                    ),
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String action) {
    if (action.contains('booking')) return Icons.confirmation_number;
    if (action.contains('bus')) return Icons.directions_bus;
    if (action.contains('driver')) return Icons.person;
    return Icons.history;
  }

  Color _getActionColor(String action) {
    if (action.contains('created')) return Colors.green;
    if (action.contains('updated')) return Colors.blue;
    if (action.contains('deleted')) return Colors.red;
    return Colors.grey;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
