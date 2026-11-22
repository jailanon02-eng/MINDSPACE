import 'package:flutter/material.dart';

import '../../all.dart';

final hubFilter = ValueNotifier<String>('For you');

class ActivitiesHub extends StatelessWidget {
  const ActivitiesHub({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: hubFilter,
    builder: (_, f, _) => ValueListenableBuilder<String?>(
      valueListenable: currentFeeling,
      builder: (_, feeling, _) {
        final list = f == 'For you'
            ? recommendFor(feeling ?? 'Okay')
            : f == 'All'
            ? allActivities
            : allActivities.where((a) => categoryOf(a) == f).toList();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Take 5', style: kTitle.copyWith(fontSize: 30)),
                      const Text(
                        'Tiny breaks, real relief.',
                        style: TextStyle(color: kMuted),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: ProgressService.todayMin,
                  builder: (_, m, _) => InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProgressScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🌱 $m min today  ›',
                        style: const TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in ['For you', 'All', ...kCategories])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: f == c,
                        selectedColor: kPrimary,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: f == c ? Colors.white : kText,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => hubFilter.value = c,
                      ),
                    ),
                ],
              ),
            ),
            if (f == 'For you')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  feeling == null
                      ? 'Suggestions for today'
                      : 'Picked for how you feel: ${feeling.toLowerCase()}',
                  style: const TextStyle(color: kMuted, fontSize: 13),
                ),
              ),
            const SizedBox(height: 14),
            for (var i = 0; i < list.length; i++)
              TweenAnimationBuilder<double>(
                key: ValueKey('$f${list[i].title}'),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + (i < 8 ? i * 70 : 500)),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - v)),
                    child: child,
                  ),
                ),
                child: ActivityCard(list[i]),
              ),
          ],
        );
      },
    ),
  );
}
