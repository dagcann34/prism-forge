/// Pure-Dart tactical rules engine for PRISM FORGE (Prizma Döküm).
///
/// Implements all signature next-gen mechanics:
/// 1. 4+ Same-Color Harmonic Resonance (x1.5 score + breaks Locked Keystones)
/// 2. ★ Prism Core 2-cell perpendicular Cross-Wave Shock Blast
/// 3. ❄ 2-Hit Frosted Crystals (hit 1 cracks frost -> hit 2 clears)
/// 4. 🔒 Locked Keystones (shattered by Resonance, Cross-Wave, or Quantum Nova)
/// 5. Tactical Overdrive Energy: 90° Rotate (35%) & 3x3 Quantum Nova (100%)
/// 6. Fair-Tray Director: prevents impossible 3-piece trays when a fit exists
/// 7. 4 Game Modes: Endless, 24-Stage Quest, Deterministic Daily, 90s Blitz
library;

import 'dart:math' as math;

import 'models.dart';
import 'quest_stages.dart';
import 'shapes.dart';

class PrismEngine {
  PrismEngine({int? seed})
    : _rng = SeededRandom(seed ?? DateTime.now().microsecondsSinceEpoch) {
    _grid = _emptyGrid();
  }

  static const int gridSize = 8;
  static const int paletteColorCount = 6;
  static const int rotateEnergyCost = 35;
  static const int novaEnergyCost = 100;
  static const int blitzInitialSeconds = 90;

  static const List<GridPoint> _crossOffsets = <GridPoint>[
    GridPoint(1, 0),
    GridPoint(-1, 0),
    GridPoint(0, 1),
    GridPoint(0, -1),
    GridPoint(2, 0),
    GridPoint(-2, 0),
    GridPoint(0, 2),
    GridPoint(0, -2),
  ];

  late SeededRandom _rng;
  late List<List<BoardCell?>> _grid;
  final List<PrismPiece?> _tray = <PrismPiece?>[null, null, null];

  GameMode mode = GameMode.quest;
  int questStageNumber = 1;
  String dailyDateKey = '';

  int score = 0;
  int streak = 0;
  int streakTurnsLeft = 0;
  int energy = 50;

  int targetCores = 0;
  int collectedCores = 0;
  int targetFrost = 0;
  int collectedFrost = 0;
  int targetLocks = 0;
  int collectedLocks = 0;

  double blitzSecondsLeft = blitzInitialSeconds.toDouble();
  bool isGameOver = false;
  bool isVictory = false;

  List<List<BoardCell?>> get grid => _grid;
  List<PrismPiece?> get tray => List<PrismPiece?>.unmodifiable(_tray);

  int get totalTargets => targetCores + targetFrost + targetLocks;
  int get totalCollected => collectedCores + collectedFrost + collectedLocks;
  bool get isObjectiveComplete =>
      (mode == GameMode.quest || mode == GameMode.daily) &&
      collectedCores >= targetCores &&
      collectedFrost >= targetFrost &&
      collectedLocks >= targetLocks;

  static List<List<BoardCell?>> _emptyGrid() => List<List<BoardCell?>>.generate(
    gridSize,
    (_) => List<BoardCell?>.filled(gridSize, null),
  );

  /// Formats a DateTime into deterministic 'YYYY-MM-DD' daily key.
  static String formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Starts or resets a game in the requested [newMode].
  void startGame({
    required GameMode newMode,
    int? stageNumber,
    String? dateKey,
    int? customSeed,
  }) {
    mode = newMode;
    score = 0;
    streak = 0;
    streakTurnsLeft = 0;
    energy = 50;
    targetCores = 0;
    collectedCores = 0;
    targetFrost = 0;
    collectedFrost = 0;
    targetLocks = 0;
    collectedLocks = 0;
    blitzSecondsLeft = blitzInitialSeconds.toDouble();
    isGameOver = false;
    isVictory = false;

    if (newMode == GameMode.quest) {
      questStageNumber = (stageNumber ?? questStageNumber).clamp(
        1,
        QuestStageCatalog.stages.length,
      );
      final spec = QuestStageCatalog.byNumber(questStageNumber);
      _rng = SeededRandom(
        customSeed ??
            SeededRandom.hashString('prism_forge_quest_${spec.stageNumber}_v1'),
      );
      _seedSpecialBoard(
        cores: spec.targetCores,
        frost: spec.targetFrost,
        locks: spec.targetLocks,
        clutter: spec.initialClutter,
      );
    } else if (newMode == GameMode.daily) {
      dailyDateKey = dateKey ?? formatDateKey(DateTime.now());
      _rng = SeededRandom(
        customSeed ??
            SeededRandom.hashString('prism_forge_daily_$dailyDateKey'),
      );
      _seedSpecialBoard(cores: 3, frost: 3, locks: 2, clutter: 13);
    } else {
      _rng = SeededRandom(customSeed ?? DateTime.now().microsecondsSinceEpoch);
      _grid = _emptyGrid();
    }

    refillTray();
  }

  /// Direct cell setter for deterministic unit testing.
  void setCellForTest(int x, int y, BoardCell? cell) {
    _grid[y][x] = cell;
  }

  /// Direct tray setter for deterministic unit testing.
  void setTrayForTest(List<PrismPiece?> pieces) {
    for (var i = 0; i < 3; i++) {
      _tray[i] = i < pieces.length ? pieces[i] : null;
    }
  }

  void _seedSpecialBoard({
    required int cores,
    required int frost,
    required int locks,
    required int clutter,
  }) {
    _grid = _emptyGrid();
    targetCores = cores;
    targetFrost = frost;
    targetLocks = locks;

    final totalCells = math.min(
      24,
      math.max(clutter, cores + frost + locks + 3),
    );
    final coords = <GridPoint>[];
    var safety = 0;

    while (coords.length < totalCells && safety < 320) {
      safety++;
      final x = _rng.nextInt(gridSize);
      final y = _rng.nextInt(gridSize);
      if (_grid[y][x] != null) continue;

      var rowCount = 0;
      var colCount = 0;
      for (var i = 0; i < gridSize; i++) {
        if (_grid[y][i] != null) rowCount++;
        if (_grid[i][x] != null) colCount++;
      }
      if (rowCount >= 5 || colCount >= 5) continue;

      _grid[y][x] = BoardCell(colorIndex: _rng.nextInt(paletteColorCount));
      coords.add(GridPoint(x, y));
    }

    // Fisher-Yates shuffle for special tile assignment.
    for (var i = coords.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final tmp = coords[i];
      coords[i] = coords[j];
      coords[j] = tmp;
    }

    var ptr = 0;
    for (var i = 0; i < cores && ptr < coords.length; i++, ptr++) {
      final p = coords[ptr];
      _grid[p.y][p.x] = _grid[p.y][p.x]!.copyWith(isPrismCore: true);
    }
    for (var i = 0; i < frost && ptr < coords.length; i++, ptr++) {
      final p = coords[ptr];
      _grid[p.y][p.x] = _grid[p.y][p.x]!.copyWith(frostHits: 1);
    }
    for (var i = 0; i < locks && ptr < coords.length; i++, ptr++) {
      final p = coords[ptr];
      _grid[p.y][p.x] = _grid[p.y][p.x]!.copyWith(isLocked: true);
    }
  }

  /// Checks whether [piece] fits cleanly at top-left anchor ([gx], [gy]).
  bool canPlaceAt(PrismPiece piece, int gx, int gy) {
    for (final c in piece.cells) {
      final x = gx + c.x;
      final y = gy + c.y;
      if (x < 0 || y < 0 || x >= gridSize || y >= gridSize) return false;
      if (_grid[y][x] != null) return false;
    }
    return true;
  }

  /// Checks whether [piece] has at least one valid anchor on the board.
  bool canPlaceAnywhere(PrismPiece piece) {
    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        if (canPlaceAt(piece, x, y)) return true;
      }
    }
    return false;
  }

  /// Returns true if the player can still act (direct placement, 35% rotate
  /// into a legal fit, or 100% Quantum Nova).
  bool hasAnyValidMove() {
    for (final p in _tray) {
      if (p != null && canPlaceAnywhere(p)) return true;
    }
    if (energy >= novaEnergyCost) return true;
    if (energy >= rotateEnergyCost) {
      for (final p in _tray) {
        if (p == null) continue;
        var cells = p.cells;
        for (var r = 0; r < 3; r++) {
          cells = ShapeLibrary.rotateCW(cells);
          if (canPlaceAnywhere(p.copyWith(cells: cells))) return true;
        }
      }
    }
    return false;
  }

  PrismPiece _generatePiece({required bool forceFit}) {
    var cells = ShapeLibrary.pickWeighted(_rng);
    if (forceFit) {
      for (var attempt = 0; attempt < 24; attempt++) {
        final cand = ShapeLibrary.pickWeighted(_rng);
        if (canPlaceAnywhere(PrismPiece(cells: cand, colorIndex: 0))) {
          cells = cand;
          break;
        }
      }
      if (!canPlaceAnywhere(PrismPiece(cells: cells, colorIndex: 0))) {
        const fallbacks = <List<GridPoint>>[
          <GridPoint>[GridPoint(0, 0)],
          <GridPoint>[GridPoint(0, 0), GridPoint(1, 0)],
          <GridPoint>[GridPoint(0, 0), GridPoint(0, 1)],
        ];
        for (final fb in fallbacks) {
          if (canPlaceAnywhere(PrismPiece(cells: fb, colorIndex: 0))) {
            cells = fb;
            break;
          }
        }
      }
    }

    final colorIdx = _rng.nextInt(paletteColorCount);
    final hasPrism = cells.length >= 3 && _rng.nextDouble() < 0.24;
    final prismIdx = hasPrism ? _rng.nextInt(cells.length) : -1;
    return PrismPiece(
      cells: cells,
      colorIndex: colorIdx,
      prismCellIndex: prismIdx,
    );
  }

  /// Fair-Tray Director: guarantees at least one piece in every fresh 3-piece
  /// tray fits the current board whenever any legal fit exists.
  void refillTray() {
    final generated = <PrismPiece>[
      _generatePiece(forceFit: true),
      _generatePiece(forceFit: false),
      _generatePiece(forceFit: false),
    ];
    for (var i = generated.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final tmp = generated[i];
      generated[i] = generated[j];
      generated[j] = tmp;
    }
    for (var i = 0; i < 3; i++) {
      _tray[i] = generated[i];
    }
  }

  /// Rotates tray piece at [trayIndex] by 90° clockwise for 35% energy.
  bool rotateTrayPiece(int trayIndex) {
    if (isGameOver || isVictory) return false;
    if (energy < rotateEnergyCost) return false;
    if (trayIndex < 0 || trayIndex >= 3) return false;
    final piece = _tray[trayIndex];
    if (piece == null) return false;

    _tray[trayIndex] = piece.copyWith(
      cells: ShapeLibrary.rotateCW(piece.cells),
    );
    energy = math.max(0, energy - rotateEnergyCost);
    return true;
  }

  /// Computes full pre-drop preview (lines, Resonance, Cross-Waves, Frost/Locks).
  PlacementPreview? previewPlacement(PrismPiece piece, int gx, int gy) {
    if (!canPlaceAt(piece, gx, gy)) return null;

    final virtual = List<List<BoardCell?>>.generate(
      gridSize,
      (y) => List<BoardCell?>.from(_grid[y]),
    );
    for (var i = 0; i < piece.cells.length; i++) {
      final c = piece.cells[i];
      virtual[gy + c.y][gx + c.x] = BoardCell(
        colorIndex: piece.colorIndex,
        isPrismCore: i == piece.prismCellIndex,
      );
    }

    final rows = <int>[];
    final cols = <int>[];
    for (var y = 0; y < gridSize; y++) {
      if (virtual[y].every((cell) => cell != null)) rows.add(y);
    }
    for (var x = 0; x < gridSize; x++) {
      var full = true;
      for (var y = 0; y < gridSize; y++) {
        if (virtual[y][x] == null) {
          full = false;
          break;
        }
      }
      if (full) cols.add(x);
    }

    var resonance = false;
    bool lineHasResonance(Iterable<BoardCell?> cells) {
      final counts = <int, int>{};
      for (final cell in cells) {
        if (cell == null) continue;
        final next = (counts[cell.colorIndex] ?? 0) + 1;
        counts[cell.colorIndex] = next;
        if (next >= 4) return true;
      }
      return false;
    }

    final lineCoords = <GridPoint>{};
    for (final y in rows) {
      if (lineHasResonance(virtual[y])) resonance = true;
      for (var x = 0; x < gridSize; x++) {
        lineCoords.add(GridPoint(x, y));
      }
    }
    for (final x in cols) {
      final colCells = <BoardCell?>[
        for (var y = 0; y < gridSize; y++) virtual[y][x],
      ];
      if (lineHasResonance(colCells)) resonance = true;
      for (var y = 0; y < gridSize; y++) {
        lineCoords.add(GridPoint(x, y));
      }
    }

    final prisms = <GridPoint>[];
    final frosts = <GridPoint>[];
    final locks = <GridPoint>[];

    for (final p in lineCoords) {
      final cell = virtual[p.y][p.x];
      if (cell == null) continue;
      if (cell.isPrismCore) prisms.add(p);
      if (cell.frostHits > 0) frosts.add(p);
      if (cell.isLocked && resonance) locks.add(p);
    }

    for (final pr in prisms) {
      for (final d in _crossOffsets) {
        final nx = pr.x + d.x;
        final ny = pr.y + d.y;
        if (nx < 0 || ny < 0 || nx >= gridSize || ny >= gridSize) continue;
        final target = virtual[ny][nx];
        if (target == null) continue;
        final pt = GridPoint(nx, ny);
        if (target.isLocked && !locks.contains(pt)) locks.add(pt);
        if (target.frostHits > 0 && !frosts.contains(pt)) frosts.add(pt);
      }
    }

    return PlacementPreview(
      anchor: GridPoint(gx, gy),
      rowsToClear: rows,
      colsToClear: cols,
      triggersResonance: resonance,
      triggeredPrisms: prisms,
      frostToCrack: frosts,
      locksToBreak: locks,
    );
  }

  /// Places tray piece [trayIndex] at ([gx], [gy]) and resolves all cascades.
  MoveOutcome placePiece(int trayIndex, int gx, int gy) {
    if (isGameOver || isVictory) return const MoveOutcome(placed: false);
    if (trayIndex < 0 || trayIndex >= 3)
      return const MoveOutcome(placed: false);
    final piece = _tray[trayIndex];
    if (piece == null || !canPlaceAt(piece, gx, gy)) {
      return const MoveOutcome(placed: false);
    }

    for (var i = 0; i < piece.cells.length; i++) {
      final c = piece.cells[i];
      _grid[gy + c.y][gx + c.x] = BoardCell(
        colorIndex: piece.colorIndex,
        isPrismCore: i == piece.prismCellIndex,
      );
    }
    _tray[trayIndex] = null;

    var pointsEarned = piece.cells.length * 10;
    score += pointsEarned;

    // Detect full rows & columns.
    final fullRows = <int>[];
    final fullCols = <int>[];
    for (var y = 0; y < gridSize; y++) {
      if (_grid[y].every((cell) => cell != null)) fullRows.add(y);
    }
    for (var x = 0; x < gridSize; x++) {
      var ok = true;
      for (var y = 0; y < gridSize; y++) {
        if (_grid[y][x] == null) {
          ok = false;
          break;
        }
      }
      if (ok) fullCols.add(x);
    }

    var triggeredResonance = false;
    final triggeredPrisms = <GridPoint>[];
    var crackedFrost = 0;
    var brokenLocks = 0;
    final clearedCells = <GridPoint>[];
    var allClear = false;
    var blitzBonus = 0;

    final totalLines = fullRows.length + fullCols.length;
    if (totalLines > 0) {
      bool lineHasResonance(Iterable<BoardCell?> cells) {
        final counts = <int, int>{};
        for (final cell in cells) {
          if (cell == null) continue;
          final next = (counts[cell.colorIndex] ?? 0) + 1;
          counts[cell.colorIndex] = next;
          if (next >= 4) return true;
        }
        return false;
      }

      // Map of coordinates hit -> whether forceBreak (breaks Locked Keystones).
      final hits = <GridPoint, bool>{};
      for (final y in fullRows) {
        if (lineHasResonance(_grid[y])) triggeredResonance = true;
        for (var x = 0; x < gridSize; x++) {
          hits[GridPoint(x, y)] = false;
        }
      }
      for (final x in fullCols) {
        final col = <BoardCell?>[
          for (var y = 0; y < gridSize; y++) _grid[y][x],
        ];
        if (lineHasResonance(col)) triggeredResonance = true;
        for (var y = 0; y < gridSize; y++) {
          hits[GridPoint(x, y)] = false;
        }
      }

      if (triggeredResonance) {
        for (final key in hits.keys.toList()) {
          hits[key] = true;
        }
      }

      // Identify Prism Cores inside cleared lines and expand 2-cell Cross-Wave.
      for (final pt in hits.keys.toList()) {
        final cell = _grid[pt.y][pt.x];
        if (cell != null && cell.isPrismCore) {
          triggeredPrisms.add(pt);
        }
      }

      var crossExtra = 0;
      for (final pr in triggeredPrisms) {
        for (final d in _crossOffsets) {
          final nx = pr.x + d.x;
          final ny = pr.y + d.y;
          if (nx < 0 || ny < 0 || nx >= gridSize || ny >= gridSize) continue;
          if (_grid[ny][nx] == null) continue;
          final pt = GridPoint(nx, ny);
          if (!hits.containsKey(pt)) crossExtra++;
          hits[pt] = true;
        }
      }

      // Apply hits respecting Locked Keystones & 2-Hit Frosted Crystals.
      for (final entry in hits.entries) {
        final pt = entry.key;
        final forceBreak = entry.value;
        final cell = _grid[pt.y][pt.x];
        if (cell == null) continue;

        if (cell.isLocked) {
          if (forceBreak) {
            brokenLocks++;
            collectedLocks = math.min(targetLocks, collectedLocks + 1);
            _grid[pt.y][pt.x] = null;
            clearedCells.add(pt);
          }
          continue;
        }

        if (cell.frostHits > 0) {
          crackedFrost++;
          collectedFrost = math.min(targetFrost, collectedFrost + 1);
          _grid[pt.y][pt.x] = cell.copyWith(frostHits: 0);
          continue;
        }

        if (cell.isPrismCore) {
          collectedCores = math.min(targetCores, collectedCores + 1);
        }
        _grid[pt.y][pt.x] = null;
        clearedCells.add(pt);
      }

      streak = math.min(8, streak + 1);
      streakTurnsLeft = 3;
      energy = math.min(
        100,
        energy +
            totalLines * 18 +
            (triggeredResonance ? 15 : 0) +
            triggeredPrisms.length * 14,
      );

      if (mode == GameMode.blitz) {
        blitzBonus = totalLines * 3 + (triggeredResonance ? 5 : 0);
        blitzSecondsLeft = math.min(99.0, blitzSecondsLeft + blitzBonus);
      }

      var linePts =
          totalLines * totalLines * 100 * streak +
          crossExtra * 35 +
          brokenLocks * 80 +
          crackedFrost * 40;
      if (triggeredResonance) {
        linePts = (linePts * 1.5).round();
      }

      allClear = _isBoardEmpty();
      if (allClear) {
        linePts += 1000;
      }

      score += linePts;
      pointsEarned += linePts;
    } else {
      if (streakTurnsLeft > 0) {
        streakTurnsLeft--;
        if (streakTurnsLeft == 0) streak = 0;
      }
      energy = math.min(100, energy + 3);
    }

    if (_tray.every((p) => p == null)) {
      refillTray();
    }

    if (isObjectiveComplete) {
      isVictory = true;
    } else if (!hasAnyValidMove()) {
      isGameOver = true;
    }

    return MoveOutcome(
      placed: true,
      pointsEarned: pointsEarned,
      linesCleared: totalLines,
      clearedRows: fullRows,
      clearedCols: fullCols,
      triggeredResonance: triggeredResonance,
      triggeredPrisms: triggeredPrisms,
      crackedFrostCount: crackedFrost,
      brokenLockCount: brokenLocks,
      clearedCells: clearedCells,
      allClearBonus: allClear,
      blitzSecondsAdded: blitzBonus,
      objectiveCompleted: isVictory,
      gameOver: isGameOver,
    );
  }

  /// Unleashes 3x3 Quantum Nova at ([cx], [cy]) for 100% energy, vaporizing
  /// normal blocks, Frosted Crystals, Prism Cores, and Locked Keystones alike.
  MoveOutcome executeQuantumNova(int cx, int cy) {
    if (isGameOver || isVictory || energy < novaEnergyCost) {
      return const MoveOutcome(placed: false);
    }

    final cleared = <GridPoint>[];
    var crackedFrost = 0;
    var brokenLocks = 0;

    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        final x = cx + dx;
        final y = cy + dy;
        if (x < 0 || y < 0 || x >= gridSize || y >= gridSize) continue;
        final cell = _grid[y][x];
        if (cell == null) continue;

        if (cell.isPrismCore) {
          collectedCores = math.min(targetCores, collectedCores + 1);
        }
        if (cell.frostHits > 0) {
          crackedFrost++;
          collectedFrost = math.min(targetFrost, collectedFrost + 1);
        }
        if (cell.isLocked) {
          brokenLocks++;
          collectedLocks = math.min(targetLocks, collectedLocks + 1);
        }
        _grid[y][x] = null;
        cleared.add(GridPoint(x, y));
      }
    }

    energy = 0;
    final pts = math.max(150, cleared.length * 50);
    score += pts;

    if (isObjectiveComplete) {
      isVictory = true;
    } else if (!hasAnyValidMove()) {
      isGameOver = true;
    }

    return MoveOutcome(
      placed: true,
      pointsEarned: pts,
      crackedFrostCount: crackedFrost,
      brokenLockCount: brokenLocks,
      clearedCells: cleared,
      objectiveCompleted: isVictory,
      gameOver: isGameOver,
    );
  }

  /// Advances Blitz countdown timer by [dtSeconds]. Returns true if time ran out.
  bool tickBlitz(double dtSeconds) {
    if (mode != GameMode.blitz || isGameOver || isVictory) return false;
    blitzSecondsLeft = math.max(0.0, blitzSecondsLeft - dtSeconds);
    if (blitzSecondsLeft <= 0.0) {
      isGameOver = true;
      return true;
    }
    return false;
  }

  /// Computes 1–3 star mastery rating for the current Quest stage.
  int computeQuestStars() {
    final spec = QuestStageCatalog.byNumber(questStageNumber);
    if (score >= spec.threeStarScore) return 3;
    if (score >= spec.twoStarScore) return 2;
    return 1;
  }

  bool _isBoardEmpty() {
    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        if (_grid[y][x] != null) return false;
      }
    }
    return true;
  }
}
