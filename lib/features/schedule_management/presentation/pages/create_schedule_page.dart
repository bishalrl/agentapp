import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/events/schedule_event.dart';
import '../bloc/states/schedule_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';

class CreateSchedulePage extends StatelessWidget {
  const CreateSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ScheduleBloc>(),
      child: const _CreateScheduleView(),
    );
  }
}

class _CreateScheduleView extends StatefulWidget {
  const _CreateScheduleView();

  @override
  State<_CreateScheduleView> createState() => _CreateScheduleViewState();
}

class _CreateScheduleViewState extends State<_CreateScheduleView> {
  final routeIdController = TextEditingController();
  final busIdController = TextEditingController();
  final departureTimeController = TextEditingController();
  final arrivalTimeController = TextEditingController();
  final List<String> selectedDays = [];
  bool isActive = true;

  @override
  void dispose() {
    routeIdController.dispose();
    busIdController.dispose();
    departureTimeController.dispose();
    arrivalTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/schedules');
            }
          },
        ),
      ),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Create Schedule',
              ),
            );
          } else if (state is ScheduleCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: routeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Route ID *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: busIdController,
                  decoration: const InputDecoration(
                    labelText: 'Bus ID (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: departureTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Departure Time * (HH:MM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: arrivalTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Arrival Time * (HH:MM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Days of Week *'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
                      .map((day) => FilterChip(
                            label: Text(day),
                            selected: selectedDays.contains(day),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is ScheduleLoading
                        ? null
                        : () {
                            if (routeIdController.text.isEmpty ||
                                departureTimeController.text.isEmpty ||
                                arrivalTimeController.text.isEmpty ||
                                selectedDays.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all required fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            context.read<ScheduleBloc>().add(
                                  CreateScheduleEvent(
                                    routeId: routeIdController.text,
                                    busId: busIdController.text.isEmpty
                                        ? null
                                        : busIdController.text,
                                    departureTime: departureTimeController.text,
                                    arrivalTime: arrivalTimeController.text,
                                    daysOfWeek: selectedDays,
                                    isActive: isActive,
                                  ),
                                );
                          },
                    child: state is ScheduleLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Schedule'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
