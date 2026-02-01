import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class UpdateDriverLocation {
  final DriverRepository repository;
  
  UpdateDriverLocation(this.repository);
  
  Future<Result<Map<String, dynamic>>> call({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    return await repository.updateDriverLocation(
      busId: busId,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      heading: heading,
      accuracy: accuracy,
    );
  }
}
