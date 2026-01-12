import '../../../../core/utils/result.dart';
import '../entities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<Result<ScheduleEntity>> createSchedule({
    required String routeId,
    String? busId,
    required String departureTime,
    required String arrivalTime,
    required List<String> daysOfWeek,
    bool? isActive,
  });
  Future<Result<List<ScheduleEntity>>> getSchedules({
    String? routeId,
    String? busId,
    bool? isActive,
  });
  Future<Result<ScheduleEntity>> getScheduleById(String scheduleId);
  Future<Result<ScheduleEntity>> updateSchedule({
    required String scheduleId,
    String? departureTime,
    String? arrivalTime,
    List<String>? daysOfWeek,
    bool? isActive,
  });
  Future<Result<void>> deleteSchedule(String scheduleId);
}
