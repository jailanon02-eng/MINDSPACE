import 'package:flutter/material.dart';
import '../../all.dart';


class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});
  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? sel;
  bool busy = false;
  final ctrl = TextEditingController();
  static const moods = [('Great', '😄'), ('Good', '🙂'), ('Okay', '😐'), ('Sad', '😢'), ('Anxious', '😰'), ('Stressed', '😣')];

  Future<void> _submit() async {
    setState(() => busy = true);
    await DbService.addMood(moods[sel!].$1, ctrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for checking in 💚')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(padding: const EdgeInsets.all(24), children: [
              Text('How are you feeling right now?', style: kTitle.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              const Text('Only you can see this. There are no wrong answers.', style: TextStyle(color: kMuted)),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12, crossAxisSpacing: 12,
                children: [
                  for (var i = 0; i < moods.length; i++)
                    GestureDetector(
                      onTap: () => setState(() => sel = i),
                      child: AnimatedScale(
                        scale: sel == i ? 1.05 : 1, duration: const Duration(milliseconds: 150),
                        child: Box(
                          selected: sel == i,
                          color: sel == i ? kPrimary.withValues(alpha: .1) : Colors.white,
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(moods[i].$2, style: const TextStyle(fontSize: 38)),
                            const SizedBox(height: 6),
                            Text(moods[i].$1, style: const TextStyle(fontWeight: FontWeight.w600, color: kText)),
                          ]),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: ctrl, maxLines: 4, maxLength: 200,
                decoration: fieldDec('Anything you want to add? (optional)', Icons.edit_note),
              ),
              const SizedBox(height: 12),
              PrimaryButton(busy ? 'Saving...' : 'Save check-in', onTap: sel == null || busy ? null : _submit),
            ]),
          ),
        ),
      );
}
