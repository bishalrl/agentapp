import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class InitiateRide {
  final DriverRepository repository;
  
  InitiateRide(this.repository);
  
  Future<Result<Map<String, dynamic>>> call(String busId) async {
    return await repository.initiateRide(busId);
  }
}
