import '../../../../core/utils/result.dart';
import '../repositories/route_repository.dart';

class DeleteRoute {
  final RouteRepository repository;

  DeleteRoute(this.repository);

  Future<Result<void>> call(String routeId) async {
    return await repository.deleteRoute(routeId);
  }
}

