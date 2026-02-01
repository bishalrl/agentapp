import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/events/profile_event.dart';
import '../bloc/states/profile_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../../core/animations/scroll_animations.dart';
import '../../../../core/animations/dialog_animations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ProfileBloc>()..add(GetProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded || state is ProfileUpdated) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Profile',
              ),
            );
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(GetProfileEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded || state is ProfileUpdated) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileUpdated).profile;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(GetProfileEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _ProfileHeader(profile: profile),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _ProfileInfoSection(profile: profile),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _ContactInfoSection(profile: profile),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _OfficeInfoSection(profile: profile),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProfileState state) {
    final profile = state is ProfileLoaded
        ? state.profile
        : (state as ProfileUpdated).profile;

    DialogAnimations.showAnimatedDialog(
      context: context,
      builder: (context) => _EditProfileDialog(profile: profile),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
      border: Border.all(
        color: AppTheme.primaryColor.withOpacity(0.2),
        width: 2,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                  ? Icon(
                      Icons.business_center_rounded,
                      size: 60,
                      color: AppTheme.primaryColor,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            profile.agencyName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            profile.email,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: profile.isVerified
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: profile.isVerified
                    ? AppTheme.successColor.withOpacity(0.5)
                    : AppTheme.warningColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profile.isVerified 
                      ? Icons.verified_rounded 
                      : Icons.pending_rounded,
                  size: 18,
                  color: profile.isVerified 
                      ? AppTheme.successColor 
                      : AppTheme.warningColor,
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  profile.isVerified ? 'Verified' : 'Pending Verification',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: profile.isVerified 
                        ? AppTheme.successColor 
                        : AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoSection extends StatelessWidget {
  final profile;

  const _ProfileInfoSection({required this.profile});

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
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Profile Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _InfoRow(label: 'Owner Name', value: profile.ownerName),
          if (profile.panVatNumber != null)
            _InfoRow(label: 'PAN/VAT Number', value: profile.panVatNumber),
          _InfoRow(label: 'Address', value: profile.address),
          _InfoRow(label: 'District/Province', value: profile.districtProvince),
          _InfoRow(
            label: 'Number of Employees',
            value: profile.numberOfEmployees.toString(),
          ),
          _InfoRow(
            label: 'Device Access',
            value: profile.hasDeviceAccess ? 'Yes' : 'No',
          ),
          _InfoRow(
            label: 'Internet Access',
            value: profile.hasInternetAccess ? 'Yes' : 'No',
          ),
          _InfoRow(
            label: 'Preferred Booking Method',
            value: profile.preferredBookingMethod,
          ),
        ],
      ),
    );
  }
}

class _ContactInfoSection extends StatelessWidget {
  final profile;

  const _ContactInfoSection({required this.profile});

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
                  Icons.phone_rounded,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Contact Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _InfoRow(label: 'Primary Contact', value: profile.primaryContact),
          if (profile.alternateContact != null)
            _InfoRow(label: 'Alternate Contact', value: profile.alternateContact),
          if (profile.whatsappViber != null)
            _InfoRow(label: 'WhatsApp/Viber', value: profile.whatsappViber),
        ],
      ),
    );
  }
}

class _OfficeInfoSection extends StatelessWidget {
  final profile;

  const _OfficeInfoSection({required this.profile});

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
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Office Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _InfoRow(label: 'Office Location', value: profile.officeLocation),
          _InfoRow(
            label: 'Office Hours',
            value: '${profile.officeOpenTime} - ${profile.officeCloseTime}',
          ),
          const SizedBox(height: AppTheme.spacingM),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Wallet Balance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Rs. ${profile.walletBalance.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

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
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final profile;

  const _EditProfileDialog({required this.profile});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _agencyNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _panVatController;
  late TextEditingController _addressController;
  late TextEditingController _districtController;
  late TextEditingController _primaryContactController;
  late TextEditingController _alternateContactController;
  late TextEditingController _whatsappController;
  late TextEditingController _officeLocationController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  late TextEditingController _employeesController;
  late TextEditingController _bookingMethodController;
  bool _hasDeviceAccess = false;
  bool _hasInternetAccess = false;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _agencyNameController = TextEditingController(text: p.agencyName);
    _ownerNameController = TextEditingController(text: p.ownerName);
    _panVatController = TextEditingController(text: p.panVatNumber ?? '');
    _addressController = TextEditingController(text: p.address);
    _districtController = TextEditingController(text: p.districtProvince);
    _primaryContactController = TextEditingController(text: p.primaryContact);
    _alternateContactController = TextEditingController(text: p.alternateContact ?? '');
    _whatsappController = TextEditingController(text: p.whatsappViber ?? '');
    _officeLocationController = TextEditingController(text: p.officeLocation);
    _openTimeController = TextEditingController(text: p.officeOpenTime);
    _closeTimeController = TextEditingController(text: p.officeCloseTime);
    _employeesController = TextEditingController(text: p.numberOfEmployees.toString());
    _bookingMethodController = TextEditingController(text: p.preferredBookingMethod);
    _hasDeviceAccess = p.hasDeviceAccess;
    _hasInternetAccess = p.hasInternetAccess;
  }

  @override
  void dispose() {
    _agencyNameController.dispose();
    _ownerNameController.dispose();
    _panVatController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _primaryContactController.dispose();
    _alternateContactController.dispose();
    _whatsappController.dispose();
    _officeLocationController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _employeesController.dispose();
    _bookingMethodController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
            UpdateProfileEvent(
              agencyName: _agencyNameController.text,
              ownerName: _ownerNameController.text,
              panVatNumber: _panVatController.text.isEmpty ? null : _panVatController.text,
              address: _addressController.text,
              districtProvince: _districtController.text,
              primaryContact: _primaryContactController.text,
              alternateContact: _alternateContactController.text.isEmpty
                  ? null
                  : _alternateContactController.text,
              whatsappViber:
                  _whatsappController.text.isEmpty ? null : _whatsappController.text,
              officeLocation: _officeLocationController.text,
              officeOpenTime: _openTimeController.text,
              officeCloseTime: _closeTimeController.text,
              numberOfEmployees: int.tryParse(_employeesController.text),
              hasDeviceAccess: _hasDeviceAccess,
              hasInternetAccess: _hasInternetAccess,
              preferredBookingMethod: _bookingMethodController.text,
              avatarPath: _avatarPath,
            ),
          );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Edit Profile'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _avatarPath != null && _avatarPath!.isNotEmpty
                              ? FileImage(File(_avatarPath!))
                              : (widget.profile.avatarUrl != null && widget.profile.avatarUrl!.isNotEmpty
                                  ? NetworkImage(widget.profile.avatarUrl!)
                                  : null),
                          child: (_avatarPath == null || _avatarPath!.isEmpty) && 
                                 (widget.profile.avatarUrl == null || widget.profile.avatarUrl!.isEmpty)
                              ? const Icon(Icons.camera_alt)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _agencyNameController,
                        decoration: const InputDecoration(labelText: 'Agency Name'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _ownerNameController,
                        decoration: const InputDecoration(labelText: 'Owner Name'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _panVatController,
                        decoration: const InputDecoration(labelText: 'PAN/VAT Number'),
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _districtController,
                        decoration: const InputDecoration(labelText: 'District/Province'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _primaryContactController,
                        decoration: const InputDecoration(labelText: 'Primary Contact'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _alternateContactController,
                        decoration: const InputDecoration(labelText: 'Alternate Contact'),
                      ),
                      TextFormField(
                        controller: _whatsappController,
                        decoration: const InputDecoration(labelText: 'WhatsApp/Viber'),
                      ),
                      TextFormField(
                        controller: _officeLocationController,
                        decoration: const InputDecoration(labelText: 'Office Location'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _openTimeController,
                              decoration: const InputDecoration(labelText: 'Open Time'),
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _closeTimeController,
                              decoration: const InputDecoration(labelText: 'Close Time'),
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _employeesController,
                        decoration: const InputDecoration(labelText: 'Number of Employees'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _bookingMethodController,
                        decoration: const InputDecoration(labelText: 'Preferred Booking Method'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SwitchListTile(
                        title: const Text('Has Device Access'),
                        value: _hasDeviceAccess,
                        onChanged: (v) => setState(() => _hasDeviceAccess = v),
                      ),
                      SwitchListTile(
                        title: const Text('Has Internet Access'),
                        value: _hasInternetAccess,
                        onChanged: (v) => setState(() => _hasInternetAccess = v),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Save Changes'),
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
