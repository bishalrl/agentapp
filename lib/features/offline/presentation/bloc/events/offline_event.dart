abstract class OfflineEvent {}

class GetOfflineQueueEvent extends OfflineEvent {}

class AddToOfflineQueueEvent extends OfflineEvent {
  final Map<String, dynamic> bookingData;

  AddToOfflineQueueEvent(this.bookingData);
}

class SyncOfflineBookingsEvent extends OfflineEvent {}
