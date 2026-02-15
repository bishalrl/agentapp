import 'package:agentapp/features/bus_driver/presentation/bloc/events/driver_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/states/driver_state.dart';
import 'driver_ride_map_page.dart';

class DriverRideTab extends StatelessWidget {
  const DriverRideTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        final dashboardData = state.dashboardData;
        final buses = dashboardData?['buses'] as List<dynamic>? ?? [];
        final hasPendingInvitations = _hasPendingOwnerInvitations(state);
        final isLoadingDashboard = dashboardData == null && state.isLoading;

        // Single scrollable layout: owner invitations first (always visible when present), then buses
        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<DriverBloc>();
            bloc.add(const GetDriverDashboardEvent(forceRefresh: true));
            bloc.add(const GetAssignedBusesEvent());
            bloc.add(const GetOwnerInvitationsEvent());
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1) Owner invitations – always at top when present (driver must accept to associate with one owner)
                ..._buildOwnerInvitationsSection(context, state),
                if (hasPendingInvitations) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                    child: Text(
                      'Accept one invitation above to join that owner\'s fleet. You will then see only that owner\'s buses here.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
                // 2) Assigned buses – only from the owner you're associated with (after accept)
                Text(
                  'Your assigned buses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPendingInvitations
                      ? 'Buses from the owner you join (after you accept an invitation)'
                      : 'Buses from your current owner',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                if (isLoadingDashboard && buses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppTheme.spacingL),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (buses.isEmpty)
                  _buildNoBusesEmptyState(context, hasPendingInvitations)
                else
                  ...buses.asMap().entries.map((entry) {
                    final bus = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                      child: _buildBusCard(context, bus),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasPendingOwnerInvitations(DriverState state) {
    final invData = state.ownerInvitations;
    if (invData == null) return false;
    final raw = invData['invitations'] as List<dynamic>? ?? invData['data'] as List<dynamic>? ?? [];
    return raw
        .where((e) => e is Map<String, dynamic>)
        .any((e) => (e['status'] as String? ?? '').toUpperCase() == 'PENDING');
  }

  Widget _buildNoBusesEmptyState(BuildContext context, bool hasPendingInvitations) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
      child: Column(
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            hasPendingInvitations
                ? 'No buses yet'
                : 'No buses assigned',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            hasPendingInvitations
                ? 'Accept an owner invitation above to join their fleet. Then you\'ll see their buses here.'
                : 'Wait for bus assignment from your owner.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Owner join flow: show pending owner invitations so driver can accept and get associated with owner.
  List<Widget> _buildOwnerInvitationsSection(BuildContext context, DriverState state) {
    final invData = state.ownerInvitations;
    if (invData == null) return [];
    // Support both { invitations: [...] } and { data: [...] }; backend may use either
    final raw = invData['invitations'] as List<dynamic>? ?? invData['data'] as List<dynamic>? ?? [];
    final invitations = raw
        .where((e) => e is Map<String, dynamic>)
        .cast<Map<String, dynamic>>()
        .where((e) => (e['status'] as String? ?? '').toUpperCase() == 'PENDING')
        .toList();
    if (invitations.isEmpty) return [];

    return [
      // Prominent header so driver always sees they have invitations
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mail_outline, color: Colors.purple.shade700, size: 24),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Owner invitations (${invitations.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'An owner invited you to join their fleet. Accept one to get associated; you will then see only that owner\'s buses below.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.purple.shade800,
                  ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppTheme.spacingM),
      ...invitations.map((inv) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: _OwnerInvitationCard(
              invitation: inv,
              isLoading: state.isLoading,
              onAccept: (id) {
                if (id.isEmpty) return;
                context.read<DriverBloc>().add(AcceptOwnerInvitationEvent(invitationId: id));
              },
              onReject: (id) {
                if (id.isEmpty) return;
                context.read<DriverBloc>().add(RejectOwnerInvitationEvent(invitationId: id));
              },
            ),
          )),
      const SizedBox(height: AppTheme.spacingL),
    ];
  }

  Widget _buildBusCard(BuildContext context, dynamic bus) {
                  final busData = bus as Map<String, dynamic>;
                  final busId = busData['_id'] ?? busData['id'];
                  final busName = busData['name'] ?? 'Unknown Bus';
                  final vehicleNumber = busData['vehicleNumber'] ?? 'N/A';
                  // Start location sharing allowed only when bus is active (owner/staff activate)
                  final busIsActive = busData['isActive'] as bool? ?? true;

                  // Prefer explicit from/to fields; fall back to any nested route info;
                  // avoid showing raw "N/A" to the user.
                  String from = (busData['from'] as String?) ?? '';
                  String to = (busData['to'] as String?) ?? '';

                  // Optional: try nested route structure if present in dashboard data.
                  // Some backends may send `route` as an ID string instead of an object,
                  // so we must check the type before casting to avoid runtime errors.
                  final dynamic rawRoute = busData['route'];
                  Map<String, dynamic>? route;
                  if (rawRoute is Map<String, dynamic>) {
                    route = rawRoute;
                  }

                  // Extract from/to from route object if not already set
                  // Route can have from/to as strings directly OR as nested objects with 'name' property
                  if (from.isEmpty && route != null && route['from'] != null) {
                    final dynamic rawFrom = route['from'];
                    if (rawFrom is Map<String, dynamic>) {
                      // Nested object format: {name: "kathmandu", ...}
                      from = rawFrom['name'] as String? ?? '';
                    } else if (rawFrom is String) {
                      // Direct string format: "kathmandu"
                      from = rawFrom;
                    } else {
                      // Fallback: convert to string
                      from = rawFrom.toString();
                    }
                  }
                  
                  if (to.isEmpty && route != null && route['to'] != null) {
                    final dynamic rawTo = route['to'];
                    if (rawTo is Map<String, dynamic>) {
                      // Nested object format: {name: "butwal", ...}
                      to = rawTo['name'] as String? ?? '';
                    } else if (rawTo is String) {
                      // Direct string format: "butwal"
                      to = rawTo;
                    } else {
                      // Fallback: convert to string
                      to = rawTo.toString();
                    }
                  }
                  
                  // Clean up: remove 'null' strings
                  if (from == 'null') from = '';
                  if (to == 'null') to = '';

                  final hasRoute = from.isNotEmpty && to.isNotEmpty;
                  final routeLabel =
                      hasRoute ? '$from → $to' : 'Route information not available';

                  final date = busData['date'] ?? '';
                  final time = busData['time'] ?? 'N/A';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                    child: EnhancedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppTheme.spacingS),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.directions_bus,
                                  color: AppTheme.primaryColor,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      busName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      vehicleNumber,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Bus active state: location sharing only when active
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (busIsActive ? Colors.green : Colors.grey).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: (busIsActive ? Colors.green : Colors.grey).withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      busIsActive ? Icons.check_circle : Icons.cancel,
                                      size: 14,
                                      color: busIsActive ? Colors.green : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      busIsActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: busIsActive ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: AppTheme.spacingL),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.location_on,
                                  label: 'Route',
                                  value: routeLabel,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.calendar_today,
                                  label: 'Date',
                                  value: date.toString().split('T')[0],
                                ),
                              ),
                              Expanded(
                                child: _InfoItem(
                                  icon: Icons.access_time,
                                  label: 'Time',
                                  value: time,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          // Route Information Display
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.route, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: AppTheme.spacingS),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.green.shade700),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              hasRoute ? 'From: $from' : 'From: (not set)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.red.shade700),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              hasRoute ? 'To: $to' : 'To: (not set)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          if (!busIsActive)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Expanded(
                                    child: Text(
                                      'Bus is inactive. Owner or staff must activate this bus before you can start location sharing.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Validate route information before proceeding
                                  if (!hasRoute || from.isEmpty || to.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Route information (From/To) is missing. Cannot initiate ride without route details.',
                                        ),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                    return;
                                  }

                                  // Request location permission before navigating
                                  final hasLocationPermission = await _DriverRideTabHelper.requestLocationPermission(context);
                                  if (!hasLocationPermission) {
                                    return;
                                  }

                                  // Initiate ride via BLoC (backend allows only when bus is active)
                                  context.read<DriverBloc>().add(
                                    InitiateRideEvent(busId: busId.toString()),
                                  );

                                  // Navigate to map page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverRideMapPage(
                                        busId: busId.toString(),
                                        busName: busName,
                                        from: from,
                                        to: to,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.map),
                                label: const Text('Initiate Ride'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
  }
}

/// Owner invitation card: Accept = join owner's fleet (driver.invitedBy set by backend).
class _OwnerInvitationCard extends StatelessWidget {
  final Map<String, dynamic> invitation;
  final bool isLoading;
  final Function(String) onAccept;
  final Function(String) onReject;

  const _OwnerInvitationCard({
    required this.invitation,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final id = invitation['id'] as String? ?? invitation['_id'] as String? ?? '';
    final owner = invitation['owner'];
    String ownerName = 'A bus owner';
    if (owner is Map<String, dynamic>) {
      ownerName = owner['name'] as String? ?? owner['agencyName'] as String? ?? ownerName;
    }
    final expiresAt = invitation['expiresAt'] as String?;

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person_add, color: Colors.purple.shade700, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join owner\'s fleet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '$ownerName invited you to join their fleet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (expiresAt != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Expires: $expiresAt',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : () => onReject(id),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : () => onAccept(id),
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                  label: Text(isLoading ? 'Accepting...' : 'Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper class for driver ride tab utilities
class _DriverRideTabHelper {
  /// Request location permission with UI feedback and return true if granted
  static Future<bool> requestLocationPermission(BuildContext context) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show dialog to enable location services
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('Location Services Disabled'),
            ],
          ),
          content: const Text(
            'Location services are disabled on your device. Please enable them in device settings to track your ride.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      
      if (shouldOpenSettings == true) {
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    // Check current permission status
    LocationPermission permission;
    try {
      permission = await Geolocator.checkPermission();
    } catch (e) {
      // Handle case where permissions are not defined in manifest
      if (e.toString().contains('No location permissions are defined in the manifest')) {
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Configuration Error'),
              ],
            ),
            content: const Text(
              'Location permissions are not properly configured in the app. Please contact support or reinstall the app.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return false;
    }
    
    // If already granted, return true
    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      return true;
    }

    // If denied, show dialog first, then request permission
    if (permission == LocationPermission.denied) {
      // Show dialog explaining why location is needed
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_on, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Location Permission Required'),
            ],
          ),
          content: const Text(
            'This app needs location permission to track your ride and provide real-time updates to passengers. Please grant location access to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Allow Location'),
            ),
          ],
        ),
      );
      
      if (shouldRequest != true) {
        return false;
      }
      
      // Show snackbar that we're requesting permission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text('Requesting location permission...'),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Request permission
      permission = await Geolocator.requestPermission();
      
      // Check result
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Location permission granted!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Location permission denied. Please enable it in app settings.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return false;
      }
    }

    // If permanently denied, show dialog with option to open settings
    if (permission == LocationPermission.deniedForever) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_disabled, color: Colors.red),
              SizedBox(width: 8),
              Text('Location Permission Denied'),
            ],
          ),
          content: const Text(
            'Location permission has been permanently denied. Please enable it in app settings to track your ride.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      
      if (shouldOpenSettings == true) {
        await Geolocator.openAppSettings();
      }
      return false;
    }

    return false;
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
