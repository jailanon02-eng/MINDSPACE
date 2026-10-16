import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../all.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Widget _row(IconData i, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Box(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: ListTile(
            contentPadding: EdgeInsets.zero, dense: true,
            leading: Icon(i, color: kPrimary), title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, color: kText)),
            trailing: const Icon(Icons.chevron_right), onTap: () {},
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const Row(children: [
          Expanded(child: Text('My Profile', style: kTitle)),
          Icon(Icons.settings, color: kPrimary),
        ]),
        const SizedBox(height: 16),
        const Center(child: CircleAvatar(radius: 50, backgroundColor: Color(0xFFCFD8F7), child: Icon(Icons.person, size: 60, color: kPrimary))),
        const SizedBox(height: 10),
        const Center(child: Text('User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText))),
        Center(child: Text(FirebaseAuth.instance.currentUser?.email ?? 'Guest user', style: const TextStyle(color: kMuted))),
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFD7F5E8), borderRadius: BorderRadius.circular(12)),
            child: const Text('Anonymous', style: TextStyle(color: Colors.green, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 20),
        _row(Icons.person_outline, 'Edit Profile'),
        _row(Icons.notifications_none, 'Notification Settings'),
        _row(Icons.shield_outlined, 'Privacy & Security'),
        _row(Icons.info_outline, 'About MindSpace'),
        _row(Icons.help, 'Help & Support'),
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFD9D6), foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              await AuthService.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]);
}
