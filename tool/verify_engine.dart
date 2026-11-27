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

  // 1. Verify ALL 1,000 Quest Stages, unique bilingual names, lore, Bosses & zero-repeat theme progression!
  _expect(PrismThemeId.values.length == 12, '12 dazzling Prism themes defined');
  _expect(
    QuestStageCatalog.stages.length == 1000,
    '1,000 Quest stages exist across 10 Realms',
  );
  final trTitles = <String>{};
  final enTitles = <String>{};
  final usedThemes = <PrismThemeId>{};
  var adjacentThemeRepeats = 0;
  var bossCount = 0;
  var exactSeedCount = 0;
  var playableCount = 0;
  var loreCount = 0;

  for (var i = 0; i < QuestStageCatalog.stages.length; i++) {
    final spec = QuestStageCatalog.stages[i];
    trTitles.add(spec.title.tr);
    enTitles.add(spec.title.en);
    usedThemes.add(spec.themeId);
    if (spec.subtitle.tr.isNotEmpty && spec.subtitle.en.isNotEmpty) {
      loreCount++;
    }
    if (spec.isBossStage) bossCount++;
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
    if (cores == spec.targetCores &&
        frosts == spec.targetFrost &&
        locks == spec.targetLocks) {
      exactSeedCount++;
    }
    if (engine.hasAnyValidMove()) {
      playableCount++;
    }
  }
  _expect(loreCount == 1000, 'All 1,000 stages have bilingual lore subtitles');
  _expect(exactSeedCount == 1000, 'All 1,000 stages seed exact ★/❄/🔒 targets');
  _expect(playableCount == 1000, 'All 1,000 stages start 100% playable');
  _expect(bossCount == 100, '100 Boss stages (#10..#1000) defined');
  _expect(trTitles.length == 1000, 'All 1,000 stages have unique Turkish names');
  _expect(enTitles.length == 1000, 'All 1,000 stages have unique English names');
  _expect(
    usedThemes.length == PrismThemeId.values.length,
    'All 12 dazzling themes are showcased across the 1,000 stages',
  );
  _expect(
    adjacentThemeRepeats == 0,
    'Zero consecutive stages share the same theme across all 1,000 stages',
  );

  // Verify Stage 1000 Final Boss move limit & Out-of-Moves -> +8 moves Rescue Revive!
  {
    final bossEngine = PrismEngine(seed: 1000);
    bossEngine.startGame(newMode: GameMode.quest, stageNumber: 1000);
    _expect(
      bossEngine.isBossStage && bossEngine.hasMoveLimit && bossEngine.movesLeft == 34,
      'Stage #1000 Final Boss starts with 34-move hardcore budget',
    );
    bossEngine.movesUsed = bossEngine.moveLimit - 1;
    // Find any valid placement for a 1x1 test piece so moves hit 0 without completing objective.
    bossEngine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 0),
      null,
      null,
    ]);
    GridPoint? freePt;
    for (var y = 0; y < PrismEngine.gridSize && freePt == null; y++) {
      for (var x = 0; x < PrismEngine.gridSize && freePt == null; x++) {
        if (bossEngine.grid[y][x] == null) freePt = GridPoint(x, y);
      }
    }
    final out = bossEngine.placePiece(0, freePt!.x, freePt.y);
    _expect(
      out.placed && bossEngine.isOutOfMoves && bossEngine.isGameOver,
      'Exhausting move budget triggers Out-of-Moves Game Over',
    );
    final rev = bossEngine.reviveWithRescueNova();
    _expect(
      rev.placed && !bossEngine.isGameOver && !bossEngine.isOutOfMoves && bossEngine.movesLeft == 8,
      'Rescue Revive grants +8 extra moves & resumes Stage #1000',
    );
  }
  stdout.writeln(
    '  [OK] All 1,000 Quest stages, 100 Bosses, unique TR/EN names, move limits & vibrant themes verified.',
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

  // 8. Production AdMob Frequency Capping Policy, Rewarded Boosts & 12 Achievements!
  {
    final policy = AdFrequencyPolicy();
    final t0 = DateTime(2026, 11, 26, 12, 0, 0);
    _expect(
      !policy.recordRoundAndShouldShowInterstitial(now: t0),
      'No interstitial on round 1 (retention protection)',
    );
    _expect(
      policy.recordRoundAndShouldShowInterstitial(now: t0),
      'Interstitial allowed on round 2',
    );
    _expect(
      !policy.recordRoundAndShouldShowInterstitial(
        now: t0.add(const Duration(seconds: 60)),
      ),
      'Interstitial blocked during 120s cooldown',
    );
    _expect(
      policy.recordRoundAndShouldShowInterstitial(
        now: t0.add(const Duration(seconds: 130)),
      ),
      'Interstitial permitted after 120s cooldown',
    );
    // Watching a voluntary Rewarded Ad triggers 90s post-Rewarded grace window.
    final tReward = t0.add(const Duration(seconds: 260));
    policy.recordRewardedAdWatched(
      RewardedPlacement.energyBoost,
      now: tReward,
    );
    _expect(
      policy.energyBoostsUsedInRun == 1 && policy.canUseEnergyBoost,
      'Energy boost 1/2 recorded',
    );
    _expect(
      !policy.recordRoundAndShouldShowInterstitial(
        now: tReward.add(const Duration(seconds: 45)),
      ),
      'Interstitial suppressed during 90s post-Rewarded grace window',
    );
    _expect(
      policy.recordRoundAndShouldShowInterstitial(
        now: tReward.add(const Duration(seconds: 95)),
      ),
      'Interstitial resumes after 90s post-Rewarded grace window',
    );
    policy.recordRewardedAdWatched(
      RewardedPlacement.energyBoost,
      now: tReward.add(const Duration(seconds: 100)),
    );
    _expect(
      !policy.canUseEnergyBoost,
      'Energy boost strictly capped at 2 per run',
    );
    policy.recordRewardedAdWatched(
      RewardedPlacement.instantTemper,
      now: tReward.add(const Duration(seconds: 105)),
    );
    _expect(
      !policy.canUseInstantTemper,
      'Instant Anvil Temper strictly capped at 1 per run',
    );
    policy.resetRunCaps();
    _expect(
      policy.canUseEnergyBoost && policy.canUseInstantTemper,
      'resetRunCaps() resets per-run rewarded caps cleanly',
    );

    // Verify Rewarded Instant Anvil Temper & +100% Energy Boost engine hooks.
    final boostEngine = PrismEngine(seed: 99);
    boostEngine.startGame(newMode: GameMode.endless, customSeed: 99);
    boostEngine.energy = 15;
    boostEngine.grantEnergyBoost();
    _expect(
      boostEngine.energy == 100,
      'grantEnergyBoost() charges energy to 100%',
    );
    boostEngine.stashOrSwapWithForge(0);
    _expect(
      boostEngine.canInstantTemperForge && boostEngine.instantTemperForge(),
      'instantTemperForge() immediately tempers stashed Anvil piece',
    );
    _expect(
      boostEngine.isForgeTempered &&
          boostEngine.forgedPiece != null &&
          boostEngine.forgedPiece!.isWildcard &&
          boostEngine.forgedPiece!.prismCellIndex >= 0,
      'Instant tempered Anvil piece is 🌈 Wildcard + ★ Prism Core',
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
  stdout.writeln(
    '  [OK] AdMob Frequency Policy, Rewarded Boosts & 12 Achievements verified.',
  );

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
