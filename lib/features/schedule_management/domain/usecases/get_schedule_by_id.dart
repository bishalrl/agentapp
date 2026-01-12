import '../../../../core/utils/result.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class GetScheduleById {
  final ScheduleRepository repository;

  GetScheduleById(this.repository);

  Future<Result<ScheduleEntity>> call(String scheduleId) async {
    return await repository.getScheduleById(scheduleId);
  }
}
