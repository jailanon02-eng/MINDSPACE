import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_service.dart';

class ProgressEntry {
  final String id, title, type;
  final int seconds;
  final bool completed;
  final DateTime at;
  ProgressEntry(
    this.id,
    this.title,
    this.type,
    this.seconds,
    this.completed,
    this.at,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'seconds': seconds,
    'completed': completed,
    'at': at.millisecondsSinceEpoch,
  };
  factory ProgressEntry.fromJson(Map<String, dynamic> m) => ProgressEntry(
    m['id'],
    m['title'],
    m['type'] ?? '',
    m['seconds'],
    m['completed'] ?? true,
    DateTime.fromMillisecondsSinceEpoch(m['at']),
  );
}

/// Progress is always saved on this device. If the user turns on "Save to my account",
/// it is also stored in Firestore (users/{uid}/activity) and can be restored on another device.
class ProgressService {
  static final todayMin = ValueNotifier<int>(0);
  static final changes = ValueNotifier<int>(0);
  static String get _u => FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  static DocumentReference<Map<String, dynamic>> get _user =>
      FirebaseFirestore.instance.collection('users').doc(_u);

  static Future<bool> cloudEnabled() async =>
      (await SharedPreferences.getInstance()).getBool('cloud_$_u') ?? false;
  static Future<void> setCloud(bool v) async {
    await (await SharedPreferences.getInstance()).setBool('cloud_$_u', v);
    if (v) {
      await _push(await loadLocal());
      await JarService.pushAll();
    }
  }

  static Future<List<ProgressEntry>> loadLocal() async {
    final raw =
        (await SharedPreferences.getInstance()).getStringList('progress_$_u') ??
        <String>[];
    return [for (final s in raw) ProgressEntry.fromJson(jsonDecode(s))]
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  static Future<void> _save(List<ProgressEntry> l) async =>
      (await SharedPreferences.getInstance()).setStringList('progress_$_u', [
        for (final e in l) jsonEncode(e.toJson()),
      ]);

  static Future<void> refresh() async {
    final n = DateTime.now();
    final secs = (await loadLocal())
        .where(
          (e) =>
              e.at.year == n.year && e.at.month == n.month && e.at.day == n.day,
        )
        .fold<int>(0, (a, e) => a + e.seconds);
    todayMin.value = (secs / 60).round();
    changes.value++;
  }

  static Future<void> log(
    String title,
    String type,
    int seconds,
    bool completed,
  ) async {
    final e = ProgressEntry(
      '${DateTime.now().microsecondsSinceEpoch}',
      title,
      type,
      seconds,
      completed,
      DateTime.now(),
    );
    final l = await loadLocal();
    l.add(e);
    await _save(l);
    await refresh();
    if (await cloudEnabled()) await _push([e]);
  }

  static Future<void> saveFeeling(String feeling) async {
    await (await SharedPreferences.getInstance()).setString(
      'feeling_$_u',
      feeling,
    );
    if (await cloudEnabled()) {
      try {
        await DbService.addMood(feeling, '');
      } catch (_) {}
    }
  }

  static Future<void> _push(List<ProgressEntry> es) async {
    try {
      for (var i = 0; i < es.length; i += 400) {
        final b = FirebaseFirestore.instance.batch();
        for (final e in es.skip(i).take(400)) {
          b.set(_user.collection('activity').doc(e.id), {
            'title': e.title,
            'type': e.type,
            'seconds': e.seconds,
            'completed': e.completed,
            'at': Timestamp.fromDate(e.at),
          });
        }
        await b.commit();
      }
    } catch (_) {}
  }

  static Future<void> restore() async {
    final s = await _user.collection('activity').get();
    final l = await loadLocal();
    final have = {for (final e in l) e.id};
    for (final d in s.docs) {
      if (have.contains(d.id)) continue;
      final m = d.data();
      l.add(
        ProgressEntry(
          d.id,
          m['title'] ?? '',
          m['type'] ?? '',
          (m['seconds'] ?? 0) as int,
          m['completed'] ?? true,
          (m['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ),
      );
    }
    await _save(l);
    await JarService.restore();
    await refresh();
  }
}

class JarWord {
  final String id, key, text;
  final DateTime at;
  JarWord(this.id, this.key, this.text, this.at);
  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'text': text,
    'at': at.millisecondsSinceEpoch,
  };
  factory JarWord.fromJson(Map<String, dynamic> m) => JarWord(
    m['id'],
    m['key'],
    m['text'],
    DateTime.fromMillisecondsSinceEpoch(m['at']),
  );
}

/// Words typed into the Gratitude jar and Compliment jar. Saved on the device; optionally in users/{uid}/jar.
class JarService {
  static Future<List<JarWord>> _all() async {
    final raw =
        (await SharedPreferences.getInstance()).getStringList(
          'jar_${ProgressService._u}',
        ) ??
        <String>[];
    return [for (final s in raw) JarWord.fromJson(jsonDecode(s))];
  }

  static Future<void> _save(List<JarWord> l) async =>
      (await SharedPreferences.getInstance()).setStringList(
        'jar_${ProgressService._u}',
        [for (final w in l) jsonEncode(w.toJson())],
      );

  static Future<List<JarWord>> load(String key) async =>
      (await _all()).where((w) => w.key == key).toList()
        ..sort((a, b) => b.at.compareTo(a.at));

  static CollectionReference<Map<String, dynamic>> get _col =>
      ProgressService._user.collection('jar');
  static Map<String, dynamic> _m(JarWord w) => {
    'key': w.key,
    'text': w.text,
    'at': Timestamp.fromDate(w.at),
  };

  static Future<JarWord> add(String key, String text) async {
    final w = JarWord(
      '${DateTime.now().microsecondsSinceEpoch}',
      key,
      text,
      DateTime.now(),
    );
    final l = await _all();
    l.add(w);
    await _save(l);
    if (await ProgressService.cloudEnabled()) {
      try {
        await _col.doc(w.id).set(_m(w));
      } catch (_) {}
    }
    return w;
  }

  static Future<void> remove(String id) async {
    final l = await _all();
    l.removeWhere((w) => w.id == id);
    await _save(l);
    if (await ProgressService.cloudEnabled()) {
      try {
        await _col.doc(id).delete();
      } catch (_) {}
    }
  }

  static Future<void> pushAll() async {
    for (final w in await _all()) {
      try {
        await _col.doc(w.id).set(_m(w));
      } catch (_) {}
    }
  }

  static Future<void> restore() async {
    final s = await _col.get();
    final l = await _all();
    final have = {for (final w in l) w.id};
    for (final d in s.docs) {
      if (have.contains(d.id)) continue;
      final m = d.data();
      l.add(
        JarWord(
          d.id,
          m['key'] ?? 'gratitude',
          m['text'] ?? '',
          (m['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ),
      );
    }
    await _save(l);
  }
}
