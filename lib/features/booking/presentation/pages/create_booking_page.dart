import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/events/booking_event.dart';
import '../bloc/states/booking_state.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/widgets/progress_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../domain/entities/booking_entity.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/events/dashboard_event.dart';
import '../../../dashboard/presentation/bloc/states/dashboard_state.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../wallet/presentation/bloc/events/wallet_event.dart';
import '../../../wallet/domain/usecases/create_wallet_hold.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/phone_normalizer.dart';

/// Create Booking UI palette: readable text, clear borders, no harsh black/white.
class _BookingUI {
  static const Color background = Color(0xFFF1F5F9); // Slate-100
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFCBD5E1); // Slate-300
  static const Color borderStrong = Color(0xFF94A3B8); // Slate-400
  static const Color textPrimary = Color(0xFF1E293B); // Slate-800
  static const Color textSecondary = Color(0xFF475569); // Slate-600
  static const Color textTertiary = Color(0xFF64748B); // Slate-500
  static const Color primary = Color(0xFF0F766E); // Teal-700
  static const Color primaryContainer = Color(0xFFCCFBF1); // Teal-100
  static const Color onPrimary = Color(0xFFFFFFFF);
}

class CreateBookingPage extends StatefulWidget {
  const CreateBookingPage({super.key});

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _passengerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _passengerEmailController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _dropoffLocationController = TextEditingController();
  final _luggageController = TextEditingController();
  
  String? _selectedBusId;
  String _selectedPaymentMethod = 'cash';
  List<dynamic> _selectedSeats = []; // Supports both int (legacy) and String (new format)
  int _bagCount = 0;
  
  @override
  void dispose() {
    _passengerNameController.dispose();
    _contactNumberController.dispose();
    _passengerEmailController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    _luggageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          // Use a fresh BookingBloc instance from DI to avoid using a closed bloc
          create: (context) => di.sl<BookingBloc>()..add(const GetAvailableBusesEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<DashboardBloc>()..add(const GetDashboardEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<WalletBloc>()..add(GetTransactionsEvent()),
        ),
      ],
      child: BackButtonHandler(
        enableDoubleBackToExit: false,
        child: Scaffold(
        appBar: AppAppBar(
          title: 'Create Booking',
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              // If booking failed and we have a holdId, release it
              final errorMessage = state.errorMessage!;
              final isHoldError = errorMessage.toLowerCase().contains('hold') ||
                  errorMessage.toLowerCase().contains('invalid') ||
                  errorMessage.toLowerCase().contains('expired');
              
              if (isHoldError) {
                // Try to extract holdId from error or get from last booking attempt
                // For now, we'll show error and let user retry
                // In production, you might want to track the holdId in state
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: errorMessage,
                  errorSource: 'Booking',
                ),
              );
            }
            if (state.successMessage != null && state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SuccessSnackBar(message: state.successMessage!),
              );
            }
            if (state.createdBooking != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SuccessSnackBar(message: 'Booking created successfully! Amount deducted from wallet.'),
              );
              
              // Refresh dashboard to update wallet balance
              context.read<DashboardBloc>().add(const GetDashboardEvent());
              
              // Navigate to home dashboard after success
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go('/dashboard');
                }
              });
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.buses.isEmpty) {
              return const SkeletonList(itemCount: 5, itemHeight: 100);
            }

            final bookingTheme = Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: _BookingUI.primary,
                onPrimary: _BookingUI.onPrimary,
                primaryContainer: _BookingUI.primaryContainer,
                surface: _BookingUI.cardBackground,
                onSurface: _BookingUI.textPrimary,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: _BookingUI.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  side: const BorderSide(color: _BookingUI.border, width: 1.5),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: _BookingUI.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: const BorderSide(color: _BookingUI.border, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: const BorderSide(color: _BookingUI.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: const BorderSide(color: _BookingUI.primary, width: 2),
                ),
                labelStyle: const TextStyle(color: _BookingUI.textSecondary),
                hintStyle: const TextStyle(color: _BookingUI.textTertiary),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _BookingUI.primary,
                  foregroundColor: _BookingUI.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    side: const BorderSide(color: _BookingUI.borderStrong, width: 1),
                  ),
                ),
              ),
              dividerTheme: const DividerThemeData(
                color: _BookingUI.border,
                thickness: 1,
                space: 1,
              ),
              textTheme: Theme.of(context).textTheme.copyWith(
                titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(color: _BookingUI.textPrimary),
                titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(color: _BookingUI.textPrimary),
                bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _BookingUI.textPrimary),
                bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _BookingUI.textSecondary),
                bodySmall: Theme.of(context).textTheme.bodySmall?.copyWith(color: _BookingUI.textTertiary),
                labelLarge: Theme.of(context).textTheme.labelLarge?.copyWith(color: _BookingUI.textPrimary),
              ),
            );
            return Container(
              color: _BookingUI.background,
              child: Theme(
                data: bookingTheme,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Step Indicator
                    StepProgressIndicator(
                      currentStep: _selectedBusId == null 
                          ? 1 
                          : (_selectedSeats.isEmpty 
                              ? 2 
                              : (_passengerNameController.text.isEmpty || _contactNumberController.text.isEmpty
                                  ? 3
                                  : 4)),
                      totalSteps: 4,
                      stepLabels: const ['Select Bus', 'Choose Seats', 'Passenger Info', 'Review & Pay'],
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Step 1: Bus Selection
                    _BusSelectionSection(
                      buses: state.buses,
                      selectedBusId: _selectedBusId,
                      onBusSelected: (busId) {
                        setState(() {
                          _selectedBusId = busId;
                          _selectedSeats = [];
                        });
                        context.read<BookingBloc>().add(GetBusDetailsEvent(busId: busId));
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Step 2: Seat Selection (only if bus is selected)
                    if (_selectedBusId != null && state.selectedBus != null) ...[
                      // Check wallet balance - if sufficient, allow booking even without access
                      BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, dashboardState) {
                          final dashboard = dashboardState.dashboard;
                          final walletBalance = dashboard?.counter.walletBalance ?? 0.0;
                          final bus = state.selectedBus!;
                          final estimatedPrice = bus.price; // Estimate for one seat
                          final hasSufficientBalance = walletBalance >= estimatedPrice;
                          final hasAccess = bus.hasAccess == true;
                          final hasNoAccess = bus.hasAccess == false || 
                                             (bus.hasAccess == null && bus.hasNoAccess == true);
                          
                          // If no access AND insufficient balance, show message
                          if (hasNoAccess && !hasSufficientBalance) {
                            return EnhancedCard(
                              border: Border.all(color: _BookingUI.border, width: 1.5),
                              child: Container(
                                padding: const EdgeInsets.all(AppTheme.spacingL),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.block,
                                      size: 64,
                                      color: AppTheme.errorColor,
                                    ),
                                    const SizedBox(height: AppTheme.spacingM),
                                    Text(
                                      'No Access',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.errorColor,
                                          ),
                                    ),
                                    const SizedBox(height: AppTheme.spacingS),
                                    Text(
                                      'You do not have access to this bus. Add money to your wallet (Rs. ${NumberFormat('#,##0.00').format(estimatedPrice)} minimum) to book seats.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: _BookingUI.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: AppTheme.spacingM),
                                    ElevatedButton.icon(
                                      onPressed: () => context.go('/wallet'),
                                      icon: const Icon(Icons.account_balance_wallet),
                                      label: const Text('Add Money to Wallet'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          
                          // Show seat map if: has access OR has sufficient wallet balance
                          if (hasAccess || hasSufficientBalance) {
                            return _SeatSelectionSection(
                              bus: state.selectedBus!,
                              selectedSeats: _selectedSeats,
                              walletGrantsAccess: hasSufficientBalance && hasNoAccess,
                              onSeatsChanged: (seats) {
                                setState(() {
                                  _selectedSeats = seats;
                                });
                              },
                              onLockSeats: (seats) {
                                context.read<BookingBloc>().add(
                                  LockSeatsEvent(busId: _selectedBusId!, seatNumbers: seats),
                                );
                              },
                              onUnlockSeats: (seats) {
                                context.read<BookingBloc>().add(
                                  UnlockSeatsEvent(busId: _selectedBusId!, seatNumbers: seats),
                                );
                              },
                            );
                          }
                          
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                    
                    if (_selectedBusId != null && state.selectedBus != null) ...[
                      const SizedBox(height: 24),
                      
                      // Selected Bus & Seats Summary
                      if (_selectedSeats.isNotEmpty)
                        _SelectedBusAndSeatsSummary(
                          bus: state.selectedBus!,
                          selectedSeats: _selectedSeats,
                        ),
                      
                      if (_selectedSeats.isNotEmpty) const SizedBox(height: 24),
                      
                      // Step 3: Passenger Information
                      _PassengerInfoSection(
                        passengerNameController: _passengerNameController,
                        contactNumberController: _contactNumberController,
                        passengerEmailController: _passengerEmailController,
                        pickupLocationController: _pickupLocationController,
                        dropoffLocationController: _dropoffLocationController,
                        luggageController: _luggageController,
                        bagCount: _bagCount,
                        onBagCountChanged: (count) {
                          setState(() {
                            _bagCount = count;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Step 4: Payment Method
                      _PaymentMethodSection(
                        selectedPaymentMethod: _selectedPaymentMethod,
                        onPaymentMethodChanged: (method) {
                          setState(() {
                            _selectedPaymentMethod = method;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Booking Summary
                      if (_selectedSeats.isNotEmpty)
                        BlocBuilder<DashboardBloc, DashboardState>(
                          builder: (context, dashboardState) {
                            final walletBalance = dashboardState.dashboard?.counter.walletBalance ?? 0.0;
                            return _BookingSummarySection(
                              bus: state.selectedBus!,
                              selectedSeats: _selectedSeats,
                              paymentMethod: _selectedPaymentMethod,
                              walletBalance: walletBalance,
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, dashboardState) {
                          final isFormValid = _isFormValid(state, context);
                          final walletBalance = dashboardState.dashboard?.counter.walletBalance ?? 0.0;
                          final totalPrice = state.selectedBus != null 
                              ? state.selectedBus!.price * _selectedSeats.length 
                              : 0.0;
                          final hasInsufficientBalance = totalPrice > 0 && walletBalance < totalPrice;
                          
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (isFormValid && !state.isLoading && !hasInsufficientBalance) 
                                  ? () => _submitBooking(context, state)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: hasInsufficientBalance 
                                    ? AppTheme.errorColor.withOpacity(0.5)
                                    : null,
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(hasInsufficientBalance 
                                      ? 'Insufficient Wallet Balance'
                                      : 'Confirm Booking'),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
              ),
            );
          },
        ),
      ),
        ),
    );
  }

  bool _isFormValid(BookingState state, BuildContext context) {
    if (_selectedBusId == null) return false;
    if (_selectedSeats.isEmpty) return false;
    if (_passengerNameController.text.trim().isEmpty) return false;
    if (_contactNumberController.text.trim().isEmpty) return false;
    
    // Check if selected bus has access
    if (state.selectedBus != null) {
      final bus = state.selectedBus!;
      
      // Check available seats
      if (bus.availableSeats == 0) {
        return false;
      }
      
      // Check wallet balance first - if sufficient, allow booking even without access
      final dashboardState = context.read<DashboardBloc>().state;
      final dashboard = dashboardState.dashboard;
      if (dashboard != null) {
        final walletBalance = dashboard.counter.walletBalance;
        final totalPrice = bus.price * _selectedSeats.length;
        
        // If user has sufficient wallet balance, allow booking (wallet grants access)
        if (walletBalance >= totalPrice) {
          return true; // Wallet balance sufficient - can book even without access
        }
        
        // If insufficient balance AND no access, block booking
        if ((bus.hasNoAccess == true || bus.hasAccess == false) && walletBalance < totalPrice) {
          return false; // Both conditions: no access AND insufficient balance
        }
      } else {
        // If dashboard not loaded, check access only
        if (bus.hasNoAccess == true || bus.hasAccess == false) {
          return false;
        }
      }
    }
    
    return true;
  }

  Future<void> _submitBooking(BuildContext context, BookingState state) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         ErrorSnackBar(message: 'Please select a bus'),
      );
      return;
    }

    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         ErrorSnackBar(message: 'Please select at least one seat'),
      );
      return;
    }

    // Validate seat access before API call
    final selectedBus = state.selectedBus;
    if (selectedBus != null) {
      // Check wallet balance first - if sufficient, allow booking even without access
      final dashboardState = context.read<DashboardBloc>().state;
      final dashboard = dashboardState.dashboard;
      final walletBalance = dashboard?.counter.walletBalance ?? 0.0;
      final totalPrice = selectedBus.price * _selectedSeats.length;

      // DEBUG: why wallet/topup messages may appear
      debugPrint('[CreateBooking] _submitBooking selectedBus: id=${selectedBus.id} name=${selectedBus.name}');
      debugPrint('[CreateBooking]   requiresWallet=${selectedBus.requiresWallet} hasAccess=${selectedBus.hasAccess} hasNoAccess=${selectedBus.hasNoAccess}');
      debugPrint('[CreateBooking]   walletBalance=$walletBalance totalPrice=$totalPrice (${_selectedSeats.length} seats x ${selectedBus.price})');
      debugPrint('[CreateBooking]   noAccessAndInsufficient=${(selectedBus.hasNoAccess == true || selectedBus.hasAccess == false) && walletBalance < totalPrice}');
      
      // If user has no access AND insufficient wallet balance, show dialog
      if ((selectedBus.hasNoAccess == true || selectedBus.hasAccess == false) && walletBalance < totalPrice) {
        debugPrint('[CreateBooking] BLOCKING: No access + insufficient balance -> showing "add money to wallet or request access"');
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar(
            message: 'You do not have access to this bus. Please add money to wallet or request access.',
          ),
        );
        // Show dialog to redirect to wallet or request access
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('No Access'),
                content: Text(
                  'You do not have access to book seats on this bus.\n\n'
                  'Required amount: Rs. ${NumberFormat('#,##0.00').format(totalPrice)}\n'
                  'Current balance: Rs. ${NumberFormat('#,##0.00').format(walletBalance)}\n\n'
                  'Would you like to add money to your wallet or request access?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pop();
                      context.go('/wallet');
                    },
                    child: const Text('Add to Wallet'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                      context.go('/counter/request-bus-access?busId=${selectedBus.id}');
                    },
                    child: const Text('Request Access'),
                  ),
                ],
              ),
            );
          }
        });
        return;
      }
      
      // If user has sufficient wallet balance, proceed with booking (wallet grants access)
      // The backend will handle the wallet deduction

      // Normalize selected seats for comparison (matches backend normalization)
      // Convert numeric strings to numbers, keep non-numeric as strings
      final normalizedSelectedSeats = _selectedSeats.map((seat) {
        if (seat == null) return null;
        
        // If already a number, keep as number
        if (seat is int) return seat;
        if (seat is num) return seat.toInt();
        
        // If string, try to parse as number
        if (seat is String) {
          final trimmed = seat.trim();
          if (trimmed.isEmpty) return null;
          
          // Try parsing as number
          final numValue = int.tryParse(trimmed);
          if (numValue != null && trimmed == numValue.toString()) {
            // It's a numeric string like "1", "2", "3" - convert to int
            return numValue;
          } else {
            // Non-numeric string like "A1", "B2" - keep as string
            return trimmed;
          }
        }
        
        // For other types, convert to string
        final str = seat.toString().trim();
        if (str.isEmpty) return null;
        final numValue = int.tryParse(str);
        if (numValue != null && str == numValue.toString()) {
          return numValue;
        }
        return str;
      }).where((seat) => seat != null).toList();

      // Check if counter has restricted access and validate selected seats
      if (selectedBus.hasRestrictedAccess == true) {
        // First, validate against allowedSeats
        if (selectedBus.allowedSeats != null && selectedBus.allowedSeats!.isNotEmpty) {
          // Find seats that are not in allowedSeats
          // Check both numeric and string comparisons to handle type mismatches
          final notAllowedSeats = normalizedSelectedSeats.where((seat) {
            // Try multiple comparison methods to handle type mismatches
            if (seat is int) {
              // Check if seat number is in allowedSeats (as int or string)
              return !selectedBus.allowedSeats!.contains(seat) &&
                     !selectedBus.allowedSeats!.any((allowed) => 
                       allowed is int ? allowed == seat : 
                       allowed.toString() == seat.toString()
                     );
            }
            // For string seats or mixed types, check string comparison
            final seatStr = seat.toString();
            return !selectedBus.allowedSeats!.any((allowed) {
              // Try multiple comparison methods
              if (allowed is int) {
                return allowed.toString() == seatStr || allowed == int.tryParse(seatStr);
              }
              return allowed.toString() == seatStr;
            });
          }).toList();

          if (notAllowedSeats.isNotEmpty) {
            final allowedSeatsStr = selectedBus.allowedSeats!.map((s) => s.toString()).join(', ');
            final notAllowedStr = notAllowedSeats.map((s) => s.toString()).join(', ');
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: 'You are not allowed to book seat(s): $notAllowedStr. Add money to wallet to book these seats.',
              ),
            );
            // Redirect to wallet for seats not in allowed list
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Seat Access Required'),
                    content: Text(
                      'You are not allowed to book seat(s): $notAllowedStr.\n\n'
                      'You can only book: $allowedSeatsStr\n\n'
                      'To book other seats, please add money to your wallet.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.pop();
                          context.go('/wallet');
                        },
                        child: const Text('Go to Wallet'),
                      ),
                    ],
                  ),
                );
              }
            });
            return;
          }
        }

        // Second, validate against availableAllowedSeats (seats that are BOTH allowed AND available)
        if (selectedBus.availableAllowedSeats != null && selectedBus.availableAllowedSeats!.isNotEmpty) {
          // Find seats that are not in availableAllowedSeats
          // Check both numeric and string comparisons to handle type mismatches
          final notAvailableSeats = normalizedSelectedSeats.where((seat) {
            // Try multiple comparison methods to handle type mismatches
            if (seat is int) {
              // Check if seat number is in availableAllowedSeats (as int or string)
              return !selectedBus.availableAllowedSeats!.contains(seat) &&
                     !selectedBus.availableAllowedSeats!.any((allowed) => 
                       allowed is int ? allowed == seat : 
                       allowed.toString() == seat.toString()
                     );
            }
            // For string seats or mixed types, check string comparison
            final seatStr = seat.toString();
            return !selectedBus.availableAllowedSeats!.any((allowed) {
              // Try multiple comparison methods
              if (allowed is int) {
                return allowed.toString() == seatStr || allowed == int.tryParse(seatStr);
              }
              return allowed.toString() == seatStr;
            });
          }).toList();

          if (notAvailableSeats.isNotEmpty) {
            final availableSeatsStr = selectedBus.availableAllowedSeats!.map((s) => s.toString()).join(', ');
            final notAvailableStr = notAvailableSeats.map((s) => s.toString()).join(', ');
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: 'Seat(s) $notAvailableStr are not currently available. Available seats: $availableSeatsStr',
              ),
            );
            return;
          }
        } else if (selectedBus.allowedSeats != null && selectedBus.allowedSeats!.isNotEmpty) {
          // If availableAllowedSeats is empty but allowedSeats exists, no seats are available
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              message: 'No seats are currently available for booking on this bus.',
            ),
          );
          return;
        }
      }

      // Check if bus requires wallet AND balance is insufficient — only then block and ask to top up
      debugPrint('[CreateBooking] requiresWallet check: selectedBus.requiresWallet=${selectedBus.requiresWallet} walletBalance=$walletBalance totalPrice=$totalPrice');
      if (selectedBus.requiresWallet == true && walletBalance < totalPrice) {
        debugPrint('[CreateBooking] BLOCKING: requiresWallet==true and insufficient balance -> showing "Wallet Required / please add money"');
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar(
            message: 'This bus requires wallet balance. Please add money to your wallet first.',
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Wallet Required'),
                content: const Text(
                  'This bus requires wallet balance to make bookings. '
                  'Please add money to your wallet first.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                      context.go('/wallet');
                    },
                    child: const Text('Go to Wallet'),
                  ),
                ],
              ),
            );
          }
        });
        return;
      }
    }

    // Check wallet balance before proceeding with booking
    final dashboardState = context.read<DashboardBloc>().state;
    final dashboard = dashboardState.dashboard;
    if (dashboard != null) {
      final walletBalance = dashboard.counter.walletBalance;
      final totalPrice = selectedBus != null 
          ? selectedBus.price * _selectedSeats.length 
          : 0.0;
      debugPrint('[CreateBooking] balance check: walletBalance=$walletBalance totalPrice=$totalPrice insufficient=${walletBalance < totalPrice}');
      if (walletBalance < totalPrice) {
        debugPrint('[CreateBooking] BLOCKING: Insufficient balance -> showing "Insufficient Wallet Balance / please add Rs.X"');
        final shortage = totalPrice - walletBalance;
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar(
            message: 'Insufficient wallet balance. You need Rs. ${NumberFormat('#,##0.00').format(totalPrice)} to book ${_selectedSeats.length} seat(s). Current balance: Rs. ${NumberFormat('#,##0.00').format(walletBalance)}. Please add Rs. ${NumberFormat('#,##0.00').format(shortage)} to your wallet.',
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Insufficient Wallet Balance'),
                content: Text(
                  'You need Rs. ${NumberFormat('#,##0.00').format(totalPrice)} to book ${_selectedSeats.length} seat(s).\n\n'
                  'Current balance: Rs. ${NumberFormat('#,##0.00').format(walletBalance)}\n\n'
                  'Please add Rs. ${NumberFormat('#,##0.00').format(shortage)} to your wallet to proceed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                      context.go('/wallet');
                    },
                    child: const Text('Add Money to Wallet'),
                  ),
                ],
              ),
            );
          }
        });
        return;
      }
    }

    // Two-Step Hold Flow (per backend API): create hold → create booking with holdId.
    // When holdId is valid, backend skips counter bus access check ("wallet balance = can book").
    await _createBookingWithHold(context, state, selectedBus);
  }

  Future<void> _createBookingWithHold(
    BuildContext context,
    BookingState state,
    BusInfoEntity? selectedBus,
  ) async {
    if (selectedBus == null) return;

    // Must match backend: |hold.amount - totalPrice| <= 0.01
    final totalPrice = selectedBus.price * _selectedSeats.length;
    final busName = selectedBus.name;
    final seatsStr = _selectedSeats.map((s) => s.toString()).join(', ');

    // Step 1: Create wallet hold
    try {
      final createHold = di.sl<CreateWalletHold>();
      final holdResult = await createHold(
        amount: totalPrice,
        description: 'Hold for booking - Bus: $busName, Seats: $seatsStr',
      );

      if (holdResult is Error) {
        final failure = (holdResult as Error).failure;
        
        // Handle insufficient balance error
        if (failure is ServerFailure && 
            failure.message.toLowerCase().contains('insufficient')) {
          final dashboardState = context.read<DashboardBloc>().state;
          final dashboard = dashboardState.dashboard;
          final walletBalance = dashboard?.counter.walletBalance ?? 0.0;
          final shortage = totalPrice - walletBalance;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: 'Insufficient wallet balance. You need Rs. ${NumberFormat('#,##0.00').format(totalPrice)}. Current balance: Rs. ${NumberFormat('#,##0.00').format(walletBalance)}.',
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Insufficient Wallet Balance'),
                    content: Text(
                      'You need Rs. ${NumberFormat('#,##0.00').format(totalPrice)} to book ${_selectedSeats.length} seat(s).\n\n'
                      'Current balance: Rs. ${NumberFormat('#,##0.00').format(walletBalance)}\n\n'
                      'Please add Rs. ${NumberFormat('#,##0.00').format(shortage)} to your wallet to proceed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.pop();
                          context.go('/wallet');
                        },
                        child: const Text('Add Money to Wallet'),
                      ),
                    ],
                  ),
                );
              }
            });
          }
          return;
        }
        
        // Handle other errors (do not expose backend/API details)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              message: 'Unable to reserve the amount. Please try again or add money to your wallet.',
            ),
          );
        }
        return;
      }

      // Step 2: Hold created successfully, create booking with holdId
      final hold = (holdResult as Success).data;
      final holdId = hold.holdId;

      if (mounted) {
        // Normalize and validate contact number
        final rawContact = _contactNumberController.text.trim();
        final normalizedContact = PhoneNormalizer.normalizeNepalPhone(rawContact);
        if (!PhoneNormalizer.isValidNormalizedNepalMobile(normalizedContact)) {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              message: 'Please enter a valid 10-digit Nepal mobile number (98XXXXXXXX).',
              errorSource: 'Booking',
            ),
          );
          return;
        }

        // Create booking with holdId (backend skips access check when holdId is valid)
        context.read<BookingBloc>().add(
          CreateBookingEvent(
            busId: _selectedBusId!,
            seatNumbers: _selectedSeats,
            passengerName: _passengerNameController.text.trim(),
            contactNumber: normalizedContact,
            passengerEmail: _passengerEmailController.text.trim().isEmpty
                ? null
                : _passengerEmailController.text.trim(),
            pickupLocation: _pickupLocationController.text.trim().isEmpty
                ? null
                : _pickupLocationController.text.trim(),
            dropoffLocation: _dropoffLocationController.text.trim().isEmpty
                ? null
                : _dropoffLocationController.text.trim(),
            luggage: _luggageController.text.trim().isEmpty
                ? null
                : _luggageController.text.trim(),
            bagCount: _bagCount > 0 ? _bagCount : null,
            // When paying via hold, backend expects paymentMethod: 'wallet'
            paymentMethod: 'wallet',
            holdId: holdId,
          ),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorSnackBar(
            message: 'An error occurred while reserving amount. Please try again.',
          ),
        );
      }
    }
  }
}

class _BusSelectionSection extends StatelessWidget {
  final List<BusInfoEntity> buses;
  final String? selectedBusId;
  final Function(String) onBusSelected;

  const _BusSelectionSection({
    required this.buses,
    required this.selectedBusId,
    required this.onBusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_bus, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Select Bus',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (buses.isEmpty)
              const EmptyStateWidget(
                icon: Icons.event_busy,
                title: 'No buses available',
                description: 'Please check back later or contact support.',
              )
            else ...[
              // Show all buses - check wallet balance to determine if accessible
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, dashboardState) {
                  final dashboard = dashboardState.dashboard;
                  final walletBalance = dashboard?.counter.walletBalance ?? 0.0;
                  
                  // Separate buses into accessible and inaccessible
                  final accessibleBuses = buses.where((bus) {
                    if (bus.availableSeats == 0) return false;
                    if (selectedBusId == bus.id) return true;
                    final hasAccess = bus.hasAccess == true;
                    final hasNoAccess = bus.hasAccess == false || 
                                       (bus.hasAccess == null && bus.hasNoAccess == true);
                    final estimatedPrice = bus.price; // Estimate for one seat
                    final hasSufficientBalance = walletBalance >= estimatedPrice;
                    
                    // Bus is accessible if: has access OR has sufficient wallet balance
                    return hasAccess || (hasNoAccess && hasSufficientBalance);
                  }).toList();
                  
                  final inaccessibleBuses = buses.where((bus) {
                    if (bus.availableSeats == 0) return true;
                    if (selectedBusId == bus.id) return false;
                    final hasAccess = bus.hasAccess == true;
                    final hasNoAccess = bus.hasAccess == false || 
                                       (bus.hasAccess == null && bus.hasNoAccess == true);
                    final estimatedPrice = bus.price;
                    final hasSufficientBalance = walletBalance >= estimatedPrice;
                    
                    // Bus is inaccessible if: no access AND insufficient balance
                    return hasNoAccess && !hasSufficientBalance;
                  }).toList();
                  
                  return Column(
                    children: [
                      // Show accessible buses first
                      ...accessibleBuses.map((bus) {
                        final hasNoAccess = bus.hasAccess == false || 
                                           (bus.hasAccess == null && bus.hasNoAccess == true);
                        final estimatedPrice = bus.price;
                        final hasSufficientBalance = walletBalance >= estimatedPrice;
                        final isSelected = selectedBusId == bus.id;
                        
                        // Disable if: 
                        // - no seats available
                        // - OR (no access AND insufficient balance AND another bus is selected)
                        // This allows users with wallet balance to switch to buses with no access
                        final isDisabled = bus.availableSeats == 0 || 
                                          (hasNoAccess && !hasSufficientBalance && selectedBusId != null && !isSelected);
                        
                        return _BusCard(
                          bus: bus,
                          isSelected: isSelected,
                          isDisabled: isDisabled,
                          onTap: isDisabled ? null : () => onBusSelected(bus.id),
                        );
                      }),
                      // Show inaccessible buses (no access AND insufficient balance) as disabled at the bottom
                      if (inaccessibleBuses.isNotEmpty)
                        ...inaccessibleBuses.map((bus) {
                          final isSelected = selectedBusId == bus.id;
                          // These buses already have no access AND insufficient balance
                          // Disable them if another bus is selected (but keep selected bus enabled)
                          final isDisabled = selectedBusId != null && !isSelected;
                          
                          return _BusCard(
                            bus: bus,
                            isSelected: isSelected,
                            isDisabled: isDisabled,
                            onTap: isDisabled ? null : () => onBusSelected(bus.id),
                          );
                        }),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BusCard extends StatelessWidget {
  final BusInfoEntity bus;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _BusCard({
    required this.bus,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  String _formatTime(String time) {
    try {
      // Try parsing as HH:mm format
      final parsed = DateFormat('HH:mm').parse(time);
      return DateFormat('h:mm a').format(parsed);
    } catch (e) {
      // If parsing fails, return original time
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNoAccess = bus.hasNoAccess == true || bus.hasAccess == false;
    final noSeats = bus.availableSeats == 0;
    final opacity = isDisabled ? 0.5 : 1.0;
    final surface = theme.colorScheme.surface;
    final disabledBg = theme.colorScheme.onSurface.withOpacity(0.06);
    final disabledFg = theme.colorScheme.onSurface.withOpacity(0.5);

    return Opacity(
      opacity: opacity,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : (isDisabled ? disabledBg : surface),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDisabled
                            ? disabledFg.withOpacity(0.3)
                            : theme.colorScheme.primaryContainer),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : _BookingUI.border,
                      width: isSelected ? 0 : 1,
                    ),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : (isDisabled ? disabledFg : theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bus.name.isEmpty ? 'Bus ${bus.id.substring(0, 8)}' : bus.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : (isDisabled
                                            ? disabledFg
                                            : theme.colorScheme.onSurface),
                                  ),
                            ),
                          ),
                          if (hasNoAccess)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'No Access',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (noSeats)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Full',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.warningColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.route,
                            size: 14,
                            color: isSelected
                                ? theme.colorScheme.onPrimary.withOpacity(0.9)
                                : (isDisabled ? disabledFg : theme.colorScheme.onSurface.withOpacity(0.8)),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${bus.from} → ${bus.to}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary.withOpacity(0.9)
                                    : (isDisabled ? disabledFg : theme.colorScheme.onSurface),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary.withOpacity(0.9)
                                    : (isDisabled ? disabledFg : theme.colorScheme.onSurface.withOpacity(0.7)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(bus.time),
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary.withOpacity(0.9)
                                          : (isDisabled ? disabledFg : theme.colorScheme.onSurface.withOpacity(0.7)),
                                    ),
                              ),
                              if (bus.arrival != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '→ ${_formatTime(bus.arrival!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary.withOpacity(0.9)
                                            : (isDisabled ? disabledFg : theme.colorScheme.onSurface.withOpacity(0.7)),
                                      ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event,
                                size: 14,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary.withOpacity(0.9)
                                    : (isDisabled ? disabledFg : theme.colorScheme.onSurface.withOpacity(0.7)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d').format(bus.date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.onPrimary.withOpacity(0.9)
                                          : (isDisabled ? disabledFg : theme.colorScheme.onSurface.withOpacity(0.7)),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${NumberFormat('#,##0').format(bus.price)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : (isDisabled ? disabledFg : theme.colorScheme.primary),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bus.availableSeats > 0 
                            ? AppTheme.successColor.withOpacity(0.1) 
                            : AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${bus.availableSeats} ${bus.availableSeats == 1 ? 'seat' : 'seats'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: bus.availableSeats > 0 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                ] else if (isDisabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.block,
                    color: AppTheme.textTertiary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatSelectionSection extends StatelessWidget {
  final BusInfoEntity bus;
  final List<dynamic> selectedSeats; // Supports both int and String
  final bool walletGrantsAccess; // True when user has no counter access but sufficient balance to book
  final Function(List<dynamic>) onSeatsChanged;
  final Function(List<dynamic>) onLockSeats;
  final Function(List<dynamic>) onUnlockSeats;

  const _SeatSelectionSection({
    required this.bus,
    required this.selectedSeats,
    this.walletGrantsAccess = false,
    required this.onSeatsChanged,
    required this.onLockSeats,
    required this.onUnlockSeats,
  });

  @override
  Widget build(BuildContext context) {
    // Extract booked seats - handle both int and String formats
    final bookedSeats = bus.bookedSeats.map((seat) {
      if (seat is num) return seat.toInt();
      if (seat is String) return seat;
      return seat.toString();
    }).toList();
    
    // Extract locked seats - handle SeatLockEntity objects
    final lockedSeats = bus.lockedSeats.map((lock) {
      final seatNum = lock.seatNumber;
      if (seatNum is num) return seatNum.toInt();
      if (seatNum is String) return seatNum;
      return seatNum.toString();
    }).toList();
    
    final seatConfiguration = bus.seatConfiguration;
    final totalSeats = bus.totalSeats;
    
    // Debug: Print seat information
    print('🔍 _SeatSelectionSection: Bus seat information');
    print('   Total Seats: $totalSeats');
    print('   Booked Seats: $bookedSeats (${bookedSeats.length})');
    print('   Locked Seats: $lockedSeats (${lockedSeats.length})');
    print('   Allowed Seats: ${bus.allowedSeats}');
    print('   Allowed Seats Count: ${bus.allowedSeatsCount}');
    print('   Has Restricted Access: ${bus.hasRestrictedAccess}');
    print('   Requires Wallet: ${bus.requiresWallet}');
    print('   Has No Access: ${bus.hasNoAccess}');
    print('   Available Allowed Seats: ${bus.availableAllowedSeats}');
    print('   Available Allowed Seats Count: ${bus.availableAllowedSeatsCount}');
    print('   Seat Configuration: $seatConfiguration');
    print('   Available Seats: ${totalSeats - bookedSeats.length - lockedSeats.length}');
    
    return EnhancedCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      border: Border.all(color: _BookingUI.border, width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: _BookingUI.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  border: Border.all(color: _BookingUI.border, width: 1),
                ),
                child: Icon(
                  Icons.event_seat_rounded,
                  color: _BookingUI.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Select Seats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _BookingUI.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          // Show access status info based on backend flags
          if (bus.hasRestrictedAccess == true) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.warningColor.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.warningColor, size: 20),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          'Restricted Access',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty)
                    Text(
                      'You can only book seats: ${bus.allowedSeats!.map((s) => s.toString()).join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  if (bus.availableAllowedSeats != null && bus.availableAllowedSeats!.isNotEmpty)
                    Text(
                      'Available allowed seats: ${bus.availableAllowedSeats!.map((s) => s.toString()).join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ] else if (bus.hasNoAccess == true) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.block, color: AppTheme.errorColor, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'No Access: You do not have permission to book seats on this bus.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ] else if (bus.hasAccess == true && bus.requiresWallet != true) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.successColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'Full Access: You can book any available seat.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ],
          // Seat Map
          _SeatMap(
            bus: bus,
            totalSeats: bus.totalSeats,
            seatConfiguration: seatConfiguration,
            bookedSeats: bookedSeats,
            lockedSeats: lockedSeats,
            selectedSeats: selectedSeats,
            walletGrantsAccess: walletGrantsAccess,
            onSeatTapped: (seatIdentifier) {
              final newSeats = List<dynamic>.from(selectedSeats);
              // Use proper comparison for both int and String
              final index = newSeats.indexWhere((s) => 
                s == seatIdentifier || 
                s.toString() == seatIdentifier.toString()
              );
              if (index != -1) {
                newSeats.removeAt(index);
              } else {
                newSeats.add(seatIdentifier);
              }
              onSeatsChanged(newSeats);
            },
          ),
          const SizedBox(height: 16),
          // Legend (Available, Sold, Selected) - like reference image
          if (bus.seatConfiguration != null && bus.seatConfiguration!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS, horizontal: AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.lightBorderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LegendChip(
                    color: AppTheme.successColor,
                    label: 'Available',
                    icon: Icons.airline_seat_recline_normal_rounded,
                  ),
                  _LegendChip(
                    color: AppTheme.errorColor,
                    label: 'Sold',
                    icon: Icons.event_busy,
                  ),
                  _LegendChip(
                    color: Theme.of(context).colorScheme.primary,
                    label: 'Selected',
                    icon: Icons.check_circle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Bus info footer (name, route, time, date)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.lightBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bus.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bus.from} to ${bus.to}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${bus.time}${bus.arrival != null ? ' | ${bus.arrival}' : ''}, ${DateFormat('EEEE, d MMMM yyyy').format(bus.date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ],
          // Seat Status Summary
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.statusInfo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.statusInfo.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SeatStatusItem(
                  icon: Icons.event_seat,
                  color: AppTheme.successColor,
                  label: bus.hasRestrictedAccess == true 
                      ? 'Available Allowed' 
                      : 'Available',
                  count: bus.hasRestrictedAccess == true && bus.availableAllowedSeatsCount != null
                      ? bus.availableAllowedSeatsCount!
                      : (totalSeats - bookedSeats.length - lockedSeats.length),
                ),
                _SeatStatusItem(
                  icon: Icons.event_busy,
                  color: AppTheme.errorColor,
                  label: 'Sold',
                  count: bookedSeats.length,
                ),
                _SeatStatusItem(
                  icon: Icons.lock,
                  color: AppTheme.warningColor,
                  label: 'Locked',
                  count: lockedSeats.length,
                ),
                if (bus.hasRestrictedAccess == true && bus.allowedSeatsCount != null)
                  _SeatStatusItem(
                    icon: Icons.check_circle,
                    color: AppTheme.statusInfo,
                    label: 'Allowed',
                    count: bus.allowedSeatsCount!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          _SeatLegend(
            hasRestrictedSeats: bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty,
            onLockSeats: () {
              if (selectedSeats.isNotEmpty) {
                onLockSeats(selectedSeats);
              }
            },
            onUnlockSeats: () {
              if (selectedSeats.isNotEmpty) {
                onUnlockSeats(selectedSeats);
              }
            },
          ),
          if (selectedSeats.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: ${selectedSeats.map((s) => s.toString()).join(', ')} (${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''})',
                      style: Theme.of(context).textTheme.bodyMedium,
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

/// Builds a column of seat widgets for Lower Decker A or B side.
/// Arranges seats in pairs (2 seats per row) matching reference image.
List<Widget> _buildDeckerSeatColumn(
  List<dynamic> seatIds,
  List<dynamic> bookedSeats,
  List<dynamic> lockedSeats,
  List<dynamic> selectedSeats,
  BusInfoEntity bus,
  double Function(dynamic) getSeatPrice, // Function to get price per seat
  bool Function(dynamic, List<dynamic>) isSeatInList,
  void Function(dynamic) onSeatTapped, {
  bool walletGrantsAccess = false,
}) {
  final widgets = <Widget>[];
  
  // Arrange seats in pairs (2 seats per row)
  for (int i = 0; i < seatIds.length; i += 2) {
    final rowSeats = seatIds.skip(i).take(2).toList();
    
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: rowSeats.map<Widget>((seatId) {
          final isBooked = isSeatInList(seatId, bookedSeats);
          final isLocked = isSeatInList(seatId, lockedSeats);
          final isSelected = isSeatInList(seatId, selectedSeats);
          final isSelectable = _seatSelectable(bus, seatId, isBooked, isLocked, walletGrantsAccess: walletGrantsAccess);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: _SeatWidget(
                seatIdentifier: seatId,
                seatPrice: getSeatPrice(seatId),
                isBooked: isBooked,
                isLocked: isLocked,
                isSelected: isSelected,
                isNotAllowed: !isSelectable,
                onTap: (isBooked || isLocked || !isSelectable) ? null : () => onSeatTapped(seatId),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  return widgets;
}

bool _seatSelectable(BusInfoEntity bus, dynamic seatId, bool isBooked, bool isLocked, {bool walletGrantsAccess = false}) {
  if (isBooked || isLocked) return false;
  // Allow selection when user has no counter access but sufficient wallet balance
  if (bus.hasNoAccess == true || bus.hasAccess == false) return walletGrantsAccess;
  if (bus.hasRestrictedAccess == true && bus.availableAllowedSeats != null && bus.availableAllowedSeats!.isNotEmpty) {
    final seatNum = seatId is int ? seatId : (seatId is String && int.tryParse(seatId) != null ? int.parse(seatId) : null);
    if (seatNum != null) return bus.availableAllowedSeats!.contains(seatNum);
    return bus.availableAllowedSeats!.any((a) => a.toString() == seatId.toString());
  }
  if (bus.hasAccess == true && bus.requiresWallet != true) return true;
  if (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty) {
    final seatNum = seatId is int ? seatId : (seatId is String && int.tryParse(seatId) != null ? int.parse(seatId) : null);
    if (seatNum != null) return bus.allowedSeats!.contains(seatNum);
    return bus.allowedSeats!.any((a) => a.toString() == seatId.toString());
  }
  return true;
}

class _SeatMap extends StatelessWidget {
  final BusInfoEntity bus; // Bus entity to check allowedSeats
  final int totalSeats;
  final List<String>? seatConfiguration; // Custom seat identifiers (e.g., ["A1", "A4", "B6"])
  final List<dynamic> bookedSeats; // Supports both int and String
  final List<dynamic> lockedSeats; // Supports both int and String
  final List<dynamic> selectedSeats; // Supports both int and String
  final bool walletGrantsAccess; // True when user can book via wallet even without counter access
  final Function(dynamic) onSeatTapped; // Accepts both int and String
  const _SeatMap({
    required this.bus,
    required this.totalSeats,
    this.seatConfiguration,
    required this.bookedSeats,
    required this.lockedSeats,
    required this.selectedSeats,
    this.walletGrantsAccess = false,
    required this.onSeatTapped,
  });
  
  // Build Lower Decker layout matching reference image exactly
  Widget _buildLowerDeckerLayout(
    BuildContext context,
    List<dynamic> seatIdentifiers,
    List<dynamic> bookedSeats,
    List<dynamic> lockedSeats,
    List<dynamic> selectedSeats,
    BusInfoEntity bus,
    double Function(dynamic) getSeatPrice,
    bool Function(dynamic, List<dynamic>) isSeatInList,
    void Function(dynamic) onSeatTapped,
  ) {
    // Separate seats by deck: Lower Decker and Upper Decker
    final lowerDeckerCabinSeats = <dynamic>[];
    final lowerDeckerASeats = <dynamic>[];
    final lowerDeckerBSeats = <dynamic>[];
    final lowerDeckerTailSeats = <dynamic>[];
    final upperDeckerSeats = <dynamic>[];
    
    for (final id in seatIdentifiers) {
      final s = id.toString().trim().toUpperCase();
      
      // Check for Upper Decker seats (typically U1, U2, U3, etc. or seats 16+)
      if (s.startsWith('U') && RegExp(r'^U\d+$').hasMatch(s)) {
        upperDeckerSeats.add(id);
      } else if (s == 'SP1' || s == 'J1' || s == 'J2' || 
          s == 'AKC' || s == 'AKHA' || s == 'AGG' || s == 'AGHA' ||
          s == 'BKC' || s == 'KHA' || s == 'BGC' || s == 'BGHA') {
        // Special cabin seats (Lower Decker)
        lowerDeckerCabinSeats.add(id);
      } else if (s.startsWith('A') && RegExp(r'^A\d+$').hasMatch(s)) {
        // Lower Decker A series
        lowerDeckerASeats.add(id);
      } else if (s.startsWith('B') && RegExp(r'^B\d+$').hasMatch(s)) {
        // Lower Decker B series
        lowerDeckerBSeats.add(id);
      } else if (s == '15') {
        // Tail seat (Lower Decker middle seat)
        lowerDeckerTailSeats.add(id);
      } else {
        // Other non-standard seats - check if numeric and > 15 for upper decker
        final numSeat = int.tryParse(s);
        if (numSeat != null && numSeat > 15) {
          upperDeckerSeats.add(id);
        } else {
          // Default to Lower Decker cabin
          lowerDeckerCabinSeats.add(id);
        }
      }
    }
    
    // Sort A and B seats numerically
    int sortKey(dynamic id) {
      final s = id.toString();
      final match = RegExp(r'\d+').firstMatch(s);
      return match != null ? int.tryParse(match.group(0) ?? '0') ?? 0 : 0;
    }
    lowerDeckerASeats.sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    lowerDeckerBSeats.sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    upperDeckerSeats.sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title: Lower Decker
        Padding(
          padding: const EdgeInsets.only(top: AppTheme.spacingS, bottom: AppTheme.spacingM),
          child: Text(
            'Lower Decker',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        // Build cabin row (special seats at top)
        if (lowerDeckerCabinSeats.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: lowerDeckerCabinSeats.map<Widget>((seatId) {
              final isBooked = isSeatInList(seatId, bookedSeats);
              final isLocked = isSeatInList(seatId, lockedSeats);
              final isSelected = isSeatInList(seatId, selectedSeats);
              final isSelectable = _seatSelectable(bus, seatId, isBooked, isLocked, walletGrantsAccess: walletGrantsAccess);
              return _SeatWidget(
                seatIdentifier: seatId,
                seatPrice: getSeatPrice(seatId),
                isBooked: isBooked,
                isLocked: isLocked,
                isSelected: isSelected,
                isNotAllowed: !isSelectable,
                onTap: (isBooked || isLocked || !isSelectable) ? null : () => onSeatTapped(seatId),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        // A (left) and B (right) columns with aisle - arranged in pairs
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildDeckerSeatColumn(
                  lowerDeckerASeats,
                  bookedSeats,
                  lockedSeats,
                  selectedSeats,
                  bus,
                  getSeatPrice,
                  isSeatInList,
                  onSeatTapped,
                  walletGrantsAccess: walletGrantsAccess,
                ),
              ),
            ),
            const SizedBox(width: 12), // Aisle
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildDeckerSeatColumn(
                  lowerDeckerBSeats,
                  bookedSeats,
                  lockedSeats,
                  selectedSeats,
                  bus,
                  getSeatPrice,
                  isSeatInList,
                  onSeatTapped,
                  walletGrantsAccess: walletGrantsAccess,
                ),
              ),
            ),
          ],
        ),
        // Tail seat "15" - single middle seat
        if (lowerDeckerTailSeats.isNotEmpty) ...[
          const SizedBox(height: 12),
          Center(
            child: lowerDeckerTailSeats.map<Widget>((seatId) {
              final isBooked = isSeatInList(seatId, bookedSeats);
              final isLocked = isSeatInList(seatId, lockedSeats);
              final isSelected = isSeatInList(seatId, selectedSeats);
              final isSelectable = _seatSelectable(bus, seatId, isBooked, isLocked, walletGrantsAccess: walletGrantsAccess);
              return _SeatWidget(
                seatIdentifier: seatId,
                seatPrice: getSeatPrice(seatId),
                isBooked: isBooked,
                isLocked: isLocked,
                isSelected: isSelected,
                isNotAllowed: !isSelectable,
                onTap: (isBooked || isLocked || !isSelectable) ? null : () => onSeatTapped(seatId),
              );
            }).toList().first,
          ),
        ],
        // Upper Decker section
        if (upperDeckerSeats.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingL),
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingM, bottom: AppTheme.spacingM),
            child: Text(
              'Upper Decker',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          // Upper Decker seats arranged in grid (2 columns)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: upperDeckerSeats.map<Widget>((seatId) {
              final isBooked = isSeatInList(seatId, bookedSeats);
              final isLocked = isSeatInList(seatId, lockedSeats);
              final isSelected = isSeatInList(seatId, selectedSeats);
              final isSelectable = _seatSelectable(bus, seatId, isBooked, isLocked, walletGrantsAccess: walletGrantsAccess);
              return SizedBox(
                width: 80,
                child: _SeatWidget(
                  seatIdentifier: seatId,
                  seatPrice: getSeatPrice(seatId),
                  isBooked: isBooked,
                  isLocked: isLocked,
                  isSelected: isSelected,
                  isNotAllowed: !isSelectable,
                  onTap: (isBooked || isLocked || !isSelectable) ? null : () => onSeatTapped(seatId),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use seatConfiguration if available, otherwise use sequential numbering
    List<dynamic> seatIdentifiers;
    if (seatConfiguration != null && seatConfiguration!.isNotEmpty) {
      seatIdentifiers = seatConfiguration!;
    } else {
      // Fallback to sequential numbering (1, 2, 3, ...)
      seatIdentifiers = List.generate(totalSeats, (index) => index + 1);
    }
    
    // Filter seats based on counter access permissions - only show allowed seats
    // Note: We show all allowed seats (even if booked/locked) but disable selection
    // This gives better UX - user can see what seats they have access to
    if (bus.hasRestrictedAccess == true) {
      // Counter has restricted access - only show allowed seats
      if (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty) {
        seatIdentifiers = seatIdentifiers.where((seatIdentifier) {
          // Convert seatIdentifier to int for comparison
          final seatNum = seatIdentifier is int 
              ? seatIdentifier 
              : (seatIdentifier is String && int.tryParse(seatIdentifier) != null)
                  ? int.parse(seatIdentifier)
                  : null;
          if (seatNum != null) {
            return bus.allowedSeats!.contains(seatNum);
          }
          // For string-based seat identifiers, check if it matches any allowed seat number
          return bus.allowedSeats!.any((allowed) => 
            allowed.toString() == seatIdentifier.toString()
          );
        }).toList();
      } else {
        // Restricted access but no allowed seats = no seats to show
        seatIdentifiers = [];
      }
    } else if (bus.hasNoAccess == true || bus.hasAccess == false) {
      // Counter has no access - show no seats unless wallet balance grants access
      if (!walletGrantsAccess) {
        seatIdentifiers = [];
      }
      // If walletGrantsAccess, keep seatIdentifiers (show all seats)
    } else if (bus.hasAccess == true && bus.requiresWallet != true) {
      // Counter has access - show all seats (no filtering needed)
      // seatIdentifiers remains unchanged
    } else {
      // Fallback: check allowedSeats if flag not available
      if (bus.allowedSeats != null) {
        if (bus.allowedSeats!.isEmpty) {
          // Empty list = no access
          seatIdentifiers = [];
        } else {
          // Filter to only show allowed seats
          seatIdentifiers = seatIdentifiers.where((seatIdentifier) {
            final seatNum = seatIdentifier is int 
                ? seatIdentifier 
                : (seatIdentifier is String && int.tryParse(seatIdentifier) != null)
                    ? int.parse(seatIdentifier)
                    : null;
            if (seatNum != null) {
              return bus.allowedSeats!.contains(seatNum);
            }
            return bus.allowedSeats!.any((allowed) => 
              allowed.toString() == seatIdentifier.toString()
            );
          }).toList();
        }
      }
    }
    
    // When using seatConfiguration (e.g. ["A1","A2","B1","B2"]), use Lower Decker layout
    final useLowerDeckerLayout = seatConfiguration != null && seatConfiguration!.isNotEmpty;
    
    // Fallback: seats per row for non-config layout
    final seatsPerRow = 4; // 2 seats on each side
    final rows = useLowerDeckerLayout ? 0 : (seatIdentifiers.length / seatsPerRow).ceil();
    
    // Helper to normalize seat IDs for comparison (handles int, String, num)
    // Converts everything to a consistent string format for comparison
    String normalizeSeatId(dynamic seatId) {
      if (seatId == null) return '';
      
      // Handle num types (int, double)
      if (seatId is num) {
        // For integers, return as int string (e.g., "1" not "1.0")
        if (seatId is int) return seatId.toString();
        // For doubles, check if it's a whole number
        if (seatId == seatId.roundToDouble()) {
          return seatId.toInt().toString();
        }
        return seatId.toString();
      }
      
      // Handle String types
      if (seatId is String) {
        // Try to parse as int to normalize (e.g., "1" vs 1)
        final parsed = int.tryParse(seatId.trim());
        if (parsed != null) return parsed.toString();
        // Return trimmed uppercase for case-insensitive comparison
        return seatId.trim().toUpperCase();
      }
      
      // Fallback: convert to string
      return seatId.toString().trim();
    }
    
    // Helper function to check if a seat is booked/locked/selected
    // Handles both int and String seat identifiers
    bool isSeatInList(dynamic seatId, List<dynamic> list) {
      if (list.isEmpty) return false;
      
      // Normalize seatId for comparison
      final normalizedSeatId = normalizeSeatId(seatId);
      
      return list.any((item) {
        final normalizedItem = normalizeSeatId(item);
        // Try multiple comparison methods
        return normalizedSeatId == normalizedItem ||
               normalizedSeatId.toString() == normalizedItem.toString() ||
               normalizedSeatId.toString().toLowerCase() == normalizedItem.toString().toLowerCase();
      });
    }

    // Helper function to get price for a specific seat
    // A13, A14, B13, B14, and seat "15" get रु.1600, others get रु.1800 (or bus base price)
    double getSeatPrice(dynamic seatId) {
      final seatStr = seatId.toString().toUpperCase();
      // Check for lower-priced seats (rear seats)
      if (seatStr == 'A13' || seatStr == 'A14' || 
          seatStr == 'B13' || seatStr == 'B14' || 
          seatStr == '15') {
        return 1600.0;
      }
      // Default price (or use bus base price if different)
      return bus.price > 0 ? bus.price : 1800.0;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.lightBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Front of bus: steering wheel icon (right-aligned like reference image)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.drive_eta_rounded, // Steering wheel icon
                size: 24,
                color: Colors.grey.shade600,
              ),
            ],
          ),
          if (useLowerDeckerLayout) 
            _buildLowerDeckerLayout(
              context,
              seatIdentifiers,
              bookedSeats,
              lockedSeats,
              selectedSeats,
              bus,
              getSeatPrice,
              isSeatInList,
              onSeatTapped,
            ),
          // Original grid layout when not using seatConfiguration
          if (!useLowerDeckerLayout && seatIdentifiers.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: AppTheme.textTertiary),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'No seats available for booking.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (bus.hasNoAccess == true)
                      Padding(
                        padding: const EdgeInsets.only(top: AppTheme.spacingS),
                        child: Text(
                          'You do not have access to book seats on this bus.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...List.generate(rows, (rowIndex) {
            final startIndex = rowIndex * seatsPerRow;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(seatsPerRow, (colIndex) {
                  final seatIndex = startIndex + colIndex;
                  if (seatIndex >= seatIdentifiers.length) {
                    return const SizedBox(width: 50, height: 50);
                  }
                  
                  final seatIdentifier = seatIdentifiers[seatIndex];
                  final isBooked = isSeatInList(seatIdentifier, bookedSeats);
                  final isLocked = isSeatInList(seatIdentifier, lockedSeats);
                  final isSelected = isSeatInList(seatIdentifier, selectedSeats);
                  
                  // Debug first few seats to verify comparison
                  if (seatIndex < 3) {
                    print('🔍 Seat Map Debug - Seat $seatIndex:');
                    print('   Seat Identifier: $seatIdentifier (type: ${seatIdentifier.runtimeType})');
                    print('   Normalized: ${normalizeSeatId(seatIdentifier)}');
                    print('   Is Booked: $isBooked');
                    print('   Is Locked: $isLocked');
                    print('   Booked Seats: $bookedSeats');
                    print('   Locked Seats: $lockedSeats');
                  }
                  
                  // Since we've already filtered seatIdentifiers to only include allowed seats,
                  // all seats shown here are allowed. However, we need to check if they're available for selection.
                  // Use availableAllowedSeats to determine if seat can be selected
                  bool isSeatSelectable = true;
                  
                  // Check if seat is in availableAllowedSeats (seats that are BOTH allowed AND available)
                  if (bus.hasRestrictedAccess == true && 
                      bus.availableAllowedSeats != null && 
                      bus.availableAllowedSeats!.isNotEmpty) {
                    // Only seats in availableAllowedSeats can be selected
                    final seatNum = seatIdentifier is int 
                        ? seatIdentifier 
                        : (seatIdentifier is String && int.tryParse(seatIdentifier) != null)
                            ? int.parse(seatIdentifier)
                            : null;
                    if (seatNum != null) {
                      isSeatSelectable = bus.availableAllowedSeats!.contains(seatNum);
                    } else {
                      isSeatSelectable = bus.availableAllowedSeats!.any((allowed) => 
                        allowed.toString() == seatIdentifier.toString()
                      );
                    }
                  } else if (bus.hasNoAccess == true || bus.hasAccess == false) {
                    isSeatSelectable = walletGrantsAccess && !isBooked && !isLocked;
                  } else if (bus.hasAccess == true && bus.requiresWallet != true) {
                    // Has access - seat is selectable if not booked/locked
                    isSeatSelectable = !isBooked && !isLocked;
                  } else {
                    // Fallback: check if seat is allowed (for backward compatibility)
                    bool isSeatAllowed = true;
                    if (bus.allowedSeats != null && bus.allowedSeats!.isNotEmpty) {
                      final seatNum = seatIdentifier is int 
                          ? seatIdentifier 
                          : (seatIdentifier is String && int.tryParse(seatIdentifier) != null)
                              ? int.parse(seatIdentifier)
                              : null;
                      if (seatNum != null) {
                        isSeatAllowed = bus.allowedSeats!.contains(seatNum);
                      } else {
                        isSeatAllowed = bus.allowedSeats!.any((allowed) => 
                          allowed.toString() == seatIdentifier.toString()
                        );
                      }
                    }
                    isSeatSelectable = isSeatAllowed && !isBooked && !isLocked;
                  }
                  
                  return _SeatWidget(
                    seatIdentifier: seatIdentifier,
                    isBooked: isBooked,
                    isLocked: isLocked,
                    isSelected: isSelected,
                    isNotAllowed: !isSeatSelectable, // Disable if not selectable
                    onTap: (isBooked || isLocked || !isSeatSelectable)
                        ? null 
                        : () => onSeatTapped(seatIdentifier),
                  );
                }),
              ),
            );
          }),
          ],
          // Back indicator (only for grid layout, not Lower Decker)
          if (!useLowerDeckerLayout && seatIdentifiers.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.airline_seat_recline_normal_rounded,
                    size: 20,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
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

class _SeatWidget extends StatelessWidget {
  final dynamic seatIdentifier; // Supports both int and String
  final double? seatPrice; // When set, show Lower Decker style (icon + label + price)
  final bool isBooked;
  final bool isLocked;
  final bool isSelected;
  final bool isNotAllowed; // Seat not in allowedSeats list
  final VoidCallback? onTap;

  const _SeatWidget({
    required this.seatIdentifier,
    this.seatPrice,
    required this.isBooked,
    required this.isLocked,
    required this.isSelected,
    this.isNotAllowed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showDeckerStyle = seatPrice != null;
    
    // Determine colors based on state - matching reference image exactly
    Color outlineColor;
    Color textColor;
    Color? backgroundColor;
    String statusText = '';
    
    if (isBooked) {
      // Sold seats: red/pinkish outline (like reference image)
      outlineColor = const Color(0xFFEF4444); // Red
      textColor = const Color(0xFF1A1A1A); // Black text
      backgroundColor = null; // No fill, just outline
      statusText = 'Sold';
    } else if (isNotAllowed) {
      outlineColor = AppTheme.textTertiary;
      textColor = AppTheme.textTertiary;
      backgroundColor = null;
      statusText = 'Blocked';
    } else if (isLocked) {
      outlineColor = AppTheme.warningColor;
      textColor = const Color(0xFF1A1A1A);
      backgroundColor = null;
      statusText = 'Locked';
    } else if (isSelected) {
      outlineColor = Theme.of(context).colorScheme.primary;
      textColor = const Color(0xFF1A1A1A);
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      statusText = 'Selected';
    } else {
      // Available seats: green outline (like reference image)
      outlineColor = const Color(0xFF10B981); // Green
      textColor = const Color(0xFF1A1A1A); // Black text
      backgroundColor = null; // No fill, just outline
      statusText = 'Available';
    }

    if (showDeckerStyle) {
      // Lower Decker style: green outline sofa icon, label, price (EXACTLY like reference image)
      return Tooltip(
        message: '$statusText - ${seatIdentifier.toString()}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: outlineColor,
                width: 2.5, // Thick outline like reference
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sofa/chair icon - rounded outline shape
                Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: outlineColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.airline_seat_recline_normal_rounded,
                    size: 18,
                    color: outlineColor,
                  ),
                ),
                const SizedBox(height: 4),
                // Seat label - bold black text
                Text(
                  seatIdentifier.toString(),
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A), // Black text
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                // Price below - smaller font
                if (seatPrice != null)
                  Text(
                    'रु.${NumberFormat('#,##0').format(seatPrice!.toInt())}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                // Show "Sold" status if booked
                if (isBooked)
                  Text(
                    'Sold',
                    style: TextStyle(
                      color: outlineColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Compact grid style (no price) - for non-decker layouts
    return Tooltip(
      message: '$statusText - Seat ${seatIdentifier.toString()}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: outlineColor,
              width: isSelected ? 2.5 : (isBooked || isLocked || isNotAllowed) ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              seatIdentifier.toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatLegend extends StatelessWidget {
  final bool hasRestrictedSeats;
  final VoidCallback onLockSeats;
  final VoidCallback onUnlockSeats;

  const _SeatLegend({
    this.hasRestrictedSeats = false,
    required this.onLockSeats,
    required this.onUnlockSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppTheme.spacingM,
      runSpacing: AppTheme.spacingS,
      children: [
        _LegendItem(
          color: Colors.white,
          label: 'Available',
        ),
        _LegendItem(
          color: AppTheme.errorColor,
          label: 'Booked',
          icon: Icons.block,
        ),
        _LegendItem(
          color: AppTheme.warningColor,
          label: 'Locked',
          icon: Icons.lock,
        ),
        if (hasRestrictedSeats)
          _LegendItem(
            color: AppTheme.lightBorderColor,
            label: 'Not Allowed',
            icon: Icons.block,
          ),
        _LegendItem(
          color: Theme.of(context).colorScheme.primary,
          label: 'Selected',
          icon: Icons.check,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;

  const _LegendItem({
    required this.color,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.lightBorderColor!),
          ),
          child: icon != null
              ? Icon(icon, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _LegendChip({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 1),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SeatStatusItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  const _SeatStatusItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PassengerInfoSection extends StatelessWidget {
  final TextEditingController passengerNameController;
  final TextEditingController contactNumberController;
  final TextEditingController passengerEmailController;
  final TextEditingController pickupLocationController;
  final TextEditingController dropoffLocationController;
  final TextEditingController luggageController;
  final int bagCount;
  final Function(int) onBagCountChanged;

  const _PassengerInfoSection({
    required this.passengerNameController,
    required this.contactNumberController,
    required this.passengerEmailController,
    required this.pickupLocationController,
    required this.dropoffLocationController,
    required this.luggageController,
    required this.bagCount,
    required this.onBagCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Passenger Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passengerNameController,
              decoration: InputDecoration(
                labelText: 'Passenger Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passenger name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: contactNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid contact number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passengerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ExpansionTile(
              title: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Additional Information (Optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              subtitle: Text(
                'Help us serve you better',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: pickupLocationController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Location',
                          helperText: 'Where will you board the bus?',
                          hintText: 'e.g., Bus Park, City Center',
                          prefixIcon: const Icon(Icons.place_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: dropoffLocationController,
                        decoration: InputDecoration(
                          labelText: 'Dropoff Location',
                          helperText: 'Where will you get off?',
                          hintText: 'e.g., Bus Park, City Center',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: luggageController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Luggage Description',
                          helperText: 'Describe your luggage for better handling',
                          hintText: 'e.g., 2 suitcases, 1 backpack',
                          prefixIcon: const Icon(Icons.luggage_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined, 
                  size: 20, 
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bag Count',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      Text(
                        'Optional (0-10 bags)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: bagCount > 0
                          ? () => onBagCountChanged(bagCount - 1)
                          : null,
                      color: bagCount > 0 
                          ? Theme.of(context).colorScheme.primary
                          : AppTheme.textTertiary,
                    ),
                    Container(
                      width: 50,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        bagCount.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: bagCount < 10
                          ? () => onBagCountChanged(bagCount + 1)
                          : null,
                      color: bagCount < 10
                          ? Theme.of(context).colorScheme.primary
                          : AppTheme.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;

  const _PaymentMethodSection({
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PaymentMethodOption(
                    icon: Icons.money,
                    label: 'Cash',
                    description: 'Pay at counter',
                    value: 'cash',
                    isSelected: selectedPaymentMethod == 'cash',
                    onTap: () => onPaymentMethodChanged('cash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PaymentMethodOption(
                    icon: Icons.payment,
                    label: 'Online',
                    description: 'eSewa / Khalti',
                    value: 'online',
                    isSelected: selectedPaymentMethod == 'online',
                    onTap: () => onPaymentMethodChanged('online'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.icon,
    required this.label,
    this.description,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : isDark
                  ? AppTheme.textPrimary
                  : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isDark
                    ? AppTheme.textSecondary!
                    : AppTheme.lightBorderColor!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : (value == 'cash' 
                      ? AppTheme.successColor  // Green for Cash
                      : AppTheme.statusInfo), // Blue for Online
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (value == 'cash' 
                            ? AppTheme.successColor  // Green for Cash
                            : AppTheme.statusInfo), // Blue for Online
                  ),
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.7)
                          : AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingSummarySection extends StatelessWidget {
  final BusInfoEntity bus;
  final List<dynamic> selectedSeats; // Supports both int (legacy) and String (new format)
  final String paymentMethod;
  final double walletBalance;

  const _BookingSummarySection({
    required this.bus,
    required this.selectedSeats,
    required this.paymentMethod,
    required this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = bus.price * selectedSeats.length;
    final hasInsufficientBalance = walletBalance < totalPrice;
    final remainingBalance = walletBalance - totalPrice;
    
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Booking Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(label: 'Seats', value: selectedSeats.join(', ')),
            _SummaryRow(label: 'Seats Count', value: '${selectedSeats.length}'),
            _SummaryRow(label: 'Price per Seat', value: 'Rs. ${NumberFormat('#,##0').format(bus.price)}'),
            const Divider(),
            _SummaryRow(
              label: 'Total Amount',
              value: 'Rs. ${NumberFormat('#,##0').format(totalPrice)}',
              isTotal: true,
            ),
            const SizedBox(height: 12),
            // Wallet Balance Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasInsufficientBalance 
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasInsufficientBalance 
                      ? AppTheme.errorColor.withOpacity(0.3)
                      : AppTheme.successColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 18,
                        color: hasInsufficientBalance 
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Wallet Balance',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: hasInsufficientBalance 
                                  ? AppTheme.errorColor
                                  : AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Balance',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      Text(
                        'Rs. ${NumberFormat('#,##0.00').format(walletBalance)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: hasInsufficientBalance 
                                  ? AppTheme.errorColor
                                  : AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Required Amount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      Text(
                        'Rs. ${NumberFormat('#,##0.00').format(totalPrice)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  if (!hasInsufficientBalance) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining Balance',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'Rs. ${NumberFormat('#,##0.00').format(remainingBalance)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Insufficient balance. Add Rs. ${NumberFormat('#,##0.00').format(totalPrice - walletBalance)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.payment, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Payment: ${paymentMethod.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (hasInsufficientBalance) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/wallet'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Money to Wallet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: BorderSide(color: AppTheme.errorColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? Theme.of(context).colorScheme.primary : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _SelectedBusAndSeatsSummary extends StatelessWidget {
  final BusInfoEntity bus;
  final List<dynamic> selectedSeats; // Supports both int (legacy) and String (new format)

  const _SelectedBusAndSeatsSummary({
    required this.bus,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Bus & Seats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review your selection',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            // Bus Information
            Row(
              children: [
                Icon(Icons.directions_bus, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bus.from} → ${bus.to}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${bus.time}${bus.arrival != null ? ' - ${bus.arrival}' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.event, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              DateFormat('MMM d, y').format(bus.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            // Selected Seats
            Row(
              children: [
                Icon(Icons.event_seat, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Seats',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedSeats.map((seatNumber) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_seat,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  seatNumber.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''} selected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Rs. ${NumberFormat('#,##0').format(bus.price * selectedSeats.length)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
