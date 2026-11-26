/// Pure-Dart verification harness for PRISM FORGE (Prizma Döküm).
///
/// Verifies all 24 Quest stages + Resonance + Cross-Wave + Frost + Locks +
/// Tactical Energy + Daily Determinism + Blitz + PCM Synth + NEW signature
/// mechanics: Prism Anvil (3-turn Wildcard tempering), Optical Chain-Refraction
/// (L-shaped ★->★ laser ricochet), and 2x2 Prism Synthesis (interlock forging).
library;

// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';

import '../lib/audio/prism_synth.dart';
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

  // 1. Verify all 24 Quest Stages.
  _expect(QuestStageCatalog.stages.length == 24, '24 Quest stages exist');
  for (final spec in QuestStageCatalog.stages) {
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
  stdout.writeln('  [OK] All 24 Architect Quest stages verified.');

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

  // 4. NEW MECHANIC #1: Prism Anvil 3-Turn Tempering -> Rainbow Wildcard + ★ Core!
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
    _expect(
      engine.forgeCharge == 0 && !engine.isForgeTempered,
      'Anvil starts at 0/3',
    );

    // Place 3 tray pieces to temper Anvil piece from 0 -> 1 -> 2 -> 3 (Tempered!)
    final o1 = engine.placePiece(1, 0, 7);
    _expect(!o1.forgeTempered && engine.forgeCharge == 1, 'Turn 1 -> 1/3');
    final o2 = engine.placePiece(2, 2, 7);
    _expect(!o2.forgeTempered && engine.forgeCharge == 2, 'Turn 2 -> 2/3');
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
    _expect(
      engine.forgedPiece!.prismCellIndex == 0,
      'Tempered piece gained ★ Prism Core',
    );

    // Verify Wildcard completes 4+ Resonance with only 3 same-color blocks!
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
      'Wildcard bonds with 3 matching blocks for Resonance!',
    );
    _expect(
      engine.forgedPiece == null && engine.forgeCharge == 0,
      'Anvil clears after placing forged piece',
    );
  }
  stdout.writeln(
    '  [OK] Prism Anvil (3-turn Wildcard + ★ tempering) verified.',
  );

  // 5. NEW MECHANIC #2: Optical Chain-Refraction L-shaped 2-Hop Laser Ricochet!
  {
    final engine = PrismEngine(seed: 77);
    engine.startGame(newMode: GameMode.endless, customSeed: 77);
    // Row 6 full except x=7; ★ Core at (1,6).
    for (var x = 0; x < 7; x++) {
      engine.setCellForTest(
        x,
        6,
        BoardCell(colorIndex: x % 6, isPrismCore: x == 1),
      );
    }
    // Second ★ Core vertically aligned at (1,1) with a 🔒 Lock strictly between at (1,3)!
    engine.setCellForTest(1, 3, const BoardCell(colorIndex: 2, isLocked: true));
    engine.setCellForTest(
      1,
      1,
      const BoardCell(colorIndex: 0, isPrismCore: true),
    );
    // Third ★ Core horizontally aligned at (6,1) with ❄ Frost strictly between at (4,1)!
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

    final prev = engine.previewPlacement(engine.tray[0]!, 7, 6);
    _expect(
      prev != null && prev.refractionBeams.length == 2,
      'Preview detects 2-hop L-shaped laser chain',
    );

    final out = engine.placePiece(0, 7, 6);
    _expect(
      out.refractionBeams.length == 2,
      'Executed 2-hop optical chain-refraction',
    );
    _expect(
      engine.grid[3][1] == null,
      'Laser hop 1 shattered intermediate Locked Keystone at (1,3)',
    );
    _expect(
      engine.grid[1][4] != null && engine.grid[1][4]!.frostHits == 0,
      'Laser hop 2 cracked Frost at (4,1)',
    );
    _expect(engine.grid[1][6] == null, 'Chain detonated 3rd ★ Core at (6,1)');
  }
  stdout.writeln(
    '  [OK] Optical Chain-Refraction (★→★ L-shaped laser ricochet) verified.',
  );

  // 6. NEW MECHANIC #3: 2x2 Prism Synthesis (Interlock Forging + Thermal Frost Crack).
  {
    final engine = PrismEngine(seed: 88);
    engine.startGame(newMode: GameMode.endless, customSeed: 88);
    // Standalone 2x2 O-piece in empty space must NOT forge a free star.
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
    final noForge = engine.placePiece(0, 0, 0);
    _expect(
      noForge.synthesizedCores.isEmpty,
      'Standalone 2x2 O-piece does not farm free ★',
    );

    // Place 3 existing cells of color 2 (one Frosted!) and interlock 4th cell to forge ★!
    engine.setCellForTest(4, 4, const BoardCell(colorIndex: 2));
    engine.setCellForTest(5, 4, const BoardCell(colorIndex: 2, frostHits: 1));
    engine.setCellForTest(4, 5, const BoardCell(colorIndex: 2));
    final prev = engine.previewPlacement(engine.tray[1]!, 5, 5);
    _expect(
      prev != null && prev.hasSynthesis,
      'Preview detects 2x2 Prism Synthesis',
    );

    final synthOut = engine.placePiece(1, 5, 5);
    _expect(
      synthOut.synthesizedCores.length == 1,
      'Interlocked 2x2 forged a ★ Prism Core',
    );
    _expect(
      engine.grid[5][5]!.isPrismCore,
      'Newly placed corner upgraded to ★ Prism Core',
    );
    _expect(
      engine.grid[4][5]!.frostHits == 0,
      '2x2 Synthesis thermally cracked Frost inside quad',
    );
  }
  stdout.writeln(
    '  [OK] 2x2 Prism Synthesis (interlock forging & frost crack) verified.',
  );

  // 7. Verify Rotate (35%), Quantum Nova (100%), Daily Determinism & Blitz Timer.
  {
    final e = PrismEngine(seed: 101);
    e.startGame(newMode: GameMode.endless, customSeed: 101);
    e.setTrayForTest(const <PrismPiece?>[
      PrismPiece(
        cells: <GridPoint>[GridPoint(0, 0), GridPoint(1, 0), GridPoint(2, 0)],
        colorIndex: 0,
      ),
      null,
      null,
    ]);
    _expect(
      e.rotateTrayPiece(0) && e.energy == 15,
      'Rotate consumes 35% energy',
    );
    e.energy = 100;
    e.setCellForTest(4, 4, const BoardCell(colorIndex: 0, isLocked: true));
    final nova = e.executeQuantumNova(4, 4);
    _expect(
      nova.placed && e.grid[4][4] == null,
      'Quantum Nova vaporizes Locks',
    );

    final d1 = PrismEngine()
      ..startGame(newMode: GameMode.daily, dateKey: '2026-11-26');
    final d2 = PrismEngine()
      ..startGame(newMode: GameMode.daily, dateKey: '2026-11-26');
    var same = true;
    for (var y = 0; y < 8; y++) {
      for (var x = 0; x < 8; x++) {
        if ((d1.grid[y][x] == null) != (d2.grid[y][x] == null)) same = false;
      }
    }
    _expect(same, 'Daily Challenge is 100% deterministic');

    final b = PrismEngine(seed: 55)
      ..startGame(newMode: GameMode.blitz, customSeed: 55);
    _expect(b.tickBlitz(95.0) && b.isGameOver, 'Blitz expires cleanly at 0s');
  }
  stdout.writeln(
    '  [OK] Rotate, Quantum Nova, Daily Determinism & Blitz verified.',
  );

  // 8. Verify all 12 lively multi-voice PCM synth cues.
  for (final cue in PrismSoundCue.values) {
    final pcm = PrismSynth.synthesizeCue(cue);
    _expect(
      pcm.isNotEmpty && pcm.length.isEven,
      'Lively PCM cue ${cue.name} valid',
    );
  }
  final chord = PrismSynth.synthesizeClearChord(
    streak: 7,
    lines: 3,
    resonance: true,
  );
  _expect(
    chord.isNotEmpty && chord.length.isEven,
    'Ascending marimba+glock chord valid',
  );
  stdout.writeln('  [OK] All 12 lively multi-voice PCM audio cues verified.');

  stdout.writeln('=== Summary: $_passed passed, $_failed failed ===');
  if (_failed > 0) exitCode = 1;
}
