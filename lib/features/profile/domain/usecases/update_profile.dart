import '../../../../core/utils/result.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<Result<ProfileEntity>> call({
    String? agencyName,
    String? ownerName,
    String? panVatNumber,
    String? address,
    String? districtProvince,
    String? primaryContact,
    String? alternateContact,
    String? whatsappViber,
    String? officeLocation,
    String? officeOpenTime,
    String? officeCloseTime,
    int? numberOfEmployees,
    bool? hasDeviceAccess,
    bool? hasInternetAccess,
    String? preferredBookingMethod,
    String? avatarPath,
  }) async {
    return await repository.updateProfile(
      agencyName: agencyName,
      ownerName: ownerName,
      panVatNumber: panVatNumber,
      address: address,
      districtProvince: districtProvince,
      primaryContact: primaryContact,
      alternateContact: alternateContact,
      whatsappViber: whatsappViber,
      officeLocation: officeLocation,
      officeOpenTime: officeOpenTime,
      officeCloseTime: officeCloseTime,
      numberOfEmployees: numberOfEmployees,
      hasDeviceAccess: hasDeviceAccess,
      hasInternetAccess: hasInternetAccess,
      preferredBookingMethod: preferredBookingMethod,
      avatarPath: avatarPath,
    );
  }
}
