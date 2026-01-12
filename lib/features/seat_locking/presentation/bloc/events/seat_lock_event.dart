import '../../../../../core/bloc/base_bloc_event.dart';

abstract class SeatLockEvent extends BaseBlocEvent {
  const SeatLockEvent();
}

class LockSeatEvent extends SeatLockEvent {
  final String busId;
  final int seatNumber;

  const LockSeatEvent({required this.busId, required this.seatNumber});

  @override
  List<Object?> get props => [busId, seatNumber];
}

class LockMultipleSeatsEvent extends SeatLockEvent {
  final String busId;
  final List<int> seatNumbers;

  const LockMultipleSeatsEvent({required this.busId, required this.seatNumbers});

  @override
  List<Object?> get props => [busId, seatNumbers];
}

class UnlockSeatEvent extends SeatLockEvent {
  final String busId;
  final int seatNumber;

  const UnlockSeatEvent({required this.busId, required this.seatNumber});

  @override
  List<Object?> get props => [busId, seatNumber];
}

class GetBusLocksEvent extends SeatLockEvent {
  final String busId;

  const GetBusLocksEvent(this.busId);

  @override
  List<Object?> get props => [busId];
}

