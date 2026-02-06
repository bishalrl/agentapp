import 'package:agentapp/features/driver_management/presentation/bloc/events/driver_management_event.dart';
import 'package:agentapp/features/driver_management/presentation/bloc/states/driver_management_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/usecases/invite_driver.dart';
import '../../domain/usecases/get_drivers.dart';
import '../../domain/usecases/get_driver_by_id.dart';
import '../../domain/usecases/assign_driver_to_bus.dart';
import '../../domain/usecases/update_driver.dart';
import '../../domain/usecases/delete_driver.dart';


class DriverManagementBloc
    extends Bloc<DriverManagementEvent, DriverManagementState> {
  final InviteDriver inviteDriver;
  final GetDrivers getDrivers;
  final GetDriverById getDriverById;
  final AssignDriverToBus assignDriverToBus;
  final UpdateDriver updateDriver;
  final DeleteDriver deleteDriver;

  DriverManagementBloc({
    required this.inviteDriver,
    required this.getDrivers,
    required this.getDriverById,
    required this.assignDriverToBus,
    required this.updateDriver,
    required this.deleteDriver,
  }) : super(DriverManagementInitial()) {
    on<GetDriversEvent>(_onGetDrivers);
    on<InviteDriverEvent>(_onInviteDriver);
    on<GetDriverByIdEvent>(_onGetDriverById);
    on<AssignDriverToBusEvent>(_onAssignDriverToBus);
    on<UpdateDriverEvent>(_onUpdateDriver);
    on<DeleteDriverEvent>(_onDeleteDriver);
  }

  Future<void> _onGetDrivers(
    GetDriversEvent event,
    Emitter<DriverManagementState> emit,
  ) async {
    emit(DriverManagementLoading());
    final result = await getDrivers(
      status: event.status,
      busId: event.busId,
    );
    if (result is Error<List<DriverEntity>>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(DriverManagementError(errorMessage));
    } else if (result is Success<List<DriverEntity>>) {
      final drivers = result.data;
      emit(DriversLoaded(drivers));
    }
  }

  Future<void> _onInviteDriver(
    InviteDriverEvent event,
    Emitter<DriverManagementState> emit,
  ) async {
    emit(DriverManagementLoading());
    final result = await inviteDriver(
      name: event.name,
      phoneNumber: event.phoneNumber,
      email: event.email,
      licenseNumber: event.licenseNumber,
      licenseExpiry: event.licenseExpiry,
      address: event.address,
      busId: event.busId,
    );
    if (result is Error<DriverEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(DriverManagementError(errorMessage));
    } else if (result is Success<DriverEntity>) {
      final driver = result.data;
      emit(DriverInvited(driver));
    }
  }

  Future<void> _onGetDriverById(
    GetDriverByIdEvent event,
    Emitter<DriverManagementState> emit,
  ) async {
    emit(DriverManagementLoading());
    final result = await getDriverById(event.driverId);
    if (result is Error<DriverEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(DriverManagementError(errorMessage));
    } else if (result is Success<DriverEntity>) {
      final driver = result.data;
      emit(DriverLoaded(driver));
    }
  }

  Future<void> _onAssignDriverToBus(
    AssignDriverToBusEvent event,
    Emitter<DriverManagementState> emit,
  ) async {
    emit(DriverManagementLoading());
    final result = await assignDriverToBus(
      driverId: event.driverId,
      busId: event.busId,
    );
    if (result is Error<DriverEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(DriverManagementError(errorMessage));
    } else if (result is Success<DriverEntity>) {
      final driver = result.data;
      emit(DriverAssigned(driver));
    }
  }

  Future<void> _onUpdateDriver(
    UpdateDriverEvent event,
    Emitter<DriverManagementState> emit,
  ) async {
    emit(DriverManagementLoading());
    final result = await updateDriver(
      driverId: event.driverId,
      name: event.name,
      email: event.email,
      licenseNumber: event.licenseNumber,
      licenseExpiry: event.licenseExpiry,
      address: event.address,
    );
    if (result is Error<DriverEntity>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(DriverManagementError(errorMessage));
    } else if (result is Success<DriverEntity>) {
      final driver = result.data;
      emit(DriverUpdated(driver));
    }
  }

  Future<void> _onDeleteDriver(
    DeleteDriverEvent event,
    Emitter<DriverManagementState> emit,
  ) async {
    emit(DriverManagementLoading());
    final result = await deleteDriver(event.driverId);
    if (result is Error<void>) {
      final failure = (result as Error<void>).failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(DriverManagementError(errorMessage));
    } else if (result is Success<void>) {
      emit(DriverDeleted());
    }
  }
}
