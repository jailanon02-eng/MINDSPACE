import 'package:flutter/material.dart';

import '../../all.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _go(String filter) {
    hubFilter.value = filter;
    currentTab.value = 1;
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      StreamBuilder<UserProfile?>(
        stream: DbService.profile(),
        builder: (_, s) => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${s.data?.name ?? ''} 👋',
                    style: kTitle.copyWith(fontSize: 26),
                  ),
                  const Text(
                    'A few minutes is enough.',
                    style: TextStyle(color: kMuted),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sos_outlined, color: Colors.redAccent),
              onPressed: () => showDialog(
                context: context,
                builder: (d) => AlertDialog(
                  title: const Text('Need urgent help?'),
                  content: const Text(kCrisisInfo),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(d),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      ValueListenableBuilder<String?>(
        valueListenable: currentFeeling,
        builder: (_, f, _) {
          final e = f == null ? '🙂' : feelings.firstWhere((x) => x.$1 == f).$2;
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FeelingFlow(onContinue: () => Navigator.pop(context)),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [kPrimary, Color(0xFF7BC0B8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Text(e, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f == null
                              ? 'How are you feeling?'
                              : 'Feeling ${f.toLowerCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Tap to update how you feel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: Text(
              'Suggested for you',
              style: kTitle.copyWith(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () => _go('For you'),
            child: const Text('See all'),
          ),
        ],
      ),
      ValueListenableBuilder<String?>(
        valueListenable: currentFeeling,
        builder: (_, f, _) => Column(
          children: [
            for (final a in recommendFor(f ?? 'Okay').take(3)) ActivityCard(a),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Text('Browse by what you need', style: kTitle.copyWith(fontSize: 18)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
        children: [
          for (final c in kCategories)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _go(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: categoryColors[c]!.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(categoryIcons[c], color: categoryColors[c]),
                    const SizedBox(width: 8),
                    Text(
                      c,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 20),
      Box(
        child: Row(
          children: [
            const IconBadge(Icons.event_available, kPrimary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Talk to a professional',
                style: TextStyle(fontWeight: FontWeight.w700, color: kText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookScreen()),
              ),
              child: const Text('Book'),
            ),
          ],
        ),
      ),
    ],
  );
}
