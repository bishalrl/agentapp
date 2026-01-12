import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/reset_password.dart';
import 'events/reset_password_event.dart';
import 'states/reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ResetPassword resetPassword;

  ResetPasswordBloc({
    required this.resetPassword,
  }) : super(const ResetPasswordState()) {
    on<ResetPasswordRequestEvent>(_onResetPassword);
  }

  Future<void> _onResetPassword(
    ResetPasswordRequestEvent event,
    Emitter<ResetPasswordState> emit,
  ) async {
    print('🔵 ResetPasswordBloc._onResetPassword called');
    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));
    
    final result = await resetPassword(
      token: event.token,
      newPassword: event.newPassword,
    );

    if (result is Error<void>) {
      final failure = result.failure;
      print('   ❌ Reset Password Error: ${failure.message}');
      
      // Provide user-friendly error message
      String errorMessage;
      if (failure is NetworkFailure) {
        final message = failure.message.toLowerCase();
        if (message.contains('no route to host') || 
            message.contains('connection refused') ||
            message.contains('failed host lookup')) {
          errorMessage = 'Unable to connect to server. Please check your internet connection and try again.';
        } else if (message.contains('timeout')) {
          errorMessage = 'Connection timeout. Please check your internet connection and try again.';
        } else if (message.contains('no internet')) {
          errorMessage = 'No internet connection. Please check your network settings.';
        } else {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        }
      } else {
        errorMessage = failure.message;
      }
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isSuccess: false,
      ));
    } else if (result is Success<void>) {
      print('   ✅ Reset Password Success');
      emit(state.copyWith(
        isSuccess: true,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }
}
