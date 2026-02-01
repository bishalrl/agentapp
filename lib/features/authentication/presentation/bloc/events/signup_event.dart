import 'dart:io';
import '../../../../../core/bloc/base_bloc_event.dart';

abstract class SignupEvent extends BaseBlocEvent {
  const SignupEvent();
}

class SignupRequestEvent extends SignupEvent {
  final String type; // 'counter' or 'betaAgent'
  final String agencyName;
  final String ownerName;
  final String? name; // Required for Beta Agent
  final String address;
  final String districtProvince;
  final String primaryContact;
  final String email;
  final String? officeLocation; // Required for Counter only
  final String? officeOpenTime; // Required for Counter only
  final String? officeCloseTime; // Required for Counter only
  final int? numberOfEmployees; // Required for Counter only
  final bool? hasDeviceAccess; // Required for Counter only
  final bool? hasInternetAccess; // Required for Counter only
  final String? preferredBookingMethod; // Required for Counter only
  final String password;
  final File citizenshipFile;
  final File photoFile;
  final File? nameMatchImage; // Optional for Beta Agent
  final String? panVatNumber;
  final String? alternateContact;
  final String? whatsappViber;
  final File? panFile;
  final File? registrationFile;

  const SignupRequestEvent({
    required this.type,
    required this.agencyName,
    required this.ownerName,
    this.name,
    required this.address,
    required this.districtProvince,
    required this.primaryContact,
    required this.email,
    this.officeLocation,
    this.officeOpenTime,
    this.officeCloseTime,
    this.numberOfEmployees,
    this.hasDeviceAccess,
    this.hasInternetAccess,
    this.preferredBookingMethod,
    required this.password,
    required this.citizenshipFile,
    required this.photoFile,
    this.nameMatchImage,
    this.panVatNumber,
    this.alternateContact,
    this.whatsappViber,
    this.panFile,
    this.registrationFile,
  });

  @override
  List<Object?> get props => [
        type,
        agencyName,
        ownerName,
        name,
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
        nameMatchImage,
        panVatNumber,
        alternateContact,
        whatsappViber,
        panFile,
        registrationFile,
      ];
}
