/// Offline audio + tactile HapticFeedback coordinator for PRISM FORGE.
library;

import 'dart:async';

import 'package:flutter/services.dart';

import 'prism_synth.dart';

class PrismAudio {
  PrismAudio({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.prismforge/audio');

  final MethodChannel _channel;
  final Map<PrismSoundCue, Uint8List> _cueCache = <PrismSoundCue, Uint8List>{};

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  void playCue(PrismSoundCue cue) {
    if (hapticsEnabled) {
      switch (cue) {
        case PrismSoundCue.pickup:
        case PrismSoundCue.rotate:
        case PrismSoundCue.hold:
          unawaited(HapticFeedback.selectionClick());
        case PrismSoundCue.place:
        case PrismSoundCue.frostCrack:
          unawaited(HapticFeedback.lightImpact());
        case PrismSoundCue.lockBreak:
        case PrismSoundCue.prismBlast:
        case PrismSoundCue.prismTempered:
        case PrismSoundCue.feverStart:
        case PrismSoundCue.achievementUnlock:
        case PrismSoundCue.nova:
        case PrismSoundCue.stageClear:
        case PrismSoundCue.allClear:
          unawaited(HapticFeedback.heavyImpact());
        case PrismSoundCue.fail:
          unawaited(HapticFeedback.vibrate());
      }
    }
    if (!soundEnabled) return;
    final pcm = _cueCache.putIfAbsent(cue, () => PrismSynth.synthesizeCue(cue));
    unawaited(_dispatchPcm(pcm));
  }

  void playClearChord({
    required int streak,
    required int lines,
    required bool resonance,
  }) {
    if (hapticsEnabled) {
      unawaited(
        (lines >= 2 || resonance)
            ? HapticFeedback.heavyImpact()
            : HapticFeedback.mediumImpact(),
      );
    }
    if (!soundEnabled) return;
    final pcm = PrismSynth.synthesizeClearChord(
      streak: streak,
      lines: lines,
      resonance: resonance,
    );
    unawaited(_dispatchPcm(pcm));
  }

  Future<void> _dispatchPcm(Uint8List pcmBytes) async {
    try {
      await _channel.invokeMethod<void>('playPcm', <String, Object>{
        'pcm': pcmBytes,
        'sampleRate': PrismSynth.sampleRate,
      });
    } on MissingPluginException {
      // Safe no-op in widget tests or headless environments.
    } on PlatformException {
      // Never interrupt gameplay if hardware audio is unavailable.
    }
  }
}
