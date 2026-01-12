import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../domain/entities/dashboard_entity.dart';

class DashboardState extends BaseBlocState {
  final DashboardEntity? dashboard;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.dashboard,
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardEntity? dashboard,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [dashboard, isLoading, errorMessage];
}

