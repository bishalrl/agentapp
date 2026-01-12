import '../../../../../core/bloc/base_bloc_state.dart';

class SplashState extends BaseBlocState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? nextRoute;

  const SplashState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.nextRoute,
  });

  SplashState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? nextRoute,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      nextRoute: nextRoute,
    );
  }

  @override
  List<Object?> get props => [isLoading, isAuthenticated, nextRoute];
}

