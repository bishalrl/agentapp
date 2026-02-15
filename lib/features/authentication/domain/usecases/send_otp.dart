import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class SendOtp {
  final AuthRepository repository;

  SendOtp(this.repository);

  Future<Result<void>> call({
    required String phone,
    String purpose = 'login',
    String userType = 'Counter',
  }) {
    return repository.sendOtp(
      phone: phone,
      purpose: purpose,
      userType: userType,
    );
  }
}

