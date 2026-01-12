import '../../../../../core/bloc/base_bloc_event.dart';

abstract class DashboardEvent extends BaseBlocEvent {
  const DashboardEvent();
}

class GetDashboardEvent extends DashboardEvent {
  const GetDashboardEvent();
}

