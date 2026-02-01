import 'dart:convert';
import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/multipart_client.dart';
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
    String? timeFormat, // '12h' or '24h' (default: '12h')
    String? arrivalFormat, // '12h' or '24h' (default: '12h')
    String? tripDirection, // 'going' or 'returning' (default: 'going')
    required double price,
    required int totalSeats,
    String? busType,
    String? driverContact,
    String? driverEmail, // Driver email for invitation system
    String? driverName, // Driver name (required if driverEmail provided)
    String? driverLicenseNumber, // Driver license number (required if driverEmail provided)
    String? driverId, // Existing driver ID
    double? commissionRate,
    List<int>? allowedSeats,
    List<String>? seatConfiguration, // Custom seat identifiers (Nepal standard: A/B only, e.g., ["A1", "A4", "B6"])
    List<String>? amenities, // Bus amenities (e.g., ["WiFi", "AC", "TV"])
    List<Map<String, String>>? boardingPoints, // Boarding points with location and time
    List<Map<String, String>>? droppingPoints, // Dropping points with location and time
    String? routeId, // Route ID reference
    String? scheduleId, // Schedule ID reference
    double? distance, // Distance in kilometers
    int? estimatedDuration, // Estimated duration in minutes
    File? mainImage, // Main bus image file
    List<File>? galleryImages, // Gallery image files
    File? driverPhoto, // Driver photo file (optional)
    File? driverLicensePhoto, // Driver license photo file (optional)
    // Recurring Schedule Fields
    bool? isRecurring, // Enable recurring schedule
    List<int>? recurringDays, // Days of week [0=Sun, 6=Sat]
    DateTime? recurringStartDate, // Recurring start date
    DateTime? recurringEndDate, // Recurring end date
    String? recurringFrequency, // 'daily' | 'weekly' | 'monthly'
    // Auto-Activation Fields
    bool? autoActivate, // Enable date-based auto activation
    DateTime? activeFromDate, // Auto-activation start date
    DateTime? activeToDate, // Auto-activation end date
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
    String? driverEmail, // Driver email for invitation system
    String? driverName, // Driver name (required if driverEmail provided)
    String? driverLicenseNumber, // Driver license number (required if driverEmail provided)
    String? driverId, // Existing driver ID
    double? commissionRate,
    List<int>? allowedSeats,
    List<String>? seatConfiguration, // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
    List<String>? amenities, // Bus amenities (e.g., ["WiFi", "AC", "TV"])
    List<Map<String, String>>? boardingPoints, // Boarding points with location and time
    List<Map<String, String>>? droppingPoints, // Dropping points with location and time
    String? routeId, // Route ID reference
    String? scheduleId, // Schedule ID reference
    double? distance, // Distance in kilometers
    int? estimatedDuration, // Estimated duration in minutes
    File? mainImage, // Main bus image file
    List<File>? galleryImages, // Gallery image files
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

  Future<BusModel> searchBusByNumber({
    required String busNumber,
    required String token,
  });

  Future<BusModel> getBusDetails(String busId, String token);
  Future<BusModel> getMyBusDetails(String busId, String token);
  
  Future<BusModel> activateBus(String busId, String token);
  Future<BusModel> deactivateBus(String busId, String token);
}

class BusRemoteDataSourceImpl implements BusRemoteDataSource {
  final ApiClient apiClient;
  final MultipartClient multipartClient;

  BusRemoteDataSourceImpl(this.apiClient, this.multipartClient);

  @override
  Future<BusModel> createBus({
    required String name,
    required String vehicleNumber,
    required String from,
    required String to,
    required DateTime date,
    required String time,
    String? arrival,
    String? timeFormat, // '12h' or '24h' (default: '12h')
    String? arrivalFormat, // '12h' or '24h' (default: '12h')
    String? tripDirection, // 'going' or 'returning' (default: 'going')
    required double price,
    required int totalSeats,
    String? busType,
    String? driverContact,
    String? driverEmail, // Driver email for invitation system
    String? driverName, // Driver name (required if driverEmail provided)
    String? driverLicenseNumber, // Driver license number (required if driverEmail provided)
    String? driverId, // Existing driver ID
    double? commissionRate,
    List<int>? allowedSeats,
    List<String>? seatConfiguration, // Custom seat identifiers (Nepal standard: A/B only, e.g., ["A1", "A4", "B6"])
    List<String>? amenities, // Bus amenities (e.g., ["WiFi", "AC", "TV"])
    List<Map<String, String>>? boardingPoints, // Boarding points with location and time
    List<Map<String, String>>? droppingPoints, // Dropping points with location and time
    String? routeId, // Route ID reference
    String? scheduleId, // Schedule ID reference
    double? distance, // Distance in kilometers
    int? estimatedDuration, // Estimated duration in minutes
    File? mainImage, // Main bus image file
    List<File>? galleryImages, // Gallery image files
    File? driverPhoto, // Driver photo file (optional)
    File? driverLicensePhoto, // Driver license photo file (optional)
    // Recurring Schedule Fields
    bool? isRecurring, // Enable recurring schedule
    List<int>? recurringDays, // Days of week [0=Sun, 6=Sat]
    DateTime? recurringStartDate, // Recurring start date
    DateTime? recurringEndDate, // Recurring end date
    String? recurringFrequency, // 'daily' | 'weekly' | 'monthly'
    // Auto-Activation Fields
    bool? autoActivate, // Enable date-based auto activation
    DateTime? activeFromDate, // Auto-activation start date
    DateTime? activeToDate, // Auto-activation end date
    required String token,
  }) async {
    try {
      print('📤 BusRemoteDataSource.createBus: Sending multipart request');
      print('   Endpoint: ${ApiConstants.counterBusCreate}');
      print('   Name: $name, From: $from, To: $to, Date: $date');
      print('   Time: $time, Arrival: $arrival');
      print('   TimeFormat: $timeFormat, ArrivalFormat: $arrivalFormat');
      print('   TripDirection: $tripDirection');
      print('   SeatConfiguration: $seatConfiguration');
      print('   DriverEmail: $driverEmail, DriverName: $driverName');
      print('   IsRecurring: $isRecurring, AutoActivate: $autoActivate');
      
      // Prepare form fields (all as strings for multipart)
      final fields = <String, String>{
        'name': name,
        'vehicleNumber': vehicleNumber,
        'from': from,
        'to': to,
        'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'time': time,
        'price': price.toString(),
        'totalSeats': totalSeats.toString(),
      };
      
      // Required fields
      if (arrival != null) fields['arrival'] = arrival;
      if (busType != null) fields['busType'] = busType;
      
      // Time format fields
      if (timeFormat != null && timeFormat.isNotEmpty) {
        fields['timeFormat'] = timeFormat;
        print('   ✅ Added timeFormat: $timeFormat');
      }
      if (arrivalFormat != null && arrivalFormat.isNotEmpty) {
        fields['arrivalFormat'] = arrivalFormat;
        print('   ✅ Added arrivalFormat: $arrivalFormat');
      }
      
      // Trip direction
      if (tripDirection != null && tripDirection.isNotEmpty) {
        fields['tripDirection'] = tripDirection;
        print('   ✅ Added tripDirection: $tripDirection');
      }
      
      // Driver assignment (at least one required)
      // Note: When driverEmail is provided, it triggers invitation system
      // The driver will register later with invitation code, so licenseNumber is not required here
      if (driverContact != null && driverContact.isNotEmpty) {
        fields['driverContact'] = driverContact;
        print('   ✅ Added driverContact to fields: $driverContact');
      }
      if (driverId != null && driverId.isNotEmpty) {
        fields['driverId'] = driverId;
        print('   ✅ Added driverId to fields: $driverId');
      }
      if (driverEmail != null && driverEmail.isNotEmpty) {
        fields['driverEmail'] = driverEmail;
        print('   ✅ Added driverEmail to fields: $driverEmail');
        // driverName is required if driverEmail is provided
        if (driverName != null && driverName.isNotEmpty) {
          fields['driverName'] = driverName;
          print('   ✅ Added driverName to fields: $driverName');
        }
        // licenseNumber is REQUIRED if driverEmail is provided (backend validation)
        // Backend expects this field when driverEmail is provided
        if (driverLicenseNumber != null && driverLicenseNumber.isNotEmpty) {
          fields['licenseNumber'] = driverLicenseNumber.trim();
          print('   ✅ Added licenseNumber to fields: ${fields['licenseNumber']}');
        } else {
          print('   ❌ ERROR: driverEmail provided but licenseNumber is missing or empty!');
          print('   ⚠️ This will cause backend validation error');
        }
      }
      
      // Commission rate (required for admin, optional for counter)
      if (commissionRate != null) {
        fields['commissionRate'] = commissionRate.toString();
        print('   ✅ Added commissionRate to fields: $commissionRate');
      }
      
      // Seat configuration (optional - custom seat identifiers)
      if (seatConfiguration != null && seatConfiguration.isNotEmpty) {
        // Convert list to JSON string for multipart
        fields['seatConfiguration'] = jsonEncode(seatConfiguration);
        print('   ✅ Added seatConfiguration to fields: $seatConfiguration');
        print('   ✅ seatConfiguration as JSON string: ${jsonEncode(seatConfiguration)}');
      } else {
        print('   ℹ️ seatConfiguration not provided - will use sequential numbering');
      }
      
      // Allowed seats (optional)
      if (allowedSeats != null && allowedSeats.isNotEmpty) {
        // Convert list to JSON string for multipart
        fields['allowedSeats'] = jsonEncode(allowedSeats);
        print('   ✅ Added allowedSeats to fields: $allowedSeats');
      }
      
      // Amenities (optional - can be array or comma-separated string)
      if (amenities != null && amenities.isNotEmpty) {
        // Send as comma-separated string for multipart (backend can parse both)
        fields['amenities'] = amenities.join(',');
        print('   ✅ Added amenities to fields: ${amenities.join(',')}');
      }
      
      // Boarding points (optional - array of objects)
      if (boardingPoints != null && boardingPoints.isNotEmpty) {
        // Convert array of maps to JSON string for multipart
        fields['boardingPoints'] = jsonEncode(boardingPoints);
        print('   ✅ Added boardingPoints to fields: ${boardingPoints.length} points');
      }
      
      // Dropping points (optional - array of objects)
      if (droppingPoints != null && droppingPoints.isNotEmpty) {
        // Convert array of maps to JSON string for multipart
        fields['droppingPoints'] = jsonEncode(droppingPoints);
        print('   ✅ Added droppingPoints to fields: ${droppingPoints.length} points');
      }
      
      // Route and schedule references (optional)
      if (routeId != null && routeId.isNotEmpty) {
        fields['routeId'] = routeId;
        print('   ✅ Added routeId to fields: $routeId');
      }
      if (scheduleId != null && scheduleId.isNotEmpty) {
        fields['scheduleId'] = scheduleId;
        print('   ✅ Added scheduleId to fields: $scheduleId');
      }
      
      // Distance and duration (optional)
      if (distance != null) {
        fields['distance'] = distance.toString();
        print('   ✅ Added distance to fields: $distance km');
      }
      if (estimatedDuration != null) {
        fields['estimatedDuration'] = estimatedDuration.toString();
        print('   ✅ Added estimatedDuration to fields: $estimatedDuration minutes');
      }
      
      print('   📋 Final fields keys: ${fields.keys.toList()}');
      print('   📋 Final fields seatConfiguration: ${fields['seatConfiguration']}');
      // Debug: Verify licenseNumber is in fields when driverEmail is provided
      if (driverEmail != null && driverEmail.isNotEmpty) {
        if (fields.containsKey('licenseNumber')) {
          print('   ✅ VERIFIED: licenseNumber is in fields map: "${fields['licenseNumber']}"');
        } else {
          print('   ❌ ERROR: licenseNumber is MISSING from fields map even though driverEmail is provided!');
        }
      }
      
      // Prepare files for multipart
      final files = <String, File>{};
      if (mainImage != null) {
        files['mainImage'] = mainImage;
        print('   ✅ Added mainImage file: ${mainImage.path}');
      }
      // Note: Multiple gallery images need to be handled by MultipartClient
      // For now, we'll only send the first gallery image if provided
      // TODO: Update MultipartClient to support multiple files with same field name
      if (galleryImages != null && galleryImages.isNotEmpty) {
        // Send first image - backend may need multiple files with same name
        files['galleryImages'] = galleryImages[0];
        print('   ✅ Added galleryImage[0]: ${galleryImages[0].path}');
        if (galleryImages.length > 1) {
          print('   ⚠️ Note: Only first gallery image sent. ${galleryImages.length - 1} additional images not sent.');
          print('   ⚠️ TODO: Update MultipartClient to support multiple files with same field name');
        }
      }
      if (driverPhoto != null) {
        files['driverPhoto'] = driverPhoto;
        print('   ✅ Added driverPhoto file: ${driverPhoto.path}');
      }
      if (driverLicensePhoto != null) {
        files['driverLicensePhoto'] = driverLicensePhoto;
        print('   ✅ Added driverLicensePhoto file: ${driverLicensePhoto.path}');
      }
      
      final response = await multipartClient.postMultipart(
        endpoint: ApiConstants.counterBusCreate,
        fields: fields,
        files: files,
        token: token,
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
    String? driverEmail, // Driver email for invitation system
    String? driverName, // Driver name (required if driverEmail provided)
    String? driverLicenseNumber, // Driver license number (required if driverEmail provided)
    String? driverId, // Existing driver ID
    double? commissionRate,
    List<int>? allowedSeats,
    List<String>? seatConfiguration, // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
    List<String>? amenities, // Bus amenities (e.g., ["WiFi", "AC", "TV"])
    List<Map<String, String>>? boardingPoints, // Boarding points with location and time
    List<Map<String, String>>? droppingPoints, // Dropping points with location and time
    String? routeId, // Route ID reference
    String? scheduleId, // Schedule ID reference
    double? distance, // Distance in kilometers
    int? estimatedDuration, // Estimated duration in minutes
    File? mainImage, // Main bus image file
    List<File>? galleryImages, // Gallery image files
    required String token,
  }) async {
    try {
      print('📤 BusRemoteDataSource.updateBus: Sending multipart request');
      print('   BusId: $busId');
      print('   SeatConfiguration: $seatConfiguration');
      
      // Prepare form fields (all as strings for multipart)
      final fields = <String, String>{};
      if (name != null) fields['name'] = name;
      if (vehicleNumber != null) fields['vehicleNumber'] = vehicleNumber;
      if (from != null) fields['from'] = from;
      if (to != null) fields['to'] = to;
      if (date != null) fields['date'] = date.toIso8601String().split('T')[0];
      if (time != null) fields['time'] = time;
      if (arrival != null) fields['arrival'] = arrival;
      if (price != null) fields['price'] = price.toString();
      if (totalSeats != null) fields['totalSeats'] = totalSeats.toString();
      if (busType != null) fields['busType'] = busType;
      if (driverContact != null) fields['driverContact'] = driverContact;
      if (driverId != null) fields['driverId'] = driverId;
      if (driverEmail != null && driverEmail.isNotEmpty) {
        fields['driverEmail'] = driverEmail;
        if (driverName != null && driverName.isNotEmpty) {
          fields['driverName'] = driverName;
        }
        // licenseNumber is required if driverEmail is provided (backend validation)
        if (driverLicenseNumber != null && driverLicenseNumber.isNotEmpty) {
          fields['licenseNumber'] = driverLicenseNumber;
          print('   ✅ Added licenseNumber to fields: $driverLicenseNumber');
        }
      }
      if (commissionRate != null) fields['commissionRate'] = commissionRate.toString();
      if (allowedSeats != null && allowedSeats.isNotEmpty) {
        fields['allowedSeats'] = jsonEncode(allowedSeats);
      }
      if (seatConfiguration != null && seatConfiguration.isNotEmpty) {
        fields['seatConfiguration'] = jsonEncode(seatConfiguration);
      }
      if (amenities != null && amenities.isNotEmpty) {
        fields['amenities'] = amenities.join(',');
      }
      if (boardingPoints != null && boardingPoints.isNotEmpty) {
        fields['boardingPoints'] = jsonEncode(boardingPoints);
      }
      if (droppingPoints != null && droppingPoints.isNotEmpty) {
        fields['droppingPoints'] = jsonEncode(droppingPoints);
      }
      if (routeId != null) fields['routeId'] = routeId;
      if (scheduleId != null) fields['scheduleId'] = scheduleId;
      if (distance != null) fields['distance'] = distance.toString();
      if (estimatedDuration != null) fields['estimatedDuration'] = estimatedDuration.toString();
      
      // Prepare files for multipart
      final files = <String, File>{};
      if (mainImage != null) files['mainImage'] = mainImage;
      if (galleryImages != null && galleryImages.isNotEmpty) {
        files['galleryImages'] = galleryImages[0]; // TODO: Support multiple files
      }
      
      final response = await multipartClient.putMultipart(
        endpoint: '${ApiConstants.counterMyBusUpdate}/$busId',
        fields: fields,
        files: files,
        token: token,
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
        
        return buses.map((busItem) {
          // Handle assigned bus structure: {busId: {...}, accessId: "...", allowedSeats: [...]}
          if (busItem is! Map<String, dynamic>) {
            return BusModel.fromJson(busItem as Map<String, dynamic>);
          }
          
          // Extract bus data - could be in 'busId' or 'bus' key
          final busData = busItem['busId'] as Map<String, dynamic>? 
              ?? busItem['bus'] as Map<String, dynamic>?
              ?? busItem;
          
          // Merge accessId and allowedSeats from top level into bus data
          final mergedBusData = <String, dynamic>{
            ...busData,
            if (busItem['accessId'] != null) 'accessId': busItem['accessId'],
            if (busItem['allowedSeats'] != null) 'allowedSeats': busItem['allowedSeats'],
            if (busItem['commissionEarned'] != null) 'commissionEarned': busItem['commissionEarned'],
            if (busItem['totalBookings'] != null) 'totalBookings': busItem['totalBookings'],
          };
          
          return BusModel.fromJson(mergedBusData);
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
  Future<BusModel> searchBusByNumber({
    required String busNumber,
    required String token,
  }) async {
    try {
      print('📤 BusRemoteDataSource.searchBusByNumber: Sending request');
      print('   BusNumber: $busNumber');
      
      final response = await apiClient.get(
        ApiConstants.counterBusSearch,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: {
          'busNumber': busNumber,
        },
      );
      
      print('📥 BusRemoteDataSource.searchBusByNumber: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Response format: {success: true, data: {bus: {...}}}
        final busData = data['bus'] ?? data;
        
        if (busData is! Map<String, dynamic>) {
          throw ServerException('Invalid bus data format in response');
        }
        
        print('   ✅ Bus found: ${busData['name'] ?? busData['vehicleNumber']}');
        return BusModel.fromJson(busData);
      } else {
        throw ServerException(response['message'] as String? ?? 'Bus not found');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('   ❌ BusRemoteDataSource.searchBusByNumber: Error: $e');
      throw ServerException('Failed to search bus: ${e.toString()}');
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
        // New response format: {bus: {...}, hasAccess: bool, message?: string}
        // Also supports old format: {bus: {...}} or bus object directly
        final busData = data['bus'] ?? data;
        
        if (busData is! Map<String, dynamic>) {
          throw ServerException('Invalid bus data format in response');
        }
        
        // Extract hasAccess if present (for new format)
        final hasAccess = data['hasAccess'] as bool?;
        final accessMessage = data['message'] as String?;
        
        print('   ✅ Parsing bus data with ${busData.keys.length} fields');
        print('   HasAccess: $hasAccess');
        if (accessMessage != null) {
          print('   Message: $accessMessage');
        }
        
        // Merge hasAccess info into bus data if available
        final mergedBusData = <String, dynamic>{
          ...busData,
          // Store hasAccess in a way that can be accessed later if needed
          // For now, we'll use accessId presence to determine access
          // If hasAccess is false, ensure accessId is null
          if (hasAccess == false && busData['accessId'] == null) 
            'accessId': null,
        };
        
        return BusModel.fromJson(mergedBusData);
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

