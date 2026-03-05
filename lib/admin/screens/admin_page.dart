import 'package:flutter/material.dart';

import 'analytics_screen.dart';
import 'booking_management_screen.dart';
import 'content_management_screen.dart';
import 'financial_dashboard_screen.dart';
import 'system_settings_screen.dart';
import 'user_management_screen.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: Icon(Icons.supervisor_account_outlined),
                text: 'User Management',
              ),
              Tab(
                icon: Icon(Icons.assignment_outlined),
                text: 'Booking Management',
              ),
              Tab(
                icon: Icon(Icons.account_balance_wallet_outlined),
                text: 'Financial Dashboard',
              ),
              Tab(
                icon: Icon(Icons.analytics_outlined),
                text: 'Analytics',
              ),
              Tab(
                icon: Icon(Icons.campaign_outlined),
                text: 'Content Management',
              ),
              Tab(
                icon: Icon(Icons.settings_outlined),
                text: 'System Settings',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UserManagementScreen(),
            BookingManagementScreen(),
            FinancialDashboardScreen(),
            AnalyticsScreen(),
            ContentManagementScreen(),
            SystemSettingsScreen(),
          ],
        ),
      ),
    );
  }
}
