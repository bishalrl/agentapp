import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/lock_seat.dart';
import '../../domain/usecases/lock_multiple_seats.dart';
import '../../domain/usecases/unlock_seat.dart';
import '../../domain/usecases/get_bus_locks.dart';
import '../../domain/entities/seat_lock_entity.dart';
import 'events/seat_lock_event.dart';
import 'states/seat_lock_state.dart';

class SeatLockBloc extends Bloc<SeatLockEvent, SeatLockState> {
  final LockSeat lockSeat;
  final LockMultipleSeats lockMultipleSeats;
  final UnlockSeat unlockSeat;
  final GetBusLocks getBusLocks;

  SeatLockBloc({
    required this.lockSeat,
    required this.lockMultipleSeats,
    required this.unlockSeat,
    required this.getBusLocks,
  }) : super(const SeatLockState()) {
    on<LockSeatEvent>(_onLockSeat);
    on<LockMultipleSeatsEvent>(_onLockMultipleSeats);
    on<UnlockSeatEvent>(_onUnlockSeat);
    on<GetBusLocksEvent>(_onGetBusLocks);
  }

  Future<void> _onLockSeat(LockSeatEvent event, Emitter<SeatLockState> emit) async {
    print('🔵 SeatLockBloc._onLockSeat called');
    print('   Event: busId=${event.busId}, seat=${event.seatNumber}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await lockSeat(event.busId, event.seatNumber);

    if (result is Error<SeatLockEntity>) {
      print('   ❌ LockSeat Error: ${result.failure.message}');
      emit(state.copyWith(isLoading: false, errorMessage: result.failure.message));
    } else if (result is Success<SeatLockEntity>) {
      final newLock = result.data;
      print('   ✅ LockSeat Success: seat=${newLock.seatNumber} locked');
      emit(state.copyWith(
        busLocks: [...state.busLocks, newLock],
        isLoading: false,
        errorMessage: null,
      ));
      print('   State emitted: lock added, isLoading=false');
    }
  }

  Future<void> _onLockMultipleSeats(LockMultipleSeatsEvent event, Emitter<SeatLockState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await lockMultipleSeats(event.busId, event.seatNumbers);

    if (result is Error<List<SeatLockEntity>>) {
      emit(state.copyWith(isLoading: false, errorMessage: result.failure.message));
    } else if (result is Success<List<SeatLockEntity>>) {
      final newLocks = result.data;
      emit(state.copyWith(
        busLocks: [...state.busLocks, ...newLocks],
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onUnlockSeat(UnlockSeatEvent event, Emitter<SeatLockState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await unlockSeat(event.busId, event.seatNumber);

    if (result is Error) {
      emit(state.copyWith(isLoading: false, errorMessage: result.failure.message));
    } else if (result is Success) {
      emit(state.copyWith(
        busLocks: state.busLocks.where((lock) => lock.seatNumber != event.seatNumber).toList(),
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onGetBusLocks(GetBusLocksEvent event, Emitter<SeatLockState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await getBusLocks(event.busId);

    if (result is Error<List<SeatLockEntity>>) {
      emit(state.copyWith(isLoading: false, errorMessage: result.failure.message));
    } else if (result is Success<List<SeatLockEntity>>) {
      emit(state.copyWith(
        busLocks: result.data,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }
}
