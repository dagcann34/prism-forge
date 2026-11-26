/// Four handcrafted architectural color palettes for PRISM FORGE:
/// Obsidian Neon, Mediterranean Ceramic, Nordic Aurora, and Gilded Atelier.
library;

import 'package:flutter/material.dart';

import '../engine/models.dart';

class GemColorRamp {
  const GemColorRamp({
    required this.main,
    required this.highlight,
    required this.shadow,
  });

  final Color main;
  final Color highlight;
  final Color shadow;
}

class PrismPalette {
  const PrismPalette({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.boardBackground,
    required this.cellBackground,
    required this.cellBorder,
    required this.ink,
    required this.mutedInk,
    required this.accent,
    required this.resonanceColor,
    required this.prismGold,
    required this.gemRamps,
  });

  final PrismThemeId id;
  final LocalizedText name;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color boardBackground;
  final Color cellBackground;
  final Color cellBorder;
  final Color ink;
  final Color mutedInk;
  final Color accent;
  final Color resonanceColor;
  final Color prismGold;
  final List<GemColorRamp> gemRamps;

  GemColorRamp gemFor(int colorIndex) => gemRamps[colorIndex % gemRamps.length];

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: resonanceColor,
        onSurface: ink,
      ),
    );
  }
}

class PrismThemes {
  const PrismThemes._();

  static const PrismPalette obsidian = PrismPalette(
    id: PrismThemeId.obsidian,
    name: LocalizedText(tr: 'Obsidyen', en: 'Obsidian'),
    background: Color(0xFF070B16),
    surface: Color(0xFF10182C),
    surfaceElevated: Color(0xFF192542),
    boardBackground: Color(0xFF0C1224),
    cellBackground: Color(0xFF15203A),
    cellBorder: Color(0x2894A3B8),
    ink: Color(0xFFF8FAFC),
    mutedInk: Color(0xFF94A3B8),
    accent: Color(0xFF38BDF8),
    resonanceColor: Color(0xFFF472B6),
    prismGold: Color(0xFFFACC15),
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFF38BDF8),
        highlight: Color(0xFFBAE6FD),
        shadow: Color(0xFF0284C7),
      ),
      GemColorRamp(
        main: Color(0xFFF472B6),
        highlight: Color(0xFFFBCFE8),
        shadow: Color(0xFFBE185D),
      ),
      GemColorRamp(
        main: Color(0xFFA78BFA),
        highlight: Color(0xFFDDD6FE),
        shadow: Color(0xFF6D28D9),
      ),
      GemColorRamp(
        main: Color(0xFF34D399),
        highlight: Color(0xFFA7F3D0),
        shadow: Color(0xFF059669),
      ),
      GemColorRamp(
        main: Color(0xFFFBBF24),
        highlight: Color(0xFFFEF08A),
        shadow: Color(0xFFB45309),
      ),
      GemColorRamp(
        main: Color(0xFFFB7185),
        highlight: Color(0xFFFECDD3),
        shadow: Color(0xFFBE123C),
      ),
    ],
  );

  static const PrismPalette ceramic = PrismPalette(
    id: PrismThemeId.ceramic,
    name: LocalizedText(tr: 'Seramik', en: 'Ceramic'),
    background: Color(0xFF0E181E),
    surface: Color(0xFF17262F),
    surfaceElevated: Color(0xFF213643),
    boardBackground: Color(0xFF132028),
    cellBackground: Color(0xFF1D303B),
    cellBorder: Color(0x24F5F0E6),
    ink: Color(0xFFFAF6EE),
    mutedInk: Color(0xFFA9BAC4),
    accent: Color(0xFF14B8A6),
    resonanceColor: Color(0xFFEA580C),
    prismGold: Color(0xFFFACC15),
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFF0EA5E9),
        highlight: Color(0xFF7DD3FC),
        shadow: Color(0xFF0369A1),
      ),
      GemColorRamp(
        main: Color(0xFFEA580C),
        highlight: Color(0xFFFDBA74),
        shadow: Color(0xFF9A3412),
      ),
      GemColorRamp(
        main: Color(0xFF14B8A6),
        highlight: Color(0xFF99F6E4),
        shadow: Color(0xFF0F766E),
      ),
      GemColorRamp(
        main: Color(0xFFEAB308),
        highlight: Color(0xFFFEF08A),
        shadow: Color(0xFFA16207),
      ),
      GemColorRamp(
        main: Color(0xFF6366F1),
        highlight: Color(0xFFC7D2FE),
        shadow: Color(0xFF3730A3),
      ),
      GemColorRamp(
        main: Color(0xFFEC4899),
        highlight: Color(0xFFF9A8D4),
        shadow: Color(0xFF9D174D),
      ),
    ],
  );

  static const PrismPalette aurora = PrismPalette(
    id: PrismThemeId.aurora,
    name: LocalizedText(tr: 'Kuzey', en: 'Aurora'),
    background: Color(0xFF061218),
    surface: Color(0xFF0D212B),
    surfaceElevated: Color(0xFF163240),
    boardBackground: Color(0xFF091A22),
    cellBackground: Color(0xFF112A36),
    cellBorder: Color(0x285EEAD4),
    ink: Color(0xFFF0FDFA),
    mutedInk: Color(0xFF8FB8BF),
    accent: Color(0xFF2DD4BF),
    resonanceColor: Color(0xFF818CF8),
    prismGold: Color(0xFFFACC15),
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFF2DD4BF),
        highlight: Color(0xFFCCFBF1),
        shadow: Color(0xFF0F766E),
      ),
      GemColorRamp(
        main: Color(0xFF818CF8),
        highlight: Color(0xFFE0E7FF),
        shadow: Color(0xFF4338CA),
      ),
      GemColorRamp(
        main: Color(0xFF4ADE80),
        highlight: Color(0xFFDCFCE7),
        shadow: Color(0xFF15803D),
      ),
      GemColorRamp(
        main: Color(0xFFF472B6),
        highlight: Color(0xFFFCE7F3),
        shadow: Color(0xFFBE185D),
      ),
      GemColorRamp(
        main: Color(0xFF38BDF8),
        highlight: Color(0xFFE0F2FE),
        shadow: Color(0xFF0369A1),
      ),
      GemColorRamp(
        main: Color(0xFFFACC15),
        highlight: Color(0xFFFEF9C3),
        shadow: Color(0xFFA16207),
      ),
    ],
  );

  static const PrismPalette atelier = PrismPalette(
    id: PrismThemeId.atelier,
    name: LocalizedText(tr: 'Atölye', en: 'Atelier'),
    background: Color(0xFF130E0C),
    surface: Color(0xFF211915),
    surfaceElevated: Color(0xFF30241E),
    boardBackground: Color(0xFF1B1512),
    cellBackground: Color(0xFF2A211C),
    cellBorder: Color(0x2AFBBF24),
    ink: Color(0xFFFEF8F0),
    mutedInk: Color(0xFFC2AFA2),
    accent: Color(0xFFF59E0B),
    resonanceColor: Color(0xFFD946EF),
    prismGold: Color(0xFFFDE047),
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFF59E0B),
        highlight: Color(0xFFFDE68A),
        shadow: Color(0xFFB45309),
      ),
      GemColorRamp(
        main: Color(0xFFEF4444),
        highlight: Color(0xFFFCA5A5),
        shadow: Color(0xFF991B1B),
      ),
      GemColorRamp(
        main: Color(0xFF10B981),
        highlight: Color(0xFFA7F3D0),
        shadow: Color(0xFF047857),
      ),
      GemColorRamp(
        main: Color(0xFF3B82F6),
        highlight: Color(0xFFBFDBFE),
        shadow: Color(0xFF1D4ED8),
      ),
      GemColorRamp(
        main: Color(0xFFD946EF),
        highlight: Color(0xFFF5D0FE),
        shadow: Color(0xFF86198F),
      ),
      GemColorRamp(
        main: Color(0xFF06B6D4),
        highlight: Color(0xFFA5F3FC),
        shadow: Color(0xFF0E7490),
      ),
    ],
  );

  static PrismPalette of(PrismThemeId id) {
    switch (id) {
      case PrismThemeId.obsidian:
        return obsidian;
      case PrismThemeId.ceramic:
        return ceramic;
      case PrismThemeId.aurora:
        return aurora;
      case PrismThemeId.atelier:
        return atelier;
    }
  }
}
