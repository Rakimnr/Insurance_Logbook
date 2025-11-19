import 'package:flutter/material.dart';
import 'features/customers/presentation/customer_debug_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // 0: Dashboard, 1: Customers, 2: Leads, 3: Birthdays, 4: Analytics, 5: Settings
  int _selectedIndex = 1; // start on Customers for now

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Customers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.call_outlined),
                selectedIcon: Icon(Icons.call),
                label: Text('Leads'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.cake_outlined),
                selectedIcon: Icon(Icons.cake),
                label: Text('Birthdays'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const Center(child: Text('Dashboard (coming soon)'));
      case 1:
        return const CustomerDebugScreen(); // your existing screen
      case 2:
        return const Center(child: Text('Leads (coming soon)'));
      case 3:
        return const Center(child: Text('Upcoming Birthdays (coming soon)'));
      case 4:
        return const Center(child: Text('Analytics (coming soon)'));
      case 5:
        return const Center(child: Text('Settings (coming soon)'));
      default:
        return const SizedBox.shrink();
    }
  }
}
