import 'package:flutter/material.dart';
import '../../all.dart';


class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _open(String f) {
    activityFilter.value = f;
    currentTab.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    const focus = [
      ('Anxiety', Icons.waves, Color(0xFF4A90D9)),
      ('Stress', Icons.local_fire_department_outlined, Color(0xFFE9895B)),
      ('Eating', Icons.restaurant_outlined, Color(0xFF3FA796)),
      ('Depression', Icons.cloud_outlined, Color(0xFF7B9E9A)),
    ];
    const labels = {'Stress': 'Burnout & Stress', 'Eating': 'Food & Body Image', 'Depression': 'Low Mood'};
    const icons = {'Read': Icons.menu_book, 'Play': Icons.sports_esports, 'Watch': Icons.play_circle_outline, 'Move': Icons.self_improvement, 'Breathe': Icons.air};
    return ListView(padding: const EdgeInsets.all(20), children: [
      StreamBuilder<UserProfile?>(
        stream: DbService.profile(),
        builder: (_, s) => Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hi, ${s.data?.name ?? ''} 👋', style: kTitle.copyWith(fontSize: 26)),
              const Text('Take a breath. A few minutes is enough.', style: TextStyle(color: kMuted)),
            ]),
          ),
          IconButton(onPressed: () => showDialog(context: context, builder: (d) => AlertDialog(
            title: const Text('Need urgent help?'), content: const Text(kCrisisInfo),
            actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('Close'))])),
              icon: const Icon(Icons.sos_outlined, color: Colors.redAccent)),
        ]),
      ),
      const SizedBox(height: 18),
      InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodScreen())),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [kPrimary, Color(0xFF7BC0B8)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: const Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('How are you feeling?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 6),
              Text('A 10-second check-in, completely private.', style: TextStyle(color: Colors.white70)),
            ])),
            Icon(Icons.arrow_circle_right_outlined, color: Colors.white, size: 36),
          ]),
        ),
      ),
      const SizedBox(height: 24),
      Text("What's on your mind?", style: kTitle.copyWith(fontSize: 18)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2,
        children: [
          for (final f in focus)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _open(f.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: f.$3.withOpacity(.14), borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Icon(f.$2, color: f.$3),
                  const SizedBox(width: 8),
                  Expanded(child: Text(labels[f.$1] ?? f.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 13))),
                ]),
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Text('Take 5 minutes to…', style: kTitle.copyWith(fontSize: 18)),
      const SizedBox(height: 12),
      SizedBox(
        height: 92,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final t in kTypes)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _open(t),
                child: Container(
                  width: 82,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFDCE9E6))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(icons[t], color: kPrimary, size: 28),
                    const SizedBox(height: 6),
                    Text(t, style: const TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  ]),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 24),
      Box(
        child: Row(children: [
          const IconBadge(Icons.event_available, kAccent),
          const SizedBox(width: 12),
          const Expanded(child: Text('Talk to a professional', style: TextStyle(fontWeight: FontWeight.w700, color: kText))),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookScreen())), child: const Text('Book')),
        ]),
      ),
    ]);
  }
}
