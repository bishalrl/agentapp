import 'package:agentapp/core/errors/failures.dart';
import 'package:agentapp/features/counter_request/domain/entities/counter_request_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../bloc/counter_request_bloc.dart';
import '../bloc/events/counter_request_event.dart';
import '../bloc/states/counter_request_state.dart';

class CounterRequestsListPage extends StatelessWidget {
  const CounterRequestsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<CounterRequestBloc>()..add(const GetCounterRequestsEvent()),
      child: BackButtonHandler(
        enableDoubleBackToExit: false,
        child: Scaffold(
        appBar: AppAppBar(
          title: 'My Requests',
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<CounterRequestBloc>().add(const GetCounterRequestsEvent());
              },
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.push('/counter/request-bus-access');
              },
              tooltip: 'Request Bus Access',
            ),
          ],
        ),
        body: BlocConsumer<CounterRequestBloc, CounterRequestState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              String displayMessage;
              String? errorType;
              
              if (state.errorFailure != null) {
                if (state.errorFailure is NetworkFailure) {
                  displayMessage = 'Network issue. Please check your internet connection and try again.';
                  errorType = 'Network Error';
                } else if (state.errorFailure is AuthenticationFailure) {
                  final authFailure = state.errorFailure as AuthenticationFailure;
                  // Check if it's a credential mismatch error
                  final message = authFailure.message.toLowerCase();
                  if (message.contains('password') || 
                      message.contains('email') || 
                      message.contains('credential') ||
                      message.contains('invalid') ||
                      message.contains('incorrect') ||
                      message.contains('wrong')) {
                    displayMessage = 'Credentials did not match. Please check your email and password.';
                    errorType = 'Authentication Error';
                  } else {
                    displayMessage = authFailure.message;
                    errorType = 'Authentication Error';
                  }
                } else {
                  displayMessage = state.errorMessage!;
                  errorType = 'Error';
                }
              } else {
                // Fallback: check error message content if failure type is not available
                final message = state.errorMessage!.toLowerCase();
                if (message.contains('network') || 
                    message.contains('connection') ||
                    message.contains('timeout') ||
                    message.contains('internet')) {
                  displayMessage = 'Network issue. Please check your internet connection and try again.';
                  errorType = 'Network Error';
                } else if (message.contains('password') || 
                    message.contains('email') || 
                    message.contains('credential') ||
                    message.contains('invalid') ||
                    message.contains('incorrect') ||
                    message.contains('wrong')) {
                  displayMessage = 'Credentials did not match. Please check your email and password.';
                  errorType = 'Authentication Error';
                } else {
                  displayMessage = state.errorMessage!;
                  errorType = 'Error';
                }
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: displayMessage,
                  errorSource: 'Counter Requests',
                  errorType: errorType,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.requests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.requests.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.inbox_outlined,
                title: 'No Requests Yet',
                description: 'Request access to owner buses to start booking.',
                actionLabel: 'Request Bus Access',
                onAction: () => context.push('/counter/request-bus-access'),
              );
            }

            // Group requests by status
            final pendingRequests = state.requests.where((r) => r.status == 'PENDING').toList();
            final approvedRequests = state.requests.where((r) => r.status == 'APPROVED').toList();
            final rejectedRequests = state.requests.where((r) => r.status == 'REJECTED').toList();
            final expiredRequests = state.requests.where((r) => r.status == 'EXPIRED').toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CounterRequestBloc>().add(const GetCounterRequestsEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pending Requests
                    if (pendingRequests.isNotEmpty) ...[
                      _RequestSectionHeader(
                        title: 'Pending Requests',
                        count: pendingRequests.length,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      ...pendingRequests.map((request) => Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: _RequestCard(request: request),
                          )),
                      const SizedBox(height: AppTheme.spacingL),
                    ],

                    // Approved Requests
                    if (approvedRequests.isNotEmpty) ...[
                      _RequestSectionHeader(
                        title: 'Approved Requests',
                        count: approvedRequests.length,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      ...approvedRequests.map((request) => Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: _RequestCard(request: request),
                          )),
                      const SizedBox(height: AppTheme.spacingL),
                    ],

                    // Rejected Requests
                    if (rejectedRequests.isNotEmpty) ...[
                      _RequestSectionHeader(
                        title: 'Rejected Requests',
                        count: rejectedRequests.length,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      ...rejectedRequests.map((request) => Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: _RequestCard(request: request),
                          )),
                      const SizedBox(height: AppTheme.spacingL),
                    ],

                    // Expired Requests
                    if (expiredRequests.isNotEmpty) ...[
                      _RequestSectionHeader(
                        title: 'Expired Requests',
                        count: expiredRequests.length,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      ...expiredRequests.map((request) => Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: _RequestCard(request: request),
                          )),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'counter_requests_fab', // Unique tag to avoid Hero widget conflicts
          onPressed: () {
            context.push('/counter/request-bus-access');
          },
          icon: const Icon(Icons.add),
          label: const Text('New Request'),
        ),
      ),
        ),
      
    );
  }
}

class _RequestSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _RequestSectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  Color _getTextColor() {
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Text(
          '$title ($count)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final CounterRequestEntity request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final bus = request.bus;
    final statusColor = _getStatusColor(request.status);
    
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(request.status),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      bus.vehicleNumber,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppTheme.spacingL),
          
          // Route Info
          Row(
            children: [
              Icon(Icons.route, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                '${bus.from} → ${bus.to}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXS),
          
          // Date & Time
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                DateFormat('MMM dd, yyyy').format(bus.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                bus.time,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          
          // Requested Seats
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.statusInfo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.event_seat, size: 16, color: AppTheme.statusInfo),
                const SizedBox(width: AppTheme.spacingXS),
                Expanded(
                  child: Text(
                    'Requested: ${request.requestedSeats.join(', ')}',
                    style: TextStyle(
                      color: AppTheme.statusInfo,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Approved Seats (if approved)
          if (request.status == 'APPROVED' && request.approvedSeats != null && request.approvedSeats!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
                  const SizedBox(width: AppTheme.spacingXS),
                  Expanded(
                    child: Text(
                      'Approved: ${request.approvedSeats!.map((s) => s.toString()).join(', ')}',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Message
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.message, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: AppTheme.spacingXS),
                  Expanded(
                    child: Text(
                      request.message!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Dates
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(request.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          if (request.expiresAt != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer_off, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  'Expires: ${DateFormat('MMM dd, yyyy HH:mm').format(request.expiresAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppTheme.warningColor;
      case 'APPROVED':
        return AppTheme.successColor;
      case 'REJECTED':
        return AppTheme.errorColor;
      case 'EXPIRED':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.pending;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      case 'EXPIRED':
        return Icons.timer_off;
      default:
        return Icons.help_outline;
    }
  }
}
