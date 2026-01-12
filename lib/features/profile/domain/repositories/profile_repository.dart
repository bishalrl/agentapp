import '../../../../core/utils/result.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Result<ProfileEntity>> getProfile();
  Future<Result<ProfileEntity>> updateProfile({
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
  });
}
