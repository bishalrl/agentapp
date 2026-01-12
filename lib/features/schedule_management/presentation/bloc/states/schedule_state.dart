import '../../../domain/entities/schedule_entity.dart';

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class SchedulesLoaded extends ScheduleState {
  final List<ScheduleEntity> schedules;

  SchedulesLoaded(this.schedules);
}

class ScheduleLoaded extends ScheduleState {
  final ScheduleEntity schedule;

  ScheduleLoaded(this.schedule);
}

class ScheduleCreated extends ScheduleState {
  final ScheduleEntity schedule;

  ScheduleCreated(this.schedule);
}

class ScheduleUpdated extends ScheduleState {
  final ScheduleEntity schedule;

  ScheduleUpdated(this.schedule);
}

class ScheduleDeleted extends ScheduleState {}

class ScheduleError extends ScheduleState {
  final String message;

  ScheduleError(this.message);
}
