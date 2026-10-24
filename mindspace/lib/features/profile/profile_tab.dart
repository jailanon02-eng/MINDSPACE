import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../all.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Updated _row to accept either a simple info string OR a custom onTap handler
  Widget _row(
    BuildContext c,
    IconData i,
    String t, {
    String? info,
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Box(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(i, color: kPrimary),
        title: Text(
          t,
          style: const TextStyle(fontWeight: FontWeight.w600, color: kText),
        ),
        trailing: const Icon(Icons.chevron_right, color: kMuted),
        onTap:
            onTap ??
            (info == null
                ? () {}
                : () => showDialog(
                    context: c,
                    builder: (d) => AlertDialog(
                      title: Text(t),
                      content: Text(info),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(d),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  )),
      ),
    ),
  );

  // Custom dialog to display the updated kCrisisInfo List
  void _showCrisisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Urgent Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If you are in danger or thinking about hurting yourself, please contact local emergency services or call a helpline immediately:',
              style: TextStyle(fontSize: 13, color: kText),
            ),
            const SizedBox(height: 16),
            ...kCrisisInfo.map(
              (info) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        info.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SelectableText(
                      info.number,
                      style: const TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<UserProfile?>(
    stream: DbService.profile(),
    builder: (_, s) {
      final p = s.data;
      final status = p == null
          ? ''
          : !p.isMinor
          ? 'Adult account'
          : p.consentStatus == 'approved'
          ? 'Parental consent verified'
          : p.consentStatus == 'pending'
          ? 'Consent under review'
          : 'Consent needed';

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: kPrimary,
              child: Text(
                (p?.name.isNotEmpty ?? false) ? p!.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 38,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(p?.name ?? '', style: kTitle)),
          Center(
            child: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(color: kMuted),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Chip(
              avatar: Icon(
                p?.restricted ?? false
                    ? Icons.lock_outline
                    : Icons.verified_outlined,
                size: 16,
                color: kPrimary,
              ),
              label: Text(status),
              backgroundColor: kPrimary.withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
          ),
          if ((p?.restricted ?? false) && p?.consentStatus == 'none') ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConsentScreen()),
                ),
                child: const Text('Upload parental consent'),
              ),
            ),
          ],
          const SizedBox(height: 18),
          _row(context, Icons.notifications_none, 'Reminders'),
          _row(
            context,
            Icons.shield_outlined,
            'Privacy & your data',
            info: 'We only store your name, birth date, check-ins and bookings. We never ask for diagnoses or medical records.',
          ),
          // Updated Urgent help row using the custom dialog handler
          _row(
            context,
            Icons.sos_outlined,
            'Urgent help',
            onTap: () => _showCrisisDialog(context),
          ),
          _row(
            context,
            Icons.info_outline,
            'About MindSpace',
            info: 'MindSpace is a self-care companion, not a replacement for professional care.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () async {
              await AuthService.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      );
    },
  );
}
