import 'dart:io';
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

class RegisterDriverWithInvitationEvent extends DriverEvent {
  final String invitationCode;
  final String email;
  final String phoneNumber;
  final String password;
  final String name;
  final String licenseNumber;

  const RegisterDriverWithInvitationEvent({
    required this.invitationCode,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.name,
    required this.licenseNumber,
  });

  @override
  List<Object?> get props => [
        invitationCode,
        email,
        phoneNumber,
        password,
        name,
        licenseNumber,
      ];
}

class DriverLoginEvent extends DriverEvent {
  final String? email;
  final String? phoneNumber;
  final String password;
  final bool? hasOTP;
  final String? otp;

  const DriverLoginEvent({
    this.email,
    this.phoneNumber,
    required this.password,
    this.hasOTP,
    this.otp,
  });

  @override
  List<Object?> get props => [email, phoneNumber, password, hasOTP, otp];
}

class GetDriverDashboardEvent extends DriverEvent {
  /// When true, skips 5-minute throttle and fetches from API.
  final bool forceRefresh;

  const GetDriverDashboardEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class UpdateDriverProfileEvent extends DriverEvent {
  final String? name;
  final String? email;

  const UpdateDriverProfileEvent({
    this.name,
    this.email,
  });

  @override
  List<Object?> get props => [name, email];
}

class RegisterDriverWithInvitationFileEvent extends DriverEvent {
  final String invitationCode;
  final String email;
  final String phoneNumber;
  final String password;
  final String name;
  final String licenseNumber;
  final File? licensePhoto;
  final File? driverPhoto;

  const RegisterDriverWithInvitationFileEvent({
    required this.invitationCode,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.name,
    required this.licenseNumber,
    this.licensePhoto,
    this.driverPhoto,
  });

  @override
  List<Object?> get props => [
        invitationCode,
        email,
        phoneNumber,
        password,
        name,
        licenseNumber,
        licensePhoto,
        driverPhoto,
      ];
}

class RegisterDriverEvent extends DriverEvent {
  final String name;
  final String phoneNumber;
  final String? email;
  final String password;
  final String licenseNumber;
  final File? licensePhoto;
  final File? driverPhoto;
  final bool? hasOTP;
  final String? otp;

  const RegisterDriverEvent({
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.licenseNumber,
    this.licensePhoto,
    this.driverPhoto,
    this.hasOTP,
    this.otp,
  });

  @override
  List<Object?> get props => [
        name,
        phoneNumber,
        email,
        password,
        licenseNumber,
        licensePhoto,
        driverPhoto,
        hasOTP,
        otp,
      ];
}

class MarkBusAsReachedEvent extends DriverEvent {
  final String busId;

  const MarkBusAsReachedEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class StopLocationSharingEvent extends DriverEvent {
  /// Optional. When ending a ride from the map, pass [busId] so the backend can target that bus.
  final String? busId;

  const StopLocationSharingEvent({this.busId});

  @override
  List<Object?> get props => [busId];
}

class GetPendingRequestsEvent extends DriverEvent {
  const GetPendingRequestsEvent();
}

class AcceptRequestEvent extends DriverEvent {
  final String requestId;

  const AcceptRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class RejectRequestEvent extends DriverEvent {
  final String requestId;

  const RejectRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// Owner join flow: already-registered driver sees owner invitations and can accept/reject.
class GetOwnerInvitationsEvent extends DriverEvent {
  const GetOwnerInvitationsEvent();

  @override
  List<Object?> get props => [];
}

class AcceptOwnerInvitationEvent extends DriverEvent {
  final String invitationId;

  const AcceptOwnerInvitationEvent({required this.invitationId});

  @override
  List<Object?> get props => [invitationId];
}

class RejectOwnerInvitationEvent extends DriverEvent {
  final String invitationId;

  const RejectOwnerInvitationEvent({required this.invitationId});

  @override
  List<Object?> get props => [invitationId];
}

class GetBusDetailsEvent extends DriverEvent {
  final String busId;

  const GetBusDetailsEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class InitiateRideEvent extends DriverEvent {
  final String busId;

  const InitiateRideEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class UpdateDriverLocationEvent extends DriverEvent {
  final String busId;
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final double? accuracy;

  const UpdateDriverLocationEvent({
    required this.busId,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    this.accuracy,
  });

  @override
  List<Object?> get props => [busId, latitude, longitude, speed, heading, accuracy];
}

class GetBusPassengersEvent extends DriverEvent {
  final String busId;

  const GetBusPassengersEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class VerifyTicketEvent extends DriverEvent {
  final String qrCode;
  final String busId;
  final int? seatNumber;

  const VerifyTicketEvent({
    required this.qrCode,
    required this.busId,
    this.seatNumber,
  });

  @override
  List<Object?> get props => [qrCode, busId, seatNumber];
}

class CreateDriverBookingEvent extends DriverEvent {
  final String busId;
  final List<dynamic> seatNumbers;
  final String passengerName;
  final String contactNumber;
  final String? passengerEmail;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? luggage;
  final int? bagCount;
  final String paymentMethod;

  const CreateDriverBookingEvent({
    required this.busId,
    required this.seatNumbers,
    required this.passengerName,
    required this.contactNumber,
    this.passengerEmail,
    this.pickupLocation,
    this.dropoffLocation,
    this.luggage,
    this.bagCount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        busId,
        seatNumbers,
        passengerName,
        contactNumber,
        passengerEmail,
        pickupLocation,
        dropoffLocation,
        luggage,
        bagCount,
        paymentMethod,
      ];
}

class RequestPermissionEvent extends DriverEvent {
  final String permissionType;
  final String? busId;
  final String? message;

  const RequestPermissionEvent({
    required this.permissionType,
    this.busId,
    this.message,
  });

  @override
  List<Object?> get props => [permissionType, busId, message];
}

class GetPermissionRequestsEvent extends DriverEvent {
  const GetPermissionRequestsEvent();

  @override
  List<Object?> get props => [];
}

