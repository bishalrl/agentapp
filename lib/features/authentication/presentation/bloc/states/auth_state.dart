import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../domain/entities/auth_entity.dart';

class AuthState extends BaseBlocState {
  final AuthEntity? auth;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final bool mustChangePassword;

  const AuthState({
    this.auth,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.mustChangePassword = false,
  });

  AuthState copyWith({
    AuthEntity? auth,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    bool? mustChangePassword,
  }) {
    return AuthState(
      auth: auth ?? this.auth,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }

  @override
  List<Object?> get props => [auth, isAuthenticated, isLoading, errorMessage, mustChangePassword];
}

