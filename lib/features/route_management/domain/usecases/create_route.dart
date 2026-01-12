import '../../../../core/utils/result.dart';
import '../entities/route_entity.dart';
import '../repositories/route_repository.dart';

class CreateRoute {
  final RouteRepository repository;

  CreateRoute(this.repository);

  Future<Result<RouteEntity>> call({
    required String from,
    required String to,
    double? distance,
    int? estimatedDuration,
    String? description,
  }) async {
    print('🎯 CreateRoute UseCase.call: Starting');
    print('   From: $from, To: $to');
    final result = await repository.createRoute(
      from: from,
      to: to,
      distance: distance,
      estimatedDuration: estimatedDuration,
      description: description,
    );
    if (result is Success<RouteEntity>) {
      print('   ✅ CreateRoute UseCase: Success');
    } else if (result is Error<RouteEntity>) {
      print('   ❌ CreateRoute UseCase: Error - ${result.failure.message}');
    }
    return result;
  }
}

