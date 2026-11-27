/// Flutter platform bridge for optional Game Center (iOS) / Google Play Games
/// (Android) Cloud Sync (re-exports pure-Dart PlayerStats & AchievementCatalog).
library;

import 'dart:async';

import 'package:flutter/services.dart';

export '../engine/achievements.dart';

class PlatformGamesService {
  PlatformGamesService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.prismforge/games');

  final MethodChannel _channel;
  bool _connected = false;

  bool get isConnected => _connected;

  Future<bool> signInOptional() async {
    try {
      final ok = await _channel.invokeMethod<bool>('signIn');
      _connected = ok ?? false;
      return _connected;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> submitScore({
    required String leaderboardId,
    required int score,
  }) async {
    if (!_connected) return;
    try {
      await _channel.invokeMethod<void>('submitScore', <String, Object>{
        'leaderboardId': leaderboardId,
        'score': score,
      });
    } on MissingPluginException {
      // Safe no-op offline.
    } on PlatformException {
      // Safe no-op offline.
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    if (!_connected) return;
    try {
      await _channel.invokeMethod<void>('unlockAchievement', <String, String>{
        'achievementId': achievementId,
      });
    } on MissingPluginException {
      // Safe no-op offline.
    } on PlatformException {
      // Safe no-op offline.
    }
  }
}
