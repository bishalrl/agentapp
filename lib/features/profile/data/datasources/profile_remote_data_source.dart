import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/multipart_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String token);
  Future<ProfileModel> updateProfile({
    required String token,
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
    File? avatar,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;
  final MultipartClient multipartClient;

  ProfileRemoteDataSourceImpl(this.apiClient, this.multipartClient);

  @override
  Future<ProfileModel> getProfile(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.counterProfile,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return ProfileModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get profile');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get profile: ${e.toString()}');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String token,
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
    File? avatar,
  }) async {
    try {
      final fields = <String, String>{};
      if (agencyName != null) fields['agencyName'] = agencyName;
      if (ownerName != null) fields['ownerName'] = ownerName;
      if (panVatNumber != null) fields['panVatNumber'] = panVatNumber;
      if (address != null) fields['address'] = address;
      if (districtProvince != null) fields['districtProvince'] = districtProvince;
      if (primaryContact != null) fields['primaryContact'] = primaryContact;
      if (alternateContact != null) fields['alternateContact'] = alternateContact;
      if (whatsappViber != null) fields['whatsappViber'] = whatsappViber;
      if (officeLocation != null) fields['officeLocation'] = officeLocation;
      if (officeOpenTime != null) fields['officeOpenTime'] = officeOpenTime;
      if (officeCloseTime != null) fields['officeCloseTime'] = officeCloseTime;
      if (numberOfEmployees != null) fields['numberOfEmployees'] = numberOfEmployees.toString();
      if (hasDeviceAccess != null) fields['hasDeviceAccess'] = hasDeviceAccess.toString();
      if (hasInternetAccess != null) fields['hasInternetAccess'] = hasInternetAccess.toString();
      if (preferredBookingMethod != null) fields['preferredBookingMethod'] = preferredBookingMethod;

      final files = <String, File>{};
      if (avatar != null) files['avatar'] = avatar;

      final response = await multipartClient.putMultipart(
        endpoint: ApiConstants.counterProfile,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        fields: fields,
        files: files,
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return ProfileModel.fromJson(response['data']);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to update profile');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }
}
