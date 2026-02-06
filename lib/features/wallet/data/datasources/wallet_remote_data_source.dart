import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> addMoney({
    required double amount,
    String? description,
    required String token,
  });
  Future<List<WalletTransactionModel>> getTransactions({
    String? type,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
    required String token,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl(this.apiClient);

  @override
  Future<WalletModel> addMoney({
    required double amount,
    String? description,
    required String token,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
      };
      if (description != null) body['description'] = description;

      final response = await apiClient.post(
        ApiConstants.counterWalletAdd,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );

      if (response['success'] == true && response['data'] != null) {
        return WalletModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to add money');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions({
    String? type,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        ApiConstants.counterWalletTransactions,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        List<dynamic> transactions;
        
        // Handle different response structures
        if (data is List) {
          // If data is directly a list of transactions
          transactions = data;
        } else if (data is Map && data.containsKey('transactions')) {
          // If data is a map with 'transactions' key
          transactions = data['transactions'] as List<dynamic>? ?? [];
        } else {
          // Fallback: try to get transactions from data
          transactions = [];
        }
        
        return transactions
            .map((t) => WalletTransactionModel.fromJson(t as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get transactions');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }
}
