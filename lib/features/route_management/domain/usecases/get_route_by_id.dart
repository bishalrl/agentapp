import '../../../../core/utils/result.dart';
import '../entities/route_entity.dart';
import '../repositories/route_repository.dart';

class GetRouteById {
  final RouteRepository repository;

  GetRouteById(this.repository);

  Future<Result<RouteEntity>> call(String routeId) async {
    return await repository.getRouteById(routeId);
  }
}

