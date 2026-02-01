import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class MarkBusAsReached {
  final DriverRepository repository;

  MarkBusAsReached(this.repository);

  Future<Result<void>> call(String busId) async {
    print('🎯 MarkBusAsReached UseCase.call: Starting');
    print('   BusId: $busId');
    
    final result = await repository.markBusAsReached(busId);
    
    if (result is Success<void>) {
      print('   ✅ MarkBusAsReached UseCase: Success');
    } else if (result is Error<void>) {
      print('   ❌ MarkBusAsReached UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
