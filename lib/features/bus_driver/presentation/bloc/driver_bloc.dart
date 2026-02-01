import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../domain/usecases/verify_driver_otp.dart';
import '../../domain/usecases/get_driver_profile.dart';
import '../../domain/usecases/get_assigned_buses.dart';
import '../../domain/usecases/register_driver.dart';
import '../../domain/usecases/register_driver_with_invitation.dart';
import '../../domain/usecases/driver_login.dart';
import '../../domain/usecases/get_driver_dashboard.dart';
import '../../domain/usecases/update_driver_profile.dart';
import '../../domain/usecases/mark_bus_as_reached.dart';
import '../../domain/usecases/get_pending_requests.dart';
import '../../domain/usecases/accept_request.dart';
import '../../domain/usecases/reject_request.dart';
import '../../domain/usecases/get_bus_details.dart';
import '../../domain/usecases/initiate_ride.dart';
import '../../domain/usecases/update_driver_location.dart';
import '../../domain/usecases/get_bus_passengers.dart';
import '../../domain/usecases/verify_ticket.dart';
import '../../domain/usecases/create_driver_booking.dart';
import '../../domain/usecases/request_permission.dart';
import '../../domain/usecases/get_permission_requests.dart';
import '../../data/models/driver_model.dart';
import '../../domain/repositories/driver_repository.dart';
import 'events/driver_event.dart';
import 'states/driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final VerifyDriverOtp verifyOtp;
  final GetDriverProfile getProfile;
  final GetAssignedBuses getBuses;
  final RegisterDriver registerDriver;
  final RegisterDriverWithInvitation registerWithInvitation;
  final DriverLogin driverLogin;
  final GetDriverDashboard getDashboard;
  final UpdateDriverProfile updateProfile;
  final MarkBusAsReached markBusAsReached;
  final GetPendingRequests getPendingRequests;
  final AcceptRequest acceptRequest;
  final RejectRequest rejectRequest;
  final GetBusDetails getBusDetails;
  final InitiateRide initiateRide;
  final UpdateDriverLocation updateDriverLocation;
  final GetBusPassengers getBusPassengers;
  final VerifyTicket verifyTicket;
  final CreateDriverBooking createDriverBooking;
  final RequestPermission requestPermission;
  final GetPermissionRequests getPermissionRequests;

  DriverBloc({
    required this.verifyOtp,
    required this.getProfile,
    required this.getBuses,
    required this.registerDriver,
    required this.registerWithInvitation,
    required this.driverLogin,
    required this.getDashboard,
    required this.updateProfile,
    required this.markBusAsReached,
    required this.getPendingRequests,
    required this.acceptRequest,
    required this.rejectRequest,
    required this.getBusDetails,
    required this.initiateRide,
    required this.updateDriverLocation,
    required this.getBusPassengers,
    required this.verifyTicket,
    required this.createDriverBooking,
    required this.requestPermission,
    required this.getPermissionRequests,
  }) : super(const DriverState()) {
    on<VerifyDriverOtpEvent>(_onVerifyOtp);
    on<GetDriverProfileEvent>(_onGetProfile);
    on<GetAssignedBusesEvent>(_onGetBuses);
    on<RegisterDriverEvent>(_onRegisterDriver);
    on<RegisterDriverWithInvitationEvent>(_onRegisterWithInvitation);
    on<RegisterDriverWithInvitationFileEvent>(_onRegisterWithInvitationFile);
    on<DriverLoginEvent>(_onDriverLogin);
    on<GetDriverDashboardEvent>(_onGetDriverDashboard);
    on<UpdateDriverProfileEvent>(_onUpdateProfile);
    on<MarkBusAsReachedEvent>(_onMarkBusAsReached);
    on<GetPendingRequestsEvent>(_onGetPendingRequests);
    on<AcceptRequestEvent>(_onAcceptRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<GetBusDetailsEvent>(_onGetBusDetails);
    on<InitiateRideEvent>(_onInitiateRide);
    on<UpdateDriverLocationEvent>(_onUpdateDriverLocation);
    on<GetBusPassengersEvent>(_onGetBusPassengers);
    on<VerifyTicketEvent>(_onVerifyTicket);
    on<CreateDriverBookingEvent>(_onCreateDriverBooking);
    on<RequestPermissionEvent>(_onRequestPermission);
    on<GetPermissionRequestsEvent>(_onGetPermissionRequests);
  }

  Future<void> _onVerifyOtp(
    VerifyDriverOtpEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onVerifyOtp called');
    print('   Event: phone=${event.phoneNumber}, otp=${event.otp}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await verifyOtp(event.phoneNumber, event.otp);

    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize((result as Error).failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      print('   ✅ OTP verification success');
      print('   Data keys: ${data.keys}');
      
      // Extract driver and token from response
      final driverData = data['driver'] as Map<String, dynamic>?;
      final token = data['token'] as String?;
      
      if (driverData != null) {
        final driver = DriverModel.fromJson(driverData);
        emit(state.copyWith(
          driver: driver,
          isLoading: false,
          errorMessage: null,
          registrationToken: token, // Store token for later use
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'OTP verified but driver data not found',
        ));
      }
    }
  }

  Future<void> _onGetProfile(
    GetDriverProfileEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onGetProfile called');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await getProfile();
    // Get full profile data including inviter
    final repository = di.sl<DriverRepository>();
    final profileDataResult = await repository.getDriverProfileWithInviter();

    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize((result as Error).failure),
      ));
    } else if (result is Success) {
      final driver = (result as Success).data;
      Map<String, dynamic>? profileData;
      if (profileDataResult is Success<Map<String, dynamic>>) {
        profileData = profileDataResult.data;
        print('   ✅ Profile data with inviter retrieved');
      }
      emit(state.copyWith(
        driver: driver,
        profileData: profileData,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onGetBuses(
    GetAssignedBusesEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onGetBuses called');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await getBuses();

    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize((result as Error).failure),
      ));
    } else if (result is Success) {
      final buses = (result as Success).data;
      emit(state.copyWith(
        buses: buses,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onRegisterWithInvitation(
    RegisterDriverWithInvitationEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onRegisterWithInvitation called');
    print('   Event: invitationCode=${event.invitationCode}, email=${event.email}, name=${event.name}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await registerWithInvitation(
      invitationCode: event.invitationCode,
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
      name: event.name,
      licenseNumber: event.licenseNumber,
    );

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ RegisterDriverWithInvitation Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      print('   ✅ RegisterDriverWithInvitation Success');
      print('   Data keys: ${data.keys}');
      
      // Extract driver and token from response
      final driverData = data['driver'] as Map<String, dynamic>?;
      final token = data['token'] as String?;
      
      if (driverData != null) {
        // Import DriverModel for parsing
        final driver = DriverModel.fromJson(driverData);
        emit(state.copyWith(
          driver: driver,
          isLoading: false,
          errorMessage: null,
          registrationToken: token, // Store token for later use
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Registration successful but driver data not found',
        ));
      }
    }
  }
  
  Future<void> _onRegisterWithInvitationFile(
    RegisterDriverWithInvitationFileEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onRegisterWithInvitationFile called');
    print('   Event: invitationCode=${event.invitationCode}, email=${event.email}, name=${event.name}');
    print('   LicensePhoto: ${event.licensePhoto?.path ?? "not provided"}');
    print('   DriverPhoto: ${event.driverPhoto?.path ?? "not provided"}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await registerWithInvitation(
      invitationCode: event.invitationCode,
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
      name: event.name,
      licenseNumber: event.licenseNumber,
      licensePhoto: event.licensePhoto,
      driverPhoto: event.driverPhoto,
    );

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ RegisterDriverWithInvitationFile Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      print('   ✅ RegisterDriverWithInvitationFile Success');
      print('   Data keys: ${data.keys}');
      
      // Extract driver and token from response
      final driverData = data['driver'] as Map<String, dynamic>?;
      final token = data['token'] as String?;
      
      if (driverData != null) {
        final driver = DriverModel.fromJson(driverData);
        emit(state.copyWith(
          driver: driver,
          isLoading: false,
          errorMessage: null,
          registrationToken: token,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Registration successful but driver data not found',
        ));
      }
    }
  }

  Future<void> _onDriverLogin(
    DriverLoginEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onDriverLogin called');
    print('   Event: email=${event.email}, phoneNumber=${event.phoneNumber}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await driverLogin(
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
      hasOTP: event.hasOTP,
      otp: event.otp,
    );

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ DriverLogin Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      print('   ✅ DriverLogin Success');
      print('   Data keys: ${data.keys}');
      
      // Extract driver and token from response
      final driverData = data['driver'] as Map<String, dynamic>?;
      final token = data['token'] as String?;
      
      if (driverData != null) {
        final driver = DriverModel.fromJson(driverData);
        emit(state.copyWith(
          driver: driver,
          isLoading: false,
          errorMessage: null,
          registrationToken: token, // Store token for later use
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Login successful but driver data not found',
        ));
      }
    }
  }

  Future<void> _onGetDriverDashboard(
    GetDriverDashboardEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onGetDriverDashboard called');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await getDashboard();

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ GetDriverDashboard Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      print('   ✅ GetDriverDashboard Success');
      print('   Data keys: ${data.keys}');
      
      emit(state.copyWith(
        dashboardData: data,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }
  
  Future<void> _onUpdateProfile(
    UpdateDriverProfileEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onUpdateProfile called');
    print('   Event: name=${event.name}, email=${event.email}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await updateProfile(
      name: event.name,
      email: event.email,
    );

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ UpdateDriverProfile Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      final driver = (result as Success).data;
      print('   ✅ UpdateDriverProfile Success');
      emit(state.copyWith(
        driver: driver,
        isLoading: false,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onRegisterDriver(
    RegisterDriverEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onRegisterDriver called (Independent Registration)');
    print('   Event: name=${event.name}, phoneNumber=${event.phoneNumber}, email=${event.email}');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await registerDriver(
      name: event.name,
      phoneNumber: event.phoneNumber,
      email: event.email,
      password: event.password,
      licenseNumber: event.licenseNumber,
      licensePhoto: event.licensePhoto,
      driverPhoto: event.driverPhoto,
      hasOTP: event.hasOTP,
      otp: event.otp,
    );

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ RegisterDriver Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      print('   ✅ RegisterDriver Success');
      print('   Data keys: ${data.keys}');
      
      // Extract driver and token from response
      final driverData = data['driver'] as Map<String, dynamic>?;
      final token = data['token'] as String?;
      
      if (driverData != null) {
        final driver = DriverModel.fromJson(driverData);
        emit(state.copyWith(
          driver: driver,
          isLoading: false,
          errorMessage: null,
          registrationToken: token,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Registration successful but driver data not found',
        ));
      }
    }
  }

  Future<void> _onMarkBusAsReached(
    MarkBusAsReachedEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onMarkBusAsReached called');
    print('   Event: busId=${event.busId}');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await markBusAsReached(event.busId);

    if (result is Error) {
      final failure = result.failure;
      print('   ❌ MarkBusAsReached Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      print('   ✅ MarkBusAsReached Success');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
      ));
      // Refresh dashboard to show updated status
      add(const GetDriverDashboardEvent());
    }
  }

  Future<void> _onGetPendingRequests(
    GetPendingRequestsEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onGetPendingRequests called');
    // Don't set loading if dashboard is already loading
    if (!state.isLoading) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }

    final result = await getPendingRequests();

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ GetPendingRequests Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      print('   ✅ GetPendingRequests Success');
      // Update state with pending requests
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        pendingRequests: data,
      ));
    }
  }

  Future<void> _onAcceptRequest(
    AcceptRequestEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onAcceptRequest called');
    print('   Event: requestId=${event.requestId}');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await acceptRequest(event.requestId);

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ AcceptRequest Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      print('   ✅ AcceptRequest Success');
      // Update pending requests - remove accepted request
      final currentRequests = state.pendingRequests;
      if (currentRequests != null) {
        final requests = (currentRequests['requests'] as List<dynamic>? ?? [])
            .where((r) {
              final req = r as Map<String, dynamic>;
              final reqId = req['id'] as String? ?? req['_id'] as String? ?? '';
              return reqId != event.requestId;
            })
            .toList();
        final updatedRequests = {
          ...currentRequests,
          'requests': requests,
          'count': requests.length,
        };
        emit(state.copyWith(
          isLoading: false,
          errorMessage: null,
          pendingRequests: updatedRequests,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: null,
        ));
      }
      // Refresh dashboard to show new bus assignment
      add(const GetDriverDashboardEvent());
      add(const GetPendingRequestsEvent());
    }
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onRejectRequest called');
    print('   Event: requestId=${event.requestId}');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await rejectRequest(event.requestId);

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ RejectRequest Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      print('   ✅ RejectRequest Success');
      // Update pending requests - remove rejected request
      final currentRequests = state.pendingRequests;
      if (currentRequests != null) {
        final requests = (currentRequests['requests'] as List<dynamic>? ?? [])
            .where((r) {
              final req = r as Map<String, dynamic>;
              final reqId = req['id'] as String? ?? req['_id'] as String? ?? '';
              return reqId != event.requestId;
            })
            .toList();
        final updatedRequests = {
          ...currentRequests,
          'requests': requests,
          'count': requests.length,
        };
        emit(state.copyWith(
          isLoading: false,
          errorMessage: null,
          pendingRequests: updatedRequests,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: null,
        ));
      }
      // Refresh pending requests
      add(const GetPendingRequestsEvent());
    }
  }

  Future<void> _onGetBusDetails(
    GetBusDetailsEvent event,
    Emitter<DriverState> emit,
  ) async {
    print('🔵 DriverBloc._onGetBusDetails called');
    print('   Event: busId=${event.busId}');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await getBusDetails(event.busId);

    if (result is Error) {
      final failure = (result as Error).failure;
      print('   ❌ GetBusDetails Error: ${failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      print('   ✅ GetBusDetails Success');
      // Store bus details in state
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        busDetails: data,
      ));
    }
  }

  Future<void> _onInitiateRide(
    InitiateRideEvent event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await initiateRide(event.busId);
    
    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize((result as Error).failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        rideData: data,
      ));
    }
  }

  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocationEvent event,
    Emitter<DriverState> emit,
  ) async {
    // Don't show loading for location updates (they happen frequently)
    final result = await updateDriverLocation(
      busId: event.busId,
      latitude: event.latitude,
      longitude: event.longitude,
      speed: event.speed,
      heading: event.heading,
      accuracy: event.accuracy,
    );
    
    if (result is Error) {
      // Only emit error if it's critical, otherwise silently fail
      print('   ⚠️ Location update failed: ${(result as Error).failure.message}');
    }
    // Success case - no need to update state for frequent location updates
  }

  Future<void> _onGetBusPassengers(
    GetBusPassengersEvent event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await getBusPassengers(event.busId);
    
    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize((result as Error).failure),
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        passengersData: data,
      ));
    }
  }

  Future<void> _onVerifyTicket(
    VerifyTicketEvent event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await verifyTicket(
      qrCode: event.qrCode,
      busId: event.busId,
      seatNumber: event.seatNumber,
    );
    
    if (result is Error) {
      final failure = (result as Error).failure;
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize(failure),
        ticketVerificationResult: {
          'success': false,
          'message': failure.message,
        },
      ));
    } else if (result is Success) {
      final data = (result as Success).data;
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        ticketVerificationResult: data,
      ));
      // Refresh passengers list after verification
      add(GetBusPassengersEvent(busId: event.busId));
    }
  }

  Future<void> _onCreateDriverBooking(
    CreateDriverBookingEvent event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await createDriverBooking(
      busId: event.busId,
      seatNumbers: event.seatNumbers,
      passengerName: event.passengerName,
      contactNumber: event.contactNumber,
      passengerEmail: event.passengerEmail,
      pickupLocation: event.pickupLocation,
      dropoffLocation: event.dropoffLocation,
      luggage: event.luggage,
      bagCount: event.bagCount,
      paymentMethod: event.paymentMethod,
    );
    
    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize((result as Error).failure),
      ));
    } else if (result is Success) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
      ));
      // Refresh dashboard after booking
      add(const GetDriverDashboardEvent());
      // Note: Success message should be shown in UI via BlocListener
    }
  }

  Future<void> _onRequestPermission(
    RequestPermissionEvent event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await requestPermission.call(
      permissionType: event.permissionType,
      busId: event.busId,
      message: event.message,
    );
    
    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize((result as Error).failure),
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
      ));
      // Refresh dashboard to get updated permissions
      add(const GetDriverDashboardEvent());
    }
  }

  Future<void> _onGetPermissionRequests(
    GetPermissionRequestsEvent event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await getPermissionRequests.call();
    
    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorMessageSanitizer.sanitize((result as Error).failure),
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: null,
        // Store permission requests in state if needed
        // For now, just clear error
      ));
    }
  }
}
