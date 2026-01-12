import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/utils/bloc_extensions.dart';
import '../../domain/entities/bus_entity.dart';
import '../bloc/bus_bloc.dart';
import '../bloc/events/bus_event.dart';
import '../bloc/states/bus_state.dart';

class EditBusPage extends StatefulWidget {
  final String busId;
  final BusEntity? bus;

  const EditBusPage({
    super.key,
    required this.busId,
    this.bus,
  });

  @override
  State<EditBusPage> createState() => _EditBusPageState();
}

class _EditBusPageState extends State<EditBusPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _vehicleNumberController;
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _timeController;
  late TextEditingController _arrivalController;
  late TextEditingController _priceController;
  late TextEditingController _totalSeatsController;
  late TextEditingController _driverContactController;
  late TextEditingController _commissionRateController;
  late TextEditingController _busTypeController;
  
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final bus = widget.bus;
    _nameController = TextEditingController(text: bus?.name ?? '');
    _vehicleNumberController = TextEditingController(text: bus?.vehicleNumber ?? '');
    _fromController = TextEditingController(text: bus?.from ?? '');
    _toController = TextEditingController(text: bus?.to ?? '');
    _timeController = TextEditingController(text: bus?.time ?? '');
    _arrivalController = TextEditingController(text: bus?.arrival ?? '');
    _priceController = TextEditingController(text: bus?.price.toString() ?? '');
    _totalSeatsController = TextEditingController(text: bus?.totalSeats.toString() ?? '');
    _driverContactController = TextEditingController(text: bus?.driverContact ?? '');
    _commissionRateController = TextEditingController(
      text: bus?.commissionRate?.toString() ?? '',
    );
    _busTypeController = TextEditingController(text: bus?.busType ?? '');
    _selectedDate = bus?.date;
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
    _commissionRateController.dispose();
    _busTypeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
          title: const Text('Edit Bus'),
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
                  errorSource: 'Bus Update',
                ),
              );
            }
            
            if (state.successMessage != null && state.updatedBus != null) {
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
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.confirmation_number),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter vehicle number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _busTypeController,
                              decoration: const InputDecoration(
                                labelText: 'Bus Type',
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
                                  child: TextFormField(
                                    controller: _timeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Departure Time *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.access_time),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter time';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _arrivalController,
                              decoration: const InputDecoration(
                                labelText: 'Arrival Time',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
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
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.percent),
                              ),
                              keyboardType: TextInputType.number,
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
                              'Additional Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _driverContactController,
                              decoration: const InputDecoration(
                                labelText: 'Driver Contact',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
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
                                
                                context.read<BusBloc>().safeAdd(
                                      UpdateBusEvent(
                                        busId: widget.busId,
                                        name: _nameController.text.trim(),
                                        vehicleNumber: _vehicleNumberController.text.trim(),
                                        from: _fromController.text.trim(),
                                        to: _toController.text.trim(),
                                        date: _selectedDate!,
                                        time: _timeController.text.trim(),
                                        arrival: _arrivalController.text.trim().isEmpty
                                            ? null
                                            : _arrivalController.text.trim(),
                                        price: double.parse(_priceController.text.trim()),
                                        totalSeats: int.parse(_totalSeatsController.text.trim()),
                                        busType: _busTypeController.text.trim().isEmpty
                                            ? null
                                            : _busTypeController.text.trim(),
                                        driverContact: _driverContactController.text.trim().isEmpty
                                            ? null
                                            : _driverContactController.text.trim(),
                                        commissionRate: _commissionRateController.text.trim().isEmpty
                                            ? null
                                            : double.tryParse(_commissionRateController.text.trim()),
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
                          : const Text('Update Bus'),
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

