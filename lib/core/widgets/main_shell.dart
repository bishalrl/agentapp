import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'back_button_handler.dart';
import '../theme/app_theme.dart';

/// Main shell widget that provides persistent bottom navigation bar
/// for the main app tabs (Dashboard, Bookings, Buses, Profile)
/// Enhanced with badge indicators and haptic feedback.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final int? bookingsBadgeCount;
  final int? busesBadgeCount;
  final int? profileBadgeCount;

  const MainShell({
    super.key,
    required this.navigationShell,
    this.bookingsBadgeCount,
    this.busesBadgeCount,
    this.profileBadgeCount,
  });

  Widget _buildBadge(Widget icon, int? count) {
    if (count == null || count == 0) {
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppTheme.errorColor,
              shape: BoxShape.circle,
            ),
            constraints: BoxConstraints(
              minWidth: count > 9 ? 18 : 16,
              minHeight: count > 9 ? 18 : 16,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExitOnDoubleBack(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              height: 70,
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.accentColor.withOpacity(0.1),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 200),
              onDestinationSelected: (index) {
                HapticFeedback.selectionClick();
                navigationShell.goBranch(
                  index,
                  // When the user taps on a destination, we want to navigate
                  // to that destination, but we don't want to reset the navigation
                  // stack if the user is already on that destination.
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: [
                NavigationDestination(
                  icon: _buildBadge(
                    Icon(
                      Icons.dashboard_outlined,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                    null,
                  ),
                  selectedIcon: _buildBadge(
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.dashboard,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                    ),
                    null,
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: _buildBadge(
                    Icon(
                      Icons.event_note_outlined,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                    bookingsBadgeCount,
                  ),
                  selectedIcon: _buildBadge(
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.event_note,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                    ),
                    bookingsBadgeCount,
                  ),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: _buildBadge(
                    Icon(
                      Icons.directions_bus_outlined,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                    busesBadgeCount,
                  ),
                  selectedIcon: _buildBadge(
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.directions_bus,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                    ),
                    busesBadgeCount,
                  ),
                  label: 'Buses',
                ),
                NavigationDestination(
                  icon: _buildBadge(
                    Icon(
                      Icons.person_outline,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                    profileBadgeCount,
                  ),
                  selectedIcon: _buildBadge(
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                    ),
                    profileBadgeCount,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
