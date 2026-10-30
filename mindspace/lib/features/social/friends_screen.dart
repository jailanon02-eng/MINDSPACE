import 'package:flutter/material.dart';

import '../../all.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsState();
}

class _FriendsState extends State<FriendsScreen> {
  final q = TextEditingController();
  List<Map<String, dynamic>> results = [];
  bool searched = false;

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _search() async {
    final r = await SocialService.search(q.text);
    if (mounted) {
      setState(() {
        results = r;
        searched = true;
      });
    }
  }

  Future<void> _add(UserProfile me, Map<String, dynamic> r) async {
    try {
      await SocialService.request(r['uid'], me.label, '@${r['username']}');
      _msg('Request sent to @${r['username']}');
    } catch (_) {
      _msg('Could not send. You may already be connected.');
    }
  }

  Widget _tile(String title, List<Widget> actions) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Box(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: kPrimary,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: kText),
            ),
          ),
          ...actions,
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Friends')),
    body: StreamBuilder<UserProfile?>(
      stream: DbService.profile(),
      builder: (_, s) {
        final me = s.data;
        if (me == null) return const Center(child: CircularProgressIndicator());
        if (me.isMinor) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Friends are available for ages 18+.',
                style: TextStyle(color: kMuted),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: q,
              onSubmitted: (_) => _search(),
              decoration: fieldDec(
                'Search by username',
                Icons.search,
                suffix: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
              ),
            ),
            if (!me.discoverable)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Tip: turn on "Let friends find me" in Edit profile so others can find you.',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ),
            if (searched && results.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Text(
                  'No one found with that username.',
                  style: TextStyle(color: kMuted),
                ),
              ),
            const SizedBox(height: 10),
            for (final r in results)
              _tile('@${r['username']}  ·  ${r['name']}', [
                FilledButton.tonal(
                  onPressed: () => _add(me, r),
                  child: const Text('Add'),
                ),
              ]),
            StreamBuilder<List<Doc>>(
              stream: SocialService.friendships(),
              builder: (_, fs) {
                final me0 = SocialService.uid;
                String other(Doc d) =>
                    (d['names'] as Map)[(d['members'] as List).firstWhere(
                      (m) => m != me0,
                    )] ??
                    'Friend';
                final all = fs.data ?? <Doc>[];
                final incoming = all
                    .where((d) => d['status'] == 'pending' && d['to'] == me0)
                    .toList();
                final sent = all
                    .where((d) => d['status'] == 'pending' && d['from'] == me0)
                    .toList();
                final friends = all
                    .where((d) => d['status'] == 'accepted')
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (incoming.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('Requests', style: kTitle.copyWith(fontSize: 18)),
                      const SizedBox(height: 10),
                      for (final d in incoming)
                        _tile(other(d), [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: kPrimary,
                            ),
                            onPressed: () => SocialService.accept(d.id),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: kMuted,
                            ),
                            onPressed: () =>
                                SocialService.removeFriendship(d.id),
                          ),
                        ]),
                    ],
                    const SizedBox(height: 14),
                    Text('Your friends', style: kTitle.copyWith(fontSize: 18)),
                    const SizedBox(height: 10),
                    if (friends.isEmpty)
                      const Text(
                        'No friends yet. Search above to add someone.',
                        style: TextStyle(color: kMuted),
                      ),
                    for (final d in friends)
                      _tile(other(d), [
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(
                            Icons.person_remove_outlined,
                            color: kMuted,
                          ),
                          onPressed: () => SocialService.removeFriendship(d.id),
                        ),
                      ]),
                    if (sent.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('Sent', style: kTitle.copyWith(fontSize: 18)),
                      const SizedBox(height: 10),
                      for (final d in sent)
                        _tile(other(d), [
                          TextButton(
                            onPressed: () =>
                                SocialService.removeFriendship(d.id),
                            child: const Text('Cancel'),
                          ),
                        ]),
                    ],
                  ],
                );
              },
            ),
          ],
        );
      },
    ),
  );
}
