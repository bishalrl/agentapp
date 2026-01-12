import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class GetStoredToken {
  final AuthRepository repository;

  GetStoredToken(this.repository);

  Future<Result<String?>> call() async {
    return await repository.getStoredToken();
  }
}

