/// Modal bottom sheet displaying PRISM FORGE's 12 unlockable Achievements,
/// lifetime player statistics, optional Game Center / Google Play Games cloud
/// sync (zero forced login!), and AdMob Rewarded/Ad-Free status.
library;

import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../../services/achievements_service.dart';
import '../../storage/prism_storage.dart';
import '../../theme/prism_themes.dart';

class TrophyHubSheet extends StatelessWidget {
  const TrophyHubSheet({
    super.key,
    required this.palette,
    required this.locale,
    required this.save,
    required this.gamesConnected,
    required this.onTapConnectGames,
  });

  final PrismPalette palette;
  final AppLocale locale;
  final PrismSaveData save;
  final bool gamesConnected;
  final VoidCallback onTapConnectGames;

  @override
  Widget build(BuildContext context) {
    final unlockedCount = save.unlockedAchievementIds.length;
    final totalCount = AchievementCatalog.all.length;
    final isTr = locale == AppLocale.tr;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: palette.ink.withValues(alpha: 0.16)),
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
                      isTr
                          ? 'Kupa Vitrini ($unlockedCount/$totalCount)'
                          : 'Trophy Vault ($unlockedCount/$totalCount)',
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

              // Optional Game Center / Google Play Games Cloud Sync card (NO login wall!)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: palette.accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      gamesConnected
                          ? Icons.cloud_done_rounded
                          : Icons.sports_esports_rounded,
                      color: palette.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            isTr
                                ? 'Game Center / Play Games'
                                : 'Game Center / Play Games',
                            style: TextStyle(
                              color: palette.ink,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            gamesConnected
                                ? (isTr
                                      ? 'Liderlik tablosu ve kupalar bağlı'
                                      : 'Leaderboards & trophies synced')
                                : (isTr
                                      ? 'Giriş zorunlu değil — istersen tek dokunuşla bağla'
                                      : 'Guest play active — optional 1-tap cloud sync'),
                            style: TextStyle(
                              color: palette.mutedInk,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      key: const ValueKey<String>('connect_games_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.accent,
                        foregroundColor: palette.accentInk,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: gamesConnected ? null : onTapConnectGames,
                      child: Text(
                        gamesConnected
                            ? (isTr ? 'Bağlı' : 'Synced')
                            : (isTr ? 'Bağla' : 'Sync'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Compact lifetime stats row
              Row(
                children: <Widget>[
                  _miniStat(
                    isTr ? 'Satır' : 'Lines',
                    '${save.stats.totalLinesCleared}',
                  ),
                  const SizedBox(width: 6),
                  _miniStat(
                    isTr ? 'Rezonans' : 'Resonance',
                    '${save.stats.totalResonances}',
                  ),
                  const SizedBox(width: 6),
                  _miniStat(
                    isTr ? 'Lazer' : 'Lasers',
                    '${save.stats.totalRefractionChains}',
                  ),
                  const SizedBox(width: 6),
                  _miniStat(
                    isTr ? 'Döküm ★' : 'Forged ★',
                    '${save.stats.totalSynthesizedCores}',
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 12 Achievement cards
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: AchievementCatalog.all.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final spec = AchievementCatalog.all[index];
                    final unlocked = save.unlockedAchievementIds.contains(
                      spec.id,
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? palette.surfaceElevated
                            : palette.background.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: unlocked
                              ? palette.prismGold.withValues(alpha: 0.75)
                              : palette.ink.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: unlocked
                                  ? palette.prismGold.withValues(alpha: 0.25)
                                  : palette.ink.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              spec.iconGlyph,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  spec.title.resolve(locale),
                                  style: TextStyle(
                                    color: palette.ink,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  spec.description.resolve(locale),
                                  style: TextStyle(
                                    color: palette.mutedInk,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            unlocked
                                ? Icons.verified_rounded
                                : Icons.lock_outline_rounded,
                            size: 18,
                            color: unlocked
                                ? palette.accent
                                : palette.mutedInk.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: palette.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.ink.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                color: palette.ink,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.mutedInk, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
