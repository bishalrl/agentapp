import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class GetPendingRequests {
  final DriverRepository repository;

  GetPendingRequests(this.repository);

  Future<Result<Map<String, dynamic>>> call() async {
    print('🎯 GetPendingRequests UseCase.call: Starting');
    
    final result = await repository.getPendingRequests();
    
    if (result is Success<Map<String, dynamic>>) {
      print('   ✅ GetPendingRequests UseCase: Success');
    } else if (result is Error<Map<String, dynamic>>) {
      print('   ❌ GetPendingRequests UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
