import '../../../../../core/bloc/base_bloc_state.dart';

class SignupState extends BaseBlocState {
  final bool isSuccess;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const SignupState({
    this.isSuccess = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  SignupState copyWith({
    bool? isSuccess,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return SignupState(
      isSuccess: isSuccess ?? this.isSuccess,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [isSuccess, isLoading, errorMessage, successMessage];
}

