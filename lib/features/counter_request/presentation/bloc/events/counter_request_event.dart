import '../../../../../core/bloc/base_bloc_event.dart';

abstract class CounterRequestEvent extends BaseBlocEvent {
  const CounterRequestEvent();
}

class RequestBusAccessEvent extends CounterRequestEvent {
  final String busId;
  final List<String> requestedSeats;
  final String? message;

  const RequestBusAccessEvent({
    required this.busId,
    required this.requestedSeats,
    this.message,
  });

  @override
  List<Object?> get props => [busId, requestedSeats, message];
}

class GetCounterRequestsEvent extends CounterRequestEvent {
  const GetCounterRequestsEvent();

  @override
  List<Object?> get props => [];
}
