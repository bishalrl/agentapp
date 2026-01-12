import '../../../domain/entities/offline_entity.dart';

abstract class OfflineState {}

class OfflineInitial extends OfflineState {}

class OfflineLoading extends OfflineState {}

class OfflineQueueLoaded extends OfflineState {
  final List<OfflineQueueItemEntity> queue;
  final int totalPending;

  OfflineQueueLoaded(this.queue, this.totalPending);
}

class AddedToOfflineQueue extends OfflineState {
  final OfflineQueueItemEntity item;

  AddedToOfflineQueue(this.item);
}

class OfflineBookingsSynced extends OfflineState {
  final OfflineSyncResultEntity result;

  OfflineBookingsSynced(this.result);
}

class OfflineError extends OfflineState {
  final String message;

  OfflineError(this.message);
}
