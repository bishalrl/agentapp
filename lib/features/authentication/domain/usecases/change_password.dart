import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;

  ChangePassword(this.repository);

  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    return await repository.changePassword(currentPassword, newPassword, token);
  }
}

