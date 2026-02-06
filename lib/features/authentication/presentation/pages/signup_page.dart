import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/events/signup_event.dart';
import '../bloc/states/signup_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/utils/bloc_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SignupBloc>(),
      child: const _SignupPageView(),
    );
  }
}

class _SignupPageView extends StatefulWidget {
  const _SignupPageView();

  @override
  State<_SignupPageView> createState() => _SignupPageViewState();
}

class _SignupPageViewState extends State<_SignupPageView> {
  final formKey = GlobalKey<FormState>();
  final agencyNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final addressController = TextEditingController();
  final districtProvinceController = TextEditingController();
  final primaryContactController = TextEditingController();
  final emailController = TextEditingController();
  final officeLocationController = TextEditingController();
  final officeOpenTimeController = TextEditingController();
  final officeCloseTimeController = TextEditingController();
  final numberOfEmployeesController = TextEditingController();
  final panVatNumberController = TextEditingController();
  final alternateContactController = TextEditingController();
  final whatsappViberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  File? citizenshipFile;
  File? photoFile;
  File? panFile;
  File? registrationFile;
  bool hasDeviceAccess = false;
  bool hasInternetAccess = false;
  String preferredBookingMethod = 'online';

  @override
  void dispose() {
    agencyNameController.dispose();
    ownerNameController.dispose();
    addressController.dispose();
    districtProvinceController.dispose();
    primaryContactController.dispose();
    emailController.dispose();
    officeLocationController.dispose();
    officeOpenTimeController.dispose();
    officeCloseTimeController.dispose();
    numberOfEmployeesController.dispose();
    panVatNumberController.dispose();
    alternateContactController.dispose();
    whatsappViberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
        title: const Text(
          'Register Counter/Agent',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<SignupBloc, SignupState>(
        listener: (context, state) {
          print('🔔 SignupState Listener: isSuccess=${state.isSuccess}, error=${state.errorMessage}');
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.errorMessage!,
                errorSource: 'Signup',
                errorType: 'Server Error',
              ),
            );
          }
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SuccessSnackBar(
                message: state.successMessage ?? 
                  'Registration successful! We will review your documents and contact you by email after verification.',
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.go('/login');
              }
            });
          }
        },
        builder: (context, state) {
          print('🎨 SignupState Builder: isLoading=${state.isLoading}');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.business_center,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Create Account',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Register your counter/agency',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const SizedBox(height: 16),
                  
                  // Business Information
                  _buildSectionCard(
                    context,
                    'Business Information',
                    Icons.business,
                    [
                      _buildTextField(
                        controller: agencyNameController,
                        label: 'Agency Name *',
                        icon: Icons.business,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: ownerNameController,
                        label: 'Owner Name *',
                        icon: Icons.person,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: addressController,
                        label: 'Address *',
                        icon: Icons.location_on,
                        maxLines: 2,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: districtProvinceController,
                        label: 'District/Province *',
                        icon: Icons.map,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: primaryContactController,
                        label: 'Primary Contact *',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: emailController,
                        label: 'Email *',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final trimmed = v.trim();
                          if (!trimmed.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: alternateContactController,
                        label: 'Alternate Contact (Optional)',
                        icon: Icons.phone_android,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: whatsappViberController,
                        label: 'WhatsApp/Viber (Optional)',
                        icon: Icons.chat,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    'Office Details',
                    Icons.business_center,
                    [
                      _buildTextField(
                        controller: officeLocationController,
                        label: 'Office Location *',
                        icon: Icons.location_city,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: officeOpenTimeController,
                              label: 'Open Time *',
                              icon: Icons.access_time,
                              hintText: '09:00',
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: officeCloseTimeController,
                              label: 'Close Time *',
                              icon: Icons.access_time,
                              hintText: '18:00',
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: numberOfEmployeesController,
                        label: 'Number of Employees *',
                        icon: Icons.people,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (int.tryParse(v) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: panVatNumberController,
                        label: 'PAN/VAT Number (Optional)',
                        icon: Icons.badge,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    'Access & Preferences',
                    Icons.settings,
                    [
                      SwitchListTile(
                        title: const Text('Has Device Access *'),
                        subtitle: const Text('Do you have device access?'),
                        value: hasDeviceAccess,
                        onChanged: (value) {
                          setState(() {
                            hasDeviceAccess = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Has Internet Access *'),
                        subtitle: const Text('Do you have internet access?'),
                        value: hasInternetAccess,
                        onChanged: (value) {
                          setState(() {
                            hasInternetAccess = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: preferredBookingMethod,
                        decoration: InputDecoration(
                          labelText: 'Preferred Booking Method *',
                          prefixIcon: const Icon(Icons.book_online),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'online', child: Text('Online')),
                          DropdownMenuItem(value: 'offline', child: Text('Offline')),
                          DropdownMenuItem(value: 'both', child: Text('Both')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              preferredBookingMethod = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Required Documents
                  _buildSectionCard(
                    context,
                    'Required Documents',
                    Icons.folder,
                    [
                      _FilePickerField(
                        label: 'Citizenship Document *',
                        icon: Icons.description,
                        selectedFile: citizenshipFile,
                        onFileSelected: (file) {
                          setState(() {
                            citizenshipFile = file;
                            print('📄 Citizenship file selected: ${file?.path}');
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _FilePickerField(
                        label: 'Photo/Image (to match name) *',
                        icon: Icons.photo_camera,
                        selectedFile: photoFile,
                        isImage: true,
                        onFileSelected: (file) {
                          setState(() {
                            photoFile = file;
                            print('📷 Photo file selected: ${file?.path}');
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _FilePickerField(
                        label: 'PAN Document (Optional)',
                        icon: Icons.description,
                        selectedFile: panFile,
                        onFileSelected: (file) {
                          setState(() {
                            panFile = file;
                            print('📄 PAN file selected: ${file?.path}');
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _FilePickerField(
                        label: 'Registration Document (Optional)',
                        icon: Icons.description,
                        selectedFile: registrationFile,
                        onFileSelected: (file) {
                          setState(() {
                            registrationFile = file;
                            print('📄 Registration file selected: ${file?.path}');
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Account Security
                  _buildSectionCard(
                    context,
                    'Account Security',
                    Icons.lock,
                    [
                      _buildTextField(
                        controller: passwordController,
                        label: 'Password *',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: confirmPasswordController,
                        label: 'Confirm Password *',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.trim() != passwordController.text.trim()) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              print('🚀 Submit button pressed');
                              if (formKey.currentState!.validate()) {
                                print('✅ Form validated');
                                if (citizenshipFile == null || photoFile == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please upload required documents (Citizenship & Photo)'),
                                      backgroundColor: AppTheme.errorColor,
                                    ),
                                  );
                                  return;
                                }

                                print('📤 Dispatching SignupRequestEvent');
                                print('   Agency: ${agencyNameController.text}');
                                print('   Email: ${emailController.text}');
                                print('   Citizenship: ${citizenshipFile?.path}');
                                print('   Photo: ${photoFile?.path}');

                                context.read<SignupBloc>().safeAdd(
                                      SignupRequestEvent(
                                        agencyName: agencyNameController.text.trim(),
                                        ownerName: ownerNameController.text.trim(),
                                        address: addressController.text.trim(),
                                        districtProvince: districtProvinceController.text.trim(),
                                        primaryContact: primaryContactController.text.trim(),
                                        email: emailController.text.trim(),
                                        officeLocation: officeLocationController.text.trim(),
                                        officeOpenTime: officeOpenTimeController.text.trim(),
                                        officeCloseTime: officeCloseTimeController.text.trim(),
                                        numberOfEmployees: int.parse(numberOfEmployeesController.text),
                                        hasDeviceAccess: hasDeviceAccess,
                                        hasInternetAccess: hasInternetAccess,
                                        preferredBookingMethod: preferredBookingMethod,
                                        password: passwordController.text.trim(),
                                        citizenshipFile: citizenshipFile!,
                                        photoFile: photoFile!,
                                        panVatNumber: panVatNumberController.text.isEmpty
                                            ? null
                                            : panVatNumberController.text.trim(),
                                        alternateContact: alternateContactController.text.isEmpty
                                            ? null
                                            : alternateContactController.text.trim(),
                                        whatsappViber: whatsappViberController.text.isEmpty
                                            ? null
                                            : whatsappViberController.text.trim(),
                                        panFile: panFile,
                                        registrationFile: registrationFile,
                                      ),
                                    );
                              } else {
                                print('❌ Form validation failed');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Submit Registration',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.lightBorderColor!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.lightBorderColor!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator,
    );
  }
}

class _FilePickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(File?) onFileSelected;
  final bool isImage;
  final File? selectedFile;

  const _FilePickerField({
    required this.label,
    required this.icon,
    required this.onFileSelected,
    this.isImage = false,
    this.selectedFile,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print('📂 File picker tapped: $label');
        try {
          if (isImage) {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              final file = File(pickedFile.path);
              print('✅ Image selected: ${file.path}');
              onFileSelected(file);
            } else {
              print('❌ Image selection cancelled');
            }
          } else {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.any,
            );
            if (result != null && result.files.single.path != null) {
              final file = File(result.files.single.path!);
              print('✅ File selected: ${file.path}');
              onFileSelected(file);
            } else {
              print('❌ File selection cancelled');
            }
          }
        } catch (e) {
          print('❌ Error picking file: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error selecting file: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedFile != null 
                ? AppTheme.successColor! 
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: selectedFile != null ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          color: selectedFile != null 
              ? AppTheme.successColor.withOpacity(0.1)! 
              : Colors.grey[50],
          boxShadow: selectedFile != null
              ? [
                  BoxShadow(
                    color: AppTheme.successColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedFile != null
                    ? AppTheme.successColor.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selectedFile != null
                    ? AppTheme.successColor
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedFile != null
                        ? selectedFile!.path.split('/').last
                        : 'Tap to select file',
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedFile != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: selectedFile != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedFile != null
                    ? AppTheme.successColor.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selectedFile != null ? Icons.check_circle : Icons.upload_file,
                color: selectedFile != null
                    ? AppTheme.successColor
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
