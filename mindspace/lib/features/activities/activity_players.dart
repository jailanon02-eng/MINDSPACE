import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const _white = TextStyle(color: Colors.white);

// ----- Box breathing -----
class BreathePlayer extends StatefulWidget {
  const BreathePlayer({super.key});
  @override
  State<BreathePlayer> createState() => _BreatheState();
}

class _BreatheState extends State<BreathePlayer> with SingleTickerProviderStateMixin {
  late final c = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
  @override
  void dispose() { c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        builder: (_, __) {
          final t = c.value * 4, ph = t.floor() % 4, f = t - t.floor();
          final e = Curves.easeInOut.transform(f);
          final s = ph == 0 ? .55 + .45 * e : ph == 1 ? 1.0 : ph == 2 ? 1 - .45 * e : .55;
          Widget ring(double size, double o) => Container(width: size * s, height: size * s, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(o)));
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: 280, height: 280,
              child: Stack(alignment: Alignment.center, children: [
                ring(280, .12), ring(220, .2),
                Container(width: 150 * s, height: 150 * s, alignment: Alignment.center,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: Text('${4 - (f * 4).floor()}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Color(0xFF3F8F8A)))),
              ]),
            ),
            const SizedBox(height: 28),
            Text(['Breathe in', 'Hold', 'Breathe out', 'Hold'][ph], style: _white.copyWith(fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('4 seconds each', style: _white.copyWith(color: Colors.white70)),
          ]);
        },
      );
}

// ----- Pop your worries -----
class _B {
  double x, speed, size, off, popAt = -1;
  _B(this.x, this.speed, this.size, this.off);
}

class BubblesPlayer extends StatefulWidget {
  const BubblesPlayer({super.key});
  @override
  State<BubblesPlayer> createState() => _BubblesState();
}

class _BubblesState extends State<BubblesPlayer> with SingleTickerProviderStateMixin {
  final rnd = math.Random();
  late final List<_B> bs = List.generate(10, (_) => _B(rnd.nextDouble(), .05 + rnd.nextDouble() * .07, 46 + rnd.nextDouble() * 40, rnd.nextDouble()));
  late final Ticker tk;
  double t = 0;
  int pops = 0;

  @override
  void initState() {
    super.initState();
    tk = createTicker((d) {
      t = d.inMilliseconds / 1000;
      for (final b in bs) {
        if (b.popAt >= 0 && t - b.popAt > .25) {
          b.popAt = -1;
          b.x = rnd.nextDouble();
          b.off = (1 - (t * b.speed) % 1) % 1;
        }
      }
      setState(() {});
    })..start();
  }

  @override
  void dispose() { tk.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, cs) {
          final w = cs.maxWidth, h = cs.maxHeight;
          return Stack(children: [
            Align(alignment: Alignment.topCenter, child: Padding(padding: const EdgeInsets.only(top: 8),
                child: Text('Popped $pops  ·  no score, just breathe', style: _white.copyWith(color: Colors.white70)))),
            for (final b in bs)
              Positioned(
                left: b.x * (w - b.size) + math.sin(t * .8 + b.off * 6) * 10,
                top: (1 - ((t * b.speed + b.off) % 1)) * (h + b.size) - b.size,
                child: GestureDetector(
                  onTap: () {
                    if (b.popAt >= 0) return;
                    HapticFeedback.lightImpact();
                    setState(() { b.popAt = t; pops++; });
                  },
                  child: Builder(builder: (_) {
                    final p = b.popAt < 0 ? 0.0 : ((t - b.popAt) / .25).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: 1 - p,
                      child: Transform.scale(
                        scale: 1 + p * .5,
                        child: Container(
                          width: b.size, height: b.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 2),
                            gradient: RadialGradient(center: const Alignment(-.4, -.4), colors: [Colors.white.withOpacity(.6), Colors.white.withOpacity(.12)]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ]);
        },
      );
}

// ----- Desk reset (guided moves) -----
class StretchPlayer extends StatefulWidget {
  const StretchPlayer({super.key});
  @override
  State<StretchPlayer> createState() => _StretchState();
}

class _StretchState extends State<StretchPlayer> with SingleTickerProviderStateMixin {
  static const moves = [
    ('🙆', 'Reach both arms up and breathe'), ('🔄', 'Roll your shoulders slowly backward'), ('🙇', 'Drop your chin, relax your neck'),
    ('🤸', 'Twist gently side to side'), ('🖐️', 'Shake out your hands and wrists'), ('🧘', 'Stand tall and feel your feet'),
  ];
  late final bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  int i = 0, s = 30;
  Timer? tm;

  @override
  void initState() {
    super.initState();
    tm = Timer.periodic(const Duration(seconds: 1), (_) => setState(() { if (--s <= 0) _next(); }));
  }

  void _next() { s = 30; i = (i + 1) % moves.length; }

  @override
  void dispose() { tm?.cancel(); bounce.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Move ${i + 1} of ${moves.length}', style: _white.copyWith(color: Colors.white70)),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (c, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(.2, 0), end: Offset.zero).animate(a), child: c)),
          child: Column(key: ValueKey(i), children: [
            AnimatedBuilder(
              animation: bounce,
              builder: (_, __) => Transform.translate(offset: Offset(0, -16 * Curves.easeInOut.transform(bounce.value)), child: Text(moves[i].$1, style: const TextStyle(fontSize: 100))),
            ),
            const SizedBox(height: 14),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(moves[i].$2, textAlign: TextAlign.center, style: _white.copyWith(fontSize: 22, fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: 76, height: 76,
          child: Stack(alignment: Alignment.center, children: [
            SizedBox.expand(child: CircularProgressIndicator(value: s / 30, strokeWidth: 6, color: Colors.white, backgroundColor: Colors.white24)),
            Text('$s', style: _white.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
        ),
        TextButton(onPressed: () => setState(_next), child: const Text('Next move', style: TextStyle(color: Colors.white70))),
      ]);
}

// ----- 5-4-3-2-1 grounding -----
class GroundPlayer extends StatefulWidget {
  final VoidCallback onDone;
  const GroundPlayer({super.key, required this.onDone});
  @override
  State<GroundPlayer> createState() => _GroundState();
}

class _GroundState extends State<GroundPlayer> {
  static const stages = [('👀', 5, 'things you can see'), ('✋', 4, 'things you can touch'), ('🎧', 3, 'sounds you can hear'), ('👃', 2, 'things you can smell'), ('👅', 1, 'thing you can taste')];
  int stage = 0;
  final tapped = <int>{};

  void _tap(int k) {
    if (tapped.contains(k)) return;
    HapticFeedback.selectionClick();
    setState(() => tapped.add(k));
    if (tapped.length == stages[stage].$2) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (stage == 4) { widget.onDone(); } else { setState(() { stage++; tapped.clear(); }); }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = stages[stage];
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Column(key: ValueKey(stage), mainAxisSize: MainAxisSize.min, children: [
          Text('Step ${stage + 1} of 5', style: _white.copyWith(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(st.$1, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 10),
          Text('Notice ${st.$2} ${st.$3}', textAlign: TextAlign.center, style: _white.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Tap a circle for each one', style: _white.copyWith(color: Colors.white70)),
          const SizedBox(height: 24),
          Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: [
            for (var k = 0; k < st.$2; k++)
              GestureDetector(
                onTap: () => _tap(k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250), width: 64, height: 64, alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: tapped.contains(k) ? Colors.white : Colors.white24),
                  child: tapped.contains(k) ? const Icon(Icons.check, color: Color(0xFF7B6FD0), size: 32) : Text('${k + 1}', style: _white.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}

// ----- Kind words -----
class AffirmPlayer extends StatefulWidget {
  final List<String> items;
  final VoidCallback onDone;
  const AffirmPlayer({super.key, required this.items, required this.onDone});
  @override
  State<AffirmPlayer> createState() => _AffirmState();
}

class _AffirmState extends State<AffirmPlayer> {
  final pc = PageController(viewportFraction: .86);
  final saved = <int>{};
  int page = 0;

  @override
  Widget build(BuildContext context) => Column(children: [
        const SizedBox(height: 8),
        Text('Swipe  ·  tap ♥ to keep one', style: _white.copyWith(color: Colors.white70)),
        Expanded(
          child: PageView.builder(
            controller: pc, itemCount: widget.items.length, onPageChanged: (p) => setState(() => page = p),
            itemBuilder: (_, i) => AnimatedScale(
              scale: i == page ? 1 : .92, duration: const Duration(milliseconds: 250),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 28), padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white30)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(widget.items[i], textAlign: TextAlign.center, style: _white.copyWith(fontSize: 26, fontWeight: FontWeight.w700, height: 1.3)),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () { HapticFeedback.mediumImpact(); setState(() => saved.contains(i) ? saved.remove(i) : saved.add(i)); },
                    child: AnimatedScale(
                      scale: saved.contains(i) ? 1.3 : 1, duration: const Duration(milliseconds: 250), curve: Curves.elasticOut,
                      child: Icon(saved.contains(i) ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 36),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < widget.items.length; i++)
            AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.all(3), width: i == page ? 20 : 8, height: 8,
                decoration: BoxDecoration(color: i == page ? Colors.white : Colors.white38, borderRadius: BorderRadius.circular(4))),
        ]),
        const SizedBox(height: 10),
        AnimatedOpacity(opacity: page == widget.items.length - 1 ? 1 : 0, duration: const Duration(milliseconds: 300),
            child: TextButton(onPressed: page == widget.items.length - 1 ? widget.onDone : null, child: const Text('I feel a little lighter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
      ]);
}

// ----- Ocean ripples -----
class _Ripple {
  final Offset p;
  final double t;
  _Ripple(this.p, this.t);
}

class ScenePlayer extends StatefulWidget {
  const ScenePlayer({super.key});
  @override
  State<ScenePlayer> createState() => _SceneState();
}

class _SceneState extends State<ScenePlayer> with SingleTickerProviderStateMixin {
  final sw = Stopwatch()..start();
  final ripples = <_Ripple>[];
  late final c = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  double get now => sw.elapsedMilliseconds / 1000;
  @override
  void dispose() { c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Stack(children: [
        GestureDetector(
          onTapDown: (d) {
            HapticFeedback.selectionClick();
            ripples.add(_Ripple(d.localPosition, now));
            if (ripples.length > 12) ripples.removeAt(0);
          },
          child: AnimatedBuilder(
            animation: c,
            builder: (_, __) => CustomPaint(size: Size.infinite, painter: _ScenePainter(now, List.of(ripples))),
          ),
        ),
        Align(alignment: Alignment.topCenter, child: IgnorePointer(child: Padding(padding: const EdgeInsets.only(top: 8), child: Text('Touch the water. Let thoughts drift by.', style: _white.copyWith(color: Colors.white70))))),
      ]);
}

class _ScenePainter extends CustomPainter {
  final double t;
  final List<_Ripple> ripples;
  _ScenePainter(this.t, this.ripples);

  @override
  void paint(Canvas cv, Size s) {
    final star = Paint();
    for (var i = 0; i < 18; i++) {
      star.color = Colors.white.withOpacity(.25 + .35 * (math.sin(t * 1.2 + i) * .5 + .5));
      cv.drawCircle(Offset((i * 73 % 100) / 100 * s.width, (i * 37 % 50) / 100 * s.height), 1.5 + (i % 3), star);
    }
    for (var k = 0; k < 3; k++) {
      final path = Path()..moveTo(0, s.height);
      for (double x = 0; x <= s.width; x += 6) {
        final y = s.height * (.58 + .1 * k) + math.sin(x / s.width * 2 * math.pi * (1.2 + .4 * k) + t * (.6 + .25 * k) + k) * (14 + 4.0 * k);
        path.lineTo(x, y);
      }
      path..lineTo(s.width, s.height)..close();
      cv.drawPath(path, Paint()..color = Colors.white.withOpacity(.12 + .08 * k));
    }
    for (final r in ripples) {
      final age = t - r.t;
      if (age > 3) continue;
      cv.drawCircle(r.p, age * 90, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.white.withOpacity((1 - age / 3) * .7));
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => true;
}


// ----- Worry release -----
class WorryPlayer extends StatefulWidget {
  final VoidCallback onDone;
  const WorryPlayer({super.key, required this.onDone});
  @override
  State<WorryPlayer> createState() => _WorryState();
}

class _WorryState extends State<WorryPlayer> with SingleTickerProviderStateMixin {
  final ctrl = TextEditingController();
  late final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
  int phase = 0; // 0 typing, 1 floating, 2 gone
  String sent = '';

  void _release() {
    sent = ctrl.text.trim();
    ctrl.clear();
    HapticFeedback.mediumImpact();
    setState(() => phase = 1);
    c.forward(from: 0).whenComplete(() { if (mounted) setState(() => phase = 2); });
  }

  @override
  void dispose() { c.dispose(); ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: phase == 1
              ? AnimatedBuilder(
                  animation: c,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(math.sin(c.value * 8) * 12, -300 * Curves.easeIn.transform(c.value)),
                    child: Opacity(
                      opacity: 1 - c.value,
                      child: Transform.scale(
                        scale: 1 - .4 * c.value,
                        child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white.withOpacity(.3), borderRadius: BorderRadius.circular(30)),
                            child: Text(sent, textAlign: TextAlign.center, style: _white.copyWith(fontSize: 20, fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                )
              : phase == 2
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('☁️', style: TextStyle(fontSize: 80)),
                      const SizedBox(height: 12),
                      Text('Breathe out. It is gone for now.', textAlign: TextAlign.center, style: _white.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 20),
                      TextButton(onPressed: () => setState(() => phase = 0), child: const Text('Release another', style: TextStyle(color: Colors.white))),
                      TextButton(onPressed: widget.onDone, child: const Text('I feel lighter', style: TextStyle(color: Colors.white70))),
                    ])
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Text("What's weighing on you?", style: _white.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: ctrl, maxLines: 3, maxLength: 120, onChanged: (_) => setState(() {}),
                        style: _white, cursorColor: Colors.white,
                        decoration: InputDecoration(hintText: 'Type it here...', hintStyle: const TextStyle(color: Colors.white54), counterStyle: const TextStyle(color: Colors.white54),
                            filled: true, fillColor: Colors.white.withOpacity(.18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
                      ),
                      const SizedBox(height: 6),
                      Text('Never saved. It disappears when you let it go.', style: _white.copyWith(color: Colors.white60, fontSize: 12)),
                      const SizedBox(height: 16),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF5B7FA6), minimumSize: const Size(220, 50)),
                        onPressed: ctrl.text.trim().isEmpty ? null : _release, child: const Text('Let it float away'),
                      ),
                    ]),
        ),
      );
}

// ----- Gratitude jar -----
class GratitudePlayer extends StatefulWidget {
  final VoidCallback onDone;
  const GratitudePlayer({super.key, required this.onDone});
  @override
  State<GratitudePlayer> createState() => _GratState();
}

class _GratState extends State<GratitudePlayer> {
  static const cols = [Color(0xFFFFE08A), Color(0xFFFFB5A7), Color(0xFFB5EAD7)];
  final ctrl = TextEditingController();
  final items = <String>[];

  void _add() {
    final t = ctrl.text.trim();
    if (t.isEmpty || items.length >= 3) return;
    HapticFeedback.lightImpact();
    setState(() { items.add(t); ctrl.clear(); });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text(items.length < 3 ? 'One small thing that was okay today (${items.length + 1}/3)' : 'Your jar is full 💛',
              textAlign: TextAlign.center, style: _white.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (items.length < 3)
            Row(children: [
              Expanded(
                child: TextField(
                  controller: ctrl, style: _white, cursorColor: Colors.white, onSubmitted: (_) => _add(),
                  decoration: InputDecoration(hintText: 'e.g. a warm drink', hintStyle: const TextStyle(color: Colors.white54), filled: true,
                      fillColor: Colors.white.withOpacity(.18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
                ),
              ),
              IconButton(onPressed: _add, icon: const Icon(Icons.add_circle, color: Colors.white, size: 36)),
            ]),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 18, left: 30, right: 30), padding: const EdgeInsets.all(14), alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(color: Colors.white.withOpacity(.1), border: Border.all(color: Colors.white54, width: 3),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(44), bottomRight: Radius.circular(44), topLeft: Radius.circular(10), topRight: Radius.circular(10))),
              child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                for (var i = 0; i < items.length; i++)
                  TweenAnimationBuilder<double>(
                    key: ValueKey(i), tween: Tween(begin: 0, end: 1), duration: const Duration(milliseconds: 900), curve: Curves.bounceOut,
                    builder: (_, v, child) => Opacity(opacity: v.clamp(0.0, 1.0), child: Transform.translate(offset: Offset(0, -160 * (1 - v)), child: child)),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: cols[i], borderRadius: BorderRadius.circular(22)),
                        child: Text(items[i], style: const TextStyle(color: Color(0xFF3B3B3B), fontWeight: FontWeight.w600))),
                  ),
              ]),
            ),
          ),
          if (items.length >= 3) TextButton(onPressed: widget.onDone, child: const Text('Keep this feeling', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ]),
      );
}

// ----- Squeeze and release -----
class SqueezePlayer extends StatefulWidget {
  final VoidCallback onDone;
  const SqueezePlayer({super.key, required this.onDone});
  @override
  State<SqueezePlayer> createState() => _SqzState();
}

class _SqzState extends State<SqueezePlayer> {
  static const parts = [('hands', 'Make tight fists'), ('arms', 'Bend and tense your arms'), ('shoulders', 'Lift your shoulders to your ears'),
    ('face', 'Scrunch your face'), ('legs', 'Press your legs and toes tight')];
  int i = 0;
  bool down = false;
  String hint = 'Press and hold the circle';
  final sw = Stopwatch();

  void _down() {
    HapticFeedback.mediumImpact();
    sw..reset()..start();
    setState(() { down = true; hint = 'Squeeze… keep holding…'; });
  }

  void _up() {
    if (!down) return;
    sw.stop();
    final ok = sw.elapsedMilliseconds >= 3000;
    final last = i == parts.length - 1;
    setState(() {
      down = false;
      hint = ok ? 'Let go. Notice the difference.' : 'Hold a little longer (about 3 seconds)';
      if (ok && !last) i++;
    });
    if (ok && last) widget.onDone();
  }

  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Muscle group ${i + 1} of ${parts.length}', style: _white.copyWith(color: Colors.white70)),
        const SizedBox(height: 10),
        Text('Squeeze your ${parts[i].$1}', style: _white.copyWith(fontSize: 26, fontWeight: FontWeight.w800)),
        Text(parts[i].$2, style: _white.copyWith(color: Colors.white70)),
        const SizedBox(height: 28),
        Listener(
          onPointerDown: (_) => _down(), onPointerUp: (_) => _up(), onPointerCancel: (_) => _up(),
          child: SizedBox(
            width: 250, height: 250,
            child: Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: down ? 500 : 1500), curve: Curves.easeInOut,
                width: down ? 120 : 230, height: down ? 120 : 230, alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(down ? .95 : .3)),
                child: Text(down ? 'HOLD' : 'PRESS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2, color: down ? const Color(0xFFB0609A) : Colors.white)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(hint, style: _white.copyWith(fontSize: 16)),
      ]);
}

// ----- Calm doodle -----
class DoodlePlayer extends StatefulWidget {
  const DoodlePlayer({super.key});
  @override
  State<DoodlePlayer> createState() => _DoodleState();
}

class _DoodleState extends State<DoodlePlayer> {
  final strokes = <List<Offset>>[];

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(children: [
          Text('Draw anything. No one will see it.', style: _white.copyWith(color: Colors.white70)),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                color: Colors.white.withOpacity(.14),
                child: GestureDetector(
                  onPanStart: (d) => setState(() => strokes.add([d.localPosition])),
                  onPanUpdate: (d) => setState(() => strokes.last.add(d.localPosition)),
                  child: CustomPaint(size: Size.infinite, painter: _DoodlePainter(strokes)),
                ),
              ),
            ),
          ),
          TextButton.icon(onPressed: () => setState(strokes.clear), icon: const Icon(Icons.refresh, color: Colors.white70), label: const Text('Start fresh', style: TextStyle(color: Colors.white70))),
        ]),
      );
}

class _DoodlePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _DoodlePainter(this.strokes);
  @override
  void paint(Canvas cv, Size s) {
    for (var si = 0; si < strokes.length; si++) {
      final st = strokes[si];
      final p = Paint()..strokeWidth = 9..strokeCap = StrokeCap.round;
      if (st.length == 1) {
        p.color = HSVColor.fromAHSV(.9, (si * 50) % 360.0, .45, 1).toColor();
        cv.drawCircle(st.first, 4.5, p);
      }
      for (var j = 1; j < st.length; j++) {
        p.color = HSVColor.fromAHSV(.9, (si * 50 + j * 4) % 360.0, .45, 1).toColor();
        cv.drawLine(st[j - 1], st[j], p);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _DoodlePainter old) => true;
}

// ----- Body scan -----
class BodyScanPlayer extends StatefulWidget {
  final VoidCallback onDone;
  const BodyScanPlayer({super.key, required this.onDone});
  @override
  State<BodyScanPlayer> createState() => _ScanState();
}

class _ScanState extends State<BodyScanPlayer> {
  static const regions = [('Head', 'Soften your forehead and scalp'), ('Face and jaw', 'Unclench your jaw, relax your eyes'),
    ('Neck and shoulders', 'Let your shoulders drop'), ('Arms and hands', 'Feel the warmth in your hands'),
    ('Chest and breath', 'Notice your breathing without changing it'), ('Belly and hips', 'Let everything go soft'), ('Legs and feet', 'Feel the ground holding you')];
  int i = 0, s = 40;
  Timer? tm;

  @override
  void initState() {
    super.initState();
    tm = Timer.periodic(const Duration(seconds: 1), (_) { if (--s <= 0) _next(); else setState(() {}); });
  }

  void _next() {
    if (i == regions.length - 1) { tm?.cancel(); widget.onDone(); return; }
    setState(() { i++; s = 40; });
  }

  @override
  void dispose() { tm?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: 60, height: 320,
            child: Stack(alignment: Alignment.center, children: [
              Container(width: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              AnimatedAlign(
                duration: const Duration(milliseconds: 1500), curve: Curves.easeInOut, alignment: Alignment(0, -.9 + i * .3),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(.7), blurRadius: 28, spreadRadius: 6)])),
              ),
            ]),
          ),
          const SizedBox(width: 24),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Column(key: ValueKey(i), mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Part ${i + 1} of ${regions.length}', style: _white.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(regions[i].$1, style: _white.copyWith(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(regions[i].$2, style: _white.copyWith(fontSize: 17, height: 1.4)),
                const SizedBox(height: 14),
                TextButton(onPressed: _next, style: TextButton.styleFrom(padding: EdgeInsets.zero), child: const Text('Next part  →', style: TextStyle(color: Colors.white70))),
              ]),
            ),
          ),
        ]),
      );
}
