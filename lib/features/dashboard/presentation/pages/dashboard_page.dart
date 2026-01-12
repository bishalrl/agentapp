import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/events/dashboard_event.dart';
import '../bloc/states/dashboard_state.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/widgets/main_drawer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DashboardBloc>()..add(const GetDashboardEvent()),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () {
          //     if (context.canPop()) {
          //       context.pop();
          //     } else {
          //       // Dashboard is root, so just show drawer or do nothing
          //       Scaffold.of(context).openDrawer();
          //     }
          //   },
          // ),
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.go('/notifications'),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/profile'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.go('/login');
              },
            ),
          ],
        ),
        body: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              // Check if it's an authentication error
              final isAuthError = state.errorMessage!.toLowerCase().contains('authentication') ||
                                  state.errorMessage!.toLowerCase().contains('token') ||
                                  state.errorMessage!.toLowerCase().contains('login');
              
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: state.errorMessage!,
                  errorSource: 'Dashboard',
                  errorType: isAuthError ? 'Authentication Error' : 'Error',
                ),
              );
              
              // Navigate to login if authentication error
              if (isAuthError) {
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    context.go('/login');
                  }
                });
              }
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(const GetDashboardEvent());
                      },
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              );
            }

            final dashboard = state.dashboard;
            if (dashboard == null) {
              return const Center(child: Text('No data available'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const GetDashboardEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CounterInfoCard(counter: dashboard.counter),
                    const SizedBox(height: 16),
                    _QuickActionsSection(),
                    const SizedBox(height: 16),
                    _TodayStatsCard(stats: dashboard.todayStats),
                    const SizedBox(height: 16),
                    _AssignedBusesSection(assignedBuses: dashboard.assignedBuses),
                  ],
                ),
              ),
            );
          },
        ),
        drawer: const MainDrawer(),
      ),
    );
  }
}

class _CounterInfoCard extends StatelessWidget {
  final CounterEntity counter;

  const _CounterInfoCard({required this.counter});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        counter.agencyName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        counter.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet Balance',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Rs. ${NumberFormat('#,##0.00').format(counter.walletBalance)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayStatsCard extends StatelessWidget {
  final TodayStatsEntity stats;

  const _TodayStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.confirmation_number,
                    label: 'Bookings',
                    value: stats.totalBookings.toString(),
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.currency_rupee,
                    label: 'Sales',
                    value: 'Rs. ${NumberFormat('#,##0').format(stats.totalSales)}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.money,
                    label: 'Cash',
                    value: 'Rs. ${NumberFormat('#,##0').format(stats.cashSales)}',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.payment,
                    label: 'Online',
                    value: 'Rs. ${NumberFormat('#,##0').format(stats.onlineSales)}',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _AssignedBusesSection extends StatelessWidget {
  final Map<String, Map<String, RouteBusesEntity>> assignedBuses;

  const _AssignedBusesSection({required this.assignedBuses});

  @override
  Widget build(BuildContext context) {
    if (assignedBuses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.directions_bus_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No buses assigned',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Buses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...assignedBuses.entries.map((dateEntry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d, y').format(DateTime.parse(dateEntry.key)),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...dateEntry.value.entries.map((routeEntry) {
                final routeBuses = routeEntry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const Icon(Icons.route),
                    title: Text('${routeBuses.route.from} → ${routeBuses.route.to}'),
                    subtitle: Text('${routeBuses.buses.length} bus(es)'),
                    children: routeBuses.buses.map((bus) {
                      return ListTile(
                        leading: const Icon(Icons.directions_bus),
                        title: Text(bus.name),
                        subtitle: Text('${bus.time} • ${bus.totalSeats} seats'),
                        trailing: Text(
                          'Rs. ${NumberFormat('#,##0').format(bus.price)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // TODO: Navigate to bus details
                        },
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'New Booking',
                  color: Colors.blue,
                  onTap: () => context.go('/bookings/create'),
                ),
                _QuickActionButton(
                  icon: Icons.directions_bus,
                  label: 'Add Bus',
                  color: Colors.green,
                  onTap: () => context.go('/buses/create'),
                ),
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Invite Driver',
                  color: Colors.orange,
                  onTap: () => context.go('/drivers/invite'),
                ),
                _QuickActionButton(
                  icon: Icons.route,
                  label: 'Add Route',
                  color: Colors.purple,
                  onTap: () => context.go('/routes/create'),
                ),
                _QuickActionButton(
                  icon: Icons.schedule,
                  label: 'Add Schedule',
                  color: Colors.teal,
                  onTap: () => context.go('/schedules/create'),
                ),
                _QuickActionButton(
                  icon: Icons.account_balance_wallet,
                  label: 'Wallet',
                  color: Colors.indigo,
                  onTap: () => context.go('/wallet'),
                ),
                _QuickActionButton(
                  icon: Icons.bar_chart,
                  label: 'Sales Report',
                  color: Colors.red,
                  onTap: () => context.go('/sales'),
                ),
                _QuickActionButton(
                  icon: Icons.cloud_off,
                  label: 'Offline Queue',
                  color: Colors.amber,
                  onTap: () => context.go('/offline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
