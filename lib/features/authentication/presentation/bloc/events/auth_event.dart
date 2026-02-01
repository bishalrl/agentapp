import '../../../../../core/bloc/base_bloc_event.dart';

abstract class AuthEvent extends BaseBlocEvent {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String loginType; // 'counter' or 'betaAgent'

  const LoginEvent({
    required this.email,
    required this.password,
    this.loginType = 'counter', // Default to counter for backward compatibility
  });

  @override
  List<Object?> get props => [email, password, loginType];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

