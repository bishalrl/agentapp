import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/multipart_client.dart';
import '../../../../core/utils/phone_normalizer.dart';
import '../models/driver_model.dart';

abstract class DriverRemoteDataSource {
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp); // Returns driver and token
  Future<Map<String, dynamic>> register({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String licenseNumber,
    File? licensePhoto, // Optional license photo file
    File? driverPhoto, // Optional driver photo file
    bool? hasOTP, // Optional: true if driver has OTP for owner association
    String? otp, // Optional: OTP code for owner association
  }); // Independent registration (no invitation code) - supports OTP-based association
  Future<Map<String, dynamic>> registerWithInvitation({
    required String invitationCode,
    required String email,
    required String phoneNumber,
    required String password,
    required String name,
    required String licenseNumber,
    File? licensePhoto, // Optional license photo file
    File? driverPhoto, // Optional driver photo file
  });
  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
    bool? hasOTP, // Optional: true if driver has OTP for owner association
    String? otp, // Optional: OTP code for owner association
  }); // Returns driver and token - supports OTP-based association
  Future<Map<String, dynamic>> getDriverDashboard(String token); // Returns dashboard data with buses and seat details
  Future<DriverModel> getDriverProfile(String token);
  Future<Map<String, dynamic>> getDriverProfileWithInviter(String token); // Returns full profile data including inviter
  Future<DriverModel> updateDriverProfile({
    required String token,
    String? name,
    String? email,
  }); // Update driver profile
  Future<List<BusModel>> getAssignedBuses(String token);
  Future<void> startLocationSharing(String token, String busId);
  Future<void> stopLocationSharing(String token, {String? busId});
  Future<void> updateLocation(String token, {
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  });
  Future<Map<String, dynamic>> getTripStatus(String token, String busId);
  Future<void> markBusAsReached(String token, String busId); // Mark bus as reached destination
  Future<Map<String, dynamic>> getPendingRequests(String token); // Get pending bus assignment requests
  Future<Map<String, dynamic>> acceptRequest(String token, String requestId); // Accept bus assignment request
  Future<Map<String, dynamic>> rejectRequest(String token, String requestId); // Reject bus assignment request
  // Owner join flow: list / accept / reject owner invitations (already-registered driver)
  Future<Map<String, dynamic>> getOwnerInvitations(String token);
  Future<Map<String, dynamic>> acceptOwnerInvitation(String token, String invitationId);
  Future<Map<String, dynamic>> rejectOwnerInvitation(String token, String invitationId);
  Future<Map<String, dynamic>> getBusDetails(String token, String busId); // Get detailed bus information with full passenger data
  
  // Driver Ride Management
  Future<Map<String, dynamic>> initiateRide(String token, String busId); // Initiate ride and get route with GPS coordinates
  Future<Map<String, dynamic>> updateDriverLocation(String token, {
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }); // Update driver location during ride
  
  // Driver Booking
  Future<Map<String, dynamic>> createDriverBooking(String token, {
    required String busId,
    required List<dynamic> seatNumbers,
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
  }); // Create booking as driver
  
  // Driver Scan/Ticket Verification
  Future<Map<String, dynamic>> getBusPassengers(String token, String busId); // Get passenger list with seat numbers
  Future<Map<String, dynamic>> verifyTicket(String token, {
    required String qrCode,
    required String busId,
    int? seatNumber,
  }); // Verify ticket via QR code scan
  
  // Driver Permission Requests
  Future<Map<String, dynamic>> requestPermission(String token, {
    required String permissionType,
    String? busId,
    String? message,
  }); // Request permission from owner
  Future<Map<String, dynamic>> getPermissionRequests(String token); // Get driver's permission requests
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final ApiClient apiClient;
  final MultipartClient multipartClient;
  
  DriverRemoteDataSourceImpl(this.apiClient, this.multipartClient);
  
  @override
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      print('📤 DriverRemoteDataSource.verifyOtp: Sending request');
      print('   PhoneNumber: $phoneNumber');
      
      final response = await apiClient.post(
        ApiConstants.driverVerifyOtp,
        body: {
          'phoneNumber': phoneNumber,
          'otp': otp,
        },
      );
      
      print('📥 DriverRemoteDataSource.verifyOtp: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Token might be in response['data']['token'] or response['token']
        final token = data['token'] as String? ?? response['token'] as String?;
        if (token != null) {
          print('   ✅ Token received from OTP verification');
        }
        // Return both driver and token
        return {
          'driver': data['driver'] as Map<String, dynamic>,
          'token': token,
        };
      } else {
        throw ServerException(response['message'] as String? ?? 'OTP verification failed');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> registerWithInvitation({
    required String invitationCode,
    required String email,
    required String phoneNumber,
    required String password,
    required String name,
    required String licenseNumber,
    File? licensePhoto,
    File? driverPhoto,
  }) async {
    try {
      print('📤 DriverRemoteDataSource.registerWithInvitation: Sending multipart request');
      print('   InvitationCode: $invitationCode, Email: $email, Name: $name');
      print('   LicensePhoto: ${licensePhoto?.path ?? "not provided"}');
      print('   DriverPhoto: ${driverPhoto?.path ?? "not provided"}');
      
      // Prepare form fields (all as strings for multipart)
      final fields = <String, String>{
        'invitationCode': invitationCode,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'name': name,
        'licenseNumber': licenseNumber,
      };
      
      // Prepare files for multipart
      final files = <String, File>{};
      if (licensePhoto != null) {
        files['licensePhoto'] = licensePhoto;
        print('   ✅ Added licensePhoto file: ${licensePhoto.path}');
      }
      if (driverPhoto != null) {
        files['driverPhoto'] = driverPhoto;
        print('   ✅ Added driverPhoto file: ${driverPhoto.path}');
      }
      
      final response = await multipartClient.postMultipart(
        endpoint: ApiConstants.driverRegisterWithInvitation,
        fields: fields,
        files: files,
        token: null, // Public endpoint
      );
      
      print('📥 DriverRemoteDataSource.registerWithInvitation: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Driver registration failed');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to register driver: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
    bool? hasOTP,
    String? otp,
  }) async {
    try {
      print('📤 DriverRemoteDataSource.login: Sending request');
      print('   Email: $email, PhoneNumber: $phoneNumber');
      print('   HasOTP: $hasOTP, OTP: ${otp != null ? "***" : null}');
      
      final body = <String, dynamic>{
        'password': password,
      };
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phoneNumber'] = phoneNumber;
      }
      if (hasOTP == true && otp != null && otp.isNotEmpty) {
        body['hasOTP'] = true;
        body['otp'] = otp;
      }
      
      final response = await apiClient.post(
        ApiConstants.driverLogin,
        body: body,
      );
      
      print('📥 DriverRemoteDataSource.login: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return {
          'driver': data['driver'] as Map<String, dynamic>,
          'token': data['token'] as String?,
        };
      } else {
        throw ServerException(response['message'] as String? ?? 'Driver login failed');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to login driver: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getDriverDashboard(String token) async {
    try {
      print('📤 DriverRemoteDataSource.getDriverDashboard: Sending request');
      
      final response = await apiClient.get(
        ApiConstants.driverDashboard,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.getDriverDashboard: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get driver dashboard');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get driver dashboard: ${e.toString()}');
    }
  }
  
  @override
  Future<DriverModel> getDriverProfile(String token) async {
    try {
      print('📤 DriverRemoteDataSource.getDriverProfile: Sending request');
      
      final response = await apiClient.get(
        ApiConstants.driverProfile,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.getDriverProfile: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        // Extract inviter if present (for display on profile page)
        final inviter = data['inviter'] as Map<String, dynamic>?;
        if (inviter != null) {
          print('   ✅ Inviter information found in profile response');
        }
        // Return driver model (inviter will be stored separately in state if needed)
        return DriverModel.fromJson(data);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get profile');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get driver profile: ${e.toString()}');
    }
  }
  
  // Helper method to get full profile response including inviter
  Future<Map<String, dynamic>> getDriverProfileWithInviter(String token) async {
    try {
      print('📤 DriverRemoteDataSource.getDriverProfileWithInviter: Sending request');
      
      final response = await apiClient.get(
        ApiConstants.driverProfile,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.getDriverProfileWithInviter: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get profile');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get driver profile: ${e.toString()}');
    }
  }
  
  @override
  Future<DriverModel> updateDriverProfile({
    required String token,
    String? name,
    String? email,
  }) async {
    try {
      print('📤 DriverRemoteDataSource.updateDriverProfile: Sending request');
      print('   Name: $name, Email: $email');
      
      final body = <String, dynamic>{};
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (email != null && email.isNotEmpty) body['email'] = email;
      
      final response = await apiClient.put(
        ApiConstants.driverProfile,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 DriverRemoteDataSource.updateDriverProfile: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return DriverModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to update profile');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update driver profile: ${e.toString()}');
    }
  }
  
  @override
  Future<List<BusModel>> getAssignedBuses(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.driverAssignedBuses,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        final buses = response['data'] as List<dynamic>;
        return buses.map((bus) => BusModel.fromJson(bus as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get buses');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get assigned buses: ${e.toString()}');
    }
  }
  
  @override
  Future<void> startLocationSharing(String token, String busId) async {
    try {
      final response = await apiClient.post(
        ApiConstants.driverLocationStart,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {'busId': busId},
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to start location sharing');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to start location sharing: ${e.toString()}');
    }
  }
  
  @override
  Future<void> stopLocationSharing(String token, {String? busId}) async {
    try {
      final body = busId != null && busId.isNotEmpty ? {'busId': busId} : null;
      final response = await apiClient.post(
        ApiConstants.driverLocationStop,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to stop location sharing');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to stop location sharing: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateLocation(String token, {
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    try {
      final body = <String, dynamic>{
        'busId': busId,
        'latitude': latitude,
        'longitude': longitude,
      };
      
      if (speed != null) body['speed'] = speed;
      if (heading != null) body['heading'] = heading;
      if (accuracy != null) body['accuracy'] = accuracy;
      
      final response = await apiClient.post(
        ApiConstants.locationUpdate,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to update location');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update location: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getTripStatus(String token, String busId) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.driverTripStatus}?busId=$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get trip status');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get trip status: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String licenseNumber,
    File? licensePhoto,
    File? driverPhoto,
    bool? hasOTP,
    String? otp,
  }) async {
    try {
      print('📤 DriverRemoteDataSource.register: Sending multipart request');
      print('   Name: $name, PhoneNumber: $phoneNumber, Email: $email');
      print('   LicenseNumber: $licenseNumber');
      print('   HasOTP: $hasOTP, OTP: ${otp != null ? "***" : null}');
      print('   LicensePhoto: ${licensePhoto?.path ?? "not provided"}');
      print('   DriverPhoto: ${driverPhoto?.path ?? "not provided"}');
      
      // Prepare form fields (all as strings for multipart)
      final fields = <String, String>{
        'name': name,
        'phoneNumber': phoneNumber,
        'password': password,
        'licenseNumber': licenseNumber,
      };
      
      if (email != null && email.isNotEmpty) {
        fields['email'] = email;
      }
      if (hasOTP == true && otp != null && otp.isNotEmpty) {
        fields['hasOTP'] = 'true';
        fields['otp'] = otp;
      }
      
      // Prepare files for multipart
      final files = <String, File>{};
      if (licensePhoto != null) {
        files['licensePhoto'] = licensePhoto;
        print('   ✅ Added licensePhoto file: ${licensePhoto.path}');
      }
      if (driverPhoto != null) {
        files['driverPhoto'] = driverPhoto;
        print('   ✅ Added driverPhoto file: ${driverPhoto.path}');
      }
      
      final response = await multipartClient.postMultipart(
        endpoint: ApiConstants.driverRegister,
        fields: fields,
        files: files,
        token: null, // Public endpoint
      );
      
      print('📥 DriverRemoteDataSource.register: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Driver registration failed');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to register driver: ${e.toString()}');
    }
  }

  @override
  Future<void> markBusAsReached(String token, String busId) async {
    try {
      print('📤 DriverRemoteDataSource.markBusAsReached: Sending request');
      print('   BusId: $busId');
      
      final response = await apiClient.post(
        ApiConstants.driverMarkReached,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {'busId': busId},
      );
      
      print('📥 DriverRemoteDataSource.markBusAsReached: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] != true) {
        throw ServerException(response['message'] as String? ?? 'Failed to mark bus as reached');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to mark bus as reached: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPendingRequests(String token) async {
    try {
      print('📤 DriverRemoteDataSource.getPendingRequests: Sending request');
      
      final response = await apiClient.get(
        ApiConstants.driverPendingRequests,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.getPendingRequests: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get pending requests');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get pending requests: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> acceptRequest(String token, String requestId) async {
    try {
      print('📤 DriverRemoteDataSource.acceptRequest: Sending request');
      print('   RequestId: $requestId');
      
      final response = await apiClient.post(
        '${ApiConstants.driverAcceptRequest}/$requestId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.acceptRequest: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to accept request');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to accept request: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> rejectRequest(String token, String requestId) async {
    try {
      print('📤 DriverRemoteDataSource.rejectRequest: Sending request');
      print('   RequestId: $requestId');
      
      final response = await apiClient.post(
        '${ApiConstants.driverRejectRequest}/$requestId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.rejectRequest: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to reject request');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to reject request: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getOwnerInvitations(String token) async {
    try {
      final response = await apiClient.get(
        ApiConstants.driverOwnerInvitations,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      if (response['success'] == true && response['data'] != null) {
        return response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : {'invitations': response['data'] is List ? response['data'] : []};
      }
      throw ServerException(response['message'] as String? ?? 'Failed to get owner invitations');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get owner invitations: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> acceptOwnerInvitation(String token, String invitationId) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.driverOwnerInvitationAccept}/$invitationId/accept',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      if (response['success'] == true) {
        return response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : <String, dynamic>{};
      }
      throw ServerException(response['message'] as String? ?? 'Failed to accept owner invitation');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to accept owner invitation: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> rejectOwnerInvitation(String token, String invitationId) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.driverOwnerInvitationReject}/$invitationId/reject',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      if (response['success'] == true) {
        return response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : <String, dynamic>{};
      }
      throw ServerException(response['message'] as String? ?? 'Failed to reject owner invitation');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to reject owner invitation: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getBusDetails(String token, String busId) async {
    try {
      print('📤 DriverRemoteDataSource.getBusDetails: Sending request');
      print('   BusId: $busId');
      
      final response = await apiClient.get(
        '${ApiConstants.driverBusDetails}/$busId',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.getBusDetails: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get bus details');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get bus details: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> initiateRide(String token, String busId) async {
    try {
      print('📤 DriverRemoteDataSource.initiateRide: Sending request');
      print('   BusId: $busId');
      
      final response = await apiClient.post(
        ApiConstants.driverRideInitiate,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'busId': busId,
        },
      );
      
      print('📥 DriverRemoteDataSource.initiateRide: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to initiate ride');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to initiate ride: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> updateDriverLocation(String token, {
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }) async {
    try {
      print('📤 DriverRemoteDataSource.updateDriverLocation: Sending request');
      print('   BusId: $busId, Lat: $latitude, Lng: $longitude');
      
      final body = <String, dynamic>{
        'busId': busId,
        'latitude': latitude,
        'longitude': longitude,
      };
      
      if (speed != null) body['speed'] = speed;
      if (heading != null) body['heading'] = heading;
      if (accuracy != null) body['accuracy'] = accuracy;
      
      final response = await apiClient.post(
        ApiConstants.driverLocationUpdate,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 DriverRemoteDataSource.updateDriverLocation: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to update location');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update location: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> createDriverBooking(String token, {
    required String busId,
    required List<dynamic> seatNumbers,
    required String passengerName,
    required String contactNumber,
    String? passengerEmail,
    String? pickupLocation,
    String? dropoffLocation,
    String? luggage,
    int? bagCount,
    required String paymentMethod,
  }) async {
    try {
      print('📤 DriverRemoteDataSource.createDriverBooking: Sending request');
      print('   BusId: $busId, Seats: $seatNumbers, Passenger: $passengerName');
      
      // Normalize seat numbers
      final normalizedSeatNumbers = seatNumbers.map((seat) {
        if (seat == null) return null;
        if (seat is int) return seat;
        if (seat is num) return seat.toInt();
        if (seat is String) {
          final numValue = int.tryParse(seat.trim());
          if (numValue != null && seat.trim() == numValue.toString()) {
            return numValue;
          }
          return seat.trim();
        }
        final str = seat.toString().trim();
        if (str.isEmpty) return null;
        final numValue = int.tryParse(str);
        if (numValue != null && str == numValue.toString()) {
          return numValue;
        }
        return str;
      }).where((seat) => seat != null).toList();
      
      final normalizedContact = PhoneNormalizer.normalizeNepalPhone(contactNumber);
      final contactForApi = PhoneNormalizer.isValidNormalizedNepalMobile(normalizedContact)
          ? normalizedContact
          : contactNumber;

      final body = <String, dynamic>{
        'busId': busId,
        'seatNumbers': normalizedSeatNumbers,
        'passengerName': passengerName,
        'contactNumber': contactForApi,
        'paymentMethod': paymentMethod,
      };
      
      if (passengerEmail != null && passengerEmail.isNotEmpty) {
        body['passengerEmail'] = passengerEmail;
      }
      if (pickupLocation != null && pickupLocation.isNotEmpty) {
        body['pickupLocation'] = pickupLocation;
      }
      if (dropoffLocation != null && dropoffLocation.isNotEmpty) {
        body['dropoffLocation'] = dropoffLocation;
      }
      if (luggage != null && luggage.isNotEmpty) {
        body['luggage'] = luggage;
      }
      if (bagCount != null && bagCount > 0) {
        body['bagCount'] = bagCount;
      }
      
      final response = await apiClient.post(
        ApiConstants.driverBookings,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 DriverRemoteDataSource.createDriverBooking: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        final message = response['message'] as String? ?? 'Failed to create booking';
        throw ServerException(message);
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to create booking: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getBusPassengers(String token, String busId) async {
    try {
      print('📤 DriverRemoteDataSource.getBusPassengers: Sending request');
      print('   BusId: $busId');
      
      final response = await apiClient.get(
        '${ApiConstants.driverBusPassengers}/$busId/passengers',
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.getBusPassengers: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get passengers');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get passengers: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyTicket(String token, {
    required String qrCode,
    required String busId,
    int? seatNumber,
  }) async {
    try {
      print('📤 DriverRemoteDataSource.verifyTicket: Sending request');
      print('   QRCode: $qrCode, BusId: $busId, SeatNumber: $seatNumber');
      
      final body = <String, dynamic>{
        'qrCode': qrCode,
        'busId': busId,
      };
      
      if (seatNumber != null) {
        body['seatNumber'] = seatNumber;
      }
      
      final response = await apiClient.post(
        ApiConstants.driverScanVerifyTicket,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 DriverRemoteDataSource.verifyTicket: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] as String? ?? 'Ticket verified successfully',
          'alreadyVerified': response['alreadyVerified'] as bool? ?? false,
          'data': response['data'] as Map<String, dynamic>?,
          'booking': response['booking'] as Map<String, dynamic>?,
        };
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to verify ticket');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to verify ticket: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> requestPermission(String token, {
    required String permissionType,
    String? busId,
    String? message,
  }) async {
    try {
      print('📤 DriverRemoteDataSource.requestPermission: Sending request');
      print('   PermissionType: $permissionType, BusId: $busId');
      
      final body = <String, dynamic>{
        'permissionType': permissionType,
      };
      
      if (busId != null) body['busId'] = busId;
      if (message != null && message.isNotEmpty) body['message'] = message;
      
      final response = await apiClient.post(
        ApiConstants.driverPermissionRequest,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: body,
      );
      
      print('📥 DriverRemoteDataSource.requestPermission: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to request permission');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to request permission: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPermissionRequests(String token) async {
    try {
      print('📤 DriverRemoteDataSource.getPermissionRequests: Sending request');
      
      final response = await apiClient.get(
        ApiConstants.driverPermissionRequests,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
      );
      
      print('📥 DriverRemoteDataSource.getPermissionRequests: Response received');
      print('   Success: ${response['success']}');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(response['message'] as String? ?? 'Failed to get permission requests');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get permission requests: ${e.toString()}');
    }
  }
}

