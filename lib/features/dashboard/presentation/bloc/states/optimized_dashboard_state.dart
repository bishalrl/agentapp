import '../../../../../core/bloc/granular_loading_state.dart';
import '../../../domain/entities/dashboard_entity.dart';

/// Optimized dashboard state with granular loading
class DashboardState {
  final DashboardEntity? dashboard;
  final LoadingState loadingState;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const DashboardState({
    this.dashboard,
    required this.loadingState,
    this.errorMessage,
    this.lastUpdated,
  });

  DashboardState copyWith({
    DashboardEntity? dashboard,
    LoadingState? loadingState,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return DashboardState(
      dashboard: dashboard ?? this.dashboard,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Check if we should show skeleton loader
  bool get shouldShowSkeleton => 
      loadingState.isInitialLoad && dashboard == null;

  /// Check if we should show refresh indicator
  bool get shouldShowRefreshIndicator => 
      loadingState.isRefreshing && dashboard != null;

  /// Check if we should show cached data
  bool get shouldShowCachedData => 
      dashboard != null && !loadingState.isInitialLoad;
}
