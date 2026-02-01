import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
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
      
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      
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
