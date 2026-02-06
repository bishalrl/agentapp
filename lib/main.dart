import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/injection/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/utils/bloc_observer.dart';
import 'core/session/session_manager.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/bus_driver/presentation/bloc/driver_bloc.dart';
import 'features/seat_locking/presentation/bloc/seat_lock_bloc.dart';
import 'features/bus_management/presentation/bloc/bus_bloc.dart';
import 'features/route_management/presentation/bloc/route_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  // Initialize session manager with router
  SessionManager().initialize(AppRouter.router);
  
  // Add BLoC Observer for debugging
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<SplashBloc>()),
        BlocProvider(create: (_) => di.sl<OnboardingBloc>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<DashboardBloc>()),
        BlocProvider(create: (_) => di.sl<BookingBloc>()),
        BlocProvider(create: (_) => di.sl<DriverBloc>()),
        BlocProvider(create: (_) => di.sl<SeatLockBloc>()),
        BlocProvider(create: (_) => di.sl<BusBloc>()),
        BlocProvider(create: (_) => di.sl<RouteBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Tejbi Agent',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

