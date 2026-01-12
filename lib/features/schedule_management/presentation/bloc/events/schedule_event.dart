abstract class ScheduleEvent {}

class GetSchedulesEvent extends ScheduleEvent {
  final String? routeId;
  final String? busId;
  final bool? isActive;

  GetSchedulesEvent({this.routeId, this.busId, this.isActive});
}

class CreateScheduleEvent extends ScheduleEvent {
  final String routeId;
  final String? busId;
  final String departureTime;
  final String arrivalTime;
  final List<String> daysOfWeek;
  final bool? isActive;

  CreateScheduleEvent({
    required this.routeId,
    this.busId,
    required this.departureTime,
    required this.arrivalTime,
    required this.daysOfWeek,
    this.isActive,
  });
}

class GetScheduleByIdEvent extends ScheduleEvent {
  final String scheduleId;

  GetScheduleByIdEvent(this.scheduleId);
}

class UpdateScheduleEvent extends ScheduleEvent {
  final String scheduleId;
  final String? departureTime;
  final String? arrivalTime;
  final List<String>? daysOfWeek;
  final bool? isActive;

  UpdateScheduleEvent({
    required this.scheduleId,
    this.departureTime,
    this.arrivalTime,
    this.daysOfWeek,
    this.isActive,
  });
}

class DeleteScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  DeleteScheduleEvent(this.scheduleId);
}
