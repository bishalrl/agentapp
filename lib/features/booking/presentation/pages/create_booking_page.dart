import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/events/booking_event.dart';
import '../bloc/states/booking_state.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/utils/user_type_helper.dart';
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
  List<dynamic> _selectedSeats = []; // Supports both int (legacy) and String (new format)
  int _bagCount = 0;
  bool _isBetaAgent = false;
  bool _isLoadingUserType = true;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final isBetaAgent = await UserTypeHelper.isBetaAgent();
    setState(() {
      _isBetaAgent = isBetaAgent;
      _isLoadingUserType = false;
    });
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

  @override
  Widget build(BuildContext context) {
    // Show loading while checking user type
    if (_isLoadingUserType) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Booking')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      // Use a fresh BookingBloc instance from DI to avoid using a closed bloc
      create: (context) => di.sl<BookingBloc>()..add(const GetAvailableBusesEvent()),
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
              padding: const EdgeInsets.all(AppTheme.spacingM),
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
                    if (_selectedBusId != null && state.selectedBus != null) ...[
                      // Check hasAccess before rendering seat map
                      if (state.selectedBus!.hasAccess == false || 
                          (state.selectedBus!.hasAccess == null && 
                           state.selectedBus!.hasNoAccess == true)) ...[
                        // No access - show message instead of seat map
                        EnhancedCard(
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingL),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.block,
                                  size: 64,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(height: AppTheme.spacingM),
                                Text(
                                  'No Access',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[700],
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacingS),
                                Text(
                                  state.selectedBus!.hasAccess == false
                                      ? 'You do not have access to this bus. Please request access first.'
                                      : 'You do not have permission to book seats on this bus.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Has access - show seat selection
                        _SeatSelectionSection(
                          bus: state.selectedBus!,
                          selectedSeats: _selectedSeats,
                          isBetaAgent: _isBetaAgent,
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
                      ],
                    ],
                    
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

    // Validate seat access before API call
    final selectedBus = state.selectedBus;
    if (selectedBus != null) {
      // Check if counter has no access
      if (selectedBus.hasNoAccess == true || selectedBus.hasAccess == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar(
            message: selectedBus.hasAccess == false
                ? 'You do not have access to this bus. Please request access first.'
                : 'You do not have permission to book seats on this bus.',
          ),
        );
        return;
      }

      // Normalize selected seats for comparison (matches backend normalization)
      // Convert numeric strings to numbers, keep non-numeric as strings
      final normalizedSelectedSeats = _selectedSeats.map((seat) {
        if (seat == null) return null;
        
        // If already a number, keep as number
        if (seat is int) return seat;
        if (seat is num) return seat.toInt();
        
        // If string, try to parse as number
        if (seat is String) {
          final trimmed = seat.trim();
          if (trimmed.isEmpty) return null;
          
          // Try parsing as number
          final numValue = int.tryParse(trimmed);
          if (numValue != null && trimmed == numValue.toString()) {
            // It's a numeric string like "1", "2", "3" - convert to int
            return numValue;
          } else {
            // Non-numeric string like "A1", "B2" - keep as string
            return trimmed;
          }
        }
        
        // For other types, convert to string
        final str = seat.toString().trim();
        if (str.isEmpty) return null;
        final numValue = int.tryParse(str);
        if (numValue != null && str == numValue.toString()) {
          return numValue;
        }
        return str;
      }).where((seat) => seat != null).toList();

      // Beta agents can book ANY seat - bypass all restrictions
      // Check if counter has restricted access and validate selected seats (only for non-beta agents)
      if (!_isBetaAgent && selectedBus.hasRestrictedAccess == true) {
        // First, validate against allowedSeats
        if (selectedBus.allowedSeats != null && selectedBus.allowedSeats!.isNotEmpty) {
          // Find seats that are not in allowedSeats
          // Check both numeric and string comparisons to handle type mismatches
          final notAllowedSeats = normalizedSelectedSeats.where((seat) {
            // Try multiple comparison methods to handle type mismatches
            if (seat is int) {
              // Check if seat number is in allowedSeats (as int or string)
              return !selectedBus.allowedSeats!.contains(seat) &&
                     !selectedBus.allowedSeats!.any((allowed) => 
                       allowed is int ? allowed == seat : 
                       allowed.toString() == seat.toString()
                     );
            }
            // For string seats or mixed types, check string comparison
            final seatStr = seat.toString();
            return !selectedBus.allowedSeats!.any((allowed) {
              // Try multiple comparison methods
              if (allowed is int) {
                return allowed.toString() == seatStr || allowed == int.tryParse(seatStr);
              }
              return allowed.toString() == seatStr;
            });
          }).toList();

          if (notAllowedSeats.isNotEmpty) {
            final allowedSeatsStr = selectedBus.allowedSeats!.map((s) => s.toString()).join(', ');
            final notAllowedStr = notAllowedSeats.map((s) => s.toString()).join(', ');
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: 'You are not allowed to book seat(s): $notAllowedStr. You can only book: $allowedSeatsStr',
              ),
            );
            return;
          }
        }

        // Second, validate against availableAllowedSeats (seats that are BOTH allowed AND available)
        if (selectedBus.availableAllowedSeats != null && selectedBus.availableAllowedSeats!.isNotEmpty) {
          // Find seats that are not in availableAllowedSeats
          // Check both numeric and string comparisons to handle type mismatches
          final notAvailableSeats = normalizedSelectedSeats.where((seat) {
            // Try multiple comparison methods to handle type mismatches
            if (seat is int) {
              // Check if seat number is in availableAllowedSeats (as int or string)
              return !selectedBus.availableAllowedSeats!.contains(seat) &&
                     !selectedBus.availableAllowedSeats!.any((allowed) => 
                       allowed is int ? allowed == seat : 
                       allowed.toString() == seat.toString()
                     );
            }
            // For string seats or mixed types, check string comparison
            final seatStr = seat.toString();
            return !selectedBus.availableAllowedSeats!.any((allowed) {
              // Try multiple comparison methods
              if (allowed is int) {
                return allowed.toString() == seatStr || allowed == int.tryParse(seatStr);
              }
              return allowed.toString() == seatStr;
            });
          }).toList();

          if (notAvailableSeats.isNotEmpty) {
            final availableSeatsStr = selectedBus.availableAllowedSeats!.map((s) => s.toString()).join(', ');
            final notAvailableStr = notAvailableSeats.map((s) => s.toString()).join(', ');
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: 'Seat(s) $notAvailableStr are not currently available. Available seats: $availableSeatsStr',
              ),
            );
            return;
          }
        } else if (selectedBus.allowedSeats != null && selectedBus.allowedSeats!.isNotEmpty) {
          // If availableAllowedSeats is empty but allowedSeats exists, no seats are available
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              message: 'No seats are currently available for booking on this bus.',
            ),
          );
          return;
        }
      }
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
    final theme = Theme.of(context);

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
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.titleMedium?.color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bus.from} → ${bus.to}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? Colors.white70
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${bus.time}${bus.arrival != null ? ' - ${bus.arrival}' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected ? Colors.white70 : Colors.grey[600],
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.event,
                          size: 16,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            DateFormat('MMM d, y').format(bus.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected ? Colors.white70 : Colors.grey[600],
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
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.primary,
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
  final List<dynamic> selectedSeats; // Supports both int and String
  final Function(List<dynamic>) onSeatsChanged;
  final Function(List<dynamic>) onLockSeats;
  final Function(List<dynamic>) onUnlockSeats;
  final bool isBetaAgent;

  const _SeatSelectionSection({
    required this.bus,
    required this.selectedSeats,
    required this.onSeatsChanged,
    required this.onLockSeats,
    required this.onUnlockSeats,
    required this.isBetaAgent,
  });

  @override
  Widget build(BuildContext context) {
    // Extract booked seats - handle both int and String formats
    final bookedSeats = bus.bookedSeats.map((seat) {
      if (seat is num) return seat.toInt();
      if (seat is String) return seat;
      return seat.toString();
    }).toList();
    
    // Extract locked seats - handle SeatLockEntity objects
    final lockedSeats = bus.lockedSeats.map((lock) {
      final seatNum = lock.seatNumber;
      if (seatNum is num) return seatNum.toInt();
      if (seatNum is String) return seatNum;
      return seatNum.toString();
    }).toList();
    
    final seatConfiguration = bus.seatConfiguration;
    final totalSeats = bus.totalSeats;
    
    // Debug: Print seat information
    print('🔍 _SeatSelectionSection: Bus seat information');
    print('   Total Seats: $totalSeats');
    print('   Booked Seats: $bookedSeats (${bookedSeats.length})');
    print('   Locked Seats: $lockedSeats (${lockedSeats.length})');
    print('   Allowed Seats: ${bus.allowedSeats}');
    print('   Allowed Seats Count: ${bus.allowedSeatsCount}');
    print('   Has Restricted Access: ${bus.hasRestrictedAccess}');
    print('   Has Full Access: ${bus.hasFullAccess}');
    print('   Has No Access: ${bus.hasNoAccess}');
    print('   Available Allowed Seats: ${bus.availableAllowedSeats}');
    print('   Available Allowed Seats Count: ${bus.availableAllowedSeatsCount}');
    print('   Seat Configuration: $seatConfiguration');
    print('   Available Seats: ${totalSeats - bookedSeats.length - lockedSeats.length}');
    
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
                  Icons.event_seat_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Select Seats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          // Show access status info based on backend flags
          // Show restricted access warning only for non-beta agents
          if (!isBetaAgent && bus.hasRestrictedAccess == true) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          'Restricted Access',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty)
                    Text(
                      'You can only book seats: ${bus.allowedSeats!.map((s) => s.toString()).join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  if (bus.availableAllowedSeats != null && bus.availableAllowedSeats!.isNotEmpty)
                    Text(
                      'Available allowed seats: ${bus.availableAllowedSeats!.map((s) => s.toString()).join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ] else if (bus.hasNoAccess == true) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'No Access: You do not have permission to book seats on this bus.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ] else if (bus.hasFullAccess == true) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'Full Access: You can book any available seat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ],
          // Seat Map
          _SeatMap(
            bus: bus,
            totalSeats: bus.totalSeats,
            seatConfiguration: seatConfiguration,
            bookedSeats: bookedSeats,
            lockedSeats: lockedSeats,
            selectedSeats: selectedSeats,
            isBetaAgent: isBetaAgent,
            onSeatTapped: (seatIdentifier) {
              final newSeats = List<dynamic>.from(selectedSeats);
              // Use proper comparison for both int and String
              final index = newSeats.indexWhere((s) => 
                s == seatIdentifier || 
                s.toString() == seatIdentifier.toString()
              );
              if (index != -1) {
                newSeats.removeAt(index);
              } else {
                newSeats.add(seatIdentifier);
              }
              onSeatsChanged(newSeats);
            },
          ),
          const SizedBox(height: 16),
          // Seat Status Summary
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SeatStatusItem(
                  icon: Icons.event_seat,
                  color: Colors.green,
                  label: bus.hasRestrictedAccess == true 
                      ? 'Available Allowed' 
                      : 'Available',
                  count: bus.hasRestrictedAccess == true && bus.availableAllowedSeatsCount != null
                      ? bus.availableAllowedSeatsCount!
                      : (totalSeats - bookedSeats.length - lockedSeats.length),
                ),
                _SeatStatusItem(
                  icon: Icons.event_busy,
                  color: Colors.red,
                  label: 'Booked',
                  count: bookedSeats.length,
                ),
                _SeatStatusItem(
                  icon: Icons.lock,
                  color: Colors.orange,
                  label: 'Locked',
                  count: lockedSeats.length,
                ),
                if (bus.hasRestrictedAccess == true && bus.allowedSeatsCount != null)
                  _SeatStatusItem(
                    icon: Icons.check_circle,
                    color: Colors.blue,
                    label: 'Allowed',
                    count: bus.allowedSeatsCount!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          _SeatLegend(
            hasRestrictedSeats: bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty,
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
                      'Selected: ${selectedSeats.map((s) => s.toString()).join(', ')} (${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SeatMap extends StatelessWidget {
  final BusInfoEntity bus; // Bus entity to check allowedSeats
  final int totalSeats;
  final List<String>? seatConfiguration; // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
  final List<dynamic> bookedSeats; // Supports both int and String
  final List<dynamic> lockedSeats; // Supports both int and String
  final List<dynamic> selectedSeats; // Supports both int and String
  final Function(dynamic) onSeatTapped; // Accepts both int and String
  final bool isBetaAgent;

  const _SeatMap({
    required this.bus,
    required this.totalSeats,
    this.seatConfiguration,
    required this.bookedSeats,
    required this.lockedSeats,
    required this.selectedSeats,
    required this.onSeatTapped,
    required this.isBetaAgent,
  });

  @override
  Widget build(BuildContext context) {
    // Use seatConfiguration if available, otherwise use sequential numbering
    List<dynamic> seatIdentifiers;
    if (seatConfiguration != null && seatConfiguration!.isNotEmpty) {
      seatIdentifiers = seatConfiguration!;
    } else {
      // Fallback to sequential numbering (1, 2, 3, ...)
      seatIdentifiers = List.generate(totalSeats, (index) => index + 1);
    }
    
    // Filter seats based on counter access permissions - only show allowed seats
    // Note: We show all allowed seats (even if booked/locked) but disable selection
    // Beta agents can see ALL seats - bypass restrictions
    // This gives better UX - user can see what seats they have access to
    if (!isBetaAgent && bus.hasRestrictedAccess == true) {
      // Counter has restricted access - only show allowed seats
      if (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty) {
        seatIdentifiers = seatIdentifiers.where((seatIdentifier) {
          // Convert seatIdentifier to int for comparison
          final seatNum = seatIdentifier is int 
              ? seatIdentifier 
              : (seatIdentifier is String && int.tryParse(seatIdentifier) != null)
                  ? int.parse(seatIdentifier)
                  : null;
          if (seatNum != null) {
            return bus.allowedSeats!.contains(seatNum);
          }
          // For string-based seat identifiers, check if it matches any allowed seat number
          return bus.allowedSeats!.any((allowed) => 
            allowed.toString() == seatIdentifier.toString()
          );
        }).toList();
      } else {
        // Restricted access but no allowed seats = no seats to show
        seatIdentifiers = [];
      }
    } else if (bus.hasNoAccess == true || bus.hasAccess == false) {
      // Counter has no access - show no seats
      seatIdentifiers = [];
    } else if (bus.hasFullAccess == true) {
      // Counter has full access - show all seats (no filtering needed)
      // seatIdentifiers remains unchanged
    } else {
      // Fallback: check allowedSeats if flag not available
      if (bus.allowedSeats != null) {
        if (bus.allowedSeats!.isEmpty) {
          // Empty list = no access
          seatIdentifiers = [];
        } else {
          // Filter to only show allowed seats
          seatIdentifiers = seatIdentifiers.where((seatIdentifier) {
            final seatNum = seatIdentifier is int 
                ? seatIdentifier 
                : (seatIdentifier is String && int.tryParse(seatIdentifier) != null)
                    ? int.parse(seatIdentifier)
                    : null;
            if (seatNum != null) {
              return bus.allowedSeats!.contains(seatNum);
            }
            return bus.allowedSeats!.any((allowed) => 
              allowed.toString() == seatIdentifier.toString()
            );
          }).toList();
        }
      }
    }
    
    // Calculate seats per row (typically 2-2 pattern or 2-1 pattern)
    final seatsPerRow = 4; // 2 seats on each side
    final rows = (seatIdentifiers.length / seatsPerRow).ceil();
    
    // Helper to normalize seat IDs for comparison (handles int, String, num)
    // Converts everything to a consistent string format for comparison
    String normalizeSeatId(dynamic seatId) {
      if (seatId == null) return '';
      
      // Handle num types (int, double)
      if (seatId is num) {
        // For integers, return as int string (e.g., "1" not "1.0")
        if (seatId is int) return seatId.toString();
        // For doubles, check if it's a whole number
        if (seatId == seatId.roundToDouble()) {
          return seatId.toInt().toString();
        }
        return seatId.toString();
      }
      
      // Handle String types
      if (seatId is String) {
        // Try to parse as int to normalize (e.g., "1" vs 1)
        final parsed = int.tryParse(seatId.trim());
        if (parsed != null) return parsed.toString();
        // Return trimmed uppercase for case-insensitive comparison
        return seatId.trim().toUpperCase();
      }
      
      // Fallback: convert to string
      return seatId.toString().trim();
    }
    
    // Helper function to check if a seat is booked/locked/selected
    // Handles both int and String seat identifiers
    bool isSeatInList(dynamic seatId, List<dynamic> list) {
      if (list.isEmpty) return false;
      
      // Normalize seatId for comparison
      final normalizedSeatId = normalizeSeatId(seatId);
      
      return list.any((item) {
        final normalizedItem = normalizeSeatId(item);
        // Try multiple comparison methods
        return normalizedSeatId == normalizedItem ||
               normalizedSeatId.toString() == normalizedItem.toString() ||
               normalizedSeatId.toString().toLowerCase() == normalizedItem.toString().toLowerCase();
      });
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Driver/Steering wheel indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.airline_seat_recline_normal_rounded,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Front',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          // Seat grid
          if (seatIdentifiers.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'No seats available for booking.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (bus.hasNoAccess == true)
                      Padding(
                        padding: const EdgeInsets.only(top: AppTheme.spacingS),
                        child: Text(
                          'You do not have access to book seats on this bus.',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...List.generate(rows, (rowIndex) {
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
                  
                  final seatIdentifier = seatIdentifiers[seatIndex];
                  final isBooked = isSeatInList(seatIdentifier, bookedSeats);
                  final isLocked = isSeatInList(seatIdentifier, lockedSeats);
                  final isSelected = isSeatInList(seatIdentifier, selectedSeats);
                  
                  // Debug first few seats to verify comparison
                  if (seatIndex < 3) {
                    print('🔍 Seat Map Debug - Seat $seatIndex:');
                    print('   Seat Identifier: $seatIdentifier (type: ${seatIdentifier.runtimeType})');
                    print('   Normalized: ${normalizeSeatId(seatIdentifier)}');
                    print('   Is Booked: $isBooked');
                    print('   Is Locked: $isLocked');
                    print('   Booked Seats: $bookedSeats');
                    print('   Locked Seats: $lockedSeats');
                  }
                  
                  // Since we've already filtered seatIdentifiers to only include allowed seats,
                  // all seats shown here are allowed. However, we need to check if they're available for selection.
                  // Use availableAllowedSeats to determine if seat can be selected
                  bool isSeatSelectable = true;
                  
                  // Check if seat is in availableAllowedSeats (seats that are BOTH allowed AND available)
                  // Beta agents can select ANY seat (if not booked/locked)
                  if (isBetaAgent) {
                    isSeatSelectable = !isBooked && !isLocked;
                  } else if (bus.hasRestrictedAccess == true && 
                      bus.availableAllowedSeats != null && 
                      bus.availableAllowedSeats!.isNotEmpty) {
                    // Only seats in availableAllowedSeats can be selected
                    final seatNum = seatIdentifier is int 
                        ? seatIdentifier 
                        : (seatIdentifier is String && int.tryParse(seatIdentifier) != null)
                            ? int.parse(seatIdentifier)
                            : null;
                    if (seatNum != null) {
                      isSeatSelectable = bus.availableAllowedSeats!.contains(seatNum);
                    } else {
                      isSeatSelectable = bus.availableAllowedSeats!.any((allowed) => 
                        allowed.toString() == seatIdentifier.toString()
                      );
                    }
                  } else if (bus.hasNoAccess == true) {
                    isSeatSelectable = false;
                  } else if (bus.hasFullAccess == true) {
                    // Full access - seat is selectable if not booked/locked
                    isSeatSelectable = !isBooked && !isLocked;
                  } else {
                    // Fallback: check if seat is allowed (for backward compatibility)
                    bool isSeatAllowed = true;
                    if (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty) {
                      final seatNum = seatIdentifier is int 
                          ? seatIdentifier 
                          : (seatIdentifier is String && int.tryParse(seatIdentifier) != null)
                              ? int.parse(seatIdentifier)
                              : null;
                      if (seatNum != null) {
                        isSeatAllowed = bus.allowedSeats!.contains(seatNum);
                      } else {
                        isSeatAllowed = bus.allowedSeats!.any((allowed) => 
                          allowed.toString() == seatIdentifier.toString()
                        );
                      }
                    }
                    isSeatSelectable = isSeatAllowed && !isBooked && !isLocked;
                  }
                  
                  return _SeatWidget(
                    seatIdentifier: seatIdentifier,
                    isBooked: isBooked,
                    isLocked: isLocked,
                    isSelected: isSelected,
                    isNotAllowed: !isSeatSelectable, // Disable if not selectable
                    onTap: (isBooked || isLocked || !isSeatSelectable)
                        ? null 
                        : () => onSeatTapped(seatIdentifier),
                  );
                }),
              ),
            );
          }),
          ],
          // Back indicator
          if (seatIdentifiers.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.airline_seat_recline_normal_rounded,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Back',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ],
        ],
      ),
    );
  }
}

class _SeatWidget extends StatelessWidget {
  final dynamic seatIdentifier; // Supports both int and String
  final bool isBooked;
  final bool isLocked;
  final bool isSelected;
  final bool isNotAllowed; // Seat not in allowedSeats list
  final VoidCallback? onTap;

  const _SeatWidget({
    required this.seatIdentifier,
    required this.isBooked,
    required this.isLocked,
    required this.isSelected,
    this.isNotAllowed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;
    String statusText = '';

    // Determine seat status and styling
    if (isBooked) {
      backgroundColor = Colors.red[400]!;
      textColor = Colors.white;
      icon = Icons.event_busy;
      statusText = 'Booked';
    } else if (isNotAllowed) {
      backgroundColor = Colors.grey[400]!;
      textColor = Colors.grey[800]!;
      icon = Icons.block;
      statusText = 'Blocked';
    } else if (isLocked) {
      backgroundColor = Colors.orange[400]!;
      textColor = Colors.white;
      icon = Icons.lock;
      statusText = 'Locked';
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Colors.white;
      icon = Icons.check_circle;
      statusText = 'Selected';
    } else {
      backgroundColor = Colors.green[50]!;
      textColor = Colors.green[900]!;
      statusText = 'Available';
    }

    return Tooltip(
      message: '$statusText - Seat ${seatIdentifier.toString()}',
      child: InkWell(
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
                  : (isBooked || isLocked || isNotAllowed)
                      ? backgroundColor
                      : Colors.grey[300]!,
              width: isSelected ? 2.5 : (isBooked || isLocked || isNotAllowed) ? 2 : 1,
            ),
            boxShadow: (isBooked || isLocked || isSelected)
                ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Seat number/text
              Text(
                seatIdentifier.toString(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              // Status icon overlay (top-right corner)
              if (icon != null && (isBooked || isLocked || isNotAllowed || isSelected))
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: textColor,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  final bool hasRestrictedSeats;
  final VoidCallback onLockSeats;
  final VoidCallback onUnlockSeats;

  const _SeatLegend({
    this.hasRestrictedSeats = false,
    required this.onLockSeats,
    required this.onUnlockSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppTheme.spacingM,
      runSpacing: AppTheme.spacingS,
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
        if (hasRestrictedSeats)
          _LegendItem(
            color: Colors.grey[300]!,
            label: 'Not Allowed',
            icon: Icons.block,
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

class _SeatStatusItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  const _SeatStatusItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
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
  final List<dynamic> selectedSeats; // Supports both int (legacy) and String (new format)
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
  final List<dynamic> selectedSeats; // Supports both int (legacy) and String (new format)

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
