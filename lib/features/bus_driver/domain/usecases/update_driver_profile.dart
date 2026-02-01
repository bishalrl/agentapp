import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_repository.dart';

class UpdateDriverProfile {
  final DriverRepository repository;

  UpdateDriverProfile(this.repository);

  Future<Result<DriverEntity>> call({
    String? name,
    String? email,
  }) async {
    print('🎯 UpdateDriverProfile UseCase.call: Starting');
    print('   Name: $name, Email: $email');
    
    final result = await repository.updateDriverProfile(
      name: name,
      email: email,
    );
    
    if (result is Success<DriverEntity>) {
      print('   ✅ UpdateDriverProfile UseCase: Success');
    } else if (result is Error<DriverEntity>) {
      print('   ❌ UpdateDriverProfile UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
