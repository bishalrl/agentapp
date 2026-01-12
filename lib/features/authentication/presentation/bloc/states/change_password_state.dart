import '../../../../../core/bloc/base_bloc_state.dart';

class ChangePasswordState extends BaseBlocState {
  final bool isSuccess;
  final bool isLoading;
  final String? errorMessage;

  const ChangePasswordState({
    this.isSuccess = false,
    this.isLoading = false,
    this.errorMessage,
  });

  ChangePasswordState copyWith({
    bool? isSuccess,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChangePasswordState(
      isSuccess: isSuccess ?? this.isSuccess,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isSuccess, isLoading, errorMessage];
}

