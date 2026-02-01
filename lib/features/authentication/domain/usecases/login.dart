import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Result<AuthEntity>> call(String email, String password, {String loginType = 'counter'}) async {
    print('🎯 Login UseCase.call: Starting');
    print('   Email: $email');
    print('   LoginType: $loginType');
    final result = await repository.login(email, password, loginType: loginType);
    if (result is Success<AuthEntity>) {
      print('   ✅ Login UseCase: Success');
    } else if (result is Error<AuthEntity>) {
      print('   ❌ Login UseCase: Error - ${result.failure.message}');
    }
    return result;
  }
}

