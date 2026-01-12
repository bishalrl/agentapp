import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../domain/entities/seat_lock_entity.dart';

class SeatLockState extends BaseBlocState {
  final List<SeatLockEntity> busLocks;
  final bool isLoading;
  final String? errorMessage;

  const SeatLockState({
    this.busLocks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SeatLockState copyWith({
    List<SeatLockEntity>? busLocks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SeatLockState(
      busLocks: busLocks ?? this.busLocks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [busLocks, isLoading, errorMessage];
}

