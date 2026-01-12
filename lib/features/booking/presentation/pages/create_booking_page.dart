import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/events/booking_event.dart';
import '../bloc/states/booking_state.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../domain/entities/booking_entity.dart';

class CreateBookingPage extends StatefulWidget {
  const CreateBookingPage({super.key});

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _passengerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _passengerEmailController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _dropoffLocationController = TextEditingController();
  final _luggageController = TextEditingController();
  
  String? _selectedBusId;
  String _selectedPaymentMethod = 'cash';
  List<int> _selectedSeats = [];
  int _bagCount = 0;
  
  @override
  void dispose() {
    _passengerNameController.dispose();
    _contactNumberController.dispose();
    _passengerEmailController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    _luggageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<BookingBloc>()..add(const GetAvailableBusesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Booking'),
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
            }
            if (state.createdBooking != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SuccessSnackBar(
                  message: 'Booking created successfully!',
                ),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.pop();
                }
              });
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.buses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 1: Bus Selection
                    _BusSelectionSection(
                      buses: state.buses,
                      selectedBusId: _selectedBusId,
                      onBusSelected: (busId) {
                        setState(() {
                          _selectedBusId = busId;
                          _selectedSeats = [];
                        });
                        context.read<BookingBloc>().add(GetBusDetailsEvent(busId: busId));
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Step 2: Seat Selection (only if bus is selected)
                    if (_selectedBusId != null && state.selectedBus != null)
                      _SeatSelectionSection(
                        bus: state.selectedBus!,
                        selectedSeats: _selectedSeats,
                        onSeatsChanged: (seats) {
                          setState(() {
                            _selectedSeats = seats;
                          });
                        },
                        onLockSeats: (seats) {
                          context.read<BookingBloc>().add(
                            LockSeatsEvent(busId: _selectedBusId!, seatNumbers: seats),
                          );
                        },
                        onUnlockSeats: (seats) {
                          context.read<BookingBloc>().add(
                            UnlockSeatsEvent(busId: _selectedBusId!, seatNumbers: seats),
                          );
                        },
                      ),
                    
                    if (_selectedBusId != null && state.selectedBus != null) ...[
                      const SizedBox(height: 24),
                      
                      // Selected Bus & Seats Summary
                      if (_selectedSeats.isNotEmpty)
                        _SelectedBusAndSeatsSummary(
                          bus: state.selectedBus!,
                          selectedSeats: _selectedSeats,
                        ),
                      
                      if (_selectedSeats.isNotEmpty) const SizedBox(height: 24),
                      
                      // Step 3: Passenger Information
                      _PassengerInfoSection(
                        passengerNameController: _passengerNameController,
                        contactNumberController: _contactNumberController,
                        passengerEmailController: _passengerEmailController,
                        pickupLocationController: _pickupLocationController,
                        dropoffLocationController: _dropoffLocationController,
                        luggageController: _luggageController,
                        bagCount: _bagCount,
                        onBagCountChanged: (count) {
                          setState(() {
                            _bagCount = count;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Step 4: Payment Method
                      _PaymentMethodSection(
                        selectedPaymentMethod: _selectedPaymentMethod,
                        onPaymentMethodChanged: (method) {
                          setState(() {
                            _selectedPaymentMethod = method;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Booking Summary
                      if (_selectedSeats.isNotEmpty)
                        _BookingSummarySection(
                          bus: state.selectedBus!,
                          selectedSeats: _selectedSeats,
                          paymentMethod: _selectedPaymentMethod,
                        ),
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : () => _submitBooking(context, state),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Create Booking'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitBooking(BuildContext context, BookingState state) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         ErrorSnackBar(message: 'Please select a bus'),
      );
      return;
    }

    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         ErrorSnackBar(message: 'Please select at least one seat'),
      );
      return;
    }

    context.read<BookingBloc>().add(
      CreateBookingEvent(
        busId: _selectedBusId!,
        seatNumbers: _selectedSeats,
        passengerName: _passengerNameController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        passengerEmail: _passengerEmailController.text.trim().isEmpty
            ? null
            : _passengerEmailController.text.trim(),
        pickupLocation: _pickupLocationController.text.trim().isEmpty
            ? null
            : _pickupLocationController.text.trim(),
        dropoffLocation: _dropoffLocationController.text.trim().isEmpty
            ? null
            : _dropoffLocationController.text.trim(),
        luggage: _luggageController.text.trim().isEmpty
            ? null
            : _luggageController.text.trim(),
        bagCount: _bagCount > 0 ? _bagCount : null,
        paymentMethod: _selectedPaymentMethod,
      ),
    );
  }
}

class _BusSelectionSection extends StatelessWidget {
  final List<BusInfoEntity> buses;
  final String? selectedBusId;
  final Function(String) onBusSelected;

  const _BusSelectionSection({
    required this.buses,
    required this.selectedBusId,
    required this.onBusSelected,
  });

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
                  'Select Bus',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (buses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No buses available',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...buses.map((bus) => _BusCard(
                    bus: bus,
                    isSelected: selectedBusId == bus.id,
                    onTap: () => onBusSelected(bus.id),
                  )),
          ],
        ),
      ),
    );
  }
}

class _BusCard extends StatelessWidget {
  final BusInfoEntity bus;
  final bool isSelected;
  final VoidCallback onTap;

  const _BusCard({
    required this.bus,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_bus,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bus.from} → ${bus.to}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${bus.time}${bus.arrival != null ? ' - ${bus.arrival}' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.event, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            DateFormat('MMM d, y').format(bus.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${NumberFormat('#,##0').format(bus.price)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bus.availableSeats > 0 ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${bus.availableSeats} seats',
                      style: TextStyle(
                        fontSize: 12,
                        color: bus.availableSeats > 0 ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatSelectionSection extends StatelessWidget {
  final BusInfoEntity bus;
  final List<int> selectedSeats;
  final Function(List<int>) onSeatsChanged;
  final Function(List<int>) onLockSeats;
  final Function(List<int>) onUnlockSeats;

  const _SeatSelectionSection({
    required this.bus,
    required this.selectedSeats,
    required this.onSeatsChanged,
    required this.onLockSeats,
    required this.onUnlockSeats,
  });

  @override
  Widget build(BuildContext context) {
    final bookedSeats = bus.bookedSeats;
    final lockedSeats = bus.lockedSeats.map((lock) => lock.seatNumber).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_seat, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Select Seats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Seat Map
            _SeatMap(
              totalSeats: bus.totalSeats,
              bookedSeats: bookedSeats,
              lockedSeats: lockedSeats,
              selectedSeats: selectedSeats,
              onSeatTapped: (seatNumber) {
                final newSeats = List<int>.from(selectedSeats);
                if (newSeats.contains(seatNumber)) {
                  newSeats.remove(seatNumber);
                } else {
                  newSeats.add(seatNumber);
                }
                onSeatsChanged(newSeats);
              },
            ),
            const SizedBox(height: 16),
            // Legend
            _SeatLegend(
              onLockSeats: () {
                if (selectedSeats.isNotEmpty) {
                  onLockSeats(selectedSeats);
                }
              },
              onUnlockSeats: () {
                if (selectedSeats.isNotEmpty) {
                  onUnlockSeats(selectedSeats);
                }
              },
            ),
            if (selectedSeats.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected: ${selectedSeats.join(', ')} (${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''})',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SeatMap extends StatelessWidget {
  final int totalSeats;
  final List<int> bookedSeats;
  final List<int> lockedSeats;
  final List<int> selectedSeats;
  final Function(int) onSeatTapped;

  const _SeatMap({
    required this.totalSeats,
    required this.bookedSeats,
    required this.lockedSeats,
    required this.selectedSeats,
    required this.onSeatTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate seats per row (typically 2-2 pattern or 2-1 pattern)
    final seatsPerRow = 4; // 2 seats on each side
    final rows = (totalSeats / seatsPerRow).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Driver/Steering wheel indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.airline_seat_recline_normal, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Front',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Seat grid
          ...List.generate(rows, (rowIndex) {
            final startSeat = rowIndex * seatsPerRow + 1;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(seatsPerRow, (colIndex) {
                  final seatNumber = startSeat + colIndex;
                  if (seatNumber > totalSeats) {
                    return const SizedBox(width: 50, height: 50);
                  }
                  
                  final isBooked = bookedSeats.contains(seatNumber);
                  final isLocked = lockedSeats.contains(seatNumber);
                  final isSelected = selectedSeats.contains(seatNumber);
                  
                  return _SeatWidget(
                    seatNumber: seatNumber,
                    isBooked: isBooked,
                    isLocked: isLocked,
                    isSelected: isSelected,
                    onTap: isBooked || isLocked ? null : () => onSeatTapped(seatNumber),
                  );
                }),
              ),
            );
          }),
          // Back indicator
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.airline_seat_recline_normal, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Back',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatWidget extends StatelessWidget {
  final int seatNumber;
  final bool isBooked;
  final bool isLocked;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SeatWidget({
    required this.seatNumber,
    required this.isBooked,
    required this.isLocked,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    if (isBooked) {
      backgroundColor = Colors.red[300]!;
      textColor = Colors.white;
      icon = Icons.block;
    } else if (isLocked) {
      backgroundColor = Colors.orange[300]!;
      textColor = Colors.white;
      icon = Icons.lock;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Colors.white;
      icon = Icons.check;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: textColor, size: 20)
              : Text(
                  seatNumber.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  final VoidCallback onLockSeats;
  final VoidCallback onUnlockSeats;

  const _SeatLegend({
    required this.onLockSeats,
    required this.onUnlockSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendItem(
          color: Colors.white,
          label: 'Available',
        ),
        _LegendItem(
          color: Colors.red[300]!,
          label: 'Booked',
          icon: Icons.block,
        ),
        _LegendItem(
          color: Colors.orange[300]!,
          label: 'Locked',
          icon: Icons.lock,
        ),
        _LegendItem(
          color: Theme.of(context).colorScheme.primary,
          label: 'Selected',
          icon: Icons.check,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;

  const _LegendItem({
    required this.color,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: icon != null
              ? Icon(icon, size: 16, color: Colors.white)
              : null,
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

class _PassengerInfoSection extends StatelessWidget {
  final TextEditingController passengerNameController;
  final TextEditingController contactNumberController;
  final TextEditingController passengerEmailController;
  final TextEditingController pickupLocationController;
  final TextEditingController dropoffLocationController;
  final TextEditingController luggageController;
  final int bagCount;
  final Function(int) onBagCountChanged;

  const _PassengerInfoSection({
    required this.passengerNameController,
    required this.contactNumberController,
    required this.passengerEmailController,
    required this.pickupLocationController,
    required this.dropoffLocationController,
    required this.luggageController,
    required this.bagCount,
    required this.onBagCountChanged,
  });

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
            TextFormField(
              controller: passengerNameController,
              decoration: InputDecoration(
                labelText: 'Passenger Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passenger name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: contactNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid contact number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passengerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Location & Luggage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: pickupLocationController,
              decoration: InputDecoration(
                labelText: 'Pickup Location (Optional)',
                hintText: 'e.g., Bus Park, City Center',
                prefixIcon: const Icon(Icons.place_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dropoffLocationController,
              decoration: InputDecoration(
                labelText: 'Dropoff Location (Optional)',
                hintText: 'e.g., Bus Park, City Center',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: luggageController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Luggage Description (Optional)',
                hintText: 'e.g., 2 suitcases, 1 backpack',
                prefixIcon: const Icon(Icons.luggage_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Bag Count',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: bagCount > 0
                          ? () => onBagCountChanged(bagCount - 1)
                          : null,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bagCount.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => onBagCountChanged(bagCount + 1),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;

  const _PaymentMethodSection({
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

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
                  'Payment Method',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PaymentMethodOption(
                    icon: Icons.money,
                    label: 'Cash',
                    value: 'cash',
                    isSelected: selectedPaymentMethod == 'cash',
                    onTap: () => onPaymentMethodChanged('cash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PaymentMethodOption(
                    icon: Icons.credit_card,
                    label: 'Online',
                    value: 'online',
                    isSelected: selectedPaymentMethod == 'online',
                    onTap: () => onPaymentMethodChanged('online'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingSummarySection extends StatelessWidget {
  final BusInfoEntity bus;
  final List<int> selectedSeats;
  final String paymentMethod;

  const _BookingSummarySection({
    required this.bus,
    required this.selectedSeats,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = bus.price * selectedSeats.length;
    
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Booking Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(label: 'Seats', value: selectedSeats.join(', ')),
            _SummaryRow(label: 'Seats Count', value: '${selectedSeats.length}'),
            _SummaryRow(label: 'Price per Seat', value: 'Rs. ${NumberFormat('#,##0').format(bus.price)}'),
            const Divider(),
            _SummaryRow(
              label: 'Total Amount',
              value: 'Rs. ${NumberFormat('#,##0').format(totalPrice)}',
              isTotal: true,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Payment: ${paymentMethod.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Theme.of(context).colorScheme.primary : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _SelectedBusAndSeatsSummary extends StatelessWidget {
  final BusInfoEntity bus;
  final List<int> selectedSeats;

  const _SelectedBusAndSeatsSummary({
    required this.bus,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Bus & Seats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review your selection',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            // Bus Information
            Row(
              children: [
                Icon(Icons.directions_bus, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bus.from} → ${bus.to}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${bus.time}${bus.arrival != null ? ' - ${bus.arrival}' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.event, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              DateFormat('MMM d, y').format(bus.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            // Selected Seats
            Row(
              children: [
                Icon(Icons.event_seat, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Seats',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedSeats.map((seatNumber) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_seat,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  seatNumber.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''} selected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Rs. ${NumberFormat('#,##0').format(bus.price * selectedSeats.length)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
