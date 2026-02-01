import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import 'driver_create_booking_page.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/states/driver_state.dart';

class DriverBookingTab extends StatelessWidget {
  const DriverBookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, driverState) {
        final dashboardData = driverState.dashboardData;
        final driver = dashboardData?['driver'] as Map<String, dynamic>?;
        final buses = dashboardData?['buses'] as List<dynamic>? ?? [];

        // Check if driver has booking access from backend
        // Check driver's permissions or bus access permissions
        final driverPermissions = driver?['permissions'] as Map<String, dynamic>?;
        final canCreateBooking = driverPermissions?['canCreateBooking'] == true;
        
        // Also check if any bus has booking access
        bool hasBookingAccessOnAnyBus = false;
        if (buses.isNotEmpty) {
          for (var bus in buses) {
            final busData = bus as Map<String, dynamic>;
            final busAccess = busData['driverBusAccess'] as Map<String, dynamic>?;
            final busPermissions = busAccess?['permissions'] as Map<String, dynamic>?;
            if (busPermissions?['canCreateBooking'] == true) {
              hasBookingAccessOnAnyBus = true;
              break;
            }
          }
        }
        
        final hasBookingAccess = canCreateBooking || hasBookingAccessOnAnyBus;

        if (!hasBookingAccess) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Booking Access',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have permission to create bookings.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingL),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to profile to request permission
                    // This will be handled by the tab dashboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Go to Profile tab to request booking permission'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.request_quote),
                  label: const Text('Request Permission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Filter buses that driver has booking access to
        final accessibleBuses = buses.where((bus) {
          final busData = bus as Map<String, dynamic>;
          final busAccess = busData['driverBusAccess'] as Map<String, dynamic>?;
          final busPermissions = busAccess?['permissions'] as Map<String, dynamic>?;
          return busPermissions?['canCreateBooking'] == true || canCreateBooking;
        }).toList();

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card with Driver-specific Design
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildHeaderCard(context),
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Available Buses List
                if (accessibleBuses.isEmpty)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: EnhancedCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              'No Buses Available',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Text(
                              'You don\'t have booking access to any assigned buses.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (accessibleBuses.isNotEmpty)
                  ...accessibleBuses.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final bus = entry.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 50)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _buildBusCard(context, bus),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: EnhancedCard(
        backgroundColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.drive_eta,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Booking',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create bookings for your assigned buses',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'Only buses you are assigned to are available for booking.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusCard(BuildContext context, dynamic bus) {
    final busData = bus as Map<String, dynamic>;
    final busId = busData['_id'] ?? busData['id'];
    final busName = busData['name'] ?? 'Unknown';
    final vehicleNumber = busData['vehicleNumber'] ?? 'N/A';

    // Prefer explicit from/to, but support nested route object like in dashboard data
    String from = (busData['from'] as String?) ?? '';
    String to = (busData['to'] as String?) ?? '';

    final dynamic rawRoute = busData['route'];
    if (rawRoute is Map<String, dynamic>) {
      final dynamic rawFrom = rawRoute['from'];
      final dynamic rawTo = rawRoute['to'];

      if ((from.isEmpty || from == 'N/A') && rawFrom != null) {
        if (rawFrom is Map<String, dynamic>) {
          from = rawFrom['name'] as String? ?? from;
        } else if (rawFrom is String) {
          from = rawFrom;
        }
      }

      if ((to.isEmpty || to == 'N/A') && rawTo != null) {
        if (rawTo is Map<String, dynamic>) {
          to = rawTo['name'] as String? ?? to;
        } else if (rawTo is String) {
          to = rawTo;
        }
      }
    }

    from = from.isEmpty ? 'Unknown' : from;
    to = to.isEmpty ? 'Unknown' : to;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: EnhancedCard(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverCreateBookingPage(
                  busId: busId?.toString(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        busName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicleNumber,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$from → $to',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                          ),
                                        ],
                                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
