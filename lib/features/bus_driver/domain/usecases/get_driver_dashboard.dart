import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class GetDriverDashboard {
  final DriverRepository repository;
  
  GetDriverDashboard(this.repository);
  
  Future<Result<Map<String, dynamic>>> call() async {
    print('🎯 GetDriverDashboard UseCase.call: Starting');
    
    final result = await repository.getDriverDashboard();
    
    if (result is Success<Map<String, dynamic>>) {
      print('   ✅ GetDriverDashboard UseCase: Success');
    } else if (result is Error<Map<String, dynamic>>) {
      print('   ❌ GetDriverDashboard UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
