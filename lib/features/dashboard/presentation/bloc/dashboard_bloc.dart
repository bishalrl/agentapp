import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_dashboard.dart';
import 'events/dashboard_event.dart';
import 'states/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboard getDashboard;

  DashboardBloc({required this.getDashboard}) : super(const DashboardState()) {
    on<GetDashboardEvent>(_onGetDashboard);
  }

  Future<void> _onGetDashboard(
    GetDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    print('🔵 DashboardBloc._onGetDashboard called');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await getDashboard();

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ GetDashboard Error: ${failure.message}');
      print('   Failure type: ${failure.runtimeType}');
      
      // Provide user-friendly error message
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else if (failure is NetworkFailure) {
        final message = failure.message.toLowerCase();
        if (message.contains('no route to host') || 
            message.contains('connection refused') ||
            message.contains('failed host lookup')) {
          errorMessage = 'Unable to connect to server. Please check your internet connection and try again.';
        } else if (message.contains('timeout')) {
          errorMessage = 'Connection timeout. Please check your internet connection and try again.';
        } else {
          errorMessage = 'Network error: ${failure.message}. Please check your internet connection.';
        }
      } else if (failure is ServerFailure) {
        // Provide user-friendly server error messages
        final message = failure.message.toLowerCase();
        if (message.contains('500') || message.contains('internal server error')) {
          errorMessage = 'Server error occurred. Please try again later or contact support if the problem persists.';
        } else if (message.contains('503') || message.contains('service unavailable')) {
          errorMessage = 'Service temporarily unavailable. Please try again in a few moments.';
        } else {
          errorMessage = failure.message;
        }
      } else {
        errorMessage = failure.message;
      }
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } else if (result is Success) {
      final dashboard = (result as Success).data;
      print('   ✅ GetDashboard Success: Agency=${dashboard.counter.agencyName}');
      emit(state.copyWith(
        dashboard: dashboard,
        isLoading: false,
        errorMessage: null,
      ));
      print('   State emitted: dashboard loaded, isLoading=false');
    }
  }
}
