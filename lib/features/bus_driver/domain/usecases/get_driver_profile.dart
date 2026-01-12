import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_repository.dart';

class GetDriverProfile {
  final DriverRepository repository;
  
  GetDriverProfile(this.repository);
  
  Future<Result<DriverEntity>> call() async {
    return await repository.getDriverProfile();
  }
}

