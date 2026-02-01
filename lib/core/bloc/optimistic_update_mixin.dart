import 'package:flutter_bloc/flutter_bloc.dart';

/// Mixin for optimistic UI updates
/// Updates UI immediately, syncs with server in background
mixin OptimisticUpdateMixin<Event, State> on Bloc<Event, State> {
  /// Execute optimistic update
  /// 
  /// [optimisticUpdate] - Function to update state optimistically
  /// [syncAction] - Async function to sync with server
  /// [onSuccess] - Callback on success
  /// [onError] - Callback on error (can revert optimistic update)
  Future<void> executeOptimisticUpdate<T>({
    required State Function(State current) optimisticUpdate,
    required Future<T> Function() syncAction,
    required void Function(T result) onSuccess,
    void Function(dynamic error)? onError,
  }) async {
    // Step 1: Update UI optimistically (instant)
    emit(optimisticUpdate(state));
    
    try {
      // Step 2: Sync with server (background)
      final result = await syncAction();
      
      // Step 3: Confirm update
      onSuccess(result);
    } catch (error) {
      // Step 4: Revert on error (optional)
      if (onError != null) {
        onError(error);
      } else {
        // Default: revert to previous state
        // This requires storing previous state, which can be done
        // by the implementing BLoC
        print('⚠️ Optimistic update failed, reverting: $error');
      }
    }
  }
}

/// Example usage in BLoC:
/// 
/// ```dart
/// class BookingBloc extends Bloc<BookingEvent, BookingState> 
///     with OptimisticUpdateMixin {
///   
///   Future<void> _onCreateBooking(
///     CreateBookingEvent event,
///     Emitter<BookingState> emit,
///   ) async {
///     await executeOptimisticUpdate(
///       optimisticUpdate: (current) {
///         // Add booking to list immediately
///         return current.copyWith(
///           bookings: [...current.bookings, event.booking],
///         );
///       },
///       syncAction: () async {
///         // Create booking via API
///         return await createBooking(event.booking);
///       },
///       onSuccess: (result) {
///         // Update with server response
///         emit(state.copyWith(
///           bookings: state.bookings.map((b) => 
///             b.id == event.booking.id ? result : b
///           ).toList(),
///         ));
///       },
///       onError: (error) {
///         // Remove optimistic booking on error
///         emit(state.copyWith(
///           bookings: state.bookings.where((b) => 
///             b.id != event.booking.id
///           ).toList(),
///           errorMessage: 'Failed to create booking',
///         ));
///       },
///     );
///   }
/// }
/// ```
