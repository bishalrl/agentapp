import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/get_stored_token.dart';
import '../../domain/entities/auth_entity.dart';
import 'events/auth_event.dart';
import 'states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Logout logout;
  final GetStoredToken getStoredToken;

  AuthBloc({
    required this.login,
    required this.logout,
    required this.getStoredToken,
  }) : super(const AuthState()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 AuthBloc._onLogin called');
    print('   Event: ${event.runtimeType}');
    print('   Email: ${event.email}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await login(event.email, event.password);

    if (result is Error<AuthEntity>) {
      final failure = result.failure;
      print('   ❌ Login Error: ${failure.message}');
      print('   Failure type: ${failure.runtimeType}');
      
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      
      // CRITICAL: Set isAuthenticated to false on login failure
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        isAuthenticated: false, // Ensure user is not authenticated on error
        auth: null, // Clear auth data on error
      ));
      print('   State emitted: isLoading=false, isAuthenticated=false, errorMessage=$errorMessage');
    } else if (result is Success) {
      final auth = (result as Success).data;
      print('   ✅ Login Success: Token=${auth.token.substring(0, 20)}...');
      print('   mustChangePassword: ${auth.mustChangePassword}');
      emit(state.copyWith(
        auth: auth,
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
        mustChangePassword: auth.mustChangePassword,
      ));
      print('   State emitted: isAuthenticated=true, isLoading=false, mustChangePassword=${auth.mustChangePassword}');
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await logout();

    if (result is Error<void>) {
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(result.failure);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    } else if (result is Success<void>) {
      emit(const AuthState(
        isAuthenticated: false,
        isLoading: false,
      ));
    }
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await getStoredToken();

    if (result is Error<String?>) {
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      ));
    } else if (result is Success<String?>) {
      final token = result.data;
      emit(state.copyWith(
        isAuthenticated: token != null && token.isNotEmpty,
        isLoading: false,
      ));
    }
  }
}
