import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/utils/bloc_extensions.dart';
import '../../../../core/utils/vehicle_number_formatter.dart';
import '../bloc/bus_bloc.dart';
import '../bloc/events/bus_event.dart';
import '../bloc/states/bus_state.dart';
import '../widgets/seat_selection_widget.dart';

class CreateBusPage extends StatefulWidget {
  const CreateBusPage({super.key});

  @override
  State<CreateBusPage> createState() => _CreateBusPageState();
}

class _CreateBusPageState extends State<CreateBusPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _timeController = TextEditingController();
  final _arrivalController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  final _driverContactController = TextEditingController();
  final _driverEmailController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverLicenseNumberController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final _busTypeController = TextEditingController();
  final _seatConfigurationController = TextEditingController();
  final _amenitiesController = TextEditingController();
  final _routeIdController = TextEditingController();
  final _scheduleIdController = TextEditingController();
  final _distanceController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedArrivalTime;
  bool _useCustomSeats = false;
  bool _showSeatSelection = false;
  List<String> _selectedSeatsFromWidget = [];
  List<Map<String, String>> _boardingPoints = [];
  List<Map<String, String>> _droppingPoints = [];
  
  // Time format selection (default 12h for Nepal)
  String _timeFormat = '12h';
  String _arrivalFormat = '12h';
  
  // Trip direction
  String _tripDirection = 'going';
  
  // Advanced features
  bool _isRecurring = false;
  List<bool> _recurringDays = [false, false, false, false, false, false, false];
  DateTime? _recurringStartDate;
  DateTime? _recurringEndDate;
  String _recurringFrequency = 'daily';
  bool _autoActivate = false;
  DateTime? _activeFromDate;
  DateTime? _activeToDate;

  @override
  void initState() {
    super.initState();
    // Auto-format vehicle number as user types
    _vehicleNumberController.addListener(() {
      final text = _vehicleNumberController.text;
      if (text.isNotEmpty && !text.contains('-')) {
        final formatted = VehicleNumberFormatter.format(text);
        if (formatted != text) {
          _vehicleNumberController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    });
    
    // Show/hide driver name field when email changes
    _driverEmailController.addListener(() {
      setState(() {});
    });
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        // Format time based on selected format
        if (_timeFormat == '12h') {
          final hour = picked.hour == 0 ? 12 : (picked.hour > 12 ? picked.hour - 12 : picked.hour);
          final period = picked.hour >= 12 ? 'PM' : 'AM';
          _timeController.text = '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
        } else {
          _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        }
      });
    }
  }
  
  Future<void> _selectArrivalTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedArrivalTime ?? (_selectedTime ?? TimeOfDay.now()).replacing(hour: (_selectedTime?.hour ?? 0) + 6),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedArrivalTime = picked;
        // Format time based on selected format
        if (_arrivalFormat == '12h') {
          final hour = picked.hour == 0 ? 12 : (picked.hour > 12 ? picked.hour - 12 : picked.hour);
          final period = picked.hour >= 12 ? 'PM' : 'AM';
          _arrivalController.text = '${hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} $period';
        } else {
          _arrivalController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleNumberController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _timeController.dispose();
    _arrivalController.dispose();
    _priceController.dispose();
    _totalSeatsController.dispose();
    _driverContactController.dispose();
    _driverEmailController.dispose();
    _driverNameController.dispose();
    _driverLicenseNumberController.dispose();
    _commissionRateController.dispose();
    _busTypeController.dispose();
    _seatConfigurationController.dispose();
    _amenitiesController.dispose();
    _routeIdController.dispose();
    _scheduleIdController.dispose();
    _distanceController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<BusBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Bus'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/buses');
              }
            },
          ),
        ),
        body: BlocConsumer<BusBloc, BusState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: state.errorMessage!,
                  errorSource: 'Bus Creation',
                ),
              );
            }
            
            if (state.successMessage != null && state.createdBus != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SuccessSnackBar(message: state.successMessage!),
              );
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.pop();
                }
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Bus Name *',
                                hintText: 'e.g., Deluxe Bus',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.directions_bus),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter bus name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _vehicleNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Number *',
                                hintText: 'BA-01-KHA-1234',
                                helperText: 'Auto-formatted: BA-01-KHA-1234',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.confirmation_number),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\s-]')),
                                LengthLimitingTextInputFormatter(20),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter vehicle number';
                                }
                                if (!VehicleNumberFormatter.isValid(value)) {
                                  return 'Invalid format. Use: BA-01-KHA-1234';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _busTypeController,
                              decoration: const InputDecoration(
                                labelText: 'Bus Type',
                                hintText: 'e.g., AC, Non-AC, Sleeper',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _fromController,
                                    decoration: const InputDecoration(
                                      labelText: 'From *',
                                      hintText: 'e.g., Kathmandu',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter origin';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _toController,
                                    decoration: const InputDecoration(
                                      labelText: 'To *',
                                      hintText: 'e.g., Pokhara',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter destination';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Date *',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(
                                        _selectedDate == null
                                            ? 'Select date'
                                            : _selectedDate!.toString().split(' ')[0],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Departure Time *',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.access_time),
                                      ),
                                      child: Text(
                                        _selectedTime == null
                                            ? 'Tap to select time'
                                            : _timeController.text.isEmpty
                                                ? 'Tap to select time'
                                                : _timeController.text,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectArrivalTime(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Arrival Time (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                child: Text(
                                  _selectedArrivalTime == null
                                      ? 'Tap to select arrival time'
                                      : _arrivalController.text.isEmpty
                                          ? 'Tap to select arrival time'
                                          : _arrivalController.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pricing & Seats',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _priceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Price per Seat *',
                                      hintText: '0.00',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.currency_rupee),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter price';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter valid price';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _totalSeatsController,
                                    decoration: const InputDecoration(
                                      labelText: 'Total Seats *',
                                      hintText: '40',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.event_seat),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter total seats';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Please enter valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _commissionRateController,
                              decoration: const InputDecoration(
                                labelText: 'Commission Rate (%)',
                                hintText: '10',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.percent),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            // Seat Configuration Toggle
                            Row(
                              children: [
                                Checkbox(
                                  value: _useCustomSeats,
                                  onChanged: (value) {
                                    setState(() {
                                      _useCustomSeats = value ?? false;
                                      _showSeatSelection = false;
                                      if (!_useCustomSeats) {
                                        _seatConfigurationController.clear();
                                        _selectedSeatsFromWidget.clear();
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    'Use Custom Seat Configuration',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            if (_useCustomSeats) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _seatConfigurationController,
                                      decoration: const InputDecoration(
                                        labelText: 'Seat Configuration',
                                        hintText: 'A1, A4, A6, B6, B7, C1, C2...',
                                        helperText: 'Enter seat identifiers separated by commas',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.event_seat),
                                      ),
                                      maxLines: 2,
                                validator: (value) {
                                  if (_useCustomSeats && (value == null || value.isEmpty) && _selectedSeatsFromWidget.isEmpty) {
                                    return 'Please enter seat configuration or select seats';
                                  }
                                  if (_useCustomSeats && value != null && value.isNotEmpty) {
                                    // Validate Nepal standard seat format: A or B followed by number(s) only
                                    final seats = value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                                    // Nepal standard: Only A and B allowed (case-insensitive)
                                    final seatPattern = RegExp(r'^[AB]\d+$', caseSensitive: false);
                                    for (final seat in seats) {
                                      if (!seatPattern.hasMatch(seat)) {
                                        return 'Invalid seat: $seat. Nepal standard: A or B followed by number (e.g., A1, A10, B1, B5)';
                                      }
                                    }
                                    // Check for duplicates (case-insensitive)
                                    final lowerSeats = seats.map((s) => s.toUpperCase()).toList();
                                    if (lowerSeats.length != lowerSeats.toSet().length) {
                                      return 'Duplicate seats found. Each seat must be unique.';
                                    }
                                  }
                                  return null;
                                },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final totalSeats = int.tryParse(_totalSeatsController.text) ?? 40;
                                      if (totalSeats > 0) {
                                        setState(() {
                                          _showSeatSelection = !_showSeatSelection;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please enter total seats first'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(_showSeatSelection ? Icons.close : Icons.grid_view),
                                    label: Text(_showSeatSelection ? 'Hide' : 'Select'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                              if (_showSeatSelection && _totalSeatsController.text.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                SeatSelectionWidget(
                                  totalSeats: int.tryParse(_totalSeatsController.text) ?? 40,
                                  seatConfiguration: _seatConfigurationController.text.isNotEmpty
                                      ? _seatConfigurationController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
                                      : null,
                                  selectedSeats: _selectedSeatsFromWidget,
                                  onSeatsChanged: (seats) {
                                    setState(() {
                                      _selectedSeatsFromWidget = seats;
                                      // Update text field with selected seats
                                      if (seats.isNotEmpty) {
                                        _seatConfigurationController.text = seats.join(', ');
                                      }
                                    });
                                  },
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _driverContactController,
                              decoration: const InputDecoration(
                                labelText: 'Driver Contact (Phone)',
                                hintText: '9841234567',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _driverEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Driver Email (for Invitation)',
                                hintText: 'driver@example.com',
                                helperText: 'An invitation will be sent to this email if provided',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                }
                                return null;
                              },
                            ),
                            if (_driverEmailController.text.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _driverNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Driver Name *',
                                  hintText: 'John Driver',
                                  helperText: 'Driver name is required when email is provided',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (_driverEmailController.text.isNotEmpty && (value == null || value.isEmpty)) {
                                    return 'Driver name is required when email is provided';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _driverLicenseNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Driver License Number *',
                                  hintText: 'DL123456',
                                  helperText: 'License number is required when email is provided',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.badge),
                                ),
                                textCapitalization: TextCapitalization.characters,
                                validator: (value) {
                                  if (_driverEmailController.text.isNotEmpty && (value == null || value.isEmpty)) {
                                    return 'License number is required when email is provided';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Advanced Features (Collapsible)
                    Card(
                      child: ExpansionTile(
                        title: const Text('Advanced Features'),
                        leading: const Icon(Icons.settings),
                        initiallyExpanded: false,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Trip Direction
                                DropdownButtonFormField<String>(
                                  value: _tripDirection,
                                  decoration: const InputDecoration(
                                    labelText: 'Trip Direction',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.swap_horiz),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'going', child: Text('Going')),
                                    DropdownMenuItem(value: 'returning', child: Text('Returning')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _tripDirection = value ?? 'going';
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Amenities
                                TextFormField(
                                  controller: _amenitiesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Amenities',
                                    hintText: 'WiFi, AC, TV',
                                    helperText: 'Separate with commas',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.star),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Route & Schedule IDs
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _routeIdController,
                                        decoration: const InputDecoration(
                                          labelText: 'Route ID',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.route),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _scheduleIdController,
                                        decoration: const InputDecoration(
                                          labelText: 'Schedule ID',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.schedule),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Distance & Duration
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _distanceController,
                                        decoration: const InputDecoration(
                                          labelText: 'Distance (km)',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.straighten),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _estimatedDurationController,
                                        decoration: const InputDecoration(
                                          labelText: 'Duration (min)',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.timer),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                // Recurring Schedule
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _isRecurring,
                                      onChanged: (value) {
                                        setState(() {
                                          _isRecurring = value ?? false;
                                        });
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('Enable Recurring Schedule'),
                                    ),
                                  ],
                                ),
                                if (_isRecurring) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Recurring Days',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      _DayChip(
                                        label: 'Sun',
                                        index: 0,
                                        selected: _recurringDays[0],
                                        onChanged: (value) {
                                          setState(() {
                                            _recurringDays[0] = value;
                                          });
                                        },
                                      ),
                                      _DayChip(
                                        label: 'Mon',
                                        index: 1,
                                        selected: _recurringDays[1],
                                        onChanged: (value) {
                                          setState(() {
                                            _recurringDays[1] = value;
                                          });
                                        },
                                      ),
                                      _DayChip(
                                        label: 'Tue',
                                        index: 2,
                                        selected: _recurringDays[2],
                                        onChanged: (value) {
                                          setState(() {
                                            _recurringDays[2] = value;
                                          });
                                        },
                                      ),
                                      _DayChip(
                                        label: 'Wed',
                                        index: 3,
                                        selected: _recurringDays[3],
                                        onChanged: (value) {
                                          setState(() {
                                            _recurringDays[3] = value;
                                          });
                                        },
                                      ),
                                      _DayChip(
                                        label: 'Thu',
                                        index: 4,
                                        selected: _recurringDays[4],
                                        onChanged: (value) {
                                          setState(() {
                                            _recurringDays[4] = value;
                                          });
                                        },
                                      ),
                                      _DayChip(
                                        label: 'Fri',
                                        index: 5,
                                        selected: _recurringDays[5],
                                        onChanged: (value) {
                                          setState(() {
                                            _recurringDays[5] = value;
                                          });
                                        },
                                      ),
                                      _DayChip(
                                        label: 'Sat',
                                        index: 6,
                                        selected: _recurringDays[6],
                                        onChanged: (value) {
                                          setState(() {
                                            _recurringDays[6] = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: _recurringStartDate ?? DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _recurringStartDate = picked;
                                              });
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Start Date',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.calendar_today),
                                            ),
                                            child: Text(
                                              _recurringStartDate == null
                                                  ? 'Select start date'
                                                  : _recurringStartDate!.toString().split(' ')[0],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: _recurringEndDate ?? (_recurringStartDate ?? DateTime.now()).add(const Duration(days: 30)),
                                              firstDate: _recurringStartDate ?? DateTime.now(),
                                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _recurringEndDate = picked;
                                              });
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'End Date',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.calendar_today),
                                            ),
                                            child: Text(
                                              _recurringEndDate == null
                                                  ? 'Select end date'
                                                  : _recurringEndDate!.toString().split(' ')[0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _recurringFrequency,
                                    decoration: const InputDecoration(
                                      labelText: 'Frequency',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.repeat),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _recurringFrequency = value ?? 'daily';
                                      });
                                    },
                                  ),
                                ],
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                // Auto-Activation
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _autoActivate,
                                      onChanged: (value) {
                                        setState(() {
                                          _autoActivate = value ?? false;
                                        });
                                      },
                                    ),
                                    const Expanded(
                                      child: Text('Enable Date-Based Auto Activation'),
                                    ),
                                  ],
                                ),
                                if (_autoActivate) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: _activeFromDate ?? DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _activeFromDate = picked;
                                              });
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Active From Date',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.calendar_today),
                                            ),
                                            child: Text(
                                              _activeFromDate == null
                                                  ? 'Select date'
                                                  : _activeFromDate!.toString().split(' ')[0],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: _activeToDate ?? (_activeFromDate ?? DateTime.now()).add(const Duration(days: 30)),
                                              firstDate: _activeFromDate ?? DateTime.now(),
                                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _activeToDate = picked;
                                              });
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: const InputDecoration(
                                              labelText: 'Active To Date',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.calendar_today),
                                            ),
                                            child: Text(
                                              _activeToDate == null
                                                  ? 'Select date'
                                                  : _activeToDate!.toString().split(' ')[0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select a date'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                
                                if (_selectedTime == null || _timeController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select departure time'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                
                                // Parse seat configuration if provided
                                List<String>? seatConfiguration;
                                if (_useCustomSeats) {
                                  if (_selectedSeatsFromWidget.isNotEmpty) {
                                    seatConfiguration = _selectedSeatsFromWidget;
                                  } else if (_seatConfigurationController.text.trim().isNotEmpty) {
                                    seatConfiguration = _seatConfigurationController.text
                                        .split(',')
                                        .map((s) => s.trim())
                                        .where((s) => s.isNotEmpty)
                                        .toList();
                                  }
                                }
                                
                                // Calculate totalSeats from seatConfiguration if provided, otherwise use input
                                final totalSeats = seatConfiguration != null && seatConfiguration.isNotEmpty
                                    ? seatConfiguration.length
                                    : int.parse(_totalSeatsController.text.trim());
                                
                                // Parse amenities
                                List<String>? amenities;
                                if (_amenitiesController.text.trim().isNotEmpty) {
                                  amenities = _amenitiesController.text
                                      .split(',')
                                      .map((s) => s.trim())
                                      .where((s) => s.isNotEmpty)
                                      .toList();
                                }
                                
                                // Parse recurring days
                                List<int>? recurringDays;
                                if (_isRecurring) {
                                  recurringDays = [];
                                  for (int i = 0; i < _recurringDays.length; i++) {
                                    if (_recurringDays[i]) {
                                      recurringDays.add(i);
                                    }
                                  }
                                  if (recurringDays.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select at least one recurring day'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (_recurringStartDate == null || _recurringEndDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select recurring start and end dates'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                }
                                
                                // Validate auto-activation dates if enabled
                                if (_autoActivate) {
                                  if (_activeFromDate == null || _activeToDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select active from and to dates'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                }
                                
                                context.read<BusBloc>().safeAdd(
                                      CreateBusEvent(
                                        name: _nameController.text.trim(),
                                        vehicleNumber: _vehicleNumberController.text.trim(),
                                        from: _fromController.text.trim(),
                                        to: _toController.text.trim(),
                                        date: _selectedDate!,
                                        time: _timeController.text.trim(),
                                        arrival: _arrivalController.text.isEmpty
                                            ? null
                                            : _arrivalController.text.trim(),
                                        timeFormat: _timeFormat,
                                        arrivalFormat: _arrivalFormat,
                                        tripDirection: _tripDirection,
                                        price: double.parse(_priceController.text.trim()),
                                        totalSeats: totalSeats,
                                        busType: _busTypeController.text.trim().isEmpty
                                            ? null
                                            : _busTypeController.text.trim(),
                                        driverContact: _driverContactController.text.trim().isEmpty
                                            ? null
                                            : _driverContactController.text.trim(),
                                        driverEmail: _driverEmailController.text.trim().isEmpty
                                            ? null
                                            : _driverEmailController.text.trim(),
                                        driverName: _driverEmailController.text.trim().isEmpty
                                            ? null
                                            : _driverNameController.text.trim(),
                                        driverLicenseNumber: _driverEmailController.text.trim().isEmpty
                                            ? null
                                            : _driverLicenseNumberController.text.trim(),
                                        commissionRate: _commissionRateController.text.trim().isEmpty
                                            ? null
                                            : double.tryParse(_commissionRateController.text.trim()),
                                        seatConfiguration: seatConfiguration,
                                        amenities: amenities,
                                        boardingPoints: _boardingPoints.isEmpty ? null : _boardingPoints,
                                        droppingPoints: _droppingPoints.isEmpty ? null : _droppingPoints,
                                        routeId: _routeIdController.text.trim().isEmpty
                                            ? null
                                            : _routeIdController.text.trim(),
                                        scheduleId: _scheduleIdController.text.trim().isEmpty
                                            ? null
                                            : _scheduleIdController.text.trim(),
                                        distance: _distanceController.text.trim().isEmpty
                                            ? null
                                            : double.tryParse(_distanceController.text.trim()),
                                        estimatedDuration: _estimatedDurationController.text.trim().isEmpty
                                            ? null
                                            : int.tryParse(_estimatedDurationController.text.trim()),
                                        isRecurring: _isRecurring ? true : null,
                                        recurringDays: recurringDays,
                                        recurringStartDate: _recurringStartDate,
                                        recurringEndDate: _recurringEndDate,
                                        recurringFrequency: _isRecurring ? _recurringFrequency : null,
                                        autoActivate: _autoActivate ? true : null,
                                        activeFromDate: _activeFromDate,
                                        activeToDate: _activeToDate,
                                      ),
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Bus'),
                    ),
                    const SizedBox(height: 16),
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

// Day Chip Widget for Recurring Days Selection
class _DayChip extends StatelessWidget {
  final String label;
  final int index;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _DayChip({
    required this.label,
    required this.index,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).primaryColor : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

