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
import '../../../../core/widgets/main_drawer.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/events/auth_event.dart';
import '../../../authentication/presentation/bloc/states/auth_state.dart' as auth;

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
            BlocListener<AuthBloc, auth.AuthState>(
              listener: (context, state) {
                if (state.isAuthenticated == false && state.isLoading == false) {
                  // Navigate to login after successful logout
                  context.go('/login');
                }
              },
              child: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.read<AuthBloc>().add(const LogoutEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
                padding: const EdgeInsets.all(AppTheme.spacingM),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: _CounterInfoCard(counter: dashboard.counter),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
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
                      child: _TodayStatsCard(stats: dashboard.todayStats),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
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
                      child: _QuickActionsSection(),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 450),
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
                      child: _AssignedBusesSection(assignedBuses: dashboard.assignedBuses),
                    ),
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
    final theme = Theme.of(context);
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  Icons.business_center_rounded,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counter.agencyName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      counter.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Wallet Balance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Rs. ${NumberFormat('#,##0.00').format(counter.walletBalance)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
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

class _TodayStatsCard extends StatelessWidget {
  final TodayStatsEntity stats;

  const _TodayStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Today\'s Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Bookings',
                  value: stats.totalBookings.toString(),
                  icon: Icons.confirmation_number_rounded,
                  iconColor: Colors.blue,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: StatCard(
                  title: 'Total Sales',
                  value: 'Rs. ${NumberFormat('#,##0').format(stats.totalSales)}',
                  icon: Icons.currency_rupee_rounded,
                  iconColor: AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Cash Sales',
                  value: 'Rs. ${NumberFormat('#,##0').format(stats.cashSales)}',
                  icon: Icons.money_rounded,
                  iconColor: AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: StatCard(
                  title: 'Online Sales',
                  value: 'Rs. ${NumberFormat('#,##0').format(stats.onlineSales)}',
                  icon: Icons.payment_rounded,
                  iconColor: Colors.purple,
                ),
              ),
            ],
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
    final theme = Theme.of(context);
    if (assignedBuses.isEmpty) {
      return EnhancedCard(
        padding: const EdgeInsets.all(AppTheme.spacingXXL),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.directions_bus_outlined,
                size: 64,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                'No buses assigned',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.directions_bus_rounded,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              'Assigned Buses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        ...assignedBuses.entries.map((dateEntry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: AppTheme.spacingS),
                child: Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.parse(dateEntry.key)),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              ...dateEntry.value.entries.map((routeEntry) {
                final routeBuses = routeEntry.value;
                return EnhancedCard(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Icon(
                        Icons.route_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${routeBuses.route.from} → ${routeBuses.route.to}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${routeBuses.buses.length} bus(es)',
                      style: theme.textTheme.bodySmall,
                    ),
                    children: routeBuses.buses.map((bus) {
                      final hasAccess = bus.accessId != null || (bus.allowedSeats.isNotEmpty);
                      return Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingS),
                              decoration: BoxDecoration(
                                color: hasAccess 
                                    ? AppTheme.successColor.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                              ),
                              child: Icon(
                                hasAccess 
                                    ? Icons.directions_bus_rounded
                                    : Icons.lock_outline_rounded,
                                color: hasAccess 
                                    ? AppTheme.successColor
                                    : Colors.orange,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              bus.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${bus.time} • ${bus.totalSeats} seats',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (hasAccess && bus.allowedSeats.isNotEmpty)
                                  Text(
                                    'Allowed: ${bus.allowedSeats.map((s) => s.toString()).join(', ')}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.blue.shade700,
                                      fontSize: 11,
                                    ),
                                  ),
                                if (!hasAccess)
                                  Text(
                                    'No access - Request to book',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.orange.shade700,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${NumberFormat('#,##0').format(bus.price)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                if (!hasAccess)
                                  TextButton(
                                    onPressed: () {
                                      context.go('/counter/request-bus-access?busId=${bus.id}');
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Request',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              context.go('/buses/${bus.id}');
                            },
                          ),
                        ],
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
    final theme = Theme.of(context);
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Wrap(
            spacing: AppTheme.spacingM,
            runSpacing: AppTheme.spacingM,
            children: [
                _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'New Booking',
                  color: Colors.blue,
                  onTap: () => context.go('/bookings/create'),
                ),
                _QuickActionButton(
                  icon: Icons.request_quote,
                  label: 'Request Bus Access',
                  color: Colors.green,
                  onTap: () => context.go('/counter/request-bus-access'),
                ),
                _QuickActionButton(
                  icon: Icons.list_alt,
                  label: 'My Requests',
                  color: Colors.cyan,
                  onTap: () => context.go('/counter/requests'),
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
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
