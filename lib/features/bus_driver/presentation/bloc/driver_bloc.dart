import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/verify_driver_otp.dart';
import '../../domain/usecases/get_driver_profile.dart';
import '../../domain/usecases/get_assigned_buses.dart';
import 'events/driver_event.dart';
import 'states/driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final VerifyDriverOtp verifyOtp;
  final GetDriverProfile getProfile;
  final GetAssignedBuses getBuses;

  DriverBloc({
    required this.verifyOtp,
    required this.getProfile,
    required this.getBuses,
  }) : super(const DriverState()) {
    on<VerifyDriverOtpEvent>(_onVerifyOtp);
    on<GetDriverProfileEvent>(_onGetProfile);
    on<GetAssignedBusesEvent>(_onGetBuses);
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
        errorMessage: (result as Error).failure.message,
      ));
    } else if (result is Success) {
      final driver = (result as Success).data;
      emit(state.copyWith(
        driver: driver,
        isLoading: false,
        errorMessage: null,
      ));
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

    if (result is Error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: (result as Error).failure.message,
      ));
    } else if (result is Success) {
      final driver = (result as Success).data;
      emit(state.copyWith(
        driver: driver,
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
        errorMessage: (result as Error).failure.message,
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
}
