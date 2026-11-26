/// Root MaterialApp shell for PRISM FORGE (Prizma Döküm).
library;

import 'package:flutter/material.dart';

import '../audio/prism_audio.dart';
import '../engine/models.dart';
import '../storage/prism_storage.dart';
import 'game_screen.dart';

class PrismForgeApp extends StatelessWidget {
  PrismForgeApp({
    super.key,
    PrismStorage? storage,
    PrismAudio? audio,
    this.initialMode = GameMode.quest,
  }) : _storage = storage ?? PlatformPrismStorage(),
       _audio = audio ?? PrismAudio();

  final PrismStorage _storage;
  final PrismAudio _audio;
  final GameMode initialMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prizma Döküm • PRISM FORGE',
      debugShowCheckedModeBanner: false,
      home: PrismGameScreen(
        storage: _storage,
        audio: _audio,
        initialMode: initialMode,
      ),
    );
  }
}
