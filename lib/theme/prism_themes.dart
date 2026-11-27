/// Four radiant, joyful ("cıvıl cıvıl") architectural art themes for PRISM FORGE:
/// 1. Tropik Mercan / Coral Lagoon (sunlit turquoise, coral & rising bubbles)
/// 2. Şeker Vitray / Candy Prism (stained-glass candy pastel & twinkling stars)
/// 3. Bahar Bahçesi / Blossom Garden (spring meadow & cherry-blossom petals)
/// 4. Karnaval Neon / Neon Carnival (vibrant royal-violet festival glow)
library;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../engine/models.dart';

enum PrismAmbientStyle {
  sunBubbles,
  candySparkles,
  blossomPetals,
  carnivalBokeh,
}

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
    required this.brightness,
    required this.backgroundGradient,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.boardBackground,
    required this.boardBorderGlow,
    required this.cellBackground,
    required this.cellAltTint,
    required this.cellBorder,
    required this.ink,
    required this.mutedInk,
    required this.accent,
    required this.accentInk,
    required this.resonanceColor,
    required this.prismGold,
    required this.ambientStyle,
    required this.gemRamps,
  });

  final PrismThemeId id;
  final LocalizedText name;
  final Brightness brightness;
  final List<Color> backgroundGradient;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color boardBackground;
  final Color boardBorderGlow;
  final Color cellBackground;
  final Color cellAltTint;
  final Color cellBorder;
  final Color ink;
  final Color mutedInk;
  final Color accent;
  final Color accentInk;
  final Color resonanceColor;
  final Color prismGold;
  final PrismAmbientStyle ambientStyle;
  final List<GemColorRamp> gemRamps;

  GemColorRamp gemFor(int colorIndex) => gemRamps[colorIndex % gemRamps.length];

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: brightness,
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

  /// Theme 1 (Default): Tropik Mercan / Coral Lagoon
  static const PrismPalette ceramic = PrismPalette(
    id: PrismThemeId.ceramic,
    name: LocalizedText(tr: 'Tropik', en: 'Coral'),
    brightness: Brightness.light,
    backgroundGradient: <Color>[
      Color(0xFF38E4FF),
      Color(0xFF56F0C8),
      Color(0xFFFFF3B0),
    ],
    background: Color(0xFF48E5DC),
    surface: Color(0xF5F7FFFE),
    surfaceElevated: Color(0xFFDFFCF7),
    boardBackground: Color(0xFF0D4F6B),
    boardBorderGlow: Color(0xFF80F7FF),
    cellBackground: Color(0xFF136685),
    cellAltTint: Color(0xFF1B7799),
    cellBorder: Color(0x4D5CEEFF),
    ink: Color(0xFF0B3547),
    mutedInk: Color(0xFF2D6A80),
    accent: Color(0xFFFF5277),
    accentInk: Color(0xFFFFFFFF),
    resonanceColor: Color(0xFFFFD60A),
    prismGold: Color(0xFFFFE14D),
    ambientStyle: PrismAmbientStyle.sunBubbles,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFFF4D79),
        highlight: Color(0xFFFFB8CB),
        shadow: Color(0xFFC4194A),
      ),
      GemColorRamp(
        main: Color(0xFFFF9F1C),
        highlight: Color(0xFFFFE38C),
        shadow: Color(0xFFD16500),
      ),
      GemColorRamp(
        main: Color(0xFF00D4FF),
        highlight: Color(0xFFBDF4FF),
        shadow: Color(0xFF0084B8),
      ),
      GemColorRamp(
        main: Color(0xFF34E870),
        highlight: Color(0xFFBDFFD4),
        shadow: Color(0xFF109E44),
      ),
      GemColorRamp(
        main: Color(0xFFB55CFF),
        highlight: Color(0xFFE9C9FF),
        shadow: Color(0xFF7829BD),
      ),
      GemColorRamp(
        main: Color(0xFFFFE22B),
        highlight: Color(0xFFFFF9BD),
        shadow: Color(0xFFCFA000),
      ),
    ],
  );

  /// Theme 2: Şeker Vitray / Candy Prism
  static const PrismPalette atelier = PrismPalette(
    id: PrismThemeId.atelier,
    name: LocalizedText(tr: 'Şeker', en: 'Candy'),
    brightness: Brightness.light,
    backgroundGradient: <Color>[
      Color(0xFFFF85C0),
      Color(0xFFFFB86C),
      Color(0xFFFFE680),
    ],
    background: Color(0xFFFF9EC7),
    surface: Color(0xF5FFF9FC),
    surfaceElevated: Color(0xFFFFEAF4),
    boardBackground: Color(0xFF3A195C),
    boardBorderGlow: Color(0xFFFFB3DA),
    cellBackground: Color(0xFF4E247A),
    cellAltTint: Color(0xFF5C2C8F),
    cellBorder: Color(0x52FF9EC7),
    ink: Color(0xFF35144F),
    mutedInk: Color(0xFF7B4B9C),
    accent: Color(0xFFFF3B9A),
    accentInk: Color(0xFFFFFFFF),
    resonanceColor: Color(0xFF00E5FF),
    prismGold: Color(0xFFFFD93D),
    ambientStyle: PrismAmbientStyle.candySparkles,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFFF3B9A),
        highlight: Color(0xFFFFB8DD),
        shadow: Color(0xFFC4126B),
      ),
      GemColorRamp(
        main: Color(0xFF18D6FF),
        highlight: Color(0xFFB8F2FF),
        shadow: Color(0xFF008CB8),
      ),
      GemColorRamp(
        main: Color(0xFFFF7A29),
        highlight: Color(0xFFFFD1AB),
        shadow: Color(0xFFCC4400),
      ),
      GemColorRamp(
        main: Color(0xFF43E85A),
        highlight: Color(0xFFC4FFCC),
        shadow: Color(0xFF169C2C),
      ),
      GemColorRamp(
        main: Color(0xFFFFD829),
        highlight: Color(0xFFFFF6B8),
        shadow: Color(0xFFCF9500),
      ),
      GemColorRamp(
        main: Color(0xFF9B5BFF),
        highlight: Color(0xFFE1C7FF),
        shadow: Color(0xFF6122C9),
      ),
    ],
  );

  /// Theme 3: Bahar Bahçesi / Blossom Garden
  static const PrismPalette aurora = PrismPalette(
    id: PrismThemeId.aurora,
    name: LocalizedText(tr: 'Bahar', en: 'Blossom'),
    brightness: Brightness.light,
    backgroundGradient: <Color>[
      Color(0xFF74EBD5),
      Color(0xFF9FACE6),
      Color(0xFFFFD6E8),
    ],
    background: Color(0xFF8CE6D8),
    surface: Color(0xF5F7FFFA),
    surfaceElevated: Color(0xFFE5FAEE),
    boardBackground: Color(0xFF124E41),
    boardBorderGlow: Color(0xFF9EF5D8),
    cellBackground: Color(0xFF1A6655),
    cellAltTint: Color(0xFF227865),
    cellBorder: Color(0x4DA7F3D0),
    ink: Color(0xFF0E3B31),
    mutedInk: Color(0xFF357364),
    accent: Color(0xFF10C98F),
    accentInk: Color(0xFFFFFFFF),
    resonanceColor: Color(0xFFFF6B9D),
    prismGold: Color(0xFFFFD93D),
    ambientStyle: PrismAmbientStyle.blossomPetals,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFFF5C93),
        highlight: Color(0xFFFFC4DC),
        shadow: Color(0xFFC92461),
      ),
      GemColorRamp(
        main: Color(0xFFFFCB1F),
        highlight: Color(0xFFFFF4AD),
        shadow: Color(0xFFC98A00),
      ),
      GemColorRamp(
        main: Color(0xFF29B6FF),
        highlight: Color(0xFFBFEAFF),
        shadow: Color(0xFF0076BA),
      ),
      GemColorRamp(
        main: Color(0xFF4EE665),
        highlight: Color(0xFFCAFFD2),
        shadow: Color(0xFF1AA133),
      ),
      GemColorRamp(
        main: Color(0xFFA86BFF),
        highlight: Color(0xFFE6CFFF),
        shadow: Color(0xFF6B2DC7),
      ),
      GemColorRamp(
        main: Color(0xFFFF8243),
        highlight: Color(0xFFFFD4BC),
        shadow: Color(0xFFCC4C14),
      ),
    ],
  );

  /// Theme 4: Karnaval Neon / Neon Carnival
  static const PrismPalette obsidian = PrismPalette(
    id: PrismThemeId.obsidian,
    name: LocalizedText(tr: 'Karnaval', en: 'Carnival'),
    brightness: Brightness.dark,
    backgroundGradient: <Color>[
      Color(0xFF231157),
      Color(0xFF4B1D8C),
      Color(0xFF9E1F7B),
    ],
    background: Color(0xFF2B1463),
    surface: Color(0xEB3A1E7D),
    surfaceElevated: Color(0xFF4E2BA3),
    boardBackground: Color(0xFF1C0E45),
    boardBorderGlow: Color(0xFF00F0FF),
    cellBackground: Color(0xFF2A1763),
    cellAltTint: Color(0xFF351F7A),
    cellBorder: Color(0x5CA855F7),
    ink: Color(0xFFFFFFFF),
    mutedInk: Color(0xFFD8C4FF),
    accent: Color(0xFF00F0FF),
    accentInk: Color(0xFF1C0E45),
    resonanceColor: Color(0xFFFF4DFF),
    prismGold: Color(0xFFFFE438),
    ambientStyle: PrismAmbientStyle.carnivalBokeh,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFF00E5FF),
        highlight: Color(0xFFC2FAFF),
        shadow: Color(0xFF008EB8),
      ),
      GemColorRamp(
        main: Color(0xFFFF38B8),
        highlight: Color(0xFFFFBCEB),
        shadow: Color(0xFFBD0F7D),
      ),
      GemColorRamp(
        main: Color(0xFFFFE424),
        highlight: Color(0xFFFFF8B8),
        shadow: Color(0xFFC99700),
      ),
      GemColorRamp(
        main: Color(0xFF25F495),
        highlight: Color(0xFFB8FFE2),
        shadow: Color(0xFF00A85E),
      ),
      GemColorRamp(
        main: Color(0xFFFF7326),
        highlight: Color(0xFFFFCCA8),
        shadow: Color(0xFFC43E00),
      ),
      GemColorRamp(
        main: Color(0xFF9D6BFF),
        highlight: Color(0xFFE2CFFF),
        shadow: Color(0xFF5E28D6),
      ),
    ],
  );

  static PrismPalette of(PrismThemeId id) {
    switch (id) {
      case PrismThemeId.ceramic:
        return ceramic;
      case PrismThemeId.atelier:
        return atelier;
      case PrismThemeId.aurora:
        return aurora;
      case PrismThemeId.obsidian:
        return obsidian;
    }
  }
}
