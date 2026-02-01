import 'dart:io';
import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';

abstract class DriverRepository {
  Future<Result<Map<String, dynamic>>> verifyOtp(String phoneNumber, String otp); // Returns driver and token
  Future<Result<Map<String, dynamic>>> register({
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
  Future<Result<Map<String, dynamic>>> registerWithInvitation({
    required String invitationCode,
    required String email,
    required String phoneNumber,
    required String password,
    required String name,
    required String licenseNumber,
    File? licensePhoto, // Optional license photo file
    File? driverPhoto, // Optional driver photo file
  });
  Future<Result<Map<String, dynamic>>> login({
    String? email,
    String? phoneNumber,
    required String password,
    bool? hasOTP, // Optional: true if driver has OTP for owner association
    String? otp, // Optional: OTP code for owner association
  }); // Returns driver and token - supports OTP-based association
  Future<Result<Map<String, dynamic>>> getDriverDashboard(); // Returns dashboard data
  Future<Result<DriverEntity>> getDriverProfile();
  Future<Result<Map<String, dynamic>>> getDriverProfileWithInviter(); // Returns full profile data including inviter
  Future<Result<DriverEntity>> updateDriverProfile({
    String? name,
    String? email,
  }); // Update driver profile
  Future<Result<List<BusEntity>>> getAssignedBuses();
  Future<Result<void>> startLocationSharing(String busId);
  Future<Result<void>> stopLocationSharing();
  Future<Result<void>> updateLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  });
  Future<Result<TripStatusEntity>> getTripStatus(String busId);
  Future<Result<void>> markBusAsReached(String busId); // Mark bus as reached destination
  Future<Result<Map<String, dynamic>>> getPendingRequests(); // Get pending bus assignment requests
  Future<Result<Map<String, dynamic>>> acceptRequest(String requestId); // Accept bus assignment request
  Future<Result<Map<String, dynamic>>> rejectRequest(String requestId); // Reject bus assignment request
  Future<Result<Map<String, dynamic>>> getBusDetails(String busId); // Get detailed bus information with full passenger data
  
  // Driver Ride Management
  Future<Result<Map<String, dynamic>>> initiateRide(String busId); // Initiate ride and get route with GPS coordinates
  Future<Result<Map<String, dynamic>>> updateDriverLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    double? accuracy,
  }); // Update driver location during ride
  
  // Driver Booking
  Future<Result<Map<String, dynamic>>> createDriverBooking({
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
  Future<Result<Map<String, dynamic>>> getBusPassengers(String busId); // Get passenger list with seat numbers
  Future<Result<Map<String, dynamic>>> verifyTicket({
    required String qrCode,
    required String busId,
    int? seatNumber,
  }); // Verify ticket via QR code scan
  
  // Driver Permission Requests
  Future<Result<Map<String, dynamic>>> requestPermission({
    required String permissionType,
    String? busId,
    String? message,
  }); // Request permission from owner
  Future<Result<Map<String, dynamic>>> getPermissionRequests(); // Get driver's permission requests
}

class TripStatusEntity {
  final BusEntity bus;
  final int passengerCount;
  final int totalSeats;
  final int availableSeats;
  final bool isLocationSharing;
  
  const TripStatusEntity({
    required this.bus,
    required this.passengerCount,
    required this.totalSeats,
    required this.availableSeats,
    required this.isLocationSharing,
  });
}

