import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<BusInfoModel>> getAvailableBuses({
    String? date,
    String? route,
    String? status,
    required String token,
  });
  Future<BusInfoModel> getBusDetails(String busId, String token);
  Future<BookingModel> createBooking({
    required String busId,
    required List<dynamic> seatNumbers, // Supports both int (legacy) and String (new format)
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
    String? holdId, // Optional wallet hold ID
    required String token,
  });
  Future<List<BookingModel>> getBookings({
    String? date,
    String? busId,
    String? status,
    String? paymentMethod,
    required String token,
  });
  Future<BookingModel> getBookingDetails(String bookingId, String token);
  Future<BookingModel> cancelBooking(String bookingId, String token);
  Future<Map<String, dynamic>> cancelMultipleBookings({
    required List<String> bookingIds,
    required String token,
  });
  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required String status,
    required String token,
  });
  Future<void> lockSeats(String busId, List<dynamic> seatNumbers, String token); // Supports both int and String
  Future<void> unlockSeats(String busId, List<dynamic> seatNumbers, String token); // Supports both int and String
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient apiClient;
  
  BookingRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<List<BusInfoModel>> getAvailableBuses({
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
        final data = response['data'] as Map<String, dynamic>?;
        if (data == null) {
          return [];
        }
        final buses = data['buses'];
        if (buses == null || buses is! List || buses.isEmpty) {
          return [];
        }
        return buses.map((bus) => BusInfoModel.fromJson(bus as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get buses');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }
  
  @override
  Future<BusInfoModel> getBusDetails(String busId, String token) async {
    try {
      print('📤 BookingRemoteDataSource.getBusDetails: Sending request');
      print('   BusId: $busId');
      
      final response = await apiClient.get(
        '${ApiConstants.counterBusDetails}/$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 BookingRemoteDataSource.getBusDetails: Response received');
      print('   Success: ${response['success']}');
      print('   Data keys: ${response['data'] is Map ? (response['data'] as Map).keys.toList() : 'N/A'}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        print('   Top-level data keys: ${data.keys.toList()}');
        // New response format: {bus: {...}, hasAccess: bool, allowedSeats: [...], ...}
        // Also supports old format: {bus: {...}} or bus object directly
        final busData = data['bus'] ?? data;
        
        if (busData is! Map<String, dynamic>) {
          throw ServerException('Invalid bus data format in response');
        }
        
        // Extract all access-related fields from top-level data object
        // These fields come from the API response but may not be in the bus object
        final hasAccess = data['hasAccess'] as bool?;
        final allowedSeats = data['allowedSeats'] as List<dynamic>?;
        final allowedSeatsCount = data['allowedSeatsCount'] as int?;
        final hasRestrictedAccess = data['hasRestrictedAccess'] as bool?;
        final requiresWallet = data['requiresWallet'] as bool?;
        final hasNoAccess = data['hasNoAccess'] as bool?;
        final availableAllowedSeats = data['availableAllowedSeats'] as List<dynamic>?;
        final availableAllowedSeatsCount = data['availableAllowedSeatsCount'] as int?;
        
        // Extract debug and message fields for troubleshooting
        final debug = data['debug'] as Map<String, dynamic>?;
        final message = data['message'] as String?;
        
        print('   ℹ️ Access Information:');
        print('      HasAccess: $hasAccess');
        print('      AllowedSeats: $allowedSeats');
        print('      HasRestrictedAccess: $hasRestrictedAccess');
        print('      RequiresWallet: $requiresWallet');
        print('      HasNoAccess: $hasNoAccess');
        print('      AvailableAllowedSeats: $availableAllowedSeats');
        if (message != null) {
          print('      Message: $message');
        }
        if (debug != null) {
          print('      Debug Info: $debug');
        }
        
        // Merge all access-related fields into busData so they get parsed into the model
        // Top-level data fields take precedence as they are the authoritative source from API
        final mergedBusData = <String, dynamic>{
          ...busData,
          // Override with top-level access fields if they exist (they are authoritative)
          if (hasAccess != null) 'hasAccess': hasAccess,
          if (allowedSeats != null) 'allowedSeats': allowedSeats,
          if (allowedSeatsCount != null) 'allowedSeatsCount': allowedSeatsCount,
          if (hasRestrictedAccess != null) 'hasRestrictedAccess': hasRestrictedAccess,
          if (requiresWallet != null) 'requiresWallet': requiresWallet,
          if (hasNoAccess != null) 'hasNoAccess': hasNoAccess,
          if (availableAllowedSeats != null) 'availableAllowedSeats': availableAllowedSeats,
          if (availableAllowedSeatsCount != null) 'availableAllowedSeatsCount': availableAllowedSeatsCount,
        };
        
        print('   ✅ Parsing bus details with merged access information');
        return BusInfoModel.fromJson(mergedBusData);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get bus details');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('   ❌ BookingRemoteDataSource.getBusDetails: Error: $e');
      throw ServerException('Request failed. Please try again.');
    }
  }
  
  @override
  Future<BookingModel> createBooking({
    required String busId,
    required List<dynamic> seatNumbers, // Supports both int (legacy) and String (new format)
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
    String? holdId, // Optional wallet hold ID
    required String token,
  }) async {
    try {
      print('📤 BookingRemoteDataSource.createBooking: Sending request');
      print('   BusId: $busId, Seats: $seatNumbers, Passenger: $passengerName');
      print('   Seat numbers (raw): $seatNumbers');
      
      // Normalize seat numbers: Convert numeric strings to numbers, keep non-numeric as strings
      // This matches backend normalization logic
      final seatNumbersForApi = seatNumbers.map((seat) {
        if (seat == null) return null;
        
        // If already a number, keep as number
        if (seat is int) {
          print('   Seat $seat: Already int');
          return seat;
        }
        
        // If string, try to parse as number
        if (seat is String) {
          final trimmed = seat.trim();
          if (trimmed.isEmpty) return null;
          
          // Try parsing as number
          final numValue = int.tryParse(trimmed);
          if (numValue != null && trimmed == numValue.toString()) {
            // It's a numeric string like "1", "2", "3" - convert to int
            print('   Seat "$seat": Converting to int $numValue');
            return numValue;
          } else {
            // Non-numeric string like "A1", "B2" - keep as string
            print('   Seat "$seat": Keeping as string');
            return trimmed;
          }
        }
        
        // For other types, convert to string
        final str = seat.toString().trim();
        if (str.isEmpty) return null;
        final numValue = int.tryParse(str);
        if (numValue != null && str == numValue.toString()) {
          return numValue;
        }
        return str;
      }).where((seat) => seat != null).toList();
      
      print('   Seat numbers (normalized): $seatNumbersForApi');
      
      final body = <String, dynamic>{
        'busId': busId,
        'seatNumbers': seatNumbersForApi,
        'passengerName': passengerName,
        'contactNumber': contactNumber,
        'paymentMethod': paymentMethod,
      };
      
      if (passengerEmail != null && passengerEmail.isNotEmpty) {
        body['passengerEmail'] = passengerEmail;
      }
      if (pickupLocation != null && pickupLocation.isNotEmpty) {
        body['pickupLocation'] = pickupLocation;
      }
      if (dropoffLocation != null && dropoffLocation.isNotEmpty) {
        body['dropoffLocation'] = dropoffLocation;
      }
      if (luggage != null && luggage.isNotEmpty) {
        body['luggage'] = luggage;
      }
      if (bagCount != null && bagCount > 0) {
        body['bagCount'] = bagCount;
      }
      if (holdId != null && holdId.isNotEmpty) {
        body['holdId'] = holdId;
      }
      
      final response = await apiClient.post(
        ApiConstants.counterBookings,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 BookingRemoteDataSource.createBooking: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Handle response format: data can have 'booking' key or be booking object directly
        final bookingData = data['booking'] ?? data;
        
        if (bookingData is! Map<String, dynamic>) {
          throw ServerException('Invalid booking data format in response');
        }
        
        print('   ✅ Parsing booking data');
        return BookingModel.fromJson(bookingData);
      } else {
        // Enhanced error handling for new backend error format with debug information
        final message = response['message'] as String? ?? 'Failed to create booking';
        final allowedSeats = response['allowedSeats'] as List<dynamic>?;
        final allowedSeatsAsStrings = response['allowedSeatsAsStrings'] as List<dynamic>?;
        final allowedSeatsAsNumbers = response['allowedSeatsAsNumbers'] as List<dynamic>?;
        final requestedSeats = response['requestedSeats'] as List<dynamic>?;
        final requestedSeatsNormalized = response['requestedSeatsNormalized'] as List<dynamic>?;
        final notAllowedSeats = response['notAllowedSeats'] as List<dynamic>?;
        final debug = response['debug'] as Map<String, dynamic>?;
        
        // Log debug information for troubleshooting
        print('❌ BookingRemoteDataSource.createBooking: Error response');
        print('   Message: $message');
        print('   Allowed Seats: $allowedSeats');
        print('   Allowed Seats (as strings): $allowedSeatsAsStrings');
        print('   Allowed Seats (as numbers): $allowedSeatsAsNumbers');
        print('   Requested Seats: $requestedSeats');
        print('   Requested Seats (normalized): $requestedSeatsNormalized');
        print('   Not Allowed Seats: $notAllowedSeats');
        if (debug != null) {
          print('   Debug Info: $debug');
        }
        
        // Build detailed error message
        String errorMessage = message;
        if (notAllowedSeats != null && notAllowedSeats.isNotEmpty) {
          final notAllowedStr = notAllowedSeats.map((s) => s.toString()).join(', ');
          if (allowedSeatsAsStrings != null && allowedSeatsAsStrings.isNotEmpty) {
            final allowedStr = allowedSeatsAsStrings.map((s) => s.toString()).join(', ');
            errorMessage = '$message\n\nNot allowed seats: $notAllowedStr\nAllowed seats: $allowedStr';
          } else {
            errorMessage = '$message\n\nNot allowed seats: $notAllowedStr';
          }
        } else if (allowedSeatsAsStrings != null && allowedSeatsAsStrings.isEmpty) {
          errorMessage = '$message\n\nYou do not have permission to book any seats on this bus.';
        }
        
        throw ServerException(errorMessage);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('❌ BookingRemoteDataSource.createBooking: Unexpected error: $e');
      throw ServerException('Request failed. Please try again.');
    }
  }
  
  @override
  Future<List<BookingModel>> getBookings({
    String? date,
    String? busId,
    String? status,
    String? paymentMethod,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;
      if (busId != null) queryParams['busId'] = busId;
      if (status != null) queryParams['status'] = status;
      if (paymentMethod != null) queryParams['paymentMethod'] = paymentMethod;
      
      final response = await apiClient.get(
        ApiConstants.counterBookings,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        queryParameters: queryParams,
      );
      
      print('📥 BookingRemoteDataSource.getBookings: Response received');
      print('   Success: ${response['success']}');
      print('   Response keys: ${response.keys}');
      
      if (response['success'] == true) {
        if (response['data'] == null) {
          print('   ⚠️ Response data is null, returning empty list');
          return [];
        }
        
        final data = response['data'];
        List<dynamic> bookings;
        
        // Handle different response formats:
        // Format 1: data is a List directly
        if (data is List) {
          print('   ℹ️ Response data is a list directly');
          bookings = data;
        }
        // Format 2: data is a Map with 'bookings' key
        else if (data is Map<String, dynamic>) {
          print('   ℹ️ Response data is a map, extracting bookings field');
          final bookingsField = data['bookings'];
          if (bookingsField == null) {
            print('   ⚠️ Bookings field is null, returning empty list');
            return [];
          }
          if (bookingsField is! List) {
            print('   ⚠️ Bookings field is not a list, returning empty list');
            return [];
          }
          bookings = bookingsField;
        }
        // Format 3: Unknown format
        else {
          print('   ⚠️ Response data is in unknown format: ${data.runtimeType}, returning empty list');
          return [];
        }
        
        if (bookings.isEmpty) {
          print('   ℹ️ Bookings list is empty');
          return [];
        }
        
        print('   ✅ Parsing ${bookings.length} bookings');
        final parsedBookings = <BookingModel>[];
        
        for (var i = 0; i < bookings.length; i++) {
          try {
            final booking = bookings[i];
            if (booking is! Map<String, dynamic>) {
              print('   ⚠️ Booking at index $i is not a Map, skipping');
              continue;
            }
            final parsedBooking = BookingModel.fromJson(booking);
            parsedBookings.add(parsedBooking);
          } catch (e, stackTrace) {
            print('   ❌ Failed to parse booking at index $i: $e');
            print('   StackTrace: $stackTrace');
            print('   Booking data: ${bookings[i]}');
            // Skip this booking and continue with others
            continue;
          }
        }
        
        print('   ✅ Successfully parsed ${parsedBookings.length} out of ${bookings.length} bookings');
        return parsedBookings;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get bookings');
      }
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      // Check if it's a network-related error
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('broken pipe') ||
          errorString.contains('connection closed') ||
          errorString.contains('connection') && errorString.contains('closed')) {
        throw NetworkException(
          'Network connection error. Please check your internet connection and try again.'
        );
      }
      throw ServerException('Request failed. Please try again.');
    }
  }
  
  @override
  Future<BookingModel> getBookingDetails(String bookingId, String token) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.counterBookings}/$bookingId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Handle response format: data can have 'booking' key or be booking object directly
        final bookingData = data['booking'] ?? data;
        
        if (bookingData is! Map<String, dynamic>) {
          throw ServerException('Invalid booking data format in response');
        }
        
        return BookingModel.fromJson(bookingData);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get booking details');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }
  
  @override
  Future<BookingModel> cancelBooking(String bookingId, String token) async {
    try {
      final response = await apiClient.put(
        '${ApiConstants.counterBookingCancel}/$bookingId/cancel',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(response['data']['booking'] as Map<String, dynamic>);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to cancel booking');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }

  @override
  Future<Map<String, dynamic>> cancelMultipleBookings({
    required List<String> bookingIds,
    required String token,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.counterBookingsCancelMultiple,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {'bookingIds': bookingIds},
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to cancel multiple bookings');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }

  @override
  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required String status,
    required String token,
  }) async {
    try {
      final response = await apiClient.patch(
        '${ApiConstants.counterBookingUpdateStatus}/$bookingId/status',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {'status': status},
      );

      if (response['success'] == true && response['data'] != null) {
        return BookingModel.fromJson(
            response['data']['booking'] as Map<String, dynamic>);
      } else {
        throw ServerException(
            response['message'] as String? ?? 'Failed to update booking status');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }
  
  @override
  Future<void> lockSeats(String busId, List<dynamic> seatNumbers, String token) async {
    try {
      // Normalize seat numbers: Convert numeric strings to numbers, keep non-numeric as strings
      final seatNumbersForApi = seatNumbers.map((seat) {
        if (seat == null) return null;
        if (seat is int) return seat;
        if (seat is num) return seat.toInt();
        if (seat is String) {
          final trimmed = seat.trim();
          if (trimmed.isEmpty) return null;
          final numValue = int.tryParse(trimmed);
          if (numValue != null && trimmed == numValue.toString()) {
            return numValue;
          }
          return trimmed;
        }
        final str = seat.toString().trim();
        if (str.isEmpty) return null;
        final numValue = int.tryParse(str);
        if (numValue != null && str == numValue.toString()) {
          return numValue;
        }
        return str;
      }).where((seat) => seat != null).toList();
      
      final response = await apiClient.post(
        seatNumbers.length == 1 ? ApiConstants.seatLock : ApiConstants.seatLockMultiple,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
          if (seatNumbers.length == 1) 'seatNumber': seatNumbersForApi.first,
          if (seatNumbers.length > 1) 'seatNumbers': seatNumbersForApi,
        },
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to lock seats');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }
  
  @override
  Future<void> unlockSeats(String busId, List<dynamic> seatNumbers, String token) async {
    try {
      // Normalize seat numbers: Convert numeric strings to numbers, keep non-numeric as strings
      final seatNumbersForApi = seatNumbers.map((seat) {
        if (seat == null) return null;
        if (seat is int) return seat;
        if (seat is num) return seat.toInt();
        if (seat is String) {
          final trimmed = seat.trim();
          if (trimmed.isEmpty) return null;
          final numValue = int.tryParse(trimmed);
          if (numValue != null && trimmed == numValue.toString()) {
            return numValue;
          }
          return trimmed;
        }
        final str = seat.toString().trim();
        if (str.isEmpty) return null;
        final numValue = int.tryParse(str);
        if (numValue != null && str == numValue.toString()) {
          return numValue;
        }
        return str;
      }).where((seat) => seat != null).toList();
      
      final response = await apiClient.post(
        ApiConstants.seatUnlock,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
          'seatNumber': seatNumbersForApi.first, // API might need individual calls
        },
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to unlock seats');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Request failed. Please try again.');
    }
  }
}

