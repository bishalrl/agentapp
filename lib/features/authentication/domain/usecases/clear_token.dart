import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ClearToken {
  final AuthRepository repository;

  ClearToken(this.repository);

  Future<Result<void>> call() async {
    return await repository.clearToken();
  }
}
