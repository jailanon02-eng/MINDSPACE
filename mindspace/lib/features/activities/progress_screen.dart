import 'package:flutter/material.dart';

import '../../all.dart';

DateTime _day(DateTime x) => DateTime(x.year, x.month, x.day);

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressState();
}

class _ProgressState extends State<ProgressScreen> {
  List<ProgressEntry>? list;
  Map<String, List<JarWord>> jars = {};
  bool cloud = false, busy = false;

  @override
  void initState() {
    super.initState();
    _load();
    ProgressService.changes.addListener(_load);
  }

  @override
  void dispose() {
    ProgressService.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final l = await ProgressService.loadLocal(),
        c = await ProgressService.cloudEnabled();
    final g = await JarService.load('gratitude'),
        k = await JarService.load('compliment');
    if (mounted)
      setState(() {
        list = l;
        cloud = c;
        jars = {'Gratitude jar': g, 'Compliment jar': k};
      });
  }

  Future<void> _toggle(bool v) async {
    setState(() => busy = true);
    await ProgressService.setCloud(v);
    await _load();
    if (mounted) setState(() => busy = false);
  }

  Future<void> _restore() async {
    setState(() => busy = true);
    await ProgressService.restore();
    if (mounted) {
      setState(() => busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restored from your account.')),
      );
    }
  }

  int _mins(Iterable<ProgressEntry> e) =>
      (e.fold<int>(0, (a, b) => a + b.seconds) / 60).round();

  Widget _stat(String label, String value) => Expanded(
    child: Box(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value, style: kTitle.copyWith(fontSize: 24, color: kPrimary)),
          Text(label, style: const TextStyle(color: kMuted, fontSize: 12)),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = list;
    if (l == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final today = _day(DateTime.now());
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final perDay = [
      for (final d in days) _mins(l.where((e) => _day(e.at) == d)),
    ];
    final peak = perDay.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);
    String label(DateTime d) => d == today
        ? 'Today'
        : d == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : fmtDate(d);
    return Scaffold(
      appBar: AppBar(title: const Text('My progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              _stat('Today', '${perDay.last} min'),
              const SizedBox(width: 10),
              _stat(
                'Last 7 days',
                '${perDay.fold<int>(0, (a, b) => a + b)} min',
              ),
              const SizedBox(width: 10),
              _stat('All time', '${_mins(l)} min'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l.length} sessions. Every minute counts, and rest days are part of it. 💚',
            style: const TextStyle(color: kMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Box(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: cloud,
                  activeThumbColor: kPrimary,
                  onChanged: busy ? null : _toggle,
                  title: const Text(
                    'Also save to my account',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    cloud
                        ? 'Progress and jar words are backed up, so you can restore them on another device.'
                        : 'Right now everything is saved only on this device.',
                  ),
                ),
                if (cloud)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: busy ? null : _restore,
                      icon: const Icon(Icons.cloud_download_outlined),
                      label: const Text('Restore from my account'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Last 7 days', style: kTitle.copyWith(fontSize: 18)),
          const SizedBox(height: 10),
          Box(
            child: SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            perDay[i] > 0 ? '${perDay[i]}' : '',
                            style: const TextStyle(fontSize: 10, color: kMuted),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: 6 + 70 * perDay[i] / peak,
                            ),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (_, h, _) => Container(
                              width: 18,
                              height: h,
                              decoration: BoxDecoration(
                                color: days[i] == today
                                    ? kPrimary
                                    : kPrimary.withValues(alpha: .35),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'MTWTFSS'[days[i].weekday - 1],
                            style: TextStyle(
                              fontSize: 11,
                              color: days[i] == today ? kPrimary : kMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('My jars', style: kTitle.copyWith(fontSize: 18)),
          const SizedBox(height: 10),
          for (final e in jars.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Box(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key}  ·  ${e.value.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    e.value.isEmpty
                        ? const Text(
                            'No words yet.',
                            style: TextStyle(color: kMuted),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final w in e.value)
                                Chip(
                                  label: Text(w.text),
                                  backgroundColor: kPrimary.withValues(
                                    alpha: .1,
                                  ),
                                  side: BorderSide.none,
                                ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text('History', style: kTitle.copyWith(fontSize: 18)),
          const SizedBox(height: 10),
          if (l.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Nothing yet. Your first Take 5 will appear here.',
                  style: TextStyle(color: kMuted),
                ),
              ),
            ),
          for (var i = 0; i < l.length; i++) ...[
            if (i == 0 || _day(l[i].at) != _day(l[i - 1].at))
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Text(
                  label(_day(l[i].at)),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kMuted,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Box(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      l[i].completed ? Icons.check_circle : Icons.timelapse,
                      color: l[i].completed ? kPrimary : kMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l[i].title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kText,
                            ),
                          ),
                          Text(
                            '${l[i].type}${l[i].completed ? '' : ' · stopped early'}',
                            style: const TextStyle(color: kMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l[i].seconds >= 60
                          ? '${(l[i].seconds / 60).round()} min'
                          : '${l[i].seconds} s',
                      style: const TextStyle(color: kMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
