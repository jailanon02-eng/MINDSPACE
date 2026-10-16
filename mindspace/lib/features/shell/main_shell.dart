import 'package:flutter/material.dart';
import '../../all.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: currentTab,
        builder: (_, i, __) => Scaffold(
          body: SafeArea(
            child: IndexedStack(index: i, children: const [HomeTab(), AppointmentsTab(), ResourcesTab(), ProfileTab()]),
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: i,
            onDestinationSelected: (v) => currentTab.value = v,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Appointments'),
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Resources'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      );
}
