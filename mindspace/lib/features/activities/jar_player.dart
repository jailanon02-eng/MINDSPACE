import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../all.dart';

/// items = [jarKey, prompt, hint]. Shows every word saved so far and lets you add more.
class JarPlayer extends StatefulWidget {
  final List<String> items;
  final VoidCallback onDone;
  const JarPlayer({super.key, required this.items, required this.onDone});
  @override
  State<JarPlayer> createState() => _JarState();
}

class _JarState extends State<JarPlayer> {
  static const cols = [
    Color(0xFFFFE08A),
    Color(0xFFFFB5A7),
    Color(0xFFB5EAD7),
    Color(0xFFC9B6FF),
    Color(0xFFA8D8FF),
  ];
  final ctrl = TextEditingController();
  List<JarWord> words = [];
  bool cloud = false, loaded = false;
  String get key => widget.items[0];

  @override
  void initState() {
    super.initState();
    JarService.load(key).then((w) async {
      final c = await ProgressService.cloudEnabled();
      if (mounted)
        setState(() {
          words = w;
          cloud = c;
          loaded = true;
        });
    });
  }

  Future<void> _add() async {
    final t = ctrl.text.trim();
    if (t.isEmpty) return;
    HapticFeedback.lightImpact();
    ctrl.clear();
    final w = await JarService.add(key, t);
    if (mounted) setState(() => words.insert(0, w));
  }

  void _remove(JarWord w) => showDialog(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('Remove this word?'),
      content: Text(w.text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Keep'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(d);
            JarService.remove(w.id);
            setState(() => words.remove(w));
          },
          child: const Text('Remove'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        Text(
          widget.items[1],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                maxLength: 80,
                onSubmitted: (_) => _add(),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: widget.items[2],
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: .18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _add,
              icon: const Icon(Icons.add_circle, color: Colors.white, size: 36),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          !loaded
              ? ''
              : '${words.length} ${words.length == 1 ? 'word' : 'words'} in your jar  ·  saved on this device${cloud ? ' and your account' : ''}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .1),
              border: Border.all(color: Colors.white54, width: 3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(44),
                bottomRight: Radius.circular(44),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: words.isEmpty
                ? Center(
                    child: Text(
                      loaded ? 'Your jar is empty. Add your first word.' : '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (var i = 0; i < words.length; i++)
                          TweenAnimationBuilder<double>(
                            key: ValueKey(words[i].id),
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 400 + (i < 10 ? i * 60 : 600),
                            ),
                            curve: Curves.easeOutBack,
                            builder: (_, v, child) => Transform.scale(
                              scale: v.clamp(0.0, 1.2),
                              child: child,
                            ),
                            child: GestureDetector(
                              onTap: () => _remove(words[i]),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: cols[i % cols.length],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  words[i].text,
                                  style: const TextStyle(
                                    color: Color(0xFF3B3B3B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ),
        TextButton(
          onPressed: widget.onDone,
          child: const Text(
            'Finish',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
