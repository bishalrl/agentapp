import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/bloc_extensions.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';

class DriverProfileEditPage extends StatefulWidget {
  const DriverProfileEditPage({super.key});

  @override
  State<DriverProfileEditPage> createState() => _DriverProfileEditPageState();
}

class _DriverProfileEditPageState extends State<DriverProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeFields(DriverState state) {
    if (!_isInitialized && state.driver != null) {
      _nameController.text = state.driver!.name;
      _emailController.text = state.driver!.email ?? '';
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DriverBloc>()..add(const GetDriverProfileEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/driver/dashboard');
              }
            },
          ),
        ),
        body: BlocConsumer<DriverBloc, DriverState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: state.errorMessage!,
                  errorSource: 'Profile Update',
                ),
              );
            }
            
            if (state.driver != null && !_isInitialized) {
              _initializeFields(state);
            }
            
            // Show success message and navigate back
            if (state.driver != null && state.isLoading == false && _formKey.currentState?.validate() == true) {
              // Check if update was successful (driver was updated)
              ScaffoldMessenger.of(context).showSnackBar(
                 SuccessSnackBar(message: 'Profile updated successfully!'),
              );
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.pop();
                }
              });
            }
          },
          builder: (context, state) {
            // Initialize fields when driver data is available
            if (state.driver != null && !_isInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _initializeFields(state);
              });
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                hintText: 'Enter your name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<DriverBloc>().safeAdd(
                                      UpdateDriverProfileEvent(
                                        name: _nameController.text.trim(),
                                        email: _emailController.text.trim().isEmpty
                                            ? null
                                            : _emailController.text.trim(),
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
                          : const Text('Update Profile'),
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

// Reuse the _InviterInfoCard widget from driver_dashboard_page
// Import it or copy the implementation here
class _InviterInfoCard extends StatelessWidget {
  final Map<String, dynamic> inviter;

  const _InviterInfoCard({
    required this.inviter,
  });

  @override
  Widget build(BuildContext context) {
    final inviterType = inviter['type'] as String? ?? 'Unknown';
    
    // Fields based on inviter type
    String? inviterName;
    String? inviterEmail;
    String? inviterPhone;
    String? agencyName;
    String? primaryContact;
    
    if (inviterType == 'BusOwner') {
      inviterName = inviter['name'] as String?;
      inviterEmail = inviter['email'] as String?;
      inviterPhone = inviter['phoneNumber'] as String?;
    } else if (inviterType == 'Admin' || inviterType == 'User') {
      inviterName = inviter['name'] as String?;
      inviterEmail = inviter['email'] as String?;
    } else if (inviterType == 'BusAgent' || inviterType == 'Counter') {
      agencyName = inviter['agencyName'] as String?;
      inviterEmail = inviter['email'] as String?;
      primaryContact = inviter['primaryContact'] as String?;
    }
    
    // If no specific type, try to get common fields
    if (inviterName == null) {
      inviterName = inviter['name'] as String?;
    }
    if (inviterEmail == null) {
      inviterEmail = inviter['email'] as String?;
    }
    if (inviterPhone == null) {
      inviterPhone = inviter['phoneNumber'] as String? ?? inviter['primaryContact'] as String?;
    }

    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_add_alt_1,
                  color: Colors.purple.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invited By',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _getInviterTypeLabel(inviterType),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getInviterTypeColor(inviterType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  inviterType,
                  style: TextStyle(
                    color: _getInviterTypeColor(inviterType),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppTheme.spacingL),
          
          // Display fields based on inviter type
          if (agencyName != null && agencyName.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.business,
              label: 'Agency Name',
              value: agencyName,
            ),
          ],
          if (inviterName != null && inviterName.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.person,
              label: 'Name',
              value: inviterName,
            ),
          ],
          if (inviterEmail != null && inviterEmail.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.email,
              label: 'Email',
              value: inviterEmail,
            ),
          ],
          if (inviterPhone != null && inviterPhone.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.phone,
              label: inviterType == 'BusAgent' || inviterType == 'Counter' ? 'Primary Contact' : 'Phone',
              value: inviterPhone,
            ),
          ],
        ],
      ),
    );
  }
  
  String _getInviterTypeLabel(String type) {
    switch (type) {
      case 'BusOwner':
        return 'Bus Owner';
      case 'Admin':
      case 'User':
        return 'Administrator';
      case 'BusAgent':
      case 'Counter':
        return 'Bus Agent / Counter';
      default:
        return 'Inviter';
    }
  }
  
  Color _getInviterTypeColor(String type) {
    switch (type) {
      case 'BusOwner':
        return Colors.purple.shade700;
      case 'Admin':
      case 'User':
        return Colors.blue.shade700;
      case 'BusAgent':
      case 'Counter':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
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
