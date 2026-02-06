import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/usecases/forgot_password.dart';
import 'events/forgot_password_event.dart';
import 'states/forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPassword forgotPassword;

  ForgotPasswordBloc({
    required this.forgotPassword,
  }) : super(const ForgotPasswordState()) {
    on<ForgotPasswordRequestEvent>(_onForgotPassword);
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequestEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    print('🔵 ForgotPasswordBloc._onForgotPassword called');
    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));
    
    final result = await forgotPassword(event.email);

    if (result is Error<void>) {
      final failure = result.failure;
      print('   ❌ Forgot Password Error: ${failure.message}');
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isSuccess: false,
      ));
    } else if (result is Success<void>) {
      print('   ✅ Forgot Password Success');
      emit(state.copyWith(
        isSuccess: true,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }
}
