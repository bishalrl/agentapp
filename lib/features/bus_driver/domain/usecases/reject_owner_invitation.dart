import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class RejectOwnerInvitation {
  final DriverRepository repository;

  RejectOwnerInvitation(this.repository);

  Future<Result<Map<String, dynamic>>> call(String invitationId) async {
    return await repository.rejectOwnerInvitation(invitationId);
  }
}
