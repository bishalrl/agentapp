import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<Result<void>> call({
    required String token,
    required String newPassword,
  }) async {
    return await repository.resetPassword(token, newPassword);
  }
}
