import 'dart:io';
import '../../../../../core/bloc/base_bloc_event.dart';

abstract class SignupEvent extends BaseBlocEvent {
  const SignupEvent();
}

class SignupRequestEvent extends SignupEvent {
  final String agencyName;
  final String ownerName;
  final String address;
  final String districtProvince;
  final String primaryContact;
  final String email;
  final String officeLocation;
  final String officeOpenTime;
  final String officeCloseTime;
  final int numberOfEmployees;
  final bool hasDeviceAccess;
  final bool hasInternetAccess;
  final String preferredBookingMethod;
  final String password;
  final File citizenshipFile;
  final File photoFile;
  final String? panVatNumber;
  final String? alternateContact;
  final String? whatsappViber;
  final File? panFile;
  final File? registrationFile;

  const SignupRequestEvent({
    required this.agencyName,
    required this.ownerName,
    required this.address,
    required this.districtProvince,
    required this.primaryContact,
    required this.email,
    required this.officeLocation,
    required this.officeOpenTime,
    required this.officeCloseTime,
    required this.numberOfEmployees,
    required this.hasDeviceAccess,
    required this.hasInternetAccess,
    required this.preferredBookingMethod,
    required this.password,
    required this.citizenshipFile,
    required this.photoFile,
    this.panVatNumber,
    this.alternateContact,
    this.whatsappViber,
    this.panFile,
    this.registrationFile,
  });

  @override
  List<Object?> get props => [
        agencyName,
        ownerName,
        address,
        districtProvince,
        primaryContact,
        email,
        officeLocation,
        officeOpenTime,
        officeCloseTime,
        numberOfEmployees,
        hasDeviceAccess,
        hasInternetAccess,
        preferredBookingMethod,
        password,
        citizenshipFile,
        photoFile,
        panVatNumber,
        alternateContact,
        whatsappViber,
        panFile,
        registrationFile,
      ];
}
