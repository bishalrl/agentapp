import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/utils/bloc_extensions.dart';
import '../bloc/route_bloc.dart';
import '../bloc/events/route_event.dart';
import '../bloc/states/route_state.dart';

class RouteListPage extends StatelessWidget {
  const RouteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<RouteBloc>()..safeAdd(const GetRoutesEvent()),
      child: BackButtonHandler(
        enableDoubleBackToExit: false,
        child: Scaffold(
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
            title: const Text('Routes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<RouteBloc>().safeAdd(const GetRoutesEvent());
                },
              ),
            ],
          ),
          body: BlocConsumer<RouteBloc, RouteState>(
            listener: (context, state) {
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                final isAuthError = state.errorMessage!.toLowerCase().contains('authentication') ||
                                    state.errorMessage!.toLowerCase().contains('token') ||
                                    state.errorMessage!.toLowerCase().contains('login');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  ErrorSnackBar(
                    message: state.errorMessage!,
                    errorSource: 'Route Management',
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
              }
            },
            builder: (context, state) {
              if (state.isLoading && state.routes.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.errorMessage != null && state.routes.isEmpty) {
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
                          context.read<RouteBloc>().safeAdd(const GetRoutesEvent());
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

              if (state.routes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.route_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No routes found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first route to get started',
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
                  context.read<RouteBloc>().safeAdd(const GetRoutesEvent());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.routes.length,
                  itemBuilder: (context, index) {
                    final route = state.routes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.route, color: Colors.white),
                        ),
                        title: Text(
                          route.routeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (route.distance != null)
                              Text('Distance: ${route.distance} km'),
                            if (route.estimatedDuration != null)
                              Text('Duration: ${route.estimatedDuration} minutes'),
                            if (route.description != null && route.description!.isNotEmpty)
                              Text(
                                route.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              context.go('/routes/${route.id}/edit');
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, route.id, route.routeName);
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
                          context.go('/routes/${route.id}');
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
              context.go('/routes/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Route'),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String routeId, String routeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: Text('Are you sure you want to delete "$routeName"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RouteBloc>().safeAdd(DeleteRouteEvent(routeId: routeId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

