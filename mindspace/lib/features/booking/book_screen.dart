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
  String? time = '09:00 AM';
  static const services = [
    ('General Counseling', 'Talk to a licensed counselor', Icons.person, Colors.blue),
    ('Stress Management', 'Learn coping techniques', Icons.spa, Colors.orange),
    ('Anxiety Support', 'Help for anxiety-related issues', Icons.healing, Colors.redAccent),
    ('Student Wellness', 'For students and young adults', Icons.school, Colors.teal),
  ];
  static const times = ['09:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:30 PM', '04:00 PM'];
  static const heads = ['Book an Appointment', 'Select Date', 'Select Time', 'Confirm'];

  Future<void> next() async {
    if (step < 3) {
      setState(() => step++);
    } else {
      await DbService.addAppointment(Appt(services[service].$1, date, time!));
      if (!mounted) return;
      currentTab.value = 1;
      Navigator.pop(context);
    }
  }

  Widget _stepper() => Row(children: [
        for (var i = 0; i < 4; i++) ...[
          Column(children: [
            CircleAvatar(radius: 14, backgroundColor: i <= step ? kPrimary : const Color(0xFFE3E1F5),
                child: Text('${i + 1}', style: TextStyle(fontSize: 12, color: i <= step ? Colors.white : kMuted))),
            const SizedBox(height: 4),
            Text(['Service', 'Date', 'Time', 'Confirm'][i], style: const TextStyle(fontSize: 11, color: kMuted)),
          ]),
          if (i < 3) Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 16), color: const Color(0xFFE3E1F5))),
        ]
      ]);

  Widget _body() {
    switch (step) {
      case 0:
        return Column(children: [
          for (var i = 0; i < services.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => service = i),
                child: Box(
                  selected: service == i,
                  child: Row(children: [
                    IconBadge(services[i].$3, services[i].$4),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(services[i].$1, style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
                      Text(services[i].$2, style: const TextStyle(fontSize: 12, color: kMuted)),
                    ])),
                    Icon(service == i ? Icons.radio_button_checked : Icons.radio_button_off, color: service == i ? kPrimary : kMuted),
                  ]),
                ),
              ),
            ),
        ]);
      case 1:
        return Box(
          child: CalendarDatePicker(
            initialDate: date.isBefore(DateTime.now()) ? DateTime.now() : date,
            firstDate: DateTime.now().subtract(const Duration(days: 0)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (d) => date = d,
          ),
        );
      case 2:
        return Column(children: [
          for (final t in times)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => time = t),
                child: Box(
                  selected: time == t,
                  color: time == t ? const Color(0xFFE9E6FA) : Colors.white,
                  child: Row(children: [
                    Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, color: kText))),
                    if (time == t) const Icon(Icons.check_circle, color: kPrimary),
                  ]),
                ),
              ),
            ),
        ]);
      default:
        return Box(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: kText)),
            const SizedBox(height: 12),
            Text('Service: ${services[service].$1}'),
            const SizedBox(height: 6),
            Text('Date: ${fmtDate(date)}'),
            const SizedBox(height: 6),
            Text('Time: $time'),
          ]),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back),
              onPressed: () => step == 0 ? Navigator.pop(context) : setState(() => step--)),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(children: [
              Expanded(
                child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
                  Text(heads[step], style: kTitle),
                  const SizedBox(height: 4),
                  const Text('Select a service and choose a date and time.', style: TextStyle(color: kMuted, fontSize: 13)),
                  const SizedBox(height: 18),
                  _stepper(),
                  const SizedBox(height: 20),
                  _body(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: PrimaryButton(step == 3 ? 'Confirm Appointment' : step == 0 ? 'Next' : 'Continue', arrow: true, onTap: next),
              ),
            ]),
          ),
        ),
      );
}
