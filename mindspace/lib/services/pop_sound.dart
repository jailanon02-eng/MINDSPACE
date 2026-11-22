import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// A soft "pop" generated in code, so no sound files are needed.
class PopSound {
  static final Uint8List _wav = _make();
  static final _players = <AudioPlayer>[];
  static int _i = 0;

  static void pop() {
    HapticFeedback.lightImpact();
    try {
      if (_players.isEmpty) {
        for (var k = 0; k < 4; k++) {
          _players.add(AudioPlayer());
        }
      }
      _players[_i++ % 4]
          .play(BytesSource(_wav, mimeType: 'audio/wav'), volume: .9)
          .catchError((_) {});
    } catch (_) {}
  }

  static Uint8List _make() {
    const sr = 22050;
    final n = (sr * .14).toInt();
    final d = ByteData(44 + n * 2);
    void tag(int o, String t) {
      for (var i = 0; i < 4; i++) {
        d.setUint8(o + i, t.codeUnitAt(i));
      }
    }

    tag(0, 'RIFF');
    d.setUint32(4, 36 + n * 2, Endian.little);
    tag(8, 'WAVE');
    tag(12, 'fmt ');
    d.setUint32(16, 16, Endian.little);
    d.setUint16(20, 1, Endian.little);
    d.setUint16(22, 1, Endian.little);
    d.setUint32(24, sr, Endian.little);
    d.setUint32(28, sr * 2, Endian.little);
    d.setUint16(32, 2, Endian.little);
    d.setUint16(34, 16, Endian.little);
    tag(36, 'data');
    d.setUint32(40, n * 2, Endian.little);
    var phase = 0.0;
    for (var i = 0; i < n; i++) {
      final t = i / sr;
      phase += 2 * math.pi * (900 * math.exp(-t * 28) + 180) / sr;
      d.setInt16(
        44 + i * 2,
        (math.sin(phase) * math.exp(-t * 34) * .9 * 32767).toInt(),
        Endian.little,
      );
    }
    return d.buffer.asUint8List();
  }
}
