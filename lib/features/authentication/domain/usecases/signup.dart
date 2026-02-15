import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';
import 'dart:io';

class Signup {
  final AuthRepository repository;

  Signup(this.repository);

  Future<Result<AuthEntity>> call({
    required String agencyName,
    required String ownerName,
    required String address,
    required String districtProvince,
    required String primaryContact,
    required String email,
    required String officeLocation,
    required String officeOpenTime,
    required String officeCloseTime,
    required int numberOfEmployees,
    required bool hasDeviceAccess,
    required bool hasInternetAccess,
    required String preferredBookingMethod,
    required String password,
    required File citizenshipFile,
    required File photoFile,
    String? panVatNumber,
    String? alternateContact,
    String? whatsappViber,
    File? panFile,
    File? registrationFile,
    required String otp,
  }) async {
    return await repository.signup(
      agencyName: agencyName,
      ownerName: ownerName,
      address: address,
      districtProvince: districtProvince,
      primaryContact: primaryContact,
      email: email,
      officeLocation: officeLocation,
      officeOpenTime: officeOpenTime,
      officeCloseTime: officeCloseTime,
      numberOfEmployees: numberOfEmployees,
      hasDeviceAccess: hasDeviceAccess,
      hasInternetAccess: hasInternetAccess,
      preferredBookingMethod: preferredBookingMethod,
      password: password,
      citizenshipFile: citizenshipFile,
      photoFile: photoFile,
      panVatNumber: panVatNumber,
      alternateContact: alternateContact,
      whatsappViber: whatsappViber,
      panFile: panFile,
      registrationFile: registrationFile,
      otp: otp,
    );
  }
}
