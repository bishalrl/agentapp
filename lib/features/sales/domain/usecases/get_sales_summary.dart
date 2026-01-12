import '../../../../core/utils/result.dart';
import '../repositories/sales_repository.dart';

class GetSalesSummary {
  final SalesRepository repository;

  GetSalesSummary(this.repository);

  Future<Result<Map<String, dynamic>>> call({
    String? startDate,
    String? endDate,
    String? busId,
    String? paymentMethod,
    String? groupBy,
  }) async {
    return await repository.getSalesSummary(
      startDate: startDate,
      endDate: endDate,
      busId: busId,
      paymentMethod: paymentMethod,
      groupBy: groupBy,
    );
  }
}
