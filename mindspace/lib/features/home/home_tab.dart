import 'package:flutter/material.dart';
import '../../all.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  Widget _card(BuildContext c, String t, String s, IconData i, Color bg, Color fg, VoidCallback f) => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: f,
        child: Container(
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(i, size: 38, color: fg),
            const SizedBox(height: 8),
            Text(t, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
            Text(s, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: fg)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    void mood() => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen()));
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        const Expanded(child: Text('Hello, User! 👋', style: kTitle)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
      ]),
      const Text("Take a deep breath. You're doing great.", style: TextStyle(color: kMuted)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFFD6D3FF), Color(0xFFB9D7F5)]),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your\nmental health\nmatters.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kPrimary, height: 1.15)),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: kPrimary),
                onPressed: mood,
                icon: const Text('Quick Check-in'),
                label: const Icon(Icons.arrow_forward, size: 16),
              ),
            ]),
          ),
          const Icon(Icons.self_improvement, size: 90, color: kPrimary),
        ]),
      ),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.05,
        children: [
          _card(context, 'Check-In', 'How are you\nfeeling today?', Icons.sentiment_satisfied_alt, const Color(0xFFD7F5E8), Colors.green, mood),
          _card(context, 'Book\nAppointment', 'Get professional\nsupport', Icons.event_available, const Color(0xFFE6DEFA), kPrimary,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookScreen()))),
          _card(context, 'Resources', 'Learn &\nfind help', Icons.menu_book, const Color(0xFFFCE0D6), Colors.deepOrange, () => currentTab.value = 2),
          _card(context, 'My Profile', 'Manage your\nsettings', Icons.account_circle, const Color(0xFFD8EAFB), Colors.blue, () => currentTab.value = 3),
        ],
      ),
    ]);
  }
}
