/// Modal bottom sheet displaying all 24 handcrafted Prism Quest stages across
/// 4 architectural chapters with 1–3 star mastery progress.
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
    required this.onSelectStage,
  });

  final PrismPalette palette;
  final AppLocale locale;
  final int currentStage;
  final Map<int, int> starsByStage;
  final ValueChanged<int> onSelectStage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: palette.ink.withValues(alpha: 0.14)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
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
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      PrismStrings.questDrawerTitle.resolve(locale),
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: palette.mutedInk),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
                          childAspectRatio: 1.45,
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
    final badge = spec.targetLocks > 0
        ? '🔒'
        : spec.targetFrost > 0
        ? '❄'
        : '★';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).pop();
        onSelectStage(spec.stageNumber);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? palette.accent : palette.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? palette.ink : palette.ink.withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '#${spec.stageNumber} $badge',
              style: TextStyle(
                color: selected ? palette.background : palette.ink,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              spec.title.resolve(locale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? palette.background.withValues(alpha: 0.85)
                    : palette.mutedInk,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${'★' * stars}${'☆' * (3 - stars)}',
              style: TextStyle(
                color: selected ? palette.background : palette.prismGold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
