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
    required List<int> seatNumbers,
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
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
  Future<void> lockSeats(String busId, List<int> seatNumbers, String token);
  Future<void> unlockSeats(String busId, List<int> seatNumbers, String token);
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
      throw ServerException('Failed to get available buses: ${e.toString()}');
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
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Handle response format: data can have 'bus' key or be bus object directly
        final busData = data['bus'] ?? data;
        
        if (busData is! Map<String, dynamic>) {
          throw ServerException('Invalid bus data format in response');
        }
        
        print('   ✅ Parsing bus details');
        return BusInfoModel.fromJson(busData);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get bus details');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      print('   ❌ BookingRemoteDataSource.getBusDetails: Error: $e');
      throw ServerException('Failed to get bus details: ${e.toString()}');
    }
  }
  
  @override
  Future<BookingModel> createBooking({
    required String busId,
    required List<int> seatNumbers,
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
    required String token,
  }) async {
    try {
      print('📤 BookingRemoteDataSource.createBooking: Sending request');
      print('   BusId: $busId, Seats: $seatNumbers, Passenger: $passengerName');
      
      final body = <String, dynamic>{
        'busId': busId,
        'seatNumbers': seatNumbers,
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
        throw ServerException(response['message'] as String? ?? 'Failed to create booking');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to create booking: ${e.toString()}');
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
    } catch (e) {
      throw ServerException('Failed to get bookings: ${e.toString()}');
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
      throw ServerException('Failed to get booking details: ${e.toString()}');
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
      throw ServerException('Failed to cancel booking: ${e.toString()}');
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
      throw ServerException('Failed to cancel multiple bookings: ${e.toString()}');
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
      throw ServerException('Failed to update booking status: ${e.toString()}');
    }
  }
  
  @override
  Future<void> lockSeats(String busId, List<int> seatNumbers, String token) async {
    try {
      final response = await apiClient.post(
        seatNumbers.length == 1 ? ApiConstants.seatLock : ApiConstants.seatLockMultiple,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
          if (seatNumbers.length == 1) 'seatNumber': seatNumbers.first,
          if (seatNumbers.length > 1) 'seatNumbers': seatNumbers,
        },
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to lock seats');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to lock seats: ${e.toString()}');
    }
  }
  
  @override
  Future<void> unlockSeats(String busId, List<int> seatNumbers, String token) async {
    try {
      final response = await apiClient.post(
        ApiConstants.seatUnlock,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
          'seatNumber': seatNumbers.first, // API might need individual calls
        },
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to unlock seats');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to unlock seats: ${e.toString()}');
    }
  }
}

