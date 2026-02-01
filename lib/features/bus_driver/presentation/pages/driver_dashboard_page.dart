import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';

class DriverDashboardPage extends StatelessWidget {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<DriverBloc>();
        bloc.add(const GetDriverDashboardEvent());
        bloc.add(const GetPendingRequestsEvent());
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Driver Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                context.push('/driver/profile/edit');
              },
              tooltip: 'Edit Profile',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<DriverBloc>().add(const GetDriverDashboardEvent());
                context.read<DriverBloc>().add(const GetPendingRequestsEvent());
              },
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.go('/driver/login');
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: BlocConsumer<DriverBloc, DriverState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            // Listen for success actions (handled via state updates)
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.dashboardData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DriverBloc>().add(const GetDriverDashboardEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final dashboardData = state.dashboardData;
            if (dashboardData == null) {
              return const Center(
                child: Text('No dashboard data available'),
              );
            }

            final driver = dashboardData['driver'] as Map<String, dynamic>?;
            final buses = dashboardData['buses'] as List<dynamic>? ?? [];
            final totalBuses = dashboardData['totalBuses'] as int? ?? buses.length;
            final inviter = dashboardData['inviter'] as Map<String, dynamic>?; // Inviter information
            
            // Enhanced dashboard data (statistics, revenue, etc.)
            final statistics = dashboardData['statistics'] as Map<String, dynamic>?;
            final totalBookings = statistics?['totalBookings'] as int? ?? 0;
            final confirmedBookings = statistics?['confirmedBookings'] as int? ?? 0;
            final cancelledBookings = statistics?['cancelledBookings'] as int? ?? 0;
            final pendingBookings = statistics?['pendingBookings'] as int? ?? 0;
            final totalRevenue = statistics?['totalRevenue'] as num? ?? 0.0;
            
            // Check driver status for feature restrictions
            final driverStatus = driver?['status'] as String?;
            final isActive = driverStatus == 'ACTIVE';
            final isSuspended = driverStatus == 'SUSPENDED';
            final isInvited = driverStatus == 'INVITED';

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DriverBloc>().add(const GetDriverDashboardEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (driver != null) _DriverInfoCard(
                      driver: driver,
                      onEditProfile: () {
                        context.push('/driver/profile/edit');
                      },
                    ),
                    
                    // Inviter Information (if driver was invited)
                    if (inviter != null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      _InviterInfoCard(inviter: inviter),
                    ],
                    
                    // Dashboard Statistics (if available)
                    if (statistics != null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      _DashboardStatisticsCard(
                        totalBookings: totalBookings,
                        confirmedBookings: confirmedBookings,
                        cancelledBookings: cancelledBookings,
                        pendingBookings: pendingBookings,
                        totalRevenue: totalRevenue,
                      ),
                    ],
                    
                    // Status-based messages
                    if (isSuspended) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: AppTheme.spacingS),
                            Expanded(
                              child: Text(
                                'Your account is suspended. Please contact your counter for assistance.',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (isInvited) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: AppTheme.spacingS),
                            Expanded(
                              child: Text(
                                'Please complete your registration to access the dashboard.',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (!isActive) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange.shade700),
                            const SizedBox(width: AppTheme.spacingS),
                            Expanded(
                              child: Text(
                                'Your account is not active. Please contact your counter to be assigned to a bus.',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Pending Assignment Requests Section
                    if (state.pendingRequests != null) ...[
                      Builder(
                        builder: (context) {
                          final pendingRequestsData = state.pendingRequests!;
                          final requests = pendingRequestsData['requests'] as List<dynamic>? ?? [];
                          final requestCount = pendingRequestsData['count'] as int? ?? requests.length;
                          
                          if (requestCount > 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppTheme.spacingM),
                                Text(
                                  'Pending Bus Assignment Requests ($requestCount)',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacingS),
                                ...requests.map((request) => Padding(
                                      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                                      child: _PendingRequestCard(
                                        request: request as Map<String, dynamic>,
                                        onAccept: (requestId) {
                                          if (requestId.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Invalid request ID. Cannot accept request.'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          if (state.isLoading) {
                                            return; // Prevent multiple clicks while loading
                                          }
                                          print('📤 Accepting request: $requestId');
                                          context.read<DriverBloc>().add(AcceptRequestEvent(requestId: requestId));
                                        },
                                        onReject: (requestId) {
                                          context.read<DriverBloc>().add(RejectRequestEvent(requestId: requestId));
                                        },
                                      ),
                                    )),
                                const SizedBox(height: AppTheme.spacingL),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                    
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Assigned Buses ($totalBuses)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    if (buses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppTheme.spacingL),
                        child: Center(
                          child: Text('No buses assigned yet'),
                        ),
                      )
                    else
                      ...buses.map((bus) => Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: _BusCard(
                              bus: bus as Map<String, dynamic>,
                              isActive: isActive,
                              onMarkReached: (busId) {
                                context.read<DriverBloc>().add(MarkBusAsReachedEvent(busId: busId));
                              },
                              onViewDetails: (busId) {
                                context.read<DriverBloc>().add(GetBusDetailsEvent(busId: busId));
                                // Navigate to bus details page
                                context.push('/driver/bus/$busId');
                              },
                            ),
                          )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DriverInfoCard extends StatelessWidget {
  final Map<String, dynamic> driver;
  final VoidCallback? onEditProfile;

  const _DriverInfoCard({
    required this.driver,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 32, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['name'] as String? ?? 'Unknown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (driver['email'] != null)
                      Text(
                        driver['email'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    if (driver['status'] != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(driver['status'] as String).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          driver['status'] as String,
                          style: TextStyle(
                            color: _getStatusColor(driver['status'] as String),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onEditProfile != null)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEditProfile,
                  tooltip: 'Edit Profile',
                ),
            ],
          ),
          const Divider(height: AppTheme.spacingL),
          _InfoRow(
            icon: Icons.phone,
            label: 'Phone',
            value: driver['phoneNumber'] as String? ?? 'N/A',
          ),
          if (driver['licenseNumber'] != null)
            _InfoRow(
              icon: Icons.badge,
              label: 'License',
              value: driver['licenseNumber'] as String,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

   Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'REGISTERED':
        return Colors.blue;
      case 'INVITED':
        return Colors.orange;
      case 'INACTIVE':
        return Colors.grey;
      case 'SUSPENDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


class _BusCard extends StatelessWidget {
  final Map<String, dynamic> bus;
  final bool isActive;
  final Function(String)? onMarkReached;
  final Function(String)? onViewDetails;

  const _BusCard({
    required this.bus,
    this.isActive = false,
    this.onMarkReached,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final busName = bus['name'] as String? ?? 'Unknown Bus';
    final vehicleNumber = bus['vehicleNumber'] as String? ?? 'N/A';
    final route = bus['route'] as Map<String, dynamic>?;
    final routeDisplay = route?['display'] as String? ??
        '${bus['from'] as String? ?? ''} to ${bus['to'] as String? ?? ''}';
    final date = bus['date'] as String?;
    final time = bus['time'] as String?;
    final arrival = bus['arrival'] as String?;
    final totalSeats = bus['totalSeats'] as int? ?? 0;
    final filledSeats = bus['filledSeats'] as int? ?? 0;
    final availableSeats = bus['availableSeats'] as int? ?? 0;
    final seats = bus['seats'] as List<dynamic>? ?? [];
    final seatConfiguration = bus['seatConfiguration'] as List<dynamic>?;

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus Header
          Row(
            children: [
              const Icon(Icons.directions_bus, size: 32, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            busName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (onViewDetails != null)
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              final busId = bus['id'] as String? ?? bus['_id'] as String? ?? '';
                              if (busId.isNotEmpty) {
                                onViewDetails!(busId);
                              }
                            },
                            tooltip: 'View Details',
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),
                    Text(
                      vehicleNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppTheme.spacingL),
          
          // Route Info
          _InfoRow(
            icon: Icons.route,
            label: 'Route',
            value: routeDisplay,
          ),
          
          // Schedule Info
          if (date != null || time != null)
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: date ?? 'N/A',
            ),
          if (time != null || arrival != null)
            _InfoRow(
              icon: Icons.access_time,
              label: 'Time',
              value: arrival != null ? '$time → $arrival' : (time ?? 'N/A'),
            ),
          
          // Seat Statistics
          const Divider(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Total',
                  value: totalSeats.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: _StatBox(
                  label: 'Booked',
                  value: filledSeats.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: _StatBox(
                  label: 'Available',
                  value: availableSeats.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          // Seat Map
          if (seats.isNotEmpty) ...[
            const Divider(height: AppTheme.spacingL),
            Text(
              'Seat Map',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            _SeatMap(
              seats: seats,
              seatConfiguration: seatConfiguration,
            ),
          ],
          
          // Mark as Reached Button (if active)
          if (isActive && onMarkReached != null) ...[
            const Divider(height: AppTheme.spacingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final busId = bus['id'] as String? ?? bus['_id'] as String? ?? '';
                  if (busId.isNotEmpty) {
                    onMarkReached!(busId);
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark as Reached'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardStatisticsCard extends StatelessWidget {
  final int totalBookings;
  final int confirmedBookings;
  final int cancelledBookings;
  final int pendingBookings;
  final num totalRevenue;

  const _DashboardStatisticsCard({
    required this.totalBookings,
    required this.confirmedBookings,
    required this.cancelledBookings,
    required this.pendingBookings,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Dashboard Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Total Bookings',
                  value: totalBookings.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: _StatBox(
                  label: 'Confirmed',
                  value: confirmedBookings.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Cancelled',
                  value: cancelledBookings.toString(),
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: _StatBox(
                  label: 'Pending',
                  value: pendingBookings.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Revenue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Rs. ${totalRevenue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Function(String) onAccept;
  final Function(String) onReject;

  const _PendingRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // Extract request ID - API may return 'id' or '_id'
    final requestId = request['id'] as String? ?? 
                     request['_id'] as String? ?? '';
    final busId = request['busId'] as Map<String, dynamic>?;
    final vehicleNumber = busId?['vehicleNumber'] as String? ?? 'N/A';
    final from = busId?['from'] as String? ?? '';
    final to = busId?['to'] as String? ?? '';
    final requestedBy = request['requestedBy'] as Map<String, dynamic>?;
    final requesterName = requestedBy?['name'] as String? ?? 'Unknown';
    final requesterEmail = requestedBy?['email'] as String?;
    final requesterRole = requestedBy?['role'] as String?; // Owner or Counter
    final requesterPhone = requestedBy?['phoneNumber'] as String?;
    final status = request['status'] as String? ?? 'PENDING';
    final expiresAt = request['expiresAt'] as String?;
    final message = request['message'] as String?;

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Request Title and Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pending_actions,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus Assignment Request',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      vehicleNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Requester Information Section (Prominent)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Invited By',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                if (requesterName.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: AppTheme.spacingXS),
                      Expanded(
                        child: Text(
                          requesterName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (requesterRole != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: requesterRole.toUpperCase() == 'OWNER' 
                                ? Colors.purple.shade100 
                                : Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            requesterRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: requesterRole.toUpperCase() == 'OWNER' 
                                  ? Colors.purple.shade700 
                                  : Colors.teal.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (requesterEmail != null && requesterEmail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: AppTheme.spacingXS),
                      Expanded(
                        child: Text(
                          requesterEmail,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (requesterPhone != null && requesterPhone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: AppTheme.spacingXS),
                      Expanded(
                        child: Text(
                          requesterPhone,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Bus Route Information
          _InfoRow(
            icon: Icons.route,
            label: 'Route',
            value: '$from → $to',
          ),
          if (expiresAt != null) ...[
            _InfoRow(
              icon: Icons.access_time,
              label: 'Expires At',
              value: expiresAt,
            ),
          ],
          if (message != null && message.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.message, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onReject(requestId),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final blocState = context.watch<DriverBloc>().state;
                    return ElevatedButton.icon(
                      onPressed: (requestId.isEmpty || blocState.isLoading)
                          ? null 
                          : () {
                              if (requestId.isEmpty) {
                                print('⚠️ Cannot accept: requestId is empty');
                                return;
                              }
                              print('✅ Accepting request with ID: $requestId');
                              onAccept(requestId);
                            },
                      icon: blocState.isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check),
                      label: Text(blocState.isLoading ? 'Accepting...' : 'Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeatMap extends StatelessWidget {
  final List<dynamic> seats;
  final List<dynamic>? seatConfiguration;

  const _SeatMap({
    required this.seats,
    this.seatConfiguration,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacingXS,
      runSpacing: AppTheme.spacingXS,
      children: seats.map((seat) {
        final seatData = seat as Map<String, dynamic>;
        final seatNumber = seatData['seatNumber']?.toString() ?? 'N/A';
        final isBooked = seatData['isBooked'] as bool? ?? false;
        final passenger = seatData['passenger'] as Map<String, dynamic>?;

        return _SeatWidget(
          seatNumber: seatNumber,
          isBooked: isBooked,
          passenger: passenger,
        );
      }).toList(),
    );
  }
}

class _SeatWidget extends StatelessWidget {
  final String seatNumber;
  final bool isBooked;
  final Map<String, dynamic>? passenger;

  const _SeatWidget({
    required this.seatNumber,
    required this.isBooked,
    this.passenger,
  });

  @override
  Widget build(BuildContext context) {
    // Show full passenger information - no masking
    final passengerName = passenger?['name'] as String? ?? 'Unknown';
    final email = passenger?['email'] as String? ?? '';
    final phone = passenger?['contactNumber'] as String? ?? '';
    
    final tooltipMessage = isBooked && passenger != null
        ? '$passengerName\n$phone\n$email'
        : 'Available';
    
    return Tooltip(
      message: tooltipMessage,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isBooked ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
          border: Border.all(
            color: isBooked ? Colors.orange : Colors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                seatNumber,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isBooked ? Colors.orange[900] : Colors.green[900],
                ),
              ),
              if (isBooked)
                const Icon(
                  Icons.person,
                  size: 12,
                  color: Colors.orange,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviterInfoCard extends StatelessWidget {
  final Map<String, dynamic> inviter;

  const _InviterInfoCard({
    required this.inviter,
  });

  @override
  Widget build(BuildContext context) {
    final inviterType = inviter['type'] as String? ?? 'Unknown';
    
    // Fields based on inviter type
    String? inviterName;
    String? inviterEmail;
    String? inviterPhone;
    String? agencyName;
    String? primaryContact;
    
    if (inviterType == 'BusOwner') {
      inviterName = inviter['name'] as String?;
      inviterEmail = inviter['email'] as String?;
      inviterPhone = inviter['phoneNumber'] as String?;
    } else if (inviterType == 'Admin' || inviterType == 'User') {
      inviterName = inviter['name'] as String?;
      inviterEmail = inviter['email'] as String?;
    } else if (inviterType == 'BusAgent' || inviterType == 'Counter') {
      agencyName = inviter['agencyName'] as String?;
      inviterEmail = inviter['email'] as String?;
      primaryContact = inviter['primaryContact'] as String?;
      // Use primaryContact as phone for BusAgent/Counter
      inviterPhone = primaryContact;
    }
    
    // If no specific type, try to get common fields
    if (inviterName == null) {
      inviterName = inviter['name'] as String?;
    }
    if (inviterEmail == null) {
      inviterEmail = inviter['email'] as String?;
    }
    if (inviterPhone == null) {
      inviterPhone = inviter['phoneNumber'] as String? ?? inviter['primaryContact'] as String?;
    }

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_add_alt_1,
                  color: Colors.purple.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invited By',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _getInviterTypeLabel(inviterType),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getInviterTypeColor(inviterType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  inviterType,
                  style: TextStyle(
                    color: _getInviterTypeColor(inviterType),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppTheme.spacingL),
          
          // Display fields based on inviter type
          if (agencyName != null && agencyName.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.business,
              label: 'Agency Name',
              value: agencyName,
            ),
          ],
          if (inviterName != null && inviterName.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.person,
              label: 'Name',
              value: inviterName,
            ),
          ],
          if (inviterEmail != null && inviterEmail.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.email,
              label: 'Email',
              value: inviterEmail,
            ),
          ],
          if (inviterPhone != null && inviterPhone.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.phone,
              label: inviterType == 'BusAgent' || inviterType == 'Counter' ? 'Primary Contact' : 'Phone',
              value: inviterPhone,
            ),
          ],
          // Show primaryContact separately if it's different from phoneNumber for BusAgent/Counter
          if ((inviterType == 'BusAgent' || inviterType == 'Counter') && 
              primaryContact != null && 
              primaryContact.isNotEmpty && 
              primaryContact != inviterPhone) ...[
            _InfoRow(
              icon: Icons.contact_phone,
              label: 'Contact',
              value: primaryContact,
            ),
          ],
        ],
      ),
    );
  }
  
  String _getInviterTypeLabel(String type) {
    switch (type) {
      case 'BusOwner':
        return 'Bus Owner';
      case 'Admin':
      case 'User':
        return 'Administrator';
      case 'BusAgent':
      case 'Counter':
        return 'Bus Agent / Counter';
      default:
        return 'Inviter';
    }
  }
  
  Color _getInviterTypeColor(String type) {
    switch (type) {
      case 'BusOwner':
        return Colors.purple.shade700;
      case 'Admin':
      case 'User':
        return Colors.blue.shade700;
      case 'BusAgent':
      case 'Counter':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
