import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard(String token);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DashboardModel> getDashboard(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.counterDashboard,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return DashboardModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get dashboard');
      }
    } on ServerException {
      rethrow;
    } on NetworkException catch (e) {
      // Re-throw NetworkException as-is to preserve the error message
      rethrow;
    } on AuthenticationException {
      // Re-throw AuthenticationException as-is
      rethrow;
    } catch (e) {
      // For other exceptions, provide a meaningful error message
      final errorMessage = e is Exception && e.toString().contains('Exception')
          ? 'Failed to get dashboard: ${e.toString()}'
          : 'Failed to get dashboard: ${e.toString()}';
      throw ServerException(errorMessage);
    }
  }
}

