import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../domain/entities/bus_entity.dart';
import '../bloc/bus_bloc.dart';
import '../bloc/events/bus_event.dart';
import '../bloc/states/bus_state.dart';

class BusDetailPage extends StatelessWidget {
  final String busId;

  const BusDetailPage({
    super.key,
    required this.busId,
  });

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
          final busIndex = state.buses.indexWhere((b) => b.id == busId);
          
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
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.go('/buses/${bus.id}/edit');
                  },
                ),
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
                final currentBusIndex = state.buses.indexWhere((b) => b.id == busId);
                final currentBus = currentBusIndex != -1 
                    ? state.buses[currentBusIndex] 
                    : bus;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Card(
                        color: currentBus.isActive 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.red.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                currentBus.isActive 
                                    ? Icons.check_circle 
                                    : Icons.cancel,
                                color: currentBus.isActive ? Colors.green : Colors.red,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentBus.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: currentBus.isActive ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentBus.isActive 
                                          ? 'This bus is available for bookings'
                                          : 'This bus is currently unavailable',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                        ? Icons.pause_circle 
                                        : Icons.play_circle,
                                  ),
                                  label: Text(
                                    currentBus.isActive ? 'Deactivate' : 'Activate',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentBus.isActive 
                                        ? Colors.orange 
                                        : Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Basic Information
                      _InfoCard(
                        title: 'Basic Information',
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
                      
                      const SizedBox(height: 16),
                      
                      // Route Information
                      _InfoCard(
                        title: 'Route Information',
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
                      
                      const SizedBox(height: 16),
                      
                      // Pricing & Seats
                      _InfoCard(
                        title: 'Pricing & Seats',
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
                      
                      const SizedBox(height: 16),
                      
                      // Driver Information
                      if (currentBus.driverContact != null || currentBus.driverId != null)
                        _InfoCard(
                          title: 'Driver Information',
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
                      
                      const SizedBox(height: 16),
                      
                      // Actions
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.go('/buses/${currentBus.id}/edit');
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Bus'),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _showDeleteDialog(context, currentBus);
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text(
                                  'Delete Bus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
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

  void _showDeleteDialog(BuildContext context, BusEntity bus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: Text('Are you sure you want to delete "${bus.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<BusBloc>().add(DeleteBusEvent(busId: bus.id));
              // Navigate back after deletion
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go('/buses');
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
