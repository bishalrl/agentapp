import '../../../../../core/bloc/base_bloc_event.dart';

abstract class DashboardEvent extends BaseBlocEvent {
  const DashboardEvent();
}

class GetDashboardEvent extends DashboardEvent {
  final bool? forceRefresh;
  
  const GetDashboardEvent({this.forceRefresh});
  
  @override
  List<Object?> get props => [forceRefresh];
}

class RefreshDashboardEvent extends DashboardEvent {
  const RefreshDashboardEvent();
  
  @override
  List<Object?> get props => [];
}
