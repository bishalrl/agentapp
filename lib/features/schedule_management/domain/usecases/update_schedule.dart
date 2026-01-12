import '../../../../core/utils/result.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class UpdateSchedule {
  final ScheduleRepository repository;

  UpdateSchedule(this.repository);

  Future<Result<ScheduleEntity>> call({
    required String scheduleId,
    String? departureTime,
    String? arrivalTime,
    List<String>? daysOfWeek,
    bool? isActive,
  }) async {
    return await repository.updateSchedule(
      scheduleId: scheduleId,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      daysOfWeek: daysOfWeek,
      isActive: isActive,
    );
  }
}
