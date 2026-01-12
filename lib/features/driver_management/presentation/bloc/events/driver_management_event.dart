abstract class DriverManagementEvent {}

class GetDriversEvent extends DriverManagementEvent {
  final String? status;
  final String? busId;

  GetDriversEvent({this.status, this.busId});
}

class InviteDriverEvent extends DriverManagementEvent {
  final String name;
  final String phoneNumber;
  final String? email;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String? address;
  final String? busId;

  InviteDriverEvent({
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.address,
    this.busId,
  });
}

class GetDriverByIdEvent extends DriverManagementEvent {
  final String driverId;

  GetDriverByIdEvent(this.driverId);
}

class AssignDriverToBusEvent extends DriverManagementEvent {
  final String driverId;
  final String busId;

  AssignDriverToBusEvent({required this.driverId, required this.busId});
}

class UpdateDriverEvent extends DriverManagementEvent {
  final String driverId;
  final String? name;
  final String? email;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? address;

  UpdateDriverEvent({
    required this.driverId,
    this.name,
    this.email,
    this.licenseNumber,
    this.licenseExpiry,
    this.address,
  });
}

class DeleteDriverEvent extends DriverManagementEvent {
  final String driverId;

  DeleteDriverEvent(this.driverId);
}
