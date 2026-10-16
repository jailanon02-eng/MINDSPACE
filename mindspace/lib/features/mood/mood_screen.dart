import 'package:flutter/material.dart';
import '../../all.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});
  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? sel;
  final ctrl = TextEditingController();
  static const moods = [
    ('Great', Icons.sentiment_very_satisfied, Colors.green),
    ('Good', Icons.sentiment_satisfied, Color(0xFF8BC34A)),
    ('Okay', Icons.sentiment_neutral, Colors.amber),
    ('Sad', Icons.sentiment_dissatisfied, Colors.lightBlue),
    ('Anxious', Icons.sentiment_very_dissatisfied, Colors.deepPurpleAccent),
    ('Stressed', Icons.mood_bad, Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Text('How are you\nfeeling today?', textAlign: TextAlign.center, style: kTitle),
            const SizedBox(height: 10),
            const Text('Choose a mood (anonymous)', style: TextStyle(color: kMuted)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 28, runSpacing: 20, alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < moods.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => sel = i),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            border: Border.all(color: sel == i ? kPrimary : Colors.transparent, width: 3)),
                        child: CircleAvatar(radius: 32, backgroundColor: moods[i].$3.withOpacity(.25),
                            child: Icon(moods[i].$2, size: 44, color: moods[i].$3)),
                      ),
                      const SizedBox(height: 6),
                      Text(moods[i].$1, style: const TextStyle(fontSize: 12, color: kText)),
                    ]),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            const Align(alignment: Alignment.centerLeft, child: Text('Optional: You can write something...', style: TextStyle(color: kText))),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl, maxLines: 4, maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Type here...', filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton('Submit Check-in', onTap: sel == null ? null : () async {
              await DbService.addMood(moods[sel!].$1, ctrl.text.trim());
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for checking in 💜')));
              Navigator.pop(context);
            }),
          ]),
        ),
      );
}
