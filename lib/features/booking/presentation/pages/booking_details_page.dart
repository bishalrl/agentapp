import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/events/booking_event.dart';
import '../bloc/states/booking_state.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../domain/entities/booking_entity.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<BookingBloc>()..add(GetBookingDetailsEvent(bookingId: bookingId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/bookings');
              }
            },
          ),
          actions: [
            BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state.selectedBooking != null) {
                  final status = state.selectedBooking!.status.toLowerCase();
                  if (status == 'confirmed' || status == 'pending') {
                    return IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      onPressed: () => _showCancelDialog(context, state.selectedBooking!),
                      tooltip: 'Cancel Booking',
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: state.errorMessage!,
                  errorSource: 'Booking',
                ),
              );
            }
            if (state.successMessage != null && state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SuccessSnackBar(message: state.successMessage!),
              );
              // Refresh booking details after cancellation
              if (state.successMessage!.toLowerCase().contains('cancel')) {
                context.read<BookingBloc>().add(GetBookingDetailsEvent(bookingId: bookingId));
              }
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.selectedBooking == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.selectedBooking == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BookingBloc>().add(GetBookingDetailsEvent(bookingId: bookingId));
                      },
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            final booking = state.selectedBooking;
            if (booking == null) {
              return const Center(child: Text('Booking not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BookingHeaderCard(booking: booking),
                  const SizedBox(height: 16),
                  _BusInfoCard(bus: booking.bus),
                  const SizedBox(height: 16),
                  _PassengerInfoCard(booking: booking),
                  const SizedBox(height: 16),
                  _PaymentInfoCard(booking: booking),
                  const SizedBox(height: 16),
                  _BookingStatusCard(booking: booking),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, BookingEntity booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel booking ${booking.ticketNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<BookingBloc>().add(CancelBookingEvent(bookingId: booking.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _BookingHeaderCard extends StatelessWidget {
  final BookingEntity booking;

  const _BookingHeaderCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.confirmation_number,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              booking.ticketNumber,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking ID: ${booking.id.substring(0, 8)}...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusInfoCard extends StatelessWidget {
  final BusInfoEntity bus;

  const _BusInfoCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_bus, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Bus Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Bus Name', value: bus.name),
            _InfoRow(
              label: 'Route',
              value: '${bus.from} → ${bus.to}',
            ),
            _InfoRow(
              label: 'Date',
              value: DateFormat('EEEE, MMMM d, y').format(bus.date),
            ),
            _InfoRow(
              label: 'Time',
              value: '${bus.time}${bus.arrival != null ? ' - ${bus.arrival}' : ''}',
            ),
            _InfoRow(
              label: 'Seats',
              value: '${bus.totalSeats} total, ${bus.availableSeats} available',
            ),
          ],
        ),
      ),
    );
  }
}

class _PassengerInfoCard extends StatelessWidget {
  final BookingEntity booking;

  const _PassengerInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Passenger Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Name', value: booking.passengerName),
            _InfoRow(label: 'Contact', value: booking.contactNumber),
            if (booking.passengerEmail != null)
              _InfoRow(label: 'Email', value: booking.passengerEmail!),
            _InfoRow(
              label: 'Seats',
              value: booking.seatNumbers.join(', '),
            ),
            if (booking.pickupLocation != null)
              _InfoRow(label: 'Pickup Location', value: booking.pickupLocation!),
            if (booking.dropoffLocation != null)
              _InfoRow(label: 'Dropoff Location', value: booking.dropoffLocation!),
            if (booking.luggage != null)
              _InfoRow(label: 'Luggage', value: booking.luggage!),
            if (booking.bagCount != null && booking.bagCount! > 0)
              _InfoRow(label: 'Bag Count', value: booking.bagCount!.toString()),
          ],
        ),
      ),
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  final BookingEntity booking;

  const _PaymentInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Payment Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Payment Method',
              value: booking.paymentMethod.toUpperCase(),
            ),
            _InfoRow(
              label: 'Price per Seat',
              value: 'Rs. ${NumberFormat('#,##0').format(booking.price)}',
            ),
            const Divider(),
            _InfoRow(
              label: 'Total Amount',
              value: 'Rs. ${NumberFormat('#,##0').format(booking.totalPrice)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingStatusCard extends StatelessWidget {
  final BookingEntity booking;

  const _BookingStatusCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.status.toLowerCase();
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Booking Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor),
                  const SizedBox(width: 12),
                  Text(
                    booking.status.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Created At',
              value: DateFormat('MMM d, y • h:mm a').format(booking.createdAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    color: isTotal ? Theme.of(context).colorScheme.primary : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
