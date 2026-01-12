import '../../../../core/utils/result.dart';
import '../repositories/schedule_repository.dart';

class DeleteSchedule {
  final ScheduleRepository repository;

  DeleteSchedule(this.repository);

  Future<Result<void>> call(String scheduleId) async {
    return await repository.deleteSchedule(scheduleId);
  }
}
