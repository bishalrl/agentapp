import '../../../../core/utils/result.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class GetSchedules {
  final ScheduleRepository repository;

  GetSchedules(this.repository);

  Future<Result<List<ScheduleEntity>>> call({
    String? routeId,
    String? busId,
    bool? isActive,
  }) async {
    return await repository.getSchedules(
      routeId: routeId,
      busId: busId,
      isActive: isActive,
    );
  }
}
