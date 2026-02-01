import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';
import '../../../authentication/domain/usecases/get_stored_session_type.dart';
import 'events/splash_event.dart';
import 'states/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetStoredToken getStoredToken;
  final GetStoredSessionType getStoredSessionType;

  SplashBloc({
    required this.getStoredToken,
    required this.getStoredSessionType,
  }) : super(const SplashState()) {
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
        // Determine which kind of session this is (counter/betaAgent vs driver)
        final sessionTypeResult = await getStoredSessionType();
        String? sessionType;
        if (sessionTypeResult is Success<String?>) {
          sessionType = sessionTypeResult.data;
        } else {
          print('   ⚠️ CheckAuth: Failed to get session type, defaulting to counter');
        }

        // Route to driver dashboard for drivers, otherwise to counter/betaAgent dashboard
        final nextRoute =
            sessionType == 'driver' ? '/driver/dashboard' : '/dashboard';
        
        print('   📍 Session type: $sessionType (counter/betaAgent use same dashboard)');

        print(
            '   ✅ CheckAuth Success: Token found, sessionType=$sessionType, nextRoute=$nextRoute');
        emit(state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          nextRoute: nextRoute,
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
