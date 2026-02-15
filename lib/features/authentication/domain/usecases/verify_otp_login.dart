import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpLogin {
  final AuthRepository repository;

  VerifyOtpLogin(this.repository);

  Future<Result<AuthEntity>> call({
    required String phone,
    required String otp,
    String userType = 'Counter',
  }) {
    return repository.verifyOtpLogin(
      phone: phone,
      otp: otp,
      userType: userType,
    );
  }
}

