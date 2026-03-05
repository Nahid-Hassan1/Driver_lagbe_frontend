import 'package:flutter/material.dart';

import 'tabs/rider_account_tab.dart';
import 'tabs/rider_activity_tab.dart';
import 'tabs/rider_home_tab.dart';
import 'tabs/rider_services_tab.dart';

class RiderMainShellPage extends StatefulWidget {
  const RiderMainShellPage({super.key});

  @override
  State<RiderMainShellPage> createState() => _RiderMainShellPageState();
}

class _RiderMainShellPageState extends State<RiderMainShellPage> {
  int _currentIndex = 0;

  void _goToServicesTab() {
    setState(() => _currentIndex = 1);
  }

  void _goToAccountTab() {
    setState(() => _currentIndex = 3);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      RiderHomeTab(
        onParcelTap: _goToServicesTab,
        onAccountTap: _goToAccountTab,
      ),
      const RiderServicesTab(),
      const RiderActivityTab(),
      const RiderAccountTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1B1B1B))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0D0D0D),
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFF8A8A8A),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
