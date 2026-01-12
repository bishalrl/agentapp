import '../../../../core/utils/result.dart';
import '../entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<Result<DashboardEntity>> getDashboard();
}

