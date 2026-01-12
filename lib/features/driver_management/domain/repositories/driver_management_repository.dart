import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';

abstract class DriverManagementRepository {
  Future<Result<DriverEntity>> inviteDriver({
    required String name,
    required String phoneNumber,
    String? email,
    required String licenseNumber,
    required DateTime licenseExpiry,
    String? address,
    String? busId,
  });
  Future<Result<List<DriverEntity>>> getDrivers({
    String? status,
    String? busId,
  });
  Future<Result<DriverEntity>> getDriverById(String driverId);
  Future<Result<DriverEntity>> assignDriverToBus({
    required String driverId,
    required String busId,
  });
  Future<Result<DriverEntity>> updateDriver({
    required String driverId,
    String? name,
    String? email,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? address,
  });
  Future<Result<void>> deleteDriver(String driverId);
}
