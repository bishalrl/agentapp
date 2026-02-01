import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';

class DriverBusDetailsPage extends StatelessWidget {
  final String busId;

  const DriverBusDetailsPage({
    super.key,
    required this.busId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DriverBloc>()..add(GetBusDetailsEvent(busId: busId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bus Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<DriverBloc, DriverState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final busDetails = state.busDetails;
            if (busDetails == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'No bus details available',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DriverBloc>().add(GetBusDetailsEvent(busId: busId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DriverBloc>().add(GetBusDetailsEvent(busId: busId));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bus Information
                    _BusInfoCard(busDetails: busDetails),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    // Booking Statistics
                    if (busDetails['statistics'] != null)
                      _BookingStatisticsCard(
                        statistics: busDetails['statistics'] as Map<String, dynamic>,
                      ),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    // All Bookings
                    if (busDetails['bookings'] != null)
                      _BookingsListCard(
                        bookings: busDetails['bookings'] as List<dynamic>,
                      ),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    // Seat Map with Full Passenger Data
                    if (busDetails['seats'] != null)
                      _SeatMapCard(
                        seats: busDetails['seats'] as List<dynamic>,
                        seatConfiguration: busDetails['seatConfiguration'] as List<dynamic>?,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BusInfoCard extends StatelessWidget {
  final Map<String, dynamic> busDetails;

  const _BusInfoCard({required this.busDetails});

  @override
  Widget build(BuildContext context) {
    final bus = busDetails['bus'] as Map<String, dynamic>? ?? busDetails;
    final vehicleNumber = bus['vehicleNumber'] as String? ?? 'N/A';
    final route = bus['route'] as Map<String, dynamic>?;
    final from = bus['from'] as String? ?? route?['from'] as String? ?? '';
    final to = bus['to'] as String? ?? route?['to'] as String? ?? '';
    final date = bus['date'] as String?;
    final time = bus['time'] as String?;
    final arrival = bus['arrival'] as String?;
    final amenities = bus['amenities'] as List<dynamic>? ?? [];
    final boardingPoints = bus['boardingPoints'] as List<dynamic>? ?? [];
    final droppingPoints = bus['droppingPoints'] as List<dynamic>? ?? [];

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, size: 32, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (from.isNotEmpty && to.isNotEmpty)
                      Text(
                        '$from → $to',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppTheme.spacingL),
          if (date != null || time != null) ...[
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: date ?? 'N/A',
            ),
            _InfoRow(
              icon: Icons.access_time,
              label: 'Time',
              value: arrival != null ? '$time → $arrival' : (time ?? 'N/A'),
            ),
          ],
          if (amenities.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Amenities',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Wrap(
              spacing: AppTheme.spacingXS,
              children: amenities.map((amenity) => Chip(
                    label: Text(amenity.toString()),
                    labelStyle: const TextStyle(fontSize: 12),
                  )).toList(),
            ),
          ],
          if (boardingPoints.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Boarding Points',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            ...boardingPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
                  child: Text('• ${point.toString()}'),
                )),
          ],
          if (droppingPoints.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Dropping Points',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            ...droppingPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
                  child: Text('• ${point.toString()}'),
                )),
          ],
        ],
      ),
    );
  }
}

class _BookingStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const _BookingStatisticsCard({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final total = statistics['totalBookings'] as int? ?? 0;
    final confirmed = statistics['confirmedBookings'] as int? ?? 0;
    final cancelled = statistics['cancelledBookings'] as int? ?? 0;
    final pending = statistics['pendingBookings'] as int? ?? 0;
    final revenue = statistics['totalRevenue'] as num? ?? 0.0;

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Booking Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Total',
                  value: total.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: _StatBox(
                  label: 'Confirmed',
                  value: confirmed.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Cancelled',
                  value: cancelled.toString(),
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: _StatBox(
                  label: 'Pending',
                  value: pending.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Revenue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Rs. ${revenue.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsListCard extends StatelessWidget {
  final List<dynamic> bookings;

  const _BookingsListCard({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.book, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'All Bookings (${bookings.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacingL),
              child: Center(child: Text('No bookings yet')),
            )
          else
            ...bookings.map((booking) {
              final bookingData = booking as Map<String, dynamic>;
              final passenger = bookingData['passenger'] as Map<String, dynamic>?;
              final seatNumber = bookingData['seatNumber'] as String? ?? 'N/A';
              final status = bookingData['status'] as String? ?? 'N/A';
              final amount = bookingData['amount'] as num? ?? 0.0;
              final ticketNumber = bookingData['ticketNumber'] as String?;
              final bookingDate = bookingData['bookingDate'] as String?;
              final paymentStatus = bookingData['paymentStatus'] as String?;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Seat: $seatNumber',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (passenger != null) ...[
                        const SizedBox(height: AppTheme.spacingS),
                        _InfoRow(
                          icon: Icons.person,
                          label: 'Name',
                          value: passenger['name'] as String? ?? 'Unknown',
                        ),
                        _InfoRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: passenger['email'] as String? ?? 'N/A',
                        ),
                        _InfoRow(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: passenger['contactNumber'] as String? ?? 'N/A',
                        ),
                      ],
                      if (ticketNumber != null)
                        _InfoRow(
                          icon: Icons.confirmation_number,
                          label: 'Ticket',
                          value: ticketNumber,
                        ),
                      if (bookingDate != null)
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: 'Booking Date',
                          value: bookingDate,
                        ),
                      if (paymentStatus != null)
                        _InfoRow(
                          icon: Icons.payment,
                          label: 'Payment',
                          value: paymentStatus,
                        ),
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: 'Amount',
                        value: 'Rs. ${amount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _SeatMapCard extends StatelessWidget {
  final List<dynamic> seats;
  final List<dynamic>? seatConfiguration;

  const _SeatMapCard({
    required this.seats,
    this.seatConfiguration,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_seat, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Seat Map with Passenger Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Wrap(
            spacing: AppTheme.spacingXS,
            runSpacing: AppTheme.spacingXS,
            children: seats.map((seat) {
              final seatData = seat as Map<String, dynamic>;
              final seatNumber = seatData['seatNumber']?.toString() ?? 'N/A';
              final isBooked = seatData['isBooked'] as bool? ?? false;
              final passenger = seatData['passenger'] as Map<String, dynamic>?;

              return _SeatWidget(
                seatNumber: seatNumber,
                isBooked: isBooked,
                passenger: passenger,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SeatWidget extends StatelessWidget {
  final String seatNumber;
  final bool isBooked;
  final Map<String, dynamic>? passenger;

  const _SeatWidget({
    required this.seatNumber,
    required this.isBooked,
    this.passenger,
  });

  @override
  Widget build(BuildContext context) {
    // Show full passenger information - no masking
    final passengerName = passenger?['name'] as String? ?? 'Unknown';
    final email = passenger?['email'] as String? ?? '';
    final phone = passenger?['contactNumber'] as String? ?? '';
    
    final tooltipMessage = isBooked && passenger != null
        ? '$passengerName\n$phone\n$email'
        : 'Available';
    
    return Tooltip(
      message: tooltipMessage,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isBooked ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
          border: Border.all(
            color: isBooked ? Colors.orange : Colors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                seatNumber,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isBooked ? Colors.orange[900] : Colors.green[900],
                ),
              ),
              if (isBooked)
                const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.orange,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
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
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
