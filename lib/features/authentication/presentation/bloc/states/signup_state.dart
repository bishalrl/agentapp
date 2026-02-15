import '../../../../../core/bloc/base_bloc_state.dart';

class SignupState extends BaseBlocState {
  final bool isSuccess;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isOtpSending;
  final bool isOtpSent;

  const SignupState({
    this.isSuccess = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isOtpSending = false,
    this.isOtpSent = false,
  });

  SignupState copyWith({
    bool? isSuccess,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isOtpSending,
    bool? isOtpSent,
  }) {
    return SignupState(
      isSuccess: isSuccess ?? this.isSuccess,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isOtpSending: isOtpSending ?? this.isOtpSending,
      isOtpSent: isOtpSent ?? this.isOtpSent,
    );
  }

  @override
  List<Object?> get props =>
      [isSuccess, isLoading, errorMessage, successMessage, isOtpSending, isOtpSent];
}

