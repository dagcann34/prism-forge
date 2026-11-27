/// Pure-Dart 12-Achievement Trophy Vault catalog and lifetime PlayerStats.
library;

import 'models.dart';

class PlayerStats {
  const PlayerStats({
    this.totalLinesCleared = 0,
    this.totalResonances = 0,
    this.totalRefractionChains = 0,
    this.totalSynthesizedCores = 0,
    this.totalTemperedWildcards = 0,
    this.totalFrostCracked = 0,
    this.totalLocksBroken = 0,
    this.totalAllClears = 0,
    this.maxStreakReached = 0,
    this.feverCount = 0,
  });

  final int totalLinesCleared;
  final int totalResonances;
  final int totalRefractionChains;
  final int totalSynthesizedCores;
  final int totalTemperedWildcards;
  final int totalFrostCracked;
  final int totalLocksBroken;
  final int totalAllClears;
  final int maxStreakReached;
  final int feverCount;

  PlayerStats copyWith({
    int? totalLinesCleared,
    int? totalResonances,
    int? totalRefractionChains,
    int? totalSynthesizedCores,
    int? totalTemperedWildcards,
    int? totalFrostCracked,
    int? totalLocksBroken,
    int? totalAllClears,
    int? maxStreakReached,
    int? feverCount,
  }) {
    return PlayerStats(
      totalLinesCleared: totalLinesCleared ?? this.totalLinesCleared,
      totalResonances: totalResonances ?? this.totalResonances,
      totalRefractionChains:
          totalRefractionChains ?? this.totalRefractionChains,
      totalSynthesizedCores:
          totalSynthesizedCores ?? this.totalSynthesizedCores,
      totalTemperedWildcards:
          totalTemperedWildcards ?? this.totalTemperedWildcards,
      totalFrostCracked: totalFrostCracked ?? this.totalFrostCracked,
      totalLocksBroken: totalLocksBroken ?? this.totalLocksBroken,
      totalAllClears: totalAllClears ?? this.totalAllClears,
      maxStreakReached: maxStreakReached ?? this.maxStreakReached,
      feverCount: feverCount ?? this.feverCount,
    );
  }

  Map<String, int> toJson() => <String, int>{
    'totalLinesCleared': totalLinesCleared,
    'totalResonances': totalResonances,
    'totalRefractionChains': totalRefractionChains,
    'totalSynthesizedCores': totalSynthesizedCores,
    'totalTemperedWildcards': totalTemperedWildcards,
    'totalFrostCracked': totalFrostCracked,
    'totalLocksBroken': totalLocksBroken,
    'totalAllClears': totalAllClears,
    'maxStreakReached': maxStreakReached,
    'feverCount': feverCount,
  };

  static PlayerStats fromJson(Map<Object?, Object?>? json) {
    if (json == null) return const PlayerStats();
    int readInt(String k) => json[k] is int ? json[k]! as int : 0;
    return PlayerStats(
      totalLinesCleared: readInt('totalLinesCleared'),
      totalResonances: readInt('totalResonances'),
      totalRefractionChains: readInt('totalRefractionChains'),
      totalSynthesizedCores: readInt('totalSynthesizedCores'),
      totalTemperedWildcards: readInt('totalTemperedWildcards'),
      totalFrostCracked: readInt('totalFrostCracked'),
      totalLocksBroken: readInt('totalLocksBroken'),
      totalAllClears: readInt('totalAllClears'),
      maxStreakReached: readInt('maxStreakReached'),
      feverCount: readInt('feverCount'),
    );
  }
}

class AchievementSpec {
  const AchievementSpec({
    required this.id,
    required this.iconGlyph,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final String id;
  final String iconGlyph;
  final LocalizedText title;
  final LocalizedText description;
  final bool Function(
    PlayerStats stats,
    int bestEndless,
    int bestBlitz,
    int solvedQuestCount,
    int solvedDailyCount,
  )
  isUnlocked;
}

class AchievementCatalog {
  const AchievementCatalog._();

  static final List<AchievementSpec> all = <AchievementSpec>[
    AchievementSpec(
      id: 'first_clear',
      iconGlyph: '✨',
      title: const LocalizedText(tr: 'İlk Kırılım', en: 'First Refraction'),
      description: const LocalizedText(
        tr: 'İlk satır veya sütunu temizle',
        en: 'Clear your first row or column',
      ),
      isUnlocked: (s, e, b, q, d) => s.totalLinesCleared >= 1,
    ),
    AchievementSpec(
      id: 'first_resonance',
      iconGlyph: '🌈',
      title: const LocalizedText(tr: 'Renk Armonisi', en: 'Color Harmony'),
      description: const LocalizedText(
        tr: '4+ aynı renkli Prizma Rezonansı tetikle',
        en: 'Trigger a 4+ same-color Prism Resonance',
      ),
      isUnlocked: (s, e, b, q, d) => s.totalResonances >= 1,
    ),
    AchievementSpec(
      id: 'quad_forger',
      iconGlyph: '★',
      title: const LocalizedText(tr: 'Kristal Dökümcü', en: 'Quad Forger'),
      description: const LocalizedText(
        tr: '2×2 aynı renk kenetleyerek ★ dök',
        en: 'Forge a ★ Core via 2×2 Prism Synthesis',
      ),
      isUnlocked: (s, e, b, q, d) => s.totalSynthesizedCores >= 1,
    ),
    AchievementSpec(
      id: 'anvil_master',
      iconGlyph: '⚒',
      title: const LocalizedText(tr: 'Örs Ustası', en: 'Anvil Master'),
      description: const LocalizedText(
        tr: 'Örs’te 3 turda 🌈 Joker Prizma dök',
        en: 'Temper a 🌈 Wildcard Prism in the Anvil',
      ),
      isUnlocked: (s, e, b, q, d) => s.totalTemperedWildcards >= 1,
    ),
    AchievementSpec(
      id: 'laser_architect',
      iconGlyph: '⚡',
      title: const LocalizedText(tr: 'Lazer Mimarı', en: 'Laser Architect'),
      description: const LocalizedText(
        tr: '★→★ Kırılım Zinciri lazeri ateşle',
        en: 'Fire a ★→★ Optical Chain-Refraction laser',
      ),
      isUnlocked: (s, e, b, q, d) => s.totalRefractionChains >= 1,
    ),
    AchievementSpec(
      id: 'prism_fever',
      iconGlyph: '🔥',
      title: const LocalizedText(tr: 'Gökkuşağı Coşkusu', en: 'Prism Fever'),
      description: const LocalizedText(
        tr: '3 ardışık temizlikle Fever ×2 moduna gir',
        en: 'Enter Fever ×2 mode with a 3-clear streak',
      ),
      isUnlocked: (s, e, b, q, d) =>
          s.feverCount >= 1 || s.maxStreakReached >= 3,
    ),
    AchievementSpec(
      id: 'frost_breaker',
      iconGlyph: '❄',
      title: const LocalizedText(tr: 'Buz Kıran', en: 'Frost Breaker'),
      description: const LocalizedText(
        tr: 'Toplam 10 Buzlu Kristal çatlat',
        en: 'Crack 10 Frosted Crystals in total',
      ),
      isUnlocked: (s, e, b, q, d) => s.totalFrostCracked >= 10,
    ),
    AchievementSpec(
      id: 'seal_shatterer',
      iconGlyph: '🔓',
      title: const LocalizedText(tr: 'Mühür Avcısı', en: 'Seal Shatterer'),
      description: const LocalizedText(
        tr: 'Toplam 5 Kilitli Taş kır',
        en: 'Shatter 5 Locked Keystones in total',
      ),
      isUnlocked: (s, e, b, q, d) => s.totalLocksBroken >= 5,
    ),
    AchievementSpec(
      id: 'board_sweeper',
      iconGlyph: '💎',
      title: const LocalizedText(tr: 'Kusursuz Tahta', en: 'Board Sweeper'),
      description: const LocalizedText(
        tr: 'Tahtayı tamamen temizle (+1000 bonus)',
        en: 'Achieve an All-Clear (+1000 bonus)',
      ),
      isUnlocked: (s, e, b, q, d) => s.totalAllClears >= 1,
    ),
    AchievementSpec(
      id: 'daily_solver',
      iconGlyph: '📅',
      title: const LocalizedText(tr: 'Günlük Mimar', en: 'Daily Architect'),
      description: const LocalizedText(
        tr: 'Bir Günlük Prizma Meydan Okumasını çöz',
        en: 'Complete a Daily Prism Challenge',
      ),
      isUnlocked: (s, e, b, q, d) => d >= 1,
    ),
    AchievementSpec(
      id: 'score_5000',
      iconGlyph: '🏆',
      title: const LocalizedText(tr: 'Prizma Şampiyonu', en: 'Prism Champion'),
      description: const LocalizedText(
        tr: 'Sonsuz modda 5.000+ puana ulaş',
        en: 'Reach 5,000+ points in Endless Flow',
      ),
      isUnlocked: (s, e, b, q, d) => e >= 5000,
    ),
    AchievementSpec(
      id: 'grand_architect',
      iconGlyph: '👑',
      title: const LocalizedText(tr: 'Büyük Mimar', en: 'Grand Architect'),
      description: const LocalizedText(
        tr: '24 Mimari Bölümün tamamını bitir',
        en: 'Complete all 24 Architect Quest stages',
      ),
      isUnlocked: (s, e, b, q, d) => q >= 24,
    ),
  ];

  /// Returns newly unlocked achievement specs not yet present in [existingIds].
  static List<AchievementSpec> evaluateNewUnlocks({
    required Set<String> existingIds,
    required PlayerStats stats,
    required int bestEndless,
    required int bestBlitz,
    required int solvedQuestCount,
    required int solvedDailyCount,
  }) {
    return <AchievementSpec>[
      for (final spec in all)
        if (!existingIds.contains(spec.id) &&
            spec.isUnlocked(
              stats,
              bestEndless,
              bestBlitz,
              solvedQuestCount,
              solvedDailyCount,
            ))
          spec,
    ];
  }
}
