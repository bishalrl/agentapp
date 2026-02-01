import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class RequestPermission {
  final DriverRepository repository;
  
  RequestPermission(this.repository);
  
  Future<Result<Map<String, dynamic>>> call({
    required String permissionType,
    String? busId,
    String? message,
  }) async {
    return await repository.requestPermission(
      permissionType: permissionType,
      busId: busId,
      message: message,
    );
  }
}
