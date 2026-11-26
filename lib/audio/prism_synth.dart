/// Pure-Dart procedural 16-bit PCM synthesizer for PRISM FORGE.
///
/// Generates warm pentatonic marimba chords, crystalline chimes, frost cracks,
/// seal shatters, and quantum nova booms offline with zero bundled audio files.
library;

import 'dart:math' as math;
import 'dart:typed_data';

enum PrismSoundCue {
  pickup,
  place,
  rotate,
  frostCrack,
  lockBreak,
  prismBlast,
  nova,
  fail,
}

class PrismSynth {
  const PrismSynth._();

  static const int sampleRate = 22050;

  /// C5–E6 bright pentatonic scale for ascending streak melodies.
  static const List<double> pentatonicScale = <double>[
    523.25,
    587.33,
    659.25,
    783.99,
    880.00,
    1046.50,
    1174.66,
    1318.51,
  ];

  static Uint8List synthesizeCue(PrismSoundCue cue) {
    switch (cue) {
      case PrismSoundCue.pickup:
        return _mixNotes(const <_Note>[
          _Note(freq: 420, startSec: 0.0, durSec: 0.06, amp: 0.22),
          _Note(freq: 640, startSec: 0.02, durSec: 0.06, amp: 0.16),
        ], totalSec: 0.10);
      case PrismSoundCue.place:
        return _mixNotes(const <_Note>[
          _Note(
            freq: 195,
            startSec: 0.0,
            durSec: 0.09,
            amp: 0.34,
            triangle: true,
          ),
          _Note(freq: 310, startSec: 0.015, durSec: 0.06, amp: 0.18),
        ], totalSec: 0.11);
      case PrismSoundCue.rotate:
        return _mixNotes(const <_Note>[
          _Note(freq: 520, startSec: 0.0, durSec: 0.06, amp: 0.22),
          _Note(
            freq: 760,
            startSec: 0.04,
            durSec: 0.09,
            amp: 0.22,
            triangle: true,
          ),
        ], totalSec: 0.15);
      case PrismSoundCue.frostCrack:
        return _mixNotes(const <_Note>[
          _Note(
            freq: 1180,
            startSec: 0.0,
            durSec: 0.07,
            amp: 0.22,
            triangle: true,
          ),
          _Note(freq: 1620, startSec: 0.03, durSec: 0.10, amp: 0.20),
        ], totalSec: 0.15);
      case PrismSoundCue.lockBreak:
        return _mixNotes(const <_Note>[
          _Note(
            freq: 320,
            startSec: 0.0,
            durSec: 0.12,
            amp: 0.24,
            triangle: true,
          ),
          _Note(freq: 880, startSec: 0.05, durSec: 0.18, amp: 0.26),
        ], totalSec: 0.25);
      case PrismSoundCue.prismBlast:
        return _mixNotes(const <_Note>[
          _Note(freq: 523.25, startSec: 0.00, durSec: 0.30, amp: 0.22),
          _Note(freq: 659.25, startSec: 0.045, durSec: 0.30, amp: 0.22),
          _Note(freq: 783.99, startSec: 0.09, durSec: 0.30, amp: 0.22),
          _Note(freq: 1046.50, startSec: 0.135, durSec: 0.32, amp: 0.24),
          _Note(freq: 1318.51, startSec: 0.18, durSec: 0.34, amp: 0.20),
        ], totalSec: 0.56);
      case PrismSoundCue.nova:
        return _mixNotes(const <_Note>[
          _Note(
            freq: 115,
            startSec: 0.0,
            durSec: 0.34,
            amp: 0.34,
            triangle: true,
          ),
          _Note(
            freq: 240,
            startSec: 0.04,
            durSec: 0.26,
            amp: 0.26,
            triangle: true,
          ),
          _Note(freq: 920, startSec: 0.08, durSec: 0.30, amp: 0.22),
        ], totalSec: 0.42);
      case PrismSoundCue.fail:
        return _mixNotes(const <_Note>[
          _Note(
            freq: 240,
            startSec: 0.0,
            durSec: 0.18,
            amp: 0.24,
            triangle: true,
          ),
          _Note(freq: 175, startSec: 0.12, durSec: 0.28, amp: 0.24),
        ], totalSec: 0.42);
    }
  }

  /// Synthesizes an ascending pentatonic chord scaled to [streak] and [lines].
  static Uint8List synthesizeClearChord({
    required int streak,
    required int lines,
    required bool resonance,
  }) {
    final baseIdx = (streak - 1).clamp(0, pentatonicScale.length - 3);
    final noteCount = (lines + (resonance ? 2 : 1)).clamp(2, 4);
    final notes = <_Note>[];
    for (var i = 0; i < noteCount; i++) {
      final f =
          pentatonicScale[(baseIdx + i).clamp(0, pentatonicScale.length - 1)];
      notes.add(
        _Note(
          freq: f,
          startSec: i * 0.055,
          durSec: 0.24,
          amp: 0.26,
          triangle: true,
        ),
      );
      notes.add(
        _Note(freq: f * 2, startSec: i * 0.055 + 0.01, durSec: 0.15, amp: 0.10),
      );
    }
    return _mixNotes(notes, totalSec: noteCount * 0.055 + 0.28);
  }

  static Uint8List _mixNotes(List<_Note> notes, {required double totalSec}) {
    final totalSamples = (totalSec * sampleRate).round();
    final samples = Float64List(totalSamples);

    for (final note in notes) {
      final startIdx = (note.startSec * sampleRate).round();
      final durSamples = (note.durSec * sampleRate).round();
      final endIdx = math.min(totalSamples, startIdx + durSamples);
      for (var i = startIdx; i < endIdx; i++) {
        final localT = (i - startIdx) / sampleRate;
        final progress = (i - startIdx) / math.max(1, durSamples);
        final attack = (localT / 0.008).clamp(0.0, 1.0);
        final decay = math.exp(-progress * 4.2);
        final phase = localT * note.freq * 2 * math.pi;
        final wave = note.triangle
            ? (2.0 / math.pi) * math.asin(math.sin(phase))
            : math.sin(phase);
        samples[i] += wave * note.amp * attack * decay;
      }
    }

    final byteData = ByteData(totalSamples * 2);
    for (var i = 0; i < totalSamples; i++) {
      final clamped = samples[i].clamp(-0.95, 0.95);
      byteData.setInt16(i * 2, (clamped * 32767).round(), Endian.little);
    }
    return byteData.buffer.asUint8List();
  }
}

class _Note {
  const _Note({
    required this.freq,
    required this.startSec,
    required this.durSec,
    required this.amp,
    this.triangle = false,
  });

  final double freq;
  final double startSec;
  final double durSec;
  final double amp;
  final bool triangle;
}
