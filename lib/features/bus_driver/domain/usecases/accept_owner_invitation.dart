import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class AcceptOwnerInvitation {
  final DriverRepository repository;

  AcceptOwnerInvitation(this.repository);

  Future<Result<Map<String, dynamic>>> call(String invitationId) async {
    return await repository.acceptOwnerInvitation(invitationId);
  }
}
