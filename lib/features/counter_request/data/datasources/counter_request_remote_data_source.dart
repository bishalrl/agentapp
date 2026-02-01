import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/counter_request_model.dart';

abstract class CounterRequestRemoteDataSource {
  Future<CounterRequestModel> requestBusAccess({
    required String token,
    required String busId,
    required List<String> requestedSeats,
    String? message,
  });

  Future<List<CounterRequestModel>> getCounterRequests(String token);
}

class CounterRequestRemoteDataSourceImpl implements CounterRequestRemoteDataSource {
  final ApiClient apiClient;

  CounterRequestRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CounterRequestModel> requestBusAccess({
    required String token,
    required String busId,
    required List<String> requestedSeats,
    String? message,
  }) async {
    try {
      print('📤 CounterRequestRemoteDataSource.requestBusAccess: Sending request');
      print('   BusId: $busId');
      print('   RequestedSeats: $requestedSeats');
      
      final response = await apiClient.post(
        ApiConstants.counterRequestBusAccess,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
          'requestedSeats': requestedSeats,
          if (message != null && message.isNotEmpty) 'message': message,
        },
      );
      
      print('📥 CounterRequestRemoteDataSource.requestBusAccess: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return CounterRequestModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        // Sanitize error message to prevent exposing sensitive server data
        final errorMessage = response['message'] as String?;
        final sanitizedMessage = _sanitizeErrorMessage(errorMessage ?? 'Failed to request bus access');
        throw ServerException(sanitizedMessage);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      // Sanitize error message to prevent exposing stack traces or internal details
      final sanitizedMessage = _sanitizeErrorMessage('Failed to request bus access');
      throw ServerException(sanitizedMessage);
    }
  }

  @override
  Future<List<CounterRequestModel>> getCounterRequests(String token) async {
    try {
      print('📤 CounterRequestRemoteDataSource.getCounterRequests: Sending request');
      
      final response = await apiClient.get(
        ApiConstants.counterRequests,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 CounterRequestRemoteDataSource.getCounterRequests: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as List<dynamic>;
        return data.map((item) => CounterRequestModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        // Sanitize error message to prevent exposing sensitive server data
        final errorMessage = response['message'] as String?;
        final sanitizedMessage = _sanitizeErrorMessage(errorMessage ?? 'Failed to get counter requests');
        throw ServerException(sanitizedMessage);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      // Sanitize error message to prevent exposing stack traces or internal details
      final sanitizedMessage = _sanitizeErrorMessage('Failed to get counter requests');
      throw ServerException(sanitizedMessage);
    }
  }

  /// Sanitizes error messages to prevent exposing sensitive server information
  String _sanitizeErrorMessage(String? message) {
    if (message == null || message.isEmpty) {
      return 'An error occurred. Please try again later.';
    }

    // Remove potential stack traces or internal error details
    final lines = message.split('\n');
    final firstLine = lines.first.trim();

    // Check for common patterns that might expose sensitive data
    if (firstLine.toLowerCase().contains('stack trace') ||
        firstLine.toLowerCase().contains('at ') ||
        firstLine.toLowerCase().contains('exception:') ||
        firstLine.toLowerCase().contains('error:')) {
      // If it looks like a stack trace or internal error, return generic message
      return 'An error occurred. Please try again later.';
    }

    // Limit message length to prevent exposing too much information
    if (firstLine.length > 200) {
      return '${firstLine.substring(0, 197)}...';
    }

    return firstLine;
  }
}
