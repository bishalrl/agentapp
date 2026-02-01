import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class GetBusPassengers {
  final DriverRepository repository;
  
  GetBusPassengers(this.repository);
  
  Future<Result<Map<String, dynamic>>> call(String busId) async {
    return await repository.getBusPassengers(busId);
  }
}
