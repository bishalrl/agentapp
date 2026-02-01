import '../../../../core/utils/result.dart';
import '../entities/counter_request_entity.dart';
import '../repositories/counter_request_repository.dart';

class RequestBusAccess {
  final CounterRequestRepository repository;

  RequestBusAccess(this.repository);

  Future<Result<CounterRequestEntity>> call({
    required String busId,
    required List<String> requestedSeats,
    String? message,
  }) async {
    print('🎯 RequestBusAccess UseCase.call: Starting');
    print('   BusId: $busId');
    print('   RequestedSeats: $requestedSeats');
    
    final result = await repository.requestBusAccess(
      busId: busId,
      requestedSeats: requestedSeats,
      message: message,
    );
    
    if (result is Success<CounterRequestEntity>) {
      print('   ✅ RequestBusAccess UseCase: Success');
    } else if (result is Error<CounterRequestEntity>) {
      print('   ❌ RequestBusAccess UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
