import 'package:flutter/material.dart';
import '../../all.dart';


class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});
  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  bool upcoming = true;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Appt>>(
        stream: DbService.appointments(),
        builder: (_, snap) {
          final n = DateTime.now(), today = DateTime(n.year, n.month, n.day);
          final shown = (snap.data ?? <Appt>[]).where((a) => upcoming == !a.date.isBefore(today)).toList();
          return ListView(padding: const EdgeInsets.all(20), children: [
            Text('Your sessions', style: kTitle.copyWith(fontSize: 28)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [ButtonSegment(value: true, label: Text('Upcoming')), ButtonSegment(value: false, label: Text('Past'))],
                selected: {upcoming},
                onSelectionChanged: (s) => setState(() => upcoming = s.first),
              ),
            ),
            const SizedBox(height: 16),
            if (shown.isEmpty)
              Box(
                padding: const EdgeInsets.all(28),
                child: Column(children: [
                  const Icon(Icons.spa_outlined, size: 44, color: kPrimary),
                  const SizedBox(height: 12),
                  Text(upcoming ? 'No sessions booked yet' : 'No past sessions', style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
                  const SizedBox(height: 4),
                  const Text('Talking to someone can help.', style: TextStyle(color: kMuted)),
                  if (upcoming) ...[
                    const SizedBox(height: 16),
                    PrimaryButton('Book a session',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookScreen()))),
                  ],
                ]),
              ),
            for (final a in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Box(
                  child: Row(children: [
                    Container(
                      width: 56, height: 64,
                      decoration: BoxDecoration(color: kPrimary.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${a.date.day}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kPrimary)),
                        Text(months[a.date.month - 1].substring(0, 3).toUpperCase(), style: const TextStyle(fontSize: 11, color: kPrimary)),
                      ]),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.service, style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
                      const SizedBox(height: 4),
                      Row(children: [const Icon(Icons.schedule, size: 14, color: kMuted), const SizedBox(width: 4),
                        Text(a.time, style: const TextStyle(color: kMuted, fontSize: 13))]),
                    ])),
                    if (upcoming) IconButton(tooltip: 'Cancel', icon: const Icon(Icons.close, color: kMuted), onPressed: () => DbService.cancel(a.id)),
                  ]),
                ),
              ),
          ]);
        },
      );
}
