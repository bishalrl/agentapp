import 'package:equatable/equatable.dart';

abstract class BaseBlocState extends Equatable {
  const BaseBlocState();

  @override
  List<Object?> get props => [];
}

class InitialState extends BaseBlocState {
  const InitialState();
}

class LoadingState extends BaseBlocState {
  const LoadingState();
}

class SuccessState<T> extends BaseBlocState {
  final T data;

  const SuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class ErrorState extends BaseBlocState {
  final String message;

  const ErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

