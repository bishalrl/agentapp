import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/route_model.dart';

abstract class RouteRemoteDataSource {
  Future<RouteModel> createRoute({
    required String from,
    required String to,
    double? distance,
    int? estimatedDuration,
    String? description,
    required String token,
  });
  
  Future<RouteModel> updateRoute({
    required String routeId,
    String? from,
    String? to,
    double? distance,
    int? estimatedDuration,
    String? description,
    required String token,
  });
  
  Future<void> deleteRoute(String routeId, String token);
  
  Future<List<RouteModel>> getRoutes({
    String? search,
    required String token,
  });
  
  Future<RouteModel> getRouteById(String routeId, String token);
}

class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  final ApiClient apiClient;

  RouteRemoteDataSourceImpl(this.apiClient);

  @override
  Future<RouteModel> createRoute({
    required String from,
    required String to,
    double? distance,
    int? estimatedDuration,
    String? description,
    required String token,
  }) async {
    try {
      print('📤 RouteRemoteDataSource.createRoute: Sending request');
      print('   Endpoint: ${ApiConstants.counterRouteCreate}');
      print('   From: $from, To: $to');
      
      final body = {
        'from': from,
        'to': to,
        if (distance != null) 'distance': distance,
        if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
        if (description != null && description.isNotEmpty) 'description': description,
      };
      
      final response = await apiClient.post(
        ApiConstants.counterRouteCreate,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 RouteRemoteDataSource.createRoute: Response received');
      print('   Response keys: ${response.keys}');
      
      if (response['success'] == true && response['data'] != null) {
        final routeData = response['data']['route'] ?? response['data'];
        return RouteModel.fromJson(routeData as Map<String, dynamic>);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to create route');
      }
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      print('   ❌ RouteRemoteDataSource.createRoute: Unexpected error');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      throw ServerException('Failed to create route: ${e.toString()}');
    }
  }

  @override
  Future<RouteModel> updateRoute({
    required String routeId,
    String? from,
    String? to,
    double? distance,
    int? estimatedDuration,
    String? description,
    required String token,
  }) async {
    try {
      print('📤 RouteRemoteDataSource.updateRoute: Sending request');
      print('   RouteId: $routeId');
      
      final body = <String, dynamic>{};
      if (from != null) body['from'] = from;
      if (to != null) body['to'] = to;
      if (distance != null) body['distance'] = distance;
      if (estimatedDuration != null) body['estimatedDuration'] = estimatedDuration;
      if (description != null) body['description'] = description;
      
      final response = await apiClient.put(
        '${ApiConstants.counterRouteUpdate}/$routeId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final routeData = response['data']['route'] ?? response['data'];
        return RouteModel.fromJson(routeData as Map<String, dynamic>);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to update route');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update route: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRoute(String routeId, String token) async {
    try {
      print('📤 RouteRemoteDataSource.deleteRoute: Sending request');
      print('   RouteId: $routeId');
      
      final response = await apiClient.delete(
        '${ApiConstants.counterRouteDelete}/$routeId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to delete route');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete route: ${e.toString()}');
    }
  }

  @override
  Future<List<RouteModel>> getRoutes({
    String? search,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final response = await apiClient.get(
        ApiConstants.counterRoutes,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );
      
      if (response['success'] == true) {
        if (response['data'] == null) {
          return [];
        }
        final data = response['data'];
        List<dynamic> routes;
        if (data is Map<String, dynamic>) {
          routes = data['routes'] as List<dynamic>? ?? [];
        } else if (data is List) {
          routes = data;
        } else {
          return [];
        }
        if (routes.isEmpty) {
          return [];
        }
        return routes.map((route) => RouteModel.fromJson(route as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get routes');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get routes: ${e.toString()}');
    }
  }

  @override
  Future<RouteModel> getRouteById(String routeId, String token) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.counterRoutes}/$routeId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        final routeData = response['data']['route'] ?? response['data'];
        return RouteModel.fromJson(routeData as Map<String, dynamic>);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get route');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get route: ${e.toString()}');
    }
  }
}

