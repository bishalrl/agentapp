import '../../../../core/utils/result.dart';
import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class ActivateBus {
  final BusRepository repository;

  ActivateBus(this.repository);

  Future<Result<BusEntity>> call(String busId) async {
    print('🎯 ActivateBus UseCase.call: Starting');
    print('   BusId: $busId');
    final result = await repository.activateBus(busId);
    if (result is Success<BusEntity>) {
      print('   ✅ ActivateBus UseCase: Success');
    } else if (result is Error<BusEntity>) {
      print('   ❌ ActivateBus UseCase: Error - ${result.failure.message}');
    }
    return result;
  }
}
