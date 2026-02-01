import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared navigation drawer for main app pages
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.business,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Neelo Sewa Agent',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          _DrawerTile(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              context.go('/dashboard');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.event_note,
            title: 'Bookings',
            onTap: () {
              context.go('/bookings');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.directions_bus,
            title: 'Buses',
            onTap: () {
              context.go('/buses');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.request_quote,
            title: 'Request Bus Access',
            onTap: () {
              context.go('/counter/request-bus-access');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.list_alt,
            title: 'My Requests',
            onTap: () {
              context.go('/counter/requests');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.route,
            title: 'Routes',
            onTap: () {
              context.go('/routes');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.schedule,
            title: 'Schedules',
            onTap: () {
              context.go('/schedules');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.person,
            title: 'Drivers',
            onTap: () {
              context.go('/drivers');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.account_balance_wallet,
            title: 'Wallet',
            onTap: () {
              context.go('/wallet');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.bar_chart,
            title: 'Sales & Reports',
            onTap: () {
              context.go('/sales');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              context.go('/notifications');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.cloud_off,
            title: 'Offline Queue',
            onTap: () {
              context.go('/offline');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.history,
            title: 'Audit Logs',
            onTap: () {
              context.go('/audit-logs');
              context.pop();
            },
          ),
          const Divider(),
          _DrawerTile(
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              context.go('/profile');
              context.pop();
            },
          ),
          _DrawerTile(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              context.go('/login');
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
