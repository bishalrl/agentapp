import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/quick_action_card.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/widgets/illustrated_empty_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/injection/injection.dart' as di;
import '../bloc/dashboard_bloc.dart';
import '../bloc/events/dashboard_event.dart';
import '../bloc/states/dashboard_state.dart';
import '../../domain/entities/dashboard_entity.dart';

/// Completely redesigned dashboard with modern UX, quick actions, metrics grid, and activity feed.
class RedesignedDashboardPage extends StatelessWidget {
  const RedesignedDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DashboardBloc>()..add(const GetDashboardEvent()),
      child: Scaffold(
        body: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              final isAuthError = state.errorMessage!.toLowerCase().contains('authentication') ||
                  state.errorMessage!.toLowerCase().contains('token') ||
                  state.errorMessage!.toLowerCase().contains('login');

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
            if (state.isLoading && state.dashboard == null) {
              return const _DashboardSkeleton();
            }

            if (state.errorMessage != null && state.dashboard == null) {
              return ErrorStateWidget(
                message: state.errorMessage!,
                onRetry: () {
                  context.read<DashboardBloc>().add(const GetDashboardEvent());
                },
              );
            }

            final dashboard = state.dashboard;
            if (dashboard == null) {
              return const IllustratedEmptyState(
                icon: Icons.dashboard_outlined,
                title: 'No data available',
                description: 'Unable to load dashboard data.',
              );
            }

            return _DashboardContent(dashboard: dashboard);
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardEntity dashboard;

  const _DashboardContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const GetDashboardEvent());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            _WelcomeHeader(
              greeting: greeting,
              agencyName: dashboard.counter.agencyName,
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Quick Actions Row
            SectionHeader(
              title: 'Quick Actions',
              showDivider: false,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _QuickActionsRow(),
            const SizedBox(height: AppTheme.spacingXL),

            // Key Metrics Grid
            SectionHeader(
              title: 'Today\'s Overview',
              subtitle: DateFormat('EEEE, MMMM d').format(DateTime.now()),
              showDivider: false,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _MetricsGrid(stats: dashboard.todayStats, walletBalance: dashboard.counter.walletBalance),
            const SizedBox(height: AppTheme.spacingXL),

            // Upcoming Buses
            SectionHeader(
              title: 'Upcoming Buses',
              actionLabel: 'View All',
              onAction: () => context.go('/buses'),
              showDivider: false,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _UpcomingBusesSection(assignedBuses: dashboard.assignedBuses),
            const SizedBox(height: AppTheme.spacingXL),

            // Recent Activity (placeholder - would need additional data)
            SectionHeader(
              title: 'Recent Activity',
              actionLabel: 'View All',
              onAction: () => context.go('/bookings'),
              showDivider: false,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _RecentActivityPlaceholder(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String greeting;
  final String agencyName;

  const _WelcomeHeader({
    required this.greeting,
    required this.agencyName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return EnhancedCard(
      elevation: CardElevation.raised,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Icon(
              Icons.business,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  agencyName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(now),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => context.go('/notifications'),
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Row(
        children: [
          QuickActionCard(
            icon: Icons.add_circle_outline,
            label: 'New Booking',
            onTap: () => context.go('/bookings/create'),
            iconColor: AppTheme.statusInfo,
          ),
          const SizedBox(width: AppTheme.spacingM),
          QuickActionCard(
            icon: Icons.request_quote,
            label: 'Request Access',
            onTap: () => context.go('/counter/request-bus-access'),
            iconColor: AppTheme.warningColor,
            badgeCount: 2, // Example: pending requests
          ),
          const SizedBox(width: AppTheme.spacingM),
          QuickActionCard(
            icon: Icons.account_balance_wallet,
            label: 'Wallet',
            onTap: () => context.go('/wallet'),
            iconColor: AppTheme.successColor,
          ),
          const SizedBox(width: AppTheme.spacingM),
          QuickActionCard(
            icon: Icons.bar_chart,
            label: 'Reports',
            onTap: () => context.go('/sales'),
            iconColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final TodayStatsEntity stats;
  final double walletBalance;

  const _MetricsGrid({
    required this.stats,
    required this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                value: stats.totalBookings.toString(),
                label: 'Today\'s Bookings',
                icon: Icons.confirmation_number,
                color: AppTheme.statusInfo,
                trendValue: 12.5, // Example trend
                trendLabel: '+12.5% vs yesterday',
                onTap: () => context.go('/bookings'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: MetricCard(
                value: '₹${NumberFormat('#,##0').format(stats.totalSales)}',
                label: 'Total Sales',
                icon: Icons.currency_rupee,
                color: AppTheme.successColor,
                trendValue: 8.3,
                trendLabel: '+8.3% vs yesterday',
                onTap: () => context.go('/sales'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                value: '2', // Example: pending requests
                label: 'Pending Requests',
                icon: Icons.pending_actions,
                color: AppTheme.warningColor,
                onTap: () => context.go('/counter/requests'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: MetricCard(
                value: '₹${NumberFormat('#,##0').format(walletBalance)}',
                label: 'Wallet Balance',
                icon: Icons.account_balance_wallet,
                color: AppTheme.primaryColor,
                onTap: () => context.go('/wallet'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UpcomingBusesSection extends StatelessWidget {
  final Map<String, Map<String, RouteBusesEntity>> assignedBuses;

  const _UpcomingBusesSection({required this.assignedBuses});

  @override
  Widget build(BuildContext context) {
    if (assignedBuses.isEmpty) {
      return IllustratedEmptyState(
        icon: Icons.directions_bus_outlined,
        title: 'No upcoming buses',
        description: 'Request access to buses to start booking.',
        actionLabel: 'Request Access',
        onAction: () => context.go('/counter/request-bus-access'),
      );
    }

    // Get next 3-5 buses
    final upcomingBuses = <BusInfoEntity>[];
    final now = DateTime.now();
    
    for (final dateEntry in assignedBuses.entries) {
      final date = DateTime.parse(dateEntry.key);
      if (date.isAfter(now) || date.day == now.day) {
        for (final routeEntry in dateEntry.value.entries) {
          for (final bus in routeEntry.value.buses) {
            if (upcomingBuses.length < 5) {
              upcomingBuses.add(bus);
            }
          }
        }
      }
    }

    if (upcomingBuses.isEmpty) {
      return IllustratedEmptyState(
        icon: Icons.directions_bus_outlined,
        title: 'No upcoming buses',
        description: 'Request access to buses to start booking.',
        actionLabel: 'Request Access',
        onAction: () => context.go('/counter/request-bus-access'),
      );
    }

    return Column(
      children: upcomingBuses.take(3).map((bus) {
        final hasAccess = bus.accessId != null || bus.allowedSeats.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: EnhancedCard(
            onTap: () => context.go('/buses/${bus.id}'),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: hasAccess
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Icon(
                    hasAccess ? Icons.directions_bus : Icons.lock_outline,
                    color: hasAccess ? AppTheme.successColor : AppTheme.warningColor,
                    size: 28,
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
                      const SizedBox(height: AppTheme.spacingXS),
                      Row(
                        children: [
                          Icon(
                            Icons.route,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${bus.from} → ${bus.to}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('MMM d').format(bus.date)} • ${bus.time}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${NumberFormat('#,##0').format(bus.price)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    if (!hasAccess)
                      TextButton(
                        onPressed: () => context.go('/counter/request-bus-access?busId=${bus.id}'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Request',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecentActivityPlaceholder extends StatelessWidget {
  const _RecentActivityPlaceholder();

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking confirmed',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '2 hours ago',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Divider(),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.statusInfo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: const Icon(
                  Icons.request_quote,
                  color: AppTheme.statusInfo,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus access requested',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '5 hours ago',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EnhancedCard(
            showSkeleton: true,
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: const SizedBox(height: 80),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: EnhancedCard(
                  showSkeleton: true,
                  child: const SizedBox(height: 100),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: EnhancedCard(
                  showSkeleton: true,
                  child: const SizedBox(height: 100),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: EnhancedCard(
                  showSkeleton: true,
                  child: const SizedBox(height: 100),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: EnhancedCard(
                  showSkeleton: true,
                  child: const SizedBox(height: 100),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXL),
          EnhancedCard(
            showSkeleton: true,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: const SizedBox(height: 60),
          ),
          const SizedBox(height: AppTheme.spacingM),
          EnhancedCard(
            showSkeleton: true,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: const SizedBox(height: 60),
          ),
        ],
      ),
    );
  }
}
