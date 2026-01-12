import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../domain/entities/route_entity.dart';

class RouteState extends BaseBlocState {
  final List<RouteEntity> routes;
  final RouteEntity? selectedRoute;
  final RouteEntity? createdRoute;
  final RouteEntity? updatedRoute;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const RouteState({
    this.routes = const [],
    this.selectedRoute,
    this.createdRoute,
    this.updatedRoute,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  RouteState copyWith({
    List<RouteEntity>? routes,
    RouteEntity? selectedRoute,
    RouteEntity? createdRoute,
    RouteEntity? updatedRoute,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return RouteState(
      routes: routes ?? this.routes,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      createdRoute: createdRoute ?? this.createdRoute,
      updatedRoute: updatedRoute ?? this.updatedRoute,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        routes,
        selectedRoute,
        createdRoute,
        updatedRoute,
        isLoading,
        errorMessage,
        successMessage,
      ];
}

