import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_management_repository.dart';

class InviteDriver {
  final DriverManagementRepository repository;

  InviteDriver(this.repository);

  Future<Result<DriverEntity>> call({
    required String name,
    required String phoneNumber,
    String? email,
    required String licenseNumber,
    required DateTime licenseExpiry,
    String? address,
    String? busId,
  }) async {
    return await repository.inviteDriver(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      address: address,
      busId: busId,
    );
  }
}
