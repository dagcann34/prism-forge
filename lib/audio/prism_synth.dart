/// Pure-Dart procedural 16-bit PCM "Cıvıl Cıvıl" synthesizer for PRISM FORGE.
///
/// Multi-voice musical synthesis with zero bundled audio files:
/// - Marimba / Kalimba (fundamental + 2x triangle + 3.98x bright wood overtone)
/// - Crystal Glockenspiel (1x + 2.756x + 5.404x shimmering bell partials)
/// - Triumphant Brass-Bell Fanfare (warm harmonics + 5.5Hz vibrato + glock layer)
/// - Sparkle High-Pass Ice Dust noise + pitch-glide pops + soft master limiter
library;

import 'dart:math' as math;
import 'dart:typed_data';

enum PrismSoundCue {
  pickup,
  place,
  rotate,
  hold,
  frostCrack,
  lockBreak,
  prismBlast,
  prismTempered,
  feverStart,
  achievementUnlock,
  nova,
  stageClear,
  allClear,
  fail,
}

enum _Voice { sine, triangle, marimba, glock, brassBell, sparkleNoise }

class PrismSynth {
  const PrismSynth._();

  static const int sampleRate = 22050;

  /// C5–C7 joyful major pentatonic scale.
  static const List<double> pentatonicScale = <double>[
    523.25,
    587.33,
    659.25,
    783.99,
    880.00,
    1046.50,
    1174.66,
    1318.51,
    1567.98,
    1760.00,
    2093.00,
  ];

  static Uint8List synthesizeCue(PrismSoundCue cue) {
    switch (cue) {
      case PrismSoundCue.pickup:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.sine,
            freq: 392.0,
            endFreq: 659.25,
            startSec: 0.0,
            durSec: 0.055,
            amp: 0.28,
            decay: 7.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1046.5,
            startSec: 0.015,
            durSec: 0.08,
            amp: 0.16,
            decay: 11.0,
          ),
        ], totalSec: 0.11);

      case PrismSoundCue.place:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.marimba,
            freq: 230.0,
            endFreq: 261.63,
            startSec: 0.0,
            durSec: 0.10,
            amp: 0.36,
            decay: 8.5,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 523.25,
            startSec: 0.012,
            durSec: 0.095,
            amp: 0.24,
            decay: 10.0,
          ),
        ], totalSec: 0.14);

      case PrismSoundCue.rotate:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.sine,
            freq: 440.0,
            endFreq: 783.99,
            startSec: 0.0,
            durSec: 0.075,
            amp: 0.24,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.triangle,
            freq: 1046.5,
            endFreq: 1174.66,
            startSec: 0.045,
            durSec: 0.095,
            amp: 0.20,
            decay: 8.5,
          ),
        ], totalSec: 0.15);

      case PrismSoundCue.hold:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.marimba,
            freq: 659.25,
            endFreq: 493.88,
            startSec: 0.0,
            durSec: 0.07,
            amp: 0.24,
            decay: 8.0,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 523.25,
            endFreq: 880.0,
            startSec: 0.055,
            durSec: 0.105,
            amp: 0.27,
            decay: 7.5,
          ),
        ], totalSec: 0.17);

      case PrismSoundCue.frostCrack:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.sparkleNoise,
            freq: 4500.0,
            startSec: 0.0,
            durSec: 0.03,
            amp: 0.18,
            decay: 14.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1760.0,
            startSec: 0.000,
            durSec: 0.13,
            amp: 0.18,
            decay: 9.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2349.3,
            startSec: 0.022,
            durSec: 0.13,
            amp: 0.18,
            decay: 9.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2637.0,
            startSec: 0.045,
            durSec: 0.13,
            amp: 0.18,
            decay: 9.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 3136.0,
            startSec: 0.070,
            durSec: 0.13,
            amp: 0.18,
            decay: 9.0,
          ),
        ], totalSec: 0.22);

      case PrismSoundCue.lockBreak:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.triangle,
            freq: 392.0,
            endFreq: 587.33,
            startSec: 0.0,
            durSec: 0.075,
            amp: 0.24,
            decay: 9.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 783.99,
            startSec: 0.030,
            durSec: 0.20,
            amp: 0.23,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 987.77,
            startSec: 0.075,
            durSec: 0.20,
            amp: 0.23,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1567.98,
            startSec: 0.120,
            durSec: 0.22,
            amp: 0.24,
            decay: 5.0,
          ),
        ], totalSec: 0.34);

      case PrismSoundCue.prismBlast:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.triangle,
            freq: 261.63,
            startSec: 0.0,
            durSec: 0.36,
            amp: 0.24,
            decay: 4.5,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 523.25,
            startSec: 0.000,
            durSec: 0.30,
            amp: 0.22,
            decay: 4.8,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 659.25,
            startSec: 0.038,
            durSec: 0.30,
            amp: 0.20,
            decay: 4.8,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 783.99,
            startSec: 0.076,
            durSec: 0.30,
            amp: 0.22,
            decay: 4.8,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 987.77,
            startSec: 0.114,
            durSec: 0.30,
            amp: 0.20,
            decay: 4.8,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 1174.66,
            startSec: 0.152,
            durSec: 0.30,
            amp: 0.22,
            decay: 4.8,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1567.98,
            startSec: 0.190,
            durSec: 0.32,
            amp: 0.21,
            decay: 4.5,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2093.00,
            startSec: 0.228,
            durSec: 0.34,
            amp: 0.20,
            decay: 4.2,
          ),
        ], totalSec: 0.60);

      case PrismSoundCue.prismTempered:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.marimba,
            freq: 523.25,
            startSec: 0.00,
            durSec: 0.16,
            amp: 0.24,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 659.25,
            startSec: 0.04,
            durSec: 0.16,
            amp: 0.24,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 783.99,
            startSec: 0.08,
            durSec: 0.16,
            amp: 0.24,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 1046.50,
            startSec: 0.14,
            durSec: 0.44,
            amp: 0.24,
            decay: 3.4,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1567.98,
            startSec: 0.16,
            durSec: 0.38,
            amp: 0.18,
            decay: 4.2,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2093.00,
            startSec: 0.20,
            durSec: 0.36,
            amp: 0.16,
            decay: 4.5,
          ),
        ], totalSec: 0.62);

      case PrismSoundCue.feverStart:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.marimba,
            freq: 523.25,
            startSec: 0.000,
            durSec: 0.16,
            amp: 0.22,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 587.33,
            startSec: 0.035,
            durSec: 0.16,
            amp: 0.20,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 659.25,
            startSec: 0.070,
            durSec: 0.16,
            amp: 0.22,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 783.99,
            startSec: 0.105,
            durSec: 0.16,
            amp: 0.20,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 880.00,
            startSec: 0.140,
            durSec: 0.16,
            amp: 0.22,
            decay: 6.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1046.50,
            startSec: 0.175,
            durSec: 0.18,
            amp: 0.22,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 1046.50,
            startSec: 0.22,
            durSec: 0.52,
            amp: 0.22,
            decay: 3.2,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 1567.98,
            startSec: 0.22,
            durSec: 0.52,
            amp: 0.20,
            decay: 3.2,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2093.00,
            startSec: 0.24,
            durSec: 0.46,
            amp: 0.18,
            decay: 3.8,
          ),
        ], totalSec: 0.76);

      case PrismSoundCue.achievementUnlock:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.glock,
            freq: 1046.50,
            startSec: 0.00,
            durSec: 0.18,
            amp: 0.22,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1318.51,
            startSec: 0.07,
            durSec: 0.20,
            amp: 0.22,
            decay: 5.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1567.98,
            startSec: 0.14,
            durSec: 0.24,
            amp: 0.24,
            decay: 4.5,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2093.00,
            startSec: 0.22,
            durSec: 0.36,
            amp: 0.24,
            decay: 3.8,
          ),
        ], totalSec: 0.60);

      case PrismSoundCue.nova:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.triangle,
            freq: 180.0,
            endFreq: 75.0,
            startSec: 0.0,
            durSec: 0.22,
            amp: 0.36,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.sine,
            freq: 523.25,
            endFreq: 2093.0,
            startSec: 0.04,
            durSec: 0.20,
            amp: 0.20,
            decay: 5.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1046.5,
            startSec: 0.10,
            durSec: 0.44,
            amp: 0.18,
            decay: 4.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1318.5,
            startSec: 0.11,
            durSec: 0.44,
            amp: 0.18,
            decay: 4.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 1568.0,
            startSec: 0.12,
            durSec: 0.44,
            amp: 0.18,
            decay: 4.0,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2093.0,
            startSec: 0.13,
            durSec: 0.44,
            amp: 0.17,
            decay: 4.0,
          ),
        ], totalSec: 0.58);

      case PrismSoundCue.stageClear:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.brassBell,
            freq: 523.25,
            startSec: 0.00,
            durSec: 0.12,
            amp: 0.26,
            decay: 5.0,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 659.25,
            startSec: 0.10,
            durSec: 0.12,
            amp: 0.26,
            decay: 5.0,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 783.99,
            startSec: 0.20,
            durSec: 0.12,
            amp: 0.27,
            decay: 5.0,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 523.25,
            startSec: 0.31,
            durSec: 0.58,
            amp: 0.22,
            decay: 2.8,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 659.25,
            startSec: 0.31,
            durSec: 0.58,
            amp: 0.22,
            decay: 2.8,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 783.99,
            startSec: 0.31,
            durSec: 0.58,
            amp: 0.22,
            decay: 2.8,
          ),
          _Note(
            voice: _Voice.brassBell,
            freq: 1046.5,
            startSec: 0.31,
            durSec: 0.58,
            amp: 0.24,
            decay: 2.8,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2093.0,
            startSec: 0.42,
            durSec: 0.26,
            amp: 0.15,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 2637.0,
            startSec: 0.49,
            durSec: 0.26,
            amp: 0.15,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.glock,
            freq: 3136.0,
            startSec: 0.56,
            durSec: 0.26,
            amp: 0.15,
            decay: 5.5,
          ),
        ], totalSec: 0.92);

      case PrismSoundCue.allClear:
        final notes = <_Note>[
          const _Note(
            voice: _Voice.triangle,
            freq: 261.63,
            startSec: 0.0,
            durSec: 0.72,
            amp: 0.20,
            decay: 3.0,
          ),
          const _Note(
            voice: _Voice.triangle,
            freq: 392.00,
            startSec: 0.0,
            durSec: 0.72,
            amp: 0.18,
            decay: 3.0,
          ),
        ];
        for (var i = 0; i < 8; i++) {
          notes.add(
            _Note(
              voice: i.isEven ? _Voice.marimba : _Voice.glock,
              freq: pentatonicScale[i],
              startSec: i * 0.036,
              durSec: 0.34,
              amp: 0.22,
              decay: 4.2,
            ),
          );
        }
        return _mixNotes(notes, totalSec: 0.80);

      case PrismSoundCue.fail:
        return _mixNotes(const <_Note>[
          _Note(
            voice: _Voice.marimba,
            freq: 329.63,
            startSec: 0.00,
            durSec: 0.14,
            amp: 0.24,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 293.66,
            startSec: 0.11,
            durSec: 0.14,
            amp: 0.24,
            decay: 5.5,
          ),
          _Note(
            voice: _Voice.marimba,
            freq: 261.63,
            endFreq: 248.0,
            startSec: 0.22,
            durSec: 0.22,
            amp: 0.26,
            decay: 4.5,
          ),
        ], totalSec: 0.45);
    }
  }

  /// Synthesizes an ascending marimba + glockenspiel shimmer chord scaled to
  /// [streak], [lines], and [resonance].
  static Uint8List synthesizeClearChord({
    required int streak,
    required int lines,
    required bool resonance,
  }) {
    final baseIdx = (streak - 1).clamp(0, 6);
    final semitoneLift = streak > 6 ? math.min(streak - 6, 4) : 0;
    final pitchMult = semitoneLift == 0
        ? 1.0
        : math.pow(2.0, semitoneLift / 12.0).toDouble();
    final noteCount = (lines + (resonance ? 3 : 2)).clamp(3, 6);

    final notes = <_Note>[];
    for (var i = 0; i < noteCount; i++) {
      final f =
          pentatonicScale[(baseIdx + i).clamp(0, pentatonicScale.length - 1)] *
          pitchMult;
      notes.add(
        _Note(
          voice: _Voice.marimba,
          freq: f,
          startSec: i * 0.042,
          durSec: 0.26,
          amp: 0.26,
          decay: 5.5,
        ),
      );
      notes.add(
        _Note(
          voice: _Voice.glock,
          freq: f * 2.0,
          startSec: i * 0.042 + 0.016,
          durSec: 0.20,
          amp: 0.13,
          decay: 7.5,
        ),
      );
    }
    if (lines >= 2 || resonance) {
      final tStart = noteCount * 0.042 + 0.02;
      notes.add(
        _Note(
          voice: _Voice.glock,
          freq: 1567.98,
          startSec: tStart,
          durSec: 0.28,
          amp: 0.16,
          decay: 5.0,
        ),
      );
      notes.add(
        _Note(
          voice: _Voice.glock,
          freq: 2093.00,
          startSec: tStart + 0.025,
          durSec: 0.30,
          amp: 0.16,
          decay: 5.0,
        ),
      );
    }
    return _mixNotes(notes, totalSec: noteCount * 0.042 + 0.34);
  }

  static double _tri(double phase) =>
      (2.0 / math.pi) * math.asin(math.sin(phase));

  static Uint8List _mixNotes(List<_Note> notes, {required double totalSec}) {
    final totalSamples = (totalSec * sampleRate).round();
    final samples = Float64List(totalSamples);
    const nyquistLimit = sampleRate * 0.45;
    var lcg = 0x13579BDF;

    for (final note in notes) {
      final startIdx = (note.startSec * sampleRate).round();
      final durSamples = math.max(1, (note.durSec * sampleRate).round());
      final endIdx = math.min(totalSamples, startIdx + durSamples);
      final targetFreq = note.endFreq ?? note.freq;
      final attackSec = note.voice == _Voice.brassBell ? 0.012 : 0.003;

      var phase = 0.0;
      var prevNoise = 0.0;

      for (var i = startIdx; i < endIdx; i++) {
        final localT = (i - startIdx) / sampleRate;
        final progress = (i - startIdx) / durSamples;
        final attack = (localT / attackSec).clamp(0.0, 1.0);
        final env = attack * math.exp(-progress * note.decay);

        var curFreq = note.freq + (targetFreq - note.freq) * progress;
        if (note.voice == _Voice.brassBell) {
          curFreq *= 1.0 + 0.004 * math.sin(localT * 5.5 * 2 * math.pi);
        }
        phase += (2.0 * math.pi * curFreq) / sampleRate;

        double sample;
        switch (note.voice) {
          case _Voice.sine:
            sample = math.sin(phase);
          case _Voice.triangle:
            sample = _tri(phase);
          case _Voice.marimba:
            var v = math.sin(phase);
            if (curFreq * 2.0 < nyquistLimit) {
              v += 0.18 * _tri(phase * 2.0) * math.exp(-progress * 3.0);
            }
            if (curFreq * 3.98 < nyquistLimit) {
              v += 0.24 * math.sin(phase * 3.98) * math.exp(-progress * 11.5);
            }
            sample = v * 0.85;
          case _Voice.glock:
            var v = math.sin(phase);
            if (curFreq * 2.756 < nyquistLimit) {
              v += 0.30 * math.sin(phase * 2.756) * math.exp(-progress * 6.5);
            }
            if (curFreq * 5.404 < nyquistLimit) {
              v += 0.12 * math.sin(phase * 5.404) * math.exp(-progress * 13.5);
            }
            sample = v * 0.82;
          case _Voice.brassBell:
            var v = 0.65 * _tri(phase);
            if (curFreq * 2.0 < nyquistLimit) v += 0.35 * math.sin(phase * 2.0);
            if (curFreq * 3.0 < nyquistLimit) v += 0.22 * math.sin(phase * 3.0);
            if (curFreq * 4.0 < nyquistLimit) v += 0.10 * math.sin(phase * 4.0);
            sample = v * 0.78;
          case _Voice.sparkleNoise:
            lcg = (lcg * 1664525 + 1013904223) & 0xFFFFFFFF;
            final raw = (lcg / 2147483648.0) - 1.0;
            sample = raw - 0.85 * prevNoise;
            prevNoise = raw;
        }
        samples[i] += sample * note.amp * env;
      }
    }

    // Warm soft-clipping limiter keeps multi-note fanfares loud and clean.
    final byteData = ByteData(totalSamples * 2);
    for (var i = 0; i < totalSamples; i++) {
      final x = samples[i];
      final soft = (x / (1.0 + 0.28 * x.abs())).clamp(-0.96, 0.96);
      byteData.setInt16(i * 2, (soft * 32767).round(), Endian.little);
    }
    return byteData.buffer.asUint8List();
  }
}

class _Note {
  const _Note({
    required this.voice,
    required this.freq,
    this.endFreq,
    required this.startSec,
    required this.durSec,
    required this.amp,
    required this.decay,
  });

  final _Voice voice;
  final double freq;
  final double? endFreq;
  final double startSec;
  final double durSec;
  final double amp;
  final double decay;
}
