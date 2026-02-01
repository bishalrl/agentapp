import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';

class DriverCreateBookingPage extends StatefulWidget {
  final String? busId; // Optional pre-selected bus ID

  const DriverCreateBookingPage({
    super.key,
    this.busId,
  });

  @override
  State<DriverCreateBookingPage> createState() => _DriverCreateBookingPageState();
}

class _DriverCreateBookingPageState extends State<DriverCreateBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _passengerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _passengerEmailController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _dropoffLocationController = TextEditingController();
  final _luggageController = TextEditingController();
  
  String? _selectedBusId;
  String _selectedPaymentMethod = 'cash';
  List<dynamic> _selectedSeats = [];
  int _bagCount = 0;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.busId != null) {
      _selectedBusId = widget.busId;
      // Load bus details for seat map
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DriverBloc>().add(GetBusDetailsEvent(busId: widget.busId!));
      });
    }
  }

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

  void _submitBooking(BuildContext context) {
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

    setState(() {
      _hasSubmitted = true;
    });

    context.read<DriverBloc>().add(
      CreateDriverBookingEvent(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<DriverBloc, DriverState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.errorMessage!,
                errorSource: 'Driver Booking',
              ),
            );
          }
          // Check if booking was successful (no error and not loading after submission)
          if (_hasSubmitted && !state.isLoading && state.errorMessage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _hasSubmitted = false;
            });
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
        },
        builder: (context, state) {
          final dashboardData = state.dashboardData;
          final buses = dashboardData?['buses'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bus Selection
                  EnhancedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Bus',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        if (buses.isEmpty)
                          const Text('No buses assigned')
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedBusId,
                            decoration: const InputDecoration(
                              labelText: 'Bus',
                              border: OutlineInputBorder(),
                            ),
                            items: buses.map((bus) {
                              final busData = bus as Map<String, dynamic>;
                              final busId = busData['_id'] ?? busData['id'];
                              final busName = busData['name'] ?? 'Unknown';
                              final vehicleNumber = busData['vehicleNumber'] ?? '';
                              return DropdownMenuItem(
                                value: busId?.toString(),
                                child: Text('$busName ($vehicleNumber)'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBusId = value;
                                _selectedSeats = [];
                              });
                              // Load bus details for seat map
                              if (value != null) {
                                context.read<DriverBloc>().add(GetBusDetailsEvent(busId: value));
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a bus';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Passenger Information
                  EnhancedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passenger Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        TextFormField(
                          controller: _passengerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Passenger Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter passenger name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        TextFormField(
                          controller: _contactNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter contact number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        TextFormField(
                          controller: _passengerEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Email (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        TextFormField(
                          controller: _pickupLocationController,
                          decoration: const InputDecoration(
                            labelText: 'Pickup Location (Optional)',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., New Bus Park',
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        TextFormField(
                          controller: _dropoffLocationController,
                          decoration: const InputDecoration(
                            labelText: 'Dropoff Location (Optional)',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., Pokhara Bus Park',
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _luggageController,
                                decoration: const InputDecoration(
                                  labelText: 'Luggage (Optional)',
                                  border: OutlineInputBorder(),
                                  hintText: 'e.g., 2 bags',
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Bag Count',
                                  border: OutlineInputBorder(),
                                  hintText: '0',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _bagCount = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Seat Selection with Seat Map
                  if (_selectedBusId != null) ...[
                    _SeatSelectionCard(
                      busId: _selectedBusId!,
                      selectedSeats: _selectedSeats,
                      onSeatsChanged: (seats) {
                        setState(() {
                          _selectedSeats = seats;
                        });
                      },
                    ),
                  ] else ...[
                    EnhancedCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        child: Center(
                          child: Text(
                            'Select a bus to view seat map',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Payment Method
                  EnhancedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        RadioListTile<String>(
                          title: const Text('Cash'),
                          value: 'cash',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Online'),
                          value: 'online',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => _submitBooking(context),
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
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeatSelectionCard extends StatelessWidget {
  final String busId;
  final List<dynamic> selectedSeats;
  final Function(List<dynamic>) onSeatsChanged;

  const _SeatSelectionCard({
    required this.busId,
    required this.selectedSeats,
    required this.onSeatsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        final busDetails = state.busDetails;
        
        if (state.isLoading && busDetails == null) {
          return const EnhancedCard(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingL),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (busDetails == null) {
          return EnhancedCard(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Center(
                child: Text(
                  'Failed to load bus details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ),
          );
        }

        final bus = busDetails['bus'] as Map<String, dynamic>? ?? busDetails;
        final totalSeats = bus['totalSeats'] as int? ?? 40;
        final seatConfiguration = bus['seatConfiguration'] as List<dynamic>?;
        final bookedSeats = bus['bookedSeats'] as List<dynamic>? ?? [];
        final lockedSeats = bus['lockedSeats'] as List<dynamic>? ?? [];

        // Generate seat identifiers
        List<dynamic> seatIdentifiers;
        if (seatConfiguration != null && seatConfiguration.isNotEmpty) {
          seatIdentifiers = seatConfiguration;
        } else {
          seatIdentifiers = List.generate(totalSeats, (index) => index + 1);
        }

        return EnhancedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Seats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Tap on available seats to select them',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              _DriverSeatMap(
                seatIdentifiers: seatIdentifiers,
                bookedSeats: bookedSeats,
                lockedSeats: lockedSeats,
                selectedSeats: selectedSeats,
                onSeatTapped: (seatId) {
                  final newSeats = List<dynamic>.from(selectedSeats);
                  final index = newSeats.indexWhere((s) =>
                      s.toString() == seatId.toString() ||
                      (s is num && seatId is num && s.toInt() == seatId.toInt()));
                  if (index != -1) {
                    newSeats.removeAt(index);
                  } else {
                    newSeats.add(seatId);
                  }
                  onSeatsChanged(newSeats);
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              if (selectedSeats.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_seat, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          'Selected: ${selectedSeats.map((s) => s.toString()).join(", ")}',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LegendItem(color: Colors.green, label: 'Available'),
                  _LegendItem(color: Colors.red, label: 'Booked'),
                  _LegendItem(color: Colors.orange, label: 'Selected'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DriverSeatMap extends StatelessWidget {
  final List<dynamic> seatIdentifiers;
  final List<dynamic> bookedSeats;
  final List<dynamic> lockedSeats;
  final List<dynamic> selectedSeats;
  final Function(dynamic) onSeatTapped;

  const _DriverSeatMap({
    required this.seatIdentifiers,
    required this.bookedSeats,
    required this.lockedSeats,
    required this.selectedSeats,
    required this.onSeatTapped,
  });

  bool _isSeatInList(dynamic seatId, List<dynamic> list) {
    return list.any((item) =>
        item.toString() == seatId.toString() ||
        (item is num && seatId is num && item.toInt() == seatId.toInt()));
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
              final isBooked = _isSeatInList(seatId, bookedSeats);
              final isLocked = _isSeatInList(seatId, lockedSeats);
              final isSelected = _isSeatInList(seatId, selectedSeats);
              final isAvailable = !isBooked && !isLocked;

              Color seatColor;
              if (isSelected) {
                seatColor = Colors.orange;
              } else if (isBooked) {
                seatColor = Colors.red;
              } else if (isLocked) {
                seatColor = Colors.grey;
              } else {
                seatColor = Colors.green;
              }

              return GestureDetector(
                onTap: isAvailable ? () => onSeatTapped(seatId) : null,
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
                    child: Text(
                      seatId.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: seatColor,
                      ),
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
