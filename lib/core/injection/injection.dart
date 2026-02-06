import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/multipart_client.dart';
import '../utils/network_info.dart';
import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_status.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding.dart';
import '../../features/bus_driver/data/datasources/driver_remote_data_source.dart';
import '../../features/bus_driver/data/repositories/driver_repository_impl.dart';
import '../../features/bus_driver/domain/repositories/driver_repository.dart';
import '../../features/bus_driver/domain/usecases/verify_driver_otp.dart';
import '../../features/bus_driver/domain/usecases/get_driver_profile.dart';
import '../../features/bus_driver/domain/usecases/get_assigned_buses.dart' as driver_usecases;
import '../../features/bus_driver/domain/usecases/register_driver.dart';
import '../../features/bus_driver/domain/usecases/register_driver_with_invitation.dart';
import '../../features/bus_driver/domain/usecases/driver_login.dart';
import '../../features/bus_driver/domain/usecases/get_driver_dashboard.dart';
import '../../features/bus_driver/domain/usecases/update_driver_profile.dart';
import '../../features/bus_driver/domain/usecases/mark_bus_as_reached.dart';
import '../../features/bus_driver/domain/usecases/get_pending_requests.dart';
import '../../features/bus_driver/domain/usecases/accept_request.dart';
import '../../features/bus_driver/domain/usecases/reject_request.dart';
import '../../features/bus_driver/domain/usecases/get_bus_details.dart' as driver_usecases;
import '../../features/bus_driver/domain/usecases/initiate_ride.dart';
import '../../features/bus_driver/domain/usecases/update_driver_location.dart';
import '../../features/bus_driver/domain/usecases/get_bus_passengers.dart';
import '../../features/bus_driver/domain/usecases/verify_ticket.dart';
import '../../features/bus_driver/domain/usecases/create_driver_booking.dart';
import '../../features/bus_driver/domain/usecases/request_permission.dart';
import '../../features/bus_driver/domain/usecases/get_permission_requests.dart';
import '../../features/booking/data/datasources/booking_remote_data_source.dart';
import '../../features/booking/data/datasources/booking_local_data_source.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/bus_management/data/datasources/bus_local_data_source.dart';
import '../../features/bus_driver/data/datasources/driver_local_data_source.dart';
import '../../features/booking/domain/usecases/create_booking.dart';
import '../../features/booking/domain/usecases/get_available_buses.dart';
import '../../features/booking/domain/usecases/get_bus_details.dart' as booking_usecases;
import '../../features/booking/domain/usecases/get_bookings.dart';
import '../../features/booking/domain/usecases/get_booking_details.dart';
import '../../features/booking/domain/usecases/cancel_booking.dart';
import '../../features/booking/domain/usecases/cancel_multiple_bookings.dart';
import '../../features/booking/domain/usecases/update_booking_status.dart';
import '../../features/booking/domain/usecases/lock_seats.dart';
import '../../features/booking/domain/usecases/unlock_seats.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/bus_driver/presentation/bloc/driver_bloc.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/datasources/auth_local_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login.dart';
import '../../features/authentication/domain/usecases/signup.dart';
import '../../features/authentication/domain/usecases/change_password.dart';
import '../../features/authentication/domain/usecases/forgot_password.dart';
import '../../features/authentication/domain/usecases/reset_password.dart';
import '../../features/authentication/domain/usecases/logout.dart';
import '../../features/authentication/domain/usecases/get_stored_token.dart';
import '../../features/authentication/domain/usecases/get_stored_session_type.dart';
import '../../features/authentication/domain/usecases/clear_token.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/signup_bloc.dart';
import '../../features/authentication/presentation/bloc/change_password_bloc.dart';
import '../../features/authentication/presentation/bloc/forgot_password_bloc.dart';
import '../../features/authentication/presentation/bloc/reset_password_bloc.dart';
import '../../features/seat_locking/data/datasources/seat_lock_remote_data_source.dart';
import '../../features/seat_locking/data/repositories/seat_lock_repository_impl.dart';
import '../../features/seat_locking/domain/repositories/seat_lock_repository.dart';
import '../../features/seat_locking/domain/usecases/lock_seat.dart';
import '../../features/seat_locking/domain/usecases/lock_multiple_seats.dart';
import '../../features/seat_locking/domain/usecases/unlock_seat.dart';
import '../../features/seat_locking/domain/usecases/get_bus_locks.dart';
import '../../features/seat_locking/presentation/bloc/seat_lock_bloc.dart';
import '../../features/bus_management/data/datasources/bus_remote_data_source.dart';
import '../../features/bus_management/data/repositories/bus_repository_impl.dart';
import '../../features/bus_management/domain/repositories/bus_repository.dart';
import '../../features/bus_management/domain/usecases/create_bus.dart';
import '../../features/bus_management/domain/usecases/update_bus.dart';
import '../../features/bus_management/domain/usecases/delete_bus.dart';
import '../../features/bus_management/domain/usecases/get_my_buses.dart';
import '../../features/bus_management/domain/usecases/get_assigned_buses.dart' as bus_management_usecases;
import '../../features/bus_management/domain/usecases/search_bus_by_number.dart';
import '../../features/bus_management/domain/usecases/activate_bus.dart';
import '../../features/bus_management/domain/usecases/deactivate_bus.dart';
import '../../features/bus_management/presentation/bloc/bus_bloc.dart';
import '../../features/route_management/data/datasources/route_remote_data_source.dart';
import '../../features/route_management/data/repositories/route_repository_impl.dart';
import '../../features/route_management/domain/repositories/route_repository.dart';
import '../../features/route_management/domain/usecases/create_route.dart';
import '../../features/route_management/domain/usecases/update_route.dart';
import '../../features/route_management/domain/usecases/delete_route.dart';
import '../../features/route_management/domain/usecases/get_routes.dart';
import '../../features/route_management/domain/usecases/get_route_by_id.dart';
import '../../features/route_management/presentation/bloc/route_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/wallet/data/datasources/wallet_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/add_money.dart';
import '../../features/wallet/domain/usecases/get_transactions.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/wallet/data/datasources/wallet_hold_remote_data_source.dart';
import '../../features/wallet/data/repositories/wallet_hold_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_hold_repository.dart';
import '../../features/wallet/domain/usecases/create_wallet_hold.dart';
import '../../features/wallet/domain/usecases/release_wallet_hold.dart';
import '../../features/wallet/domain/usecases/confirm_wallet_hold.dart';
import '../../features/driver_management/data/datasources/driver_management_remote_data_source.dart';
import '../../features/driver_management/data/repositories/driver_management_repository_impl.dart';
import '../../features/driver_management/domain/repositories/driver_management_repository.dart';
import '../../features/driver_management/domain/usecases/invite_driver.dart';
import '../../features/driver_management/domain/usecases/get_drivers.dart';
import '../../features/driver_management/domain/usecases/get_driver_by_id.dart';
import '../../features/driver_management/domain/usecases/assign_driver_to_bus.dart';
import '../../features/driver_management/domain/usecases/update_driver.dart';
import '../../features/driver_management/domain/usecases/delete_driver.dart';
import '../../features/driver_management/presentation/bloc/driver_management_bloc.dart';
import '../../features/schedule_management/data/datasources/schedule_remote_data_source.dart';
import '../../features/schedule_management/data/repositories/schedule_repository_impl.dart';
import '../../features/schedule_management/domain/repositories/schedule_repository.dart';
import '../../features/schedule_management/domain/usecases/create_schedule.dart';
import '../../features/schedule_management/domain/usecases/get_schedules.dart';
import '../../features/schedule_management/domain/usecases/get_schedule_by_id.dart';
import '../../features/schedule_management/domain/usecases/update_schedule.dart';
import '../../features/schedule_management/domain/usecases/delete_schedule.dart';
import '../../features/schedule_management/presentation/bloc/schedule_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/mark_notifications_read.dart';
import '../../features/notifications/domain/usecases/mark_all_read.dart';
import '../../features/notifications/domain/usecases/delete_notification.dart';
import '../../features/notifications/domain/usecases/delete_all_notifications.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/sales/data/datasources/sales_remote_data_source.dart';
import '../../features/sales/data/repositories/sales_repository_impl.dart';
import '../../features/sales/domain/repositories/sales_repository.dart';
import '../../features/sales/domain/usecases/get_sales_summary.dart';
import '../../features/sales/presentation/bloc/sales_bloc.dart';
import '../../features/offline/data/datasources/offline_remote_data_source.dart';
import '../../features/offline/data/repositories/offline_repository_impl.dart';
import '../../features/offline/domain/repositories/offline_repository.dart';
import '../../features/offline/domain/usecases/get_offline_queue.dart';
import '../../features/offline/domain/usecases/add_to_offline_queue.dart';
import '../../features/offline/domain/usecases/sync_offline_bookings.dart';
import '../../features/offline/presentation/bloc/offline_bloc.dart';
import '../../features/audit_logs/data/datasources/audit_log_remote_data_source.dart';
import '../../features/audit_logs/data/repositories/audit_log_repository_impl.dart';
import '../../features/audit_logs/domain/repositories/audit_log_repository.dart';
import '../../features/audit_logs/domain/usecases/get_audit_logs.dart';
import '../../features/audit_logs/presentation/bloc/audit_log_bloc.dart';
import '../../features/counter_request/data/datasources/counter_request_remote_data_source.dart';
import '../../features/counter_request/data/repositories/counter_request_repository_impl.dart';
import '../../features/counter_request/domain/repositories/counter_request_repository.dart';
import '../../features/counter_request/domain/usecases/request_bus_access.dart';
import '../../features/counter_request/domain/usecases/get_counter_requests.dart';
import '../../features/counter_request/presentation/bloc/counter_request_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Onboarding
  // Bloc
  sl.registerFactory(() => OnboardingBloc(
        getOnboardingStatus: sl(),
        completeOnboarding: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetOnboardingStatus(sl()));
  sl.registerLazySingleton(() => CompleteOnboarding(sl()));

  // Repository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl()),
  );

  //! Features - Counter Request Management
  // Bloc
  sl.registerFactory(() => CounterRequestBloc(
        requestBusAccess: sl(),
        getCounterRequests: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => RequestBusAccess(sl()));
  sl.registerLazySingleton(() => GetCounterRequests(sl()));

  // Repository
  sl.registerLazySingleton<CounterRequestRepository>(
    () => CounterRequestRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CounterRequestRemoteDataSource>(
    () => CounterRequestRemoteDataSourceImpl(sl()),
  );

  //! Features - Bus Driver
  // Bloc
  sl.registerFactory(() => DriverBloc(
        verifyOtp: sl(),
        getProfile: sl(),
        getBuses: sl(),
        registerDriver: sl(),
        registerWithInvitation: sl(),
        driverLogin: sl(),
        getDashboard: sl(),
        updateProfile: sl(),
        markBusAsReached: sl(),
        getPendingRequests: sl(),
        acceptRequest: sl(),
        rejectRequest: sl(),
        getBusDetails: sl(),
        initiateRide: sl(),
        updateDriverLocation: sl(),
        getBusPassengers: sl(),
        verifyTicket: sl(),
        createDriverBooking: sl(),
        requestPermission: sl(),
        getPermissionRequests: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => VerifyDriverOtp(sl()));
  sl.registerLazySingleton(() => GetDriverProfile(sl()));
  sl.registerLazySingleton(() => driver_usecases.GetAssignedBuses(sl()));
  sl.registerLazySingleton(() => RegisterDriver(sl()));
  sl.registerLazySingleton(() => RegisterDriverWithInvitation(sl()));
  sl.registerLazySingleton(() => DriverLogin(sl()));
  sl.registerLazySingleton(() => GetDriverDashboard(sl()));
  sl.registerLazySingleton(() => UpdateDriverProfile(sl()));
  sl.registerLazySingleton(() => MarkBusAsReached(sl()));
  sl.registerLazySingleton(() => GetPendingRequests(sl()));
  sl.registerLazySingleton(() => AcceptRequest(sl()));
  sl.registerLazySingleton(() => RejectRequest(sl()));
  sl.registerLazySingleton(() => driver_usecases.GetBusDetails(sl()));
  sl.registerLazySingleton(() => InitiateRide(sl()));
  sl.registerLazySingleton(() => UpdateDriverLocation(sl()));
  sl.registerLazySingleton(() => GetBusPassengers(sl()));
  sl.registerLazySingleton(() => VerifyTicket(sl()));
  sl.registerLazySingleton(() => CreateDriverBooking(sl()));
  sl.registerLazySingleton(() => RequestPermission(sl()));
  sl.registerLazySingleton(() => GetPermissionRequests(sl()));

  // Repository
  sl.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSourceImpl(sl(), sl()), // ApiClient and MultipartClient
  );
  sl.registerLazySingleton<DriverLocalDataSource>(
    () => DriverLocalDataSourceImpl(sl()),
  );

  //! Features - Booking
  // Bloc
  sl.registerFactory(() => BookingBloc(
        getBuses: sl(),
        getBusDetails: sl(),
        getBookings: sl(),
        getBookingDetails: sl(),
        createBooking: sl(),
        cancelBooking: sl(),
        cancelMultipleBookings: sl(),
        updateBookingStatus: sl(),
        lockSeats: sl(),
        unlockSeats: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetAvailableBuses(sl()));
  sl.registerLazySingleton(() => booking_usecases.GetBusDetails(sl()));
  sl.registerLazySingleton(() => GetBookings(sl()));
  sl.registerLazySingleton(() => GetBookingDetails(sl()));
  sl.registerLazySingleton(() => CreateBooking(sl()));
  sl.registerLazySingleton(() => CancelBooking(sl()));
  sl.registerLazySingleton(() => CancelMultipleBookings(sl()));
  sl.registerLazySingleton(() => UpdateBookingStatus(sl()));
  sl.registerLazySingleton(() => LockSeats(sl()));
  sl.registerLazySingleton(() => UnlockSeats(sl()));

  // Repository
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl(), sl(), getStoredToken: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BookingLocalDataSource>(
    () => BookingLocalDataSourceImpl(sl()),
  );

  //! Features - Dashboard
  // Bloc
  sl.registerFactory(() => DashboardBloc(getDashboard: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetDashboard(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl(), sl(), getStoredToken: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSourceImpl(sl()),
  );

  //! Features - Splash
  // Bloc
  sl.registerFactory(() => SplashBloc(
        getStoredToken: sl(),
        getStoredSessionType: sl(),
      ));

  //! Features - Authentication
  // Bloc
  // Use LazySingleton for AuthBloc since it should persist throughout app lifecycle
  sl.registerLazySingleton(() => AuthBloc(
        login: sl(),
        logout: sl(),
        getStoredToken: sl(),
      ));
  sl.registerFactory(() => SignupBloc(signup: sl()));
  sl.registerFactory(() => ChangePasswordBloc(
        changePassword: sl(),
        getStoredToken: sl(),
      ));
  sl.registerFactory(() => ForgotPasswordBloc(
        forgotPassword: sl(),
      ));
  sl.registerFactory(() => ResetPasswordBloc(
        resetPassword: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Signup(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetStoredToken(sl()));
  sl.registerLazySingleton(() => GetStoredSessionType(sl()));
  sl.registerLazySingleton(() => ClearToken(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  //! Features - Seat Locking
  // Bloc
  sl.registerFactory(() => SeatLockBloc(
        lockSeat: sl(),
        lockMultipleSeats: sl(),
        unlockSeat: sl(),
        getBusLocks: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => LockSeat(sl()));
  sl.registerLazySingleton(() => LockMultipleSeats(sl()));
  sl.registerLazySingleton(() => UnlockSeat(sl()));
  sl.registerLazySingleton(() => GetBusLocks(sl()));

  // Repository
  sl.registerLazySingleton<SeatLockRepository>(
    () => SeatLockRepositoryImpl(sl(), token: null),
  );

  // Data sources
  sl.registerLazySingleton<SeatLockRemoteDataSource>(
    () => SeatLockRemoteDataSourceImpl(sl()),
  );

  //! Features - Bus Management
  // Bloc
  sl.registerFactory(() => BusBloc(
        createBus: sl(),
        updateBus: sl(),
        deleteBus: sl(),
        getMyBuses: sl(),
        getAssignedBuses: sl(),
        searchBusByNumber: sl(),
        activateBus: sl(),
        deactivateBus: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => CreateBus(sl()));
  sl.registerLazySingleton(() => UpdateBus(sl()));
  sl.registerLazySingleton(() => DeleteBus(sl()));
  sl.registerLazySingleton(() => GetMyBuses(sl()));
  sl.registerLazySingleton(() => bus_management_usecases.GetAssignedBuses(sl(), sl()));
  sl.registerLazySingleton(() => SearchBusByNumber(sl(), sl()));
  sl.registerLazySingleton(() => ActivateBus(sl()));
  sl.registerLazySingleton(() => DeactivateBus(sl()));

  // Repository
  sl.registerLazySingleton<BusRepository>(
    () => BusRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      getStoredToken: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<BusRemoteDataSource>(
    () => BusRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<BusLocalDataSource>(
    () => BusLocalDataSourceImpl(sl()),
  );

  //! Features - Route Management
  // Bloc
  sl.registerFactory(() => RouteBloc(
        createRoute: sl(),
        updateRoute: sl(),
        deleteRoute: sl(),
        getRoutes: sl(),
        getRouteById: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => CreateRoute(sl()));
  sl.registerLazySingleton(() => UpdateRoute(sl()));
  sl.registerLazySingleton(() => DeleteRoute(sl()));
  sl.registerLazySingleton(() => GetRoutes(sl()));
  sl.registerLazySingleton(() => GetRouteById(sl()));

  // Repository
  sl.registerLazySingleton<RouteRepository>(
    () => RouteRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RouteRemoteDataSource>(
    () => RouteRemoteDataSourceImpl(sl()),
  );

  //! Features - Profile Management
  // Bloc
  sl.registerFactory(() => ProfileBloc(
        getProfile: sl(),
        updateProfile: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sl()),
  );

  //! Features - Wallet Management
  // Bloc
  sl.registerFactory(() => WalletBloc(
        addMoney: sl(),
        getTransactions: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => AddMoney(sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));

  // Repository
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(sl()),
  );
  
  // Wallet Hold dependencies
  // Use cases
  sl.registerLazySingleton(() => CreateWalletHold(sl()));
  sl.registerLazySingleton(() => ReleaseWalletHold(sl()));
  sl.registerLazySingleton(() => ConfirmWalletHold(sl()));

  // Repository
  sl.registerLazySingleton<WalletHoldRepository>(
    () => WalletHoldRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<WalletHoldRemoteDataSource>(
    () => WalletHoldRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Driver Management
  // Bloc
  sl.registerFactory(() => DriverManagementBloc(
        inviteDriver: sl(),
        getDrivers: sl(),
        getDriverById: sl(),
        assignDriverToBus: sl(),
        updateDriver: sl(),
        deleteDriver: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => InviteDriver(sl()));
  sl.registerLazySingleton(() => GetDrivers(sl()));
  sl.registerLazySingleton(() => GetDriverById(sl()));
  sl.registerLazySingleton(() => AssignDriverToBus(sl()));
  sl.registerLazySingleton(() => UpdateDriver(sl()));
  sl.registerLazySingleton(() => DeleteDriver(sl()));

  // Repository
  sl.registerLazySingleton<DriverManagementRepository>(
    () => DriverManagementRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DriverManagementRemoteDataSource>(
    () => DriverManagementRemoteDataSourceImpl(sl()),
  );

  //! Features - Schedule Management
  // Bloc
  sl.registerFactory(() => ScheduleBloc(
        createSchedule: sl(),
        getSchedules: sl(),
        getScheduleById: sl(),
        updateSchedule: sl(),
        deleteSchedule: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => CreateSchedule(sl()));
  sl.registerLazySingleton(() => GetSchedules(sl()));
  sl.registerLazySingleton(() => GetScheduleById(sl()));
  sl.registerLazySingleton(() => UpdateSchedule(sl()));
  sl.registerLazySingleton(() => DeleteSchedule(sl()));

  // Repository
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ScheduleRemoteDataSource>(
    () => ScheduleRemoteDataSourceImpl(sl()),
  );

  //! Features - Notifications
  // Bloc
  sl.registerFactory(() => NotificationBloc(
        getNotifications: sl(),
        markAsRead: sl(),
        markAllAsRead: sl(),
        deleteNotification: sl(),
        deleteAllNotifications: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationsRead(sl()));
  sl.registerLazySingleton(() => MarkAllRead(sl()));
  sl.registerLazySingleton(() => DeleteNotification(sl()));
  sl.registerLazySingleton(() => DeleteAllNotifications(sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );

  //! Features - Sales & Reports
  // Bloc
  sl.registerFactory(() => SalesBloc(getSalesSummary: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetSalesSummary(sl()));

  // Repository
  sl.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<SalesRemoteDataSource>(
    () => SalesRemoteDataSourceImpl(sl()),
  );

  //! Features - Offline Mode
  // Bloc
  sl.registerFactory(() => OfflineBloc(
        getOfflineQueue: sl(),
        addToOfflineQueue: sl(),
        syncOfflineBookings: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetOfflineQueue(sl()));
  sl.registerLazySingleton(() => AddToOfflineQueue(sl()));
  sl.registerLazySingleton(() => SyncOfflineBookings(sl()));

  // Repository
  sl.registerLazySingleton<OfflineRepository>(
    () => OfflineRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<OfflineRemoteDataSource>(
    () => OfflineRemoteDataSourceImpl(sl()),
  );

  //! Features - Audit Logs
  // Bloc
  sl.registerFactory(() => AuditLogBloc(getAuditLogs: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetAuditLogs(sl()));

  // Repository
  sl.registerLazySingleton<AuditLogRepository>(
    () => AuditLogRepositoryImpl(
      remoteDataSource: sl(),
      getStoredToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuditLogRemoteDataSource>(
    () => AuditLogRemoteDataSourceImpl(sl()),
  );

  //! Core
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => MultipartClient());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}

