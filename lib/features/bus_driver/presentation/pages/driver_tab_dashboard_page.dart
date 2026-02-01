import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/animations/scroll_animations.dart';
import '../../../../core/animations/dialog_animations.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/events/driver_event.dart';
import '../bloc/states/driver_state.dart';
import 'driver_ride_tab.dart';
import 'driver_booking_tab.dart';
import 'driver_scan_tab.dart';
import 'driver_profile_tab.dart';

class DriverTabDashboardPage extends StatefulWidget {
  const DriverTabDashboardPage({super.key});

  @override
  State<DriverTabDashboardPage> createState() => _DriverTabDashboardPageState();
}

class _DriverTabDashboardPageState extends State<DriverTabDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DriverRideTab(),
    const DriverBookingTab(),
    const DriverScanTab(),
    const DriverProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<DriverBloc>();
        // Initial load: dashboard, assigned buses, and pending requests
        bloc.add(const GetDriverDashboardEvent());
        bloc.add(const GetAssignedBusesEvent());
        bloc.add(const GetPendingRequestsEvent());
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final bloc = context.read<DriverBloc>();
                // Reload dashboard, assigned buses and pending requests
                bloc.add(const GetDriverDashboardEvent());
                bloc.add(const GetAssignedBusesEvent());
                bloc.add(const GetPendingRequestsEvent());
              },
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.go('/driver/login');
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: BlocConsumer<DriverBloc, DriverState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: IndexedStack(
                key: ValueKey<int>(_currentIndex),
                index: _currentIndex,
                children: _tabs,
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus),
              label: 'Ride',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_seat),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Ride';
      case 1:
        return 'Booking';
      case 2:
        return 'Scan Tickets';
      case 3:
        return 'Profile';
      default:
        return 'Driver Dashboard';
    }
  }
}
