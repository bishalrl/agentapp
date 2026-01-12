import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.id,
    required super.agencyName,
    required super.ownerName,
    required super.email,
    super.panVatNumber,
    required super.address,
    required super.districtProvince,
    required super.primaryContact,
    super.alternateContact,
    super.whatsappViber,
    required super.officeLocation,
    required super.officeOpenTime,
    required super.officeCloseTime,
    required super.numberOfEmployees,
    required super.hasDeviceAccess,
    required super.hasInternetAccess,
    required super.preferredBookingMethod,
    required super.walletBalance,
    super.avatarUrl,
    required super.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final counter = json['counter'] ?? json;
    return ProfileModel(
      id: counter['_id'] ?? counter['id'] ?? '',
      agencyName: counter['agencyName'] ?? '',
      ownerName: counter['ownerName'] ?? '',
      email: counter['email'] ?? '',
      panVatNumber: counter['panVatNumber'],
      address: counter['address'] ?? '',
      districtProvince: counter['districtProvince'] ?? '',
      primaryContact: counter['primaryContact'] ?? '',
      alternateContact: counter['alternateContact'],
      whatsappViber: counter['whatsappViber'],
      officeLocation: counter['officeLocation'] ?? '',
      officeOpenTime: counter['officeOpenTime'] ?? '',
      officeCloseTime: counter['officeCloseTime'] ?? '',
      numberOfEmployees: counter['numberOfEmployees'] ?? 0,
      hasDeviceAccess: counter['hasDeviceAccess'] ?? false,
      hasInternetAccess: counter['hasInternetAccess'] ?? false,
      preferredBookingMethod: counter['preferredBookingMethod'] ?? '',
      walletBalance: (counter['walletBalance'] ?? 0).toDouble(),
      avatarUrl: counter['avatarUrl'] ?? counter['avatar'],
      isVerified: counter['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agencyName': agencyName,
      'ownerName': ownerName,
      'email': email,
      if (panVatNumber != null) 'panVatNumber': panVatNumber,
      'address': address,
      'districtProvince': districtProvince,
      'primaryContact': primaryContact,
      if (alternateContact != null) 'alternateContact': alternateContact,
      if (whatsappViber != null) 'whatsappViber': whatsappViber,
      'officeLocation': officeLocation,
      'officeOpenTime': officeOpenTime,
      'officeCloseTime': officeCloseTime,
      'numberOfEmployees': numberOfEmployees,
      'hasDeviceAccess': hasDeviceAccess,
      'hasInternetAccess': hasInternetAccess,
      'preferredBookingMethod': preferredBookingMethod,
    };
  }
}
