/// High-craft "Cıvıl Cıvıl" 3D crystal gem & optical laser CustomPainters:
/// - Chromatic jewel rims (no muddy black strokes), specular pill gleam & caustic bounce
/// - Iridescent Rainbow Wildcard Crystal Glass (tempered in the Prism Anvil)
/// - Rotating ★ Prism Core with radiant aura
/// - Translucent ❄ 2-Hit Frost lattice & gold 🔒 Locked Keystone clasps
/// - Live pre-drop 2x2 Synthesis quad outline + ghost ★, Row/Col Resonance glow,
///   and ★→★ golden Optical Chain-Refraction laser beams!
/// - Animated background ambiance (sunlit bubbles, candy sparkles, blossom petals, neon bokeh)
/// - Confetti-star & diamond shard particles + laser beam shockwaves
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../../engine/prism_engine.dart';
import '../../theme/prism_themes.dart';

/// Animated diamond shard or twinkling 4-point confetti star particle.
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
    this.isStar = false,
  });

  double gx;
  double gy;
  double vx;
  double vy;
  final double size;
  double rotation;
  final double vRot;
  final Color color;
  final bool isStar;
  double life = 1.0;
}

/// Shockwave visual (row beam, column beam, optical laser link, or prism ring).
class ShockWave {
  ShockWave.row(this.index, this.color)
    : kind = _WaveKind.row,
      gx = 0,
      gy = 0,
      gx2 = 0,
      gy2 = 0;

  ShockWave.col(this.index, this.color)
    : kind = _WaveKind.col,
      gx = 0,
      gy = 0,
      gx2 = 0,
      gy2 = 0;

  ShockWave.ring(this.gx, this.gy, this.color)
    : kind = _WaveKind.ring,
      index = 0,
      gx2 = 0,
      gy2 = 0;

  ShockWave.beam(this.gx, this.gy, this.gx2, this.gy2, this.color)
    : kind = _WaveKind.beam,
      index = 0;

  final _WaveKind kind;
  final int index;
  final double gx;
  final double gy;
  final double gx2;
  final double gy2;
  final Color color;
  double life = 1.0;
}

enum _WaveKind { row, col, ring, beam }

/// Animated joyful background canvas behind the entire screen.
class AmbientBackdropPainter extends CustomPainter {
  const AmbientBackdropPainter({required this.palette, required this.phase});

  final PrismPalette palette;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.backgroundGradient,
        ).createShader(rect),
    );

    switch (palette.ambientStyle) {
      case PrismAmbientStyle.sunBubbles:
        // Soft sunlit rays + rising translucent lagoon bubbles.
        final rayPaint = Paint()..color = Colors.white.withValues(alpha: 0.13);
        for (var r = 0; r < 2; r++) {
          final sway = math.sin(phase * math.pi * 2 + r) * 18;
          final x0 = size.width * (0.18 + r * 0.42) + sway;
          canvas.drawPath(
            Path()
              ..moveTo(x0, 0)
              ..lineTo(x0 + 90, 0)
              ..lineTo(x0 - 60, size.height)
              ..lineTo(x0 - 150, size.height)
              ..close(),
            rayPaint,
          );
        }
        for (var i = 0; i < 12; i++) {
          final bx = size.width * (((i * 0.173) % 0.92) + 0.04);
          final by =
              size.height -
              ((phase * size.height + i * 73.0) % (size.height + 40)) +
              20;
          final rad = 6.0 + (i % 4) * 4.5;
          canvas.drawCircle(
            Offset(bx, by),
            rad,
            Paint()..color = Colors.white.withValues(alpha: 0.22),
          );
          canvas.drawCircle(
            Offset(bx - rad * 0.3, by - rad * 0.3),
            rad * 0.25,
            Paint()..color = Colors.white.withValues(alpha: 0.55),
          );
        }

      case PrismAmbientStyle.candySparkles:
        for (var i = 0; i < 14; i++) {
          final sx = size.width * (((i * 0.217) % 0.90) + 0.05);
          final sy = size.height * (((i * 0.143) % 0.90) + 0.05);
          final pulse = 0.55 + 0.45 * math.sin(phase * math.pi * 2 + i * 1.1);
          final rad = (5.0 + (i % 3) * 3.5) * pulse;
          _draw4PointStar(
            canvas,
            Offset(sx, sy),
            rad,
            Colors.white.withValues(alpha: 0.35 + 0.35 * pulse),
          );
        }

      case PrismAmbientStyle.blossomPetals:
        final petalPaint = Paint()
          ..color = const Color(0xFFFFD1E6).withValues(alpha: 0.55);
        for (var i = 0; i < 11; i++) {
          final px =
              size.width * (((i * 0.19) % 0.9) + 0.05) +
              math.sin(phase * math.pi * 2 + i) * 14;
          final py =
              ((phase * size.height * 0.8 + i * 77.0) % (size.height + 30)) -
              15;
          canvas.save();
          canvas.translate(px, py);
          canvas.rotate(phase * math.pi * 2 * (i.isEven ? 0.5 : -0.5) + i);
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: 12, height: 6),
            petalPaint,
          );
          canvas.restore();
        }

      case PrismAmbientStyle.carnivalBokeh:
        const bokehColors = <Color>[
          Color(0xFF00F0FF),
          Color(0xFFFF4DFF),
          Color(0xFFFFE438),
        ];
        for (var i = 0; i < 9; i++) {
          final cx = size.width * (((i * 0.23) % 0.86) + 0.07);
          final cy = size.height * (((i * 0.17) % 0.86) + 0.07);
          final r =
              24.0 + (i % 3) * 16.0 + math.sin(phase * math.pi * 2 + i) * 5;
          canvas.drawCircle(
            Offset(cx, cy),
            r,
            Paint()..color = bokehColors[i % 3].withValues(alpha: 0.12),
          );
        }
    }
  }

  @override
  bool shouldRepaint(covariant AmbientBackdropPainter oldDelegate) =>
      oldDelegate.palette.id != palette.id || oldDelegate.phase != phase;
}

void _draw4PointStar(Canvas canvas, Offset center, double radius, Color color) {
  final p = Path()
    ..moveTo(center.dx, center.dy - radius)
    ..lineTo(center.dx + radius * 0.28, center.dy - radius * 0.28)
    ..lineTo(center.dx + radius, center.dy)
    ..lineTo(center.dx + radius * 0.28, center.dy + radius * 0.28)
    ..lineTo(center.dx, center.dy + radius)
    ..lineTo(center.dx - radius * 0.28, center.dy + radius * 0.28)
    ..lineTo(center.dx - radius, center.dy)
    ..lineTo(center.dx - radius * 0.28, center.dy - radius * 0.28)
    ..close();
  canvas.drawPath(p, Paint()..color = color);
}

/// Shared jelly-crystal gem block drawing helper for board & tray pieces.
void paintCrystalGem({
  required Canvas canvas,
  required Rect cellRect,
  required GemColorRamp ramp,
  bool isPrismCore = false,
  int frostHits = 0,
  bool isLocked = false,
  bool isWildcard = false,
  double pulsePhase = 0.0,
  double opacity = 1.0,
  bool isGhost = false,
}) {
  final pad = cellRect.width * 0.06;
  final rect = cellRect.deflate(pad);
  final radius = Radius.circular(math.max(4.5, rect.width * 0.24));
  final rrect = RRect.fromRectAndRadius(rect, radius);

  if (isGhost) {
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = (isWildcard ? const Color(0xFFFFE438) : ramp.main).withValues(
          alpha: 0.45 * opacity,
        ),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = (isWildcard ? Colors.white : ramp.highlight).withValues(
          alpha: 0.88 * opacity,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    return;
  }

  // 1. Multi-stop bevel fill (iridescent rainbow sweep if Tempered Wildcard!).
  final Shader fillShader = isWildcard
      ? SweepGradient(
          colors: const <Color>[
            Color(0xFF00E5FF),
            Color(0xFFFF38B8),
            Color(0xFFFFE424),
            Color(0xFF34E870),
            Color(0xFF9D6BFF),
            Color(0xFF00E5FF),
          ],
          transform: GradientRotation(pulsePhase * math.pi * 2),
        ).createShader(rect)
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            ramp.highlight.withValues(alpha: opacity),
            ramp.main.withValues(alpha: opacity),
            ramp.shadow.withValues(alpha: opacity),
          ],
          stops: const <double>[0.0, 0.30, 1.0],
        ).createShader(rect);
  canvas.drawRRect(rrect, Paint()..shader = fillShader);

  // 2. Chromatic jewel rim (crisp color-matched rim, never muddy black).
  canvas.drawRRect(
    rrect,
    Paint()
      ..color = (isWildcard ? const Color(0xFFFFF8B8) : ramp.shadow).withValues(
        alpha: 0.86 * opacity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, rect.width * 0.05),
  );

  // 3. Inner jelly-crystal facet + bottom-right caustic bounce.
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
          Colors.white.withValues(alpha: 0.34 * opacity),
          Colors.white.withValues(alpha: 0.02 * opacity),
          ramp.highlight.withValues(alpha: 0.34 * opacity),
        ],
        stops: const <double>[0.0, 0.58, 1.0],
      ).createShader(innerRect),
  );

  // 4. Glossy top-left pill specular + tiny sparkle dot.
  canvas.drawLine(
    Offset(rect.left + rect.width * 0.22, rect.top + rect.height * 0.16),
    Offset(rect.left + rect.width * 0.56, rect.top + rect.height * 0.16),
    Paint()
      ..color = Colors.white.withValues(alpha: 0.78 * opacity)
      ..strokeWidth = math.max(1.6, rect.width * 0.072)
      ..strokeCap = StrokeCap.round,
  );
  _draw4PointStar(
    canvas,
    Offset(rect.left + rect.width * 0.23, rect.top + rect.height * 0.26),
    rect.width * 0.08,
    Colors.white.withValues(alpha: 0.72 * opacity),
  );

  // 5. ★ Rotating Iridescent Prism Star Core.
  if (isPrismCore) {
    final center = rect.center;
    canvas.drawCircle(
      center,
      rect.width * 0.34,
      Paint()
        ..color = const Color(0xFFFFE438).withValues(alpha: 0.36 * opacity),
    );
    final starR =
        rect.width * (0.29 + math.sin(pulsePhase * math.pi * 2) * 0.035);
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
      Paint()
        ..shader = const RadialGradient(
          colors: <Color>[Colors.white, Color(0xFFFFE047)],
        ).createShader(Rect.fromCircle(center: center, radius: starR)),
    );
  }

  // 6. ❄ Frosted 2-Hit Ice Lattice Sheath.
  if (frostHits > 0) {
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.48 * opacity),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.94 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    final center = rect.center;
    final r = rect.width * 0.24;
    final frostLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.92 * opacity)
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
        ..color = const Color(0xFFFFE14D).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    final bodyRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.center.dy + rect.height * 0.05),
      width: rect.width * 0.42,
      height: rect.height * 0.30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)),
      Paint()..color = const Color(0xCC0F172A),
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

/// Renders the 8x8 PRISM FORGE board, pre-drop 2x2 Synthesis & ★→★ Laser preview,
/// confetti-star particles & laser shockwaves.
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
    final outerRRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );

    // 1. Jewel-toned board well + luminous glossy rim.
    canvas.drawRRect(outerRRect, Paint()..color = palette.boardBackground);
    canvas.drawRRect(
      outerRRect.deflate(1),
      Paint()
        ..color = palette.boardBorderGlow.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 2. 8x8 architectural grid slots with 4x4 quadrant shimmer.
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
          Radius.circular(math.max(5.0, cellSize * 0.20)),
        );
        final isAltQuad = ((x >> 2) + (y >> 2)).isOdd;
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = isAltQuad ? palette.cellAltTint : palette.cellBackground,
        );
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = palette.cellBorder
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }

    // 3. Pre-drop Row/Column Clear, Resonance & Cross-Wave Glow.
    final activePreview = preview;
    if (activePreview != null && activePreview.hasLineClear) {
      final glowAlpha = 0.25 + 0.14 * math.sin(phase * math.pi * 4).abs();
      final glowColor = activePreview.triggersResonance
          ? palette.resonanceColor.withValues(alpha: glowAlpha + 0.14)
          : palette.boardBorderGlow.withValues(alpha: glowAlpha + 0.08);
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
    }

    // 4. Placed crystal blocks.
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
          isWildcard: cell.isWildcard,
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
              ..strokeWidth = 2.2,
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
          isWildcard: hoverPiece!.isWildcard,
          isGhost: true,
        );
      }
    }

    // 5b. Live Pre-Drop 2x2 Prism Synthesis Quad Outline + Ghost ★!
    if (activePreview != null && activePreview.hasSynthesis) {
      for (final origin in activePreview.synthesisQuadOrigins) {
        final quadRect = Rect.fromLTWH(
          boardPadding + origin.x * cellSize + 2,
          boardPadding + origin.y * cellSize + 2,
          cellSize * 2 - 4,
          cellSize * 2 - 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(quadRect, const Radius.circular(10)),
          Paint()..color = palette.prismGold.withValues(alpha: 0.22),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(quadRect, const Radius.circular(10)),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
      for (final corePt in activePreview.synthesizedCores) {
        final center = Offset(
          boardPadding + (corePt.x + 0.5) * cellSize,
          boardPadding + (corePt.y + 0.5) * cellSize,
        );
        _draw4PointStar(canvas, center, cellSize * 0.34, palette.prismGold);
      }
    }

    // 5c. Live Pre-Drop Optical Chain-Refraction ★→★ Golden Laser Beams!
    if (activePreview != null && activePreview.hasRefraction) {
      for (final beam in activePreview.refractionBeams) {
        final p1 = Offset(
          boardPadding + (beam.from.x + 0.5) * cellSize,
          boardPadding + (beam.from.y + 0.5) * cellSize,
        );
        final p2 = Offset(
          boardPadding + (beam.to.x + 0.5) * cellSize,
          boardPadding + (beam.to.y + 0.5) * cellSize,
        );
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = palette.prismGold.withValues(alpha: 0.55)
            ..strokeWidth = 7.0
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round,
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
        Paint()..color = palette.prismGold.withValues(alpha: 0.26),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(novaRect, const Radius.circular(10)),
        Paint()
          ..color = palette.prismGold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    // 7. Shockwaves & Optical Laser Beams.
    for (final w in waves) {
      final alpha = (w.life * 0.78).clamp(0.0, 1.0).toDouble();
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
      } else if (w.kind == _WaveKind.beam) {
        final p1 = Offset(
          boardPadding + w.gx * cellSize,
          boardPadding + w.gy * cellSize,
        );
        final p2 = Offset(
          boardPadding + w.gx2 * cellSize,
          boardPadding + w.gy2 * cellSize,
        );
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = w.color.withValues(alpha: alpha)
            ..strokeWidth = 9.0 * w.life
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = Colors.white.withValues(alpha: alpha)
            ..strokeWidth = 3.0 * w.life
            ..strokeCap = StrokeCap.round,
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
            ..strokeWidth = 4.2 * w.life,
        );
      }
    }

    // 8. Confetti-star & diamond crystal shard particles.
    for (final p in particles) {
      final alpha = p.life.clamp(0.0, 1.0).toDouble();
      final s = p.size * cellSize * (0.45 + alpha * 0.65);
      canvas.save();
      canvas.translate(
        boardPadding + p.gx * cellSize,
        boardPadding + p.gy * cellSize,
      );
      canvas.rotate(p.rotation);
      if (p.isStar) {
        _draw4PointStar(
          canvas,
          Offset.zero,
          s * 0.85,
          p.color.withValues(alpha: alpha),
        );
        _draw4PointStar(
          canvas,
          Offset.zero,
          s * 0.42,
          Colors.white.withValues(alpha: alpha),
        );
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: s, height: s),
          Paint()..color = p.color.withValues(alpha: alpha),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PrismBoardPainter oldDelegate) => true;
}

/// Renders a single polyomino piece cleanly centered inside a tray/anvil card.
class PieceMiniPainter extends CustomPainter {
  const PieceMiniPainter({
    required this.piece,
    required this.palette,
    this.cellSizeOverride,
    this.phase = 0.0,
  });

  final PrismPiece piece;
  final PrismPalette palette;
  final double? cellSizeOverride;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 6.0;
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
        isWildcard: piece.isWildcard,
        pulsePhase: phase,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PieceMiniPainter oldDelegate) =>
      oldDelegate.piece != piece ||
      oldDelegate.palette.id != palette.id ||
      oldDelegate.phase != phase;
}
