/// Bilingual Turkish / English copy for PRISM FORGE (Prizma Döküm).
library;

import '../engine/models.dart';

class PrismStrings {
  const PrismStrings._();

  static const LocalizedText appTitle = LocalizedText(
    tr: 'PRİZMA DÖKÜM',
    en: 'PRISM FORGE',
  );

  static const LocalizedText appSubtitle = LocalizedText(
    tr: 'Kristal Rezonans • Buz & Mühür • Taktik Enerji',
    en: 'Crystal Resonance • Frost & Seal • Tactical Energy',
  );

  static LocalizedText modeLabel(GameMode mode) {
    switch (mode) {
      case GameMode.endless:
        return const LocalizedText(tr: 'Sonsuz', en: 'Endless');
      case GameMode.quest:
        return const LocalizedText(tr: '24 Bölüm', en: '24 Stages');
      case GameMode.daily:
        return const LocalizedText(tr: 'Günlük', en: 'Daily');
      case GameMode.blitz:
        return const LocalizedText(tr: '90s Hız', en: '90s Blitz');
    }
  }

  static const LocalizedText score = LocalizedText(tr: 'Skor', en: 'Score');
  static const LocalizedText best = LocalizedText(tr: 'En İyi', en: 'Best');
  static const LocalizedText combo = LocalizedText(tr: 'Kombo', en: 'Combo');
  static const LocalizedText stage = LocalizedText(tr: 'Bölüm', en: 'Stage');
  static const LocalizedText time = LocalizedText(tr: 'Süre', en: 'Time');
  static const LocalizedText energy = LocalizedText(
    tr: 'Taktik Enerji',
    en: 'Tactical Energy',
  );
  static const LocalizedText rotate = LocalizedText(tr: 'Döndür', en: 'Rotate');
  static const LocalizedText nova = LocalizedText(
    tr: 'Nova 3×3',
    en: 'Nova 3×3',
  );
  static const LocalizedText cancel = LocalizedText(tr: 'İptal', en: 'Cancel');
  static const LocalizedText restart = LocalizedText(
    tr: 'Yenile',
    en: 'Restart',
  );

  static const LocalizedText novaBanner = LocalizedText(
    tr: 'NOVA MODU: Buz ve Mühür dahil 3×3 alanı buharlaştırmak için tahtaya dokun!',
    en: 'NOVA MODE: Tap any 3×3 area on the board to shatter blocks, Frost & Seals!',
  );

  static const LocalizedText blitzHint = LocalizedText(
    tr: 'Satır sil +3sn • Rezonans +5sn!',
    en: 'Line clear +3s • Resonance +5s!',
  );

  static const LocalizedText legendShort = LocalizedText(
    tr: '★ Çapraz Şok  •  ❄ 2 Vuruş  •  🔒 Rezonans/Şok/Nova  •  4+ Renk ×1.5',
    en: '★ Cross-Wave  •  ❄ 2-Hit Ice  •  🔒 Resonance/Wave/Nova  •  4+ Color ×1.5',
  );

  static const LocalizedText gameOverTitle = LocalizedText(
    tr: 'Hamle Kalmadı',
    en: 'No Moves Left',
  );
  static const LocalizedText timeUpTitle = LocalizedText(
    tr: 'Süre Doldu!',
    en: 'Time Up!',
  );
  static const LocalizedText stageClearTitle = LocalizedText(
    tr: 'Bölüm Mühürlendi!',
    en: 'Stage Forged!',
  );
  static const LocalizedText dailyClearTitle = LocalizedText(
    tr: 'Günlük Prizma Tamam!',
    en: 'Daily Prism Solved!',
  );

  static const LocalizedText gameOverDesc = LocalizedText(
    tr: '4+ aynı renkli Rezonans kurarak mühürleri kırabilir, Taktik Enerji ile parçaları döndürebilirsin.',
    en: 'Build 4+ same-color Resonance lines to shatter Seals, and spend Energy to rotate tricky shapes.',
  );
  static const LocalizedText timeUpDesc = LocalizedText(
    tr: '90 saniyelik Hız Düellosu tamamlandı! Kendi rekorunu geçmek için tekrar dene.',
    en: 'Your 90-second Blitz Duel ended! Race again to beat your personal best.',
  );
  static const LocalizedText stageClearDesc = LocalizedText(
    tr: 'Tüm mimari hedefler kristal rezonansa ulaştı. Sonraki bölüm seni bekliyor!',
    en: 'All architectural targets reached resonance. Your next stage awaits!',
  );
  static const LocalizedText dailyClearDesc = LocalizedText(
    tr: 'Bugünün ortak tohumlu Günlük Prizma Meydan Okumasını çözdün!',
    en: 'You conquered today’s deterministic Daily Prism Challenge!',
  );

  static const LocalizedText playAgain = LocalizedText(
    tr: 'Tekrar Oyna',
    en: 'Play Again',
  );
  static const LocalizedText nextStage = LocalizedText(
    tr: 'Sonraki Bölüm',
    en: 'Next Stage',
  );

  static const LocalizedText questDrawerTitle = LocalizedText(
    tr: 'Prizma Görevi — 24 Bölüm',
    en: 'Prism Quest — 24 Stages',
  );

  static LocalizedText resonanceBanner = const LocalizedText(
    tr: 'PRİZMA REZONANSI ×1.5!',
    en: 'PRISM RESONANCE ×1.5!',
  );
  static LocalizedText crossWaveBanner = const LocalizedText(
    tr: 'ÇAPRAZ ŞOK DALGASI!',
    en: 'CROSS-WAVE BLAST!',
  );
  static LocalizedText allClearBanner = const LocalizedText(
    tr: 'TAHTA TEMİZLENDİ +1000!',
    en: 'ALL CLEAR +1000!',
  );

  static LocalizedText questObjectiveSummary({
    required int remainingCores,
    required int remainingFrost,
    required int remainingLocks,
  }) {
    final trParts = <String>[];
    final enParts = <String>[];
    if (remainingCores > 0) {
      trParts.add('$remainingCores ★ Çekirdek');
      enParts.add('$remainingCores ★ Cores');
    }
    if (remainingFrost > 0) {
      trParts.add('$remainingFrost ❄ Buz');
      enParts.add('$remainingFrost ❄ Frost');
    }
    if (remainingLocks > 0) {
      trParts.add('$remainingLocks 🔒 Mühür');
      enParts.add('$remainingLocks 🔒 Seals');
    }
    return LocalizedText(
      tr: trParts.isEmpty ? 'Tamamlandı!' : trParts.join(' • '),
      en: enParts.isEmpty ? 'Completed!' : enParts.join(' • '),
    );
  }
}
