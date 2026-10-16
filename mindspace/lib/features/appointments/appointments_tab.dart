import 'package:flutter/material.dart';
import '../../all.dart';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});
  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  bool upcoming = true;

  Widget _seg(String t, bool on) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => upcoming = on),
          child: Container(
            height: 40, alignment: Alignment.center,
            decoration: BoxDecoration(color: upcoming == on ? kPrimary : const Color(0xFFE9E7F7), borderRadius: BorderRadius.circular(10)),
            child: Text(t, style: TextStyle(color: upcoming == on ? Colors.white : kMuted, fontWeight: FontWeight.w600)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Appt>>(
        stream: DbService.appointments(),
        builder: (_, snap) {
          final list = snap.data ?? <Appt>[];
          final today = DateTime.now();
          final shown = list.where((a) => upcoming == (!a.date.isBefore(DateTime(today.year, today.month, today.day)))).toList();
          return ListView(padding: const EdgeInsets.all(20), children: [
            const Text('My Appointments', style: kTitle),
            const SizedBox(height: 16),
            Row(children: [_seg('Upcoming', true), const SizedBox(width: 12), _seg('Past', false)]),
            const SizedBox(height: 16),
            for (final a in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Box(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const IconBadge(Icons.person, Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.service, style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
                      Text(fmtDate(a.date), style: const TextStyle(fontSize: 12, color: kMuted)),
                      Row(children: [const Icon(Icons.access_time, size: 14, color: kPrimary), const SizedBox(width: 4),
                        Text(a.time, style: const TextStyle(fontSize: 12, color: kMuted))]),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFD7F5E8), borderRadius: BorderRadius.circular(10)),
                        child: Text(upcoming ? 'Upcoming' : 'Completed', style: const TextStyle(fontSize: 11, color: Colors.green)),
                      ),
                    ])),
                    PopupMenuButton<String>(
                      onSelected: (_) => DbService.cancel(a.id),
                      itemBuilder: (_) => const [PopupMenuItem(value: 'cancel', child: Text('Cancel appointment'))],
                    ),
                  ]),
                ),
              ),
            Box(
              color: const Color(0xFFEDEBFA),
              child: Column(children: [
                const Icon(Icons.event, size: 32, color: kPrimary),
                const SizedBox(height: 8),
                Text(shown.isEmpty ? 'No appointments yet.\nBook one to get started!' : 'No more appointments.\nBook a new one to get started!',
                    textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
                const SizedBox(height: 12),
                PrimaryButton('Book Appointment',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookScreen()))),
              ]),
            ),
          ]);
        },
      );
}
