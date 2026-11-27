/// Core immutable data models for PRISM FORGE (Prizma Döküm).
///
/// Pure Dart with zero Flutter dependencies so the entire tactical rules engine
/// (Resonance, Prism Cores, Optical Chain-Refraction, 2x2 Prism Synthesis,
/// Prism Anvil Tempering, 2-Hit Frost, Locked Keystones) can be verified offline.
library;

/// Supported bilingual locales.
enum AppLocale { tr, en }

/// Four distinct gameplay modes designed for depth and App Store 4.3 originality.
enum GameMode {
  /// Infinite zen-combo score chase with 3-turn streak grace & All-Clear bonuses.
  endless,

  /// 24 handcrafted architectural stages introducing Prism Cores, Frost & Seals.
  quest,

  /// Deterministic date-seeded (YYYY-MM-DD) daily board & deck shared offline.
  daily,

  /// 90-second speed duel where clears add +3s and Resonance adds +5s.
  blitz,
}

/// Curated vibrant visual art palettes.
enum PrismThemeId {
  /// Tropik Mercan / Coral Lagoon (sunlit turquoise & coral)
  ceramic,

  /// Şeker Vitray / Candy Prism (joyful stained-glass candy)
  atelier,

  /// Bahar Bahçesi / Blossom Garden (blooming spring meadow)
  aurora,

  /// Karnaval Neon / Neon Carnival (electric festival twilight)
  obsidian,
}

/// Localized string pair (Turkish + English).
class LocalizedText {
  const LocalizedText({required this.tr, required this.en});

  final String tr;
  final String en;

  String resolve(AppLocale locale) => locale == AppLocale.tr ? tr : en;
}

/// Integer 2D coordinate on the 8x8 Prism Forge grid.
class GridPoint {
  const GridPoint(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is GridPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x,$y)';
}

/// A cardinal optical laser ricochet link between two aligned ★ Prism Cores.
class RefractionBeam {
  const RefractionBeam({
    required this.from,
    required this.to,
    required this.depth,
  });

  final GridPoint from;
  final GridPoint to;

  /// Cascade hop depth (1 = first jump, 2 = second ricochet, etc.).
  final int depth;
}

/// A single occupied tile on the 8x8 forge grid.
class BoardCell {
  const BoardCell({
    required this.colorIndex,
    this.isPrismCore = false,
    this.frostHits = 0,
    this.isLocked = false,
    this.isWildcard = false,
  });

  /// Palette color index (0..5) participating in 4+ Harmonic Color Resonance.
  final int colorIndex;

  /// ★ Prism Core: clearing this cell unleashes Cross-Wave + Chain-Refraction.
  final bool isPrismCore;

  /// ❄ Frosted Crystal: 1 means encased in frost (hit 1 cracks it; hit 2 clears).
  final int frostHits;

  /// 🔒 Locked Keystone: immune to ordinary line clears; breaks via Resonance,
  /// Prism Core Cross-Wave / Optical Beam, or 3x3 Quantum Nova.
  final bool isLocked;

  /// 🌈 Tempered Rainbow Wildcard Glass (forged in the Prism Anvil): matches
  /// ALL 6 colors simultaneously for 4+ Resonance and 2x2 Prism Synthesis.
  final bool isWildcard;

  BoardCell copyWith({
    int? colorIndex,
    bool? isPrismCore,
    int? frostHits,
    bool? isLocked,
    bool? isWildcard,
  }) {
    return BoardCell(
      colorIndex: colorIndex ?? this.colorIndex,
      isPrismCore: isPrismCore ?? this.isPrismCore,
      frostHits: frostHits ?? this.frostHits,
      isLocked: isLocked ?? this.isLocked,
      isWildcard: isWildcard ?? this.isWildcard,
    );
  }
}

/// A polyomino piece sitting in the 3-slot tray or the Prism Anvil slot.
class PrismPiece {
  const PrismPiece({
    required this.cells,
    required this.colorIndex,
    this.prismCellIndex = -1,
    this.isWildcard = false,
  });

  final List<GridPoint> cells;
  final int colorIndex;

  /// Index inside [cells] carrying a ★ Prism Core, or -1 if none.
  final int prismCellIndex;

  /// True once tempered for 3 turns in the Prism Anvil (iridescent wildcard).
  final bool isWildcard;

  int get cols {
    var maxX = 0;
    for (final c in cells) {
      if (c.x > maxX) maxX = c.x;
    }
    return maxX + 1;
  }

  int get rows {
    var maxY = 0;
    for (final c in cells) {
      if (c.y > maxY) maxY = c.y;
    }
    return maxY + 1;
  }

  PrismPiece copyWith({
    List<GridPoint>? cells,
    int? colorIndex,
    int? prismCellIndex,
    bool? isWildcard,
  }) {
    return PrismPiece(
      cells: cells ?? this.cells,
      colorIndex: colorIndex ?? this.colorIndex,
      prismCellIndex: prismCellIndex ?? this.prismCellIndex,
      isWildcard: isWildcard ?? this.isWildcard,
    );
  }
}

/// Pre-drop live tactical preview computed while hovering a piece over the board.
class PlacementPreview {
  const PlacementPreview({
    required this.anchor,
    required this.rowsToClear,
    required this.colsToClear,
    required this.triggersResonance,
    required this.triggeredPrisms,
    required this.frostToCrack,
    required this.locksToBreak,
    this.refractionBeams = const <RefractionBeam>[],
    this.synthesizedCores = const <GridPoint>[],
    this.synthesisQuadOrigins = const <GridPoint>[],
  });

  final GridPoint anchor;
  final List<int> rowsToClear;
  final List<int> colsToClear;
  final bool triggersResonance;
  final List<GridPoint> triggeredPrisms;
  final List<GridPoint> frostToCrack;
  final List<GridPoint> locksToBreak;
  final List<RefractionBeam> refractionBeams;
  final List<GridPoint> synthesizedCores;
  final List<GridPoint> synthesisQuadOrigins;

  bool get hasLineClear => rowsToClear.isNotEmpty || colsToClear.isNotEmpty;
  bool get hasSynthesis => synthesizedCores.isNotEmpty;
  bool get hasRefraction => refractionBeams.isNotEmpty;
}

/// Detailed result of placing a piece or unleashing Quantum Nova.
class MoveOutcome {
  const MoveOutcome({
    required this.placed,
    this.pointsEarned = 0,
    this.linesCleared = 0,
    this.clearedRows = const <int>[],
    this.clearedCols = const <int>[],
    this.triggeredResonance = false,
    this.triggeredPrisms = const <GridPoint>[],
    this.refractionBeams = const <RefractionBeam>[],
    this.synthesizedCores = const <GridPoint>[],
    this.forgeTempered = false,
    this.enteredFever = false,
    this.crackedFrostCount = 0,
    this.brokenLockCount = 0,
    this.clearedCells = const <GridPoint>[],
    this.allClearBonus = false,
    this.blitzSecondsAdded = 0,
    this.objectiveCompleted = false,
    this.gameOver = false,
  });

  final bool placed;
  final int pointsEarned;
  final int linesCleared;
  final List<int> clearedRows;
  final List<int> clearedCols;
  final bool triggeredResonance;
  final List<GridPoint> triggeredPrisms;
  final List<RefractionBeam> refractionBeams;
  final List<GridPoint> synthesizedCores;
  final bool forgeTempered;
  final bool enteredFever;
  final int crackedFrostCount;
  final int brokenLockCount;
  final List<GridPoint> clearedCells;
  final bool allClearBonus;
  final int blitzSecondsAdded;
  final bool objectiveCompleted;
  final bool gameOver;
}

/// Handcrafted stage blueprint for the 24-stage Prizma Görevi (Prism Quest).
class QuestStageSpec {
  const QuestStageSpec({
    required this.stageNumber,
    required this.chapterNumber,
    required this.title,
    required this.targetCores,
    required this.targetFrost,
    required this.targetLocks,
    required this.initialClutter,
    required this.twoStarScore,
    required this.threeStarScore,
  });

  final int stageNumber;
  final int chapterNumber;
  final LocalizedText title;
  final int targetCores;
  final int targetFrost;
  final int targetLocks;
  final int initialClutter;
  final int twoStarScore;
  final int threeStarScore;

  int get totalTargets => targetCores + targetFrost + targetLocks;
}
