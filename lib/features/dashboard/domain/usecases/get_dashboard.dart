import '../../../../core/utils/result.dart';
import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboard {
  final DashboardRepository repository;

  GetDashboard(this.repository);

  Future<Result<DashboardEntity>> call() async {
    return await repository.getDashboard();
  }
}

