import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/sales_model.dart';

abstract class SalesRemoteDataSource {
  Future<Map<String, dynamic>> getSalesSummary({
    String? startDate,
    String? endDate,
    String? busId,
    String? paymentMethod,
    String? groupBy,
    required String token,
  });
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final ApiClient apiClient;

  SalesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> getSalesSummary({
    String? startDate,
    String? endDate,
    String? busId,
    String? paymentMethod,
    String? groupBy,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (busId != null) queryParams['busId'] = busId;
      if (paymentMethod != null) queryParams['paymentMethod'] = paymentMethod;
      if (groupBy != null) queryParams['groupBy'] = groupBy;

      final response = await apiClient.get(
        ApiConstants.counterSalesSummary,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to get sales summary');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get sales summary: ${e.toString()}');
    }
  }
}
