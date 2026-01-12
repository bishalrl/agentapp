import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_repository.dart';

class GetAssignedBuses {
  final DriverRepository repository;
  
  GetAssignedBuses(this.repository);
  
  Future<Result<List<BusEntity>>> call() async {
    return await repository.getAssignedBuses();
  }
}

