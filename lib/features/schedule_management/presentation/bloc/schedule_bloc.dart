import 'package:agentapp/features/schedule_management/presentation/bloc/events/schedule_event.dart';
import 'package:agentapp/features/schedule_management/presentation/bloc/states/schedule_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/usecases/create_schedule.dart';
import '../../domain/usecases/get_schedules.dart';
import '../../domain/usecases/get_schedule_by_id.dart';
import '../../domain/usecases/update_schedule.dart';
import '../../domain/usecases/delete_schedule.dart';


class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final CreateSchedule createSchedule;
  final GetSchedules getSchedules;
  final GetScheduleById getScheduleById;
  final UpdateSchedule updateSchedule;
  final DeleteSchedule deleteSchedule;

  ScheduleBloc({
    required this.createSchedule,
    required this.getSchedules,
    required this.getScheduleById,
    required this.updateSchedule,
    required this.deleteSchedule,
  }) : super(ScheduleInitial()) {
    on<GetSchedulesEvent>(_onGetSchedules);
    on<CreateScheduleEvent>(_onCreateSchedule);
    on<GetScheduleByIdEvent>(_onGetScheduleById);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<DeleteScheduleEvent>(_onDeleteSchedule);
  }

  Future<void> _onGetSchedules(
    GetSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    final result = await getSchedules(
      routeId: event.routeId,
      busId: event.busId,
      isActive: event.isActive,
    );
    if (result is Error<List<ScheduleEntity>>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(ScheduleError(errorMessage));
    } else if (result is Success<List<ScheduleEntity>>) {
      emit(SchedulesLoaded(result.data));
    }
  }

  Future<void> _onCreateSchedule(
    CreateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    final result = await createSchedule(
      routeId: event.routeId,
      busId: event.busId,
      departureTime: event.departureTime,
      arrivalTime: event.arrivalTime,
      daysOfWeek: event.daysOfWeek,
      isActive: event.isActive,
    );
    if (result is Error<ScheduleEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(ScheduleError(errorMessage));
    } else if (result is Success<ScheduleEntity>) {
      emit(ScheduleCreated(result.data));
    }
  }

  Future<void> _onGetScheduleById(
    GetScheduleByIdEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    final result = await getScheduleById(event.scheduleId);
    if (result is Error<ScheduleEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(ScheduleError(errorMessage));
    } else if (result is Success<ScheduleEntity>) {
      emit(ScheduleLoaded(result.data));
    }
  }

  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    final result = await updateSchedule(
      scheduleId: event.scheduleId,
      departureTime: event.departureTime,
      arrivalTime: event.arrivalTime,
      daysOfWeek: event.daysOfWeek,
      isActive: event.isActive,
    );
    if (result is Error<ScheduleEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(ScheduleError(errorMessage));
    } else if (result is Success<ScheduleEntity>) {
      emit(ScheduleUpdated(result.data));
    }
  }

  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    final result = await deleteSchedule(event.scheduleId);
    if (result is Error<void>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(ScheduleError(errorMessage));
    } else if (result is Success<void>) {
      emit(ScheduleDeleted());
    }
  }
}
