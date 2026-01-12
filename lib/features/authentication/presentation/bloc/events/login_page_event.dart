import '../../../../../core/bloc/base_bloc_event.dart';

abstract class LoginPageEvent extends BaseBlocEvent {
  const LoginPageEvent();
}

class TogglePasswordVisibilityEvent extends LoginPageEvent {
  const TogglePasswordVisibilityEvent();
}

