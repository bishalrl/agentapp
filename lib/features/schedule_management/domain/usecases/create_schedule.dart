import '../../../../core/utils/result.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class CreateSchedule {
  final ScheduleRepository repository;

  CreateSchedule(this.repository);

  Future<Result<ScheduleEntity>> call({
    required String routeId,
    String? busId,
    required String departureTime,
    required String arrivalTime,
    required List<String> daysOfWeek,
    bool? isActive,
  }) async {
    return await repository.createSchedule(
      routeId: routeId,
      busId: busId,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      daysOfWeek: daysOfWeek,
      isActive: isActive,
    );
  }
}
