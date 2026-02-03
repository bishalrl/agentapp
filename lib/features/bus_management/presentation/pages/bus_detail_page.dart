import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../domain/entities/bus_entity.dart';
import '../bloc/bus_bloc.dart';
import '../bloc/events/bus_event.dart';
import '../bloc/states/bus_state.dart';

class BusDetailPage extends StatefulWidget {
  final String busId;

  const BusDetailPage({
    super.key,
    required this.busId,
  });

  @override
  State<BusDetailPage> createState() => _BusDetailPageState();
}

class _BusDetailPageState extends State<BusDetailPage> {
  @override
  Widget build(BuildContext context) {

    // Get BusBloc from context or create new one
    BusBloc? busBloc;
    try {
      busBloc = context.read<BusBloc>();
    } catch (e) {
      busBloc = di.sl<BusBloc>();
    }

    // Fetch bus details - we'll get it from the list or fetch separately
    // For now, let's find it from the state or show a loading state
    return BlocProvider.value(
      value: busBloc,
      child: BlocBuilder<BusBloc, BusState>(
        builder: (context, state) {
          // Try to find bus in the list
          final busIndex = state.buses.indexWhere((b) => b.id == widget.busId);
          
          if (busIndex == -1) {
            // Bus not found in list, show error
            return Scaffold(
              appBar: AppBar(
                title: const Text('Bus Details'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/buses');
                    }
                  },
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text('Bus not found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/buses'),
                      child: const Text('Go to Bus List'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final bus = state.buses[busIndex];

          return Scaffold(
            appBar: AppBar(
              title: Text(bus.name),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/buses');
                  }
                },
              ),
              actions: [
                // Edit bus functionality removed - counters can only request access to owner buses
              ],
            ),
            body: BlocConsumer<BusBloc, BusState>(
              listener: (context, state) {
                if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    ErrorSnackBar(
                      message: state.errorMessage!,
                      errorSource: 'Bus Management',
                    ),
                  );
                }
                
                if (state.successMessage != null && state.successMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SuccessSnackBar(message: state.successMessage!),
                  );
                }
              },
              builder: (context, state) {
                // Get updated bus from state
                final currentBusIndex = state.buses.indexWhere((b) => b.id == widget.busId);
                final currentBus = currentBusIndex != -1 
                    ? state.buses[currentBusIndex] 
                    : bus;

                final theme = Theme.of(context);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      EnhancedCard(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        backgroundColor: currentBus.isActive 
                            ? AppTheme.successColor.withOpacity(0.1) 
                            : AppTheme.errorColor.withOpacity(0.1),
                        border: Border.all(
                          color: currentBus.isActive 
                              ? AppTheme.successColor.withOpacity(0.3) 
                              : AppTheme.errorColor.withOpacity(0.3),
                          width: 2,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: currentBus.isActive 
                                    ? AppTheme.successColor.withOpacity(0.2) 
                                    : AppTheme.errorColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                currentBus.isActive 
                                    ? Icons.check_circle_rounded 
                                    : Icons.cancel_rounded,
                                color: currentBus.isActive 
                                    ? AppTheme.successColor 
                                    : AppTheme.errorColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentBus.isActive ? 'Active' : 'Inactive',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: currentBus.isActive 
                                          ? AppTheme.successColor 
                                          : AppTheme.errorColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingXS),
                                  Text(
                                    currentBus.isActive 
                                        ? 'This bus is available for bookings'
                                        : 'This bus is currently unavailable',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Only show activate/deactivate for legacy "my buses" (without accessId)
                            if (currentBus.accessId == null)
                              if (state.isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (currentBus.isActive) {
                                      _showDeactivateDialog(context, currentBus);
                                    } else {
                                      context.read<BusBloc>().add(
                                        ActivateBusEvent(busId: currentBus.id),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    currentBus.isActive 
                                        ? Icons.pause_circle_rounded 
                                        : Icons.play_circle_rounded,
                                  ),
                                  label: Text(
                                    currentBus.isActive ? 'Deactivate' : 'Activate',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentBus.isActive 
                                        ? AppTheme.warningColor 
                                        : AppTheme.successColor,
                                    foregroundColor: Colors.white,
                                  ),
                                )
                            else
                              // For assigned buses, show access status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingM,
                                  vertical: AppTheme.spacingS,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                                    const SizedBox(width: AppTheme.spacingXS),
                                    Text(
                                      'Assigned Bus',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      
                      // Basic Information
                      _InfoCard(
                        title: 'Basic Information',
                        icon: Icons.info_rounded,
                        iconColor: AppTheme.primaryColor,
                        children: [
                          _InfoRow(label: 'Name', value: currentBus.name),
                          _InfoRow(
                            label: 'Vehicle Number', 
                            value: currentBus.vehicleNumber,
                          ),
                          _InfoRow(
                            label: 'Bus Type', 
                            value: currentBus.busType ?? 'N/A',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.spacingM),
                      
                      // Route Information
                      _InfoCard(
                        title: 'Route Information',
                        icon: Icons.route_rounded,
                        iconColor: AppTheme.secondaryColor,
                        children: [
                          _InfoRow(label: 'From', value: currentBus.from),
                          _InfoRow(label: 'To', value: currentBus.to),
                          _InfoRow(
                            label: 'Date', 
                            value: currentBus.date.toString().split(' ')[0],
                          ),
                          _InfoRow(label: 'Time', value: currentBus.time),
                          if (currentBus.arrival != null)
                            _InfoRow(label: 'Arrival', value: currentBus.arrival!),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.spacingM),
                      
                      // Pricing & Seats
                      _InfoCard(
                        title: 'Pricing & Seats',
                        icon: Icons.currency_rupee_rounded,
                        iconColor: AppTheme.successColor,
                        children: [
                          _InfoRow(
                            label: 'Price', 
                            value: '₹${currentBus.price.toStringAsFixed(0)}',
                          ),
                          _InfoRow(
                            label: 'Total Seats', 
                            value: currentBus.totalSeats.toString(),
                          ),
                          if (currentBus.commissionRate != null)
                            _InfoRow(
                              label: 'Commission Rate', 
                              value: '${currentBus.commissionRate}%',
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: AppTheme.spacingM),
                      
                      // Driver Information
                      if (currentBus.driverContact != null || currentBus.driverId != null)
                        _InfoCard(
                          title: 'Driver Information',
                          icon: Icons.person_rounded,
                          iconColor: AppTheme.warningColor,
                          children: [
                            if (currentBus.driverContact != null)
                              _InfoRow(
                                label: 'Driver Contact', 
                                value: currentBus.driverContact!,
                              ),
                            if (currentBus.driverId != null)
                              _InfoRow(
                                label: 'Driver ID', 
                                value: currentBus.driverId!,
                              ),
                          ],
                        ),
                      
                      if (currentBus.driverContact != null || currentBus.driverId != null)
                        const SizedBox(height: AppTheme.spacingM),
                      
                      // Access Information (for assigned buses)
                      if (currentBus.accessId != null || (currentBus.allowedSeats != null && currentBus.allowedSeats!.isNotEmpty))
                        EnhancedCard(
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lock_open_rounded, color: Colors.green.shade700),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Text(
                                    'Access Information',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              if (currentBus.allowedSeats != null && currentBus.allowedSeats!.isNotEmpty)
                                _InfoRow(
                                  label: 'Allowed Seats',
                                  value: currentBus.allowedSeats!.map((s) => s.toString()).join(', '),
                                )
                              else
                                const _InfoRow(
                                  label: 'Access Level',
                                  value: 'Full Access (All Seats)',
                                ),
                            ],
                          ),
                        ),
                      
                      // Actions section - Edit bus functionality removed
                      if (currentBus.allowedSeats == null || currentBus.allowedSeats!.isEmpty)
                        EnhancedCard(
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'No Access',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingS),
                              Text(
                                'You don\'t have access to book seats on this bus. Request access from the owner.',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.go('/counter/request-bus-access?busId=${currentBus.id}');
                                },
                                icon: const Icon(Icons.request_quote),
                                label: const Text('Request Bus Access'),
                              ),
                            ],
                          ),
                        )
                      else
                        EnhancedCard(
                          padding: const EdgeInsets.all(AppTheme.spacingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Expanded(
                                    child: Text(
                                      'Read-only access. You can view bus details and make bookings, but cannot edit or delete bus data.',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontStyle: FontStyle.italic,
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
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, BusEntity bus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Bus'),
        content: Text('Are you sure you want to deactivate "${bus.name}"? This will make it unavailable for bookings.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<BusBloc>().add(DeactivateBusEvent(busId: bus.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData icon;
  final Color iconColor;

  const _InfoCard({
    required this.title,
    required this.children,
    this.icon = Icons.info_rounded,
    this.iconColor = AppTheme.primaryColor,
  });

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
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
