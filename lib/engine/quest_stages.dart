/// 24 handcrafted architectural stages for Prizma Görevi (Prism Quest),
/// spanning 4 progressive chapters:
/// - Chapter 1 (1–6): Kristal Temelleri / Crystal Foundations (Prism Cores & Resonance)
/// - Chapter 2 (7–12): Buzul Atölyesi / Glacial Atelier (❄ 2-Hit Frosted Crystals)
/// - Chapter 3 (13–18): Mühürlü Vitray / Sealed Stained Glass (🔒 Locked Keystones)
/// - Chapter 4 (19–24): Büyük Prizma / Grand Prism (All mechanics combined)
library;

import 'models.dart';

class QuestStageCatalog {
  const QuestStageCatalog._();

  static const List<QuestStageSpec> stages = <QuestStageSpec>[
    // Chapter 1: Crystal Foundations
    QuestStageSpec(
      stageNumber: 1,
      chapterNumber: 1,
      title: LocalizedText(tr: 'İlk Kırılım', en: 'First Refraction'),
      targetCores: 2,
      targetFrost: 0,
      targetLocks: 0,
      initialClutter: 8,
      twoStarScore: 700,
      threeStarScore: 1400,
    ),
    QuestStageSpec(
      stageNumber: 2,
      chapterNumber: 1,
      title: LocalizedText(tr: 'İkili Yankı', en: 'Twin Resonance'),
      targetCores: 3,
      targetFrost: 0,
      targetLocks: 0,
      initialClutter: 9,
      twoStarScore: 850,
      threeStarScore: 1600,
    ),
    QuestStageSpec(
      stageNumber: 3,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Çapraz Işık', en: 'Crossbeam'),
      targetCores: 3,
      targetFrost: 0,
      targetLocks: 0,
      initialClutter: 10,
      twoStarScore: 950,
      threeStarScore: 1800,
    ),
    QuestStageSpec(
      stageNumber: 4,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Saf Spektrum', en: 'Pure Spectrum'),
      targetCores: 4,
      targetFrost: 0,
      targetLocks: 0,
      initialClutter: 11,
      twoStarScore: 1100,
      threeStarScore: 2000,
    ),
    QuestStageSpec(
      stageNumber: 5,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Mercek Dengesi', en: 'Lens Balance'),
      targetCores: 4,
      targetFrost: 0,
      targetLocks: 0,
      initialClutter: 12,
      twoStarScore: 1200,
      threeStarScore: 2200,
    ),
    QuestStageSpec(
      stageNumber: 6,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Atölye Finali', en: 'Atelier Finale'),
      targetCores: 5,
      targetFrost: 0,
      targetLocks: 0,
      initialClutter: 13,
      twoStarScore: 1350,
      threeStarScore: 2400,
    ),

    // Chapter 2: Glacial Atelier (❄ 2-Hit Frosted Crystals)
    QuestStageSpec(
      stageNumber: 7,
      chapterNumber: 2,
      title: LocalizedText(tr: 'İnce Kırağı', en: 'Thin Frost'),
      targetCores: 2,
      targetFrost: 2,
      targetLocks: 0,
      initialClutter: 9,
      twoStarScore: 1000,
      threeStarScore: 1900,
    ),
    QuestStageSpec(
      stageNumber: 8,
      chapterNumber: 2,
      title: LocalizedText(tr: 'Buz Çatlağı', en: 'Ice Fracture'),
      targetCores: 2,
      targetFrost: 3,
      targetLocks: 0,
      initialClutter: 10,
      twoStarScore: 1150,
      threeStarScore: 2100,
    ),
    QuestStageSpec(
      stageNumber: 9,
      chapterNumber: 2,
      title: LocalizedText(tr: 'Kuzey Camı', en: 'Nordic Pane'),
      targetCores: 3,
      targetFrost: 3,
      targetLocks: 0,
      initialClutter: 11,
      twoStarScore: 1250,
      threeStarScore: 2300,
    ),
    QuestStageSpec(
      stageNumber: 10,
      chapterNumber: 2,
      title: LocalizedText(tr: 'Kristal Kış', en: 'Crystal Winter'),
      targetCores: 2,
      targetFrost: 4,
      targetLocks: 0,
      initialClutter: 12,
      twoStarScore: 1350,
      threeStarScore: 2500,
    ),
    QuestStageSpec(
      stageNumber: 11,
      chapterNumber: 2,
      title: LocalizedText(tr: 'Çift Katman', en: 'Double Glaze'),
      targetCores: 3,
      targetFrost: 5,
      targetLocks: 0,
      initialClutter: 13,
      twoStarScore: 1500,
      threeStarScore: 2700,
    ),
    QuestStageSpec(
      stageNumber: 12,
      chapterNumber: 2,
      title: LocalizedText(tr: 'Buzul Kubbesi', en: 'Glacial Dome'),
      targetCores: 3,
      targetFrost: 6,
      targetLocks: 0,
      initialClutter: 14,
      twoStarScore: 1650,
      threeStarScore: 2900,
    ),

    // Chapter 3: Sealed Stained Glass (🔒 Locked Keystones)
    QuestStageSpec(
      stageNumber: 13,
      chapterNumber: 3,
      title: LocalizedText(tr: 'İlk Mühür', en: 'First Seal'),
      targetCores: 2,
      targetFrost: 1,
      targetLocks: 1,
      initialClutter: 10,
      twoStarScore: 1200,
      threeStarScore: 2200,
    ),
    QuestStageSpec(
      stageNumber: 14,
      chapterNumber: 3,
      title: LocalizedText(tr: 'Rezonans Kilidi', en: 'Resonance Lock'),
      targetCores: 2,
      targetFrost: 2,
      targetLocks: 2,
      initialClutter: 11,
      twoStarScore: 1350,
      threeStarScore: 2400,
    ),
    QuestStageSpec(
      stageNumber: 15,
      chapterNumber: 3,
      title: LocalizedText(tr: 'Vitray Kemeri', en: 'Stained Arch'),
      targetCores: 3,
      targetFrost: 2,
      targetLocks: 2,
      initialClutter: 12,
      twoStarScore: 1500,
      threeStarScore: 2600,
    ),
    QuestStageSpec(
      stageNumber: 16,
      chapterNumber: 3,
      title: LocalizedText(tr: 'Altın Kelepçe', en: 'Gilded Clasp'),
      targetCores: 2,
      targetFrost: 3,
      targetLocks: 3,
      initialClutter: 13,
      twoStarScore: 1650,
      threeStarScore: 2800,
    ),
    QuestStageSpec(
      stageNumber: 17,
      chapterNumber: 3,
      title: LocalizedText(tr: 'Şok Anahtarı', en: 'Shock Key'),
      targetCores: 3,
      targetFrost: 2,
      targetLocks: 3,
      initialClutter: 14,
      twoStarScore: 1750,
      threeStarScore: 3000,
    ),
    QuestStageSpec(
      stageNumber: 18,
      chapterNumber: 3,
      title: LocalizedText(tr: 'Mühürlü Salon', en: 'Sealed Hall'),
      targetCores: 3,
      targetFrost: 3,
      targetLocks: 4,
      initialClutter: 15,
      twoStarScore: 1900,
      threeStarScore: 3200,
    ),

    // Chapter 4: Grand Prism (Master Architectural Combinations)
    QuestStageSpec(
      stageNumber: 19,
      chapterNumber: 4,
      title: LocalizedText(tr: 'Üçlü Döküm', en: 'Triple Forge'),
      targetCores: 3,
      targetFrost: 3,
      targetLocks: 2,
      initialClutter: 13,
      twoStarScore: 1800,
      threeStarScore: 3200,
    ),
    QuestStageSpec(
      stageNumber: 20,
      chapterNumber: 4,
      title: LocalizedText(tr: 'Kırılma Ekseni', en: 'Refraction Axis'),
      targetCores: 4,
      targetFrost: 3,
      targetLocks: 3,
      initialClutter: 14,
      twoStarScore: 1950,
      threeStarScore: 3400,
    ),
    QuestStageSpec(
      stageNumber: 21,
      chapterNumber: 4,
      title: LocalizedText(tr: 'Kuantum Kafes', en: 'Quantum Lattice'),
      targetCores: 3,
      targetFrost: 4,
      targetLocks: 3,
      initialClutter: 14,
      twoStarScore: 2100,
      threeStarScore: 3600,
    ),
    QuestStageSpec(
      stageNumber: 22,
      chapterNumber: 4,
      title: LocalizedText(tr: 'Işık Katedrali', en: 'Light Cathedral'),
      targetCores: 4,
      targetFrost: 4,
      targetLocks: 3,
      initialClutter: 15,
      twoStarScore: 2250,
      threeStarScore: 3800,
    ),
    QuestStageSpec(
      stageNumber: 23,
      chapterNumber: 4,
      title: LocalizedText(tr: 'Kraliyet Prizması', en: 'Royal Prism'),
      targetCores: 4,
      targetFrost: 4,
      targetLocks: 4,
      initialClutter: 16,
      twoStarScore: 2400,
      threeStarScore: 4100,
    ),
    QuestStageSpec(
      stageNumber: 24,
      chapterNumber: 4,
      title: LocalizedText(tr: 'Büyük Döküm', en: 'The Grand Forge'),
      targetCores: 5,
      targetFrost: 5,
      targetLocks: 4,
      initialClutter: 17,
      twoStarScore: 2600,
      threeStarScore: 4500,
    ),
  ];

  static QuestStageSpec byNumber(int stageNumber) {
    final clamped = stageNumber.clamp(1, stages.length);
    return stages[clamped - 1];
  }

  static LocalizedText chapterTitle(int chapter) {
    switch (chapter) {
      case 1:
        return const LocalizedText(
          tr: 'Bölüm I • Kristal Temelleri',
          en: 'Chapter I • Crystal Foundations',
        );
      case 2:
        return const LocalizedText(
          tr: 'Bölüm II • Buzul Atölyesi',
          en: 'Chapter II • Glacial Atelier',
        );
      case 3:
        return const LocalizedText(
          tr: 'Bölüm III • Mühürlü Vitray',
          en: 'Chapter III • Sealed Stained Glass',
        );
      default:
        return const LocalizedText(
          tr: 'Bölüm IV • Büyük Prizma',
          en: 'Chapter IV • Grand Prism',
        );
    }
  }
}
