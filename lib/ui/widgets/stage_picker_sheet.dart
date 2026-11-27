/// Visual 1,000-Stage Journey Map & 12-Theme Realm Gallery for PRISM FORGE.
///
/// Features:
/// - Auto-Theme toggle (switches atmosphere vibrantly on every single stage #1..#1000)
/// - Horizontally scrollable 12 Dazzling Realms quick-swatch selector
/// - 10 Grand Realm tabs (1–100, 101–200, ..., 901–1000) with lazy GridView.builder
///   so browsing all 1,000 stages stays 60fps with instant opening
/// - Per-stage unique gradient crest (`PrismThemes.vibrantForStage`), 👑 Boss
///   crown badges on every 10th stage, move-limit indicators, and 1–3 stars.
library;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../../engine/quest_stages.dart';
import '../../l10n/prism_strings.dart';
import '../../theme/prism_themes.dart';

class StagePickerSheet extends StatefulWidget {
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
  State<StagePickerSheet> createState() => _StagePickerSheetState();
}

class _StagePickerSheetState extends State<StagePickerSheet> {
  late int _selectedChapter;

  @override
  void initState() {
    super.initState();
    _selectedChapter =
        (((widget.currentStage - 1) ~/ QuestStageCatalog.stagesPerChapter) + 1)
            .clamp(1, QuestStageCatalog.totalChapters);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final locale = widget.locale;
    final totalStars = widget.starsByStage.values.fold<int>(0, (a, b) => a + b);
    final chapterStart =
        (_selectedChapter - 1) * QuestStageCatalog.stagesPerChapter + 1;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.86,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: p.ink.withValues(alpha: 0.14)),
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
                    color: p.mutedInk.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          PrismStrings.questDrawerTitle.resolve(locale),
                          style: TextStyle(
                            color: p.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '★ $totalStars / ${QuestStageCatalog.totalStages * 3}',
                          style: TextStyle(
                            color: p.prismGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    key: const ValueKey<String>('auto_theme_toggle'),
                    borderRadius: BorderRadius.circular(99),
                    onTap: () {
                      widget.onToggleAutoTheme();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.autoStageTheme
                            ? p.accent
                            : p.surfaceElevated,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: widget.autoStageTheme
                              ? p.accent
                              : p.ink.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        (widget.autoStageTheme
                                ? PrismStrings.autoThemeOn
                                : PrismStrings.autoThemeOff)
                            .resolve(locale),
                        style: TextStyle(
                          color: widget.autoStageTheme ? p.accentInk : p.ink,
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
                    icon: Icon(Icons.close_rounded, color: p.mutedInk),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                PrismStrings.themeGalleryLabel.resolve(locale),
                style: TextStyle(
                  color: p.mutedInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: PrismThemes.all.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final theme = PrismThemes.all[index];
                    final active = theme.id == p.id;
                    return InkWell(
                      borderRadius: BorderRadius.circular(99),
                      onTap: () {
                        widget.onSelectTheme(theme.id);
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

              // 10 Grand Realm chapter selector (1-100 .. 901-1000)
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: QuestStageCatalog.totalChapters,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final ch = index + 1;
                    final start =
                        index * QuestStageCatalog.stagesPerChapter + 1;
                    final end = start + QuestStageCatalog.stagesPerChapter - 1;
                    final isSel = ch == _selectedChapter;
                    return InkWell(
                      key: ValueKey<String>('realm_tab_$ch'),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _selectedChapter = ch),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSel ? p.accent : p.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel
                                ? p.accent
                                : p.ink.withValues(alpha: 0.16),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$start–$end',
                          style: TextStyle(
                            color: isSel ? p.accentInk : p.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                QuestStageCatalog.chapterTitle(
                  _selectedChapter,
                ).resolve(locale),
                style: TextStyle(
                  color: p.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: GridView.builder(
                  itemCount: QuestStageCatalog.stagesPerChapter,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.16,
                  ),
                  itemBuilder: (context, idx) {
                    final stageNum = chapterStart + idx;
                    final spec = QuestStageCatalog.byNumber(stageNum);
                    return _buildStageTile(context, spec);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageTile(BuildContext context, QuestStageSpec spec) {
    final p = widget.palette;
    final stars = widget.starsByStage[spec.stageNumber] ?? 0;
    final selected = spec.stageNumber == widget.currentStage;
    final stagePalette = PrismThemes.vibrantForStage(
      spec.themeId,
      spec.stageNumber,
    );
    final badge = spec.isBossStage
        ? '👑'
        : spec.targetLocks > 0
        ? '🔒'
        : spec.targetFrost > 0
        ? '❄'
        : '★';

    return InkWell(
      key: ValueKey<String>('stage_tile_${spec.stageNumber}'),
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).pop();
        widget.onSelectStage(spec.stageNumber);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? p.accent
                : spec.isBossStage
                ? p.prismGold.withValues(alpha: 0.16)
                : p.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? p.ink
                  : spec.isBossStage
                  ? p.prismGold
                  : stagePalette.boardBorderGlow.withValues(alpha: 0.48),
              width: selected || spec.isBossStage ? 1.8 : 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Top theme gradient crest previewing this exact stage's vibrant backdrop!
              Container(
                height: 7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: stagePalette.backgroundGradient,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '#${spec.stageNumber} ${stagePalette.badgeEmoji}$badge',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? p.accentInk : p.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        spec.title.resolve(widget.locale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? p.accentInk.withValues(alpha: 0.92)
                              : p.mutedInk,
                          fontSize: 9.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${'★' * stars}${'☆' * (3 - stars)}',
                            style: TextStyle(
                              color: selected ? p.accentInk : p.prismGold,
                              fontSize: 9.8,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (spec.moveLimit > 0) ...<Widget>[
                            const SizedBox(width: 4),
                            Text(
                              '🎯${spec.moveLimit}',
                              style: TextStyle(
                                color: selected
                                    ? p.accentInk.withValues(alpha: 0.9)
                                    : p.mutedInk,
                                fontSize: 8.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ],
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
