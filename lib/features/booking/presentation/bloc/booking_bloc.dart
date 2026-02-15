import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_available_buses.dart';
import '../../domain/usecases/get_bus_details.dart';
import '../../domain/usecases/get_bookings.dart';
import '../../domain/usecases/get_booking_details.dart';
import '../../domain/usecases/cancel_booking.dart';
import '../../domain/usecases/cancel_multiple_bookings.dart';
import '../../domain/usecases/update_booking_status.dart';
import '../../domain/usecases/lock_seats.dart';
import '../../domain/usecases/unlock_seats.dart';
import '../../../wallet/domain/usecases/release_wallet_hold.dart';
import 'events/booking_event.dart';
import 'states/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetAvailableBuses getBuses;
  final GetBusDetails getBusDetails;
  final GetBookings getBookings;
  final GetBookingDetails getBookingDetails;
  final CreateBooking createBooking;
  final CancelBooking cancelBooking;
  final CancelMultipleBookings cancelMultipleBookings;
  final UpdateBookingStatus updateBookingStatus;
  final LockSeats lockSeats;
  final UnlockSeats unlockSeats;
  final ReleaseWalletHold releaseWalletHold;

  BookingBloc({
    required this.getBuses,
    required this.getBusDetails,
    required this.getBookings,
    required this.getBookingDetails,
    required this.createBooking,
    required this.cancelBooking,
    required this.cancelMultipleBookings,
    required this.updateBookingStatus,
    required this.lockSeats,
    required this.unlockSeats,
    required this.releaseWalletHold,
  }) : super(const BookingState()) {
    on<GetAvailableBusesEvent>(_onGetBuses);
    on<GetBusDetailsEvent>(_onGetBusDetails);
    on<GetBookingsEvent>(_onGetBookings);
    on<GetBookingDetailsEvent>(_onGetBookingDetails);
    on<CreateBookingEvent>(_onCreateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
    on<CancelMultipleBookingsEvent>(_onCancelMultipleBookings);
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
    on<LockSeatsEvent>(_onLockSeats);
    on<UnlockSeatsEvent>(_onUnlockSeats);
  }

  Future<void> _onGetBuses(
    GetAvailableBusesEvent event,
    Emitter<BookingState> emit,
  ) async {
    print('🔵 BookingBloc._onGetBuses called');
    print('   Event: date=${event.date}, route=${event.route}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await getBuses(
      date: event.date,
      route: event.route,
      status: event.status,
    );

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ GetBuses Error: ${failure.message}');
      print('   Failure type: ${failure.runtimeType}');
      
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } else if (result is Success) {
      final buses = (result as Success).data;
      print('   ✅ GetBuses Success: ${buses.length} buses found');
      emit(state.copyWith(
        buses: buses,
        isLoading: false,
        errorMessage: null,
      ));
      print('   State emitted: buses=${buses.length}, isLoading=false');
    }
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    print('🔵 BookingBloc._onCreateBooking called');
    print('   Event: busId=${event.busId}, seats=${event.seatNumbers}, passenger=${event.passengerName}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await createBooking(
      busId: event.busId,
      seatNumbers: event.seatNumbers,
      passengerName: event.passengerName,
      contactNumber: event.contactNumber,
      passengerEmail: event.passengerEmail,
      pickupLocation: event.pickupLocation,
      dropoffLocation: event.dropoffLocation,
      luggage: event.luggage,
      bagCount: event.bagCount,
      paymentMethod: event.paymentMethod,
      holdId: event.holdId,
    );

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ CreateBooking Error: ${failure.message}');
      print('   Failure type: ${failure.runtimeType}');

      // Release wallet hold so the amount is not left held when booking fails
      if (event.holdId != null && event.holdId!.isNotEmpty) {
        try {
          final releaseResult = await releaseWalletHold(holdId: event.holdId!);
          if (releaseResult is Success) {
            print('   🔓 Wallet hold released after booking failure: ${event.holdId}');
          }
        } catch (_) {
          print('   ⚠️ Could not release wallet hold (backend may auto-release): ${event.holdId}');
        }
      }

      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);

      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } else if (result is Success) {
      final booking = (result as Success).data;
      print('   ✅ CreateBooking Success: bookingId=${booking.id}');
      emit(state.copyWith(
        createdBooking: booking,
        isLoading: false,
        errorMessage: null,
      ));
      print('   State emitted: booking created, isLoading=false');
    }
  }

  Future<void> _onCancelMultipleBookings(
    CancelMultipleBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await cancelMultipleBookings(bookingIds: event.bookingIds);
    if (result is Error<Map<String, dynamic>>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<Map<String, dynamic>>) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        successMessage: 'Bookings cancelled successfully',
      ));
    }
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatusEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await updateBookingStatus(
      bookingId: event.bookingId,
      status: event.status,
    );
    if (result is Error<BookingEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<BookingEntity>) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        successMessage: 'Booking status updated successfully',
      ));
    }
  }

  Future<void> _onGetBusDetails(
    GetBusDetailsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await getBusDetails(event.busId);
    if (result is Error<BusInfoEntity>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<BusInfoEntity>) {
      emit(state.copyWith(
        selectedBus: result.data,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onGetBookings(
    GetBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await getBookings(
      date: event.date,
      busId: event.busId,
      status: event.status,
      paymentMethod: event.paymentMethod,
    );
    if (result is Error<List<BookingEntity>>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<List<BookingEntity>>) {
      emit(state.copyWith(
        bookings: result.data,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onGetBookingDetails(
    GetBookingDetailsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await getBookingDetails(event.bookingId);
    if (result is Error<BookingEntity>) {
      final failure = result.failure;
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<BookingEntity>) {
      emit(state.copyWith(
        selectedBooking: result.data,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await cancelBooking(event.bookingId);
    if (result is Error<BookingEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<BookingEntity>) {
      // Remove from bookings list
      final updatedBookings = state.bookings.where((b) => b.id != event.bookingId).toList();
      emit(state.copyWith(
        bookings: updatedBookings,
        isLoading: false,
        errorMessage: null,
        successMessage: 'Booking cancelled successfully',
      ));
    }
  }

  Future<void> _onLockSeats(
    LockSeatsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await lockSeats(
      busId: event.busId,
      seatNumbers: event.seatNumbers,
    );
    if (result is Error<void>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<void>) {
      // Refresh bus details to get updated seat locks
      add(GetBusDetailsEvent(busId: event.busId));
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        successMessage: 'Seats locked successfully',
      ));
    }
  }

  Future<void> _onUnlockSeats(
    UnlockSeatsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await unlockSeats(
      busId: event.busId,
      seatNumbers: event.seatNumbers,
    );
    if (result is Error<void>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
    } else if (result is Success<void>) {
      // Refresh bus details to get updated seat locks
      add(GetBusDetailsEvent(busId: event.busId));
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        successMessage: 'Seats unlocked successfully',
      ));
    }
  }
}
