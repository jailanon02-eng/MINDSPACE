import 'package:flutter/material.dart';
import '../../all.dart';

class ResourcesTab extends StatefulWidget {
  const ResourcesTab({super.key});
  @override
  State<ResourcesTab> createState() => _ResourcesTabState();
}

class _ResourcesTabState extends State<ResourcesTab> {
  String filter = 'All', query = '';
  static const items = [
    ('How to Manage Stress', 'Learn simple techniques', 'Stress', Color(0xFFE8B16B)),
    ('Understanding Anxiety', 'Know what to do', 'Anxiety', Color(0xFF5C7C99)),
    ('Self-Care for Better Days', 'Small steps, big impact', 'Self-Care', Color(0xFF7EB5D6)),
    ('Student Wellness', 'Tips for a healthy mind', 'Stress', Color(0xFF455A73)),
  ];

  @override
  Widget build(BuildContext context) {
    final shown = items.where((e) =>
        (filter == 'All' || e.$3 == filter) && e.$1.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Wellness Resources', style: kTitle),
      const Text('Explore helpful guides and tips.', style: TextStyle(color: kMuted)),
      const SizedBox(height: 14),
      TextField(
        onChanged: (v) => setState(() => query = v),
        decoration: InputDecoration(
          hintText: 'Search resources...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: const Color(0xFFE9E7F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final c in ['All', 'Stress', 'Anxiety', 'Self-Care'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c), selected: filter == c, selectedColor: kPrimary,
                labelStyle: TextStyle(color: filter == c ? Colors.white : kText),
                onSelected: (_) => setState(() => filter = c),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      for (final e in shown)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Box(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(colors: [e.$4, e.$4.withOpacity(.5)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: const Icon(Icons.landscape, color: Colors.white70, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 4),
                Text(e.$2, style: const TextStyle(fontSize: 12, color: kPrimary)),
              ])),
              const Icon(Icons.chevron_right, color: kMuted),
            ]),
          ),
        ),
    ]);
  }
}
