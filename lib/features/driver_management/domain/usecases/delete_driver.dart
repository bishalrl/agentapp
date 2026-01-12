import '../../../../core/utils/result.dart';
import '../repositories/driver_management_repository.dart';

class DeleteDriver {
  final DriverManagementRepository repository;

  DeleteDriver(this.repository);

  Future<Result<void>> call(String driverId) async {
    return await repository.deleteDriver(driverId);
  }
}
