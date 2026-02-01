import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class AcceptRequest {
  final DriverRepository repository;

  AcceptRequest(this.repository);

  Future<Result<Map<String, dynamic>>> call(String requestId) async {
    print('🎯 AcceptRequest UseCase.call: Starting');
    print('   RequestId: $requestId');
    
    final result = await repository.acceptRequest(requestId);
    
    if (result is Success<Map<String, dynamic>>) {
      print('   ✅ AcceptRequest UseCase: Success');
    } else if (result is Error<Map<String, dynamic>>) {
      print('   ❌ AcceptRequest UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
