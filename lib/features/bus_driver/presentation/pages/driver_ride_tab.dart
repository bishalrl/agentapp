import 'package:agentapp/features/bus_driver/presentation/bloc/events/driver_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/animations/scroll_animations.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/states/driver_state.dart';
import 'driver_ride_map_page.dart';

class DriverRideTab extends StatelessWidget {
  const DriverRideTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        final dashboardData = state.dashboardData;
        if (dashboardData == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final buses = dashboardData['buses'] as List<dynamic>? ?? [];

        if (buses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_bus_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No buses assigned',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Wait for bus assignment from the owner',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<DriverBloc>();
            // Refresh both dashboard summary and enriched assigned buses
            bloc.add(const GetDriverDashboardEvent());
            bloc.add(const GetAssignedBusesEvent());
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  child: Text(
                    'Assigned Buses',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                ...buses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bus = entry.value;
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 350 + (index * 50)),
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

  Widget _buildBusCard(BuildContext context, dynamic bus) {
                  final busData = bus as Map<String, dynamic>;
                  final busId = busData['_id'] ?? busData['id'];
                  final busName = busData['name'] ?? 'Unknown Bus';
                  final vehicleNumber = busData['vehicleNumber'] ?? 'N/A';

                  // Prefer explicit from/to fields; fall back to any nested route info;
                  // avoid showing raw "N/A" to the user.
                  String from = (busData['from'] as String?) ?? '';
                  String to = (busData['to'] as String?) ?? '';

                  // Optional: try nested route structure if present in dashboard data.
                  // Some backends may send `route` as an ID string instead of an object,
                  // so we must check the type before casting to avoid runtime errors.
                  final dynamic rawRoute = busData['route'];
                  Map<String, dynamic>? route;
                  if (rawRoute is Map<String, dynamic>) {
                    route = rawRoute;
                  }

                  if (from.isEmpty && route != null) {
                    final dynamic rawFrom = route['from'];
                    if (rawFrom is Map<String, dynamic>) {
                      from = rawFrom['name'] as String? ?? '';
                    }
                  }
                  if (to.isEmpty && route != null) {
                    final dynamic rawTo = route['to'];
                    if (rawTo is Map<String, dynamic>) {
                      to = rawTo['name'] as String? ?? '';
                    }
                  }

                  final hasRoute = from.isNotEmpty && to.isNotEmpty;
                  final routeLabel =
                      hasRoute ? '$from → $to' : 'Route information not available';

                  final date = busData['date'] ?? '';
                  final time = busData['time'] ?? 'N/A';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                    child: EnhancedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      vehicleNumber,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: AppTheme.spacingL),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.location_on,
                                  label: 'Route',
                                  value: routeLabel,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.calendar_today,
                                  label: 'Date',
                                  value: date.toString().split('T')[0],
                                ),
                              ),
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.access_time,
                                  label: 'Time',
                                  value: time,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          // Route Information Display
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.route, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: AppTheme.spacingS),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.green.shade700),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              hasRoute ? 'From: $from' : 'From: (not set)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.red.shade700),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              hasRoute ? 'To: $to' : 'To: (not set)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Initiate ride via BLoC
                                context.read<DriverBloc>().add(
                                  InitiateRideEvent(busId: busId.toString()),
                                );
                                // Navigate to map page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriverRideMapPage(
                                      busId: busId.toString(),
                                      busName: busName,
                                      from: from,
                                      to: to,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.map),
                              label: const Text('Initiate Ride'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
