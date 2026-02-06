import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../../../core/bloc/optimized_bloc_mixin.dart';
import '../../../../core/bloc/granular_loading_state.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../domain/usecases/get_dashboard.dart';
import 'events/optimized_dashboard_event.dart';
import 'states/optimized_dashboard_state.dart';
import '../../domain/entities/dashboard_entity.dart';

/// Optimized Dashboard BLoC with:
/// - Cache-first loading
/// - Granular loading states
/// - Event deduplication
/// - Background refresh
class OptimizedDashboardBloc extends Bloc<DashboardEvent, DashboardState> 
    with OptimizedBlocMixin {
  final GetDashboard getDashboard;
  
  OptimizedDashboardBloc({required this.getDashboard}) 
      : super(DashboardState(
          loadingState: const LoadingState(isInitialLoad: true),
        )) {
    on<GetDashboardEvent>(_onGetDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onGetDashboard(
    GetDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    await executeWithDeduplication(
      event,
      'get_dashboard',
      () async {
        // Emit loading state (but keep previous data visible)
        emit(state.copyWith(
          loadingState: state.loadingState.copyWith(
            isInitialLoad: state.dashboard == null,
            isLoading: state.dashboard == null, // Only show full loading if no data
            isRefreshing: state.dashboard != null, // Background refresh if data exists
          ),
          errorMessage: null,
        ));

        // Load with cache-first strategy
        final result = await loadWithCache<DashboardEntity>(
          cacheKey: CacheKeys.dashboard,
          fetchRemote: () async {
            final Result<DashboardEntity> remoteResult = await getDashboard();
            if (remoteResult is Error<DashboardEntity>) {
              throw remoteResult.failure;
            } else if (remoteResult is Success<DashboardEntity>) {
              return remoteResult.data;
            }
            throw ServerFailure('Unexpected result type from getDashboard');
          },
          ttl: CacheTTL.dashboard,
          forceRefresh: event.forceRefresh ?? false,
        );

        emit(state.copyWith(
          dashboard: result,
          loadingState: state.loadingState.copyWith(
            isLoading: false,
            isRefreshing: false,
            isInitialLoad: false,
          ),
          errorMessage: null,
        ));
      },
    ).catchError((error) {
      final failure = error is Failure ? error : ServerFailure(error.toString());
      
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      final String displayMessage;
      if (failure is NetworkFailure && state.dashboard != null) {
        displayMessage = 'Unable to refresh. Showing cached data.';
      } else {
        displayMessage = errorMessage;
      }
      
      emit(state.copyWith(
        loadingState: state.loadingState.copyWith(
          isLoading: false,
          isRefreshing: false,
          isInitialLoad: false,
        ),
        errorMessage: displayMessage,
      ));
    });
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // Background refresh - don't show loading, just refresh indicator
    emit(state.copyWith(
      loadingState: state.loadingState.copyWith(isRefreshing: true),
    ));

    try {
      final Result<DashboardEntity> result = await getDashboard();
      
      if (result is Success<DashboardEntity>) {
        // Update cache
        await CacheManager.set(
          CacheKeys.dashboard,
          result.data,
          ttl: CacheTTL.dashboard,
        );
        
        emit(state.copyWith(
          dashboard: result.data,
          loadingState: state.loadingState.copyWith(isRefreshing: false),
        ));
      } else {
        emit(state.copyWith(
          loadingState: state.loadingState.copyWith(isRefreshing: false),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        loadingState: state.loadingState.copyWith(isRefreshing: false),
      ));
    }
  }
}
