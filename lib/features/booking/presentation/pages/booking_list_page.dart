import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/events/booking_event.dart';
import '../bloc/states/booking_state.dart';
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/widgets/main_drawer.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/animations/dialog_animations.dart';
import '../../domain/entities/booking_entity.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  String? _selectedDateFilter; // 'today', 'yesterday', 'all', or custom date string
  bool _hasLoadedInitialData = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _selectedDateFilter = 'all';
  }
  
  @override
  void dispose() {
    _isInitializing = false;
    super.dispose();
  }

  String? _getDateForFilter() {
    // For "today" and "yesterday", we filter on frontend by createdAt
    // For custom dates, we can use backend filtering
    // For "all", no filter
    switch (_selectedDateFilter) {
      case 'today':
      case 'yesterday':
      case 'all':
        return null; // Fetch all, filter on frontend
      default:
        // Custom date string (YYYY-MM-DD format) - use backend filter
        return _selectedDateFilter;
    }
  }

  List<BookingEntity> _filterBookingsByDate(List<BookingEntity> bookings) {
    if (_selectedDateFilter == 'all') {
      return bookings;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return bookings.where((booking) {
      final bookingDate = DateTime(
        booking.createdAt.year,
        booking.createdAt.month,
        booking.createdAt.day,
      );

      if (_selectedDateFilter == 'today') {
        return bookingDate == today;
      } else if (_selectedDateFilter == 'yesterday') {
        return bookingDate == yesterday;
      } else if (_selectedDateFilter != null && _selectedDateFilter != 'all') {
        // Custom date filter
        try {
          final filterDate = DateFormat('yyyy-MM-dd').parse(_selectedDateFilter!);
          final filterDateOnly = DateTime(filterDate.year, filterDate.month, filterDate.day);
          return bookingDate == filterDateOnly;
        } catch (e) {
          return true; // If date parsing fails, show all
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Try to read BookingBloc from context, if not available create new one
    BookingBloc? bookingBloc;
    try {
      bookingBloc = context.read<BookingBloc>();
    } catch (e) {
      // BLoC not in context, will create new one
      bookingBloc = di.sl<BookingBloc>();
    }
    
    // Trigger the event to load bookings only once on initial load
    // Only load if bookings are empty (not already loaded)
    if (!_hasLoadedInitialData && _isInitializing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Check if bookings are already loaded before making API call
        final currentState = bookingBloc!.state;
        if (currentState.bookings.isEmpty && !currentState.isLoading) {
          _hasLoadedInitialData = true;
          _isInitializing = false;
          bookingBloc.add(GetBookingsEvent(date: _getDateForFilter()));
        } else {
          // Bookings already loaded or loading, just mark as loaded
          _hasLoadedInitialData = true;
          _isInitializing = false;
        }
      });
    }
    
    return BlocProvider.value(
      value: bookingBloc,
      child: BackButtonHandler(
        enableDoubleBackToExit: false, // Allow normal back navigation
        child: Scaffold(
        drawer: const MainDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold?.hasDrawer == true) scaffold!.openDrawer();
            },
          ),
          title: const Text('Bookings'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh from API (fetch all, then filter on frontend)
                context.read<BookingBloc>().add(const GetBookingsEvent());
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightBorderColor,
                    width: 1,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _selectedDateFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedDateFilter = 'all';
                        });
                        // Reload bookings if empty to ensure we have data
                        if (context.read<BookingBloc>().state.bookings.isEmpty) {
                          context.read<BookingBloc>().add(const GetBookingsEvent());
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Today',
                      selected: _selectedDateFilter == 'today',
                      onTap: () {
                        setState(() {
                          _selectedDateFilter = 'today';
                        });
                        // Reload bookings if empty to ensure we have data
                        if (context.read<BookingBloc>().state.bookings.isEmpty) {
                          context.read<BookingBloc>().add(const GetBookingsEvent());
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Yesterday',
                      selected: _selectedDateFilter == 'yesterday',
                      onTap: () {
                        setState(() {
                          _selectedDateFilter = 'yesterday';
                        });
                        // Reload bookings if empty to ensure we have data
                        if (context.read<BookingBloc>().state.bookings.isEmpty) {
                          context.read<BookingBloc>().add(const GetBookingsEvent());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              // Check if it's an authentication error
              final isAuthError = state.errorMessage!.toLowerCase().contains('authentication') ||
                                  state.errorMessage!.toLowerCase().contains('token') ||
                                  state.errorMessage!.toLowerCase().contains('login');
              
              ScaffoldMessenger.of(context).showSnackBar(
                ErrorSnackBar(
                  message: state.errorMessage!,
                  errorSource: 'Booking',
                  errorType: isAuthError ? 'Authentication Error' : 'Error',
                ),
              );
              
              // Navigate to login if authentication error
              if (isAuthError) {
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    context.go('/login');
                  }
                });
              }
            }
          },
          builder: (context, state) {
            // Only show loading if bookings are empty (initial load)
            // If bookings exist, show them even if loading (for better UX)
            if (state.isLoading && state.bookings.isEmpty) {
              return const SkeletonList(itemCount: 6, itemHeight: 88);
            }

            if (state.errorMessage != null) {
              return ErrorStateWidget(
                message: state.errorMessage!,
                onRetry: () => context.read<BookingBloc>().add(GetBookingsEvent(date: _getDateForFilter())),
              );
            }

            if (state.bookings.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.event_busy,
                title: 'No bookings found',
                description: 'Create your first booking to get started.',
              );
            }

            // Filter bookings by selected date (if filtering by today/yesterday)
            final filteredBookings = _filterBookingsByDate(state.bookings);
            
            if (filteredBookings.isEmpty && state.bookings.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.event_busy,
                title: 'No bookings found',
                description: 'Create your first booking to get started.',
              );
            }
            
            if (filteredBookings.isEmpty && state.bookings.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_alt_off,
                      size: 80,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookings match the filter',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedDateFilter == 'today'
                          ? 'No bookings created today'
                          : _selectedDateFilter == 'yesterday'
                              ? 'No bookings created yesterday'
                              : 'Try adjusting your filters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }
            
            // Group bookings by date
            final groupedBookings = _groupBookingsByDate(filteredBookings);
            
            return RefreshIndicator(
              onRefresh: () async {
                // Refresh from API
                context.read<BookingBloc>().add(const GetBookingsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                physics: const BouncingScrollPhysics(),
                itemCount: groupedBookings.length,
                itemBuilder: (context, index) {
                  final dateGroup = groupedBookings[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Date Header
                      Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : AppTheme.spacingL,
                          bottom: AppTheme.spacingM,
                          left: AppTheme.spacingS,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: AppTheme.spacingXS),
                            Text(
                              dateGroup['label'] as String,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: 14,
                                  ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${dateGroup['bookings'].length}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bookings for this date
                      ...(dateGroup['bookings'] as List<BookingEntity>).map((booking) {
                        return _BookingCard(
                          booking: booking,
                          onTap: () {
                            context.go('/bookings/${booking.id}');
                          },
                        );
                      }).toList(),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'booking_list_fab', // Unique tag to avoid Hero widget conflicts
          onPressed: () {
            context.go('/bookings/create');
          },
          icon: const Icon(Icons.add),
          label: const Text('New Booking'),
        ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupBookingsByDate(List<BookingEntity> bookings) {
    final Map<String, List<BookingEntity>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final booking in bookings) {
      final bookingDate = DateTime(
        booking.createdAt.year,
        booking.createdAt.month,
        booking.createdAt.day,
      );

      String dateKey;

      if (bookingDate == today) {
        dateKey = 'today';
      } else if (bookingDate == yesterday) {
        dateKey = 'yesterday';
      } else {
        dateKey = DateFormat('yyyy-MM-dd').format(bookingDate);
      }

      grouped.putIfAbsent(dateKey, () => []).add(booking);
    }

    // Sort bookings within each group by creation time (newest first)
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // Convert to list and sort by date (today first, then yesterday, then others)
    final sortedGroups = grouped.entries.map((entry) {
      return {
        'key': entry.key,
        'label': _getDateLabel(entry.key, now),
        'bookings': entry.value,
        'date': entry.value.first.createdAt,
      };
    }).toList();

    sortedGroups.sort((a, b) {
      final aKey = a['key'] as String;
      final bKey = b['key'] as String;
      
      // Today first
      if (aKey == 'today') return -1;
      if (bKey == 'today') return 1;
      
      // Yesterday second
      if (aKey == 'yesterday') return -1;
      if (bKey == 'yesterday') return 1;
      
      // Then by date (newest first)
      return (b['date'] as DateTime).compareTo(a['date'] as DateTime);
    });

    return sortedGroups;
  }

  String _getDateLabel(String dateKey, DateTime now) {
    if (dateKey == 'today') {
      return 'Today';
    } else if (dateKey == 'yesterday') {
      return 'Yesterday';
    } else {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(dateKey);
        return DateFormat('MMM d, y').format(date);
      } catch (e) {
        return dateKey;
      }
    }
  }

  void _showFilterDialog(BuildContext context) {
    final statusController = TextEditingController();
    final paymentMethodController = TextEditingController();
    String? tempDateFilter = _selectedDateFilter;
    DateTime? selectedCustomDate;

    DialogAnimations.showAnimatedBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    Text(
                      'Filter Bookings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Date Filter Section
                    Text(
                      'Date',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DialogFilterChip(
                      label: 'All',
                      selected: tempDateFilter == 'all',
                      onTap: () {
                        setDialogState(() {
                          tempDateFilter = 'all';
                          selectedCustomDate = null;
                        });
                      },
                    ),
                    _DialogFilterChip(
                      label: 'Today',
                      selected: tempDateFilter == 'today',
                      onTap: () {
                        setDialogState(() {
                          tempDateFilter = 'today';
                          selectedCustomDate = null;
                        });
                      },
                    ),
                    _DialogFilterChip(
                      label: 'Yesterday',
                      selected: tempDateFilter == 'yesterday',
                      onTap: () {
                        setDialogState(() {
                          tempDateFilter = 'yesterday';
                          selectedCustomDate = null;
                        });
                      },
                    ),
                    _DialogFilterChip(
                      label: 'Custom',
                      selected: tempDateFilter != null &&
                          tempDateFilter != 'all' &&
                          tempDateFilter != 'today' &&
                          tempDateFilter != 'yesterday',
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedCustomDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedCustomDate = pickedDate;
                            tempDateFilter = DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                    ),
                  ],
                ),
                    if (tempDateFilter != null &&
                        tempDateFilter != 'all' &&
                        tempDateFilter != 'today' &&
                        tempDateFilter != 'yesterday' &&
                        selectedCustomDate != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM d, y').format(selectedCustomDate!),
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Status Filter
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: statusController,
                      decoration: InputDecoration(
                        hintText: 'e.g., confirmed, cancelled, pending',
                        prefixIcon: const Icon(Icons.filter_alt),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Payment Method Filter
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: paymentMethodController,
                      decoration: InputDecoration(
                        hintText: 'e.g., cash, online',
                        prefixIcon: const Icon(Icons.payment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedDateFilter = 'all';
                              });
                              Navigator.pop(context);
                              // Only refresh if status or payment method filters are applied
                              if (statusController.text.isNotEmpty || paymentMethodController.text.isNotEmpty) {
                                context.read<BookingBloc>().add(const GetBookingsEvent());
                              }
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              final hasStatusFilter = statusController.text.isNotEmpty;
                              final hasPaymentFilter = paymentMethodController.text.isNotEmpty;
                              final isCustomDate = tempDateFilter != null &&
                                  tempDateFilter != 'all' &&
                                  tempDateFilter != 'today' &&
                                  tempDateFilter != 'yesterday';
                              
                              setState(() {
                                _selectedDateFilter = tempDateFilter;
                              });
                              Navigator.pop(context);
                              
                              // Only make API call if status/payment filters or custom date is selected
                              // For today/yesterday/all, we filter on frontend
                              if (hasStatusFilter || hasPaymentFilter || isCustomDate) {
                                context.read<BookingBloc>().add(
                                      GetBookingsEvent(
                                        date: isCustomDate ? tempDateFilter : null,
                                        status: hasStatusFilter ? statusController.text : null,
                                        paymentMethod: hasPaymentFilter ? paymentMethodController.text : null,
                                      ),
                                    );
                              }
                            },
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      case 'pending':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'CONFIRMED';
      case 'cancelled':
        return 'CANCELLED';
      case 'pending':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);
    final statusLabel = _getStatusLabel(booking.status);
    final timeAgo = _getTimeAgo(booking.createdAt);

    return EnhancedCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      onTap: onTap,
      elevation: CardElevation.raised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner at Top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusM),
                topRight: Radius.circular(AppTheme.radiusM),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  statusLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  booking.ticketNumber,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Passenger Name - LARGE and PROMINENT
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passenger Name',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.passengerName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Route - Clear and Prominent
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: AppTheme.lightBorderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${booking.bus.from} → ${booking.bus.to}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Key Info Grid - Seats, Amount, Payment
                Row(
                  children: [
                    // Seats
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: AppTheme.statusInfo.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event_seat,
                                  size: 16,
                                  color: AppTheme.statusInfo,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Seats',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.seatNumbers.map((s) => s.toString()).join(', '),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${booking.seatNumbers.length} ${booking.seatNumbers.length == 1 ? 'seat' : 'seats'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    // Amount - MOST PROMINENT
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.successColor.withOpacity(0.1),
                              AppTheme.successColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          border: Border.all(
                            color: AppTheme.successColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.currency_rupee,
                                  size: 16,
                                  color: AppTheme.successColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Total Amount',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs. ${NumberFormat('#,##0').format(booking.totalPrice)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '${booking.seatNumbers.length} × Rs. ${NumberFormat('#,##0').format(booking.bus.price)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Payment Method & Contact Info Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              booking.paymentMethod.toLowerCase() == 'cash'
                                  ? Icons.money
                                  : Icons.payment,
                              size: 16,
                              color: booking.paymentMethod.toLowerCase() == 'cash'
                                  ? AppTheme.successColor
                                  : AppTheme.statusInfo,
                            ),
                            const SizedBox(width: AppTheme.spacingXS),
                            Text(
                              'Payment: ${booking.paymentMethod.toUpperCase()}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    if (booking.contactNumber.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: AppTheme.spacingXS),
                            Text(
                              booking.contactNumber,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Luggage Info (if exists)
                if (booking.luggage != null || (booking.bagCount != null && booking.bagCount! > 0)) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: AppTheme.warningColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.luggage,
                          size: 20,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (booking.bagCount != null && booking.bagCount! > 0)
                                Text(
                                  '${booking.bagCount} bag${booking.bagCount! > 1 ? 's' : ''}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (booking.luggage != null) ...[
                                if (booking.bagCount != null && booking.bagCount! > 0)
                                  const SizedBox(height: 4),
                                Text(
                                  booking.luggage!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Booking Time
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                    Text(
                      'Booked $timeAgo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      DateFormat('MMM d, h:mm a').format(booking.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accentColor.withOpacity(0.1)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.accentColor
                : AppTheme.lightBorderColor,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accentColor : AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DialogFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DialogFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accentColor.withOpacity(0.1)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.accentColor
                : AppTheme.lightBorderColor,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accentColor : AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

