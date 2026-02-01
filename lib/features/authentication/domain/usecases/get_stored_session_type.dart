import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class GetStoredSessionType {
  final AuthRepository repository;

  GetStoredSessionType(this.repository);

  Future<Result<String?>> call() async {
    return await repository.getStoredSessionType();
  }
}

