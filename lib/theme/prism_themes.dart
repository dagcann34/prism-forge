/// Twelve dazzling, museum-grade glass & crystal art themes for PRISM FORGE:
/// 1. Tropik Mercan / Coral Lagoon
/// 2. Şeker Vitray / Candy Prism
/// 3. Bahar Bahçesi / Sakura Blossom
/// 4. Karnaval Neon / Neon Carnival
/// 5. Altın Şafak / Solar Amber
/// 6. Kuzey Işığı / Polar Aurora
/// 7. Buzul Kristali / Glacier Quartz
/// 8. Derin Mercan / Biolume Reef
/// 9. Zümrüt Orman / Emerald Canopy
/// 10. Ametist Vitray / Amethyst Cathedral
/// 11. Yakut Ocak / Crimson Forge
/// 12. Göksel Prizma / Celestial Nebula
library;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../engine/models.dart';

enum PrismAmbientStyle {
  sunBubbles,
  candySparkles,
  blossomPetals,
  carnivalBokeh,
  goldenEmbers,
  auroraRibbons,
  frostCrystals,
  biolumeMotes,
  fireflySparks,
  prismRain,
  forgeSparks,
  stardustNebula,
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
    required this.fullName,
    required this.badgeEmoji,
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
    required this.feverAccent,
    required this.ambientStyle,
    required this.gemRamps,
  });

  final PrismThemeId id;

  /// Compact chip label for the top header bar.
  final LocalizedText name;

  /// Full poetic atmosphere name for Stage Intro banners & Theme Gallery.
  final LocalizedText fullName;

  /// Expressive realm badge glyph.
  final String badgeEmoji;

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
  final Color feverAccent;
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
    fullName: LocalizedText(tr: 'Tropik Mercan', en: 'Coral Lagoon'),
    badgeEmoji: '🌴',
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
    feverAccent: Color(0xFF00F0FF),
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
    fullName: LocalizedText(tr: 'Şeker Vitray', en: 'Candy Prism'),
    badgeEmoji: '🍬',
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
    feverAccent: Color(0xFFFF9E2C),
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

  /// Theme 3: Bahar Bahçesi / Sakura Blossom
  static const PrismPalette aurora = PrismPalette(
    id: PrismThemeId.aurora,
    name: LocalizedText(tr: 'Bahar', en: 'Blossom'),
    fullName: LocalizedText(tr: 'Bahar Bahçesi', en: 'Sakura Blossom'),
    badgeEmoji: '🌸',
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
    feverAccent: Color(0xFFFF85B3),
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
    fullName: LocalizedText(tr: 'Karnaval Neon', en: 'Neon Carnival'),
    badgeEmoji: '🎡',
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
    feverAccent: Color(0xFFFF38B8),
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

  /// Theme 5: Altın Şafak / Solar Amber
  static const PrismPalette solarAmber = PrismPalette(
    id: PrismThemeId.solarAmber,
    name: LocalizedText(tr: 'Şafak', en: 'Amber'),
    fullName: LocalizedText(tr: 'Altın Şafak', en: 'Solar Amber'),
    badgeEmoji: '☀️',
    brightness: Brightness.light,
    backgroundGradient: <Color>[
      Color(0xFFFF9A44),
      Color(0xFFFFCE54),
      Color(0xFFFFF2A6),
    ],
    background: Color(0xFFFFB84D),
    surface: Color(0xF5FFFBF2),
    surfaceElevated: Color(0xFFFFF2D6),
    boardBackground: Color(0xFF3E1A0B),
    boardBorderGlow: Color(0xFFFFD166),
    cellBackground: Color(0xFF572611),
    cellAltTint: Color(0xFF692F16),
    cellBorder: Color(0x52FFB74D),
    ink: Color(0xFF471E06),
    mutedInk: Color(0xFF8A4B1E),
    accent: Color(0xFFF95738),
    accentInk: Color(0xFFFFFFFF),
    resonanceColor: Color(0xFF00E5FF),
    prismGold: Color(0xFFFFE64D),
    feverAccent: Color(0xFFFFB703),
    ambientStyle: PrismAmbientStyle.goldenEmbers,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFFF4769),
        highlight: Color(0xFFFFB3C1),
        shadow: Color(0xFFB8143A),
      ),
      GemColorRamp(
        main: Color(0xFF00D4FF),
        highlight: Color(0xFFBAF3FF),
        shadow: Color(0xFF0082B3),
      ),
      GemColorRamp(
        main: Color(0xFF36EA7C),
        highlight: Color(0xFFC0FFD8),
        shadow: Color(0xFF0FA14B),
      ),
      GemColorRamp(
        main: Color(0xFFFFAE19),
        highlight: Color(0xFFFFE89E),
        shadow: Color(0xFFC97300),
      ),
      GemColorRamp(
        main: Color(0xFFB666FF),
        highlight: Color(0xFFE8CCFF),
        shadow: Color(0xFF7326C9),
      ),
      GemColorRamp(
        main: Color(0xFFFFF04D),
        highlight: Color(0xFFFFFCCB),
        shadow: Color(0xFFC9A700),
      ),
    ],
  );

  /// Theme 6: Kuzey Işığı / Polar Aurora (Radiant Electric Teal & Violet)
  static const PrismPalette polarAurora = PrismPalette(
    id: PrismThemeId.polarAurora,
    name: LocalizedText(tr: 'Kuzey', en: 'Aurora'),
    fullName: LocalizedText(tr: 'Kuzey Işığı', en: 'Polar Aurora'),
    badgeEmoji: '🌌',
    brightness: Brightness.dark,
    backgroundGradient: <Color>[
      Color(0xFF0E4D92),
      Color(0xFF14A3B8),
      Color(0xFF3BF5C4),
    ],
    background: Color(0xFF1175A6),
    surface: Color(0xEB0F2C4D),
    surfaceElevated: Color(0xFF163F66),
    boardBackground: Color(0xFF06182B),
    boardBorderGlow: Color(0xFF48F7C7),
    cellBackground: Color(0xFF0D2B47),
    cellAltTint: Color(0xFF133859),
    cellBorder: Color(0x5248F7C7),
    ink: Color(0xFFF2FDFF),
    mutedInk: Color(0xFFA8E1F0),
    accent: Color(0xFF2BF5B4),
    accentInk: Color(0xFF06182B),
    resonanceColor: Color(0xFFC77DFF),
    prismGold: Color(0xFFFFE548),
    feverAccent: Color(0xFF00E5FF),
    ambientStyle: PrismAmbientStyle.auroraRibbons,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFF2CF5B6),
        highlight: Color(0xFFC2FFE9),
        shadow: Color(0xFF00A373),
      ),
      GemColorRamp(
        main: Color(0xFFFF4F8B),
        highlight: Color(0xFFFFC0D6),
        shadow: Color(0xFFBD1954),
      ),
      GemColorRamp(
        main: Color(0xFF33CCFF),
        highlight: Color(0xFFC4F0FF),
        shadow: Color(0xFF007FB8),
      ),
      GemColorRamp(
        main: Color(0xFFFFD92E),
        highlight: Color(0xFFFFF5B5),
        shadow: Color(0xFFC99500),
      ),
      GemColorRamp(
        main: Color(0xFFC270FF),
        highlight: Color(0xFFECD1FF),
        shadow: Color(0xFF7B2EC9),
      ),
      GemColorRamp(
        main: Color(0xFFFF8833),
        highlight: Color(0xFFFFD5B3),
        shadow: Color(0xFFC94F00),
      ),
    ],
  );

  /// Theme 7: Buzul Kristali / Glacier Quartz
  static const PrismPalette glacierCrystal = PrismPalette(
    id: PrismThemeId.glacierCrystal,
    name: LocalizedText(tr: 'Buzul', en: 'Glacier'),
    fullName: LocalizedText(tr: 'Buzul Kristali', en: 'Glacier Quartz'),
    badgeEmoji: '❄️',
    brightness: Brightness.light,
    backgroundGradient: <Color>[
      Color(0xFF66CCFF),
      Color(0xFFBAE8FF),
      Color(0xFFDDC2FF),
    ],
    background: Color(0xFFAEE2FF),
    surface: Color(0xF5F6FCFF),
    surfaceElevated: Color(0xFFE3F5FF),
    boardBackground: Color(0xFF0E2F54),
    boardBorderGlow: Color(0xFF8CE8FF),
    cellBackground: Color(0xFF164273),
    cellAltTint: Color(0xFF1E528A),
    cellBorder: Color(0x528CE8FF),
    ink: Color(0xFF0B2948),
    mutedInk: Color(0xFF39648F),
    accent: Color(0xFF008CFF),
    accentInk: Color(0xFFFFFFFF),
    resonanceColor: Color(0xFFFF5CA8),
    prismGold: Color(0xFFFFE047),
    feverAccent: Color(0xFF5CEEFF),
    ambientStyle: PrismAmbientStyle.frostCrystals,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFFF4D88),
        highlight: Color(0xFFFFC2D6),
        shadow: Color(0xFFBD1753),
      ),
      GemColorRamp(
        main: Color(0xFF00E0FF),
        highlight: Color(0xFFC2F8FF),
        shadow: Color(0xFF008EB8),
      ),
      GemColorRamp(
        main: Color(0xFFFF9E2C),
        highlight: Color(0xFFFFE0B0),
        shadow: Color(0xFFC96100),
      ),
      GemColorRamp(
        main: Color(0xFF38EB7D),
        highlight: Color(0xFFC4FFDA),
        shadow: Color(0xFF10A34D),
      ),
      GemColorRamp(
        main: Color(0xFFFFE138),
        highlight: Color(0xFFFFF7BD),
        shadow: Color(0xFFC99E00),
      ),
      GemColorRamp(
        main: Color(0xFFAC6BFF),
        highlight: Color(0xFFE5D1FF),
        shadow: Color(0xFF6A29C9),
      ),
    ],
  );

  /// Theme 8: Derin Mercan / Biolume Reef (Vibrant Glowing Ocean Cyan & Magenta)
  static const PrismPalette abyssalReef = PrismPalette(
    id: PrismThemeId.abyssalReef,
    name: LocalizedText(tr: 'Okyanus', en: 'Biolume'),
    fullName: LocalizedText(tr: 'Derin Mercan', en: 'Biolume Reef'),
    badgeEmoji: '🪼',
    brightness: Brightness.dark,
    backgroundGradient: <Color>[
      Color(0xFF0A47A6),
      Color(0xFF00A8CC),
      Color(0xFF00F5D4),
    ],
    background: Color(0xFF065E91),
    surface: Color(0xEB0A2E52),
    surfaceElevated: Color(0xFF114270),
    boardBackground: Color(0xFF04152B),
    boardBorderGlow: Color(0xFF00F5D4),
    cellBackground: Color(0xFF0A2647),
    cellAltTint: Color(0xFF103259),
    cellBorder: Color(0x5200F5D4),
    ink: Color(0xFFF0FBFF),
    mutedInk: Color(0xFF9EDBF0),
    accent: Color(0xFF00E5FF),
    accentInk: Color(0xFF04152B),
    resonanceColor: Color(0xFFFF5EC4),
    prismGold: Color(0xFFFFE14D),
    feverAccent: Color(0xFF00F5D4),
    ambientStyle: PrismAmbientStyle.biolumeMotes,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFF00F5D4),
        highlight: Color(0xFFBDFFF6),
        shadow: Color(0xFF00A38E),
      ),
      GemColorRamp(
        main: Color(0xFFFF47A3),
        highlight: Color(0xFFFFBDDF),
        shadow: Color(0xFFBD1468),
      ),
      GemColorRamp(
        main: Color(0xFFFFCC29),
        highlight: Color(0xFFFFF2B3),
        shadow: Color(0xFFC98C00),
      ),
      GemColorRamp(
        main: Color(0xFF4D9BFF),
        highlight: Color(0xFFC7E0FF),
        shadow: Color(0xFF1659C4),
      ),
      GemColorRamp(
        main: Color(0xFF52F26D),
        highlight: Color(0xFFC7FFD0),
        shadow: Color(0xFF14A632),
      ),
      GemColorRamp(
        main: Color(0xFFFF7847),
        highlight: Color(0xFFFFD0BD),
        shadow: Color(0xFFC43E14),
      ),
    ],
  );

  /// Theme 9: Zümrüt Orman / Emerald Canopy (Sunlit Lush Jade & Lime)
  static const PrismPalette emeraldCanopy = PrismPalette(
    id: PrismThemeId.emeraldCanopy,
    name: LocalizedText(tr: 'Zümrüt', en: 'Emerald'),
    fullName: LocalizedText(tr: 'Zümrüt Orman', en: 'Emerald Canopy'),
    badgeEmoji: '🌿',
    brightness: Brightness.dark,
    backgroundGradient: <Color>[
      Color(0xFF0E7C5B),
      Color(0xFF22C58B),
      Color(0xFFA3F76B),
    ],
    background: Color(0xFF12946C),
    surface: Color(0xEB104235),
    surfaceElevated: Color(0xFF175947),
    boardBackground: Color(0xFF07211A),
    boardBorderGlow: Color(0xFF69F0AE),
    cellBackground: Color(0xFF0E362B),
    cellAltTint: Color(0xFF144537),
    cellBorder: Color(0x5269F0AE),
    ink: Color(0xFFF2FFF9),
    mutedInk: Color(0xFFA9E8D0),
    accent: Color(0xFF38F29A),
    accentInk: Color(0xFF07211A),
    resonanceColor: Color(0xFFFFD60A),
    prismGold: Color(0xFFFFE752),
    feverAccent: Color(0xFFA7F3D0),
    ambientStyle: PrismAmbientStyle.fireflySparks,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFF42F58D),
        highlight: Color(0xFFC7FFDE),
        shadow: Color(0xFF12A650),
      ),
      GemColorRamp(
        main: Color(0xFFFF5E7E),
        highlight: Color(0xFFFFC4D0),
        shadow: Color(0xFFBD1E40),
      ),
      GemColorRamp(
        main: Color(0xFFFFD933),
        highlight: Color(0xFFFFF6B8),
        shadow: Color(0xFFC99500),
      ),
      GemColorRamp(
        main: Color(0xFF29D4FF),
        highlight: Color(0xFFBFF3FF),
        shadow: Color(0xFF0086B8),
      ),
      GemColorRamp(
        main: Color(0xFFC075FF),
        highlight: Color(0xFFEBD1FF),
        shadow: Color(0xFF7B2EC9),
      ),
      GemColorRamp(
        main: Color(0xFFFF9233),
        highlight: Color(0xFFFFD9B3),
        shadow: Color(0xFFC95600),
      ),
    ],
  );

  /// Theme 10: Ametist Vitray / Amethyst Cathedral (Vivid Orchid & Electric Violet)
  static const PrismPalette amethystDusk = PrismPalette(
    id: PrismThemeId.amethystDusk,
    name: LocalizedText(tr: 'Ametist', en: 'Amethyst'),
    fullName: LocalizedText(tr: 'Ametist Vitray', en: 'Amethyst Cathedral'),
    badgeEmoji: '🔮',
    brightness: Brightness.dark,
    backgroundGradient: <Color>[
      Color(0xFF5D2AE8),
      Color(0xFFA84DFF),
      Color(0xFFFF6BD6),
    ],
    background: Color(0xFF7736E8),
    surface: Color(0xEB2D1959),
    surfaceElevated: Color(0xFF3E2478),
    boardBackground: Color(0xFF160B30),
    boardBorderGlow: Color(0xFFD98BFF),
    cellBackground: Color(0xFF23144A),
    cellAltTint: Color(0xFF2E1B5E),
    cellBorder: Color(0x5CD98BFF),
    ink: Color(0xFFFAF5FF),
    mutedInk: Color(0xFFD8C2FF),
    accent: Color(0xFFE066FF),
    accentInk: Color(0xFF160B30),
    resonanceColor: Color(0xFF00F0FF),
    prismGold: Color(0xFFFFE44D),
    feverAccent: Color(0xFFFF70D9),
    ambientStyle: PrismAmbientStyle.prismRain,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFE066FF),
        highlight: Color(0xFFF5CCFF),
        shadow: Color(0xFF991FC4),
      ),
      GemColorRamp(
        main: Color(0xFF00E5FF),
        highlight: Color(0xFFC2F9FF),
        shadow: Color(0xFF008EB8),
      ),
      GemColorRamp(
        main: Color(0xFFFFE033),
        highlight: Color(0xFFFFF7B8),
        shadow: Color(0xFFC99D00),
      ),
      GemColorRamp(
        main: Color(0xFFFF4D7D),
        highlight: Color(0xFFFFC2D3),
        shadow: Color(0xFFBD1746),
      ),
      GemColorRamp(
        main: Color(0xFF38F088),
        highlight: Color(0xFFC4FFDC),
        shadow: Color(0xFF10A352),
      ),
      GemColorRamp(
        main: Color(0xFFFF8C38),
        highlight: Color(0xFFFFD6B8),
        shadow: Color(0xFFC4500B),
      ),
    ],
  );

  /// Theme 11: Yakut Ocak / Crimson Forge (Fiery Sunset Coral & Tangerine Gold)
  static const PrismPalette crimsonForge = PrismPalette(
    id: PrismThemeId.crimsonForge,
    name: LocalizedText(tr: 'Yakut', en: 'Forge'),
    fullName: LocalizedText(tr: 'Yakut Ocak', en: 'Crimson Forge'),
    badgeEmoji: '🔥',
    brightness: Brightness.dark,
    backgroundGradient: <Color>[
      Color(0xFFC81D4E),
      Color(0xFFFF5252),
      Color(0xFFFFB347),
    ],
    background: Color(0xFFE0354F),
    surface: Color(0xEB471022),
    surfaceElevated: Color(0xFF611830),
    boardBackground: Color(0xFF210610),
    boardBorderGlow: Color(0xFFFF8A5B),
    cellBackground: Color(0xFF360D1C),
    cellAltTint: Color(0xFF451224),
    cellBorder: Color(0x5CFF7A59),
    ink: Color(0xFFFFF5F7),
    mutedInk: Color(0xFFFFC4D2),
    accent: Color(0xFFFF7043),
    accentInk: Color(0xFFFFFFFF),
    resonanceColor: Color(0xFFFFD60A),
    prismGold: Color(0xFFFFE54D),
    feverAccent: Color(0xFFFF3D71),
    ambientStyle: PrismAmbientStyle.forgeSparks,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFFF5C33),
        highlight: Color(0xFFFFC9B8),
        shadow: Color(0xFFC42A08),
      ),
      GemColorRamp(
        main: Color(0xFF00E5FF),
        highlight: Color(0xFFC2F9FF),
        shadow: Color(0xFF008EB8),
      ),
      GemColorRamp(
        main: Color(0xFFFFE438),
        highlight: Color(0xFFFFF8BD),
        shadow: Color(0xFFC9A000),
      ),
      GemColorRamp(
        main: Color(0xFF3CF080),
        highlight: Color(0xFFC4FFD9),
        shadow: Color(0xFF12A34C),
      ),
      GemColorRamp(
        main: Color(0xFFC770FF),
        highlight: Color(0xFFEED1FF),
        shadow: Color(0xFF802BC9),
      ),
      GemColorRamp(
        main: Color(0xFFFF4DA6),
        highlight: Color(0xFFFFC2E0),
        shadow: Color(0xFFBD176A),
      ),
    ],
  );

  /// Theme 12: Göksel Prizma / Celestial Nebula (Luminous Starlight Indigo & Pink-Gold)
  static const PrismPalette celestialCrown = PrismPalette(
    id: PrismThemeId.celestialCrown,
    name: LocalizedText(tr: 'Göksel', en: 'Celestial'),
    fullName: LocalizedText(tr: 'Göksel Prizma', en: 'Celestial Nebula'),
    badgeEmoji: '✨',
    brightness: Brightness.dark,
    backgroundGradient: <Color>[
      Color(0xFF2E27A8),
      Color(0xFF7B3FE4),
      Color(0xFFFF6FA5),
    ],
    background: Color(0xFF4733BF),
    surface: Color(0xEB191752),
    surfaceElevated: Color(0xFF282478),
    boardBackground: Color(0xFF090824),
    boardBorderGlow: Color(0xFFFFE45E),
    cellBackground: Color(0xFF131240),
    cellAltTint: Color(0xFF1C1B57),
    cellBorder: Color(0x5CFFE45E),
    ink: Color(0xFFFFFDF5),
    mutedInk: Color(0xFFD2D0FF),
    accent: Color(0xFFFFD84D),
    accentInk: Color(0xFF090824),
    resonanceColor: Color(0xFF00F0FF),
    prismGold: Color(0xFFFFF066),
    feverAccent: Color(0xFFC77DFF),
    ambientStyle: PrismAmbientStyle.stardustNebula,
    gemRamps: <GemColorRamp>[
      GemColorRamp(
        main: Color(0xFFFFE047),
        highlight: Color(0xFFFFF8C2),
        shadow: Color(0xFFC99C00),
      ),
      GemColorRamp(
        main: Color(0xFF00ECFF),
        highlight: Color(0xFFC4FAFF),
        shadow: Color(0xFF0093B8),
      ),
      GemColorRamp(
        main: Color(0xFFFF4DB8),
        highlight: Color(0xFFFFC2E7),
        shadow: Color(0xFFBD177B),
      ),
      GemColorRamp(
        main: Color(0xFF47F592),
        highlight: Color(0xFFC7FFDF),
        shadow: Color(0xFF12A655),
      ),
      GemColorRamp(
        main: Color(0xFFA370FF),
        highlight: Color(0xFFE3D1FF),
        shadow: Color(0xFF5E2BC9),
      ),
      GemColorRamp(
        main: Color(0xFFFF8C3B),
        highlight: Color(0xFFFFD8BA),
        shadow: Color(0xFFC4500E),
      ),
    ],
  );

  static const List<PrismPalette> all = <PrismPalette>[
    ceramic,
    atelier,
    aurora,
    obsidian,
    solarAmber,
    polarAurora,
    glacierCrystal,
    abyssalReef,
    emeraldCanopy,
    amethystDusk,
    crimsonForge,
    celestialCrown,
  ];

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
      case PrismThemeId.solarAmber:
        return solarAmber;
      case PrismThemeId.polarAurora:
        return polarAurora;
      case PrismThemeId.glacierCrystal:
        return glacierCrystal;
      case PrismThemeId.abyssalReef:
        return abyssalReef;
      case PrismThemeId.emeraldCanopy:
        return emeraldCanopy;
      case PrismThemeId.amethystDusk:
        return amethystDusk;
      case PrismThemeId.crimsonForge:
        return crimsonForge;
      case PrismThemeId.celestialCrown:
        return celestialCrown;
    }
  }

  /// Generates a vibrant, joyful ("cıvıl cıvıl") per-stage variation of [id]
  /// so every single stage across 1..1000 radiates its own lively backdrop hue
  /// while keeping UI surfaces and contrast crisp and legible.
  static PrismPalette vibrantForStage(PrismThemeId id, int stageNumber) {
    final base = of(id);
    if (stageNumber <= 12) return base;
    // Golden-angle hue rotation produces richly varied, never-monotonous backdrops.
    final cycle = (stageNumber - 1) ~/ all.length;
    final hueShift = ((cycle * 37.5 + (stageNumber % 7) * 9.0) % 360.0);
    Color shiftVivid(Color c, double deltaDeg, double lightBoost) {
      final hsl = HSLColor.fromColor(c);
      final nextHue = (hsl.hue + deltaDeg) % 360.0;
      final nextSat = (hsl.saturation + 0.08).clamp(0.58, 1.0);
      final nextLight = (hsl.lightness + lightBoost).clamp(0.34, 0.84);
      return hsl
          .withHue(nextHue)
          .withSaturation(nextSat)
          .withLightness(nextLight)
          .toColor();
    }

    final grad = <Color>[
      shiftVivid(base.backgroundGradient[0], hueShift, 0.03),
      shiftVivid(base.backgroundGradient[1], (hueShift + 14.0) % 360.0, 0.04),
      shiftVivid(base.backgroundGradient[2], (hueShift + 28.0) % 360.0, 0.05),
    ];

    return PrismPalette(
      id: base.id,
      name: base.name,
      fullName: base.fullName,
      badgeEmoji: base.badgeEmoji,
      brightness: base.brightness,
      backgroundGradient: grad,
      background: grad[1],
      surface: base.surface,
      surfaceElevated: base.surfaceElevated,
      boardBackground: base.boardBackground,
      boardBorderGlow: shiftVivid(base.boardBorderGlow, hueShift * 0.5, 0.04),
      cellBackground: base.cellBackground,
      cellAltTint: base.cellAltTint,
      cellBorder: base.cellBorder,
      ink: base.ink,
      mutedInk: base.mutedInk,
      accent: base.accent,
      accentInk: base.accentInk,
      resonanceColor: base.resonanceColor,
      prismGold: base.prismGold,
      feverAccent: base.feverAccent,
      ambientStyle: PrismAmbientStyle
          .values[(base.ambientStyle.index + cycle) % PrismAmbientStyle.values.length],
      gemRamps: base.gemRamps,
    );
  }
}
