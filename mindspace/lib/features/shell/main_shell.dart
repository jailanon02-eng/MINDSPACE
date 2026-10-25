import 'package:flutter/material.dart';
import '../../all.dart';


class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: currentTab,
        builder: (_, i, __) => Scaffold(
          body: SafeArea(
            child: Column(children: [
              StreamBuilder<UserProfile?>(
                stream: DbService.profile(),
                builder: (_, s) {
                  final p = s.data;
                  if (p == null || !p.restricted) return const SizedBox.shrink();
                  final pending = p.consentStatus == 'pending';
                  return Material(
                    color: const Color(0xFFFFF3D6),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.family_restroom, color: Color(0xFFB57A00)),
                      title: Text(pending ? 'Consent form under review' : 'Parental consent needed to unlock all features',
                          style: const TextStyle(fontSize: 13)),
                      trailing: pending ? null : TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsentScreen())),
                          child: const Text('Upload')),
                    ),
                  );
                },
              ),
              Expanded(child: IndexedStack(index: i, children: const [HomeTab(), ActivitiesTab(), AppointmentsTab(), ProfileTab()])),
            ]),
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white, indicatorColor: kPrimary.withOpacity(.15),
            selectedIndex: i, onDestinationSelected: (v) => currentTab.value = v,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: kPrimary), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer, color: kPrimary), label: 'Take 5'),
              NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today, color: kPrimary), label: 'Sessions'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: kPrimary), label: 'Profile'),
            ],
          ),
        ),
      );
}
