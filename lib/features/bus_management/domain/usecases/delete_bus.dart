import '../../../../core/utils/result.dart';
import '../repositories/bus_repository.dart';

class DeleteBus {
  final BusRepository repository;

  DeleteBus(this.repository);

  Future<Result<void>> call(String busId) async {
    return await repository.deleteBus(busId);
  }
}

