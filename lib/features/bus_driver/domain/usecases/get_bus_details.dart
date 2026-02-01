import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class GetBusDetails {
  final DriverRepository repository;

  GetBusDetails(this.repository);

  Future<Result<Map<String, dynamic>>> call(String busId) async {
    print('🎯 GetBusDetails UseCase.call: Starting');
    print('   BusId: $busId');
    
    final result = await repository.getBusDetails(busId);
    
    if (result is Success<Map<String, dynamic>>) {
      print('   ✅ GetBusDetails UseCase: Success');
    } else if (result is Error<Map<String, dynamic>>) {
      print('   ❌ GetBusDetails UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
