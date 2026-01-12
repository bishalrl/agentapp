import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_management_repository.dart';

class GetDrivers {
  final DriverManagementRepository repository;

  GetDrivers(this.repository);

  Future<Result<List<DriverEntity>>> call({
    String? status,
    String? busId,
  }) async {
    return await repository.getDrivers(
      status: status,
      busId: busId,
    );
  }
}
