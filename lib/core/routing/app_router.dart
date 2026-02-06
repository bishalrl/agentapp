import 'package:go_router/go_router.dart';
import '../widgets/main_shell.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/authentication/presentation/pages/change_password_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/reset_password_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/redesigned_dashboard_page.dart';
import '../../features/bus_driver/presentation/pages/driver_login_page.dart';
import '../../features/bus_driver/presentation/pages/driver_dashboard_page.dart';
import '../../features/bus_driver/presentation/pages/driver_tab_dashboard_page.dart';
import '../../features/bus_driver/presentation/pages/driver_profile_edit_page.dart';
import '../../features/bus_driver/presentation/pages/driver_bus_details_page.dart';
import '../../features/booking/presentation/pages/booking_list_page.dart';
import '../../features/booking/presentation/pages/create_booking_page.dart';
import '../../features/booking/presentation/pages/booking_details_page.dart';
import '../../features/bus_management/presentation/pages/bus_list_page.dart';
import '../../features/bus_management/presentation/pages/bus_detail_page.dart';
import '../../features/bus_management/presentation/pages/create_bus_page.dart';
import '../../features/bus_management/presentation/pages/edit_bus_page.dart';
import '../../features/route_management/presentation/pages/route_list_page.dart';
import '../../features/route_management/presentation/pages/create_route_page.dart';
import '../../features/route_management/presentation/pages/edit_route_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/driver_management/presentation/pages/driver_list_page.dart';
import '../../features/driver_management/presentation/pages/invite_driver_page.dart';
import '../../features/schedule_management/presentation/pages/schedule_list_page.dart';
import '../../features/schedule_management/presentation/pages/create_schedule_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/sales/presentation/pages/sales_page.dart';
import '../../features/offline/presentation/pages/offline_page.dart';
import '../../features/audit_logs/presentation/pages/audit_logs_page.dart';
import '../../features/counter_request/presentation/pages/request_bus_access_page.dart';
import '../../features/counter_request/presentation/pages/counter_requests_list_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Add any global redirects here if needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password/:token',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return ResetPasswordPage(token: token);
        },
      ),
      GoRoute(
        path: '/driver/login',
        name: 'driver-login',
        builder: (context, state) => const DriverLoginPage(),
      ),
      GoRoute(
        path: '/driver/dashboard',
        name: 'driver-dashboard',
        builder: (context, state) => const DriverTabDashboardPage(),
      ),
      // Keep old dashboard route for backward compatibility
      GoRoute(
        path: '/driver/dashboard/old',
        name: 'driver-dashboard-old',
        builder: (context, state) => const DriverDashboardPage(),
      ),
      GoRoute(
        path: '/driver/profile/edit',
        name: 'driver-profile-edit',
        builder: (context, state) => const DriverProfileEditPage(),
      ),
      GoRoute(
        path: '/driver/bus/:busId',
        name: 'driver-bus-details',
        builder: (context, state) {
          final busId = state.pathParameters['busId']!;
          return DriverBusDetailsPage(busId: busId);
        },
      ),
      // Main shell route with bottom navigation bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const RedesignedDashboardPage(),
              ),
            ],
          ),
          // Bookings branch (only list page in shell)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                name: 'bookings',
                builder: (context, state) => const BookingListPage(),
              ),
            ],
          ),
          // Buses branch (only list page in shell)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buses',
                name: 'buses',
                builder: (context, state) => const BusListPage(),
              ),
            ],
          ),
          // Profile branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Child routes (create/edit/details) - no bottom nav bar
      GoRoute(
        path: '/bookings/create',
        name: 'create-booking',
        builder: (context, state) => const CreateBookingPage(),
      ),
      GoRoute(
        path: '/bookings/:id',
        name: 'booking-details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookingDetailsPage(bookingId: id);
        },
      ),
      GoRoute(
        path: '/buses/create',
        name: 'create-bus',
        builder: (context, state) => const CreateBusPage(),
      ),
      GoRoute(
        path: '/buses/:id',
        name: 'bus-details',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BusDetailPage(busId: id);
        },
      ),
      GoRoute(
        path: '/buses/:id/edit',
        name: 'edit-bus',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditBusPage(busId: id);
        },
      ),
      // Other routes (not part of main tabs)
      GoRoute(
        path: '/routes',
        name: 'routes',
        builder: (context, state) => const RouteListPage(),
      ),
      GoRoute(
        path: '/routes/create',
        name: 'create-route',
        builder: (context, state) => const CreateRoutePage(),
      ),
      GoRoute(
        path: '/routes/:id/edit',
        name: 'edit-route',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditRoutePage(routeId: id);
        },
      ),
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/drivers',
        name: 'drivers',
        builder: (context, state) => const DriverListPage(),
      ),
      GoRoute(
        path: '/drivers/invite',
        name: 'invite-driver',
        builder: (context, state) => const InviteDriverPage(),
      ),
      GoRoute(
        path: '/schedules',
        name: 'schedules',
        builder: (context, state) => const ScheduleListPage(),
      ),
      GoRoute(
        path: '/schedules/create',
        name: 'create-schedule',
        builder: (context, state) => const CreateSchedulePage(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/sales',
        name: 'sales',
        builder: (context, state) => const SalesPage(),
      ),
      GoRoute(
        path: '/offline',
        name: 'offline',
        builder: (context, state) => const OfflinePage(),
      ),
      GoRoute(
        path: '/audit-logs',
        name: 'audit-logs',
        builder: (context, state) => const AuditLogsPage(),
      ),
      // Counter Request Management
      GoRoute(
        path: '/counter/request-bus-access',
        name: 'request-bus-access',
        builder: (context, state) {
          final busId = state.uri.queryParameters['busId'];
          return RequestBusAccessPage(busId: busId);
        },
      ),
      GoRoute(
        path: '/counter/requests',
        name: 'counter-requests',
        builder: (context, state) => const CounterRequestsListPage(),
      ),
    ],
  );
}

