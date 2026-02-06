import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/events/booking_event.dart';
import '../bloc/states/booking_state.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../domain/entities/booking_entity.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<BookingBloc>()..add(GetBookingDetailsEvent(bookingId: bookingId)),
      child: BackButtonHandler(
        enableDoubleBackToExit: false,
        child: Scaffold(
        appBar: AppAppBar(
          title: 'Booking Details',
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
              return ErrorStateWidget(
                message: state.errorMessage!,
                onRetry: () => context.read<BookingBloc>().add(GetBookingDetailsEvent(bookingId: bookingId)),
              );
            }

            final booking = state.selectedBooking;
            if (booking == null) {
              return const Center(child: Text('Booking not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BookingHeaderCard(booking: booking),
                  const SizedBox(height: AppTheme.spacingM),
                  _BusInfoCard(bus: booking.bus),
                  const SizedBox(height: AppTheme.spacingM),
                  _PassengerInfoCard(booking: booking),
                  const SizedBox(height: AppTheme.spacingM),
                  _PaymentInfoCard(booking: booking),
                  const SizedBox(height: AppTheme.spacingM),
                  _BookingStatusCard(booking: booking),
                ],
              ),
            );
          },
        ),
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
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
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
    final theme = Theme.of(context);
    final status = booking.status.toLowerCase();
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'confirmed':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel_rounded;
        break;
      case 'pending':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending_rounded;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.info_rounded;
    }
    
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
      border: Border.all(
        color: AppTheme.primaryColor.withOpacity(0.2),
        width: 2,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            booking.ticketNumber,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              border: Border.all(
                color: statusColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  booking.status.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'ID: ${booking.id.substring(0, 8)}...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BusInfoCard extends StatelessWidget {
  final BusInfoEntity bus;

  const _BusInfoCard({required this.bus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Bus Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
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
    );
  }
}

class _PassengerInfoCard extends StatelessWidget {
  final BookingEntity booking;

  const _PassengerInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Passenger Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _InfoRow(label: 'Name', value: booking.passengerName),
          _InfoRow(label: 'Contact', value: booking.contactNumber),
          if (booking.passengerEmail != null)
            _InfoRow(label: 'Email', value: booking.passengerEmail!),
          _InfoRow(
            label: 'Seats',
            value: booking.seatNumbers.map((s) => s.toString()).join(', '),
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
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  final BookingEntity booking;

  const _PaymentInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Payment Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _InfoRow(
            label: 'Payment Method',
            value: booking.paymentMethod.toUpperCase(),
          ),
          _InfoRow(
            label: 'Price per Seat',
            value: 'Rs. ${NumberFormat('#,##0').format(booking.price)}',
          ),
          const Divider(height: AppTheme.spacingM),
          _InfoRow(
            label: 'Total Amount',
            value: 'Rs. ${NumberFormat('#,##0').format(booking.totalPrice)}',
            isTotal: true,
          ),
        ],
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

    final theme = Theme.of(context);
    switch (status) {
      case 'confirmed':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel_rounded;
        break;
      case 'pending':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending_rounded;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.info_rounded;
    }

    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Booking Status',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.status.toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        status == 'confirmed'
                            ? 'This booking is confirmed'
                            : status == 'cancelled'
                                ? 'This booking has been cancelled'
                                : 'This booking is pending confirmation',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _InfoRow(
            label: 'Created At',
            value: DateFormat('MMM d, y • h:mm a').format(booking.createdAt),
          ),
        ],
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
