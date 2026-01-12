import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/seat_lock_model.dart';

abstract class SeatLockRemoteDataSource {
  Future<SeatLockModel> lockSeat(String busId, int seatNumber, String token);
  Future<List<SeatLockModel>> lockMultipleSeats(String busId, List<int> seatNumbers, String token);
  Future<void> unlockSeat(String busId, int seatNumber, String token);
  Future<List<SeatLockModel>> getBusLocks(String busId, String token);
  Future<List<SeatLockModel>> getMyLocks(String token);
}

class SeatLockRemoteDataSourceImpl implements SeatLockRemoteDataSource {
  final ApiClient apiClient;

  SeatLockRemoteDataSourceImpl(this.apiClient);

  @override
  Future<SeatLockModel> lockSeat(String busId, int seatNumber, String token) async {
    try {
      final response = await apiClient.post(
        ApiConstants.seatLock,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
          'seatNumber': seatNumber,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return SeatLockModel.fromJson({
          ...data,
          'busId': busId,
          'seatNumber': seatNumber,
        });
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to lock seat');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to lock seat: ${e.toString()}');
    }
  }

  @override
  Future<List<SeatLockModel>> lockMultipleSeats(String busId, List<int> seatNumbers, String token) async {
    try {
      final response = await apiClient.post(
        ApiConstants.seatLockMultiple,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
          'seatNumbers': seatNumbers,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final locks = (response['data']['locks'] as List<dynamic>)
            .map((lock) => SeatLockModel.fromJson({
                  ...lock as Map<String, dynamic>,
                  'busId': busId,
                }))
            .toList();
        return locks;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to lock seats');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to lock seats: ${e.toString()}');
    }
  }

  @override
  Future<void> unlockSeat(String busId, int seatNumber, String token) async {
    try {
      final response = await apiClient.post(
        ApiConstants.seatUnlock,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
          'seatNumber': seatNumber,
        },
      );

      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to unlock seat');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to unlock seat: ${e.toString()}');
    }
  }

  @override
  Future<List<SeatLockModel>> getBusLocks(String busId, String token) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.seatLockBus}/$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final locks = (response['data'] as List<dynamic>)
            .map((lock) => SeatLockModel.fromJson({
                  ...lock as Map<String, dynamic>,
                  'busId': busId,
                }))
            .toList();
        return locks;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get bus locks');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get bus locks: ${e.toString()}');
    }
  }

  @override
  Future<List<SeatLockModel>> getMyLocks(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.seatLockMyLocks,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final locks = (response['data'] as List<dynamic>)
            .map((lock) => SeatLockModel.fromJson(lock as Map<String, dynamic>))
            .toList();
        return locks;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get my locks');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get my locks: ${e.toString()}');
    }
  }
}

