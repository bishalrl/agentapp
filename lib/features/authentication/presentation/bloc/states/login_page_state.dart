import '../../../../../core/bloc/base_bloc_state.dart';

class LoginPageState extends BaseBlocState {
  final bool obscurePassword;

  const LoginPageState({this.obscurePassword = true});

  LoginPageState copyWith({bool? obscurePassword}) {
    return LoginPageState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  @override
  List<Object?> get props => [obscurePassword];
}

