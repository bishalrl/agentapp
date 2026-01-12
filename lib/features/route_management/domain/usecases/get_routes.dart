import '../../../../core/utils/result.dart';
import '../entities/route_entity.dart';
import '../repositories/route_repository.dart';

class GetRoutes {
  final RouteRepository repository;

  GetRoutes(this.repository);

  Future<Result<List<RouteEntity>>> call({
    String? search,
  }) async {
    return await repository.getRoutes(search: search);
  }
}

