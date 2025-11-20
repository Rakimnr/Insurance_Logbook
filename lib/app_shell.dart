import 'package:flutter/material.dart';
import 'features/customers/presentation/customer_debug_screen.dart';
import 'features/leads/presentation/leads_page.dart';
import 'features/dashboard/presentation/dashboard_page.dart';
import 'features/birthdays/presentation/birthdays_page.dart';
import 'features/analytics/presentation/analytics_page.dart';
import 'features/settings/presentation/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // 0: Dashboard, 1: Customers, 2: Leads, 3: Birthdays, 4: Analytics, 5: Settings
  int _selectedIndex = 0; // now we can start on Dashboard if you like

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
        return const DashboardPage();
      case 1:
        return const CustomerDebugScreen();
      case 2:
        return const LeadsPage();
      case 3:
        return const BirthdaysPage();
      case 4:
        return const AnalyticsPage();
      case 5:
        return const SettingsPage();
      default:
        return const SizedBox.shrink();
    }
  }
}
