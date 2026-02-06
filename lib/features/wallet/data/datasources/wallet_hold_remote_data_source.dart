import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_hold_model.dart';

abstract class WalletHoldRemoteDataSource {
  Future<WalletHoldModel> createHold({
    required double amount,
    String? description,
    DateTime? expiresAt,
    required String token,
  });
  
  Future<WalletHoldModel> releaseHold({
    required String holdId,
    required String token,
  });
  
  Future<WalletHoldModel> confirmHold({
    required String holdId,
    String? bookingId,
    String? description,
    required String token,
  });
  
  Future<List<WalletHoldModel>> getHolds({
    String? status,
    int? limit,
    int? offset,
    required String token,
  });
  
  Future<WalletHoldModel> getHold({
    required String holdId,
    required String token,
  });
}

class WalletHoldRemoteDataSourceImpl implements WalletHoldRemoteDataSource {
  final ApiClient apiClient;

  WalletHoldRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WalletHoldModel> createHold({
    required double amount,
    String? description,
    DateTime? expiresAt,
    required String token,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
      };
      
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      if (expiresAt != null) {
        body['expiresAt'] = expiresAt.toIso8601String();
      }

      final response = await apiClient.post(
        ApiConstants.counterWalletHold,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Backend might return additional fields, ensure we have required fields
        // If holdId is missing, try 'id' field
        if (!data.containsKey('holdId') && data.containsKey('id')) {
          data['holdId'] = data['id'];
        }
        return WalletHoldModel.fromJson(data);
      } else {
        final error = response['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? 'Failed to create wallet hold';
        final code = error?['code'] as String?;
        throw ServerException(message);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }

  @override
  Future<WalletHoldModel> releaseHold({
    required String holdId,
    required String token,
  }) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.counterWalletHoldRelease}/$holdId/release',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return WalletHoldModel.fromJson(data);
      } else {
        final error = response['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? 'Failed to release wallet hold';
        throw ServerException(message);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }

  @override
  Future<WalletHoldModel> confirmHold({
    required String holdId,
    String? bookingId,
    String? description,
    required String token,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (bookingId != null && bookingId.isNotEmpty) {
        body['bookingId'] = bookingId;
      }
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      final response = await apiClient.post(
        '${ApiConstants.counterWalletHoldConfirm}/$holdId/confirm',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return WalletHoldModel.fromJson(data);
      } else {
        final error = response['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? 'Failed to confirm wallet hold';
        throw ServerException(message);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }

  @override
  Future<List<WalletHoldModel>> getHolds({
    String? status,
    int? limit,
    int? offset,
    required String token,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }
      if (offset != null) {
        queryParams['offset'] = offset.toString();
      }

      final queryString = queryParams.isEmpty
          ? ''
          : '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      final response = await apiClient.get(
        '${ApiConstants.counterWalletHolds}$queryString',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final holds = data['holds'] as List<dynamic>? ?? [];
        return holds.map((hold) => WalletHoldModel.fromJson(hold as Map<String, dynamic>)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }

  @override
  Future<WalletHoldModel> getHold({
    required String holdId,
    required String token,
  }) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.counterWalletHoldGet}/$holdId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return WalletHoldModel.fromJson(data);
      } else {
        final error = response['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? 'Failed to get wallet hold';
        throw ServerException(message);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }
}
