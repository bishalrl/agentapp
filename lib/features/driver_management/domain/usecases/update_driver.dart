import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_management_repository.dart';

class UpdateDriver {
  final DriverManagementRepository repository;

  UpdateDriver(this.repository);

  Future<Result<DriverEntity>> call({
    required String driverId,
    String? name,
    String? email,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? address,
  }) async {
    return await repository.updateDriver(
      driverId: driverId,
      name: name,
      email: email,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      address: address,
    );
  }
}
