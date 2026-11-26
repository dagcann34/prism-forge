/// Main one-handed portrait gameplay screen for PRISM FORGE (Prizma Döküm).
///
/// Features:
/// - Radiant animated ambient backdrops (sunlit bubbles, candy sparkles, petals, bokeh)
/// - 3 Tray Slots + 4th Golden Prism Anvil Slot (0px extra height, 3-turn Wildcard forging)
/// - Live pre-drop previews for 2x2 Prism Synthesis, 4+ Resonance & ★->★ Laser Chains
/// - Drag-and-drop (with upward touch lift) + tap-to-place + 90° Rotate + 3x3 Quantum Nova
/// - 4 Modes, 4 Joyful Art Themes, lively multi-voice PCM audio, haptics & TR/EN
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/prism_audio.dart';
import '../audio/prism_synth.dart';
import '../engine/models.dart';
import '../engine/prism_engine.dart';
import '../l10n/prism_strings.dart';
import '../storage/prism_storage.dart';
import '../theme/prism_themes.dart';
import 'board/prism_board_painter.dart';
import 'widgets/stage_picker_sheet.dart';

class PrismGameScreen extends StatefulWidget {
  const PrismGameScreen({
    super.key,
    required this.storage,
    required this.audio,
    this.initialMode = GameMode.quest,
  });

  final PrismStorage storage;
  final PrismAudio audio;
  final GameMode initialMode;

  @override
  State<PrismGameScreen> createState() => _PrismGameScreenState();
}

class _PrismGameScreenState extends State<PrismGameScreen>
    with SingleTickerProviderStateMixin {
  /// Sentinel slot index representing the Golden Prism Anvil (Forge Slot).
  static const int _anvilSlotIndex = -1;

  final PrismEngine _engine = PrismEngine();
  final GlobalKey _boardKey = GlobalKey();
  final math.Random _fxRng = math.Random();

  late final AnimationController _ticker;
  Timer? _blitzTimer;
  Timer? _bannerTimer;

  PrismSaveData _save = const PrismSaveData();

  /// Selected slot: 0..2 for tray, -1 for Prism Anvil, null for none.
  int? _selectedSlot;
  int? _draggingSlot;
  Offset? _dragGlobalPos;
  PlacementPreview? _activePreview;
  bool _novaMode = false;
  GridPoint? _novaHover;
  String? _kineticBanner;
  Color _kineticColor = const Color(0xFFFFE14D);

  final List<ShardParticle> _particles = <ShardParticle>[];
  final List<ShockWave> _waves = <ShockWave>[];
  DateTime _lastFrame = DateTime.now();

  PrismPalette get _palette => PrismThemes.of(_save.themeId);
  AppLocale get _locale => _save.locale;

  PrismPiece? _pieceForSlot(int? slot) {
    if (slot == null) return null;
    if (slot == _anvilSlotIndex) return _engine.forgedPiece;
    if (slot >= 0 && slot < 3) return _engine.tray[slot];
    return null;
  }

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(_onAnimationTick);
    _engine.startGame(newMode: widget.initialMode, stageNumber: 1);
    unawaited(_loadSave());
  }

  Future<void> _loadSave() async {
    final loaded = await widget.storage.load();
    if (!mounted) return;
    setState(() {
      _save = loaded;
      widget.audio.soundEnabled = loaded.soundEnabled;
      widget.audio.hapticsEnabled = loaded.hapticsEnabled;
      _engine.startGame(
        newMode: widget.initialMode,
        stageNumber: loaded.currentQuestStage,
      );
      if (!loaded.reducedMotion) {
        _ticker.repeat();
      }
    });
    _syncBlitzTimer();
  }

  void _syncBlitzTimer() {
    _blitzTimer?.cancel();
    if (_engine.mode == GameMode.blitz &&
        !_engine.isGameOver &&
        !_engine.isVictory) {
      _blitzTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!mounted) return;
        final expired = _engine.tickBlitz(0.1);
        if (expired) {
          _blitzTimer?.cancel();
          widget.audio.playCue(PrismSoundCue.fail);
          _persistHighScores();
        }
        setState(() {});
      });
    }
  }

  void _onAnimationTick() {
    final now = DateTime.now();
    final dt = (now.difference(_lastFrame).inMicroseconds / 1000000.0).clamp(
      0.0,
      0.05,
    );
    _lastFrame = now;

    if (_particles.isEmpty && _waves.isEmpty) return;
    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life -= dt * 1.65;
      if (p.life <= 0) {
        _particles.removeAt(i);
        continue;
      }
      p.gx += p.vx * dt;
      p.gy += p.vy * dt;
      p.vy += 8.5 * dt;
      p.rotation += p.vRot;
    }
    for (var i = _waves.length - 1; i >= 0; i--) {
      final w = _waves[i];
      w.life -= dt * 2.2;
      if (w.life <= 0) _waves.removeAt(i);
    }
  }

  @override
  void dispose() {
    _blitzTimer?.cancel();
    _bannerTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  void _showBanner(String text, Color color) {
    _bannerTimer?.cancel();
    setState(() {
      _kineticBanner = text;
      _kineticColor = color;
    });
    _bannerTimer = Timer(const Duration(milliseconds: 1450), () {
      if (mounted) setState(() => _kineticBanner = null);
    });
  }

  void _spawnClearFx(MoveOutcome outcome) {
    if (_save.reducedMotion) return;
    for (final r in outcome.clearedRows) {
      _waves.add(ShockWave.row(r, _palette.boardBorderGlow));
    }
    for (final c in outcome.clearedCols) {
      _waves.add(ShockWave.col(c, _palette.resonanceColor));
    }
    for (final pr in outcome.triggeredPrisms) {
      _waves.add(ShockWave.ring(pr.x + 0.5, pr.y + 0.5, _palette.prismGold));
    }
    for (final s in outcome.synthesizedCores) {
      _waves.add(ShockWave.ring(s.x + 0.5, s.y + 0.5, Colors.white));
    }
    for (final beam in outcome.refractionBeams) {
      _waves.add(
        ShockWave.beam(
          beam.from.x + 0.5,
          beam.from.y + 0.5,
          beam.to.x + 0.5,
          beam.to.y + 0.5,
          _palette.prismGold,
        ),
      );
    }
    for (final pt in outcome.clearedCells) {
      final color = _palette
          .gemFor((pt.x + pt.y) % PrismEngine.paletteColorCount)
          .main;
      for (var i = 0; i < 6; i++) {
        final ang = _fxRng.nextDouble() * math.pi * 2;
        final spd = 1.6 + _fxRng.nextDouble() * 4.0;
        _particles.add(
          ShardParticle(
            gx: pt.x + 0.5,
            gy: pt.y + 0.5,
            vx: math.cos(ang) * spd,
            vy: math.sin(ang) * spd - 1.2,
            size: 0.13 + _fxRng.nextDouble() * 0.14,
            rotation: _fxRng.nextDouble() * math.pi,
            vRot: (_fxRng.nextDouble() - 0.5) * 0.28,
            color: i.isEven ? color : _palette.prismGold,
            isStar: i.isOdd,
          ),
        );
      }
    }
  }

  void _persistHighScores() {
    var updated = _save;
    if (_engine.mode == GameMode.endless &&
        _engine.score > updated.bestEndlessScore) {
      updated = updated.copyWith(bestEndlessScore: _engine.score);
    } else if (_engine.mode == GameMode.blitz &&
        _engine.score > updated.bestBlitzScore) {
      updated = updated.copyWith(bestBlitzScore: _engine.score);
    } else if (_engine.mode == GameMode.quest && _engine.isVictory) {
      final stars = _engine.computeQuestStars();
      final nextMap = Map<int, int>.from(updated.questStarsByStage);
      final prev = nextMap[_engine.questStageNumber] ?? 0;
      if (stars > prev) nextMap[_engine.questStageNumber] = stars;
      updated = updated.copyWith(
        questStarsByStage: nextMap,
        currentQuestStage: _engine.questStageNumber,
      );
    } else if (_engine.mode == GameMode.daily && _engine.isVictory) {
      final nextDates = Set<String>.from(updated.solvedDailyDates)
        ..add(_engine.dailyDateKey);
      updated = updated.copyWith(solvedDailyDates: nextDates);
    }
    _save = updated;
    unawaited(widget.storage.save(updated));
  }

  void _startMode(GameMode mode, {int? stage}) {
    setState(() {
      _selectedSlot = null;
      _draggingSlot = null;
      _activePreview = null;
      _novaMode = false;
      _novaHover = null;
      _particles.clear();
      _waves.clear();
      _engine.startGame(
        newMode: mode,
        stageNumber: stage ?? _save.currentQuestStage,
      );
      if (stage != null) {
        _save = _save.copyWith(currentQuestStage: stage);
        unawaited(widget.storage.save(_save));
      }
    });
    _syncBlitzTimer();
  }

  GridPoint? _globalToBoardAnchor(
    Offset globalPos,
    PrismPiece piece, {
    required bool applyTouchLift,
  }) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(globalPos);
    const pad = PrismBoardPainter.boardPadding;
    final cellSize = (box.size.width - pad * 2) / PrismEngine.gridSize;
    final lift = applyTouchLift ? cellSize * 1.4 : 0.0;

    final rawGx = ((local.dx - pad) / cellSize - piece.cols / 2.0).round();
    final rawGy = (((local.dy - lift) - pad) / cellSize - piece.rows / 2.0)
        .round();

    const offsets = <GridPoint>[
      GridPoint(0, 0),
      GridPoint(1, 0),
      GridPoint(-1, 0),
      GridPoint(0, 1),
      GridPoint(0, -1),
    ];
    for (final d in offsets) {
      final gx = rawGx + d.x;
      final gy = rawGy + d.y;
      if (_engine.canPlaceAt(piece, gx, gy)) {
        return GridPoint(gx, gy);
      }
    }
    return null;
  }

  GridPoint? _globalToCell(Offset globalPos) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(globalPos);
    const pad = PrismBoardPainter.boardPadding;
    final cellSize = (box.size.width - pad * 2) / PrismEngine.gridSize;
    final gx = ((local.dx - pad) / cellSize).floor();
    final gy = ((local.dy - pad) / cellSize).floor();
    if (gx < 0 ||
        gy < 0 ||
        gx >= PrismEngine.gridSize ||
        gy >= PrismEngine.gridSize) {
      return null;
    }
    return GridPoint(gx, gy);
  }

  void _commitPlacement(int slotIndex, GridPoint anchor) {
    final outcome = slotIndex == _anvilSlotIndex
        ? _engine.placeForgedPiece(anchor.x, anchor.y)
        : _engine.placePiece(slotIndex, anchor.x, anchor.y);
    if (!outcome.placed) return;

    setState(() {
      _selectedSlot = null;
      _activePreview = null;
    });

    if (outcome.linesCleared > 0 || outcome.synthesizedCores.isNotEmpty) {
      _spawnClearFx(outcome);
    }

    if (outcome.objectiveCompleted) {
      _blitzTimer?.cancel();
      widget.audio.playCue(PrismSoundCue.stageClear);
    } else if (outcome.allClearBonus) {
      widget.audio.playCue(PrismSoundCue.allClear);
      _showBanner(
        PrismStrings.allClearBanner.resolve(_locale),
        const Color(0xFF34E870),
      );
    } else if (outcome.refractionBeams.isNotEmpty) {
      widget.audio.playCue(PrismSoundCue.prismBlast);
      _showBanner(
        PrismStrings.chainRefractionBanner(outcome.refractionBeams.length)
            .resolve(_locale),
        _palette.prismGold,
      );
    } else if (outcome.triggeredPrisms.isNotEmpty) {
      widget.audio.playCue(PrismSoundCue.prismBlast);
      _showBanner(
        PrismStrings.crossWaveBanner.resolve(_locale),
        _palette.prismGold,
      );
    } else if (outcome.linesCleared > 0) {
      widget.audio.playClearChord(
        streak: _engine.streak,
        lines: outcome.linesCleared,
        resonance: outcome.triggeredResonance,
      );
      if (outcome.triggeredResonance) {
        _showBanner(
          PrismStrings.resonanceBanner.resolve(_locale),
          _palette.resonanceColor,
        );
      } else if (outcome.linesCleared >= 2 || _engine.streak >= 2) {
        _showBanner(
          '+${outcome.pointsEarned}  ×${_engine.streak}',
          _palette.prismGold,
        );
      }
    } else if (outcome.synthesizedCores.isNotEmpty) {
      widget.audio.playCue(PrismSoundCue.prismBlast);
      _showBanner(
        PrismStrings.synthesisBanner.resolve(_locale),
        _palette.prismGold,
      );
    } else {
      widget.audio.playCue(PrismSoundCue.place);
    }

    if (outcome.brokenLockCount > 0) {
      widget.audio.playCue(PrismSoundCue.lockBreak);
    } else if (outcome.crackedFrostCount > 0) {
      widget.audio.playCue(PrismSoundCue.frostCrack);
    }

    if (outcome.forgeTempered) {
      widget.audio.playCue(PrismSoundCue.prismTempered);
      _showBanner(
        PrismStrings.temperedBanner.resolve(_locale),
        _palette.prismGold,
      );
    }

    if (outcome.gameOver) {
      _blitzTimer?.cancel();
      widget.audio.playCue(PrismSoundCue.fail);
    }

    _persistHighScores();
    setState(() {});
  }

  void _handleAnvilTap() {
    if (_engine.isGameOver || _engine.isVictory) return;
    // If a tray piece is currently selected, stash/swap it into the Prism Anvil!
    if (_selectedSlot != null &&
        _selectedSlot! >= 0 &&
        _engine.tray[_selectedSlot!] != null &&
        !_engine.forgeUsedThisTurn) {
      if (_engine.stashOrSwapWithForge(_selectedSlot!)) {
        widget.audio.playCue(PrismSoundCue.hold);
        setState(() {
          _selectedSlot = null;
          _activePreview = null;
        });
        return;
      }
    }
    // Otherwise toggle selecting the forged piece for direct board placement,
    // OR stash the first tray piece if Anvil is empty!
    if (_engine.forgedPiece != null) {
      widget.audio.playCue(PrismSoundCue.pickup);
      setState(() {
        _selectedSlot = _selectedSlot == _anvilSlotIndex
            ? null
            : _anvilSlotIndex;
        _activePreview = null;
      });
    } else if (!_engine.forgeUsedThisTurn) {
      final firstIdx = _engine.tray.indexWhere((p) => p != null);
      if (firstIdx >= 0 && _engine.stashOrSwapWithForge(firstIdx)) {
        widget.audio.playCue(PrismSoundCue.hold);
        setState(() {
          _selectedSlot = null;
          _activePreview = null;
        });
      }
    }
  }

  void _handleRotate() {
    var slot = _selectedSlot;
    if (slot == null || _pieceForSlot(slot) == null) {
      final idx = _engine.tray.indexWhere((p) => p != null);
      slot = idx >= 0
          ? idx
          : (_engine.forgedPiece != null ? _anvilSlotIndex : null);
    }
    if (slot == null) return;
    if (_engine.rotateTrayPiece(slot)) {
      widget.audio.playCue(PrismSoundCue.rotate);
      setState(() {
        _selectedSlot = slot;
        _activePreview = null;
      });
    }
  }

  void _handleNovaTap(GridPoint cell) {
    final outcome = _engine.executeQuantumNova(cell.x, cell.y);
    if (!outcome.placed) return;
    _spawnClearFx(outcome);
    _waves.add(ShockWave.ring(cell.x + 0.5, cell.y + 0.5, _palette.prismGold));
    widget.audio.playCue(PrismSoundCue.nova);
    _showBanner('NOVA +${outcome.pointsEarned}', _palette.prismGold);
    if (outcome.objectiveCompleted) {
      widget.audio.playCue(PrismSoundCue.stageClear);
    }
    _persistHighScores();
    setState(() {
      _novaMode = false;
      _novaHover = null;
    });
  }

  void _cycleTheme() {
    const values = PrismThemeId.values;
    final next = values[(values.indexOf(_save.themeId) + 1) % values.length];
    setState(() => _save = _save.copyWith(themeId: next));
    unawaited(widget.storage.save(_save));
  }

  void _toggleLocale() {
    final next = _save.locale == AppLocale.tr ? AppLocale.en : AppLocale.tr;
    setState(() => _save = _save.copyWith(locale: next));
    unawaited(widget.storage.save(_save));
  }

  void _toggleSound() {
    final next = !_save.soundEnabled;
    widget.audio.soundEnabled = next;
    if (next) widget.audio.playCue(PrismSoundCue.pickup);
    setState(() => _save = _save.copyWith(soundEnabled: next));
    unawaited(widget.storage.save(_save));
  }

  void _openStagePicker() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => StagePickerSheet(
          palette: _palette,
          locale: _locale,
          currentStage: _engine.questStageNumber,
          starsByStage: _save.questStarsByStage,
          onSelectStage: (stage) => _startMode(GameMode.quest, stage: stage),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette;
    final draggingPiece = _pieceForSlot(_draggingSlot);

    return Theme(
      data: p.toThemeData(),
      child: Scaffold(
        backgroundColor: p.background,
        body: Stack(
          children: <Widget>[
            // Radiant animated "cıvıl cıvıl" gradient + ambient bubbles/sparkles/petals!
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ticker,
                builder: (context, _) => CustomPaint(
                  painter: AmbientBackdropPainter(
                    palette: p,
                    phase: _save.reducedMotion ? 0.25 : _ticker.value,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildHeader(p),
                    const SizedBox(height: 8),
                    _buildModeStrip(p),
                    const SizedBox(height: 8),
                    _buildScoreHud(p),
                    if (_engine.mode != GameMode.endless) ...<Widget>[
                      const SizedBox(height: 6),
                      _buildContextBar(p),
                    ],
                    const SizedBox(height: 8),
                    _buildEnergyBar(p),
                    const SizedBox(height: 8),
                    Expanded(child: _buildBoardArea(p)),
                    const SizedBox(height: 10),
                    _buildTrayWithAnvil(p),
                    const SizedBox(height: 8),
                    _buildFooter(p),
                  ],
                ),
              ),
            ),
            if (draggingPiece != null && _dragGlobalPos != null)
              _buildFloatingDragPiece(p, draggingPiece, _dragGlobalPos!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PrismPalette p) {
    return Row(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF2B1463), Color(0xFFDF248A)],
            ),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.diamond_rounded,
            color: Color(0xFFA5FAFF),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                PrismStrings.appTitle.resolve(_locale),
                style: TextStyle(
                  color: p.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                PrismStrings.appSubtitle.resolve(_locale),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.mutedInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _headerChip(
          key: const ValueKey<String>('theme_button'),
          p: p,
          label: p.name.resolve(_locale),
          onTap: _cycleTheme,
        ),
        const SizedBox(width: 6),
        _headerChip(
          key: const ValueKey<String>('sound_button'),
          p: p,
          icon: _save.soundEnabled
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          onTap: _toggleSound,
        ),
        const SizedBox(width: 6),
        _headerChip(
          key: const ValueKey<String>('lang_button'),
          p: p,
          label: _locale.name.toUpperCase(),
          onTap: _toggleLocale,
        ),
      ],
    );
  }

  Widget _headerChip({
    Key? key,
    required PrismPalette p,
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 34,
        padding: EdgeInsets.symmetric(horizontal: icon != null ? 9 : 10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: p.ink.withValues(alpha: 0.14)),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 17, color: p.ink)
            : Text(
                label ?? '',
                style: TextStyle(
                  color: p.ink,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _buildModeStrip(PrismPalette p) {
    return Row(
      children: <Widget>[
        for (final m in GameMode.values) ...<Widget>[
          Expanded(
            child: InkWell(
              key: ValueKey<String>('mode_${m.name}'),
              borderRadius: BorderRadius.circular(11),
              onTap: () => _startMode(m),
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: _engine.mode == m ? p.accent : p.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: _engine.mode == m
                        ? p.accent
                        : p.ink.withValues(alpha: 0.14),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  PrismStrings.modeLabel(m).resolve(_locale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _engine.mode == m ? p.accentInk : p.ink,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          if (m != GameMode.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildScoreHud(PrismPalette p) {
    final String rightLabel;
    final String rightValue;
    switch (_engine.mode) {
      case GameMode.endless:
        rightLabel = PrismStrings.best.resolve(_locale);
        rightValue = '${_save.bestEndlessScore}';
      case GameMode.quest:
        rightLabel = PrismStrings.stage.resolve(_locale);
        rightValue = '#${_engine.questStageNumber}/24';
      case GameMode.daily:
        rightLabel = PrismStrings.modeLabel(GameMode.daily).resolve(_locale);
        rightValue = _save.solvedDailyDates.contains(_engine.dailyDateKey)
            ? '✓'
            : '${_save.solvedDailyDates.length}';
      case GameMode.blitz:
        rightLabel = PrismStrings.time.resolve(_locale);
        rightValue = '${_engine.blitzSecondsLeft.ceil()}s';
    }

    return Row(
      children: <Widget>[
        _statCard(p, PrismStrings.score.resolve(_locale), '${_engine.score}'),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: p.ink.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      PrismStrings.combo.resolve(_locale),
                      style: TextStyle(color: p.mutedInk, fontSize: 11),
                    ),
                    Row(
                      children: <Widget>[
                        for (var i = 0; i < 3; i++)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(left: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < _engine.streakTurnsLeft
                                  ? p.accent
                                  : p.ink.withValues(alpha: 0.18),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '×${math.max(1, _engine.streak)}',
                  style: TextStyle(
                    color: _engine.streak >= 2 ? p.accent : p.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _statCard(p, rightLabel, rightValue),
      ],
    );
  }

  Widget _statCard(PrismPalette p, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: p.ink.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: TextStyle(color: p.mutedInk, fontSize: 11)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: p.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextBar(PrismPalette p) {
    final String pillText;
    final String descText;
    final double progress;
    final String metric;

    if (_engine.mode == GameMode.quest) {
      pillText =
          '${PrismStrings.stage.resolve(_locale)} ${_engine.questStageNumber} ▾';
      descText = PrismStrings.questObjectiveSummary(
        remainingCores: math.max(
          0,
          _engine.targetCores - _engine.collectedCores,
        ),
        remainingFrost: math.max(
          0,
          _engine.targetFrost - _engine.collectedFrost,
        ),
        remainingLocks: math.max(
          0,
          _engine.targetLocks - _engine.collectedLocks,
        ),
      ).resolve(_locale);
      progress = _engine.totalTargets == 0
          ? 1.0
          : _engine.totalCollected / _engine.totalTargets;
      metric = '${_engine.totalCollected}/${_engine.totalTargets}';
    } else if (_engine.mode == GameMode.daily) {
      pillText = _engine.dailyDateKey;
      descText = PrismStrings.questObjectiveSummary(
        remainingCores: math.max(
          0,
          _engine.targetCores - _engine.collectedCores,
        ),
        remainingFrost: math.max(
          0,
          _engine.targetFrost - _engine.collectedFrost,
        ),
        remainingLocks: math.max(
          0,
          _engine.targetLocks - _engine.collectedLocks,
        ),
      ).resolve(_locale);
      progress = _engine.totalTargets == 0
          ? 1.0
          : _engine.totalCollected / _engine.totalTargets;
      metric = '${_engine.totalCollected}/${_engine.totalTargets}';
    } else {
      pillText =
          '${PrismStrings.best.resolve(_locale)}: ${_save.bestBlitzScore}';
      descText = PrismStrings.blitzHint.resolve(_locale);
      progress = (_engine.blitzSecondsLeft / 90.0).clamp(0.0, 1.0).toDouble();
      metric = '${_engine.blitzSecondsLeft.ceil()}s';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: p.ink.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            key: const ValueKey<String>('context_pill_button'),
            borderRadius: BorderRadius.circular(8),
            onTap: _engine.mode == GameMode.quest ? _openStagePicker : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pillText,
                style: TextStyle(
                  color: p.accentInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              descText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.ink,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 54,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: p.ink.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(p.accent),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            metric,
            style: TextStyle(
              color: p.ink,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyBar(PrismPalette p) {
    final hasAnyPiece =
        _engine.tray.any((t) => t != null) || _engine.forgedPiece != null;
    final canRotate =
        _engine.energy >= PrismEngine.rotateEnergyCost &&
        hasAnyPiece &&
        !_engine.isGameOver &&
        !_engine.isVictory;
    final canNova =
        _engine.energy >= PrismEngine.novaEnergyCost &&
        !_engine.isGameOver &&
        !_engine.isVictory;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: p.ink.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      PrismStrings.energy.resolve(_locale),
                      style: TextStyle(color: p.mutedInk, fontSize: 11),
                    ),
                    Text(
                      '${_engine.energy}%',
                      style: TextStyle(
                        color: p.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: (_engine.energy / 100.0).clamp(0.0, 1.0).toDouble(),
                    minHeight: 7,
                    backgroundColor: p.ink.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      canNova ? p.prismGold : p.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _powerButton(
            key: const ValueKey<String>('rotate_button'),
            p: p,
            icon: Icons.rotate_right_rounded,
            label: '${PrismStrings.rotate.resolve(_locale)} 35%',
            enabled: canRotate,
            highlight: false,
            onTap: _handleRotate,
          ),
          const SizedBox(width: 6),
          _powerButton(
            key: const ValueKey<String>('nova_button'),
            p: p,
            icon: Icons.auto_awesome_rounded,
            label: PrismStrings.nova.resolve(_locale),
            enabled: canNova,
            highlight: _novaMode || canNova,
            onTap: () => setState(() {
              _novaMode = !_novaMode;
              _selectedSlot = null;
              _activePreview = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _powerButton({
    Key? key,
    required PrismPalette p,
    required IconData icon,
    required String label,
    required bool enabled,
    required bool highlight,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.42,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: highlight ? p.accent : p.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlight ? p.accent : p.ink.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 15, color: highlight ? p.accentInk : p.ink),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: highlight ? p.accentInk : p.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardArea(PrismPalette p) {
    final hoverPiece = _pieceForSlot(_draggingSlot ?? _selectedSlot);

    return Column(
      children: <Widget>[
        if (_novaMode)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.accent, width: 1.6),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    PrismStrings.novaBanner.resolve(_locale),
                    style: TextStyle(
                      color: p.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _novaMode = false),
                  child: Text(
                    PrismStrings.cancel.resolve(_locale),
                    style: TextStyle(
                      color: p.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    key: _boardKey,
                    onTapUp: (details) {
                      if (_engine.isGameOver || _engine.isVictory) return;
                      if (_novaMode) {
                        final cell = _globalToCell(details.globalPosition);
                        if (cell != null) _handleNovaTap(cell);
                        return;
                      }
                      final sel = _selectedSlot;
                      final piece = _pieceForSlot(sel);
                      if (sel != null && piece != null) {
                        final anchor = _globalToBoardAnchor(
                          details.globalPosition,
                          piece,
                          applyTouchLift: false,
                        );
                        if (anchor != null) {
                          _commitPlacement(sel, anchor);
                        }
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _ticker,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: PrismBoardPainter(
                            grid: _engine.grid,
                            palette: p,
                            phase: _save.reducedMotion ? 0.25 : _ticker.value,
                            particles: _particles,
                            waves: _waves,
                            hoverPiece: hoverPiece,
                            preview: _activePreview,
                            novaMode: _novaMode,
                            novaHover: _novaHover,
                          ),
                        );
                      },
                    ),
                  ),
                  if (_kineticBanner != null)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: p.boardBackground.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _kineticColor,
                                width: 1.8,
                              ),
                            ),
                            child: Text(
                              _kineticBanner!,
                              style: TextStyle(
                                color: _kineticColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_engine.isGameOver || _engine.isVictory)
                    _buildResultOverlay(p),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultOverlay(PrismPalette p) {
    final isWin = _engine.isVictory;
    final String title;
    final String desc;
    final String actionLabel;

    if (isWin && _engine.mode == GameMode.daily) {
      title = PrismStrings.dailyClearTitle.resolve(_locale);
      desc = PrismStrings.dailyClearDesc.resolve(_locale);
      actionLabel = PrismStrings.playAgain.resolve(_locale);
    } else if (isWin) {
      title = PrismStrings.stageClearTitle.resolve(_locale);
      desc = PrismStrings.stageClearDesc.resolve(_locale);
      actionLabel = _engine.questStageNumber < 24
          ? PrismStrings.nextStage.resolve(_locale)
          : PrismStrings.playAgain.resolve(_locale);
    } else if (_engine.mode == GameMode.blitz &&
        _engine.blitzSecondsLeft <= 0) {
      title = PrismStrings.timeUpTitle.resolve(_locale);
      desc = PrismStrings.timeUpDesc.resolve(_locale);
      actionLabel = PrismStrings.playAgain.resolve(_locale);
    } else {
      title = PrismStrings.gameOverTitle.resolve(_locale);
      desc = PrismStrings.gameOverDesc.resolve(_locale);
      actionLabel = PrismStrings.playAgain.resolve(_locale);
    }

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: p.boardBackground.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p.accent, width: 1.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isWin ? Icons.auto_awesome_rounded : Icons.refresh_rounded,
                  color: p.accent,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.mutedInk, fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const ValueKey<String>('overlay_action_button'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.accent,
                      foregroundColor: p.accentInk,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (isWin &&
                          _engine.mode == GameMode.quest &&
                          _engine.questStageNumber < 24) {
                        _startMode(
                          GameMode.quest,
                          stage: _engine.questStageNumber + 1,
                        );
                      } else {
                        _startMode(_engine.mode);
                      }
                    },
                    child: Text(
                      actionLabel,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 3 Tray Slots + Golden Divider + 4th Golden Prism Anvil Slot (0px extra height!).
  Widget _buildTrayWithAnvil(PrismPalette p) {
    return SizedBox(
      height: 92,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < 3; i++) ...<Widget>[
            Expanded(flex: 10, child: _buildTraySlot(p, i)),
            const SizedBox(width: 6),
          ],
          Container(
            width: 1.5,
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: p.ink.withValues(alpha: 0.16),
          ),
          const SizedBox(width: 4),
          Expanded(flex: 11, child: _buildAnvilSlot(p)),
        ],
      ),
    );
  }

  Widget _buildTraySlot(PrismPalette p, int index) {
    final piece = _engine.tray[index];
    final selected = _selectedSlot == index && piece != null;
    final isDragging = _draggingSlot == index;
    final fits = piece != null && _engine.canPlaceAnywhere(piece);

    return Listener(
      onPointerDown: (event) {
        if (piece == null || _engine.isGameOver || _engine.isVictory) return;
        widget.audio.playCue(PrismSoundCue.pickup);
        setState(() {
          _novaMode = false;
          _draggingSlot = index;
          _dragGlobalPos = event.position;
          _activePreview = null;
        });
      },
      onPointerMove: (event) {
        if (_draggingSlot != index || piece == null) return;
        final anchor = _globalToBoardAnchor(
          event.position,
          piece,
          applyTouchLift: true,
        );
        setState(() {
          _dragGlobalPos = event.position;
          _activePreview = anchor != null
              ? _engine.previewPlacement(piece, anchor.x, anchor.y)
              : null;
        });
      },
      onPointerUp: (_) {
        if (_draggingSlot != index || piece == null) return;
        final preview = _activePreview;
        setState(() {
          _draggingSlot = null;
          _dragGlobalPos = null;
          _activePreview = null;
        });
        if (preview != null) {
          _commitPlacement(index, preview.anchor);
        } else {
          setState(() {
            _selectedSlot = _selectedSlot == index ? null : index;
          });
        }
      },
      onPointerCancel: (_) {
        if (_draggingSlot != index) return;
        setState(() {
          _draggingSlot = null;
          _dragGlobalPos = null;
          _activePreview = null;
        });
      },
      child: AnimatedContainer(
        key: ValueKey<String>('tray_slot_$index'),
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? p.accent
                : (piece != null && !fits)
                ? const Color(0xCCF43F5E)
                : p.ink.withValues(alpha: 0.14),
            width: selected ? 2.4 : 1.2,
          ),
        ),
        child: piece == null
            ? const SizedBox.shrink()
            : Opacity(
                opacity: isDragging ? 0.25 : 1.0,
                child: AnimatedBuilder(
                  animation: _ticker,
                  builder: (context, _) => CustomPaint(
                    painter: PieceMiniPainter(
                      piece: piece,
                      palette: p,
                      phase: _save.reducedMotion ? 0.25 : _ticker.value,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  /// Dedicated Golden Prism Anvil (Prizma Örsü): stash/swap 1x per turn,
  /// 3 placements temper the held piece into 🌈 Wildcard + ★ Prism Core!
  Widget _buildAnvilSlot(PrismPalette p) {
    final piece = _engine.forgedPiece;
    final selected = _selectedSlot == _anvilSlotIndex && piece != null;
    final isDragging = _draggingSlot == _anvilSlotIndex;
    final tempered = _engine.isForgeTempered;

    return Listener(
      onPointerDown: (event) {
        if (_engine.isGameOver || _engine.isVictory) return;
        if (piece == null ||
            (_selectedSlot != null &&
                _selectedSlot! >= 0 &&
                !_engine.forgeUsedThisTurn)) {
          _handleAnvilTap();
          return;
        }
        widget.audio.playCue(PrismSoundCue.pickup);
        setState(() {
          _novaMode = false;
          _draggingSlot = _anvilSlotIndex;
          _dragGlobalPos = event.position;
          _activePreview = null;
        });
      },
      onPointerMove: (event) {
        if (_draggingSlot != _anvilSlotIndex || piece == null) return;
        final anchor = _globalToBoardAnchor(
          event.position,
          piece,
          applyTouchLift: true,
        );
        setState(() {
          _dragGlobalPos = event.position;
          _activePreview = anchor != null
              ? _engine.previewPlacement(piece, anchor.x, anchor.y)
              : null;
        });
      },
      onPointerUp: (_) {
        if (_draggingSlot != _anvilSlotIndex || piece == null) return;
        final preview = _activePreview;
        setState(() {
          _draggingSlot = null;
          _dragGlobalPos = null;
          _activePreview = null;
        });
        if (preview != null) {
          _commitPlacement(_anvilSlotIndex, preview.anchor);
        } else {
          setState(() {
            _selectedSlot = _selectedSlot == _anvilSlotIndex
                ? null
                : _anvilSlotIndex;
          });
        }
      },
      onPointerCancel: (_) {
        if (_draggingSlot != _anvilSlotIndex) return;
        setState(() {
          _draggingSlot = null;
          _dragGlobalPos = null;
          _activePreview = null;
        });
      },
      child: AnimatedContainer(
        key: const ValueKey<String>('anvil_slot'),
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        decoration: BoxDecoration(
          color: tempered
              ? p.prismGold.withValues(alpha: 0.25)
              : p.surfaceElevated,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected || tempered
                ? p.prismGold
                : p.prismGold.withValues(alpha: 0.65),
            width: selected || tempered ? 2.4 : 1.6,
          ),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  tempered
                      ? PrismStrings.anvilReady.resolve(_locale)
                      : PrismStrings.anvilLabel.resolve(_locale),
                  style: TextStyle(
                    color: p.ink,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 5.5,
                    height: 5.5,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _engine.forgeCharge
                          ? p.accent
                          : p.ink.withValues(alpha: 0.22),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: piece == null
                  ? Center(
                      child: Icon(
                        Icons.auto_fix_high_rounded,
                        size: 22,
                        color: p.mutedInk.withValues(alpha: 0.65),
                      ),
                    )
                  : Opacity(
                      opacity: isDragging ? 0.25 : 1.0,
                      child: AnimatedBuilder(
                        animation: _ticker,
                        builder: (context, _) => CustomPaint(
                          size: Size.infinite,
                          painter: PieceMiniPainter(
                            piece: piece,
                            palette: p,
                            phase: _save.reducedMotion ? 0.25 : _ticker.value,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingDragPiece(
    PrismPalette p,
    PrismPiece piece,
    Offset globalPos,
  ) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    final cellSize = box != null
        ? (box.size.width - PrismBoardPainter.boardPadding * 2) /
              PrismEngine.gridSize
        : 38.0;
    final w = piece.cols * cellSize;
    final h = piece.rows * cellSize;
    final lift = cellSize * 1.4;

    final stackBox = context.findRenderObject() as RenderBox?;
    final local = stackBox != null
        ? stackBox.globalToLocal(globalPos)
        : globalPos;

    return Positioned(
      left: local.dx - w / 2,
      top: local.dy - lift - h / 2,
      width: w,
      height: h,
      child: IgnorePointer(
        child: CustomPaint(
          painter: PieceMiniPainter(
            piece: piece,
            palette: p,
            cellSizeOverride: cellSize,
            phase: _save.reducedMotion ? 0.25 : _ticker.value,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(PrismPalette p) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            PrismStrings.legendShort.resolve(_locale),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: p.ink.withValues(alpha: 0.78),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          key: const ValueKey<String>('restart_button'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => _startMode(_engine.mode),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.ink.withValues(alpha: 0.14)),
            ),
            child: Text(
              PrismStrings.restart.resolve(_locale),
              style: TextStyle(
                color: p.ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
