import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../all.dart';

const dayMoods = {
  'Great': ('😄', Color(0xFFFFB347), Color(0xFFFF7E8B)),
  'Good': ('🙂', Color(0xFF6FCF97), Color(0xFF56CCF2)),
  'Okay': ('😐', Color(0xFF8EC5FC), Color(0xFFB4A7F5)),
  'Sad': ('😢', Color(0xFF6A85B6), Color(0xFF9FB4D6)),
  'Anxious': ('😰', Color(0xFF7F7FD5), Color(0xFF86A8E7)),
  'Stressed': ('😣', Color(0xFFE9895B), Color(0xFFB06AB3)),
};

/// Generated art card: the same seed + mood always draws the same picture.
class DayArt extends StatelessWidget {
  final int seed;
  final String mood, text;
  const DayArt({
    super.key,
    required this.seed,
    required this.mood,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final m = dayMoods[mood] ?? dayMoods['Okay']!;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _ArtPainter(seed, m.$2, m.$3)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(blurRadius: 12, color: Colors.black38)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 16,
              child: Text(m.$1, style: const TextStyle(fontSize: 30)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  final int seed;
  final Color a, b;
  _ArtPainter(this.seed, this.a, this.b);
  @override
  void paint(Canvas c, Size s) {
    final r = math.Random(seed), rect = Offset.zero & s;
    c.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(r.nextDouble() * 2 - 1, -1),
          end: Alignment(r.nextDouble() * 2 - 1, 1),
          colors: [a, b],
        ).createShader(rect),
    );
    for (var i = 0; i < 7; i++) {
      c.drawCircle(
        Offset(r.nextDouble() * s.width, r.nextDouble() * s.height),
        30 + r.nextDouble() * s.width * .28,
        Paint()
          ..color = Colors.white.withValues(alpha: .12 + r.nextDouble() * .2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
    }
    for (var i = 0; i < 3; i++) {
      final y0 = s.height * (.3 + .2 * i + r.nextDouble() * .1),
          amp = 10 + r.nextDouble() * 18,
          f = 1 + r.nextDouble() * 2,
          ph = r.nextDouble() * 6;
      final path = Path()..moveTo(0, y0);
      for (double x = 0; x <= s.width; x += 6) {
        path.lineTo(x, y0 + math.sin(x / s.width * 2 * math.pi * f + ph) * amp);
      }
      c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white.withValues(alpha: .28),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArtPainter o) => o.seed != seed || o.a != a;
}

class MyDayScreen extends StatelessWidget {
  const MyDayScreen({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<UserProfile?>(
    stream: DbService.profile(),
    builder: (_, s) {
      final p = s.data;
      if (p == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My day'),
            bottom: const TabBar(
              labelColor: kPrimary,
              indicatorColor: kPrimary,
              tabs: [
                Tab(text: 'Create'),
                Tab(text: 'From friends'),
              ],
            ),
          ),
          body: TabBarView(children: [_Create(p), _Feed(p)]),
        ),
      );
    },
  );
}

class _Create extends StatefulWidget {
  final UserProfile p;
  const _Create(this.p);
  @override
  State<_Create> createState() => _CreateState();
}

class _CreateState extends State<_Create> {
  final txt = TextEditingController();
  final rnd = math.Random();
  String mood = 'Good';
  late int seed = rnd.nextInt(1 << 30);
  bool busy = false;

  Future<void> _save(bool share) async {
    if (txt.text.trim().isEmpty) return;
    setState(() => busy = true);
    await SocialService.addNote(
      text: txt.text.trim(),
      mood: mood,
      seed: seed,
      share: share,
      authorName: widget.p.label,
    );
    if (!mounted) return;
    txt.clear();
    setState(() {
      busy = false;
      seed = rnd.nextInt(1 << 30);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          share ? 'Shared with your friends 💚' : 'Saved privately 💚',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('How was your day?', style: kTitle.copyWith(fontSize: 24)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in dayMoods.entries)
            ChoiceChip(
              label: Text('${e.value.$1} ${e.key}'),
              selected: mood == e.key,
              selectedColor: kPrimary.withValues(alpha: .2),
              onSelected: (_) => setState(() => mood = e.key),
            ),
        ],
      ),
      const SizedBox(height: 14),
      TextField(
        controller: txt,
        maxLength: 100,
        onChanged: (_) => setState(() {}),
        decoration: fieldDec('A few words about today', Icons.edit_note),
      ),
      const SizedBox(height: 10),
      DayArt(
        seed: seed,
        mood: mood,
        text: txt.text.trim().isEmpty
            ? 'Your day, in a few words'
            : txt.text.trim(),
      ),
      TextButton.icon(
        onPressed: () => setState(() => seed = rnd.nextInt(1 << 30)),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Generate a new look'),
      ),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: busy ? null : () => _save(false),
              child: const Text('Save privately'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: busy || widget.p.isMinor ? null : () => _save(true),
              style: FilledButton.styleFrom(backgroundColor: kPrimary),
              child: const Text('Share with friends'),
            ),
          ),
        ],
      ),
      if (widget.p.isMinor)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Sharing is available for ages 18+.',
            style: TextStyle(color: kMuted, fontSize: 12),
          ),
        ),
      const SizedBox(height: 24),
      Text('Your cards', style: kTitle.copyWith(fontSize: 18)),
      const SizedBox(height: 10),
      StreamBuilder<List<Doc>>(
        stream: SocialService.myNotes(),
        builder: (_, s) => Column(
          children: [
            for (final d in s.data ?? <Doc>[])
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    DayArt(seed: d['seed'], mood: d['mood'], text: d['text']),
                    Row(
                      children: [
                        Text(
                          (d['sharedWith'] as List).isEmpty
                              ? 'Private'
                              : 'Shared with ${(d['sharedWith'] as List).length} friends',
                          style: const TextStyle(color: kMuted, fontSize: 12),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: kMuted),
                          onPressed: () => SocialService.deleteNote(d.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _Feed extends StatelessWidget {
  final UserProfile p;
  const _Feed(this.p);
  @override
  Widget build(BuildContext context) {
    if (p.isMinor) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Friends and sharing are available for ages 18+.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kMuted),
          ),
        ),
      );
    }
    return StreamBuilder<List<Doc>>(
      stream: SocialService.sharedWithMe(),
      builder: (_, s) {
        final docs = s.data ?? <Doc>[];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Nothing shared yet. Add friends to see their days.',
              style: TextStyle(color: kMuted),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            for (final d in docs)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['authorName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DayArt(seed: d['seed'], mood: d['mood'], text: d['text']),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          await SocialService.report(d.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thanks. We will review this.'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: kMuted,
                        ),
                        label: const Text(
                          'Report',
                          style: TextStyle(color: kMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
