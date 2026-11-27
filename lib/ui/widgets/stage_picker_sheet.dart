/// Visual Stage Journey Map & 12-Theme Realm Gallery bottom sheet for PRISM FORGE.
///
/// Displays:
/// - Auto-Theme toggle (switches atmosphere automatically after every stage & Endless milestone)
/// - Horizontally scrollable 12 Dazzling Realms quick-swatch selector
/// - All 24 handcrafted Quest stages across 4 chapters, each styled with its own
///   top theme gradient crest, realm emoji, unique poetic title, obstacle badge, and 1–3 stars.
library;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../../engine/quest_stages.dart';
import '../../l10n/prism_strings.dart';
import '../../theme/prism_themes.dart';

class StagePickerSheet extends StatelessWidget {
  const StagePickerSheet({
    super.key,
    required this.palette,
    required this.locale,
    required this.currentStage,
    required this.starsByStage,
    required this.autoStageTheme,
    required this.onSelectStage,
    required this.onSelectTheme,
    required this.onToggleAutoTheme,
  });

  final PrismPalette palette;
  final AppLocale locale;
  final int currentStage;
  final Map<int, int> starsByStage;
  final bool autoStageTheme;
  final ValueChanged<int> onSelectStage;
  final ValueChanged<PrismThemeId> onSelectTheme;
  final VoidCallback onToggleAutoTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.84,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: palette.ink.withValues(alpha: 0.14)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.mutedInk.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      PrismStrings.questDrawerTitle.resolve(locale),
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  InkWell(
                    key: const ValueKey<String>('auto_theme_toggle'),
                    borderRadius: BorderRadius.circular(99),
                    onTap: () {
                      onToggleAutoTheme();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: autoStageTheme
                            ? palette.accent
                            : palette.surfaceElevated,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: autoStageTheme
                              ? palette.accent
                              : palette.ink.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        (autoStageTheme
                                ? PrismStrings.autoThemeOn
                                : PrismStrings.autoThemeOff)
                            .resolve(locale),
                        style: TextStyle(
                          color: autoStageTheme
                              ? palette.accentInk
                              : palette.ink,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: palette.mutedInk),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                PrismStrings.themeGalleryLabel.resolve(locale),
                style: TextStyle(
                  color: palette.mutedInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: PrismThemes.all.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final theme = PrismThemes.all[index];
                    final active = theme.id == palette.id;
                    return InkWell(
                      borderRadius: BorderRadius.circular(99),
                      onTap: () {
                        onSelectTheme(theme.id);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: theme.backgroundGradient,
                          ),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            width: active ? 2.2 : 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${theme.badgeEmoji} ${theme.name.resolve(locale)}',
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : theme.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (var ch = 1; ch <= 4; ch++) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 6),
                          child: Text(
                            QuestStageCatalog.chapterTitle(ch).resolve(locale),
                            style: TextStyle(
                              color: palette.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.24,
                          children: <Widget>[
                            for (final st in QuestStageCatalog.stages.where(
                              (s) => s.chapterNumber == ch,
                            ))
                              _buildStageTile(context, st),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageTile(BuildContext context, QuestStageSpec spec) {
    final stars = starsByStage[spec.stageNumber] ?? 0;
    final selected = spec.stageNumber == currentStage;
    final stagePalette = PrismThemes.of(spec.themeId);
    final badge = spec.targetLocks > 0
        ? '🔒'
        : spec.targetFrost > 0
        ? '❄'
        : '★';

    return InkWell(
      key: ValueKey<String>('stage_tile_${spec.stageNumber}'),
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).pop();
        onSelectStage(spec.stageNumber);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? palette.accent : palette.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? palette.ink
                  : stagePalette.boardBorderGlow.withValues(alpha: 0.45),
              width: selected ? 2.0 : 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Top theme gradient crest previewing this stage's realm!
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: stagePalette.backgroundGradient,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '#${spec.stageNumber} ${stagePalette.badgeEmoji}$badge',
                        style: TextStyle(
                          color: selected ? palette.accentInk : palette.ink,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spec.title.resolve(locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? palette.accentInk.withValues(alpha: 0.92)
                              : palette.mutedInk,
                          fontSize: 9.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${'★' * stars}${'☆' * (3 - stars)}',
                        style: TextStyle(
                          color: selected
                              ? palette.accentInk
                              : palette.prismGold,
                          fontSize: 10.5,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
