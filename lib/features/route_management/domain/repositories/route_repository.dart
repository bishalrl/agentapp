import '../../../../core/utils/result.dart';
import '../entities/route_entity.dart';

abstract class RouteRepository {
  Future<Result<RouteEntity>> createRoute({
    required String from,
    required String to,
    double? distance,
    int? estimatedDuration,
    String? description,
  });
  
  Future<Result<RouteEntity>> updateRoute({
    required String routeId,
    String? from,
    String? to,
    double? distance,
    int? estimatedDuration,
    String? description,
  });
  
  Future<Result<void>> deleteRoute(String routeId);
  
  Future<Result<List<RouteEntity>>> getRoutes({
    String? search,
  });
  
  Future<Result<RouteEntity>> getRouteById(String routeId);
}

