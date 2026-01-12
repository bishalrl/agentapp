import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_management_repository.dart';

class AssignDriverToBus {
  final DriverManagementRepository repository;

  AssignDriverToBus(this.repository);

  Future<Result<DriverEntity>> call({
    required String driverId,
    required String busId,
  }) async {
    return await repository.assignDriverToBus(
      driverId: driverId,
      busId: busId,
    );
  }
}
