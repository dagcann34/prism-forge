/// Zero-dependency offline progress persistence for PRISM FORGE.
///
/// Stores high scores, 24-stage stars, Daily Challenge history, 12 Achievements,
/// lifetime PlayerStats, theme/locale/audio prefs, and Ad-Free entitlement.
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import '../engine/models.dart';
import '../services/achievements_service.dart';

class PrismSaveData {
  const PrismSaveData({
    this.bestEndlessScore = 0,
    this.bestBlitzScore = 0,
    this.currentQuestStage = 1,
    this.questStarsByStage = const <int, int>{},
    this.solvedDailyDates = const <String>{},
    this.unlockedAchievementIds = const <String>{},
    this.stats = const PlayerStats(),
    this.adsRemoved = false,
    this.themeId = PrismThemeId.ceramic,
    this.autoStageTheme = true,
    this.locale = AppLocale.tr,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final int bestEndlessScore;
  final int bestBlitzScore;
  final int currentQuestStage;
  final Map<int, int> questStarsByStage;
  final Set<String> solvedDailyDates;
  final Set<String> unlockedAchievementIds;
  final PlayerStats stats;
  final bool adsRemoved;
  final PrismThemeId themeId;
  final bool autoStageTheme;
  final AppLocale locale;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool reducedMotion;

  PrismSaveData copyWith({
    int? bestEndlessScore,
    int? bestBlitzScore,
    int? currentQuestStage,
    Map<int, int>? questStarsByStage,
    Set<String>? solvedDailyDates,
    Set<String>? unlockedAchievementIds,
    PlayerStats? stats,
    bool? adsRemoved,
    PrismThemeId? themeId,
    bool? autoStageTheme,
    AppLocale? locale,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? reducedMotion,
  }) {
    return PrismSaveData(
      bestEndlessScore: bestEndlessScore ?? this.bestEndlessScore,
      bestBlitzScore: bestBlitzScore ?? this.bestBlitzScore,
      currentQuestStage: currentQuestStage ?? this.currentQuestStage,
      questStarsByStage: questStarsByStage ?? this.questStarsByStage,
      solvedDailyDates: solvedDailyDates ?? this.solvedDailyDates,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
      stats: stats ?? this.stats,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      themeId: themeId ?? this.themeId,
      autoStageTheme: autoStageTheme ?? this.autoStageTheme,
      locale: locale ?? this.locale,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'bestEndlessScore': bestEndlessScore,
    'bestBlitzScore': bestBlitzScore,
    'currentQuestStage': currentQuestStage,
    'questStarsByStage': <String, int>{
      for (final e in questStarsByStage.entries) '${e.key}': e.value,
    },
    'solvedDailyDates': solvedDailyDates.toList()..sort(),
    'unlockedAchievementIds': unlockedAchievementIds.toList()..sort(),
    'stats': stats.toJson(),
    'adsRemoved': adsRemoved,
    'themeId': themeId.name,
    'autoStageTheme': autoStageTheme,
    'locale': locale.name,
    'soundEnabled': soundEnabled,
    'hapticsEnabled': hapticsEnabled,
    'reducedMotion': reducedMotion,
  };

  static PrismSaveData fromJson(Map<String, Object?> json) {
    final stars = <int, int>{};
    final rawStars = json['questStarsByStage'];
    if (rawStars is Map<Object?, Object?>) {
      for (final entry in rawStars.entries) {
        final k = int.tryParse('${entry.key}');
        final v = entry.value;
        if (k != null && v is int) {
          stars[k] = v.clamp(1, 3);
        }
      }
    }

    final daily = <String>{};
    final rawDaily = json['solvedDailyDates'];
    if (rawDaily is List<Object?>) {
      for (final item in rawDaily) {
        if (item is String) daily.add(item);
      }
    }

    final trophies = <String>{};
    final rawTrophies = json['unlockedAchievementIds'];
    if (rawTrophies is List<Object?>) {
      for (final item in rawTrophies) {
        if (item is String) trophies.add(item);
      }
    }

    final rawStats = json['stats'];
    final stats = rawStats is Map<Object?, Object?>
        ? PlayerStats.fromJson(rawStats)
        : const PlayerStats();

    final themeName = json['themeId'] is String
        ? json['themeId']! as String
        : '';
    final theme = PrismThemeId.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => PrismThemeId.ceramic,
    );

    return PrismSaveData(
      bestEndlessScore: json['bestEndlessScore'] is int
          ? json['bestEndlessScore']! as int
          : 0,
      bestBlitzScore: json['bestBlitzScore'] is int
          ? json['bestBlitzScore']! as int
          : 0,
      currentQuestStage: json['currentQuestStage'] is int
          ? (json['currentQuestStage']! as int).clamp(1, 24)
          : 1,
      questStarsByStage: stars,
      solvedDailyDates: daily,
      unlockedAchievementIds: trophies,
      stats: stats,
      adsRemoved: json['adsRemoved'] == true,
      themeId: theme,
      autoStageTheme: json['autoStageTheme'] != false,
      locale: json['locale'] == 'en' ? AppLocale.en : AppLocale.tr,
      soundEnabled: json['soundEnabled'] != false,
      hapticsEnabled: json['hapticsEnabled'] != false,
      reducedMotion: json['reducedMotion'] == true,
    );
  }
}

abstract class PrismStorage {
  Future<PrismSaveData> load();
  Future<void> save(PrismSaveData data);
}

class PlatformPrismStorage implements PrismStorage {
  PlatformPrismStorage({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.prismforge/storage');

  static const String _storageKey = 'prism_forge_save_v2';
  final MethodChannel _channel;
  PrismSaveData _fallback = const PrismSaveData();

  @override
  Future<PrismSaveData> load() async {
    try {
      final raw = await _channel.invokeMethod<String>('read', <String, String>{
        'key': _storageKey,
      });
      if (raw == null || raw.isEmpty) return _fallback;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) {
        _fallback = PrismSaveData.fromJson(decoded);
        return _fallback;
      }
    } on MissingPluginException {
      return _fallback;
    } on PlatformException {
      return _fallback;
    } on FormatException {
      return _fallback;
    }
    return _fallback;
  }

  @override
  Future<void> save(PrismSaveData data) async {
    _fallback = data;
    try {
      await _channel.invokeMethod<void>('write', <String, String>{
        'key': _storageKey,
        'value': jsonEncode(data.toJson()),
      });
    } on MissingPluginException {
      // Safe no-op in headless/test environments.
    } on PlatformException {
      // Preserve in-memory fallback if native store unavailable.
    }
  }
}

class MemoryPrismStorage implements PrismStorage {
  MemoryPrismStorage([this._data = const PrismSaveData()]);

  PrismSaveData _data;

  @override
  Future<PrismSaveData> load() async => _data;

  @override
  Future<void> save(PrismSaveData data) async {
    _data = data;
  }
}
