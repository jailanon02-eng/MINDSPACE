import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../all.dart';

const feelings = [
  ('Great', '😄'),
  ('Good', '🙂'),
  ('Okay', '😐'),
  ('Tired', '😴'),
  ('Sad', '😢'),
  ('Anxious', '😰'),
  ('Stressed', '😣'),
  ('Overwhelmed', '🤯'),
];
final currentFeeling = ValueNotifier<String?>(null);

// Categories describe what an activity does, not who it is for.
const kCategories = [
  'Calm',
  'Release',
  'Move',
  'Focus',
  'Encourage',
  'Unwind',
  'Reflect',
  'Create',
];
const categoryIcons = {
  'Calm': Icons.air,
  'Release': Icons.bubble_chart,
  'Move': Icons.self_improvement,
  'Focus': Icons.center_focus_strong,
  'Encourage': Icons.favorite_border,
  'Unwind': Icons.nights_stay_outlined,
  'Reflect': Icons.edit_note,
  'Create': Icons.brush,
};
const categoryColors = {
  'Calm': Color(0xFF3F8F8A),
  'Release': Color(0xFF4A90D9),
  'Move': Color(0xFFE9895B),
  'Focus': Color(0xFF7B6FD0),
  'Encourage': Color(0xFFD9638F),
  'Unwind': Color(0xFF2F7DA6),
  'Reflect': Color(0xFFD89B2B),
  'Create': Color(0xFFD9656F),
};

List<Activity> get allActivities => [...activities, ...moreActivities];

String categoryOf(Activity a) {
  switch (a.kind) {
    case Kind.breathe:
    case Kind.pattern:
    case Kind.bodyscan:
      return 'Calm';
    case Kind.bubbles:
    case Kind.float:
    case Kind.squeeze:
      return 'Release';
    case Kind.stretch:
    case Kind.moves:
      return 'Move';
    case Kind.ground:
      return 'Focus';
    case Kind.affirm:
      return 'Encourage';
    case Kind.scene:
    case Kind.scenery:
      return 'Unwind';
    case Kind.worry:
    case Kind.write:
    case Kind.gratitude:
      return 'Reflect';
    case Kind.doodle:
    case Kind.paint:
      return 'Create';
  }
}

const _prefs = {
  'Great': ['Create', 'Move', 'Reflect', 'Encourage'],
  'Good': ['Create', 'Reflect', 'Move', 'Unwind'],
  'Okay': ['Focus', 'Move', 'Create', 'Unwind'],
  'Tired': ['Unwind', 'Calm', 'Encourage', 'Move'],
  'Sad': ['Encourage', 'Reflect', 'Unwind', 'Create'],
  'Anxious': ['Calm', 'Focus', 'Release', 'Unwind'],
  'Stressed': ['Release', 'Calm', 'Move', 'Unwind'],
  'Overwhelmed': ['Calm', 'Unwind', 'Reflect', 'Focus'],
};

/// Two activities from each of the four best-fitting categories; the pick rotates daily.
List<Activity> recommendFor(String feeling) {
  final day = DateTime.now().difference(DateTime(2024)).inDays;
  final out = <Activity>[];
  for (final c in _prefs[feeling] ?? kCategories.take(4)) {
    final l = allActivities.where((a) => categoryOf(a) == c).toList()
      ..sort(
        (a, b) => (a.title.hashCode ^ day).compareTo(b.title.hashCode ^ day),
      );
    out.addAll(l.take(2));
  }
  return out;
}

Future<void> openActivity(BuildContext c, Activity a) async {
  if (!a.free && !await ensureAccess(c)) return;
  if (!c.mounted) return;
  Navigator.push(
    c,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, _, _) => ActivityRunner(a),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}

class ActivityCard extends StatelessWidget {
  final Activity a;
  const ActivityCard(this.a, {super.key});
  @override
  Widget build(BuildContext context) {
    final cat = categoryOf(a), col = categoryColors[cat]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [col, Color.lerp(col, Colors.black, .25)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => openActivity(context, a),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(categoryIcons[cat], color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            a.desc,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${cat.toUpperCase()}  ·  ${a.type.toUpperCase()}  ·  5 MIN',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 34,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown after login / when the app opens, once per session, before the main app.
class FeelingGate extends StatefulWidget {
  const FeelingGate({super.key});
  static String? _shownFor;
  @override
  State<FeelingGate> createState() => _FeelingGateState();
}

class _FeelingGateState extends State<FeelingGate> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (FeelingGate._shownFor == uid) return const MainShell();
    return FeelingFlow(
      onContinue: () => setState(() => FeelingGate._shownFor = uid),
    );
  }
}

class FeelingFlow extends StatefulWidget {
  final VoidCallback onContinue;
  const FeelingFlow({super.key, required this.onContinue});
  @override
  State<FeelingFlow> createState() => _FeelingFlowState();
}

class _FeelingFlowState extends State<FeelingFlow> {
  String? sel;
  bool recs = false;

  Future<void> _confirm() async {
    currentFeeling.value = sel;
    ProgressService.saveFeeling(sel!);
    setState(() => recs = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: recs ? _list() : _pick(),
          ),
        ),
      ),
    ),
  );

  Widget _pick() => ListView(
    key: const ValueKey('pick'),
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'How are you feeling right now?',
        style: kTitle.copyWith(fontSize: 28),
      ),
      const SizedBox(height: 6),
      const Text(
        'Pick one. We will suggest a few activities that fit.',
        style: TextStyle(color: kMuted),
      ),
      const SizedBox(height: 20),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.9,
        children: [
          for (final f in feelings)
            GestureDetector(
              onTap: () => setState(() => sel = f.$1),
              child: Box(
                selected: sel == f.$1,
                color: sel == f.$1
                    ? kPrimary.withValues(alpha: .1)
                    : Colors.white,
                child: Row(
                  children: [
                    Text(f.$2, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      PrimaryButton(
        'Show me what helps',
        arrow: true,
        onTap: sel == null ? null : _confirm,
      ),
    ],
  );

  Widget _list() {
    final f = feelings.firstWhere((x) => x.$1 == sel);
    return ListView(
      key: const ValueKey('recs'),
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '${f.$2}  Feeling ${f.$1.toLowerCase()}',
          style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Here is what might help right now',
          style: kTitle.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap any activity to start. Each takes about 5 minutes.',
          style: TextStyle(color: kMuted),
        ),
        const SizedBox(height: 18),
        for (final a in recommendFor(sel!)) ActivityCard(a),
        const SizedBox(height: 8),
        PrimaryButton('Go to my home', arrow: true, onTap: widget.onContinue),
        TextButton(
          onPressed: () => setState(() => recs = false),
          child: const Text('Pick a different feeling'),
        ),
      ],
    );
  }
}
