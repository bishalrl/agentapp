import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository repository;

  ForgotPassword(this.repository);

  Future<Result<void>> call(String email) async {
    return await repository.forgotPassword(email);
  }
}
