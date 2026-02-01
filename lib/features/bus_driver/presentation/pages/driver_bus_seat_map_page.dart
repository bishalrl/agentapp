import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';

class DriverBusSeatMapPage extends StatefulWidget {
  final String busId;

  const DriverBusSeatMapPage({
    super.key,
    required this.busId,
  });

  @override
  State<DriverBusSeatMapPage> createState() => _DriverBusSeatMapPageState();
}

class _DriverBusSeatMapPageState extends State<DriverBusSeatMapPage> {
  Map<String, dynamic>? _selectedPassenger;

  @override
  void initState() {
    super.initState();
    // Load bus details and passengers
    context.read<DriverBloc>().add(GetBusDetailsEvent(busId: widget.busId));
    context.read<DriverBloc>().add(GetBusPassengersEvent(busId: widget.busId));
  }

  void _showPassengerInfo(BuildContext context, Map<String, dynamic>? passenger) {
    if (passenger == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Passenger Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppTheme.spacingM),
              _InfoRow('Name', passenger['passengerName'] ?? 'Unknown'),
              const SizedBox(height: AppTheme.spacingS),
              _InfoRow('Seat', passenger['seatNumber']?.toString() ?? 'N/A'),
              const SizedBox(height: AppTheme.spacingS),
              _InfoRow('Ticket', passenger['ticketNumber'] ?? 'N/A'),
              if (passenger['contactNumber'] != null) ...[
                const SizedBox(height: AppTheme.spacingS),
                _InfoRow('Contact', passenger['contactNumber']),
              ],
              if (passenger['passengerEmail'] != null) ...[
                const SizedBox(height: AppTheme.spacingS),
                _InfoRow('Email', passenger['passengerEmail']),
              ],
              if (passenger['pickupLocation'] != null) ...[
                const SizedBox(height: AppTheme.spacingS),
                _InfoRow('Pickup', passenger['pickupLocation']),
              ],
              if (passenger['dropoffLocation'] != null) ...[
                const SizedBox(height: AppTheme.spacingS),
                _InfoRow('Dropoff', passenger['dropoffLocation']),
              ],
              const SizedBox(height: AppTheme.spacingM),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: passenger['ticketVerified'] == true
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      passenger['ticketVerified'] == true
                          ? Icons.check_circle
                          : Icons.pending,
                      color: passenger['ticketVerified'] == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      passenger['ticketVerified'] == true
                          ? 'Ticket Verified'
                          : 'Ticket Pending Verification',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: passenger['ticketVerified'] == true
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Seat Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
          final busDetails = state.busDetails;
          final passengersData = state.passengersData;
          final passengers = passengersData?['passengers'] as List<dynamic>? ?? [];

          if (state.isLoading && busDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (busDetails == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load bus details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          final bus = busDetails['bus'] as Map<String, dynamic>? ?? busDetails;
          final totalSeats = bus['totalSeats'] as int? ?? 40;
          final seatConfiguration = bus['seatConfiguration'] as List<dynamic>?;
          final bookedSeats = bus['bookedSeats'] as List<dynamic>? ?? [];

          // Create a map of seat number to passenger
          final seatToPassenger = <String, Map<String, dynamic>>{};
          for (var passenger in passengers) {
            final p = passenger as Map<String, dynamic>;
            final seatNum = p['seatNumber']?.toString();
            if (seatNum != null) {
              seatToPassenger[seatNum] = p;
            }
          }

          // Generate seat identifiers
          List<dynamic> seatIdentifiers;
          if (seatConfiguration != null && seatConfiguration.isNotEmpty) {
            seatIdentifiers = seatConfiguration;
          } else {
            seatIdentifiers = List.generate(totalSeats, (index) => index + 1);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bus Info Card
                EnhancedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus['name'] ?? 'Unknown Bus',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        '${bus['vehicleNumber'] ?? 'N/A'} • ${bus['from'] ?? 'N/A'} → ${bus['to'] ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Seat Map
                EnhancedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seat Map',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Tap on a seat to view passenger information',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _SeatMapGrid(
                        seatIdentifiers: seatIdentifiers,
                        bookedSeats: bookedSeats,
                        seatToPassenger: seatToPassenger,
                        onSeatTap: (seatId, passenger) {
                          _showPassengerInfo(context, passenger);
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _LegendItem(
                            color: Colors.green,
                            label: 'Available',
                          ),
                          _LegendItem(
                            color: Colors.red,
                            label: 'Booked',
                          ),
                          _LegendItem(
                            color: Colors.blue,
                            label: 'Verified',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Passenger List (Keep as requested)
                Text(
                  'Passenger List',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                if (passengers.isEmpty)
                  EnhancedCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Center(
                        child: Text(
                          'No passengers found',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ),
                    ),
                  )
                else
                  ...passengers.map((passenger) {
                    final p = passenger as Map<String, dynamic>;
                    final isVerified = p['ticketVerified'] == true;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      child: EnhancedCard(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isVerified
                                ? Colors.green.shade100
                                : AppTheme.primaryColor.withOpacity(0.1),
                            child: Icon(
                              isVerified ? Icons.check_circle : Icons.person,
                              color: isVerified ? Colors.green : AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(p['passengerName'] ?? 'Unknown'),
                          subtitle: Text('Seat: ${p['seatNumber']} • ${p['ticketNumber'] ?? 'N/A'}'),
                          trailing: Chip(
                            label: Text(
                              isVerified ? 'Verified' : 'Pending',
                              style: TextStyle(
                                fontSize: 12,
                                color: isVerified ? Colors.green : Colors.orange,
                              ),
                            ),
                            backgroundColor: isVerified
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                          ),
                          onTap: () => _showPassengerInfo(context, p),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeatMapGrid extends StatelessWidget {
  final List<dynamic> seatIdentifiers;
  final List<dynamic> bookedSeats;
  final Map<String, Map<String, dynamic>> seatToPassenger;
  final Function(String, Map<String, dynamic>?) onSeatTap;

  const _SeatMapGrid({
    required this.seatIdentifiers,
    required this.bookedSeats,
    required this.seatToPassenger,
    required this.onSeatTap,
  });

  bool _isSeatBooked(dynamic seatId) {
    return bookedSeats.any((booked) =>
        booked.toString() == seatId.toString() ||
        (booked is num && seatId is num && booked.toInt() == seatId.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    const seatsPerRow = 4;
    final rows = (seatIdentifiers.length / seatsPerRow).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * seatsPerRow;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(seatsPerRow, (colIndex) {
              final seatIndex = startIndex + colIndex;
              if (seatIndex >= seatIdentifiers.length) {
                return const SizedBox(width: 50, height: 50);
              }

              final seatId = seatIdentifiers[seatIndex];
              final seatIdStr = seatId.toString();
              final isBooked = _isSeatBooked(seatId);
              final passenger = seatToPassenger[seatIdStr];
              final isVerified = passenger?['ticketVerified'] == true;

              Color seatColor;
              if (isBooked) {
                seatColor = isVerified ? Colors.blue : Colors.red;
              } else {
                seatColor = Colors.green;
              }

              return GestureDetector(
                onTap: () => onSeatTap(seatIdStr, passenger),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: seatColor.withOpacity(0.2),
                    border: Border.all(
                      color: seatColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          seatIdStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: seatColor,
                          ),
                        ),
                        if (isBooked && isVerified)
                          Icon(
                            Icons.check,
                            size: 12,
                            color: seatColor,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
