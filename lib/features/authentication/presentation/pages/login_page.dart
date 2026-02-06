import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/events/auth_event.dart';
import '../bloc/states/auth_state.dart';
import '../bloc/login_page_bloc.dart';
import '../bloc/events/login_page_event.dart';
import '../bloc/states/login_page_state.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/utils/bloc_extensions.dart';
import '../../../../core/theme/app_theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc is already provided at app level, no need to recreate it
    return BlocProvider(
      create: (context) => LoginPageBloc(),
      child: const _LoginPageView(),
    );
  }
}

class _LoginPageView extends StatefulWidget {
  const _LoginPageView();

  @override
  State<_LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<_LoginPageView> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isNavigating = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitOnDoubleBack(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              // Prevent multiple navigations
              if (_isNavigating) return;
              
              print('🔔 AuthState Listener: isAuthenticated=${state.isAuthenticated}, mustChangePassword=${state.mustChangePassword}, error=${state.errorMessage}');
              
              // Show error message if present
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  ErrorSnackBar(
                    message: state.errorMessage!,
                    errorSource: 'Login',
                    errorType: 'Authentication Error',
                  ),
                );
                // Reset navigation flag on error so user can try again
                _isNavigating = false;
              }
              
              // CRITICAL: Only navigate if authenticated AND no error message
              // This prevents navigation on wrong credentials
              if (state.isAuthenticated && 
                  state.errorMessage == null && 
                  !_isNavigating) {
                _isNavigating = true;
                // Only redirect to change password if mustChangePassword is explicitly true
                // This should only happen on FIRST login after signup
                if (state.mustChangePassword == true) {
                  print('🔐 Must change password, navigating to change password screen');
                  print('   ⚠️ NOTE: If you see this after changing password, the API is returning mustChangePassword=true incorrectly');
                  Future.microtask(() {
                    if (mounted) {
                      context.go('/change-password');
                    }
                  });
                } else {
                  print('✅ Login successful, navigating to dashboard');
                  print('   mustChangePassword: ${state.mustChangePassword} (should be false after password change)');
                  Future.microtask(() {
                    if (mounted) {
                      context.go('/dashboard');
                    }
                  });
                }
              } else if (!state.isAuthenticated && state.errorMessage == null && !state.isLoading) {
                // Reset navigation flag when not authenticated and not loading
                _isNavigating = false;
              }
            },
            builder: (context, authState) {
              return BlocBuilder<LoginPageBloc, LoginPageState>(
                builder: (context, pageState) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.business,
                              size: 64,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Counter Login',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to manage your bookings',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 32),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              side: BorderSide(color: Colors.grey.shade100, width: 0.5),
                            ),
                            color: AppTheme.backgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: const Icon(Icons.email),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter email';
                                      }
                                      final trimmed = value.trim();
                                      if (!trimmed.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: pageState.obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          pageState.obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<LoginPageBloc>()
                                              .safeAdd(const TogglePasswordVisibilityEvent());
                                        },
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
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: (authState.isLoading || _isNavigating)
                                          ? null
                                          : () {
                                              if (formKey.currentState!.validate() && !_isNavigating && mounted) {
                                                try {
                                                  final authBloc = context.read<AuthBloc>();
                                                  print('🔍 AuthBloc state check: isClosed=${authBloc.isClosed}');
                                                  if (!authBloc.isClosed) {
                                                    print('📤 Adding LoginEvent to AuthBloc');
                                                    authBloc.add(
                                                      LoginEvent(
                                                        email: emailController.text.trim(),
                                                        password: passwordController.text.trim(),
                                                      ),
                                                    );
                                                    print('✅ LoginEvent added successfully');
                                                  } else {
                                                    print('❌ AuthBloc is closed, cannot add event');
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      ErrorSnackBar(
                                                        message: 'Authentication service is not available. Please restart the app.',
                                                        errorSource: 'Login',
                                                        errorType: 'Service Error',
                                                      ),
                                                    );
                                                  }
                                                } catch (e, stackTrace) {
                                                  print('❌ Error accessing AuthBloc: $e');
                                                  print('   StackTrace: $stackTrace');
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    ErrorSnackBar(
                                                      message: 'Failed to initiate login. Please try again.',
                                                      errorSource: 'Login',
                                                      errorType: 'System Error',
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: authState.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Text('Login'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        context.go('/forgot-password');
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.textSecondary,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // "I'm a Driver" button
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        context.go('/driver/login');
                                      },
                                      icon: const Icon(Icons.drive_eta),
                                      label: const Text("I'm a Driver"),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Don\'t have an account? ',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.go('/signup');
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppTheme.primaryColor,
                                        ),
                                        child: const Text('Sign Up'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

