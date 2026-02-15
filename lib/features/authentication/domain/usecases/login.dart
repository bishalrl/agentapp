import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Result<AuthEntity>> call(String phone, String password) async {
    print('🎯 Login UseCase.call: Starting');
    print('   Phone: $phone');
    final result = await repository.login(phone, password);
    if (result is Success<AuthEntity>) {
      print('   ✅ Login UseCase: Success');
    } else if (result is Error<AuthEntity>) {
      print('   ❌ Login UseCase: Error - ${result.failure.message}');
    }
    return result;
  }
}

