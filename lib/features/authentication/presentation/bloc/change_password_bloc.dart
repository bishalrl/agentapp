import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/get_stored_token.dart';
import 'events/change_password_event.dart';
import 'states/change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ChangePassword changePassword;
  final GetStoredToken getStoredToken;

  ChangePasswordBloc({
    required this.changePassword,
    required this.getStoredToken,
  }) : super(const ChangePasswordState()) {
    on<ChangePasswordRequestEvent>(_onChangePassword);
  }

  Future<void> _onChangePassword(
    ChangePasswordRequestEvent event,
    Emitter<ChangePasswordState> emit,
  ) async {
    print('🔵 ChangePasswordBloc._onChangePassword called');
    print('   Event: ${event.runtimeType}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    // Get token first
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      print('   ❌ Failed to get token: ${tokenResult.failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Authentication required. Please login again.',
      ));
      return;
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    } else {
      print('   ❌ Unexpected result type');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Authentication required. Please login again.',
      ));
      return;
    }
    if (token == null || token.isEmpty) {
      print('   ❌ Token is null or empty');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Authentication required. Please login again.',
      ));
      return;
    }

    print('   ✅ Token retrieved, proceeding with password change');

    final result = await changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      token: token,
    );

    if (result is Error) {
      final error = result;
      final errorMessage = error.failure.message.isEmpty 
          ? 'Failed to change password' 
          : error.failure.message;
      print('   ❌ Change Password Error:');
      print('   Failure Type: ${error.failure.runtimeType}');
      print('   Error Message: $errorMessage');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
      print('   State emitted: isLoading=false, errorMessage=$errorMessage');
    } else if (result is Success) {
      print('   ✅ Change Password Success');
      emit(state.copyWith(
        isSuccess: true,
        isLoading: false,
        errorMessage: null,
      ));
      print('   State emitted: isSuccess=true, isLoading=false');
    }
  }
}