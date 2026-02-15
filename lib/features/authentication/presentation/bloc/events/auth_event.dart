import '../../../../../core/bloc/base_bloc_event.dart';

abstract class AuthEvent extends BaseBlocEvent {
  const AuthEvent();
}

/// Counter login: phone + password (no OTP).
class LoginEvent extends AuthEvent {
  final String phone;
  final String password;

  const LoginEvent({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

