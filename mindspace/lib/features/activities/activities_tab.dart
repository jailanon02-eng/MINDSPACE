import 'package:flutter/material.dart';
import '../../all.dart';


import 'dart:async';

final activityFilter = ValueNotifier<String>('All');

class Activity {
  final String title, desc, type;
  final IconData icon;
  final Color color;
  final List<String> focus, steps;
  final bool free;
  const Activity(this.title, this.desc, this.type, this.icon, this.color, this.focus, this.steps, {this.free = false});
}

const kTypes = ['Read', 'Play', 'Watch', 'Move', 'Breathe'];
const kFocus = ['Anxiety', 'Stress', 'Eating', 'Depression'];
const activities = [
  Activity('Box breathing', 'Slow your body down', 'Breathe', Icons.air, Color(0xFF3FA796), ['Anxiety', 'Stress'],
      ['Breathe in for 4', 'Hold for 4', 'Out for 4', 'Hold for 4. Repeat.'], free: true),
  Activity('Grounding 5-4-3-2-1', 'Come back to the present', 'Read', Icons.menu_book, Color(0xFF5E57B0), ['Anxiety'],
      ['Name 5 things you see', '4 you can touch', '3 you hear', '2 you smell, 1 you taste']),
  Activity('Gentle desk stretch', 'Release tension from burnout', 'Move', Icons.self_improvement, Color(0xFFE9895B), ['Stress', 'Depression'],
      ['Roll your shoulders slowly', 'Stretch your neck side to side', 'Reach up and breathe', 'Shake out your hands']),
  Activity('Calm tap', 'A mindful focus game', 'Play', Icons.bubble_chart, Color(0xFF4A90D9), ['Anxiety', 'Stress'],
      ['Tap slowly, one bubble at a time', 'Notice each breath', 'No score. No rush.']),
  Activity('Kindness to my body', 'A compassionate reading', 'Read', Icons.favorite_border, Color(0xFFD9638F), ['Eating', 'Depression'],
      ['Place a hand on your chest', 'Say: I am doing my best today', 'Notice how you feel, without judging']),
  Activity('Nature moment', 'Relaxing visuals and sounds', 'Watch', Icons.landscape, Color(0xFF6FA86B), ['Stress', 'Depression'],
      ['Find a comfortable seat', 'Watch and listen', 'Let your thoughts pass by']),
  Activity('Small win walk', 'A short walk to lift mood', 'Move', Icons.directions_walk, Color(0xFFE0A93B), ['Depression'],
      ['Step outside or walk a hallway', 'Notice 3 colors', 'Smile at one thing']),
  Activity('Mealtime calm', 'Ease anxious moments around food', 'Breathe', Icons.spa, Color(0xFF7B9E9A), ['Eating', 'Anxiety'],
      ['Sit down and unclench your jaw', 'Breathe slowly for a minute', 'Remind yourself: food is care']),
];

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: activityFilter,
        builder: (_, f, __) {
          final shown = activities.where((a) => f == 'All' || a.type == f || a.focus.contains(f)).toList();
          return ListView(padding: const EdgeInsets.all(20), children: [
            Text('Take 5', style: kTitle.copyWith(fontSize: 28)),
            const Text('Pick a short activity that fits how you feel.', style: TextStyle(color: kMuted)),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final c in ['All', ...kFocus, ...kTypes])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c), selected: f == c, selectedColor: kPrimary, showCheckmark: false,
                      labelStyle: TextStyle(color: f == c ? Colors.white : kText),
                      onSelected: (_) => activityFilter.value = c,
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 14),
            for (final a in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    if (!a.free && !await ensureAccess(context)) return;
                    if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityScreen(a)));
                  },
                  child: Box(
                    child: Row(children: [
                      IconBadge(a.icon, a.color),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 16)),
                        Text('${a.type} · 5 min · ${a.desc}', style: const TextStyle(fontSize: 12, color: kMuted)),
                      ])),
                      Icon(a.free ? Icons.play_circle_outline : Icons.chevron_right, color: kMuted),
                    ]),
                  ),
                ),
              ),
          ]);
        },
      );
}

class ActivityScreen extends StatefulWidget {
  final Activity a;
  const ActivityScreen(this.a, {super.key});
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  Timer? timer;
  int left = 300;

  void _toggle() {
    if (timer != null) {
      timer!.cancel();
      setState(() => timer = null);
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (left <= 1) {
        t.cancel();
        setState(() { left = 0; timer = null; });
        return;
      }
      setState(() => left--);
    });
    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.a;
    final mm = '${left ~/ 60}:${(left % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(title: Text(a.title)),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        Center(
          child: ScaleTransition(
            scale: Tween(begin: .8, end: 1.0).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut)),
            child: Container(
              width: 190, height: 190, alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: a.color.withOpacity(.2),
                  border: Border.all(color: a.color, width: 3)),
              child: Text(left == 0 ? 'Well done' : mm, style: kTitle.copyWith(fontSize: 38, color: a.color)),
            ),
          ),
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < a.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Box(child: Row(children: [
              CircleAvatar(radius: 13, backgroundColor: a.color, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
              const SizedBox(width: 12),
              Expanded(child: Text(a.steps[i], style: const TextStyle(color: kText))),
            ])),
          ),
        const SizedBox(height: 14),
        PrimaryButton(timer != null ? 'Pause' : left == 300 ? 'Start 5 minutes' : left == 0 ? 'Finish' : 'Resume',
            onTap: left == 0 ? () => Navigator.pop(context) : _toggle),
      ]),
    );
  }
}
