import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class GetOwnerInvitations {
  final DriverRepository repository;

  GetOwnerInvitations(this.repository);

  Future<Result<Map<String, dynamic>>> call() async {
    return await repository.getOwnerInvitations();
  }
}
