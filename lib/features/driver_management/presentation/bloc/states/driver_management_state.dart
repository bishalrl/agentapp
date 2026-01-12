import '../../../domain/entities/driver_entity.dart';

abstract class DriverManagementState {}

class DriverManagementInitial extends DriverManagementState {}

class DriverManagementLoading extends DriverManagementState {}

class DriversLoaded extends DriverManagementState {
  final List<DriverEntity> drivers;

  DriversLoaded(this.drivers);
}

class DriverLoaded extends DriverManagementState {
  final DriverEntity driver;

  DriverLoaded(this.driver);
}

class DriverInvited extends DriverManagementState {
  final DriverEntity driver;

  DriverInvited(this.driver);
}

class DriverUpdated extends DriverManagementState {
  final DriverEntity driver;

  DriverUpdated(this.driver);
}

class DriverAssigned extends DriverManagementState {
  final DriverEntity driver;

  DriverAssigned(this.driver);
}

class DriverDeleted extends DriverManagementState {}

class DriverManagementError extends DriverManagementState {
  final String message;

  DriverManagementError(this.message);
}
