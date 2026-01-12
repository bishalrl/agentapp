import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../../core/utils/bloc_extensions.dart';
import '../../../../core/injection/injection.dart' as di;
import '../bloc/bus_bloc.dart';
import '../bloc/events/bus_event.dart';
import '../bloc/states/bus_state.dart';

class BusListPage extends StatelessWidget {
  const BusListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to read BusBloc from context, if not available create new one
    BusBloc? busBloc;
    try {
      busBloc = context.read<BusBloc>();
    } catch (e) {
      // BLoC not in context, will create new one
      busBloc = di.sl<BusBloc>();
    }
    
    // Trigger the event
    busBloc!.safeAdd(const GetMyBusesEvent());
    
    return BlocProvider.value(
      value: busBloc,
      child: BackButtonHandler(
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
          title: const Text('My Buses'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<BusBloc>().safeAdd(const GetMyBusesEvent());
              },
            ),
          ],
        ),
        body: BlocConsumer<BusBloc, BusState>(
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
                  if (context.mounted) {
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
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.buses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BusBloc>().safeAdd(const GetMyBusesEvent());
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

            if (state.buses.isEmpty) {
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
                      'No buses found',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first bus to get started',
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
                context.read<BusBloc>().safeAdd(const GetMyBusesEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.buses.length,
                itemBuilder: (context, index) {
                  final bus = state.buses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: bus.isActive 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey,
                        child: Icon(
                          Icons.directions_bus, 
                          color: Colors.white,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              bus.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: bus.isActive 
                                  ? Colors.green.withOpacity(0.1) 
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: bus.isActive ? Colors.green : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  bus.isActive ? Icons.check_circle : Icons.cancel,
                                  size: 14,
                                  color: bus.isActive ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  bus.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: bus.isActive ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${bus.from} → ${bus.to}'),
                          Text('${bus.date.toString().split(' ')[0]} at ${bus.time}'),
                          Text('₹${bus.price.toStringAsFixed(0)} | ${bus.totalSeats} seats'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.go('/buses/${bus.id}/edit');
                          } else if (value == 'activate') {
                            context.read<BusBloc>().safeAdd(ActivateBusEvent(busId: bus.id));
                          } else if (value == 'deactivate') {
                            context.read<BusBloc>().safeAdd(DeactivateBusEvent(busId: bus.id));
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, bus.id, bus.name);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          if (!bus.isActive)
                            const PopupMenuItem(
                              value: 'activate',
                              child: Row(
                                children: [
                                  Icon(Icons.play_circle, size: 20, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Activate', style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            ),
                          if (bus.isActive)
                            const PopupMenuItem(
                              value: 'deactivate',
                              child: Row(
                                children: [
                                  Icon(Icons.pause_circle, size: 20, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Deactivate', style: TextStyle(color: Colors.orange)),
                                ],
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        context.go('/buses/${bus.id}');
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.go('/buses/create');
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Bus'),
        ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String busId, String busName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: Text('Are you sure you want to delete "$busName"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BusBloc>().safeAdd(DeleteBusEvent(busId: busId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

