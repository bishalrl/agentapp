import 'package:agentapp/core/errors/failures.dart';
import 'package:agentapp/core/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../features/booking/domain/usecases/get_bus_details.dart' as booking_usecases;
import '../../../../features/booking/domain/entities/booking_entity.dart';
import '../../../../features/bus_management/presentation/bloc/bus_bloc.dart';
import '../../../../features/bus_management/presentation/bloc/states/bus_state.dart' as bus_management_state;
import '../../../../features/bus_management/presentation/bloc/events/bus_event.dart';
import '../../../../features/bus_management/domain/entities/bus_entity.dart';
import '../bloc/counter_request_bloc.dart';
import '../bloc/events/counter_request_event.dart';
import '../bloc/states/counter_request_state.dart';

class RequestBusAccessPage extends StatefulWidget {
  final String? busId; // Optional pre-selected bus ID

  const RequestBusAccessPage({
    super.key,
    this.busId,
  });

  @override
  State<RequestBusAccessPage> createState() => _RequestBusAccessPageState();
}

class _RequestBusAccessPageState extends State<RequestBusAccessPage> {
  final _formKey = GlobalKey<FormState>();
  final _busSearchController = TextEditingController();
  final _messageController = TextEditingController();
  final List<String> _selectedSeats = [];
  BusInfoEntity? _busDetails;
  BusEntity? _searchedBus;
  bool _isSearching = false;
  String? _busDetailsError;

  @override
  void initState() {
    super.initState();
    if (widget.busId != null) {
      _busSearchController.text = widget.busId!;
      _loadBusDetails(widget.busId!);
    }
  }

  @override
  void dispose() {
    _busSearchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _searchBusByNumber(String busNumber) async {
    if (busNumber.trim().isEmpty) {
      setState(() {
        _busDetailsError = 'Please enter a vehicle number';
        _searchedBus = null;
        _busDetails = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _busDetailsError = null;
      _searchedBus = null;
      _busDetails = null;
      _selectedSeats.clear();
    });

    // Trigger search via BusBloc
    if (mounted) {
      context.read<BusBloc>().add(SearchBusByNumberEvent(busNumber: busNumber.trim()));
    }
  }

  Future<void> _loadBusDetails(String busId) async {
    setState(() {
      _isSearching = true;
      _busDetailsError = null;
      _busDetails = null;
      _selectedSeats.clear();
    });

    try {
      final getBusDetails = di.sl<booking_usecases.GetBusDetails>();
      final result = await getBusDetails(busId);
      
      if (result is Success<BusInfoEntity>) {
        setState(() {
          _busDetails = result.data;
          _isSearching = false;
        });
      } else if (result is Error<BusInfoEntity>) {
        setState(() {
          _busDetailsError = result.failure.message;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _busDetailsError = 'Failed to load bus details: $e';
        _isSearching = false;
      });
    }
  }

  void _onBusFound(BusEntity bus) {
    setState(() {
      _searchedBus = bus;
      _busSearchController.text = bus.vehicleNumber ?? bus.id ?? '';
      _isSearching = false;
    });
    // Load full bus details for booking
    if (bus.id != null) {
      _loadBusDetails(bus.id!);
    }
  }

  void _toggleSeat(String seatIdentifier) {
    setState(() {
      if (_selectedSeats.contains(seatIdentifier)) {
        _selectedSeats.remove(seatIdentifier);
      } else {
        _selectedSeats.add(seatIdentifier);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<CounterRequestBloc>()),
        BlocProvider(create: (context) => di.sl<BusBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Request Bus Access'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<CounterRequestBloc, CounterRequestState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              String displayMessage;
              String? errorType;
              
              if (state.errorFailure != null) {
                if (state.errorFailure is NetworkFailure) {
                  displayMessage = 'Network issue. Please check your internet connection and try again.';
                  errorType = 'Network Error';
                } else if (state.errorFailure is AuthenticationFailure) {
                  final authFailure = state.errorFailure as AuthenticationFailure;
                  // Check if it's a credential mismatch error
                  final message = authFailure.message.toLowerCase();
                  if (message.contains('password') || 
                      message.contains('email') || 
                      message.contains('credential') ||
                      message.contains('invalid') ||
                      message.contains('incorrect') ||
                      message.contains('wrong')) {
                    displayMessage = 'Credentials did not match. Please check your email and password.';
                    errorType = 'Authentication Error';
                  } else {
                    displayMessage = authFailure.message;
                    errorType = 'Authentication Error';
                  }
                } else {
                  displayMessage = state.errorMessage!;
                  errorType = 'Error';
                }
              } else {
                // Fallback: check error message content if failure type is not available
                final message = state.errorMessage!.toLowerCase();
                if (message.contains('network') || 
                    message.contains('connection') ||
                    message.contains('timeout') ||
                    message.contains('internet')) {
                  displayMessage = 'Network issue. Please check your internet connection and try again.';
                  errorType = 'Network Error';
                } else if (message.contains('password') || 
                    message.contains('email') || 
                    message.contains('credential') ||
                    message.contains('invalid') ||
                    message.contains('incorrect') ||
                    message.contains('wrong')) {
                  displayMessage = 'Credentials did not match. Please check your email and password.';
                  errorType = 'Authentication Error';
                } else {
                  displayMessage = state.errorMessage!;
                  errorType = 'Error';
                }
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: displayMessage,
                  errorSource: 'Request Bus Access',
                  errorType: errorType,
                ),
              );
            }
            if (state.lastCreatedRequest != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bus access request submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate back after a short delay
              Future.delayed(const Duration(seconds: 1), () {
                if (!mounted) return;
                // Check if we can pop, otherwise navigate to requests list
                if (context.canPop()) {
                  context.pop();
                } else {
                  // If there's nothing to pop, navigate to requests list
                  context.go('/counter/requests');
                }
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bus Search Section
                    EnhancedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.search, color: Theme.of(context).primaryColor),
                              const SizedBox(width: AppTheme.spacingS),
                              Text(
                                'Search Bus',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Search for a bus by vehicle number to request access',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          TextFormField(
                            controller: _busSearchController,
                            decoration: InputDecoration(
                              labelText: 'Vehicle Number *',
                              hintText: 'Enter vehicle number (e.g., BA-12-kha-75787)',
                              prefixIcon: const Icon(Icons.directions_bus),
                              suffixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: () {
                                        if (_busSearchController.text.trim().isNotEmpty) {
                                          _searchBusByNumber(_busSearchController.text.trim());
                                        }
                                      },
                                    ),
                              border: const OutlineInputBorder(),
                              helperText: 'Search by vehicle number to find the bus',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter vehicle number';
                              }
                              if (_searchedBus == null && _busDetails == null) {
                                return 'Please search and select a bus first';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                _searchBusByNumber(value.trim());
                              }
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSearching
                                  ? null
                                  : () {
                                      if (_busSearchController.text.trim().isNotEmpty) {
                                        _searchBusByNumber(_busSearchController.text.trim());
                                      }
                                    },
                              icon: const Icon(Icons.search),
                              label: const Text('Search Bus'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bus Search Results (from BusBloc)
                    BlocListener<BusBloc, bus_management_state.BusState>(
                      listener: (context, busState) {
                        if (busState.searchedBus != null) {
                          _onBusFound(busState.searchedBus!);
                        }
                        if (busState.errorMessage != null && _isSearching) {
                          setState(() {
                            _busDetailsError = busState.errorMessage;
                            _isSearching = false;
                          });
                        }
                      },
                      child: const SizedBox.shrink(),
                    ),

                    // Searched Bus Preview
                    if (_searchedBus != null && _busDetails == null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      EnhancedCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: AppTheme.spacingS),
                                Text(
                                  'Bus Found',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            if (_searchedBus != null)
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: Icon(Icons.directions_bus, color: Theme.of(context).primaryColor),
                                ),
                                title: Text(_searchedBus?.name ?? 'Bus'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Vehicle: ${_searchedBus!.vehicleNumber ?? 'N/A'}'),
                                    Text('Route: ${_searchedBus!.from ?? 'N/A'} → ${_searchedBus!.to ?? 'N/A'}'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Loading State
                    if (_isSearching && _searchedBus == null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: AppTheme.spacingS),
                      Center(
                        child: Text(
                          'Searching for bus...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ),
                    ] else if (_busDetailsError != null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: AppTheme.spacingS),
                            Expanded(
                              child: Text(
                                _busDetailsError!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_busDetails != null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      _BusDetailsCard(bus: _busDetails!),
                      
                      // Check if already has access
                      if (_busDetails!.hasAccess == true) ...[
                        const SizedBox(height: AppTheme.spacingM),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
                              const SizedBox(width: AppTheme.spacingS),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'You already have access to this bus',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    if (_busDetails!.hasRestrictedAccess == true && 
                                        _busDetails!.allowedSeats != null && 
                                        _busDetails!.allowedSeats!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Allowed seats: ${_busDetails!.allowedSeats!.map((s) => s.toString()).join(', ')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Seat Selection (only show if no access or if we have seat info)
                      if (_busDetails!.hasAccess != true || 
                          (_busDetails!.totalSeats > 0 && 
                           (_busDetails!.seatConfiguration != null || _busDetails!.totalSeats > 0))) ...[
                        const SizedBox(height: AppTheme.spacingM),
                        _SeatSelectionCard(
                          bus: _busDetails!,
                          selectedSeats: _selectedSeats,
                          onSeatToggled: _toggleSeat,
                        ),
                      ] else if (_busDetails!.hasAccess == true && _busDetails!.totalSeats == 0) ...[
                        const SizedBox(height: AppTheme.spacingM),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                              const SizedBox(width: AppTheme.spacingS),
                              Expanded(
                                child: Text(
                                  'Seat information is not available. You may still request access.',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Message (Optional)
                      const SizedBox(height: AppTheme.spacingM),
                      EnhancedCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Message (Optional)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            TextFormField(
                              controller: _messageController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Message to Owner',
                                hintText: 'Please approve access to these seats...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Submit Button
                      const SizedBox(height: AppTheme.spacingL),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (state.isLoading || 
                                      _selectedSeats.isEmpty || 
                                      (_searchedBus == null && _busDetails == null))
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_selectedSeats.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please select at least one seat'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    final busId = _searchedBus?.id ?? _busDetails?.id;
                                    if (busId != null) {
                                      context.read<CounterRequestBloc>().add(
                                            RequestBusAccessEvent(
                                              busId: busId,
                                              requestedSeats: _selectedSeats,
                                              message: _messageController.text.trim().isEmpty
                                                  ? null
                                                  : _messageController.text.trim(),
                                            ),
                                          );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please search and select a bus first'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Submit Request'),
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
}

class _BusDetailsCard extends StatelessWidget {
  final BusInfoEntity bus;

  const _BusDetailsCard({required this.bus});

  @override
  Widget build(BuildContext context) {
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
                      bus.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${bus.from} → ${bus.to}',
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
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: DateFormat('MMM dd, yyyy').format(bus.date),
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: bus.time,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.event_seat,
                  label: 'Total Seats',
                  value: bus.totalSeats.toString(),
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.attach_money,
                  label: 'Price',
                  value: 'Rs. ${bus.price.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

class _SeatSelectionCard extends StatelessWidget {
  final BusInfoEntity bus;
  final List<String> selectedSeats;
  final Function(String) onSeatToggled;

  const _SeatSelectionCard({
    required this.bus,
    required this.selectedSeats,
    required this.onSeatToggled,
  });

  @override
  Widget build(BuildContext context) {
    final seatConfiguration = bus.seatConfiguration;
    final bookedSeats = bus.bookedSeats.map((e) => e.toString()).toList();
    
    // Generate seat list
    List<String> seatIdentifiers;
    if (seatConfiguration != null && seatConfiguration.isNotEmpty) {
      seatIdentifiers = seatConfiguration;
    } else {
      seatIdentifiers = List.generate(bus.totalSeats, (index) => (index + 1).toString());
    }

    // For request access page, we show all seats so user can request access to them
    // However, if hasAccess is true and hasRestrictedAccess is true, we can show which seats are already allowed
    // If hasAccess is false, we still show all seats (since this is a request page)
    // Only filter if hasNoAccess is explicitly true (meaning access was denied)
    if (bus.hasNoAccess == true && bus.hasAccess == false) {
      // Access was explicitly denied - show no seats
      seatIdentifiers = [];
    } else if (bus.hasAccess == true && bus.hasRestrictedAccess == true) {
      // Already has restricted access - show allowed seats (user can request more)
      if (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty) {
        // Show allowed seats, but user can still request access to other seats
        // For now, show all seats but highlight allowed ones
        // seatIdentifiers remains unchanged - show all seats
      }
      // Note: We don't filter here because this is a request page - user should see all seats
    }
    // For request access page, we generally show all seats regardless of current access status

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Seats to Request Access',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Select the seats you want to request access to. Owner will review and approve.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          // Show access status info
          if (bus.hasRestrictedAccess == true) ...[
            const SizedBox(height: AppTheme.spacingS),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
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
                      bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty
                          ? 'Restricted Access: You can only request seats: ${bus.allowedSeats!.map((s) => s.toString()).join(', ')}'
                          : 'Restricted Access: No seats available for request.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (bus.hasNoAccess == true) ...[
            const SizedBox(height: AppTheme.spacingS),
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
                      'No Access: You do not have permission to request seats on this bus.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (bus.hasFullAccess == true) ...[
            const SizedBox(height: AppTheme.spacingS),
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
                      'Full Access: You can request any available seat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spacingM),
          // Seat Grid
          if (seatIdentifiers.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'No seats available for request.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ),
          ] else ...[
            Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingS,
              children: seatIdentifiers.map((seatId) {
                final isBooked = bookedSeats.contains(seatId);
                final isSelected = selectedSeats.contains(seatId);
                
                return _SeatChip(
                  seatId: seatId,
                  isBooked: isBooked,
                  isSelected: isSelected,
                  onTap: isBooked ? null : () => onSeatToggled(seatId),
                );
              }).toList(),
            ),
          ],
          if (selectedSeats.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'Selected: ${selectedSeats.join(', ')} (${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''})',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
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

class _SeatChip extends StatelessWidget {
  final String seatId;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SeatChip({
    required this.seatId,
    required this.isBooked,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    
    if (isBooked) {
      backgroundColor = Colors.red[300]!;
      textColor = Colors.white;
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check, size: 16, color: textColor)
            else if (isBooked)
              Icon(Icons.block, size: 16, color: textColor),
            const SizedBox(width: 4),
            Text(
              seatId,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
