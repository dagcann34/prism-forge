/// Root MaterialApp shell for PRISM FORGE (Prizma Döküm).
library;

import 'package:flutter/material.dart';

import '../audio/prism_audio.dart';
import '../engine/models.dart';
import '../services/achievements_service.dart';
import '../services/ad_service.dart';
import '../storage/prism_storage.dart';
import 'game_screen.dart';

class PrismForgeApp extends StatelessWidget {
  PrismForgeApp({
    super.key,
    PrismStorage? storage,
    PrismAudio? audio,
    AdService? adService,
    PlatformGamesService? gamesService,
    this.initialMode = GameMode.quest,
  }) : _storage = storage ?? PlatformPrismStorage(),
       _audio = audio ?? PrismAudio(),
       _adService = adService ?? PlatformAdService(),
       _gamesService = gamesService ?? PlatformGamesService();

  final PrismStorage _storage;
  final PrismAudio _audio;
  final AdService _adService;
  final PlatformGamesService _gamesService;
  final GameMode initialMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prizma Döküm • PRISM FORGE',
      debugShowCheckedModeBanner: false,
      home: PrismGameScreen(
        storage: _storage,
        audio: _audio,
        adService: _adService,
        gamesService: _gamesService,
        initialMode: initialMode,
      ),
    );
  }
}
