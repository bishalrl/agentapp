import 'package:agentapp/features/counter_request/domain/usecases/get_counter_requests.dart';
import 'package:agentapp/features/counter_request/domain/usecases/request_bus_access.dart';
import 'package:agentapp/features/counter_request/domain/entities/counter_request_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';

import 'events/counter_request_event.dart';
import 'states/counter_request_state.dart';

class CounterRequestBloc extends Bloc<CounterRequestEvent, CounterRequestState> {
  final RequestBusAccess requestBusAccess;
  final GetCounterRequests getCounterRequests;

  CounterRequestBloc({
    required this.requestBusAccess,
    required this.getCounterRequests,
  }) : super(const CounterRequestState()) {
    on<RequestBusAccessEvent>(_onRequestBusAccess);
    on<GetCounterRequestsEvent>(_onGetCounterRequests);
  }

  Future<void> _onRequestBusAccess(
    RequestBusAccessEvent event,
    Emitter<CounterRequestState> emit,
  ) async {
    print('🔵 CounterRequestBloc._onRequestBusAccess called');
    print('   Event: busId=${event.busId}, requestedSeats=${event.requestedSeats}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await requestBusAccess(
      busId: event.busId,
      requestedSeats: event.requestedSeats,
      message: event.message,
    );

    if (result is Error<CounterRequestEntity>) {
      final failure = result.failure;
      print('   ❌ RequestBusAccess Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        errorFailure: failure,
      ));
    } else if (result is Success<CounterRequestEntity>) {
      final request = result.data;
      print('   ✅ RequestBusAccess Success');
      // Add to requests list and refresh
      final updatedRequests = [request, ...state.requests];
      emit(state.copyWith(
        requests: updatedRequests,
        isLoading: false,
        errorMessage: null,
        lastCreatedRequest: request,
      ));
      // Refresh requests list
      add(const GetCounterRequestsEvent());
    }
  }

  Future<void> _onGetCounterRequests(
    GetCounterRequestsEvent event,
    Emitter<CounterRequestState> emit,
  ) async {
    print('🔵 CounterRequestBloc._onGetCounterRequests called');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await getCounterRequests();

    if (result is Error<List<CounterRequestEntity>>) {
      final failure = result.failure;
      print('   ❌ GetCounterRequests Error: ${failure.message}');
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        errorFailure: failure,
      ));
    } else if (result is Success<List<CounterRequestEntity>>) {
      final requests = result.data;
      print('   ✅ GetCounterRequests Success: ${requests.length} requests');
      emit(state.copyWith(
        requests: requests,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }
}
