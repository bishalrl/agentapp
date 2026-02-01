import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../features/authentication/data/datasources/auth_local_data_source.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';

class DriverLoginPage extends StatelessWidget {
  const DriverLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<DriverBloc>(),
      child: const _DriverLoginPageView(),
    );
  }
}

class _DriverLoginPageView extends StatefulWidget {
  const _DriverLoginPageView();

  @override
  State<_DriverLoginPageView> createState() => _DriverLoginPageViewState();
}

class _DriverLoginPageViewState extends State<_DriverLoginPageView> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  
  // Login form controllers
  final _loginEmailController = TextEditingController();
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginOtpController = TextEditingController();
  bool _hasOtpForLogin = false;
  bool _obscureLoginPassword = true;
  
  // Registration form controllers
  final _invitationCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _registrationOtpController = TextEditingController();
  bool _hasOtpForRegistration = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // File pickers for registration
  File? _licensePhoto;
  File? _driverPhoto;
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoginMode = true;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _loginOtpController.dispose();
    _invitationCodeController.dispose();
    _emailController.dispose();
    _registerPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _licenseNumberController.dispose();
    _registrationOtpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<DriverBloc, DriverState>(
            listener: (context, state) async {
              if (!mounted) return;
              
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (state.driver != null) {
                // Store token if available from registration or OTP verification
                if (state.registrationToken != null) {
                  print('✅ Token received: ${state.registrationToken}');
                  // Store token in secure storage
                  try {
                    final authLocalDataSource = di.sl<AuthLocalDataSource>();
                    await authLocalDataSource.saveToken(state.registrationToken!);
                    await authLocalDataSource.saveSessionType('driver');
                    print('   ✅ Token & session type (driver) saved to secure storage');
                  } catch (e) {
                    print('   ⚠️ Failed to save token/session type: $e');
                  }
                }
                if (mounted) {
                  context.go('/driver/dashboard');
                }
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _isLoginMode ? _loginFormKey : _registerFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _isLoginMode ? 'Driver Login' : 'Driver Registration',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLoginMode
                            ? 'Login to access your driver dashboard'
                            : 'Create your driver account',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Mode Toggle (Login/Register)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isLoginMode = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isLoginMode
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: _isLoginMode
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isLoginMode = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isLoginMode
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Register',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: !_isLoginMode
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: _isLoginMode
                              ? _buildLoginForm(context, state)
                              : _buildRegistrationForm(context, state),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, DriverState state) {
    return Column(
      children: [
        TextFormField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'driver@example.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            helperText: 'Enter email OR phone number',
          ),
          validator: (value) {
            if ((value == null || value.isEmpty) &&
                (_loginPhoneController.text.isEmpty)) {
              return 'Please enter email or phone number';
            }
            if (value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          'OR',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _loginPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+977-9800000000',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if ((value == null || value.isEmpty) &&
                (_loginEmailController.text.isEmpty)) {
              return 'Please enter email or phone number';
            }
            if (value != null && value.isNotEmpty && value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // OTP for Owner Association (Login)
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _hasOtpForLogin,
                      onChanged: (value) {
                        setState(() {
                          _hasOtpForLogin = value ?? false;
                          if (!_hasOtpForLogin) {
                            _loginOtpController.clear();
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'I have an OTP for owner association',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            'Check this if you received an OTP from owner/counter',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_hasOtpForLogin) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _loginOtpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'OTP Code *',
                      hintText: 'Enter 6-digit OTP',
                      prefixIcon: const Icon(Icons.vpn_key),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      counterText: '',
                      helperText: 'OTP sent to your email by owner/counter',
                    ),
                    validator: _hasOtpForLogin ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    } : null,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    if (_loginFormKey.currentState!.validate()) {
                      // Validate OTP if hasOTP is checked
                      if (_hasOtpForLogin && _loginOtpController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter OTP code'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      if (!mounted) return;
                      context.read<DriverBloc>().add(
                            DriverLoginEvent(
                              email: _loginEmailController.text.trim().isEmpty
                                  ? null
                                  : _loginEmailController.text.trim(),
                              phoneNumber: _loginPhoneController.text.trim().isEmpty
                                  ? null
                                  : _loginPhoneController.text.trim(),
                              password: _loginPasswordController.text,
                              hasOTP: _hasOtpForLogin ? true : null,
                              otp: _hasOtpForLogin && _loginOtpController.text.isNotEmpty
                                  ? _loginOtpController.text.trim()
                                  : null,
                            ),
                          );
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
                : const Text('Login'),
          ),
        ),
        const SizedBox(height: 16),
        // Login as Counter Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/login');
            },
            icon: const Icon(Icons.business, color: Colors.black87),
            label: const Text(
              'Login as Counter',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context, DriverState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _invitationCodeController,
          decoration: InputDecoration(
            labelText: 'Invitation Code (Optional)',
            hintText: 'ABC123',
            prefixIcon: const Icon(Icons.vpn_key),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            helperText: 'Enter invitation code if you have one',
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email (Optional)',
            hintText: 'driver@example.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _registerPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+977-9800000000',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: 'Enter secure password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            helperText: 'Minimum 6 characters',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password *',
            hintText: 'Re-enter password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            hintText: 'John Driver',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _licenseNumberController,
          decoration: InputDecoration(
            labelText: 'License Number *',
            hintText: 'DL123456',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter license number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // OTP for Owner Association (Registration)
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _hasOtpForRegistration,
                      onChanged: (value) {
                        setState(() {
                          _hasOtpForRegistration = value ?? false;
                          if (!_hasOtpForRegistration) {
                            _registrationOtpController.clear();
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'I have an OTP for owner association (Optional)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            'Check this if you received an OTP from owner/counter',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_hasOtpForRegistration) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _registrationOtpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'OTP Code *',
                      hintText: 'Enter 6-digit OTP',
                      prefixIcon: const Icon(Icons.vpn_key),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      counterText: '',
                      helperText: 'OTP sent to your email by owner/counter',
                    ),
                    validator: _hasOtpForRegistration ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    } : null,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // License Photo Upload
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'License Photo',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final image = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            setState(() {
                              _licensePhoto = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick from Gallery'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final image = await _imagePicker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            setState(() {
                              _licensePhoto = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                    ),
                  ],
                ),
                if (_licensePhoto != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _licensePhoto!.path.split('/').last,
                          style: TextStyle(fontSize: 12, color: Colors.green[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _licensePhoto = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Driver Photo Upload
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver Photo (Optional)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final image = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            setState(() {
                              _driverPhoto = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick from Gallery'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final image = await _imagePicker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            setState(() {
                              _driverPhoto = File(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                    ),
                  ],
                ),
                if (_driverPhoto != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _driverPhoto!.path.split('/').last,
                          style: TextStyle(fontSize: 12, color: Colors.green[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _driverPhoto = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    if (!mounted) return;
                    if (_registerFormKey.currentState!.validate()) {
                      // Validate license photo is provided (required)
                      if (_licensePhoto == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please upload license photo'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      if (!mounted) return;
                      
                      final hasInvitationCode = _invitationCodeController.text.trim().isNotEmpty;
                      
                      if (hasInvitationCode) {
                        // Registration with invitation code (legacy method - automatically associates with owner)
                        if (!mounted) return;
                        context.read<DriverBloc>().add(
                              RegisterDriverWithInvitationFileEvent(
                                invitationCode: _invitationCodeController.text.trim().toUpperCase(),
                                email: _emailController.text.trim(),
                                phoneNumber: _registerPhoneController.text.trim(),
                                password: _passwordController.text,
                                name: _nameController.text.trim(),
                                licenseNumber: _licenseNumberController.text.trim(),
                                licensePhoto: _licensePhoto,
                                driverPhoto: _driverPhoto,
                              ),
                            );
                      } else {
                        // Independent registration (can optionally use OTP for owner association)
                        // Validate OTP if hasOTP is checked
                        if (_hasOtpForRegistration && _registrationOtpController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter OTP code'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (!mounted) return;
                        context.read<DriverBloc>().add(
                              RegisterDriverEvent(
                                name: _nameController.text.trim(),
                                phoneNumber: _registerPhoneController.text.trim(),
                                email: _emailController.text.trim().isEmpty 
                                    ? null 
                                    : _emailController.text.trim(),
                                password: _passwordController.text,
                                licenseNumber: _licenseNumberController.text.trim(),
                                licensePhoto: _licensePhoto,
                                driverPhoto: _driverPhoto,
                                hasOTP: _hasOtpForRegistration ? true : null,
                                otp: _hasOtpForRegistration && _registrationOtpController.text.isNotEmpty
                                    ? _registrationOtpController.text.trim()
                                    : null,
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
                : const Text('Register'),
          ),
        ),
        const SizedBox(height: 16),
        // Login as Counter Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/login');
            },
            icon: const Icon(Icons.business, color: Colors.black87),
            label: const Text(
              'Login as Counter',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
