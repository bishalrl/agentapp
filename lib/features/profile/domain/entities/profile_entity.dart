class ProfileEntity {
  final String id;
  final String agencyName;
  final String ownerName;
  final String email;
  final String? panVatNumber;
  final String address;
  final String districtProvince;
  final String primaryContact;
  final String? alternateContact;
  final String? whatsappViber;
  final String officeLocation;
  final String officeOpenTime;
  final String officeCloseTime;
  final int numberOfEmployees;
  final bool hasDeviceAccess;
  final bool hasInternetAccess;
  final String preferredBookingMethod;
  final double walletBalance;
  final String? avatarUrl;
  final bool isVerified;

  ProfileEntity({
    required this.id,
    required this.agencyName,
    required this.ownerName,
    required this.email,
    this.panVatNumber,
    required this.address,
    required this.districtProvince,
    required this.primaryContact,
    this.alternateContact,
    this.whatsappViber,
    required this.officeLocation,
    required this.officeOpenTime,
    required this.officeCloseTime,
    required this.numberOfEmployees,
    required this.hasDeviceAccess,
    required this.hasInternetAccess,
    required this.preferredBookingMethod,
    required this.walletBalance,
    this.avatarUrl,
    required this.isVerified,
  });
}
