import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/animations/scroll_animations.dart';
import '../../../../core/animations/dialog_animations.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';
import 'driver_qr_scanner_page.dart';
import 'driver_bus_seat_map_page.dart';

class DriverScanTab extends StatelessWidget {
  const DriverScanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        final dashboardData = state.dashboardData;
        final buses = dashboardData?['buses'] as List<dynamic>? ?? [];
        final passengersData = state.passengersData;
        
        // Get passengers from API response or use empty list
        final passengers = passengersData?['passengers'] as List<dynamic>? ?? [];
        
        // If no passengers loaded and we have buses, load passengers for first bus
        if (passengers.isEmpty && buses.isNotEmpty && !state.isLoading) {
          final firstBus = buses[0] as Map<String, dynamic>;
          final busId = firstBus['_id'] ?? firstBus['id'];
          if (busId != null) {
            // Load passengers for first bus
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<DriverBloc>().add(GetBusPassengersEvent(busId: busId.toString()));
            });
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EnhancedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Ticket Verification',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Scan QR codes to verify passenger tickets',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (buses.isNotEmpty) {
                          final firstBus = buses[0] as Map<String, dynamic>;
                          final busId = firstBus['_id'] ?? firstBus['id'];
                          if (busId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverQRScannerPage(
                                  busId: busId.toString(),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (buses.isNotEmpty) {
                          final firstBus = buses[0] as Map<String, dynamic>;
                          final busId = firstBus['_id'] ?? firstBus['id'];
                          if (busId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverBusSeatMapPage(
                                  busId: busId.toString(),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.event_seat),
                      label: const Text('Seat Map'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Passenger List',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              if (state.isLoading && passengers.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (passengers.isEmpty)
                EnhancedCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No passengers found',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...passengers.map((passenger) {
                  final passengerData = passenger as Map<String, dynamic>;
                  final isVerified = passengerData['ticketVerified'] == true;
                  final seatNumber = passengerData['seatNumber'];
                  final ticketNumber = passengerData['ticketNumber'] ?? '';
                  final passengerName = passengerData['passengerName'] ?? 'Unknown';
                  final qrCode = passengerData['qrCode'] ?? ticketNumber;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                    child: EnhancedCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isVerified
                              ? Colors.green.shade100
                              : AppTheme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            isVerified ? Icons.check_circle : Icons.person,
                            color: isVerified
                                ? Colors.green
                                : AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(passengerName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Seat: ${seatNumber.toString()}'),
                            Text('Ticket: $ticketNumber'),
                            if (passengerData['contactNumber'] != null)
                              Text('Contact: ${passengerData['contactNumber']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isVerified)
                              IconButton(
                                icon: const Icon(Icons.qr_code_scanner),
                                onPressed: () {
                                  _showScanDialog(context, passengerData, buses);
                                },
                                tooltip: 'Scan Ticket',
                              ),
                            Chip(
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
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showScanDialog(BuildContext context, Map<String, dynamic> passenger, List<dynamic> buses) {
    final busId = buses.isNotEmpty ? (buses[0] as Map)['_id'] ?? (buses[0] as Map)['id'] : null;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Passenger: ${passenger['passengerName'] ?? 'Unknown'}'),
            Text('Seat: ${passenger['seatNumber']}'),
            Text('Ticket: ${passenger['ticketNumber'] ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Text('Open QR scanner to verify this ticket?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (busId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverQRScannerPage(
                      busId: busId.toString(),
                      expectedTicketNumber: passenger['ticketNumber'] as String?,
                      passengerSeat: passenger['seatNumber']?.toString(),
                    ),
                  ),
                );
              }
            },
            child: const Text('Scan'),
          ),
        ],
      ),
    );
  }
}
