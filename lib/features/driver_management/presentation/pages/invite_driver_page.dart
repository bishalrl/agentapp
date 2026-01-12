import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/driver_management_bloc.dart';
import '../bloc/events/driver_management_event.dart';
import '../bloc/states/driver_management_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';

class InviteDriverPage extends StatelessWidget {
  const InviteDriverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DriverManagementBloc>(),
      child: const _InviteDriverView(),
    );
  }
}

class _InviteDriverView extends StatelessWidget {
  const _InviteDriverView();

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final licenseController = TextEditingController();
    final addressController = TextEditingController();
    final licenseExpiryController = TextEditingController();
    DateTime? selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Driver'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/drivers');
            }
          },
        ),
      ),
      body: BlocConsumer<DriverManagementBloc, DriverManagementState>(
        listener: (context, state) {
          if (state is DriverManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Invite Driver',
              ),
            );
          } else if (state is DriverInvited) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Driver invited successfully. OTP sent to phone number.'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: licenseExpiryController,
                  decoration: const InputDecoration(
                    labelText: 'License Expiry *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      selectedDate = date;
                      licenseExpiryController.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is DriverManagementLoading
                        ? null
                        : () {
                            if (nameController.text.isEmpty ||
                                phoneController.text.isEmpty ||
                                licenseController.text.isEmpty ||
                                selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all required fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            context.read<DriverManagementBloc>().add(
                                  InviteDriverEvent(
                                    name: nameController.text,
                                    phoneNumber: phoneController.text,
                                    email: emailController.text.isEmpty
                                        ? null
                                        : emailController.text,
                                    licenseNumber: licenseController.text,
                                    licenseExpiry: selectedDate!,
                                    address: addressController.text.isEmpty
                                        ? null
                                        : addressController.text,
                                  ),
                                );
                          },
                    child: state is DriverManagementLoading
                        ? const CircularProgressIndicator()
                        : const Text('Invite Driver'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
