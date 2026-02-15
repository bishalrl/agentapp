import '../../../../../core/bloc/base_bloc_state.dart';
import '../../../domain/entities/driver_entity.dart';

class DriverState extends BaseBlocState {
  final DriverEntity? driver;
  final List<BusEntity> buses;
  final bool isLoading;
  final String? errorMessage;
  final String? registrationToken; // Token received after registration
  final Map<String, dynamic>? dashboardData; // Driver dashboard data
  final Map<String, dynamic>? pendingRequests; // Pending bus assignment requests
  final Map<String, dynamic>? ownerInvitations; // Pending owner invitations (owner join flow)
  final Map<String, dynamic>? busDetails; // Detailed bus information from GET /api/driver/bus/:busId
  final Map<String, dynamic>? profileData; // Full profile data including inviter
  final Map<String, dynamic>? rideData; // Ride initiation data with route and GPS coordinates
  final Map<String, dynamic>? passengersData; // Passenger list for ticket verification
  final Map<String, dynamic>? ticketVerificationResult; // Ticket verification result
  /// Last time dashboard was fetched (for 5-minute throttle).
  final DateTime? lastDashboardFetchTime;

  const DriverState({
    this.driver,
    this.buses = const [],
    this.isLoading = false,
    this.errorMessage,
    this.registrationToken,
    this.dashboardData,
    this.pendingRequests,
    this.ownerInvitations,
    this.busDetails,
    this.profileData,
    this.rideData,
    this.passengersData,
    this.ticketVerificationResult,
    this.lastDashboardFetchTime,
  });

  DriverState copyWith({
    DriverEntity? driver,
    List<BusEntity>? buses,
    bool? isLoading,
    String? errorMessage,
    String? registrationToken,
    Map<String, dynamic>? dashboardData,
    Map<String, dynamic>? pendingRequests,
    Map<String, dynamic>? ownerInvitations,
    Map<String, dynamic>? busDetails,
    Map<String, dynamic>? profileData,
    Map<String, dynamic>? rideData,
    Map<String, dynamic>? passengersData,
    Map<String, dynamic>? ticketVerificationResult,
    DateTime? lastDashboardFetchTime,
  }) {
    return DriverState(
      driver: driver ?? this.driver,
      buses: buses ?? this.buses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      registrationToken: registrationToken ?? this.registrationToken,
      dashboardData: dashboardData ?? this.dashboardData,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      ownerInvitations: ownerInvitations ?? this.ownerInvitations,
      busDetails: busDetails ?? this.busDetails,
      profileData: profileData ?? this.profileData,
      rideData: rideData ?? this.rideData,
      passengersData: passengersData ?? this.passengersData,
      ticketVerificationResult: ticketVerificationResult ?? this.ticketVerificationResult,
      lastDashboardFetchTime: lastDashboardFetchTime ?? this.lastDashboardFetchTime,
    );
  }

  @override
  List<Object?> get props => [
        driver,
        buses,
        isLoading,
        errorMessage,
        registrationToken,
        dashboardData,
        pendingRequests,
        ownerInvitations,
        busDetails,
        profileData,
        rideData,
        passengersData,
        ticketVerificationResult,
        lastDashboardFetchTime,
      ];
}

