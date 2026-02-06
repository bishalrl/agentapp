import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/bloc_extensions.dart';
import 'package:intl/intl.dart';
import '../bloc/bus_bloc.dart';
import '../bloc/events/bus_event.dart';
import '../bloc/states/bus_state.dart';

class BusListPage extends StatefulWidget {
  const BusListPage({super.key});

  @override
  State<BusListPage> createState() => _BusListPageState();
}

class _BusListPageState extends State<BusListPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Load initial bus list
    context.read<BusBloc>().safeAdd(const GetAllAvailableBusesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      context
          .read<BusBloc>()
          .safeAdd(SearchBusByNumberEvent(busNumber: _searchController.text.trim()));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<BusBloc>().safeAdd(const GetAllAvailableBusesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      enableDoubleBackToExit: false, // Allow normal back navigation
      child: Scaffold(
        drawer: const MainDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold?.hasDrawer == true) scaffold!.openDrawer();
            },
          ),
          title: const Text('Buses'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearSearch,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: AppSearchBar(
                hintText: 'Search by bus number or name...',
                controller: _searchController,
                onChanged: (value) {
                  if (value.isEmpty) {
                    _clearSearch();
                  }
                },
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            Expanded(
              child: BlocConsumer<BusBloc, BusState>(
                listener: (context, state) {
                  if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                    final isAuthError = state.errorMessage!.toLowerCase().contains('authentication') ||
                                        state.errorMessage!.toLowerCase().contains('token') ||
                                        state.errorMessage!.toLowerCase().contains('login');
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      ErrorSnackBar(
                        message: state.errorMessage!,
                        errorSource: 'Bus Management',
                        errorType: isAuthError ? 'Authentication Error' : 'Error',
                      ),
                    );
                    
                    if (isAuthError) {
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          context.go('/login');
                        }
                      });
                    }
                  }
                  
                  if (state.successMessage != null && state.successMessage!.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SuccessSnackBar(message: state.successMessage!),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.isLoading && state.buses.isEmpty && state.searchedBus == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.searchedBus != null) {
                    return _buildSearchResults(context, state);
                  }

                  if (state.errorMessage != null && state.buses.isEmpty) {
                    return ErrorStateWidget(
                      message: state.errorMessage!,
                      onRetry: _clearSearch,
                    );
                  }

                  if (state.buses.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.directions_bus_outlined,
                      title: 'No buses available',
                      description: 'Request access to buses to start booking.',
                      actionLabel: 'Request Bus Access',
                      onAction: () => context.go('/counter/request-bus-access'),
                    );
                  }

                  return _buildBusList(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSearchResults(BuildContext context, BusState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          _buildBusCard(context, state.searchedBus!),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusList(BuildContext context, BusState state) {
    return RefreshIndicator(
      onRefresh: () async => _clearSearch(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        physics: const BouncingScrollPhysics(),
        itemCount: state.buses.length,
        itemBuilder: (context, index) {
          final bus = state.buses[index];
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
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
        },
      ),
    );
  }


  Widget _buildBusCard(BuildContext context, bus) {
    final theme = Theme.of(context);
    final hasNoAccess = bus.hasNoAccess == true || bus.hasAccess == false;
    final hasRestrictedAccess = bus.hasRestrictedAccess == true;
    final hasFullAccess = bus.hasAccess == true && !hasRestrictedAccess;
    // Calculate available seats: if restricted access, use allowedSeats count, otherwise use totalSeats
    final availableSeats = hasRestrictedAccess && bus.allowedSeats != null
        ? bus.allowedSeats!.length
        : bus.totalSeats;
    final isActive = bus.isActive ?? true;

    return EnhancedCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => context.go('/buses/${bus.id}'),
      elevation: CardElevation.raised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner at Top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.errorColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusM),
                topRight: Radius.circular(AppTheme.radiusM),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? AppTheme.successColor : AppTheme.errorColor,
                  size: 18,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  isActive ? 'ACTIVE' : 'INACTIVE',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isActive ? AppTheme.successColor : AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                // Access Status Badge
                if (hasNoAccess)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'NO ACCESS',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (hasRestrictedAccess)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.statusInfo.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_open,
                          size: 14,
                          color: AppTheme.statusInfo,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIMITED',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.statusInfo,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (hasFullAccess)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'FULL ACCESS',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bus Name - LARGE and PROMINENT
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
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
                            'Bus Name',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bus.name.isEmpty ? 'Bus ${bus.id.substring(0, 8)}' : bus.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Route - Clear and Prominent
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: AppTheme.lightBorderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${bus.from} → ${bus.to}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Key Info Grid - Date, Time, Price, Seats
                Row(
                  children: [
                    Expanded(
                      child: _BusInfoItem(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: DateFormat('MMM d').format(bus.date),
                      ),
                    ),
                    Expanded(
                      child: _BusInfoItem(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: _formatTime(bus.time),
                      ),
                    ),
                    Expanded(
                      child: _BusInfoItem(
                        icon: Icons.currency_rupee,
                        label: 'Price',
                        value: '₹${NumberFormat('#,##0').format(bus.price)}',
                      ),
                    ),
                    Expanded(
                      child: _BusInfoItem(
                        icon: Icons.event_seat,
                        label: 'Seats',
                        value: '$availableSeats/${bus.totalSeats}',
                        highlight: availableSeats == 0,
                      ),
                    ),
                  ],
                ),

                // Access Details
                if (hasRestrictedAccess && bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.statusInfo.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: AppTheme.statusInfo.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppTheme.statusInfo,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Allowed Seats',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                bus.allowedSeats!.map((s) => s.toString()).join(', '),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action Button
                if (hasNoAccess) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/counter/request-bus-access?busId=${bus.id}'),
                      icon: const Icon(Icons.request_quote, size: 20),
                      label: const Text('Request Access'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final parsed = DateFormat('HH:mm').parse(time);
      return DateFormat('h:mm a').format(parsed);
    } catch (e) {
      return time;
    }
  }
}

class _BusInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _BusInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.errorColor.withOpacity(0.05)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: highlight ? AppTheme.errorColor : AppTheme.primaryColor,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight ? AppTheme.errorColor : AppTheme.textPrimary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


