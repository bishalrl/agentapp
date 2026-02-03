import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/bloc_extensions.dart';
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
          title: const Text('Buses'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearSearch,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.searchedBus != null) {
                    return _buildSearchResults(context, state);
                  }

                  if (state.errorMessage != null && state.buses.isEmpty) {
                    return _buildErrorState(context, state.errorMessage!);
                  }

                  if (state.buses.isEmpty) {
                    return _buildEmptyState(context);
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by bus number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, BusState state) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          _buildBusCard(context, state.searchedBus!),
          const SizedBox(height: AppTheme.spacingM),
          TextButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear),
            label: const Text('Clear Search'),
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

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearSearch,
            child: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bus_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No buses available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a bus or request access to see them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/counter/request-bus-access'),
            icon: const Icon(Icons.request_quote),
            label: const Text('Request Bus Access'),
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(BuildContext context, bus) {
    final theme = Theme.of(context);
    return EnhancedCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: () => context.go('/buses/${bus.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: bus.isActive 
                      ? AppTheme.primaryColor.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  color: bus.isActive ? AppTheme.primaryColor : Colors.grey,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      children: [
                        Icon(Icons.route_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(
                          '${bus.from} → ${bus.to}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: bus.isActive 
                      ? AppTheme.successColor.withOpacity(0.1) 
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  border: Border.all(
                    color: bus.isActive ? AppTheme.successColor : AppTheme.errorColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      bus.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 14,
                      color: bus.isActive ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bus.isActive ? 'Active' : 'Inactive',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: bus.isActive ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Access Status Badge
          if (bus.hasNoAccess == true || bus.hasAccess == false)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingXS,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'No Access',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            )
          else if (bus.hasRestrictedAccess == true)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingXS,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_open, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Limited Access',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            )
          else if (bus.hasAccess == true)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingS,
                vertical: AppTheme.spacingXS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: Border.all(color: AppTheme.successColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: AppTheme.successColor),
                  const SizedBox(width: 4),
                  Text(
                    'Full Access',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppTheme.spacingM),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _BusInfoItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: bus.date.toString().split(' ')[0],
                ),
              ),
              Expanded(
                child: _BusInfoItem(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: bus.time,
                ),
              ),
              Expanded(
                child: _BusInfoItem(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Price',
                  value: '₹${bus.price.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _BusInfoItem(
                  icon: Icons.event_seat_rounded,
                  label: 'Seats',
                  value: '${bus.totalSeats}',
                ),
              ),
            ],
          ),
          if (bus.accessId != null || (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty)) ...[
            const SizedBox(height: AppTheme.spacingS),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: AppTheme.spacingXS),
                  Expanded(
                    child: Text(
                      bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty
                          ? 'Allowed Seats: ${bus.allowedSeats!.map((s) => s.toString()).join(', ')}'
                          : 'Full Access',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppTheme.spacingS),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/counter/request-bus-access?busId=${bus.id}'),
                icon: const Icon(Icons.request_quote, size: 18),
                label: const Text('Request Access'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BusInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BusInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class SuccessSnackBar extends SnackBar {
  SuccessSnackBar({super.key, required String message})
      : super(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        );
}

