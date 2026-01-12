import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';
import 'events/splash_event.dart';
import 'states/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetStoredToken getStoredToken;

  SplashBloc({required this.getStoredToken}) : super(const SplashState()) {
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<SplashState> emit,
  ) async {
    print('🔵 SplashBloc._onCheckAuth called');
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));
    print('   Checking stored token...');

    final result = await getStoredToken();

    if (result is Error<String?>) {
      print('   ❌ CheckAuth Error: ${result.failure.message}');
      print('   State emitted: nextRoute=/onboarding');
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        nextRoute: '/onboarding',
      ));
    } else if (result is Success<String?>) {
      final token = result.data;
      if (token != null && token.isNotEmpty) {
        print('   ✅ CheckAuth Success: Token found, nextRoute=/dashboard');
        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          nextRoute: '/dashboard',
        ));
      } else {
        print('   ⚠️ CheckAuth: No token found, nextRoute=/onboarding');
        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          nextRoute: '/onboarding',
        ));
      }
    }
  }
}
