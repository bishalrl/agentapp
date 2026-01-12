import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/utils/bloc_extensions.dart';
import '../../domain/entities/route_entity.dart';
import '../bloc/route_bloc.dart';
import '../bloc/events/route_event.dart';
import '../bloc/states/route_state.dart';

class EditRoutePage extends StatefulWidget {
  final String routeId;
  final RouteEntity? route;

  const EditRoutePage({
    super.key,
    required this.routeId,
    this.route,
  });

  @override
  State<EditRoutePage> createState() => _EditRoutePageState();
}

class _EditRoutePageState extends State<EditRoutePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _distanceController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final route = widget.route;
    _fromController = TextEditingController(text: route?.from ?? '');
    _toController = TextEditingController(text: route?.to ?? '');
    _distanceController = TextEditingController(
      text: route?.distance?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: route?.estimatedDuration?.toString() ?? '',
    );
    _descriptionController = TextEditingController(text: route?.description ?? '');
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = context.read<RouteBloc>();
        // If route is not provided, fetch it
        if (widget.route == null) {
          bloc.safeAdd(GetRouteByIdEvent(routeId: widget.routeId));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Route'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/routes');
              }
            },
          ),
        ),
        body: BlocConsumer<RouteBloc, RouteState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: state.errorMessage!,
                  errorSource: 'Route Update',
                ),
              );
            }
            
            if (state.successMessage != null && state.updatedRoute != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.successMessage!)),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.pop();
                }
              });
            }
            
            // Update form if route is fetched
            if (state.selectedRoute != null && widget.route == null) {
              final route = state.selectedRoute!;
              _fromController.text = route.from;
              _toController.text = route.to;
              _distanceController.text = route.distance?.toString() ?? '';
              _durationController.text = route.estimatedDuration?.toString() ?? '';
              _descriptionController.text = route.description ?? '';
            }
          },
          builder: (context, state) {
            if (state.isLoading && widget.route == null && state.selectedRoute == null) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final route = widget.route ?? state.selectedRoute;
            if (route == null && !state.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text('Route not found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _fromController,
                                    decoration: const InputDecoration(
                                      labelText: 'From *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter origin';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _toController,
                                    decoration: const InputDecoration(
                                      labelText: 'To *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter destination';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _distanceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Distance (km)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.straighten),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        if (double.tryParse(value) == null) {
                                          return 'Please enter valid distance';
                                        }
                                        if (double.parse(value) < 0) {
                                          return 'Distance cannot be negative';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _durationController,
                                    decoration: const InputDecoration(
                                      labelText: 'Duration (minutes)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.access_time),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        if (int.tryParse(value) == null) {
                                          return 'Please enter valid duration';
                                        }
                                        if (int.parse(value) < 0) {
                                          return 'Duration cannot be negative';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<RouteBloc>().safeAdd(
                                      UpdateRouteEvent(
                                        routeId: widget.routeId,
                                        from: _fromController.text.trim(),
                                        to: _toController.text.trim(),
                                        distance: _distanceController.text.trim().isEmpty
                                            ? null
                                            : double.tryParse(_distanceController.text.trim()),
                                        estimatedDuration: _durationController.text.trim().isEmpty
                                            ? null
                                            : int.tryParse(_durationController.text.trim()),
                                        description: _descriptionController.text.trim().isEmpty
                                            ? null
                                            : _descriptionController.text.trim(),
                                      ),
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Route'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

