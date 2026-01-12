abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? agencyName;
  final String? ownerName;
  final String? panVatNumber;
  final String? address;
  final String? districtProvince;
  final String? primaryContact;
  final String? alternateContact;
  final String? whatsappViber;
  final String? officeLocation;
  final String? officeOpenTime;
  final String? officeCloseTime;
  final int? numberOfEmployees;
  final bool? hasDeviceAccess;
  final bool? hasInternetAccess;
  final String? preferredBookingMethod;
  final String? avatarPath;

  UpdateProfileEvent({
    this.agencyName,
    this.ownerName,
    this.panVatNumber,
    this.address,
    this.districtProvince,
    this.primaryContact,
    this.alternateContact,
    this.whatsappViber,
    this.officeLocation,
    this.officeOpenTime,
    this.officeCloseTime,
    this.numberOfEmployees,
    this.hasDeviceAccess,
    this.hasInternetAccess,
    this.preferredBookingMethod,
    this.avatarPath,
  });
}
