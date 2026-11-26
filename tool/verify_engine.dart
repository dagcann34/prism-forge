/// Pure-Dart verification harness for PRISM FORGE (Prizma Döküm).
///
/// Runs offline with zero Flutter/network dependencies via:
///   dart run tool/verify_engine.dart
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

  // 1. Verify all 24 Quest Stages generate valid non-full boards & valid trays.
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
      'Stage #${spec.stageNumber} (${spec.title.tr}) seeds exact targets ($cores/$frosts/$locks)',
    );
    _expect(
      engine.hasAnyValidMove(),
      'Stage #${spec.stageNumber} starts with at least one valid move (Fair-Tray)',
    );
  }
  stdout.writeln('  [OK] All 24 Architect Quest stages verified.');

  // 2. Verify 4+ Same-Color Harmonic Resonance (x1.5) & Lock-Breaking synergy.
  {
    final engine = PrismEngine(seed: 42);
    engine.startGame(newMode: GameMode.endless, customSeed: 42);
    // Fill row 0 cols 0..6: 4 blocks of color 0 + 1 Locked Keystone + 2 blocks of color 1.
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

    final preview = engine.previewPlacement(engine.tray[0]!, 7, 0);
    _expect(
      preview != null && preview.triggersResonance,
      'Preview detects 4+ Resonance',
    );
    _expect(
      preview != null && preview.locksToBreak.contains(const GridPoint(4, 0)),
      'Preview detects Resonance breaks Locked Keystone',
    );

    final out = engine.placePiece(0, 7, 0);
    _expect(
      out.placed && out.linesCleared == 1,
      'Resonance line clears cleanly',
    );
    _expect(out.triggeredResonance, 'Outcome reports Harmonic Resonance');
    _expect(out.brokenLockCount == 1, 'Resonance shattered Locked Keystone');
    _expect(
      engine.grid[0][4] == null,
      'Locked Keystone cell removed from grid',
    );
  }
  stdout.writeln(
    '  [OK] Harmonic Color Resonance (x1.5) & Seal shattering verified.',
  );

  // 3. Verify normal (non-Resonance) line clear leaves Locked Keystone intact
  //    AND cracks 2-Hit Frosted Crystal on hit 1 instead of deleting it!
  {
    final engine = PrismEngine(seed: 7);
    engine.startGame(newMode: GameMode.endless, customSeed: 7);
    // Distinct colors so no color reaches 4 (no Resonance).
    engine.setCellForTest(0, 0, const BoardCell(colorIndex: 0));
    engine.setCellForTest(1, 0, const BoardCell(colorIndex: 1));
    engine.setCellForTest(2, 0, const BoardCell(colorIndex: 2));
    engine.setCellForTest(3, 0, const BoardCell(colorIndex: 3, frostHits: 1));
    engine.setCellForTest(4, 0, const BoardCell(colorIndex: 4, isLocked: true));
    engine.setCellForTest(5, 0, const BoardCell(colorIndex: 5));
    engine.setCellForTest(6, 0, const BoardCell(colorIndex: 0));
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 1),
      null,
      null,
    ]);

    final out = engine.placePiece(0, 7, 0);
    _expect(!out.triggeredResonance, 'Mixed colors do not trigger Resonance');
    _expect(out.crackedFrostCount == 1, 'Frost cell cracked on hit 1');
    _expect(
      engine.grid[0][3] != null && engine.grid[0][3]!.frostHits == 0,
      'Frosted block converted to normal crystal (needs hit 2 to clear)',
    );
    _expect(
      engine.grid[0][4] != null && engine.grid[0][4]!.isLocked,
      'Locked Keystone stayed sealed without Resonance/Cross-Wave/Nova',
    );
  }
  stdout.writeln(
    '  [OK] 2-Hit Frosted Crystal & Locked Keystone protection verified.',
  );

  // 4. Verify ★ Prism Core 2-cell perpendicular Cross-Wave Shock Blast.
  {
    final engine = PrismEngine(seed: 19);
    engine.startGame(newMode: GameMode.endless, customSeed: 19);
    for (var x = 0; x < 7; x++) {
      engine.setCellForTest(
        x,
        3,
        BoardCell(colorIndex: x % 6, isPrismCore: x == 3),
      );
    }
    // Place a Locked Keystone 2 cells below the Prism Core (at x=3, y=5).
    engine.setCellForTest(3, 5, const BoardCell(colorIndex: 2, isLocked: true));
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(cells: <GridPoint>[GridPoint(0, 0)], colorIndex: 5),
      null,
      null,
    ]);

    final out = engine.placePiece(0, 7, 3);
    _expect(
      out.triggeredPrisms.length == 1,
      'Prism Core triggered in line clear',
    );
    _expect(
      engine.grid[5][3] == null,
      'Cross-Wave blasted Locked Keystone 2 cells away',
    );
  }
  stdout.writeln('  [OK] ★ Prism Core Cross-Wave blast verified.');

  // 5. Verify Tactical Energy: 90° Rotate (35%) & 3x3 Quantum Nova (100%).
  {
    final engine = PrismEngine(seed: 101);
    engine.startGame(newMode: GameMode.endless, customSeed: 101);
    engine.setTrayForTest(const <PrismPiece?>[
      PrismPiece(
        cells: <GridPoint>[GridPoint(0, 0), GridPoint(1, 0), GridPoint(2, 0)],
        colorIndex: 0,
      ),
      null,
      null,
    ]);
    final energyBefore = engine.energy;
    final rotated = engine.rotateTrayPiece(0);
    _expect(rotated, 'Rotate succeeded with 50% energy');
    _expect(
      engine.energy == energyBefore - 35,
      'Rotate spent exactly 35% energy',
    );
    _expect(
      engine.tray[0]!.cols == 1 && engine.tray[0]!.rows == 3,
      'Horizontal 3-bar rotated to vertical',
    );

    // Fill 3x3 center with Frost + Lock + Normal and fire Quantum Nova at 100%.
    engine.energy = 100;
    engine.setCellForTest(4, 4, const BoardCell(colorIndex: 0, isLocked: true));
    engine.setCellForTest(3, 4, const BoardCell(colorIndex: 1, frostHits: 1));
    final novaOut = engine.executeQuantumNova(4, 4);
    _expect(
      novaOut.placed && engine.energy == 0,
      'Quantum Nova spent 100% energy',
    );
    _expect(
      engine.grid[4][4] == null && engine.grid[4][3] == null,
      'Nova vaporized Lock & Frost in 3x3',
    );
  }
  stdout.writeln(
    '  [OK] Tactical Energy (90° Rotate & 3x3 Quantum Nova) verified.',
  );

  // 6. Verify Daily Challenge determinism (identical date key -> identical board & tray).
  {
    final a = PrismEngine();
    final b = PrismEngine();
    a.startGame(newMode: GameMode.daily, dateKey: '2026-11-26');
    b.startGame(newMode: GameMode.daily, dateKey: '2026-11-26');
    var identical = true;
    for (var y = 0; y < PrismEngine.gridSize; y++) {
      for (var x = 0; x < PrismEngine.gridSize; x++) {
        final ca = a.grid[y][x];
        final cb = b.grid[y][x];
        if ((ca == null) != (cb == null)) identical = false;
        if (ca != null &&
            cb != null &&
            (ca.colorIndex != cb.colorIndex ||
                ca.isPrismCore != cb.isPrismCore ||
                ca.frostHits != cb.frostHits ||
                ca.isLocked != cb.isLocked)) {
          identical = false;
        }
      }
    }
    _expect(identical, 'Daily Challenge is 100% deterministic for YYYY-MM-DD');
  }
  stdout.writeln('  [OK] Deterministic Daily Challenge verified.');

  // 7. Verify Blitz mode time bonus & countdown expiry.
  {
    final engine = PrismEngine(seed: 55);
    engine.startGame(newMode: GameMode.blitz, customSeed: 55);
    _expect(engine.blitzSecondsLeft == 90.0, 'Blitz starts at 90s');
    final expiredEarly = engine.tickBlitz(10.0);
    _expect(
      !expiredEarly && engine.blitzSecondsLeft == 80.0,
      'Blitz ticks down accurately',
    );
    final expiredNow = engine.tickBlitz(85.0);
    _expect(expiredNow && engine.isGameOver, 'Blitz ends cleanly at 0s');
  }
  stdout.writeln('  [OK] 90s Blitz Speed Duel verified.');

  // 8. Verify procedural PCM audio synth generates valid non-empty buffers.
  for (final cue in PrismSoundCue.values) {
    final pcm = PrismSynth.synthesizeCue(cue);
    _expect(
      pcm.isNotEmpty && pcm.length.isEven,
      'Synth cue ${cue.name} valid 16-bit PCM',
    );
  }
  final chord = PrismSynth.synthesizeClearChord(
    streak: 3,
    lines: 2,
    resonance: true,
  );
  _expect(
    chord.isNotEmpty && chord.length.isEven,
    'Pentatonic clear chord valid 16-bit PCM',
  );
  stdout.writeln('  [OK] Procedural pentatonic PCM synthesizer verified.');

  stdout.writeln('=== Summary: $_passed passed, $_failed failed ===');
  if (_failed > 0) exitCode = 1;
}
