import '../../../../core/utils/result.dart';
import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class GetMyBuses {
  final BusRepository repository;

  GetMyBuses(this.repository);

  Future<Result<List<BusEntity>>> call({
    String? date,
    String? route,
    String? status,
  }) async {
    return await repository.getMyBuses(
      date: date,
      route: route,
      status: status,
    );
  }
}

