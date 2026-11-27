/// High-craft 60fps 3D crystal gem, 12-atmosphere cross-fading backdrop,
/// damped-spring block pop, stained-glass specular shimmer, and staggered
/// optical laser CustomPainters for PRISM FORGE (Prizma Döküm).
library;

import 'dart:math' as math;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../../engine/prism_engine.dart';
import '../../theme/prism_themes.dart';

/// Animated faceted crystal shard or twinkling 4-point confetti star particle.
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

/// Shockwave visual (row beam, column beam, staggered optical laser link, or double prism ring).
class ShockWave {
  ShockWave.row(this.index, this.color)
    : kind = _WaveKind.row,
      gx = 0,
      gy = 0,
      gx2 = 0,
      gy2 = 0,
      delay = 0.0;

  ShockWave.col(this.index, this.color)
    : kind = _WaveKind.col,
      gx = 0,
      gy = 0,
      gx2 = 0,
      gy2 = 0,
      delay = 0.0;

  ShockWave.ring(this.gx, this.gy, this.color, {this.delay = 0.0})
    : kind = _WaveKind.ring,
      index = 0,
      gx2 = 0,
      gy2 = 0;

  ShockWave.beam(
    this.gx,
    this.gy,
    this.gx2,
    this.gy2,
    this.color, {
    this.delay = 0.0,
  }) : kind = _WaveKind.beam,
       index = 0;

  final _WaveKind kind;
  final int index;
  final double gx;
  final double gy;
  final double gx2;
  final double gy2;
  final Color color;

  /// Optional stagger delay in seconds (used for hop-by-hop laser ricochets).
  double delay;
  double life = 1.0;
}

enum _WaveKind { row, col, ring, beam }

/// Animated 12-atmosphere background canvas with smooth 650ms theme cross-fade.
class AmbientBackdropPainter extends CustomPainter {
  const AmbientBackdropPainter({
    required this.palette,
    required this.phase,
    this.previousPalette,
    this.transitionT = 1.0,
  });

  final PrismPalette palette;
  final PrismPalette? previousPalette;
  final double transitionT;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = transitionT.clamp(0.0, 1.0);
    final prev = previousPalette;
    final hasPrevChange =
        prev != null &&
        t < 1.0 &&
        (prev.id != palette.id ||
            prev.backgroundGradient[0] != palette.backgroundGradient[0]);
    final List<Color> gradColors;
    if (hasPrevChange) {
      gradColors = <Color>[
        for (var i = 0; i < 3; i++)
          Color.lerp(
            prev.backgroundGradient[i % prev.backgroundGradient.length],
            palette.backgroundGradient[i % palette.backgroundGradient.length],
            t,
          )!,
      ];
    } else {
      gradColors = palette.backgroundGradient;
    }

    // Living gently breathing diagonal gradient angle.
    final sway = math.sin(phase * math.pi * 2) * 0.24;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1.0 + sway, -1.0),
          end: Alignment(1.0 - sway, 1.0),
          colors: gradColors,
        ).createShader(rect),
    );

    // Radiant drifting luminous bokeh color-blooms ("cıvıl cıvıl" glow!).
    final bloomColors = <Color>[
      palette.prismGold,
      palette.resonanceColor,
      palette.feverAccent,
    ];
    for (var b = 0; b < 3; b++) {
      final ang = phase * math.pi * 2 + b * 2.094;
      final cx = size.width * (0.2 + b * 0.3) + math.cos(ang) * 34;
      final cy = size.height * (0.18 + b * 0.28) + math.sin(ang * 0.8) * 28;
      final rad = size.width * (0.42 + (b % 2) * 0.14);
      final col = bloomColors[b];
      canvas.drawCircle(
        Offset(cx, cy),
        rad,
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              col.withValues(alpha: 0.24),
              col.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: rad)),
      );
    }

    if (hasPrevChange) {
      _paintAmbientStyle(canvas, size, prev.ambientStyle, 1.0 - t);
      _paintAmbientStyle(canvas, size, palette.ambientStyle, t);
    } else {
      _paintAmbientStyle(canvas, size, palette.ambientStyle, 1.0);
    }

    // Cheerful twinkling 4-point crystal confetti sparkles across every realm.
    for (var s = 0; s < 10; s++) {
      final sx = size.width * (((s * 0.197 + 0.07) % 0.9) + 0.05);
      final sy = size.height * (((s * 0.271 + 0.11) % 0.88) + 0.06);
      final pulse = 0.25 + 0.75 * math.sin(phase * math.pi * 4 + s * 1.1).abs();
      final r = (3.5 + (s % 3) * 1.8) * pulse;
      final sparklePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.34 * pulse);
      canvas.drawPath(
        Path()
          ..moveTo(sx, sy - r)
          ..lineTo(sx + r * 0.28, sy - r * 0.28)
          ..lineTo(sx + r, sy)
          ..lineTo(sx + r * 0.28, sy + r * 0.28)
          ..lineTo(sx, sy + r)
          ..lineTo(sx - r * 0.28, sy + r * 0.28)
          ..lineTo(sx - r, sy)
          ..lineTo(sx - r * 0.28, sy - r * 0.28)
          ..close(),
        sparklePaint,
      );
    }
  }

  void _paintAmbientStyle(
    Canvas canvas,
    Size size,
    PrismAmbientStyle style,
    double weight,
  ) {
    if (weight <= 0.01) return;
    switch (style) {
      case PrismAmbientStyle.sunBubbles:
        final rayPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.13 * weight);
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
            Paint()..color = Colors.white.withValues(alpha: 0.22 * weight),
          );
          canvas.drawCircle(
            Offset(bx - rad * 0.3, by - rad * 0.3),
            rad * 0.25,
            Paint()..color = Colors.white.withValues(alpha: 0.55 * weight),
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
            Colors.white.withValues(alpha: (0.35 + 0.35 * pulse) * weight),
          );
        }

      case PrismAmbientStyle.blossomPetals:
        final petalPaint = Paint()
          ..color = const Color(0xFFFFD1E6).withValues(alpha: 0.58 * weight);
        for (var i = 0; i < 12; i++) {
          final px =
              size.width * (((i * 0.19) % 0.9) + 0.05) +
              math.sin(phase * math.pi * 2 + i) * 16;
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
            Paint()..color = bokehColors[i % 3].withValues(alpha: 0.13 * weight),
          );
        }

      case PrismAmbientStyle.goldenEmbers:
        // Warm diagonal sun shafts + ascending golden dust motes.
        final beamPaint = Paint()
          ..color = const Color(0xFFFFF8C4).withValues(alpha: 0.16 * weight);
        for (var r = 0; r < 2; r++) {
          final shift = math.cos(phase * math.pi * 2 + r * 1.4) * 20;
          final x0 = size.width * (0.28 + r * 0.44) + shift;
          canvas.drawPath(
            Path()
              ..moveTo(x0, 0)
              ..lineTo(x0 + 75, 0)
              ..lineTo(x0 - 85, size.height)
              ..lineTo(x0 - 160, size.height)
              ..close(),
            beamPaint,
          );
        }
        for (var i = 0; i < 15; i++) {
          final ex =
              size.width * (((i * 0.163) % 0.90) + 0.05) +
              math.sin(phase * math.pi * 2 + i * 0.9) * 12;
          final ey =
              size.height -
              ((phase * size.height * 0.85 + i * 64.0) % (size.height + 30)) +
              15;
          final rad = 2.6 + (i % 3) * 1.8;
          canvas.drawCircle(
            Offset(ex, ey),
            rad,
            Paint()
              ..color = const Color(0xFFFFF3A0).withValues(alpha: 0.65 * weight),
          );
        }

      case PrismAmbientStyle.auroraRibbons:
        // Translucent flowing emerald & cyan northern-lights curtains.
        const ribbonColors = <Color>[Color(0xFF2BF5B4), Color(0xFF00E5FF)];
        for (var r = 0; r < 2; r++) {
          final baseY = size.height * (0.24 + r * 0.28);
          final path = Path()..moveTo(0, baseY);
          final cp1Y =
              baseY + math.sin(phase * math.pi * 2 + r * 1.5) * 44 - 20;
          final cp2Y =
              baseY + math.cos(phase * math.pi * 2 + r * 1.2) * 44 + 14;
          path.cubicTo(
            size.width * 0.33,
            cp1Y,
            size.width * 0.67,
            cp2Y,
            size.width,
            baseY - 12,
          );
          path.lineTo(size.width, baseY + 66);
          path.cubicTo(
            size.width * 0.67,
            cp2Y + 62,
            size.width * 0.33,
            cp1Y + 62,
            0,
            baseY + 56,
          );
          path.close();
          canvas.drawPath(
            path,
            Paint()..color = ribbonColors[r].withValues(alpha: 0.16 * weight),
          );
        }
        for (var i = 0; i < 10; i++) {
          final sx = size.width * (((i * 0.21) % 0.92) + 0.04);
          final sy = size.height * (((i * 0.13) % 0.72) + 0.05);
          final tw = 0.4 + 0.6 * math.sin(phase * math.pi * 2 + i * 1.3).abs();
          canvas.drawCircle(
            Offset(sx, sy),
            1.8 + (i % 2) * 1.2,
            Paint()..color = Colors.white.withValues(alpha: 0.45 * tw * weight),
          );
        }

      case PrismAmbientStyle.frostCrystals:
        final stroke = Paint()
          ..color = Colors.white.withValues(alpha: 0.58 * weight)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 10; i++) {
          final cx =
              size.width * (((i * 0.193) % 0.90) + 0.05) +
              math.sin(phase * math.pi * 2 + i) * 10;
          final cy =
              ((phase * size.height * 0.65 + i * 82.0) % (size.height + 30)) -
              15;
          final r = 5.5 + (i % 3) * 2.8;
          final rot = phase * math.pi + i * 0.6;
          for (var k = 0; k < 3; k++) {
            final a = rot + (math.pi * k) / 3.0;
            canvas.drawLine(
              Offset(cx - math.cos(a) * r, cy - math.sin(a) * r),
              Offset(cx + math.cos(a) * r, cy + math.sin(a) * r),
              stroke,
            );
          }
        }

      case PrismAmbientStyle.biolumeMotes:
        const reefColors = <Color>[Color(0xFF00F5D4), Color(0xFFFF5EC4)];
        for (var i = 0; i < 14; i++) {
          final mx =
              size.width * (((i * 0.181) % 0.90) + 0.05) +
              math.sin(phase * math.pi * 2 + i * 0.8) * 14;
          final my =
              size.height * (((i * 0.137) % 0.90) + 0.05) +
              math.cos(phase * math.pi * 2 + i * 1.1) * 12;
          final glow = 0.5 + 0.5 * math.sin(phase * math.pi * 2 + i * 1.7);
          final col = reefColors[i % 2];
          canvas.drawCircle(
            Offset(mx, my),
            11.0 + glow * 8.0,
            Paint()..color = col.withValues(alpha: 0.12 * glow * weight),
          );
          canvas.drawCircle(
            Offset(mx, my),
            3.0 + (i % 3),
            Paint()..color = col.withValues(alpha: 0.65 * weight),
          );
        }

      case PrismAmbientStyle.fireflySparks:
        for (var i = 0; i < 14; i++) {
          final t = phase * math.pi * 2 + i * 0.95;
          final fx = size.width * (((i * 0.17) % 0.86) + 0.07) + math.sin(t) * 22;
          final fy =
              size.height * (((i * 0.19) % 0.86) + 0.07) + math.sin(t * 2) * 14;
          final pulse = 0.35 + 0.65 * math.sin(t * 1.5).abs();
          canvas.drawCircle(
            Offset(fx, fy),
            9.5 * pulse,
            Paint()
              ..color = const Color(0xFFD9FF66)
                  .withValues(alpha: 0.18 * pulse * weight),
          );
          canvas.drawCircle(
            Offset(fx, fy),
            2.6,
            Paint()
              ..color = const Color(0xFFFFF59D)
                  .withValues(alpha: 0.82 * pulse * weight),
          );
        }

      case PrismAmbientStyle.prismRain:
        const rainColors = <Color>[
          Color(0xFFE066FF),
          Color(0xFF00F0FF),
          Color(0xFFFFE44D),
        ];
        for (var i = 0; i < 12; i++) {
          final progress = (phase * 1.4 + i * 0.17) % 1.0;
          final x0 = size.width * (((i * 0.213) % 0.94) + 0.03);
          final y0 = -40.0 + progress * (size.height + 90.0);
          canvas.drawLine(
            Offset(x0, y0),
            Offset(x0 - 18, y0 + 46),
            Paint()
              ..color = rainColors[i % 3].withValues(alpha: 0.34 * weight)
              ..strokeWidth = 2.4
              ..strokeCap = StrokeCap.round,
          );
        }

      case PrismAmbientStyle.forgeSparks:
        const emberColors = <Color>[Color(0xFFFF8A5B), Color(0xFFFFE54D)];
        for (var i = 0; i < 16; i++) {
          final prog = (phase * 1.2 + i * 0.13) % 1.0;
          final ex =
              size.width * (((i * 0.157) % 0.90) + 0.05) +
              math.sin(prog * math.pi * 3 + i) * 14;
          final ey = size.height * (1.05 - prog * 1.12);
          final fade = math.sin(prog * math.pi).clamp(0.0, 1.0);
          canvas.drawCircle(
            Offset(ex, ey),
            2.2 + (i % 3) * 1.1,
            Paint()
              ..color = emberColors[i % 2].withValues(alpha: 0.78 * fade * weight),
          );
        }

      case PrismAmbientStyle.stardustNebula:
        // Soft astral nebula clouds + twinkling 4-point constellation stars.
        const nebColors = <Color>[Color(0xFFC77DFF), Color(0xFF00F0FF)];
        for (var n = 0; n < 3; n++) {
          final nx = size.width * (0.2 + n * 0.32);
          final ny =
              size.height * (0.22 + (n % 2) * 0.44) +
              math.sin(phase * math.pi * 2 + n) * 12;
          canvas.drawCircle(
            Offset(nx, ny),
            64.0 + n * 16.0,
            Paint()..color = nebColors[n % 2].withValues(alpha: 0.10 * weight),
          );
        }
        for (var i = 0; i < 16; i++) {
          final sx = size.width * (((i * 0.197) % 0.92) + 0.04);
          final sy = size.height * (((i * 0.131) % 0.90) + 0.05);
          final tw = 0.4 + 0.6 * math.sin(phase * math.pi * 2 + i * 1.4).abs();
          _draw4PointStar(
            canvas,
            Offset(sx, sy),
            (3.4 + (i % 3) * 2.2) * tw,
            (i % 3 == 0 ? const Color(0xFFFFF066) : Colors.white).withValues(
              alpha: 0.75 * tw * weight,
            ),
          );
        }
    }
  }

  @override
  bool shouldRepaint(covariant AmbientBackdropPainter oldDelegate) =>
      oldDelegate.palette.id != palette.id ||
      oldDelegate.previousPalette?.id != previousPalette?.id ||
      oldDelegate.transitionT != transitionT ||
      oldDelegate.phase != phase;
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

/// Shared jelly-crystal gem block drawing helper for board & tray pieces,
/// with optional damped-spring scale pop & periodic diagonal glass shimmer.
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
  double scale = 1.0,
  double shimmerOffset = -1.0,
}) {
  final bool scaled = (scale - 1.0).abs() > 0.002;
  if (scaled) {
    canvas.save();
    canvas.translate(cellRect.center.dx, cellRect.center.dy);
    canvas.scale(scale, scale);
    canvas.translate(-cellRect.center.dx, -cellRect.center.dy);
  }

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
    if (scaled) canvas.restore();
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

  // 3b. Periodic diagonal glass specular glint wave across the gem mosaic.
  if (shimmerOffset >= 0.0 && shimmerOffset <= 1.0) {
    final sheenAlpha = math.sin(shimmerOffset * math.pi) * 0.24 * opacity;
    if (sheenAlpha > 0.01) {
      canvas.save();
      canvas.clipRRect(rrect);
      final sx = rect.left - rect.width * 0.4 + shimmerOffset * rect.width * 1.8;
      canvas.drawLine(
        Offset(sx, rect.top - 4),
        Offset(sx - rect.width * 0.45, rect.bottom + 4),
        Paint()
          ..color = Colors.white.withValues(alpha: sheenAlpha)
          ..strokeWidth = rect.width * 0.26,
      );
      canvas.restore();
    }
  }

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

  if (scaled) {
    canvas.restore();
  }
}

/// Renders the 8x8 PRISM FORGE board, per-cell spring bounce, stained-glass sheen,
/// pre-drop 2x2 Synthesis & ★→★ Laser preview, faceted shards & staggered beams.
class PrismBoardPainter extends CustomPainter {
  const PrismBoardPainter({
    required this.grid,
    required this.palette,
    required this.phase,
    required this.particles,
    required this.waves,
    this.cellPopProgress = const <GridPoint, double>{},
    this.reducedMotion = false,
    this.hoverPiece,
    this.preview,
    this.novaMode = false,
    this.novaHover,
    this.isFever = false,
  });

  final List<List<BoardCell?>> grid;
  final PrismPalette palette;
  final double phase;
  final List<ShardParticle> particles;
  final List<ShockWave> waves;
  final Map<GridPoint, double> cellPopProgress;
  final bool reducedMotion;
  final PrismPiece? hoverPiece;
  final PlacementPreview? preview;
  final bool novaMode;
  final GridPoint? novaHover;
  final bool isFever;

  static const double boardPadding = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = (size.width - boardPadding * 2) / PrismEngine.gridSize;
    final outerRRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );

    // 1. Jewel-toned board well + luminous rim (rotating Rainbow Fever aura when streak >= 3!).
    canvas.drawRRect(outerRRect, Paint()..color = palette.boardBackground);
    if (isFever) {
      canvas.drawRRect(
        outerRRect.deflate(1.5),
        Paint()
          ..shader = SweepGradient(
            colors: <Color>[
              palette.feverAccent,
              const Color(0xFFFF38B8),
              palette.prismGold,
              const Color(0xFF34E870),
              palette.resonanceColor,
              palette.feverAccent,
            ],
            transform: GradientRotation(phase * math.pi * 2),
          ).createShader(Offset.zero & size)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
      );
    } else {
      canvas.drawRRect(
        outerRRect.deflate(1),
        Paint()
          ..color = palette.boardBorderGlow.withValues(alpha: 0.60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

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

    // 4. Placed crystal blocks with damped-spring bounce + diagonal glass sheen.
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

        var cellScale = 1.0;
        if (!reducedMotion) {
          final popT = cellPopProgress[GridPoint(x, y)];
          if (popT != null && popT < 1.0) {
            cellScale =
                1.0 - 0.38 * math.exp(-7.5 * popT) * math.cos(popT * math.pi * 2.4);
          }
        }

        var shimmer = -1.0;
        if (!reducedMotion) {
          final wave = ((phase * 1.8 - (x + y) * 0.045) % 1.0 + 1.0) % 1.0;
          if (wave < 0.14) {
            shimmer = wave / 0.14;
          }
        }

        paintCrystalGem(
          canvas: canvas,
          cellRect: rect,
          ramp: palette.gemFor(cell.colorIndex),
          isPrismCore: cell.isPrismCore,
          frostHits: cell.frostHits,
          isLocked: cell.isLocked,
          isWildcard: cell.isWildcard,
          pulsePhase: phase,
          scale: cellScale,
          shimmerOffset: shimmer,
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

    // 7. Shockwaves, Double Concentric Rings & Staggered Optical Laser Beams.
    for (final w in waves) {
      if (w.delay > 0.0) continue;
      final alpha = (w.life * 0.82).clamp(0.0, 1.0).toDouble();
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
        final p2Full = Offset(
          boardPadding + w.gx2 * cellSize,
          boardPadding + w.gy2 * cellSize,
        );
        // First 26% of lifetime extends the beam head swiftly from p1 -> p2!
        final headT = ((1.0 - w.life) / 0.26).clamp(0.0, 1.0);
        final p2 = Offset.lerp(p1, p2Full, Curves.easeOutCubic.transform(headT))!;
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = w.color.withValues(alpha: alpha)
            ..strokeWidth = 11.0 * w.life
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = Colors.white.withValues(alpha: alpha)
            ..strokeWidth = 3.2 * w.life
            ..strokeCap = StrokeCap.round,
        );
        _draw4PointStar(
          canvas,
          p2,
          cellSize * 0.36 * w.life,
          Colors.white.withValues(alpha: alpha),
        );
      } else {
        final eased = 1.0 - math.pow(w.life, 3.0).toDouble();
        final radius = eased * cellSize * 3.6;
        final center = Offset(
          boardPadding + w.gx * cellSize,
          boardPadding + w.gy * cellSize,
        );
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = w.color.withValues(alpha: alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.4 * w.life,
        );
        canvas.drawCircle(
          center,
          radius * 0.68,
          Paint()
            ..color = Colors.white.withValues(alpha: alpha * 0.72)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 * w.life,
        );
      }
    }

    // 8. Confetti-star & faceted crystal diamond shard particles.
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
          s * 0.88,
          p.color.withValues(alpha: alpha),
        );
        _draw4PointStar(
          canvas,
          Offset.zero,
          s * 0.42,
          Colors.white.withValues(alpha: alpha),
        );
      } else {
        final diamond = Path()
          ..moveTo(0, -s * 0.85)
          ..lineTo(s * 0.48, 0)
          ..lineTo(0, s * 0.85)
          ..lineTo(-s * 0.48, 0)
          ..close();
        canvas.drawPath(diamond, Paint()..color = p.color.withValues(alpha: alpha));
        canvas.drawPath(
          diamond,
          Paint()
            ..color = Colors.white.withValues(alpha: alpha * 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
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
