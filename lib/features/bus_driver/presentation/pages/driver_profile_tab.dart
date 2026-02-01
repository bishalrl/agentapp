import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/animations/scroll_animations.dart';
import '../../../../core/animations/dialog_animations.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';
import 'driver_profile_edit_page.dart';

class DriverProfileTab extends StatelessWidget {
  const DriverProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverBloc, DriverState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Check if permission request was successful
        if (!state.isLoading && state.errorMessage == null) {
          // Success is handled in the dialog
        }
      },
      child: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, state) {
        final dashboardData = state.dashboardData;
        final driver = dashboardData?['driver'] as Map<String, dynamic>?;
        final inviter = dashboardData?['inviter'] as Map<String, dynamic>?;

        if (driver == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final driverName = driver['name'] ?? 'Unknown';
        final driverEmail = driver['email'] ?? 'N/A';
        final driverPhone = driver['phone'] ?? 'N/A';
        final driverLicense = driver['licenseNumber'] ?? 'N/A';
        final driverStatus = driver['status'] ?? 'Unknown';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              EnhancedCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      driverName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Chip(
                      label: Text(driverStatus.toUpperCase()),
                      backgroundColor: _getStatusColor(driverStatus),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DriverProfileEditPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Personal Information
              EnhancedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Personal Information',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Divider(height: AppTheme.spacingL),
                    _ProfileInfoItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: driverEmail,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    _ProfileInfoItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: driverPhone,
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    _ProfileInfoItem(
                      icon: Icons.badge,
                      label: 'License Number',
                      value: driverLicense,
                    ),
                  ],
                ),
              ),

              // Inviter Information (if available)
              if (inviter != null) ...[
                const SizedBox(height: AppTheme.spacingM),
                EnhancedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Text(
                            'Invited By',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const Divider(height: AppTheme.spacingL),
                      _ProfileInfoItem(
                        icon: Icons.person,
                        label: 'Name',
                        value: inviter['name'] ?? 'N/A',
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _ProfileInfoItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: inviter['email'] ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacingM),

              // Permission Request Section
              EnhancedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_open,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Request Permissions',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Divider(height: AppTheme.spacingL),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Request additional permissions from the owner to access more features.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showPermissionRequestDialog(context, inviter);
                        },
                        icon: const Icon(Icons.request_quote),
                        label: const Text('Request Booking Permission'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contact your owner for other permission requests'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.contact_support),
                        label: const Text('Contact Owner'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Actions
              EnhancedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Account Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(height: AppTheme.spacingL),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to help
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        context.go('/driver/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade100;
      case 'suspended':
        return Colors.red.shade100;
      case 'invited':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showPermissionRequestDialog(BuildContext context, Map<String, dynamic>? inviter) {
    DialogAnimations.showAnimatedDialog(
      context: context,
      builder: (context) => BlocListener<DriverBloc, DriverState>(
        listener: (context, state) {
          if (!state.isLoading && state.errorMessage == null) {
            // Permission request successful
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission request sent to owner successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<DriverBloc, DriverState>(
          builder: (context, state) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.request_quote, color: AppTheme.primaryColor),
                SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    'Request Booking Permission',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request permission from the owner to create bookings for passengers.',
                ),
                const SizedBox(height: AppTheme.spacingM),
                if (inviter != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Owner Information',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text('Name: ${inviter['name'] ?? 'N/A'}'),
                        Text('Email: ${inviter['email'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingM),
                const Text(
                  'Your request will be sent to the owner for approval.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        // Request permission via BLoC
                        context.read<DriverBloc>().add(
                          RequestPermissionEvent(
                            permissionType: 'booking',
                            message: 'I would like to request permission to create bookings for passengers.',
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
