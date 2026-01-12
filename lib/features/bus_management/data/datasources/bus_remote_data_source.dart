import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/bus_model.dart';

abstract class BusRemoteDataSource {
  Future<BusModel> createBus({
    required String name,
    required String vehicleNumber,
    required String from,
    required String to,
    required DateTime date,
    required String time,
    String? arrival,
    required double price,
    required int totalSeats,
    String? busType,
    String? driverContact,
    double? commissionRate,
    List<int>? allowedSeats,
    required String token,
  });
  
  Future<BusModel> updateBus({
    required String busId,
    String? name,
    String? vehicleNumber,
    String? from,
    String? to,
    DateTime? date,
    String? time,
    String? arrival,
    double? price,
    int? totalSeats,
    String? busType,
    String? driverContact,
    double? commissionRate,
    List<int>? allowedSeats,
    required String token,
  });
  
  Future<void> deleteBus(String busId, String token);
  
  Future<List<BusModel>> getMyBuses({
    String? date,
    String? route,
    String? status,
    required String token,
  });

  Future<List<BusModel>> getAssignedBuses({
    String? date,
    String? from,
    String? to,
    required String token,
  });

  Future<BusModel> getBusDetails(String busId, String token);
  Future<BusModel> getMyBusDetails(String busId, String token);
  
  Future<BusModel> activateBus(String busId, String token);
  Future<BusModel> deactivateBus(String busId, String token);
}

class BusRemoteDataSourceImpl implements BusRemoteDataSource {
  final ApiClient apiClient;

  BusRemoteDataSourceImpl(this.apiClient);

  @override
  Future<BusModel> createBus({
    required String name,
    required String vehicleNumber,
    required String from,
    required String to,
    required DateTime date,
    required String time,
    String? arrival,
    required double price,
    required int totalSeats,
    String? busType,
    String? driverContact,
    double? commissionRate,
    List<int>? allowedSeats,
    required String token,
  }) async {
    try {
      print('📤 BusRemoteDataSource.createBus: Sending request');
      print('   Endpoint: ${ApiConstants.counterBusCreate}');
      print('   Name: $name, From: $from, To: $to, Date: $date');
      
      final body = {
        'name': name,
        'vehicleNumber': vehicleNumber,
        'from': from,
        'to': to,
        'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'time': time,
        'price': price,
        'totalSeats': totalSeats,
        if (arrival != null) 'arrival': arrival,
        if (busType != null) 'busType': busType,
        if (driverContact != null) 'driverContact': driverContact,
        if (commissionRate != null) 'commissionRate': commissionRate,
        if (allowedSeats != null && allowedSeats.isNotEmpty) 'allowedSeats': allowedSeats,
      };
      
      final response = await apiClient.post(
        ApiConstants.counterBusCreate,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 BusRemoteDataSource.createBus: Response received');
      print('   Response keys: ${response.keys}');
      print('   Success: ${response['success']}');
      print('   Data type: ${response['data']?.runtimeType}');
      
      if (response['success'] == true && response['data'] != null) {
        // Handle response format: data can be bus object directly or wrapped in 'bus' key
        final data = response['data'];
        final busData = data is Map<String, dynamic> && data.containsKey('bus')
            ? data['bus'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        
        print('   ✅ Parsing bus data with ${busData.keys.length} fields');
        return BusModel.fromJson(busData);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to create bus');
      }
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      print('   ❌ BusRemoteDataSource.createBus: Unexpected error');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      throw ServerException('Failed to create bus: ${e.toString()}');
    }
  }

  @override
  Future<BusModel> updateBus({
    required String busId,
    String? name,
    String? vehicleNumber,
    String? from,
    String? to,
    DateTime? date,
    String? time,
    String? arrival,
    double? price,
    int? totalSeats,
    String? busType,
    String? driverContact,
    double? commissionRate,
    List<int>? allowedSeats,
    required String token,
  }) async {
    try {
      print('📤 BusRemoteDataSource.updateBus: Sending request');
      print('   BusId: $busId');
      
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (vehicleNumber != null) body['vehicleNumber'] = vehicleNumber;
      if (from != null) body['from'] = from;
      if (to != null) body['to'] = to;
      if (date != null) body['date'] = date.toIso8601String().split('T')[0];
      if (time != null) body['time'] = time;
      if (arrival != null) body['arrival'] = arrival;
      if (price != null) body['price'] = price;
      if (totalSeats != null) body['totalSeats'] = totalSeats;
      if (busType != null) body['busType'] = busType;
      if (driverContact != null) body['driverContact'] = driverContact;
      if (commissionRate != null) body['commissionRate'] = commissionRate;
      if (allowedSeats != null) body['allowedSeats'] = allowedSeats;
      
      final response = await apiClient.put(
        '${ApiConstants.counterMyBusUpdate}/$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 BusRemoteDataSource.updateBus: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Handle response format: data can be bus object directly or wrapped in 'bus' key
        final busData = data.containsKey('bus')
            ? data['bus'] as Map<String, dynamic>
            : data;
        
        print('   ✅ Parsing updated bus data');
        return BusModel.fromJson(busData);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to update bus');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update bus: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBus(String busId, String token) async {
    try {
      print('📤 BusRemoteDataSource.deleteBus: Sending request');
      print('   BusId: $busId');
      
      final response = await apiClient.delete(
        '${ApiConstants.counterMyBusDelete}/$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to delete bus');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to delete bus: ${e.toString()}');
    }
  }

  @override
  Future<List<BusModel>> getMyBuses({
    String? date,
    String? route,
    String? status,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (route != null) queryParams['route'] = route;
      if (status != null) queryParams['status'] = status;
      
      final response = await apiClient.get(
        ApiConstants.counterMyBuses,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );
      
      if (response['success'] == true) {
        // Handle null or empty data - return empty list instead of throwing error
        if (response['data'] == null) {
          print('   ⚠️ Response data is null, returning empty list');
          return [];
        }
        
        final data = response['data'];
        List<dynamic> buses;
        
        // Handle different response formats:
        // Format 1: data is a List directly
        if (data is List) {
          print('   ℹ️ Response data is a list directly');
          buses = data;
        }
        // Format 2: data is a Map with 'buses' key
        else if (data is Map<String, dynamic>) {
          print('   ℹ️ Response data is a map, extracting buses field');
          final busesField = data['buses'];
          if (busesField == null) {
            print('   ⚠️ Buses field is null, returning empty list');
            return [];
          }
          if (busesField is! List) {
            print('   ⚠️ Buses field is not a list, returning empty list');
            return [];
          }
          buses = busesField;
        }
        // Format 3: Unknown format
        else {
          print('   ⚠️ Response data is in unknown format: ${data.runtimeType}, returning empty list');
          return [];
        }
        
        if (buses.isEmpty) {
          print('   ℹ️ Buses list is empty');
          return [];
        }
        
        return buses.map((bus) => BusModel.fromJson(bus as Map<String, dynamic>)).toList();
      } else {
        // Only throw error if success is explicitly false
        final errorMsg = response['message'] as String? ?? 'Failed to fetch bus details. Please try again later or contact support.';
        throw ServerException(errorMsg);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get buses: ${e.toString()}');
    }
  }

  @override
  Future<List<BusModel>> getAssignedBuses({
    String? date,
    String? from,
    String? to,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      
      final response = await apiClient.get(
        ApiConstants.counterBuses,
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
        List<dynamic> buses;
        
        // Handle different response formats:
        // Format 1: data is a List directly
        if (data is List) {
          buses = data;
        }
        // Format 2: data is a Map with 'buses' key
        else if (data is Map<String, dynamic>) {
          final busesField = data['buses'];
          if (busesField == null || busesField is! List) {
            return [];
          }
          buses = busesField;
        }
        // Format 3: Unknown format
        else {
          return [];
        }
        
        if (buses.isEmpty) {
          return [];
        }
        
        return buses.map((bus) {
          // Handle assigned bus structure which may have busId and bus nested
          final busData = bus is Map<String, dynamic> ? (bus['bus'] ?? bus) : bus;
          return BusModel.fromJson(busData as Map<String, dynamic>);
        }).toList();
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get assigned buses');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get assigned buses: ${e.toString()}');
    }
  }

  @override
  Future<BusModel> getBusDetails(String busId, String token) async {
    try {
      // GET /buses/:busId - Get assigned bus details
      // Response format: {success: true, data: {bus: {...}, access: {...}, bookedSeats: [...], ...}}
      print('📤 BusRemoteDataSource.getBusDetails: Sending request');
      print('   BusId: $busId');
      print('   Endpoint: ${ApiConstants.counterBusDetails}/$busId');
      
      final response = await apiClient.get(
        '${ApiConstants.counterBusDetails}/$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 BusRemoteDataSource.getBusDetails: Response received');
      print('   Success: ${response['success']}');
      print('   Data keys: ${response['data'] is Map ? (response['data'] as Map).keys : 'N/A'}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Assigned bus response has 'bus' key with the bus object
        final busData = data['bus'] ?? data;
        
        if (busData is! Map<String, dynamic>) {
          throw ServerException('Invalid bus data format in response');
        }
        
        print('   ✅ Parsing assigned bus data with ${busData.keys.length} fields');
        return BusModel.fromJson(busData);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get bus details');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('   ❌ BusRemoteDataSource.getBusDetails: Error: $e');
      throw ServerException('Failed to get bus details: ${e.toString()}');
    }
  }

  @override
  Future<BusModel> getMyBusDetails(String busId, String token) async {
    try {
      // GET /buses/my-buses/:busId - Get my bus details
      // Response format: {success: true, data: {_id, name, ..., filledSeats, availableSeats, ...}}
      // Data is the bus object directly (not wrapped in 'bus' key)
      print('📤 BusRemoteDataSource.getMyBusDetails: Sending request');
      print('   BusId: $busId');
      print('   Endpoint: ${ApiConstants.counterMyBusDetails}/$busId');
      
      final response = await apiClient.get(
        '${ApiConstants.counterMyBusDetails}/$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 BusRemoteDataSource.getMyBusDetails: Response received');
      print('   Success: ${response['success']}');
      print('   Data type: ${response['data']?.runtimeType}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        // My bus response has bus object directly in data (not wrapped in 'bus' key)
        final busData = data is Map<String, dynamic> && data.containsKey('bus')
            ? data['bus'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        
        if (busData is! Map<String, dynamic>) {
          throw ServerException('Invalid bus data format in response');
        }
        
        print('   ✅ Parsing my bus data with ${busData.keys.length} fields');
        print('   Bus fields: ${busData.keys.take(10).join(', ')}...');
        return BusModel.fromJson(busData);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get my bus details');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('   ❌ BusRemoteDataSource.getMyBusDetails: Error: $e');
      throw ServerException('Failed to get my bus details: ${e.toString()}');
    }
  }
  
  @override
  Future<BusModel> activateBus(String busId, String token) async {
    try {
      print('📤 BusRemoteDataSource.activateBus: Activating bus $busId');
      
      final response = await apiClient.patch(
        '${ApiConstants.counterBuses}/my-buses/$busId/activate',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 BusRemoteDataSource.activateBus: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        print('   ✅ Parsing bus data');
        return BusModel.fromJson(data);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to activate bus');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('   ❌ BusRemoteDataSource.activateBus: Error: $e');
      throw ServerException('Failed to activate bus: ${e.toString()}');
    }
  }
  
  @override
  Future<BusModel> deactivateBus(String busId, String token) async {
    try {
      print('📤 BusRemoteDataSource.deactivateBus: Deactivating bus $busId');
      
      final response = await apiClient.patch(
        '${ApiConstants.counterBuses}/my-buses/$busId/deactivate',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 BusRemoteDataSource.deactivateBus: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        print('   ✅ Parsing bus data');
        return BusModel.fromJson(data);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to deactivate bus');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('   ❌ BusRemoteDataSource.deactivateBus: Error: $e');
      throw ServerException('Failed to deactivate bus: ${e.toString()}');
    }
  }
}

