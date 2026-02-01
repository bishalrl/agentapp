import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';

class DriverRideMapPage extends StatefulWidget {
  final String busId;
  final String busName;
  final String from;
  final String to;

  const DriverRideMapPage({
    super.key,
    required this.busId,
    required this.busName,
    required this.from,
    required this.to,
  });

  @override
  State<DriverRideMapPage> createState() => _DriverRideMapPageState();
}

class _DriverRideMapPageState extends State<DriverRideMapPage> {
  bool _isRideActive = false;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  StreamSubscription<Position>? _positionStream;
  Map<String, dynamic>? _routeData;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    // Load ride data from BLoC state
    final driverState = context.read<DriverBloc>().state;
    if (driverState.rideData != null) {
      _routeData = driverState.rideData;
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable them.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please enable them in settings.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleRide() {
    if (!_isRideActive) {
      // Initiate ride if not already initiated
      context.read<DriverBloc>().add(
        InitiateRideEvent(busId: widget.busId),
      );
    }

    setState(() {
      _isRideActive = !_isRideActive;
    });

    if (_isRideActive) {
      // Start location tracking
      _startLocationTracking();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride started! Location tracking active.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Stop location tracking
      _stopLocationTracking();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride ended. Location tracking stopped.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _startLocationTracking() {
    print('Starting location tracking for bus: ${widget.busId}');
    
    // Start listening to position stream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      
      // Send location update to backend
      context.read<DriverBloc>().add(
        UpdateDriverLocationEvent(
          busId: widget.busId,
          latitude: position.latitude,
          longitude: position.longitude,
          speed: position.speed,
          heading: position.heading,
          accuracy: position.accuracy,
        ),
      );
    });
  }

  void _stopLocationTracking() {
    print('Stopping location tracking for bus: ${widget.busId}');
    _positionStream?.cancel();
    _positionStream = null;
  }

  Widget _buildMapView() {
    // Google Maps integration placeholder
    // TODO: Replace with actual GoogleMap widget when API key is configured
    // Example:
    // return GoogleMap(
    //   initialCameraPosition: CameraPosition(
    //     target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
    //     zoom: 14.0,
    //   ),
    //   markers: _buildMarkers(),
    //   polylines: _buildRoutePolyline(),
    //   myLocationEnabled: true,
    //   myLocationButtonEnabled: true,
    // );
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Map View',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Current Location',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                if (_currentPosition!.speed > 0) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Speed: ${(_currentPosition!.speed * 3.6).toStringAsFixed(1)} km/h',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          if (_routeData != null && _routeData!['route'] != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route, color: Colors.green.shade700, size: 16),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Route loaded - Ready for map integration',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Note: Configure Google Maps API key to enable map view.\nSee DRIVER_BACKEND_REQUIREMENTS.md for setup instructions.',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context) {
    if (_routeData != null && _routeData!['route'] != null) {
      final dynamic rawRoute = _routeData!['route'];

      // Some backends may return only a route ID (String) instead of a full route object.
      // In that case, fall back to the widget-level from/to values.
      if (rawRoute is! Map<String, dynamic>) {
        return Row(
          children: [
            Expanded(
              child: _RoutePoint(
                label: 'From',
                location: widget.from,
                icon: Icons.location_on,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Icon(Icons.arrow_forward, color: Colors.grey[400]),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _RoutePoint(
                label: 'To',
                location: widget.to,
                icon: Icons.location_on,
                color: Colors.red,
              ),
            ),
          ],
        );
      }

      final Map<String, dynamic> route = rawRoute;
      final fromData = route['from'] as Map<String, dynamic>?;
      final toData = route['to'] as Map<String, dynamic>?;
      final stops = route['stops'] as List<dynamic>? ?? [];
      
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _RoutePoint(
                  label: 'From',
                  location: fromData?['name'] ?? widget.from,
                  icon: Icons.location_on,
                  color: Colors.green,
                  coordinates: fromData?['coordinates'],
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _RoutePoint(
                  label: 'To',
                  location: toData?['name'] ?? widget.to,
                  icon: Icons.location_on,
                  color: Colors.red,
                  coordinates: toData?['coordinates'],
                ),
              ),
            ],
          ),
          if (stops.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Stops: ${stops.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (_currentPosition != null) ...[
              const SizedBox(height: 4),
              Text(
                'Current position: ${_getCurrentRoutePositionLabel(stops)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _RoutePoint(
              label: 'From',
              location: widget.from,
              icon: Icons.location_on,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Icon(Icons.arrow_forward, color: Colors.grey[400]),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: _RoutePoint(
              label: 'To',
              location: widget.to,
              icon: Icons.location_on,
              color: Colors.red,
            ),
          ),
        ],
      );
    }
  }

  /// Returns a human‑readable label describing where along the route
  /// the bus currently is, based on the nearest stop coordinates.
  String _getCurrentRoutePositionLabel(List<dynamic> stops) {
    if (_currentPosition == null || stops.isEmpty) {
      return 'Location not available';
    }

    double minDistance = double.infinity;
    String? nearestStopName;

    for (final stop in stops) {
      if (stop is! Map<String, dynamic>) continue;
      final coords = stop['coordinates'] as Map<String, dynamic>?;
      if (coords == null) continue;

      final lat = coords['latitude'] as num?;
      final lng = coords['longitude'] as num?;
      if (lat == null || lng == null) continue;

      final dLat = (_currentPosition!.latitude - lat.toDouble());
      final dLng = (_currentPosition!.longitude - lng.toDouble());
      final distance = (dLat * dLat) + (dLng * dLng); // rough planar distance

      if (distance < minDistance) {
        minDistance = distance;
        nearestStopName = stop['name'] as String?;
      }
    }

    if (nearestStopName == null || nearestStopName.isEmpty) {
      return 'On route';
    }

    return 'Near $nearestStopName';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverBloc, DriverState>(
      listener: (context, state) {
        if (state.rideData != null && _routeData == null) {
          setState(() {
            _routeData = state.rideData;
          });
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
        title: Text(widget.busName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
        children: [
          // Route Information Card
          EnhancedCard(
            margin: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Route Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Display route from API if available, otherwise use widget props
                _buildRouteInfo(context),
              ],
            ),
          ),

          // Map Display (Google Maps Integration Ready)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _isLoadingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : _currentPosition == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Waiting for GPS location...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enable location services to track your ride',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _getCurrentLocation,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Get Location'),
                              ),
                            ],
                          ),
                        )
                      : _buildMapView(),
            ),
          ),

          // Control Button
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleRide,
                icon: Icon(_isRideActive ? Icons.stop : Icons.play_arrow),
                label: Text(_isRideActive ? 'End Ride' : 'Start Ride'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      _isRideActive ? Colors.red : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      );
  }
}

class _RoutePoint extends StatelessWidget {
  final String label;
  final String location;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? coordinates;

  const _RoutePoint({
    required this.label,
    required this.location,
    required this.icon,
    required this.color,
    this.coordinates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
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
          location,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        if (coordinates != null) ...[
          const SizedBox(height: 2),
          Text(
            'Lat: ${coordinates!['latitude']?.toStringAsFixed(6) ?? 'N/A'}, Lng: ${coordinates!['longitude']?.toStringAsFixed(6) ?? 'N/A'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
          ),
        ],
      ],
    );
  }
}
