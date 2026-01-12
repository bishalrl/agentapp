import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object> get props => [];
}

class ForgotPasswordRequestEvent extends ForgotPasswordEvent {
  final String email;

  const ForgotPasswordRequestEvent(this.email);

  @override
  List<Object> get props => [email];
}
