import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';
import 'dart:io';

class Signup {
  final AuthRepository repository;

  Signup(this.repository);

  Future<Result<AuthEntity>> call({
    required String type,
    required String agencyName,
    required String ownerName,
    String? name,
    required String address,
    required String districtProvince,
    required String primaryContact,
    required String email,
    String? officeLocation,
    String? officeOpenTime,
    String? officeCloseTime,
    int? numberOfEmployees,
    bool? hasDeviceAccess,
    bool? hasInternetAccess,
    String? preferredBookingMethod,
    required String password,
    required File citizenshipFile,
    required File photoFile,
    File? nameMatchImage,
    String? panVatNumber,
    String? alternateContact,
    String? whatsappViber,
    File? panFile,
    File? registrationFile,
  }) async {
    return await repository.signup(
      type: type,
      agencyName: agencyName,
      ownerName: ownerName,
      name: name,
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
      nameMatchImage: nameMatchImage,
      panVatNumber: panVatNumber,
      alternateContact: alternateContact,
      whatsappViber: whatsappViber,
      panFile: panFile,
      registrationFile: registrationFile,
    );
  }
}
