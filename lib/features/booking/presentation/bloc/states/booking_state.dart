import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../domain/entities/booking_entity.dart';

class BookingState extends BaseBlocState {
  final List<BusInfoEntity> buses;
  final BusInfoEntity? selectedBus;
  final List<BookingEntity> bookings;
  final BookingEntity? selectedBooking;
  final BookingEntity? createdBooking;
  final List<int> selectedSeats;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const BookingState({
    this.buses = const [],
    this.selectedBus,
    this.bookings = const [],
    this.selectedBooking,
    this.createdBooking,
    this.selectedSeats = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  BookingState copyWith({
    List<BusInfoEntity>? buses,
    BusInfoEntity? selectedBus,
    List<BookingEntity>? bookings,
    BookingEntity? selectedBooking,
    BookingEntity? createdBooking,
    List<int>? selectedSeats,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return BookingState(
      buses: buses ?? this.buses,
      selectedBus: selectedBus ?? this.selectedBus,
      bookings: bookings ?? this.bookings,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      createdBooking: createdBooking ?? this.createdBooking,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        buses,
        selectedBus,
        bookings,
        selectedBooking,
        createdBooking,
        selectedSeats,
        isLoading,
        errorMessage,
        successMessage,
      ];
}

