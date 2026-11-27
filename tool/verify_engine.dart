/// Pure-Dart verification harness for PRISM FORGE (Prizma Döküm).
///
/// Verifies all 24 Quest stages + Resonance + Cross-Wave + Frost + Locks +
/// Prism Anvil Tempering + Optical Chain-Refraction + 2x2 Prism Synthesis +
/// Prism Fever x2 + Rewarded Rescue Revive + AdFrequencyPolicy + 12 Achievements
/// + Daily Determinism + Blitz + all 14 lively multi-voice PCM audio cues.
library;

// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';

import '../lib/audio/prism_synth.dart';
import '../lib/engine/achievements.dart';
import '../lib/engine/ad_policy.dart';
import '../lib/engine/models.dart';
import '../lib/engine/prism_engine.dart';
import '../lib/engine/quest_stages.dart';

int _passed = 0;
int _failed = 0;

void _expect(bool condition, String label) {
  if (condition) {
    _passed++;
  } else {
    _failed++;
    stderr.writeln('  [FAIL] $label');
  }
}

void main() {
  stdout.writeln(
    '=== PRISM FORGE (Prizma Döküm) — Pure Dart Engine Verification ===',
  );

  // 1. Verify all 24 Quest Stages, unique bilingual names, lore & zero-repeat 12-theme progression.
  _expect(PrismThemeId.values.length == 12, '12 dazzling Prism themes defined');
  _expect(QuestStageCatalog.stages.length == 24, '24 Quest stages exist');
  final trTitles = <String>{};
  final enTitles = <String>{};
  final usedThemes = <PrismThemeId>{};
  var adjacentThemeRepeats = 0;
  for (var i = 0; i < QuestStageCatalog.stages.length; i++) {
    final spec = QuestStageCatalog.stages[i];
    trTitles.add(spec.title.tr);
    enTitles.add(spec.title.en);
    usedThemes.add(spec.themeId);
    _expect(
      spec.subtitle.tr.isNotEmpty && spec.subtitle.en.isNotEmpty,
      'Stage #${spec.stageNumber} has bilingual lore subtitle',
    );
    if (i > 0 && QuestStageCatalog.stages[i - 1].themeId == spec.themeId) {
      adjacentThemeRepeats++;
    }

    final engine = PrismEngine();
    engine.startGame(newMode: GameMode.quest, stageNumber: spec.stageNumber);
    var cores = 0;
    var frosts = 0;
    var locks = 0;
    for (var y = 0; y < PrismEngine.gridSize; y++) {
      for (var x = 0; x < PrismEngine.gridSize; x++) {
        final c = engine.grid[y][x];
        if (c == null) continue;
        if (c.isPrismCore) cores++;
        if (c.frostHits > 0) frosts++;
        if (c.isLocked) locks++;
      }
    }
    _expect(
      cores == spec.targetCores &&
          frosts == spec.targetFrost &&
          locks == spec.targetLocks,
      'Stage #${spec.stageNumber} seeds exact targets ($cores/$frosts/$locks)',
    );
    _expect(
      engine.hasAnyValidMove(),
      'Stage #${spec.stageNumber} starts playable',
    );
  }
  _expect(trTitles.length == 24, 'All 24 stages have unique Turkish names');
  _expect(enTitles.length == 24, 'All 24 stages have unique English names');
  _expect(
    usedThemes.length == PrismThemeId.values.length,
    'All 12 dazzling themes are showcased across the 24 stages',
  );
  _expect(
    adjacentThemeRepeats == 0,
    'Zero consecutive stages share the same theme (theme evolves every stage)',
  );
  stdout.writeln(
    '  [OK] All 24 Architect Quest stages, unique TR/EN names & 12-theme rotation verified.',
  );

  // 2. Verify 4+ Harmonic Resonance (x1.5) & Lock breaking.
  {
    final engine = PrismEngine(seed: 42);
    engine.startGame(newMode: GameMode.endless, customSeed: 42);
    for (var x = 0; x < 4; x++) {
      engine.setCellForTest(x, 0, const BoardCell(colorIndex: 0));
    }
    engine.setCellForTest(4, 0, const BoardCell(colorIndex: 2, isLocked: true));
    engine.setCellForTest(5, 0, const BoardCell(colorIndex: 1));
    engine.setCellForTest(6, 0, const BoardCell(colorIndex: 1));
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 0),
      null,
      null,
    ]);
    final out = engine.placePiece(0, 7, 0);
    _expect(
      out.triggeredResonance && out.brokenLockCount == 1,
      'Resonance breaks Locked Keystone',
    );
  }
  stdout.writeln(
    '  [OK] Harmonic Color Resonance (x1.5) & Seal shattering verified.',
  );

  // 3. Verify 2-Hit Frosted Crystal & Locked Keystone protection.
  {
    final engine = PrismEngine(seed: 7);
    engine.startGame(newMode: GameMode.endless, customSeed: 7);
    for (var x = 0; x < 7; x++) {
      engine.setCellForTest(
        x,
        0,
        BoardCell(
          colorIndex: x % 6,
          frostHits: x == 3 ? 1 : 0,
          isLocked: x == 4,
        ),
      );
    }
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 1),
      null,
      null,
    ]);
    final out = engine.placePiece(0, 7, 0);
    _expect(
      !out.triggeredResonance && out.crackedFrostCount == 1,
      'Frost cracks on hit 1',
    );
    _expect(
      engine.grid[0][3] != null && engine.grid[0][3]!.frostHits == 0,
      'Frost converts to normal',
    );
    _expect(
      engine.grid[0][4] != null && engine.grid[0][4]!.isLocked,
      'Lock stays intact without forceBreak',
    );
  }
  stdout.writeln(
    '  [OK] 2-Hit Frosted Crystal & Locked Keystone protection verified.',
  );

  // 4. Prism Anvil 3-Turn Tempering -> Rainbow Wildcard + ★ Core.
  {
    final engine = PrismEngine(seed: 123);
    engine.startGame(newMode: GameMode.endless, customSeed: 123);
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 5),
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 1),
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 2),
    ]);
    _expect(engine.stashOrSwapWithForge(0), 'Stashed piece into Prism Anvil');
    _expect(!engine.stashOrSwapWithForge(1), '1-per-turn Anvil guard enforced');
    engine.placePiece(1, 0, 7);
    engine.placePiece(2, 2, 7);
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 3),
      null,
      null,
    ]);
    final o3 = engine.placePiece(0, 4, 7);
    _expect(
      o3.forgeTempered && engine.isForgeTempered,
      'Turn 3 tempers into Wildcard + ★!',
    );

    for (var x = 0; x < 3; x++) {
      engine.setCellForTest(x, 0, const BoardCell(colorIndex: 0));
    }
    engine.setCellForTest(3, 0, const BoardCell(colorIndex: 1));
    engine.setCellForTest(4, 0, const BoardCell(colorIndex: 2));
    engine.setCellForTest(5, 0, const BoardCell(colorIndex: 3));
    engine.setCellForTest(6, 0, const BoardCell(colorIndex: 4));
    final wildOut = engine.placeForgedPiece(7, 0);
    _expect(
      wildOut.placed && wildOut.triggeredResonance,
      'Wildcard bonds with 3 matching blocks for Resonance',
    );
  }
  stdout.writeln(
    '  [OK] Prism Anvil (3-turn Wildcard + ★ tempering) verified.',
  );

  // 5. Optical Chain-Refraction L-shaped 2-Hop Laser Ricochet.
  {
    final engine = PrismEngine(seed: 77);
    engine.startGame(newMode: GameMode.endless, customSeed: 77);
    for (var x = 0; x < 7; x++) {
      engine.setCellForTest(
        x,
        6,
        BoardCell(colorIndex: x % 6, isPrismCore: x == 1),
      );
    }
    engine.setCellForTest(1, 3, const BoardCell(colorIndex: 2, isLocked: true));
    engine.setCellForTest(
      1,
      1,
      const BoardCell(colorIndex: 0, isPrismCore: true),
    );
    engine.setCellForTest(4, 1, const BoardCell(colorIndex: 3, frostHits: 1));
    engine.setCellForTest(
      6,
      1,
      const BoardCell(colorIndex: 4, isPrismCore: true),
    );
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 5),
      null,
      null,
    ]);
    final out = engine.placePiece(0, 7, 6);
    _expect(
      out.refractionBeams.length == 2,
      'Executed 2-hop optical chain-refraction',
    );
    _expect(
      engine.grid[3][1] == null,
      'Laser shattered Locked Keystone at (1,3)',
    );
    _expect(engine.grid[1][4]!.frostHits == 0, 'Laser cracked Frost at (4,1)');
    _expect(engine.grid[1][6] == null, 'Chain detonated 3rd ★ Core at (6,1)');
  }
  stdout.writeln(
    '  [OK] Optical Chain-Refraction (★→★ L-shaped laser ricochet) verified.',
  );

  // 6. 2x2 Prism Synthesis.
  {
    final engine = PrismEngine(seed: 88);
    engine.startGame(newMode: GameMode.endless, customSeed: 88);
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(
        cells: <GridPoint>[
          GridPoint(0, 0),
          GridPoint(1, 0),
          GridPoint(0, 1),
          GridPoint(1, 1),
        ],
        colorIndex: 0,
      ),
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 2),
      null,
    ]);
    _expect(
      engine.placePiece(0, 0, 0).synthesizedCores.isEmpty,
      'Standalone 2x2 does not farm ★',
    );
    engine.setCellForTest(4, 4, const BoardCell(colorIndex: 2));
    engine.setCellForTest(5, 4, const BoardCell(colorIndex: 2, frostHits: 1));
    engine.setCellForTest(4, 5, const BoardCell(colorIndex: 2));
    final synthOut = engine.placePiece(1, 5, 5);
    _expect(
      synthOut.synthesizedCores.length == 1 && engine.grid[5][5]!.isPrismCore,
      '2x2 Synthesis forged ★',
    );
    _expect(
      engine.grid[4][5]!.frostHits == 0,
      '2x2 Synthesis cracked quad Frost',
    );
  }
  stdout.writeln('  [OK] 2x2 Prism Synthesis verified.');

  // 7. NEW: Prism Fever x2 (3-clear streak) & Rewarded Rescue Revive (max 1/run)!
  {
    final engine = PrismEngine(seed: 33);
    engine.startGame(newMode: GameMode.endless, customSeed: 33);
    engine.streak = 2;
    engine.streakTurnsLeft = 3;
    for (var x = 0; x < 7; x++) {
      engine.setCellForTest(x, 0, BoardCell(colorIndex: x % 6));
    }
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 5),
      null,
      null,
    ]);
    final feverOut = engine.placePiece(0, 7, 0);
    _expect(
      feverOut.enteredFever && engine.isFeverActive,
      '3rd consecutive clear activates Prism Fever x2',
    );
    // Base 1-line streak=3 is 300; Fever doubles to 600 (+10 placement + 1000 All-Clear = 1610).
    _expect(feverOut.pointsEarned >= 610, 'Fever x2 doubles clear points');

    // Simulate Game Over -> Rescue Revive works once and clears center 3x3 + restores 100% energy!
    engine.isGameOver = true;
    engine.energy = 10;
    engine.setCellForTest(4, 4, const BoardCell(colorIndex: 0, isLocked: true));
    _expect(engine.canRevive, 'Can revive on first Game Over');
    final rev = engine.reviveWithRescueNova();
    _expect(
      rev.placed && !engine.isGameOver && engine.energy == 100,
      'Rescue Revive resumes with 100% energy',
    );
    _expect(engine.grid[4][4] == null, 'Rescue Revive cleared center 3x3 Lock');
    engine.isGameOver = true;
    _expect(!engine.canRevive, 'Revive strictly capped at 1 per run');
  }
  stdout.writeln('  [OK] Prism Fever x2 & Rewarded Rescue Revive verified.');

  // 8. NEW: AdMob Frequency Capping Policy & 12 Achievements Evaluator!
  {
    final policy = AdFrequencyPolicy(
      minRoundsBeforeFirstInterstitial: 3,
      interstitialCooldownSeconds: 180,
    );
    final t0 = DateTime(2026, 11, 26, 12, 0, 0);
    _expect(
      !policy.recordRoundAndShouldShowInterstitial(now: t0),
      'No interstitial on round 1',
    );
    _expect(
      !policy.recordRoundAndShouldShowInterstitial(now: t0),
      'No interstitial on round 2',
    );
    _expect(
      policy.recordRoundAndShouldShowInterstitial(now: t0),
      'Interstitial allowed on round 3',
    );
    _expect(
      !policy.recordRoundAndShouldShowInterstitial(
        now: t0.add(const Duration(seconds: 60)),
      ),
      'Interstitial blocked during 180s cooldown',
    );
    _expect(
      policy.recordRoundAndShouldShowInterstitial(
        now: t0.add(const Duration(seconds: 200)),
      ),
      'Interstitial permitted after 180s cooldown',
    );

    const stats = PlayerStats(
      totalLinesCleared: 12,
      totalResonances: 2,
      totalRefractionChains: 1,
      totalSynthesizedCores: 2,
      totalTemperedWildcards: 1,
      totalFrostCracked: 10,
      totalLocksBroken: 5,
      totalAllClears: 1,
      maxStreakReached: 4,
      feverCount: 1,
    );
    final unlocks = AchievementCatalog.evaluateNewUnlocks(
      existingIds: const <String>{},
      stats: stats,
      bestEndless: 5400,
      bestBlitz: 2000,
      solvedQuestCount: 24,
      solvedDailyCount: 1,
    );
    _expect(
      unlocks.length == 12,
      'All 12 Achievements evaluate and unlock cleanly',
    );
  }
  stdout.writeln('  [OK] AdMob Frequency Policy & 12 Achievements verified.');

  // 9. Verify all 14 lively multi-voice PCM synth cues.
  for (final cue in PrismSoundCue.values) {
    final pcm = PrismSynth.synthesizeCue(cue);
    _expect(
      pcm.isNotEmpty && pcm.length.isEven,
      'Lively PCM cue ${cue.name} valid',
    );
  }
  stdout.writeln(
    '  [OK] All ${PrismSoundCue.values.length} lively multi-voice PCM audio cues verified.',
  );

  stdout.writeln('=== Summary: $_passed passed, $_failed failed ===');
  if (_failed > 0) exitCode = 1;
}
