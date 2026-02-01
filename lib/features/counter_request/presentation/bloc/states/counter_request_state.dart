import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/entities/counter_request_entity.dart';

class CounterRequestState extends BaseBlocState {
  final List<CounterRequestEntity> requests;
  final bool isLoading;
  final String? errorMessage;
  final Failure? errorFailure; // Store failure type for better error handling
  final CounterRequestEntity? lastCreatedRequest; // Last successfully created request

  const CounterRequestState({
    this.requests = const [],
    this.isLoading = false,
    this.errorMessage,
    this.errorFailure,
    this.lastCreatedRequest,
  });

  CounterRequestState copyWith({
    List<CounterRequestEntity>? requests,
    bool? isLoading,
    String? errorMessage,
    Failure? errorFailure,
    CounterRequestEntity? lastCreatedRequest,
  }) {
    return CounterRequestState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      errorFailure: errorFailure,
      lastCreatedRequest: lastCreatedRequest ?? this.lastCreatedRequest,
    );
  }

  @override
  List<Object?> get props => [requests, isLoading, errorMessage, errorFailure, lastCreatedRequest];
}
