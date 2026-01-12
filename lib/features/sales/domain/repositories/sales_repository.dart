import '../../../../core/utils/result.dart';
import '../entities/sales_entity.dart';

abstract class SalesRepository {
  Future<Result<Map<String, dynamic>>> getSalesSummary({
    String? startDate,
    String? endDate,
    String? busId,
    String? paymentMethod,
    String? groupBy,
  });
}
