import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/driver_management_bloc.dart';
import '../bloc/events/driver_management_event.dart';
import '../bloc/states/driver_management_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import 'invite_driver_page.dart';

class DriverListPage extends StatelessWidget {
  const DriverListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DriverManagementBloc>()..add(GetDriversEvent()),
      child: const _DriverListView(),
    );
  }
}

class _DriverListView extends StatelessWidget {
  const _DriverListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => context.push('/drivers/invite'),
          ),
        ],
      ),
      body: BlocConsumer<DriverManagementBloc, DriverManagementState>(
        listener: (context, state) {
          if (state is DriverManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Drivers',
              ),
            );
          } else if (state is DriverInvited || state is DriverUpdated || state is DriverDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Operation successful'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DriverManagementBloc>().add(GetDriversEvent());
          }
        },
        builder: (context, state) {
          if (state is DriverManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DriverManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DriverManagementBloc>().add(GetDriversEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DriversLoaded) {
            if (state.drivers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No drivers found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/drivers/invite'),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Invite Driver'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DriverManagementBloc>().add(GetDriversEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.drivers.length,
                itemBuilder: (context, index) {
                  final driver = state.drivers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(driver.name[0].toUpperCase()),
                      ),
                      title: Text(
                        driver.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(driver.phoneNumber),
                          if (driver.email != null) Text(driver.email!),
                          Chip(
                            label: Text(
                              driver.status.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getStatusColor(driver.status),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Text('View Details'),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'assign',
                            child: Text('Assign to Bus'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                        onSelected: (value) {
                          // Handle actions
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green.withOpacity(0.2);
      case 'active':
        return Colors.blue.withOpacity(0.2);
      default:
        return Colors.orange.withOpacity(0.2);
    }
  }
}
