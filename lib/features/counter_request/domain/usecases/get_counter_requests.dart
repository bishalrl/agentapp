import '../../../../core/utils/result.dart';
import '../entities/counter_request_entity.dart';
import '../repositories/counter_request_repository.dart';

class GetCounterRequests {
  final CounterRequestRepository repository;

  GetCounterRequests(this.repository);

  Future<Result<List<CounterRequestEntity>>> call() async {
    print('🎯 GetCounterRequests UseCase.call: Starting');
    
    final result = await repository.getCounterRequests();
    
    if (result is Success<List<CounterRequestEntity>>) {
      print('   ✅ GetCounterRequests UseCase: Success - ${result.data.length} requests');
    } else if (result is Error<List<CounterRequestEntity>>) {
      print('   ❌ GetCounterRequests UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
