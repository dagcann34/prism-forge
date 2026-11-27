/// Non-blocking crystalline Stage Intro & Realm Evolution showcase banner.
///
/// Slides & scales in with an `easeOutBack` spring, sweeps a diagonal glass
/// specular shimmer across the card, displays the unique stage name, poetic
/// lore subtitle, and dazzling theme gradient badge, then fades smoothly out.
library;

import 'dart:math' as math;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../../theme/prism_themes.dart';

class StageIntroPayload {
  const StageIntroPayload({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.sequenceId,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final PrismPalette palette;
  final int sequenceId;
}

class StageIntroBanner extends StatelessWidget {
  const StageIntroBanner({
    super.key,
    required this.payload,
    required this.locale,
    required this.progress,
    required this.reducedMotion,
  });

  final StageIntroPayload payload;
  final AppLocale locale;

  /// Normalized 0.0 -> 1.0 lifecycle progress (~1950ms total).
  final double progress;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final p = payload.palette;
    final t = progress.clamp(0.0, 1.0);

    double opacity;
    double scale;
    double dy;
    if (reducedMotion) {
      opacity = t < 0.82 ? 1.0 : ((1.0 - t) / 0.18).clamp(0.0, 1.0);
      scale = 1.0;
      dy = 0.0;
    } else if (t < 0.20) {
      final u = Curves.easeOutBack.transform((t / 0.20).clamp(0.0, 1.0));
      opacity = (t / 0.14).clamp(0.0, 1.0);
      scale = 0.86 + 0.14 * u;
      dy = -18.0 * (1.0 - u);
    } else if (t > 0.80) {
      final u = Curves.easeInCubic.transform(((t - 0.80) / 0.20).clamp(0.0, 1.0));
      opacity = 1.0 - u;
      scale = 1.0 + 0.02 * u;
      dy = -10.0 * u;
    } else {
      opacity = 1.0;
      scale = 1.0;
      dy = 0.0;
    }

    // Diagonal glass specular sweep between 18% and 62% of the banner lifecycle.
    final shimmerT = ((t - 0.18) / 0.44).clamp(0.0, 1.0);
    final showShimmer = !reducedMotion && t >= 0.18 && t <= 0.62;

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
                    decoration: BoxDecoration(
                      color: p.boardBackground.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: p.boardBorderGlow.withValues(alpha: 0.92),
                        width: 1.8,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: p.boardBorderGlow.withValues(alpha: 0.34),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Top 4px luminous theme gradient crest.
                        Container(
                          width: 68,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: LinearGradient(
                              colors: p.backgroundGradient,
                            ),
                          ),
                        ),
                        Text(
                          payload.eyebrow,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.prismGold,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          payload.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          payload.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.84),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: LinearGradient(
                              colors: p.backgroundGradient,
                            ),
                          ),
                          child: Text(
                            '${p.badgeEmoji} ${p.fullName.resolve(locale)}',
                            style: TextStyle(
                              color: p.brightness == Brightness.dark
                                  ? Colors.white
                                  : p.ink,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showShimmer)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GlassShimmerPainter(progress: shimmerT),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassShimmerPainter extends CustomPainter {
  const _GlassShimmerPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final sweepX = -size.width * 0.45 + progress * size.width * 1.9;
    final bandW = size.width * 0.34;
    canvas.save();
    canvas.translate(sweepX, 0);
    canvas.skew(-0.35, 0);
    final rect = Rect.fromLTWH(0, -20, bandW, size.height + 40);
    final alpha = math.sin(progress * math.pi).clamp(0.0, 1.0) * 0.36;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: alpha),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlassShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
