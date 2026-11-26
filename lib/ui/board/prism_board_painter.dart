/// High-craft 3D crystal gem CustomPainters for PRISM FORGE:
/// - Multi-layered beveled gem blocks with top-left specular gleam
/// - Rotating ★ Prism Star Cores
/// - Translucent ❄ 2-Hit Frosted Crystal lattice overlay
/// - Architectural gold 🔒 Locked Keystone clasps
/// - Live pre-drop Row/Column clear glow, Resonance halo & Cross-Wave range
/// - 60fps glass shard particles & expanding laser/ring shockwaves
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../../engine/prism_engine.dart';
import '../../theme/prism_themes.dart';

/// Animated glass shard particle spawned when blocks shatter.
class ShardParticle {
  ShardParticle({
    required this.gx,
    required this.gy,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.vRot,
    required this.color,
  });

  double gx;
  double gy;
  double vx;
  double vy;
  final double size;
  double rotation;
  final double vRot;
  final Color color;
  double life = 1.0;
}

/// Shockwave visual (row beam, column beam, or expanding prism ring).
class ShockWave {
  ShockWave.row(this.index, this.color) : kind = _WaveKind.row, gx = 0, gy = 0;

  ShockWave.col(this.index, this.color) : kind = _WaveKind.col, gx = 0, gy = 0;

  ShockWave.ring(this.gx, this.gy, this.color)
    : kind = _WaveKind.ring,
      index = 0;

  final _WaveKind kind;
  final int index;
  final double gx;
  final double gy;
  final Color color;
  double life = 1.0;
}

enum _WaveKind { row, col, ring }

/// Shared gem block drawing helper used by both the 8x8 board and tray pieces.
void paintCrystalGem({
  required Canvas canvas,
  required Rect cellRect,
  required GemColorRamp ramp,
  bool isPrismCore = false,
  int frostHits = 0,
  bool isLocked = false,
  double pulsePhase = 0.0,
  double opacity = 1.0,
  bool isGhost = false,
}) {
  final pad = cellRect.width * 0.065;
  final rect = cellRect.deflate(pad);
  final radius = Radius.circular(math.max(4.0, rect.width * 0.22));
  final rrect = RRect.fromRectAndRadius(rect, radius);

  if (isGhost) {
    canvas.drawRRect(
      rrect,
      Paint()..color = ramp.main.withValues(alpha: 0.45 * opacity),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = ramp.highlight.withValues(alpha: 0.85 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    return;
  }

  // 1. Multi-stop 3D bevel gradient fill.
  final fillPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        ramp.highlight.withValues(alpha: opacity),
        ramp.main.withValues(alpha: opacity),
        ramp.shadow.withValues(alpha: opacity),
      ],
      stops: const <double>[0.0, 0.30, 1.0],
    ).createShader(rect);
  canvas.drawRRect(rrect, fillPaint);

  // 2. Crisp dark base rim.
  canvas.drawRRect(
    rrect,
    Paint()
      ..color = Colors.black.withValues(alpha: 0.28 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, rect.width * 0.045),
  );

  // 3. Inner crystal facet window.
  final innerRect = rect.deflate(rect.width * 0.16);
  final innerRRect = RRect.fromRectAndRadius(
    innerRect,
    Radius.circular(math.max(2.5, rect.width * 0.12)),
  );
  canvas.drawRRect(
    innerRRect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.28 * opacity),
          Colors.white.withValues(alpha: 0.02 * opacity),
        ],
      ).createShader(innerRect),
  );

  // 4. Top-left glass specular gleam.
  canvas.drawLine(
    Offset(rect.left + rect.width * 0.20, rect.top + rect.height * 0.16),
    Offset(rect.left + rect.width * 0.54, rect.top + rect.height * 0.16),
    Paint()
      ..color = Colors.white.withValues(alpha: 0.68 * opacity)
      ..strokeWidth = math.max(1.4, rect.width * 0.065)
      ..strokeCap = StrokeCap.round,
  );

  // 5. ★ Rotating Prism Star Core.
  if (isPrismCore) {
    final center = rect.center;
    final starR =
        rect.width * (0.28 + math.sin(pulsePhase * math.pi * 2) * 0.03);
    final starPath = Path();
    for (var i = 0; i < 8; i++) {
      final rad = i.isEven ? starR : starR * 0.42;
      final angle = (math.pi * i) / 4.0 + pulsePhase * math.pi * 0.5;
      final pt = Offset(
        center.dx + math.cos(angle) * rad,
        center.dy + math.sin(angle) * rad,
      );
      if (i == 0) {
        starPath.moveTo(pt.dx, pt.dy);
      } else {
        starPath.lineTo(pt.dx, pt.dy);
      }
    }
    starPath.close();
    canvas.drawPath(
      starPath,
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: opacity),
    );
  }

  // 6. ❄ Frosted 2-Hit Ice Lattice Sheath.
  if (frostHits > 0) {
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.46 * opacity),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.92 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    final center = rect.center;
    final r = rect.width * 0.24;
    final frostLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.9 * opacity)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final a = (math.pi * i) / 3.0;
      canvas.drawLine(
        Offset(center.dx - math.cos(a) * r, center.dy - math.sin(a) * r),
        Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r),
        frostLine,
      );
    }
  }

  // 7. 🔒 Architectural Gold Locked Keystone Clasp.
  if (isLocked) {
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFFACC15).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    final bodyRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.center.dy + rect.height * 0.05),
      width: rect.width * 0.42,
      height: rect.height * 0.30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)),
      Paint()..color = const Color(0xBF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)),
      Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(rect.center.dx, rect.center.dy - rect.height * 0.11),
        width: rect.width * 0.24,
        height: rect.height * 0.22,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFFEF08A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }
}

/// Renders the full 8x8 PRISM FORGE board, pre-drop glow, particles & waves.
class PrismBoardPainter extends CustomPainter {
  const PrismBoardPainter({
    required this.grid,
    required this.palette,
    required this.phase,
    required this.particles,
    required this.waves,
    this.hoverPiece,
    this.preview,
    this.novaMode = false,
    this.novaHover,
  });

  final List<List<BoardCell?>> grid;
  final PrismPalette palette;
  final double phase;
  final List<ShardParticle> particles;
  final List<ShockWave> waves;
  final PrismPiece? hoverPiece;
  final PlacementPreview? preview;
  final bool novaMode;
  final GridPoint? novaHover;

  static const double boardPadding = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = (size.width - boardPadding * 2) / PrismEngine.gridSize;

    // 1. Board outer frame.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      Paint()..color = palette.boardBackground,
    );

    // 2. 8x8 architectural grid slots with subtle 4x4 quadrant shading.
    for (var y = 0; y < PrismEngine.gridSize; y++) {
      for (var x = 0; x < PrismEngine.gridSize; x++) {
        final rect = Rect.fromLTWH(
          boardPadding + x * cellSize + 2,
          boardPadding + y * cellSize + 2,
          cellSize - 4,
          cellSize - 4,
        );
        final rrect = RRect.fromRectAndRadius(
          rect,
          Radius.circular(math.max(5.0, cellSize * 0.18)),
        );
        canvas.drawRRect(rrect, Paint()..color = palette.cellBackground);
        if (((x >> 2) + (y >> 2)).isOdd) {
          canvas.drawRRect(
            rrect,
            Paint()..color = Colors.white.withValues(alpha: 0.025),
          );
        }
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = palette.cellBorder
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }

    // 3. Pre-drop Line-Clear, Resonance & Prism Cross-Wave Highlight!
    final activePreview = preview;
    if (activePreview != null && activePreview.hasLineClear) {
      final glowAlpha = 0.24 + 0.14 * math.sin(phase * math.pi * 4).abs();
      final glowColor = activePreview.triggersResonance
          ? palette.resonanceColor.withValues(alpha: glowAlpha + 0.12)
          : palette.accent.withValues(alpha: glowAlpha + 0.06);
      final glowPaint = Paint()..color = glowColor;

      for (final r in activePreview.rowsToClear) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              boardPadding,
              boardPadding + r * cellSize + 1,
              size.width - boardPadding * 2,
              cellSize - 2,
            ),
            const Radius.circular(8),
          ),
          glowPaint,
        );
      }
      for (final c in activePreview.colsToClear) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              boardPadding + c * cellSize + 1,
              boardPadding,
              cellSize - 2,
              size.height - boardPadding * 2,
            ),
            const Radius.circular(8),
          ),
          glowPaint,
        );
      }

      // Highlight Cross-Wave blast range for any Prism Core in the clear!
      if (activePreview.triggeredPrisms.isNotEmpty) {
        final prismGlow = Paint()
          ..color = palette.prismGold.withValues(alpha: glowAlpha + 0.16);
        const dirs = <GridPoint>[
          GridPoint(1, 0),
          GridPoint(-1, 0),
          GridPoint(0, 1),
          GridPoint(0, -1),
          GridPoint(2, 0),
          GridPoint(-2, 0),
          GridPoint(0, 2),
          GridPoint(0, -2),
        ];
        for (final pr in activePreview.triggeredPrisms) {
          for (final d in dirs) {
            final nx = pr.x + d.x;
            final ny = pr.y + d.y;
            if (nx < 0 ||
                ny < 0 ||
                nx >= PrismEngine.gridSize ||
                ny >= PrismEngine.gridSize) {
              continue;
            }
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(
                  boardPadding + nx * cellSize + 3,
                  boardPadding + ny * cellSize + 3,
                  cellSize - 6,
                  cellSize - 6,
                ),
                const Radius.circular(7),
              ),
              prismGlow,
            );
          }
        }
      }
    }

    // 4. Placed blocks.
    for (var y = 0; y < PrismEngine.gridSize; y++) {
      for (var x = 0; x < PrismEngine.gridSize; x++) {
        final cell = grid[y][x];
        if (cell == null) continue;
        final rect = Rect.fromLTWH(
          boardPadding + x * cellSize,
          boardPadding + y * cellSize,
          cellSize,
          cellSize,
        );
        paintCrystalGem(
          canvas: canvas,
          cellRect: rect,
          ramp: palette.gemFor(cell.colorIndex),
          isPrismCore: cell.isPrismCore,
          frostHits: cell.frostHits,
          isLocked: cell.isLocked,
          pulsePhase: phase,
        );

        final willClear =
            activePreview != null &&
            (activePreview.rowsToClear.contains(y) ||
                activePreview.colsToClear.contains(x));
        if (willClear) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(8)),
            Paint()
              ..color = activePreview.triggersResonance
                  ? palette.resonanceColor
                  : palette.prismGold
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0,
          );
        }
      }
    }

    // 5. Magnetic ghost preview for hovered piece.
    if (hoverPiece != null && activePreview != null) {
      final anchor = activePreview.anchor;
      final ramp = palette.gemFor(hoverPiece!.colorIndex);
      for (var i = 0; i < hoverPiece!.cells.length; i++) {
        final c = hoverPiece!.cells[i];
        final rect = Rect.fromLTWH(
          boardPadding + (anchor.x + c.x) * cellSize,
          boardPadding + (anchor.y + c.y) * cellSize,
          cellSize,
          cellSize,
        );
        paintCrystalGem(
          canvas: canvas,
          cellRect: rect,
          ramp: ramp,
          isPrismCore: i == hoverPiece!.prismCellIndex,
          isGhost: true,
        );
      }
    }

    // 6. Quantum Nova 3x3 target reticle.
    if (novaMode && novaHover != null) {
      final x0 = math.max(0, novaHover!.x - 1);
      final y0 = math.max(0, novaHover!.y - 1);
      final x1 = math.min(PrismEngine.gridSize - 1, novaHover!.x + 1);
      final y1 = math.min(PrismEngine.gridSize - 1, novaHover!.y + 1);
      final novaRect = Rect.fromLTWH(
        boardPadding + x0 * cellSize + 2,
        boardPadding + y0 * cellSize + 2,
        (x1 - x0 + 1) * cellSize - 4,
        (y1 - y0 + 1) * cellSize - 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(novaRect, const Radius.circular(10)),
        Paint()..color = palette.prismGold.withValues(alpha: 0.24),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(novaRect, const Radius.circular(10)),
        Paint()
          ..color = palette.prismGold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // 7. Shockwaves.
    for (final w in waves) {
      final alpha = (w.life * 0.72).clamp(0.0, 1.0).toDouble();
      if (w.kind == _WaveKind.row) {
        canvas.drawRect(
          Rect.fromLTWH(
            boardPadding,
            boardPadding + w.index * cellSize + cellSize * 0.16,
            size.width - boardPadding * 2,
            cellSize * 0.68,
          ),
          Paint()..color = w.color.withValues(alpha: alpha),
        );
      } else if (w.kind == _WaveKind.col) {
        canvas.drawRect(
          Rect.fromLTWH(
            boardPadding + w.index * cellSize + cellSize * 0.16,
            boardPadding,
            cellSize * 0.68,
            size.height - boardPadding * 2,
          ),
          Paint()..color = w.color.withValues(alpha: alpha),
        );
      } else {
        final radius = (1.0 - w.life) * cellSize * 3.5;
        canvas.drawCircle(
          Offset(
            boardPadding + w.gx * cellSize,
            boardPadding + w.gy * cellSize,
          ),
          radius,
          Paint()
            ..color = w.color.withValues(alpha: alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0 * w.life,
        );
      }
    }

    // 8. Glass shard particles.
    for (final p in particles) {
      final alpha = p.life.clamp(0.0, 1.0).toDouble();
      final s = p.size * cellSize * (0.4 + alpha * 0.6);
      canvas.save();
      canvas.translate(
        boardPadding + p.gx * cellSize,
        boardPadding + p.gy * cellSize,
      );
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: s, height: s),
        Paint()..color = p.color.withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PrismBoardPainter oldDelegate) => true;
}

/// Renders a single polyomino piece cleanly centered inside a tray card or drag feedback.
class PieceMiniPainter extends CustomPainter {
  const PieceMiniPainter({
    required this.piece,
    required this.palette,
    this.cellSizeOverride,
  });

  final PrismPiece piece;
  final PrismPalette palette;
  final double? cellSizeOverride;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 8.0;
    final cs =
        cellSizeOverride ??
        math.min(
          (size.width - pad * 2) / math.max(piece.cols, 3),
          (size.height - pad * 2) / math.max(piece.rows, 3),
        );
    final ox = (size.width - piece.cols * cs) / 2.0;
    final oy = (size.height - piece.rows * cs) / 2.0;
    final ramp = palette.gemFor(piece.colorIndex);

    for (var i = 0; i < piece.cells.length; i++) {
      final c = piece.cells[i];
      paintCrystalGem(
        canvas: canvas,
        cellRect: Rect.fromLTWH(ox + c.x * cs, oy + c.y * cs, cs, cs),
        ramp: ramp,
        isPrismCore: i == piece.prismCellIndex,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PieceMiniPainter oldDelegate) =>
      oldDelegate.piece != piece || oldDelegate.palette.id != palette.id;
}
