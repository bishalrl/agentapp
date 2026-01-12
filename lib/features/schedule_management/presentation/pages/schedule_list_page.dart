import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/events/schedule_event.dart';
import '../bloc/states/schedule_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import 'create_schedule_page.dart';

class ScheduleListPage extends StatelessWidget {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ScheduleBloc>()..add(GetSchedulesEvent()),
      child: const _ScheduleListView(),
    );
  }
}

class _ScheduleListView extends StatelessWidget {
  const _ScheduleListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
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
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/schedules/create'),
          ),
        ],
      ),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Schedules',
              ),
            );
          } else if (state is ScheduleCreated || state is ScheduleUpdated || state is ScheduleDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Operation successful'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ScheduleBloc>().add(GetSchedulesEvent());
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScheduleError) {
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
                      context.read<ScheduleBloc>().add(GetSchedulesEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SchedulesLoaded) {
            if (state.schedules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No schedules found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/schedules/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Schedule'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ScheduleBloc>().add(GetSchedulesEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = state.schedules[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: schedule.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        child: Icon(
                          Icons.schedule,
                          color: schedule.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                      title: Text(
                        '${schedule.departureTime} - ${schedule.arrivalTime}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Route ID: ${schedule.routeId}'),
                          if (schedule.busId != null) Text('Bus ID: ${schedule.busId}'),
                          Text('Days: ${schedule.daysOfWeek.join(", ")}'),
                          Chip(
                            label: Text(
                              schedule.isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: schedule.isActive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
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
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            context.read<ScheduleBloc>().add(
                                  DeleteScheduleEvent(schedule.id),
                                );
                          }
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
}
