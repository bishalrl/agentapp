import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/injection/injection.dart' as di;
import '../bloc/optimized_dashboard_bloc.dart';
import '../bloc/events/optimized_dashboard_event.dart';
import '../bloc/states/optimized_dashboard_state.dart';

/// Optimized Dashboard Page with:
/// - Instant cache rendering
/// - Skeleton loaders
/// - Granular loading states
/// - Background refresh
class OptimizedDashboardPage extends StatelessWidget {
  const OptimizedDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<OptimizedDashboardBloc>()
        ..add(const GetDashboardEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            // Refresh button
            BlocBuilder<OptimizedDashboardBloc, DashboardState>(
              builder: (context, state) {
                return IconButton(
                  icon: state.shouldShowRefreshIndicator
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<OptimizedDashboardBloc>().add(
                      const RefreshDashboardEvent(),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<OptimizedDashboardBloc, DashboardState>(
          builder: (context, state) {
            // Show skeleton loader on initial load
            if (state.shouldShowSkeleton) {
              return const SkeletonDashboard();
            }

            // Show cached data immediately (even if refreshing)
            if (state.shouldShowCachedData && state.dashboard != null) {
              return _buildDashboardContent(context, state);
            }

            // Error state (but still show cached data if available)
            if (state.errorMessage != null && state.dashboard == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(state.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OptimizedDashboardBloc>().add(
                          const GetDashboardEvent(forceRefresh: true),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardState state) {
    final dashboard = state.dashboard!;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OptimizedDashboardBloc>().add(
          const RefreshDashboardEvent(),
        );
        // Wait a bit for refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show refresh indicator overlay if refreshing
            if (state.shouldShowRefreshIndicator)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Refreshing...',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
            
            // Error banner (if error but showing cached data)
            if (state.errorMessage != null && state.dashboard != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Dashboard content
            Text(
              'Welcome, ${dashboard.counter.agencyName}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: EnhancedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Bookings',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dashboard.todayStats.totalBookings}',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EnhancedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Sales',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${dashboard.todayStats.totalSales.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Buses list
            Text(
              'Assigned Buses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Show buses grouped by date/route
            ...dashboard.assignedBuses.entries.map((entry) {
              final date = entry.key;
              final routes = entry.value;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...routes.values.expand((routeBuses) {
                    return routeBuses.buses.map((bus) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(bus.name),
                          subtitle: Text('${bus.from} → ${bus.to}'),
                          trailing: Text('₹${bus.price.toStringAsFixed(0)}'),
                        ),
                      );
                    });
                  }),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
