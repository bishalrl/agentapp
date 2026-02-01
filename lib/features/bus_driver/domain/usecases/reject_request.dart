import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class RejectRequest {
  final DriverRepository repository;

  RejectRequest(this.repository);

  Future<Result<Map<String, dynamic>>> call(String requestId) async {
    print('🎯 RejectRequest UseCase.call: Starting');
    print('   RequestId: $requestId');
    
    final result = await repository.rejectRequest(requestId);
    
    if (result is Success<Map<String, dynamic>>) {
      print('   ✅ RejectRequest UseCase: Success');
    } else if (result is Error<Map<String, dynamic>>) {
      print('   ❌ RejectRequest UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
