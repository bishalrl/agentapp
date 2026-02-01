import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/usecases/create_route.dart';
import '../../domain/usecases/update_route.dart';
import '../../domain/usecases/delete_route.dart';
import '../../domain/usecases/get_routes.dart';
import '../../domain/usecases/get_route_by_id.dart';
import 'events/route_event.dart';
import 'states/route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final CreateRoute createRoute;
  final UpdateRoute updateRoute;
  final DeleteRoute deleteRoute;
  final GetRoutes getRoutes;
  final GetRouteById getRouteById;

  RouteBloc({
    required this.createRoute,
    required this.updateRoute,
    required this.deleteRoute,
    required this.getRoutes,
    required this.getRouteById,
  }) : super(const RouteState()) {
    on<CreateRouteEvent>(_onCreateRoute);
    on<UpdateRouteEvent>(_onUpdateRoute);
    on<DeleteRouteEvent>(_onDeleteRoute);
    on<GetRoutesEvent>(_onGetRoutes);
    on<GetRouteByIdEvent>(_onGetRouteById);
  }

  Future<void> _onCreateRoute(
    CreateRouteEvent event,
    Emitter<RouteState> emit,
  ) async {
    print('🔵 RouteBloc._onCreateRoute called');
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));
    
    final result = await createRoute(
      from: event.from,
      to: event.to,
      distance: event.distance,
      estimatedDuration: event.estimatedDuration,
      description: event.description,
    );

    if (result is Error<RouteEntity>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } else if (result is Success<RouteEntity>) {
      final route = result.data;
      emit(state.copyWith(
        isLoading: false,
        createdRoute: route,
        successMessage: 'Route created successfully!',
        routes: [...state.routes, route],
      ));
    }
  }

  Future<void> _onUpdateRoute(
    UpdateRouteEvent event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));
    
    final result = await updateRoute(
      routeId: event.routeId,
      from: event.from,
      to: event.to,
      distance: event.distance,
      estimatedDuration: event.estimatedDuration,
      description: event.description,
    );

    if (result is Error<RouteEntity>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<RouteEntity>) {
      final updatedRoute = result.data;
      final updatedRoutes = state.routes.map((route) {
        return route.id == updatedRoute.id ? updatedRoute : route;
      }).toList();
      emit(state.copyWith(
        isLoading: false,
        updatedRoute: updatedRoute,
        routes: updatedRoutes,
        successMessage: 'Route updated successfully!',
      ));
    }
  }

  Future<void> _onDeleteRoute(
    DeleteRouteEvent event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));
    
    final result = await deleteRoute(event.routeId);

    if (result is Error<void>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<void>) {
      final updatedRoutes = state.routes.where((route) => route.id != event.routeId).toList();
      emit(state.copyWith(
        isLoading: false,
        routes: updatedRoutes,
        successMessage: 'Route deleted successfully!',
      ));
    }
  }

  Future<void> _onGetRoutes(
    GetRoutesEvent event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await getRoutes(search: event.search);

    if (result is Error<List<RouteEntity>>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<List<RouteEntity>>) {
      emit(state.copyWith(
        isLoading: false,
        routes: result.data,
      ));
    }
  }

  Future<void> _onGetRouteById(
    GetRouteByIdEvent event,
    Emitter<RouteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await getRouteById(event.routeId);

    if (result is Error<RouteEntity>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<RouteEntity>) {
      emit(state.copyWith(
        isLoading: false,
        selectedRoute: result.data,
      ));
    }
  }
}

