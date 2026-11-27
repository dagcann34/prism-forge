/// 24 handcrafted architectural stages for Prizma Görevi (Prism Quest),
/// each with a unique bilingual poetic name, atmospheric lore subtitle,
/// and dedicated dazzling theme (zero consecutive theme repeats across 1..24):
/// - Chapter 1 (1–6): Kristal Temelleri / Crystal Foundations
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
      subtitle: LocalizedText(
        tr: 'Güneşli lagünde ilk kristal ışığı yak.',
        en: 'Ignite your first crystal beam in the sunlit lagoon.',
      ),
      themeId: PrismThemeId.ceramic,
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
      title: LocalizedText(tr: 'Şeker Mercek', en: 'Sugar Prism'),
      subtitle: LocalizedText(
        tr: 'Tatlı vitray parçalarını ikili yankıyla birleştir.',
        en: 'Weave stained-glass candy tiles into twin resonance.',
      ),
      themeId: PrismThemeId.atelier,
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
      title: LocalizedText(tr: 'Sakura Çaprazı', en: 'Blossom Crossbeam'),
      subtitle: LocalizedText(
        tr: 'Bahar rüzgârında çapraz ışık şokunu uyandır.',
        en: 'Awaken cross-wave light amidst drifting cherry petals.',
      ),
      themeId: PrismThemeId.aurora,
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
      title: LocalizedText(tr: 'Kehribar Spektrum', en: 'Amber Spectrum'),
      subtitle: LocalizedText(
        tr: 'Altın şafakta dörtlü renk harmonisini kur.',
        en: 'Align four-color harmony under the golden dawn.',
      ),
      themeId: PrismThemeId.solarAmber,
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
      title: LocalizedText(tr: 'Zümrüt Mercek', en: 'Emerald Lens'),
      subtitle: LocalizedText(
        tr: 'Orman ışığında kusursuz 2×2 çekirdek dök.',
        en: 'Forge flawless 2×2 prism cores beneath the canopy.',
      ),
      themeId: PrismThemeId.emeraldCanopy,
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
      title: LocalizedText(tr: 'Karnaval Finali', en: 'Carnival Overture'),
      subtitle: LocalizedText(
        tr: 'Festival ışıkları altında ilk bölümü taçlandır.',
        en: 'Crown the opening chapter beneath neon festival lights.',
      ),
      themeId: PrismThemeId.obsidian,
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
      title: LocalizedText(tr: 'Kırağı Şafağı', en: 'Rime Dawn'),
      subtitle: LocalizedText(
        tr: 'İnce buzul tabakasını ilk dokunuşla çatlat.',
        en: 'Fracture the crystalline frost with a clean first strike.',
      ),
      themeId: PrismThemeId.glacierCrystal,
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
      title: LocalizedText(tr: 'Kuzey Çatlağı', en: 'Aurora Fracture'),
      subtitle: LocalizedText(
        tr: 'Kutup perdeleri altında donmuş taşları çöz.',
        en: 'Thaw frosted crystals beneath flowing northern curtains.',
      ),
      themeId: PrismThemeId.polarAurora,
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
      title: LocalizedText(tr: 'Derin Buzul', en: 'Abyssal Thaw'),
      subtitle: LocalizedText(
        tr: 'Okyanus parıltısında çift darbeli kırılım başlat.',
        en: 'Trigger double-hit clears in the bioluminescent depths.',
      ),
      themeId: PrismThemeId.abyssalReef,
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
      title: LocalizedText(tr: 'Ametist Kış', en: 'Amethyst Winter'),
      subtitle: LocalizedText(
        tr: 'Mor vitray yağmurunda dört buz kristalini arıt.',
        en: 'Purify four frost-sealed gems through violet prism rain.',
      ),
      themeId: PrismThemeId.amethystDusk,
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
      title: LocalizedText(tr: 'Köz ve Kırağı', en: 'Ember & Frost'),
      subtitle: LocalizedText(
        tr: 'Yakut ocağın sıcaklığıyla çift katmanlı buzu erit.',
        en: 'Melt double-glazed frost with radiant forge embers.',
      ),
      themeId: PrismThemeId.crimsonForge,
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
      title: LocalizedText(tr: 'Yıldız Kubbesi', en: 'Starlight Dome'),
      subtitle: LocalizedText(
        tr: 'Buzul atölyesinin zirvesini göksel ışıkla mühürle.',
        en: 'Seal the glacial summit with celestial starlight.',
      ),
      themeId: PrismThemeId.celestialCrown,
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
      title: LocalizedText(tr: 'Vitray Mührü', en: 'Stained Seal'),
      subtitle: LocalizedText(
        tr: 'Kilitli taşı kırmak için 4+ renk rezonansını ateşle.',
        en: 'Ignite 4+ color resonance to shatter your first keystone.',
      ),
      themeId: PrismThemeId.amethystDusk,
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
      title: LocalizedText(tr: 'Mercan Kilidi', en: 'Lagoon Clasp'),
      subtitle: LocalizedText(
        tr: 'Lazer zinciriyle turkuaz mühürleri parçala.',
        en: 'Shatter turquoise clasps with cardinal optical lasers.',
      ),
      themeId: PrismThemeId.ceramic,
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
      title: LocalizedText(tr: 'Yakut Kemer', en: 'Ruby Archway'),
      subtitle: LocalizedText(
        tr: 'Örs’te 🌈 Joker dökerek kilitli kemeri aç.',
        en: 'Temper a 🌈 Wildcard in the Anvil to breach the arch.',
      ),
      themeId: PrismThemeId.crimsonForge,
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
      subtitle: LocalizedText(
        tr: 'Güneş ışınlarıyla üçlü mühür kilidini çöz.',
        en: 'Unlock triple gilded clasps with solar beam chains.',
      ),
      themeId: PrismThemeId.solarAmber,
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
      title: LocalizedText(tr: 'Neon Anahtar', en: 'Neon Keystone'),
      subtitle: LocalizedText(
        tr: 'Şok dalgası ve lazerlerle festival salonunu aç.',
        en: 'Crack the neon vault with shockwaves and laser hops.',
      ),
      themeId: PrismThemeId.obsidian,
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
      title: LocalizedText(tr: 'Buzul Mahzeni', en: 'Glacial Vault'),
      subtitle: LocalizedText(
        tr: 'Dört mührü ve buzu aynı akışta özgür bırak.',
        en: 'Free four sealed keystones and frost in a single flow.',
      ),
      themeId: PrismThemeId.glacierCrystal,
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
      title: LocalizedText(tr: 'Zümrüt Döküm', en: 'Emerald Foundry'),
      subtitle: LocalizedText(
        tr: 'Örs, 2×2 Döküm ve Lazer zincirini tek ritimde birleştir.',
        en: 'Unite Anvil, 2×2 Synthesis, and Lasers in one rhythm.',
      ),
      themeId: PrismThemeId.emeraldCanopy,
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
      title: LocalizedText(tr: 'Şeker Ekseni', en: 'Prismatic Axis'),
      subtitle: LocalizedText(
        tr: 'Dört çekirdeği hizalayıp çapraz kırılım zinciri kur.',
        en: 'Align four prism cores for a sweeping refraction chain.',
      ),
      themeId: PrismThemeId.atelier,
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
      title: LocalizedText(tr: 'Derin Kafes', en: 'Abyssal Lattice'),
      subtitle: LocalizedText(
        tr: 'Biyolüminesans kafeste buz ve mühür dengesini çöz.',
        en: 'Master frost and seals inside the bioluminescent lattice.',
      ),
      themeId: PrismThemeId.abyssalReef,
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
      title: LocalizedText(tr: 'Sakura Katedrali', en: 'Blossom Cathedral'),
      subtitle: LocalizedText(
        tr: 'Taç yaprakları altında ustalık katedralini aydınlat.',
        en: 'Illuminate the master cathedral beneath sakura petals.',
      ),
      themeId: PrismThemeId.aurora,
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
      title: LocalizedText(tr: 'Kuzey Tacı', en: 'Borealis Crown'),
      subtitle: LocalizedText(
        tr: 'Kutup ışıkları eşliğinde son büyük sınavı geç.',
        en: 'Conquer the penultimate trial beneath aurora ribbons.',
      ),
      themeId: PrismThemeId.polarAurora,
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
      title: LocalizedText(tr: 'Büyük Prizma Dökümü', en: 'The Grand Prism Forge'),
      subtitle: LocalizedText(
        tr: 'Tüm elementler bir arada — efsanevi mimar unvanını kazan.',
        en: 'All elements united — claim the Grand Architect crown.',
      ),
      themeId: PrismThemeId.celestialCrown,
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
