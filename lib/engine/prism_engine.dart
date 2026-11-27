/// Pure-Dart tactical rules engine for PRISM FORGE (Prizma Döküm).
///
/// Closed "Forge -> Synthesize -> Refract" signature loop:
/// 1. Prism Anvil (Prizma Örsü): Free stash/swap once per turn; 3 placements
///    temper the stashed piece into Iridescent Rainbow Wildcard Glass + ★ Core.
/// 2. 2x2 Prism Synthesis (Kristal Döküm): Interlocking same-color blocks into
///    a 2x2 quad forges a brand-new ★ Prism Core on the board & cracks Frost.
/// 3. Optical Chain-Refraction (Kırılım Zinciri): Detonating a ★ Core fires
///    cardinal laser beams to aligned ★ Cores across the 8x8 board, shattering
///    🔒 Locks & cracking ❄ Frost along every beam hop.
/// 4. 4+ Harmonic Color Resonance (x1.5 score + shatters Locked Keystones).
/// 5. Tactical Overdrive Energy: 90° Rotate (35%) & 3x3 Quantum Nova (100%).
/// 6. Fair-Tray Director + 4 Modes (Endless, 24-Stage Quest, Daily, 90s Blitz).
library;

import 'dart:collection';
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
  static const int forgeMaxCharge = 3;

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

  static const List<GridPoint> _cardinalDirs = <GridPoint>[
    GridPoint(1, 0),
    GridPoint(-1, 0),
    GridPoint(0, 1),
    GridPoint(0, -1),
  ];

  late SeededRandom _rng;
  late List<List<BoardCell?>> _grid;
  final List<PrismPiece?> _tray = <PrismPiece?>[null, null, null];

  /// Dedicated Prism Anvil (Forge Slot) state.
  PrismPiece? _forgedPiece;
  int _forgeCharge = 0;
  bool _forgeUsedThisTurn = false;

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
  bool reviveUsedInRun = false;

  List<List<BoardCell?>> get grid => _grid;
  List<PrismPiece?> get tray => List<PrismPiece?>.unmodifiable(_tray);
  PrismPiece? get forgedPiece => _forgedPiece;
  int get forgeCharge => _forgeCharge;
  bool get forgeUsedThisTurn => _forgeUsedThisTurn;
  bool get isForgeTempered => _forgedPiece != null && _forgedPiece!.isWildcard;
  bool get isFeverActive => streak >= 3 && streakTurnsLeft > 0;
  bool get canRevive => isGameOver && !isVictory && !reviveUsedInRun;

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
    reviveUsedInRun = false;
    _forgedPiece = null;
    _forgeCharge = 0;
    _forgeUsedThisTurn = false;

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

  /// Returns true if the player can still act (tray placement, forged piece
  /// placement, 35% rotate into a fit, or 100% Quantum Nova).
  bool hasAnyValidMove() {
    for (final p in _tray) {
      if (p != null && canPlaceAnywhere(p)) return true;
    }
    if (_forgedPiece != null && canPlaceAnywhere(_forgedPiece!)) return true;
    if (energy >= novaEnergyCost) return true;
    if (energy >= rotateEnergyCost) {
      for (final p in <PrismPiece?>[..._tray, _forgedPiece]) {
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

  /// Stashes or swaps tray piece [trayIndex] with the Prism Anvil (0% energy,
  /// once per board placement). Newly inserted pieces start at 0/3 charge.
  bool stashOrSwapWithForge(int trayIndex) {
    if (isGameOver || isVictory || _forgeUsedThisTurn) return false;
    if (trayIndex < 0 || trayIndex >= 3) return false;
    final incoming = _tray[trayIndex];
    if (incoming == null) return false;

    final outgoing = _forgedPiece;
    _forgedPiece = incoming;
    _forgeCharge = incoming.isWildcard ? forgeMaxCharge : 0;
    _tray[trayIndex] = outgoing;
    _forgeUsedThisTurn = true;

    if (_tray.every((p) => p == null)) {
      refillTray();
    }
    return true;
  }

  /// Rotates tray piece at [trayIndex] (or the Prism Anvil piece when
  /// [trayIndex == -1]) by 90° clockwise for 35% energy.
  bool rotateTrayPiece(int trayIndex) {
    if (isGameOver || isVictory) return false;
    if (energy < rotateEnergyCost) return false;
    if (trayIndex == -1) {
      if (_forgedPiece == null) return false;
      _forgedPiece = _forgedPiece!.copyWith(
        cells: ShapeLibrary.rotateCW(_forgedPiece!.cells),
      );
      energy = math.max(0, energy - rotateEnergyCost);
      return true;
    }
    if (trayIndex < 0 || trayIndex >= 3) return false;
    final piece = _tray[trayIndex];
    if (piece == null) return false;

    _tray[trayIndex] = piece.copyWith(
      cells: ShapeLibrary.rotateCW(piece.cells),
    );
    energy = math.max(0, energy - rotateEnergyCost);
    return true;
  }

  static bool _lineHasResonance(Iterable<BoardCell?> cells) {
    final counts = <int, int>{};
    var wildcards = 0;
    var maxColor = 0;
    for (final cell in cells) {
      if (cell == null) continue;
      if (cell.isWildcard) {
        wildcards++;
      } else {
        final next = (counts[cell.colorIndex] ?? 0) + 1;
        counts[cell.colorIndex] = next;
        if (next > maxColor) maxColor = next;
      }
    }
    return (maxColor + wildcards) >= 4;
  }

  /// Scans all 2x2 windows touching [placedCoords] for 2x2 Prism Synthesis.
  /// Returns synthesized core positions, 2x2 top-left origins, and frost cells
  /// thermally cracked inside synthesized quads (mutating [board] in-place).
  static ({
    List<GridPoint> cores,
    List<GridPoint> quadOrigins,
    List<GridPoint> frostCracks,
  })
  _apply2x2Synthesis(
    List<List<BoardCell?>> board,
    Set<GridPoint> placedCoords,
  ) {
    final cores = <GridPoint>[];
    final origins = <GridPoint>[];
    final frostCracks = <GridPoint>[];

    for (var y = 0; y < gridSize - 1; y++) {
      for (var x = 0; x < gridSize - 1; x++) {
        final pts = <GridPoint>[
          GridPoint(x, y),
          GridPoint(x + 1, y),
          GridPoint(x, y + 1),
          GridPoint(x + 1, y + 1),
        ];

        var hasNew = false;
        var hasExisting = false;
        var invalid = false;
        int? commonColor;
        GridPoint? upgradeTarget;

        for (final pt in pts) {
          final cell = board[pt.y][pt.x];
          if (cell == null || cell.isLocked || cell.isPrismCore) {
            invalid = true;
            break;
          }
          if (placedCoords.contains(pt)) {
            hasNew = true;
            upgradeTarget ??= pt;
          } else {
            hasExisting = true;
          }
          if (!cell.isWildcard) {
            if (commonColor == null) {
              commonColor = cell.colorIndex;
            } else if (commonColor != cell.colorIndex) {
              invalid = true;
              break;
            }
          }
        }

        if (invalid || !hasNew || !hasExisting || upgradeTarget == null) {
          continue;
        }

        board[upgradeTarget.y][upgradeTarget.x] =
            board[upgradeTarget.y][upgradeTarget.x]!.copyWith(
              isPrismCore: true,
            );
        cores.add(upgradeTarget);
        origins.add(GridPoint(x, y));

        for (final pt in pts) {
          final c = board[pt.y][pt.x]!;
          if (c.frostHits > 0) {
            board[pt.y][pt.x] = c.copyWith(frostHits: 0);
            if (!frostCracks.contains(pt)) frostCracks.add(pt);
          }
        }
      }
    }

    return (cores: cores, quadOrigins: origins, frostCracks: frostCracks);
  }

  /// Expands local 2-cell Cross-Wave + cardinal ★→★ Optical Chain-Refraction
  /// BFS starting from [seedPrisms]. Mutates [hits] (`forceBreak = true`).
  static ({
    List<RefractionBeam> beams,
    List<GridPoint> allTriggeredPrisms,
    int extraCellsHit,
  })
  _expandOpticalChain(
    List<List<BoardCell?>> board,
    List<GridPoint> seedPrisms,
    Map<GridPoint, bool> hits,
  ) {
    final visited = <GridPoint>{...seedPrisms};
    final depthMap = <GridPoint, int>{for (final p in seedPrisms) p: 0};
    final queue = Queue<GridPoint>()..addAll(seedPrisms);
    final beams = <RefractionBeam>[];
    final allPrisms = List<GridPoint>.from(seedPrisms);
    var extraCells = 0;

    while (queue.isNotEmpty) {
      final pr = queue.removeFirst();
      final depth = depthMap[pr]!;

      // 1. Local 2-cell perpendicular Cross-Wave.
      for (final d in _crossOffsets) {
        final nx = pr.x + d.x;
        final ny = pr.y + d.y;
        if (nx < 0 || ny < 0 || nx >= gridSize || ny >= gridSize) continue;
        final cell = board[ny][nx];
        if (cell == null) continue;
        final pt = GridPoint(nx, ny);
        if (!hits.containsKey(pt)) extraCells++;
        hits[pt] = true;
        if (cell.isPrismCore && visited.add(pt)) {
          depthMap[pt] = depth + 1;
          allPrisms.add(pt);
          queue.add(pt);
        }
      }

      // 2. Cardinal Optical Chain-Refraction: find nearest unvisited ★ core.
      for (final dir in _cardinalDirs) {
        var cx = pr.x + dir.x;
        var cy = pr.y + dir.y;
        final between = <GridPoint>[];
        while (cx >= 0 && cy >= 0 && cx < gridSize && cy < gridSize) {
          final pt = GridPoint(cx, cy);
          final cell = board[cy][cx];
          if (cell != null && cell.isPrismCore && !visited.contains(pt)) {
            beams.add(RefractionBeam(from: pr, to: pt, depth: depth + 1));
            for (final mid in between) {
              if (board[mid.y][mid.x] != null) {
                if (!hits.containsKey(mid)) extraCells++;
                hits[mid] = true;
              }
            }
            if (!hits.containsKey(pt)) extraCells++;
            hits[pt] = true;
            visited.add(pt);
            depthMap[pt] = depth + 1;
            allPrisms.add(pt);
            queue.add(pt);
            break;
          }
          between.add(pt);
          cx += dir.x;
          cy += dir.y;
        }
      }
    }

    return (
      beams: beams,
      allTriggeredPrisms: allPrisms,
      extraCellsHit: extraCells,
    );
  }

  /// Computes full pre-drop preview (2x2 Synthesis, lines, Resonance,
  /// Cross-Waves, ★→★ Optical Laser Beams, Frost cracks & Lock shatters).
  PlacementPreview? previewPlacement(PrismPiece piece, int gx, int gy) {
    if (!canPlaceAt(piece, gx, gy)) return null;

    final virtual = List<List<BoardCell?>>.generate(
      gridSize,
      (y) => List<BoardCell?>.from(_grid[y]),
    );
    final placedCoords = <GridPoint>{};
    for (var i = 0; i < piece.cells.length; i++) {
      final c = piece.cells[i];
      final pt = GridPoint(gx + c.x, gy + c.y);
      placedCoords.add(pt);
      virtual[pt.y][pt.x] = BoardCell(
        colorIndex: piece.colorIndex,
        isPrismCore: i == piece.prismCellIndex,
        isWildcard: piece.isWildcard,
      );
    }

    final synth = _apply2x2Synthesis(virtual, placedCoords);

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
    final hits = <GridPoint, bool>{};
    for (final y in rows) {
      if (_lineHasResonance(virtual[y])) resonance = true;
      for (var x = 0; x < gridSize; x++) {
        hits[GridPoint(x, y)] = false;
      }
    }
    for (final x in cols) {
      final col = <BoardCell?>[
        for (var y = 0; y < gridSize; y++) virtual[y][x],
      ];
      if (_lineHasResonance(col)) resonance = true;
      for (var y = 0; y < gridSize; y++) {
        hits[GridPoint(x, y)] = false;
      }
    }
    if (resonance) {
      for (final k in hits.keys.toList()) {
        hits[k] = true;
      }
    }

    final seedPrisms = <GridPoint>[
      for (final pt in hits.keys)
        if (virtual[pt.y][pt.x]?.isPrismCore == true) pt,
    ];
    final chain = _expandOpticalChain(virtual, seedPrisms, hits);

    final frosts = List<GridPoint>.from(synth.frostCracks);
    final locks = <GridPoint>[];
    for (final entry in hits.entries) {
      final pt = entry.key;
      final cell = virtual[pt.y][pt.x];
      if (cell == null) continue;
      if (cell.frostHits > 0 && !frosts.contains(pt)) frosts.add(pt);
      if (cell.isLocked && entry.value && !locks.contains(pt)) locks.add(pt);
    }

    return PlacementPreview(
      anchor: GridPoint(gx, gy),
      rowsToClear: rows,
      colsToClear: cols,
      triggersResonance: resonance,
      triggeredPrisms: chain.allTriggeredPrisms,
      frostToCrack: frosts,
      locksToBreak: locks,
      refractionBeams: chain.beams,
      synthesizedCores: synth.cores,
      synthesisQuadOrigins: synth.quadOrigins,
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
    _tray[trayIndex] = null;
    return _commitPlacedPiece(piece, gx, gy, fromForge: false);
  }

  /// Places the piece currently held in the Prism Anvil directly onto the board.
  MoveOutcome placeForgedPiece(int gx, int gy) {
    if (isGameOver || isVictory) return const MoveOutcome(placed: false);
    final piece = _forgedPiece;
    if (piece == null || !canPlaceAt(piece, gx, gy)) {
      return const MoveOutcome(placed: false);
    }
    _forgedPiece = null;
    _forgeCharge = 0;
    return _commitPlacedPiece(piece, gx, gy, fromForge: true);
  }

  MoveOutcome _commitPlacedPiece(
    PrismPiece piece,
    int gx,
    int gy, {
    required bool fromForge,
  }) {
    final placedCoords = <GridPoint>{};
    for (var i = 0; i < piece.cells.length; i++) {
      final c = piece.cells[i];
      final pt = GridPoint(gx + c.x, gy + c.y);
      placedCoords.add(pt);
      _grid[pt.y][pt.x] = BoardCell(
        colorIndex: piece.colorIndex,
        isPrismCore: i == piece.prismCellIndex,
        isWildcard: piece.isWildcard,
      );
    }

    var pointsEarned = piece.cells.length * 10;
    if (piece.isWildcard) {
      pointsEarned += 50;
      energy = math.min(100, energy + 10);
    }
    score += pointsEarned;

    // Step A — 2x2 Prism Synthesis BEFORE line clears (enables forge+detonate!).
    final synth = _apply2x2Synthesis(_grid, placedCoords);
    var crackedFrost = synth.frostCracks.length;
    collectedFrost = math.min(targetFrost, collectedFrost + crackedFrost);
    var blitzBonus = 0;
    if (synth.cores.isNotEmpty) {
      final synthPts = synth.cores.length * 100 + crackedFrost * 40;
      score += synthPts;
      pointsEarned += synthPts;
      energy = math.min(100, energy + synth.cores.length * 12);
      if (mode == GameMode.blitz) {
        final add = synth.cores.length * 2;
        blitzBonus += add;
        blitzSecondsLeft = math.min(99.0, blitzSecondsLeft + add);
      }
    }

    // Step B — Full row & column detection + Wildcard-aware Resonance.
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
    var triggeredPrisms = <GridPoint>[];
    var refractionBeams = <RefractionBeam>[];
    var brokenLocks = 0;
    final clearedCells = <GridPoint>[];
    var allClear = false;

    final totalLines = fullRows.length + fullCols.length;
    if (totalLines > 0) {
      final hits = <GridPoint, bool>{};
      for (final y in fullRows) {
        if (_lineHasResonance(_grid[y])) triggeredResonance = true;
        for (var x = 0; x < gridSize; x++) {
          hits[GridPoint(x, y)] = false;
        }
      }
      for (final x in fullCols) {
        final col = <BoardCell?>[
          for (var y = 0; y < gridSize; y++) _grid[y][x],
        ];
        if (_lineHasResonance(col)) triggeredResonance = true;
        for (var y = 0; y < gridSize; y++) {
          hits[GridPoint(x, y)] = false;
        }
      }

      if (triggeredResonance) {
        for (final key in hits.keys.toList()) {
          hits[key] = true;
        }
      }

      // Step C — Cross-Wave + Optical Chain-Refraction BFS.
      final seedPrisms = <GridPoint>[
        for (final pt in hits.keys)
          if (_grid[pt.y][pt.x]?.isPrismCore == true) pt,
      ];
      final chain = _expandOpticalChain(_grid, seedPrisms, hits);
      triggeredPrisms = chain.allTriggeredPrisms;
      refractionBeams = chain.beams;

      // Step D — Apply hits respecting Locked Keystones & 2-Hit Frost.
      var lineFrostCracked = 0;
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
          lineFrostCracked++;
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

      final wasFever = isFeverActive;
      streak = math.min(8, streak + 1);
      streakTurnsLeft = 3;
      final enteredFever = !wasFever && isFeverActive;
      energy = math.min(
        100,
        energy +
            totalLines * 18 +
            (triggeredResonance ? 15 : 0) +
            seedPrisms.length * 14 +
            refractionBeams.length * 10,
      );

      if (mode == GameMode.blitz) {
        final add =
            totalLines * 3 +
            (triggeredResonance ? 5 : 0) +
            refractionBeams.length * 2;
        blitzBonus += add;
        blitzSecondsLeft = math.min(99.0, blitzSecondsLeft + add);
      }

      final beamPts = refractionBeams.fold<int>(
        0,
        (sum, b) => sum + 120 * b.depth,
      );
      var linePts =
          totalLines * totalLines * 100 * streak +
          chain.extraCellsHit * 35 +
          beamPts +
          brokenLocks * 80 +
          lineFrostCracked * 40;
      if (triggeredResonance) {
        linePts = (linePts * 1.5).round();
      }
      if (isFeverActive) {
        linePts *= 2;
      }

      allClear = _isBoardEmpty();
      if (allClear) {
        linePts += 1000;
      }

      score += linePts;
      pointsEarned += linePts;

      // Step E — Prism Anvil 3-Turn Tempering Progression!
      _forgeUsedThisTurn = false;
      var forgeTempered = false;
      if (!fromForge && _forgedPiece != null && _forgeCharge < forgeMaxCharge) {
        _forgeCharge++;
        if (_forgeCharge >= forgeMaxCharge && !_forgedPiece!.isWildcard) {
          _forgedPiece = _forgedPiece!.copyWith(
            isWildcard: true,
            prismCellIndex: _forgedPiece!.prismCellIndex >= 0
                ? _forgedPiece!.prismCellIndex
                : 0,
          );
          forgeTempered = true;
        }
      }

      // Step F — Refill tray & check victory / game over.
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
        refractionBeams: refractionBeams,
        synthesizedCores: synth.cores,
        forgeTempered: forgeTempered,
        enteredFever: enteredFever,
        crackedFrostCount: crackedFrost,
        brokenLockCount: brokenLocks,
        clearedCells: clearedCells,
        allClearBonus: allClear,
        blitzSecondsAdded: blitzBonus,
        objectiveCompleted: isVictory,
        gameOver: isGameOver,
      );
    } else {
      if (streakTurnsLeft > 0) {
        streakTurnsLeft--;
        if (streakTurnsLeft == 0) streak = 0;
      }
      energy = math.min(100, energy + 3);
    }

    // Step E — Prism Anvil 3-Turn Tempering Progression!
    _forgeUsedThisTurn = false;
    var forgeTempered = false;
    if (!fromForge && _forgedPiece != null && _forgeCharge < forgeMaxCharge) {
      _forgeCharge++;
      if (_forgeCharge >= forgeMaxCharge && !_forgedPiece!.isWildcard) {
        _forgedPiece = _forgedPiece!.copyWith(
          isWildcard: true,
          prismCellIndex: _forgedPiece!.prismCellIndex >= 0
              ? _forgedPiece!.prismCellIndex
              : 0,
        );
        forgeTempered = true;
      }
    }

    // Step F — Refill tray & check victory / game over.
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
      refractionBeams: refractionBeams,
      synthesizedCores: synth.cores,
      forgeTempered: forgeTempered,
      crackedFrostCount: crackedFrost,
      brokenLockCount: brokenLocks,
      clearedCells: clearedCells,
      allClearBonus: allClear,
      blitzSecondsAdded: blitzBonus,
      objectiveCompleted: isVictory,
      gameOver: isGameOver,
    );
  }

  /// Rewarded Ad "Son Nefes / Rescue Revive" (max 1 per run): vaporizes the
  /// center 3x3 zone, restores 100% Tactical Energy (+15s in Blitz), and
  /// resumes gameplay cleanly.
  MoveOutcome reviveWithRescueNova() {
    if (!canRevive) return const MoveOutcome(placed: false);
    reviveUsedInRun = true;
    isGameOver = false;

    final cleared = <GridPoint>[];
    for (var y = 2; y <= 5; y++) {
      for (var x = 2; x <= 5; x++) {
        if (x < 3 || x > 5 || y < 3 || y > 5) continue;
        final cell = _grid[y][x];
        if (cell == null) continue;
        if (cell.isPrismCore) {
          collectedCores = math.min(targetCores, collectedCores + 1);
        }
        if (cell.frostHits > 0) {
          collectedFrost = math.min(targetFrost, collectedFrost + 1);
        }
        if (cell.isLocked) {
          collectedLocks = math.min(targetLocks, collectedLocks + 1);
        }
        _grid[y][x] = null;
        cleared.add(GridPoint(x, y));
      }
    }

    energy = 100;
    if (mode == GameMode.blitz && blitzSecondsLeft <= 0) {
      blitzSecondsLeft = 20.0;
    }
    if (isObjectiveComplete) {
      isVictory = true;
    }

    return MoveOutcome(
      placed: true,
      clearedCells: cleared,
      objectiveCompleted: isVictory,
      gameOver: false,
    );
  }

  /// Rewarded Ad optional boost: refills Tactical Energy to 100%.
  void grantEnergyBoost() {
    energy = 100;
  }

  /// True when a piece is waiting in the Prism Anvil and not yet tempered.
  bool get canInstantTemperForge =>
      _forgedPiece != null &&
      !_forgedPiece!.isWildcard &&
      !isGameOver &&
      !isVictory;

  /// Rewarded Ad optional boost: instantly tempers the stashed Anvil piece
  /// into Iridescent Rainbow Wildcard Glass + ★ Prism Core.
  bool instantTemperForge() {
    if (!canInstantTemperForge) return false;
    _forgeCharge = forgeMaxCharge;
    _forgedPiece = _forgedPiece!.copyWith(
      isWildcard: true,
      prismCellIndex: _forgedPiece!.prismCellIndex >= 0
          ? _forgedPiece!.prismCellIndex
          : 0,
    );
    return true;
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
