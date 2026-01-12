import 'package:flutter_bloc/flutter_bloc.dart';
import 'events/login_page_event.dart';
import 'states/login_page_state.dart';

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {
  LoginPageBloc() : super(const LoginPageState()) {
    on<TogglePasswordVisibilityEvent>(_onTogglePasswordVisibility);
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibilityEvent event,
    Emitter<LoginPageState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }
}
