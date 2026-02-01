import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class GetPermissionRequests {
  final DriverRepository repository;
  
  GetPermissionRequests(this.repository);
  
  Future<Result<Map<String, dynamic>>> call() async {
    return await repository.getPermissionRequests();
  }
}
