import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_management_repository.dart';

class GetDriverById {
  final DriverManagementRepository repository;

  GetDriverById(this.repository);

  Future<Result<DriverEntity>> call(String driverId) async {
    return await repository.getDriverById(driverId);
  }
}
