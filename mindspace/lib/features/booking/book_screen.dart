import 'package:flutter/material.dart';
import '../../all.dart';


class BookScreen extends StatefulWidget {
  const BookScreen({super.key});
  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  int step = 0, service = 0;
  DateTime date = DateTime.now();
  String time = '09:00 AM';
  bool saving = false;
  static const services = [
    ('General Counseling', 'Talk with a licensed counselor', Icons.chat_bubble_outline),
    ('Anxiety Support', 'Tools for worry and panic', Icons.waves),
    ('Burnout & Stress', 'Coping skills and planning', Icons.local_fire_department_outlined),
    ('Food & Body Image', 'Gentle, judgment-free support', Icons.restaurant_outlined),
    ('Low Mood', 'Support for depression', Icons.cloud_outlined),
  ];
  static const times = ['09:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:30 PM', '04:00 PM'];
  static const heads = ['Choose a service', 'Pick a day', 'Pick a time', 'Review and confirm'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!await ensureAccess(context) && mounted) Navigator.pop(context);
    });
  }

  Future<void> _next() async {
    if (step < 3) return setState(() => step++);
    setState(() => saving = true);
    await DbService.addAppointment(Appt(services[service].$1, date, time));
    if (!mounted) return;
    currentTab.value = 2;
    Navigator.pop(context);
  }

  Widget _body() {
    switch (step) {
      case 0:
        return Column(children: [
          for (var i = 0; i < services.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => service = i),
                child: Box(
                  selected: service == i,
                  child: Row(children: [
                    IconBadge(services[i].$3, kPrimary),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(services[i].$1, style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
                      Text(services[i].$2, style: const TextStyle(fontSize: 12, color: kMuted)),
                    ])),
                    if (service == i) const Icon(Icons.check_circle, color: kPrimary),
                  ]),
                ),
              ),
            ),
        ]);
      case 1:
        return Box(
          child: CalendarDatePicker(
            initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (d) => date = d,
          ),
        );
      case 2:
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final t in times)
            ChoiceChip(
              label: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: Text(t)),
              selected: time == t, selectedColor: kPrimary, showCheckmark: false,
              labelStyle: TextStyle(color: time == t ? Colors.white : kText, fontWeight: FontWeight.w600),
              onSelected: (_) => setState(() => time = t),
            ),
        ]);
      default:
        return Box(
          child: Column(children: [
            for (final r in [('Service', services[service].$1), ('Date', fmtDate(date)), ('Time', time)])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Text(r.$1, style: const TextStyle(color: kMuted)),
                  const Spacer(),
                  Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
                ]),
              ),
          ]),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Step ${step + 1} of 4', style: const TextStyle(fontSize: 14, color: kMuted)),
          leading: IconButton(icon: const Icon(Icons.arrow_back),
              onPressed: () => step == 0 ? Navigator.pop(context) : setState(() => step--)),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LinearProgressIndicator(value: (step + 1) / 4, minHeight: 6, color: kPrimary,
                    backgroundColor: kPrimary.withValues(alpha: .15), borderRadius: BorderRadius.circular(3)),
              ),
              Expanded(
                child: ListView(padding: const EdgeInsets.all(24), children: [
                  Text(heads[step], style: kTitle.copyWith(fontSize: 26)),
                  const SizedBox(height: 18),
                  _body(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(saving ? 'Booking...' : step == 3 ? 'Confirm booking' : 'Continue', arrow: step < 3,
                    onTap: saving ? null : _next),
              ),
            ]),
          ),
        ),
      );
}
