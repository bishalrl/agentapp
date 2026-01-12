import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;
  
  BookingRepositoryImpl(this.remoteDataSource, {required this.getStoredToken});
  
  @override
  Future<Result<List<BusInfoEntity>>> getAvailableBuses({
    String? date,
    String? route,
    String? status,
  }) async {
    print('📦 BookingRepositoryImpl.getAvailableBuses: Starting');
    
    // Get token from storage
    print('   Getting stored token...');
    final tokenResult = await getStoredToken();
    
    String? token;
    if (tokenResult is Error<String?>) {
      print('   ❌ Failed to get token: ${tokenResult.failure.message}');
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      print('   ❌ Token is null or empty');
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    print('   ✅ Token retrieved, fetching available buses');
    
    try {
      final buses = await remoteDataSource.getAvailableBuses(
        date: date,
        route: route,
        status: status,
        token: token,
      );
      print('   ✅ Available buses retrieved successfully: ${buses.length} buses');
      return Success(buses);
    } on AuthenticationException catch (e) {
      print('   ❌ AuthenticationException: ${e.message}');
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      print('   ❌ NetworkException: ${e.message}');
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      print('   ❌ ServerException: ${e.message}');
      return Error(ServerFailure(e.message));
    } catch (e, stackTrace) {
      print('   ❌ Unexpected error: $e');
      print('   StackTrace: $stackTrace');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<BusInfoEntity>> getBusDetails(String busId) async {
    print('📦 BookingRepositoryImpl.getBusDetails: Starting');
    print('   BusId: $busId');
    
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      final bus = await remoteDataSource.getBusDetails(busId, token);
      return Success(bus);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<BookingEntity>> createBooking({
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
  }) async {
    print('📦 BookingRepositoryImpl.createBooking: Starting');
    
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      final booking = await remoteDataSource.createBooking(
        busId: busId,
        seatNumbers: seatNumbers,
        passengerName: passengerName,
        contactNumber: contactNumber,
        passengerEmail: passengerEmail,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        luggage: luggage,
        bagCount: bagCount,
        paymentMethod: paymentMethod,
        token: token,
      );
      return Success(booking);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<List<BookingEntity>>> getBookings({
    String? date,
    String? busId,
    String? status,
    String? paymentMethod,
  }) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      final bookings = await remoteDataSource.getBookings(
        date: date,
        busId: busId,
        status: status,
        paymentMethod: paymentMethod,
        token: token,
      );
      return Success(bookings);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<BookingEntity>> getBookingDetails(String bookingId) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      final booking = await remoteDataSource.getBookingDetails(bookingId, token);
      return Success(booking);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<BookingEntity>> cancelBooking(String bookingId) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      final booking = await remoteDataSource.cancelBooking(bookingId, token);
      return Success(booking);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> cancelMultipleBookings({
    required List<String> bookingIds,
  }) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final result = await remoteDataSource.cancelMultipleBookings(
        bookingIds: bookingIds,
        token: token,
      );
      return Success(result);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<BookingEntity>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final booking = await remoteDataSource.updateBookingStatus(
        bookingId: bookingId,
        status: status,
        token: token,
      );
      return Success(booking);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> lockSeats(String busId, List<int> seatNumbers) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      await remoteDataSource.lockSeats(busId, seatNumbers, token);
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> unlockSeats(String busId, List<int> seatNumbers) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }
    
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }
    
    try {
      await remoteDataSource.unlockSeats(busId, seatNumbers, token);
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

