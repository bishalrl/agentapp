import 'package:agentapp/features/offline/presentation/bloc/events/offline_event.dart';
import 'package:agentapp/features/offline/presentation/bloc/states/offline_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/offline_entity.dart';
import '../../domain/usecases/get_offline_queue.dart';
import '../../domain/usecases/add_to_offline_queue.dart';
import '../../domain/usecases/sync_offline_bookings.dart';


class OfflineBloc extends Bloc<OfflineEvent, OfflineState> {
  final GetOfflineQueue getOfflineQueue;
  final AddToOfflineQueue addToOfflineQueue;
  final SyncOfflineBookings syncOfflineBookings;

  OfflineBloc({
    required this.getOfflineQueue,
    required this.addToOfflineQueue,
    required this.syncOfflineBookings,
  }) : super(OfflineInitial()) {
    on<GetOfflineQueueEvent>(_onGetOfflineQueue);
    on<AddToOfflineQueueEvent>(_onAddToOfflineQueue);
    on<SyncOfflineBookingsEvent>(_onSyncOfflineBookings);
  }

  Future<void> _onGetOfflineQueue(
    GetOfflineQueueEvent event,
    Emitter<OfflineState> emit,
  ) async {
    emit(OfflineLoading());
    final result = await getOfflineQueue();
    if (result is Error<List<OfflineQueueItemEntity>>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(OfflineError(errorMessage));
    } else if (result is Success<List<OfflineQueueItemEntity>>) {
      final queue = result.data;
      final totalPending = queue.where((q) => q.status == 'pending').length;
      emit(OfflineQueueLoaded(queue, totalPending));
    }
  }

  Future<void> _onAddToOfflineQueue(
    AddToOfflineQueueEvent event,
    Emitter<OfflineState> emit,
  ) async {
    emit(OfflineLoading());
    final result = await addToOfflineQueue(bookingData: event.bookingData);
    if (result is Error<OfflineQueueItemEntity>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(OfflineError(errorMessage));
    } else if (result is Success<OfflineQueueItemEntity>) {
      emit(AddedToOfflineQueue(result.data));
    }
  }

  Future<void> _onSyncOfflineBookings(
    SyncOfflineBookingsEvent event,
    Emitter<OfflineState> emit,
  ) async {
    emit(OfflineLoading());
    final result = await syncOfflineBookings();
    if (result is Error<OfflineSyncResultEntity>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(OfflineError(errorMessage));
    } else if (result is Success<OfflineSyncResultEntity>) {
      emit(OfflineBookingsSynced(result.data));
    }
  }
}
