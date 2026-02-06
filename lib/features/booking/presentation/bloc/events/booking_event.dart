import '../../../../../core/bloc/base_bloc_event.dart';

abstract class BookingEvent extends BaseBlocEvent {
  const BookingEvent();
}

class GetAvailableBusesEvent extends BookingEvent {
  final String? date;
  final String? route;
  final String? status;

  const GetAvailableBusesEvent({
    this.date,
    this.route,
    this.status,
  });

  @override
  List<Object?> get props => [date, route, status];
}

class CreateBookingEvent extends BookingEvent {
  final String busId;
  final List<dynamic> seatNumbers; // Supports both int (legacy) and String (new format)
  final String passengerName;
  final String contactNumber;
  final String? passengerEmail;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? luggage;
  final int? bagCount;
  final String paymentMethod;
  final String? holdId; // Optional wallet hold ID

  const CreateBookingEvent({
    required this.busId,
    required this.seatNumbers,
    required this.passengerName,
    required this.contactNumber,
    this.passengerEmail,
    this.pickupLocation,
    this.dropoffLocation,
    this.luggage,
    this.bagCount,
    required this.paymentMethod,
    this.holdId,
  });

  @override
  List<Object?> get props => [
        busId,
        seatNumbers,
        passengerName,
        contactNumber,
        passengerEmail,
        pickupLocation,
        dropoffLocation,
        luggage,
        bagCount,
        paymentMethod,
        holdId,
      ];
}

class CancelMultipleBookingsEvent extends BookingEvent {
  final List<String> bookingIds;

  const CancelMultipleBookingsEvent({required this.bookingIds});

  @override
  List<Object?> get props => [bookingIds];
}

class UpdateBookingStatusEvent extends BookingEvent {
  final String bookingId;
  final String status;

  const UpdateBookingStatusEvent({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object?> get props => [bookingId, status];
}

class GetBusDetailsEvent extends BookingEvent {
  final String busId;

  const GetBusDetailsEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class GetBookingsEvent extends BookingEvent {
  final String? date;
  final String? busId;
  final String? status;
  final String? paymentMethod;

  const GetBookingsEvent({
    this.date,
    this.busId,
    this.status,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [date, busId, status, paymentMethod];
}

class GetBookingDetailsEvent extends BookingEvent {
  final String bookingId;

  const GetBookingDetailsEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;

  const CancelBookingEvent({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class LockSeatsEvent extends BookingEvent {
  final String busId;
  final List<dynamic> seatNumbers; // Supports both int (legacy) and String (new format)

  const LockSeatsEvent({
    required this.busId,
    required this.seatNumbers,
  });

  @override
  List<Object?> get props => [busId, seatNumbers];
}

class UnlockSeatsEvent extends BookingEvent {
  final String busId;
  final List<dynamic> seatNumbers; // Supports both int (legacy) and String (new format)

  const UnlockSeatsEvent({
    required this.busId,
    required this.seatNumbers,
  });

  @override
  List<Object?> get props => [busId, seatNumbers];
}

