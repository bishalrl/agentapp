import '../../../../../core/bloc/base_bloc_event.dart';

abstract class DriverEvent extends BaseBlocEvent {
  const DriverEvent();
}

class VerifyDriverOtpEvent extends DriverEvent {
  final String phoneNumber;
  final String otp;

  const VerifyDriverOtpEvent({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class GetDriverProfileEvent extends DriverEvent {
  const GetDriverProfileEvent();
}

class GetAssignedBusesEvent extends DriverEvent {
  const GetAssignedBusesEvent();
}

