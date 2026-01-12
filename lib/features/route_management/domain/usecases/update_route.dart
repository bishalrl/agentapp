import '../../../../core/utils/result.dart';
import '../entities/route_entity.dart';
import '../repositories/route_repository.dart';

class UpdateRoute {
  final RouteRepository repository;

  UpdateRoute(this.repository);

  Future<Result<RouteEntity>> call({
    required String routeId,
    String? from,
    String? to,
    double? distance,
    int? estimatedDuration,
    String? description,
  }) async {
    return await repository.updateRoute(
      routeId: routeId,
      from: from,
      to: to,
      distance: distance,
      estimatedDuration: estimatedDuration,
      description: description,
    );
  }
}

