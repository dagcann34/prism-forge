/// Main one-handed portrait gameplay screen for PRISM FORGE (Prizma Döküm).
///
/// Features:
/// - 12 dazzling glass/crystal atmospheres that auto-evolve after every Quest stage
///   and every 1,500 points in Endless mode (with 650ms smooth gradient & ambient cross-fade)
/// - Unique bilingual poetic stage titles & lore subtitles showcased via a non-blocking
///   crystalline StageIntroBanner with diagonal glass shimmer sweep
/// - 60fps tactile animations: damped-spring block pop, diagonal gem sheen,
///   depth-staggered ★->★ optical laser beams, double concentric shockwaves,
///   faceted crystal shards, rolling score counter, micro screen-shake,
///   pulsing Anvil/Nova/Fever glow, and staggered-star Stage Clear modal with
///   Next-Stage Theme Preview CTA!
library;

import 'dart:async';
import 'dart:math' as math;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../audio/prism_audio.dart';
import '../audio/prism_synth.dart';
import '../engine/models.dart';
import '../engine/prism_engine.dart';
import '../engine/quest_stages.dart';
import '../l10n/prism_strings.dart';
import '../services/achievements_service.dart';
import '../services/ad_service.dart';
import '../storage/prism_storage.dart';
import '../theme/prism_themes.dart';
import 'board/prism_board_painter.dart';
import 'widgets/stage_intro_banner.dart';
import 'widgets/stage_picker_sheet.dart';
import 'widgets/trophy_hub_sheet.dart';

class PrismGameScreen extends StatefulWidget {
  const PrismGameScreen({
    super.key,
    required this.storage,
    required this.audio,
    required this.adService,
    required this.gamesService,
    this.initialMode = GameMode.quest,
  });

  final PrismStorage storage;
  final PrismAudio audio;
  final AdService adService;
  final PlatformGamesService gamesService;
  final GameMode initialMode;

  @override
  State<PrismGameScreen> createState() => _PrismGameScreenState();
}

class _PrismGameScreenState extends State<PrismGameScreen>
    with TickerProviderStateMixin {
  /// Sentinel slot index representing the Golden Prism Anvil (Forge Slot).
  static const int _anvilSlotIndex = -1;
  static const int _endlessEvolutionStep = 1500;

  final PrismEngine _engine = PrismEngine();
  final GlobalKey _boardKey = GlobalKey();
  final math.Random _fxRng = math.Random();

  late final AnimationController _ticker;
  late final AnimationController _themeCrossFade;
  late final AnimationController _stageIntroCtrl;
  late final AnimationController _victoryStarsCtrl;
  Timer? _blitzTimer;
  Timer? _bannerTimer;

  PrismSaveData _save = const PrismSaveData();
  PrismPalette? _previousPalette;
  StageIntroPayload? _stageIntro;
  int _introSequence = 0;

  /// Selected slot: 0..2 for tray, -1 for Prism Anvil, null for none.
  int? _selectedSlot;
  int? _draggingSlot;
  Offset? _dragGlobalPos;
  PlacementPreview? _activePreview;
  bool _novaMode = false;
  GridPoint? _novaHover;
  String? _kineticBanner;
  int _kineticSeq = 0;
  Color _kineticColor = const Color(0xFFFFE14D);

  final List<ShardParticle> _particles = <ShardParticle>[];
  final List<ShockWave> _waves = <ShockWave>[];
  final Map<GridPoint, double> _cellPopProgress = <GridPoint, double>{};
  int _displayedScore = 0;
  int _endlessRealmTier = 0;
  double _boardShake = 0.0;
  DateTime _lastFrame = DateTime.now();

  PrismPalette get _palette => _engine.mode == GameMode.quest
      ? PrismThemes.vibrantForStage(_save.themeId, _engine.questStageNumber)
      : PrismThemes.vibrantForStage(_save.themeId, _endlessRealmTier + 1);
  AppLocale get _locale => _save.locale;

  PrismPiece? _pieceForSlot(int? slot) {
    if (slot == null) return null;
    if (slot == _anvilSlotIndex) return _engine.forgedPiece;
    if (slot >= 0 && slot < 3) return _engine.tray[slot];
    return null;
  }

  static int _fnvHash(String input) {
    var h = 2166136261;
    for (var i = 0; i < input.length; i++) {
      h ^= input.codeUnitAt(i);
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h;
  }

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(_onAnimationTick);
    _themeCrossFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: 1.0,
    );
    _stageIntroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1950),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _stageIntro = null);
        }
      });
    _victoryStarsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
      value: 1.0,
    );

    _engine.startGame(newMode: widget.initialMode, stageNumber: 1);
    unawaited(widget.adService.initialize());
    unawaited(_loadSave());
  }

  Future<void> _loadSave() async {
    final loaded = await widget.storage.load();
    if (!mounted) return;
    final startStage = loaded.currentQuestStage;
    final initialTheme =
        (widget.initialMode == GameMode.quest && loaded.autoStageTheme)
        ? QuestStageCatalog.byNumber(startStage).themeId
        : loaded.themeId;

    setState(() {
      _save = loaded.copyWith(themeId: initialTheme);
      widget.audio.soundEnabled = loaded.soundEnabled;
      widget.audio.hapticsEnabled = loaded.hapticsEnabled;
      widget.adService.policy.adsRemoved = loaded.adsRemoved;
      _engine.startGame(
        newMode: widget.initialMode,
        stageNumber: startStage,
      );
      _displayedScore = _engine.score;
      _endlessRealmTier = 0;
      if (!loaded.reducedMotion) {
        _ticker.repeat();
      }
    });
    if (widget.initialMode == GameMode.quest && !loaded.reducedMotion) {
      _triggerStageIntroForCurrentQuest();
    }
    _syncBlitzTimer();
  }

  void _transitionToTheme(
    PrismThemeId nextTheme, {
    bool persist = true,
    bool forceCrossFade = false,
  }) {
    if (_save.themeId == nextTheme && !forceCrossFade) return;
    _previousPalette = _palette;
    _save = _save.copyWith(themeId: nextTheme);
    if (_save.reducedMotion) {
      _themeCrossFade.value = 1.0;
    } else {
      _themeCrossFade.forward(from: 0.0);
    }
    if (persist) {
      unawaited(widget.storage.save(_save));
    }
  }

  void _triggerStageIntroForCurrentQuest() {
    if (_save.reducedMotion) return;
    final spec = QuestStageCatalog.byNumber(_engine.questStageNumber);
    final stagePalette = PrismThemes.vibrantForStage(
      _save.autoStageTheme ? spec.themeId : _save.themeId,
      spec.stageNumber,
    );
    const romans = <String>['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    final chapterRoman = romans[(spec.chapterNumber - 1).clamp(0, 9)];
    final bossPrefix = spec.isBossStage ? '👑 BOSS • ' : '';
    final eyebrow = _locale == AppLocale.tr
        ? '${bossPrefix}BÖLÜM ${spec.stageNumber}/1000 • DİYAR $chapterRoman'
        : '${bossPrefix}STAGE ${spec.stageNumber}/1000 • REALM $chapterRoman';
    _stageIntro = StageIntroPayload(
      eyebrow: eyebrow,
      title: spec.title.resolve(_locale),
      subtitle: spec.subtitle.resolve(_locale),
      palette: stagePalette,
      sequenceId: ++_introSequence,
    );
    _stageIntroCtrl.forward(from: 0.0);
  }

  void _triggerRealmEvolutionIntro(PrismPalette newPalette, int tier) {
    if (_save.reducedMotion) return;
    _stageIntro = StageIntroPayload(
      eyebrow:
          '${PrismStrings.realmEvolutionTag.resolve(_locale)} • ${tier * _endlessEvolutionStep}+',
      title: newPalette.fullName.resolve(_locale),
      subtitle: _locale == AppLocale.tr
          ? 'Sonsuz akışta yeni kristal atmosfere geçildi!'
          : 'You ascended into a new crystalline atmosphere!',
      palette: newPalette,
      sequenceId: ++_introSequence,
    );
    _stageIntroCtrl.forward(from: 0.0);
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

    var needsScoreRebuild = false;
    if (_displayedScore != _engine.score) {
      final diff = _engine.score - _displayedScore;
      if (diff.abs() <= 4 || _save.reducedMotion) {
        _displayedScore = _engine.score;
      } else {
        _displayedScore += diff > 0
            ? math.max(1, (diff * 0.24).ceil())
            : math.min(-1, (diff * 0.24).floor());
      }
      needsScoreRebuild = true;
    }

    if (_cellPopProgress.isNotEmpty) {
      final done = <GridPoint>[];
      _cellPopProgress.forEach((pt, t) {
        final nextT = t + dt * 3.1;
        if (nextT >= 1.0) {
          done.add(pt);
        } else {
          _cellPopProgress[pt] = nextT;
        }
      });
      for (final pt in done) {
        _cellPopProgress.remove(pt);
      }
    }

    if (_boardShake > 0.05) {
      _boardShake *= math.pow(0.03, dt).toDouble();
      if (_boardShake < 0.05) _boardShake = 0.0;
    }

    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life -= dt * 1.55;
      if (p.life <= 0) {
        _particles.removeAt(i);
        continue;
      }
      p.gx += p.vx * dt;
      p.gy += p.vy * dt;
      p.vy += 8.2 * dt;
      p.rotation += p.vRot;
    }

    for (var i = _waves.length - 1; i >= 0; i--) {
      final w = _waves[i];
      if (w.delay > 0.0) {
        w.delay -= dt;
        continue;
      }
      w.life -= dt * 2.0;
      if (w.life <= 0) _waves.removeAt(i);
    }

    if (needsScoreRebuild && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _blitzTimer?.cancel();
    _bannerTimer?.cancel();
    _ticker.dispose();
    _themeCrossFade.dispose();
    _stageIntroCtrl.dispose();
    _victoryStarsCtrl.dispose();
    widget.adService.dispose();
    super.dispose();
  }

  void _showBanner(String text, Color color) {
    _bannerTimer?.cancel();
    setState(() {
      _kineticBanner = text;
      _kineticColor = color;
      _kineticSeq++;
    });
    _bannerTimer = Timer(const Duration(milliseconds: 1450), () {
      if (mounted) setState(() => _kineticBanner = null);
    });
  }

  void _spawnVictoryConfetti() {
    if (_save.reducedMotion) return;
    for (var i = 0; i < 30; i++) {
      final ang = _fxRng.nextDouble() * math.pi * 2;
      final spd = 1.8 + _fxRng.nextDouble() * 4.8;
      final col = _palette
          .gemFor(i % PrismEngine.paletteColorCount)
          .main;
      _particles.add(
        ShardParticle(
          gx: 4.0 + (_fxRng.nextDouble() - 0.5) * 3.0,
          gy: 3.6 + (_fxRng.nextDouble() - 0.5) * 2.0,
          vx: math.cos(ang) * spd,
          vy: math.sin(ang) * spd - 2.6,
          size: 0.16 + _fxRng.nextDouble() * 0.16,
          rotation: _fxRng.nextDouble() * math.pi,
          vRot: (_fxRng.nextDouble() - 0.5) * 0.34,
          color: i % 3 == 0 ? _palette.prismGold : col,
          isStar: i.isEven,
        ),
      );
    }
  }

  void _spawnClearFx(MoveOutcome outcome) {
    if (_save.reducedMotion) return;
    if (outcome.linesCleared >= 2 ||
        outcome.triggeredPrisms.isNotEmpty ||
        outcome.refractionBeams.isNotEmpty) {
      _boardShake = math.min(
        7.5,
        2.5 +
            outcome.linesCleared * 1.4 +
            outcome.refractionBeams.length * 1.6 +
            outcome.triggeredPrisms.length * 1.2,
      );
    }
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
      final hopDelay = math.max(0, beam.depth - 1) * 0.08;
      _waves.add(
        ShockWave.beam(
          beam.from.x + 0.5,
          beam.from.y + 0.5,
          beam.to.x + 0.5,
          beam.to.y + 0.5,
          _palette.prismGold,
          delay: hopDelay,
        ),
      );
      _waves.add(
        ShockWave.ring(
          beam.to.x + 0.5,
          beam.to.y + 0.5,
          _palette.resonanceColor,
          delay: hopDelay + 0.06,
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
    final targetStage = stage ?? _save.currentQuestStage;
    final oldPalette = _palette;
    final oldStage = _engine.questStageNumber;
    widget.adService.policy.resetRunCaps();
    setState(() {
      _selectedSlot = null;
      _draggingSlot = null;
      _activePreview = null;
      _novaMode = false;
      _novaHover = null;
      _particles.clear();
      _waves.clear();
      _cellPopProgress.clear();
      _boardShake = 0.0;
      _engine.startGame(
        newMode: mode,
        stageNumber: targetStage,
      );
      _displayedScore = _engine.score;
      _endlessRealmTier = 0;

      if (stage != null) {
        _save = _save.copyWith(currentQuestStage: stage);
      }

      // Auto-evolve vibrant background on EVERY stage (Quest) or per date (Daily)!
      if (_save.autoStageTheme) {
        if (mode == GameMode.quest) {
          final stageTheme = QuestStageCatalog.byNumber(
            _engine.questStageNumber,
          ).themeId;
          _previousPalette = oldPalette;
          _transitionToTheme(
            stageTheme,
            persist: false,
            forceCrossFade: _engine.questStageNumber != oldStage,
          );
        } else if (mode == GameMode.daily) {
          final idx =
              _fnvHash(_engine.dailyDateKey) % PrismThemeId.values.length;
          _transitionToTheme(PrismThemeId.values[idx], persist: false);
        }
      }
      unawaited(widget.storage.save(_save));

      if (mode == GameMode.quest) {
        _triggerStageIntroForCurrentQuest();
      } else {
        _stageIntro = null;
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

  void _checkEndlessRealmEvolution() {
    if (_engine.mode != GameMode.endless || !_save.autoStageTheme) return;
    final newTier = _engine.score ~/ _endlessEvolutionStep;
    if (newTier <= _endlessRealmTier) return;
    _endlessRealmTier = newTier;
    const values = PrismThemeId.values;
    final nextTheme =
        values[(values.indexOf(_save.themeId) + 1) % values.length];
    _transitionToTheme(nextTheme);
    widget.audio.playCue(PrismSoundCue.prismTempered);
    _triggerRealmEvolutionIntro(PrismThemes.of(nextTheme), newTier);
  }

  void _commitPlacement(int slotIndex, GridPoint anchor) {
    final placedPiece = _pieceForSlot(slotIndex);
    final outcome = slotIndex == _anvilSlotIndex
        ? _engine.placeForgedPiece(anchor.x, anchor.y)
        : _engine.placePiece(slotIndex, anchor.x, anchor.y);
    if (!outcome.placed) return;

    if (!_save.reducedMotion && placedPiece != null) {
      for (final c in placedPiece.cells) {
        final pt = GridPoint(anchor.x + c.x, anchor.y + c.y);
        if (_engine.grid[pt.y][pt.x] != null) {
          _cellPopProgress[pt] = 0.0;
        }
      }
    }
    if (_save.reducedMotion) {
      _displayedScore = _engine.score;
    }

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
      _spawnVictoryConfetti();
      if (_save.reducedMotion) {
        _victoryStarsCtrl.value = 1.0;
      } else {
        _victoryStarsCtrl.forward(from: 0.0);
      }
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

    if (outcome.enteredFever) {
      widget.audio.playCue(PrismSoundCue.feverStart);
      _showBanner(
        _locale == AppLocale.tr
            ? '🔥 PRİZMA COŞKUSU ×2!'
            : '🔥 PRISM FEVER ×2!',
        _palette.prismGold,
      );
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

    _checkEndlessRealmEvolution();
    _recordOutcomeStatsAndTrophies(outcome);
    _persistHighScores();
    setState(() {});
  }

  void _recordOutcomeStatsAndTrophies(MoveOutcome outcome) {
    final prev = _save.stats;
    final nextStats = prev.copyWith(
      totalLinesCleared: prev.totalLinesCleared + outcome.linesCleared,
      totalResonances:
          prev.totalResonances + (outcome.triggeredResonance ? 1 : 0),
      totalRefractionChains:
          prev.totalRefractionChains + outcome.refractionBeams.length,
      totalSynthesizedCores:
          prev.totalSynthesizedCores + outcome.synthesizedCores.length,
      totalTemperedWildcards:
          prev.totalTemperedWildcards + (outcome.forgeTempered ? 1 : 0),
      totalFrostCracked: prev.totalFrostCracked + outcome.crackedFrostCount,
      totalLocksBroken: prev.totalLocksBroken + outcome.brokenLockCount,
      totalAllClears: prev.totalAllClears + (outcome.allClearBonus ? 1 : 0),
      maxStreakReached: math.max(prev.maxStreakReached, _engine.streak),
      feverCount: prev.feverCount + (outcome.enteredFever ? 1 : 0),
    );
    _save = _save.copyWith(stats: nextStats);

    final newlyUnlocked = AchievementCatalog.evaluateNewUnlocks(
      existingIds: _save.unlockedAchievementIds,
      stats: nextStats,
      bestEndless: math.max(
        _save.bestEndlessScore,
        _engine.mode == GameMode.endless ? _engine.score : 0,
      ),
      bestBlitz: math.max(
        _save.bestBlitzScore,
        _engine.mode == GameMode.blitz ? _engine.score : 0,
      ),
      solvedQuestCount: _save.questStarsByStage.length,
      solvedDailyCount: _save.solvedDailyDates.length,
    );
    if (newlyUnlocked.isNotEmpty) {
      final merged = Set<String>.from(_save.unlockedAchievementIds)
        ..addAll(newlyUnlocked.map((a) => a.id));
      _save = _save.copyWith(unlockedAchievementIds: merged);
      widget.audio.playCue(PrismSoundCue.achievementUnlock);
      final first = newlyUnlocked.first;
      _showBanner(
        '${first.iconGlyph} ${first.title.resolve(_locale)}',
        _palette.prismGold,
      );
      for (final a in newlyUnlocked) {
        unawaited(widget.gamesService.unlockAchievement(a.id));
      }
    }
  }

  Future<T> _runWithMutedAudio<T>(Future<T> Function() action) async {
    final prevSound = widget.audio.soundEnabled;
    widget.audio.soundEnabled = false;
    try {
      return await action();
    } finally {
      widget.audio.soundEnabled = prevSound && _save.soundEnabled;
    }
  }

  void _showAdLoadingNotice() {
    _showBanner(
      _locale == AppLocale.tr
          ? 'Reklam hazırlanıyor, tekrar dene'
          : 'Ad loading, please try again',
      _palette.accent,
    );
  }

  Future<void> _handleRewardedRevive() async {
    if (!_engine.canRevive) return;
    final earned = await _runWithMutedAudio(
      () => widget.adService.showRewarded(RewardedPlacement.rescueRevive),
    );
    if (!mounted) return;
    if (!earned) {
      _showAdLoadingNotice();
      return;
    }
    final res = _engine.reviveWithRescueNova();
    if (!res.placed) return;
    _spawnClearFx(res);
    _waves.add(ShockWave.ring(4.0, 4.0, _palette.prismGold));
    if (!_save.reducedMotion) _boardShake = 6.5;
    widget.audio.playCue(PrismSoundCue.nova);
    _showBanner(
      _locale == AppLocale.tr ? '✨ SON NEFES KURTARMA!' : '✨ RESCUE REVIVE!',
      _palette.prismGold,
    );
    _syncBlitzTimer();
    _persistHighScores();
    setState(() {});
  }

  Future<void> _handleRewardedEnergyBoost() async {
    if (_engine.isGameOver ||
        _engine.isVictory ||
        _engine.energy >= 100 ||
        !widget.adService.policy.canUseEnergyBoost) {
      return;
    }
    final earned = await _runWithMutedAudio(
      () => widget.adService.showRewarded(RewardedPlacement.energyBoost),
    );
    if (!mounted) return;
    if (!earned) {
      _showAdLoadingNotice();
      return;
    }
    _engine.grantEnergyBoost();
    widget.audio.playCue(PrismSoundCue.prismTempered);
    _showBanner(
      _locale == AppLocale.tr ? '⚡ +100% NOVA ENERJİSİ!' : '⚡ +100% NOVA ENERGY!',
      _palette.prismGold,
    );
    setState(() {});
  }

  Future<void> _handleRewardedInstantTemper() async {
    if (!_engine.canInstantTemperForge ||
        !widget.adService.policy.canUseInstantTemper) {
      return;
    }
    final earned = await _runWithMutedAudio(
      () => widget.adService.showRewarded(RewardedPlacement.instantTemper),
    );
    if (!mounted) return;
    if (!earned) {
      _showAdLoadingNotice();
      return;
    }
    if (_engine.instantTemperForge()) {
      widget.audio.playCue(PrismSoundCue.prismTempered);
      _showBanner(
        _locale == AppLocale.tr ? '🌈 ANINDA JOKER ★!' : '🌈 INSTANT WILDCARD ★!',
        _palette.prismGold,
      );
      setState(() {});
    }
  }

  void _openTrophyHub() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => TrophyHubSheet(
          palette: _palette,
          locale: _locale,
          save: _save,
          gamesConnected: widget.gamesService.isConnected,
          onTapConnectGames: () async {
            await widget.gamesService.signInOptional();
            if (mounted) setState(() {});
          },
          privacyOptionsRequired: widget.adService.isPrivacyOptionsRequired,
          onTapPrivacyOptions: () =>
              unawaited(widget.adService.showPrivacyOptionsForm()),
        ),
      ),
    );
  }

  void _handleAnvilTap() {
    if (_engine.isGameOver || _engine.isVictory) return;
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
    if (!_save.reducedMotion) _boardShake = 7.0;
    widget.audio.playCue(PrismSoundCue.nova);
    _showBanner('NOVA +${outcome.pointsEarned}', _palette.prismGold);
    if (outcome.objectiveCompleted) {
      widget.audio.playCue(PrismSoundCue.stageClear);
      _spawnVictoryConfetti();
      if (_save.reducedMotion) {
        _victoryStarsCtrl.value = 1.0;
      } else {
        _victoryStarsCtrl.forward(from: 0.0);
      }
    }
    _checkEndlessRealmEvolution();
    _persistHighScores();
    setState(() {
      _novaMode = false;
      _novaHover = null;
    });
  }

  void _cycleTheme() {
    const values = PrismThemeId.values;
    final next = values[(values.indexOf(_save.themeId) + 1) % values.length];
    setState(() => _transitionToTheme(next));
  }

  void _selectTheme(PrismThemeId id) {
    setState(() => _transitionToTheme(id));
  }

  void _toggleAutoTheme() {
    final next = !_save.autoStageTheme;
    setState(() {
      _save = _save.copyWith(autoStageTheme: next);
      if (next && _engine.mode == GameMode.quest) {
        _transitionToTheme(
          QuestStageCatalog.byNumber(_engine.questStageNumber).themeId,
          persist: false,
        );
      }
    });
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
          autoStageTheme: _save.autoStageTheme,
          onSelectStage: (stage) => _startMode(GameMode.quest, stage: stage),
          onSelectTheme: _selectTheme,
          onToggleAutoTheme: _toggleAutoTheme,
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
            // 12-atmosphere animated backdrop with silky 650ms theme cross-fade!
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: Listenable.merge(<Listenable>[
                    _ticker,
                    _themeCrossFade,
                  ]),
                  builder: (context, _) => CustomPaint(
                    painter: AmbientBackdropPainter(
                      palette: p,
                      previousPalette: _previousPalette,
                      transitionT: Curves.easeInOutCubic.transform(
                        _themeCrossFade.value,
                      ),
                      phase: _save.reducedMotion ? 0.25 : _ticker.value,
                    ),
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
                    const SizedBox(height: 6),
                    _buildContextBar(p),
                    const SizedBox(height: 8),
                    _buildEnergyBar(p),
                    const SizedBox(height: 8),
                    Expanded(child: _buildBoardArea(p)),
                    const SizedBox(height: 10),
                    _buildTrayWithAnvil(p),
                    const SizedBox(height: 8),
                    _buildFooter(p),
                    if (widget.adService.isBannerVisible) ...<Widget>[
                      const SizedBox(height: 6),
                      _buildSafeAdBannerSlot(p),
                    ],
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

  Widget _buildSafeAdBannerSlot(PrismPalette p) {
    final fallbackLabel = _locale == AppLocale.tr
        ? (AdUnitConfig.isUsingTestIds
              ? 'AdMob Uyarlanabilir Banner (Test Modu)'
              : 'AdMob Uyarlanabilir Banner')
        : (AdUnitConfig.isUsingTestIds
              ? 'AdMob Adaptive Banner (Test Mode)'
              : 'AdMob Adaptive Banner');

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: widget.adService.statusListenable,
          builder: (context, _) => Center(
            child: widget.adService.buildBannerWidget(
              maxWidth: constraints.maxWidth,
              surfaceColor: p.surface.withValues(alpha: 0.72),
              borderColor: p.ink.withValues(alpha: 0.12),
              textColor: p.mutedInk,
              fallbackLabel: fallbackLabel,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(PrismPalette p) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[p.boardBackground, p.accent],
            ),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
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
          key: const ValueKey<String>('trophy_button'),
          p: p,
          icon: Icons.emoji_events_rounded,
          onTap: _openTrophyHub,
        ),
        const SizedBox(width: 5),
        _headerChip(
          key: const ValueKey<String>('theme_button'),
          p: p,
          label: p.name.resolve(_locale),
          onTap: _cycleTheme,
        ),
        const SizedBox(width: 5),
        _headerChip(
          key: const ValueKey<String>('sound_button'),
          p: p,
          icon: _save.soundEnabled
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          onTap: _toggleSound,
        ),
        const SizedBox(width: 5),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
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
        rightLabel = _engine.isBossStage
            ? '👑 ${PrismStrings.stage.resolve(_locale)}'
            : PrismStrings.stage.resolve(_locale);
        rightValue = '#${_engine.questStageNumber}/1000';
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
        _statCard(p, PrismStrings.score.resolve(_locale), '$_displayedScore'),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: _engine.isFeverActive
                    ? p.prismGold
                    : p.ink.withValues(alpha: 0.14),
                width: _engine.isFeverActive ? 1.8 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _engine.isFeverActive
                          ? PrismStrings.feverBadge.resolve(_locale)
                          : PrismStrings.combo.resolve(_locale),
                      style: TextStyle(
                        color: _engine.isFeverActive ? p.accent : p.mutedInk,
                        fontSize: 10.5,
                        fontWeight: _engine.isFeverActive
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        for (var i = 0; i < 3; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: p.ink.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: p.mutedInk, fontSize: 11),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: p.ink,
                  fontSize: 17.5,
                  fontWeight: FontWeight.w900,
                ),
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
    final bool opensSheet;

    if (_engine.mode == GameMode.quest) {
      final spec = QuestStageCatalog.byNumber(_engine.questStageNumber);
      final stPalette = PrismThemes.vibrantForStage(
        spec.themeId,
        spec.stageNumber,
      );
      final bossCrown = spec.isBossStage ? '👑' : '';
      pillText =
          '#${spec.stageNumber} $bossCrown${stPalette.badgeEmoji} ${spec.title.resolve(_locale)} ▾';
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
      opensSheet = true;
    } else if (_engine.mode == GameMode.endless) {
      const themes = PrismThemeId.values;
      final nextPalette = PrismThemes.of(
        themes[(themes.indexOf(_save.themeId) + 1) % themes.length],
      );
      pillText = '${p.badgeEmoji} ${p.fullName.resolve(_locale)} ▾';
      descText =
          '${PrismStrings.endlessNextRealm.resolve(_locale)} → ${nextPalette.badgeEmoji} ${nextPalette.name.resolve(_locale)}';
      progress = ((_engine.score % _endlessEvolutionStep) /
              _endlessEvolutionStep)
          .clamp(0.0, 1.0)
          .toDouble();
      metric = '${_engine.score % _endlessEvolutionStep}/$_endlessEvolutionStep';
      opensSheet = true;
    } else if (_engine.mode == GameMode.daily) {
      pillText = '${p.badgeEmoji} ${_engine.dailyDateKey}';
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
      opensSheet = true;
    } else {
      pillText =
          '${p.badgeEmoji} ${PrismStrings.best.resolve(_locale)}: ${_save.bestBlitzScore}';
      descText = PrismStrings.blitzHint.resolve(_locale);
      progress = (_engine.blitzSecondsLeft / 90.0).clamp(0.0, 1.0).toDouble();
      metric = '${_engine.blitzSecondsLeft.ceil()}s';
      opensSheet = true;
    }

    final showMovesBadge =
        _engine.hasMoveLimit &&
        (_engine.mode == GameMode.quest || _engine.mode == GameMode.daily);
    final lowMoves = showMovesBadge && _engine.movesLeft <= 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: lowMoves
              ? const Color(0xFFFF3B5C)
              : p.ink.withValues(alpha: 0.14),
          width: lowMoves ? 1.6 : 1.0,
        ),
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            key: const ValueKey<String>('context_pill_button'),
            borderRadius: BorderRadius.circular(8),
            onTap: opensSheet ? _openStagePicker : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              constraints: const BoxConstraints(maxWidth: 152),
              decoration: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pillText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.accentInk,
                  fontSize: 10.6,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              descText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.ink,
                fontSize: 10.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showMovesBadge) ...<Widget>[
            const SizedBox(width: 5),
            Container(
              key: const ValueKey<String>('moves_left_badge'),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: lowMoves
                    ? const Color(0xFFFF3B5C)
                    : p.prismGold.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: lowMoves ? const Color(0xFFFF3B5C) : p.prismGold,
                ),
              ),
              child: Text(
                '🎯${_engine.movesLeft}',
                style: TextStyle(
                  color: lowMoves ? Colors.white : p.ink,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
          const SizedBox(width: 6),
          SizedBox(
            width: 38,
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
          const SizedBox(width: 5),
          Text(
            metric,
            style: TextStyle(
              color: p.ink,
              fontSize: 10.5,
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
    final canRewardedBoost =
        _engine.energy < PrismEngine.novaEnergyCost &&
        widget.adService.policy.canUseEnergyBoost &&
        !_engine.isGameOver &&
        !_engine.isVictory;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: canNova ? p.prismGold : p.ink.withValues(alpha: 0.14),
          width: canNova ? 1.6 : 1.0,
        ),
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
          const SizedBox(width: 6),
          if (canRewardedBoost) ...<Widget>[
            InkWell(
              key: const ValueKey<String>('rewarded_energy_button'),
              borderRadius: BorderRadius.circular(10),
              onTap: () => unawaited(_handleRewardedEnergyBoost()),
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color: p.prismGold.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.prismGold, width: 1.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.play_circle_filled_rounded,
                      size: 14,
                      color: p.ink,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+100%',
                      style: TextStyle(
                        color: p.ink,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
          ],
          _powerButton(
            key: const ValueKey<String>('rotate_button'),
            p: p,
            icon: Icons.rotate_right_rounded,
            label: '${PrismStrings.rotate.resolve(_locale)} 35%',
            enabled: canRotate,
            highlight: false,
            onTap: _handleRotate,
          ),
          const SizedBox(width: 5),
          _powerButton(
            key: const ValueKey<String>('nova_button'),
            p: p,
            icon: Icons.auto_awesome_rounded,
            label: PrismStrings.nova.resolve(_locale),
            enabled: canNova,
            highlight: _novaMode || canNova,
            glowPulse: canNova,
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
    bool glowPulse = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.42,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: highlight ? p.accent : p.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: glowPulse
                  ? p.prismGold
                  : highlight
                  ? p.accent
                  : p.ink.withValues(alpha: 0.16),
              width: glowPulse ? 1.8 : 1.0,
            ),
            boxShadow: glowPulse
                ? <BoxShadow>[
                    BoxShadow(
                      color: p.prismGold.withValues(alpha: 0.48),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
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
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _ticker,
                        builder: (context, _) {
                          final shakeDx = _boardShake > 0.05 && !_save.reducedMotion
                              ? math.sin(_ticker.value * math.pi * 24) * _boardShake
                              : 0.0;
                          final shakeDy = _boardShake > 0.05 && !_save.reducedMotion
                              ? math.cos(_ticker.value * math.pi * 19) *
                                    _boardShake *
                                    0.7
                              : 0.0;
                          return Transform.translate(
                            offset: Offset(shakeDx, shakeDy),
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: PrismBoardPainter(
                                grid: _engine.grid,
                                palette: p,
                                phase: _save.reducedMotion ? 0.25 : _ticker.value,
                                particles: _particles,
                                waves: _waves,
                                cellPopProgress: _cellPopProgress,
                                reducedMotion: _save.reducedMotion,
                                hoverPiece: hoverPiece,
                                preview: _activePreview,
                                novaMode: _novaMode,
                                novaHover: _novaHover,
                                isFever: _engine.isFeverActive,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Non-blocking crystalline Stage Intro / Realm Evolution Showcase Banner!
                  if (_stageIntro != null)
                    Positioned(
                      top: 24,
                      left: 18,
                      right: 18,
                      child: AnimatedBuilder(
                        animation: _stageIntroCtrl,
                        builder: (context, _) => StageIntroBanner(
                          key: ValueKey<int>(_stageIntro!.sequenceId),
                          payload: _stageIntro!,
                          locale: _locale,
                          progress: _stageIntroCtrl.value,
                          reducedMotion: _save.reducedMotion,
                        ),
                      ),
                    ),
                  // Spring-pop kinetic callout banner (Resonance / Chain-Refraction / Fever!)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: IgnorePointer(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutBack,
                            ),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: _kineticBanner == null
                              ? const SizedBox.shrink()
                              : Container(
                                  key: ValueKey<int>(_kineticSeq),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.boardBackground.withValues(
                                      alpha: 0.94,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: _kineticColor,
                                      width: 1.8,
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: _kineticColor.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 12,
                                      ),
                                    ],
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
    final isQuestWin = isWin && _engine.mode == GameMode.quest;
    final hasNextQuestStage =
        isQuestWin && _engine.questStageNumber < QuestStageCatalog.totalStages;
    final currentSpec = QuestStageCatalog.byNumber(_engine.questStageNumber);
    final nextSpec = hasNextQuestStage
        ? QuestStageCatalog.byNumber(_engine.questStageNumber + 1)
        : null;
    final nextPalette = nextSpec != null
        ? PrismThemes.vibrantForStage(nextSpec.themeId, nextSpec.stageNumber)
        : null;
    final earnedStars = isQuestWin ? _engine.computeQuestStars() : 0;

    final String title;
    final String desc;
    final String actionLabel;

    if (isWin && _engine.mode == GameMode.daily) {
      title = PrismStrings.dailyClearTitle.resolve(_locale);
      desc = PrismStrings.dailyClearDesc.resolve(_locale);
      actionLabel = PrismStrings.playAgain.resolve(_locale);
    } else if (isQuestWin) {
      final crown = currentSpec.isBossStage ? '👑 ' : '';
      title =
          '$crown#${currentSpec.stageNumber} • ${currentSpec.title.resolve(_locale)}';
      desc = PrismStrings.stageClearDesc.resolve(_locale);
      actionLabel = hasNextQuestStage && nextSpec != null && nextPalette != null
          ? '${PrismStrings.nextStage.resolve(_locale)} → ${nextPalette.badgeEmoji} ${nextSpec.title.resolve(_locale)}'
          : PrismStrings.playAgain.resolve(_locale);
    } else if (_engine.mode == GameMode.blitz &&
        _engine.blitzSecondsLeft <= 0) {
      title = PrismStrings.timeUpTitle.resolve(_locale);
      desc = PrismStrings.timeUpDesc.resolve(_locale);
      actionLabel = PrismStrings.playAgain.resolve(_locale);
    } else if (_engine.isOutOfMoves) {
      title = PrismStrings.outOfMovesTitle.resolve(_locale);
      desc = PrismStrings.outOfMovesDesc.resolve(_locale);
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
        padding: const EdgeInsets.all(18),
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
                if (isQuestWin)
                  AnimatedBuilder(
                    animation: _victoryStarsCtrl,
                    builder: (context, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          for (var i = 0; i < 3; i++)
                            Builder(
                              builder: (context) {
                                final start = i * 0.22;
                                final localT =
                                    ((_victoryStarsCtrl.value - start) / 0.45)
                                        .clamp(0.0, 1.0);
                                final scale = _save.reducedMotion
                                    ? 1.0
                                    : Curves.easeOutBack.transform(localT);
                                final filled = i < earnedStars;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      filled
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: filled
                                          ? p.prismGold
                                          : p.mutedInk.withValues(alpha: 0.45),
                                      size: i == 1 ? 40 : 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  )
                else
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
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.mutedInk, fontSize: 12),
                ),
                const SizedBox(height: 12),
                if (_engine.canRevive) ...<Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const ValueKey<String>('revive_rewarded_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.prismGold,
                        foregroundColor: const Color(0xFF1C0E45),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => unawaited(_handleRewardedRevive()),
                      icon: const Icon(
                        Icons.play_circle_filled_rounded,
                        size: 18,
                      ),
                      label: Text(
                        _engine.isOutOfMoves
                            ? (_locale == AppLocale.tr
                                  ? 'Son Nefes: +8 Hamle & 3×3 Kurtar (Ödüllü)'
                                  : 'Rescue Revive: +8 Moves & 3×3 (Rewarded)')
                            : (_locale == AppLocale.tr
                                  ? 'Son Nefes: 3×3 Kurtar (Ödüllü)'
                                  : 'Rescue Revive: Clear 3×3 (Rewarded)'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: nextPalette != null
                          ? LinearGradient(
                              colors: nextPalette.backgroundGradient,
                            )
                          : null,
                      color: nextPalette == null ? p.accent : null,
                      border: nextPalette != null
                          ? Border.all(
                              color: nextPalette.boardBorderGlow,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: ElevatedButton(
                      key: const ValueKey<String>('overlay_action_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: nextPalette != null
                            ? (nextPalette.brightness == Brightness.dark
                                  ? Colors.white
                                  : nextPalette.ink)
                            : p.accentInk,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _runWithMutedAudio(
                          () => widget.adService.maybeShowInterstitial(),
                        );
                        if (!mounted) return;
                        if (hasNextQuestStage) {
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
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
      child: AnimatedBuilder(
        animation: _ticker,
        builder: (context, child) {
          final pulse = tempered && !_save.reducedMotion
              ? 0.45 + 0.45 * math.sin(_ticker.value * math.pi * 4).abs()
              : 0.0;
          return AnimatedContainer(
            key: const ValueKey<String>('anvil_slot'),
            duration: const Duration(milliseconds: 220),
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
              boxShadow: tempered
                  ? <BoxShadow>[
                      BoxShadow(
                        color: p.prismGold.withValues(alpha: pulse * 0.55),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: child,
          );
        },
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
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
    final showInstantTemper =
        _engine.canInstantTemperForge &&
        widget.adService.policy.canUseInstantTemper;

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
        if (showInstantTemper) ...<Widget>[
          const SizedBox(width: 6),
          InkWell(
            key: const ValueKey<String>('rewarded_temper_button'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => unawaited(_handleRewardedInstantTemper()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: p.prismGold.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.prismGold, width: 1.4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.play_circle_filled_rounded,
                    size: 13,
                    color: p.ink,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _locale == AppLocale.tr ? 'Hızlı Örs ★' : 'Instant Wild ★',
                    style: TextStyle(
                      color: p.ink,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(width: 6),
        InkWell(
          key: const ValueKey<String>('restart_button'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => _startMode(_engine.mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
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
