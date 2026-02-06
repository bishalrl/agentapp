import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/events/auth_event.dart' as auth;
import '../../features/authentication/presentation/bloc/states/auth_state.dart';

/// Redesigned navigation drawer with user header, grouped items, and improved styling.
class MainDrawer extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final double? walletBalance;
  final int? pendingRequestsCount;

  const MainDrawer({
    super.key,
    this.userName,
    this.userEmail,
    this.walletBalance,
    this.pendingRequestsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = userName ?? 'Tejbi Agent';
    final displayEmail = userEmail ?? 'agent@tejbi.com';
    final displayBalance = walletBalance ?? 0.0;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated == false && state.isLoading == false) {
          // Navigate to login after successful logout
          Navigator.of(context).pop(); // Close drawer if open
          context.go('/login');
        }
      },
      child: Drawer(
      child: Column(
        children: [
          // User Profile Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
              bottom: AppTheme.spacingL,
              left: AppTheme.spacingL,
              right: AppTheme.spacingL,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  displayEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        '₹${NumberFormat('#,##0').format(displayBalance)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pendingRequestsCount != null && pendingRequestsCount! > 0) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pending_actions,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                        Text(
                          '$pendingRequestsCount Pending',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Main Section
                _DrawerSectionHeader(title: 'Main'),
                _DrawerTile(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    context.go('/dashboard');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.event_note,
                  title: 'Bookings',
                  onTap: () {
                    context.go('/bookings');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.directions_bus,
                  title: 'Buses',
                  onTap: () {
                    context.go('/buses');
                    Navigator.of(context).pop();
                  },
                ),

                const Divider(height: AppTheme.spacingXL),

                // Requests Section
                _DrawerSectionHeader(title: 'Requests'),
                _DrawerTile(
                  icon: Icons.request_quote,
                  title: 'Request Bus Access',
                  badgeCount: pendingRequestsCount,
                  onTap: () {
                    context.go('/counter/request-bus-access');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.list_alt,
                  title: 'My Requests',
                  badgeCount: pendingRequestsCount,
                  onTap: () {
                    context.go('/counter/requests');
                    Navigator.of(context).pop();
                  },
                ),

                const Divider(height: AppTheme.spacingXL),

                // Management Section
                _DrawerSectionHeader(title: 'Management'),
                _DrawerTile(
                  icon: Icons.route,
                  title: 'Routes',
                  onTap: () {
                    context.go('/routes');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.schedule,
                  title: 'Schedules',
                  onTap: () {
                    context.go('/schedules');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.person,
                  title: 'Drivers',
                  onTap: () {
                    context.go('/drivers');
                    Navigator.of(context).pop();
                  },
                ),

                const Divider(height: AppTheme.spacingXL),

                // Financial Section
                _DrawerSectionHeader(title: 'Financial'),
                _DrawerTile(
                  icon: Icons.account_balance_wallet,
                  title: 'Wallet',
                  onTap: () {
                    context.go('/wallet');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.bar_chart,
                  title: 'Sales & Reports',
                  onTap: () {
                    context.go('/sales');
                    Navigator.of(context).pop();
                  },
                ),

                const Divider(height: AppTheme.spacingXL),

                // Other Section
                _DrawerSectionHeader(title: 'Other'),
                _DrawerTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    context.go('/notifications');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.cloud_off,
                  title: 'Offline Queue',
                  onTap: () {
                    context.go('/offline');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.history,
                  title: 'Audit Logs',
                  onTap: () {
                    context.go('/audit-logs');
                    Navigator.of(context).pop();
                  },
                ),

                const Divider(height: AppTheme.spacingXL),

                // Settings Section
                _DrawerSectionHeader(title: 'Settings'),
                _DrawerTile(
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    context.go('/profile');
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.read<AuthBloc>().add(const auth.LogoutEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
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

class _DrawerSectionHeader extends StatelessWidget {
  final String title;

  const _DrawerSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingM,
        AppTheme.spacingL,
        AppTheme.spacingS,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool isDestructive;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badgeCount,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive
        ? AppTheme.errorColor
        : Theme.of(context).iconTheme.color;

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  badgeCount! > 9 ? '9+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.errorColor : null,
          fontWeight: isDestructive ? FontWeight.w600 : null,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
    );
  }
}
