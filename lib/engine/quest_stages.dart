/// 1,000-stage architectural campaign for Prizma Görevi (Prism Quest).
///
/// Design invariants:
/// - 10 Grand Realms (Chapters I–X, 100 stages each = 1,000 stages total).
/// - Stages 1–24 are handcrafted signature opening trials teaching every mechanic.
/// - Stages 25–1000 are deterministically architected with escalating challenge:
///   dense crystal fortresses (up to 34 pre-seeded cells), higher ★/❄/🔒 targets,
///   tactical move budgets (`moveLimit`), adaptive polyomino pressure, and 100
///   epic Boss Milestones (#10, #20, ..., #1000).
/// - Zero consecutive stages share the same theme (`stages[i-1].themeId != stages[i].themeId`),
///   and every stage carries its own vibrant `backgroundVariant` hue shift.
/// - All 1,000 Turkish titles and all 1,000 English titles are 100% unique.
library;

import 'dart:math' as math;

import 'models.dart';

class QuestStageCatalog {
  const QuestStageCatalog._();

  static const int totalStages = 1000;
  static const int totalChapters = 10;
  static const int stagesPerChapter = 100;

  static const List<QuestStageSpec> _handcrafted24 = <QuestStageSpec>[
    // Opening Trials 1–6: Crystal Foundations
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
      backgroundVariant: 0,
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
      backgroundVariant: 1,
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
      backgroundVariant: 2,
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
      backgroundVariant: 3,
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
      backgroundVariant: 4,
    ),
    QuestStageSpec(
      stageNumber: 6,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Karnaval Finali', en: 'Carnival Overture'),
      subtitle: LocalizedText(
        tr: 'Festival ışıkları altında ilk sınavı taçlandır.',
        en: 'Crown the opening trials beneath neon festival lights.',
      ),
      themeId: PrismThemeId.obsidian,
      targetCores: 5,
      targetFrost: 0,
      targetLocks: 0,
      initialClutter: 13,
      twoStarScore: 1350,
      threeStarScore: 2400,
      backgroundVariant: 5,
    ),

    // Opening Trials 7–12: Glacial Atelier (❄ 2-Hit Frosted Crystals)
    QuestStageSpec(
      stageNumber: 7,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Kırağı Şafağı', en: 'Rime Dawn'),
      subtitle: LocalizedText(
        tr: 'İnce buzul tabakasını ilk dokunuşla çatlat.',
        en: 'Fracture the crystalline frost with a clean first strike.',
      ),
      themeId: PrismThemeId.glacierCrystal,
      targetCores: 2,
      targetFrost: 2,
      targetLocks: 0,
      initialClutter: 10,
      twoStarScore: 1000,
      threeStarScore: 1900,
      backgroundVariant: 6,
    ),
    QuestStageSpec(
      stageNumber: 8,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Kuzey Çatlağı', en: 'Aurora Fracture'),
      subtitle: LocalizedText(
        tr: 'Kutup perdeleri altında donmuş taşları çöz.',
        en: 'Thaw frosted crystals beneath flowing northern curtains.',
      ),
      themeId: PrismThemeId.polarAurora,
      targetCores: 2,
      targetFrost: 3,
      targetLocks: 0,
      initialClutter: 11,
      twoStarScore: 1150,
      threeStarScore: 2100,
      backgroundVariant: 7,
    ),
    QuestStageSpec(
      stageNumber: 9,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Derin Buzul', en: 'Abyssal Thaw'),
      subtitle: LocalizedText(
        tr: 'Okyanus parıltısında çift darbeli kırılım başlat.',
        en: 'Trigger double-hit clears in the bioluminescent depths.',
      ),
      themeId: PrismThemeId.abyssalReef,
      targetCores: 3,
      targetFrost: 3,
      targetLocks: 0,
      initialClutter: 12,
      twoStarScore: 1250,
      threeStarScore: 2300,
      backgroundVariant: 8,
    ),
    QuestStageSpec(
      stageNumber: 10,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Ametist Kış', en: 'Amethyst Winter'),
      subtitle: LocalizedText(
        tr: '👑 İlk Boss! Hamle bütçenle 4 buzu mor vitrayda arıt.',
        en: '👑 First Boss! Purify four frost gems before moves run out.',
      ),
      themeId: PrismThemeId.amethystDusk,
      targetCores: 3,
      targetFrost: 4,
      targetLocks: 0,
      initialClutter: 14,
      twoStarScore: 1450,
      threeStarScore: 2600,
      moveLimit: 24,
      isBossStage: true,
      backgroundVariant: 9,
    ),
    QuestStageSpec(
      stageNumber: 11,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Köz ve Kırağı', en: 'Ember & Frost'),
      subtitle: LocalizedText(
        tr: 'Yakut ocağın sıcaklığıyla çift katmanlı buzu erit.',
        en: 'Melt double-glazed frost with radiant forge embers.',
      ),
      themeId: PrismThemeId.crimsonForge,
      targetCores: 3,
      targetFrost: 5,
      targetLocks: 0,
      initialClutter: 14,
      twoStarScore: 1500,
      threeStarScore: 2700,
      backgroundVariant: 10,
    ),
    QuestStageSpec(
      stageNumber: 12,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Yıldız Kubbesi', en: 'Starlight Dome'),
      subtitle: LocalizedText(
        tr: 'Buzul atölyesinin zirvesini göksel ışıkla mühürle.',
        en: 'Seal the glacial summit with celestial starlight.',
      ),
      themeId: PrismThemeId.celestialCrown,
      targetCores: 3,
      targetFrost: 6,
      targetLocks: 0,
      initialClutter: 15,
      twoStarScore: 1650,
      threeStarScore: 2900,
      backgroundVariant: 11,
    ),

    // Opening Trials 13–18: Sealed Stained Glass (🔒 Locked Keystones + Move Budget)
    QuestStageSpec(
      stageNumber: 13,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Vitray Mührü', en: 'Stained Seal'),
      subtitle: LocalizedText(
        tr: 'Kilitli taşı kırmak için 4+ renk rezonansını ateşle.',
        en: 'Ignite 4+ color resonance to shatter your first keystone.',
      ),
      themeId: PrismThemeId.amethystDusk,
      targetCores: 2,
      targetFrost: 1,
      targetLocks: 1,
      initialClutter: 12,
      twoStarScore: 1200,
      threeStarScore: 2200,
      moveLimit: 24,
      backgroundVariant: 12,
    ),
    QuestStageSpec(
      stageNumber: 14,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Mercan Kilidi', en: 'Lagoon Clasp'),
      subtitle: LocalizedText(
        tr: 'Lazer zinciriyle turkuaz mühürleri parçala.',
        en: 'Shatter turquoise clasps with cardinal optical lasers.',
      ),
      themeId: PrismThemeId.ceramic,
      targetCores: 2,
      targetFrost: 2,
      targetLocks: 2,
      initialClutter: 13,
      twoStarScore: 1350,
      threeStarScore: 2400,
      moveLimit: 25,
      backgroundVariant: 13,
    ),
    QuestStageSpec(
      stageNumber: 15,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Yakut Kemer', en: 'Ruby Archway'),
      subtitle: LocalizedText(
        tr: 'Örs’te 🌈 Joker dökerek kilitli kemeri aç.',
        en: 'Temper a 🌈 Wildcard in the Anvil to breach the arch.',
      ),
      themeId: PrismThemeId.crimsonForge,
      targetCores: 3,
      targetFrost: 2,
      targetLocks: 2,
      initialClutter: 14,
      twoStarScore: 1500,
      threeStarScore: 2600,
      moveLimit: 26,
      backgroundVariant: 14,
    ),
    QuestStageSpec(
      stageNumber: 16,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Altın Kelepçe', en: 'Gilded Clasp'),
      subtitle: LocalizedText(
        tr: 'Güneş ışınlarıyla üçlü mühür kilidini çöz.',
        en: 'Unlock triple gilded clasps with solar beam chains.',
      ),
      themeId: PrismThemeId.solarAmber,
      targetCores: 2,
      targetFrost: 3,
      targetLocks: 3,
      initialClutter: 15,
      twoStarScore: 1650,
      threeStarScore: 2800,
      moveLimit: 27,
      backgroundVariant: 15,
    ),
    QuestStageSpec(
      stageNumber: 17,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Neon Anahtar', en: 'Neon Keystone'),
      subtitle: LocalizedText(
        tr: 'Şok dalgası ve lazerlerle festival salonunu aç.',
        en: 'Crack the neon vault with shockwaves and laser hops.',
      ),
      themeId: PrismThemeId.obsidian,
      targetCores: 3,
      targetFrost: 2,
      targetLocks: 3,
      initialClutter: 16,
      twoStarScore: 1750,
      threeStarScore: 3000,
      moveLimit: 27,
      backgroundVariant: 16,
    ),
    QuestStageSpec(
      stageNumber: 18,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Buzul Mahzeni', en: 'Glacial Vault'),
      subtitle: LocalizedText(
        tr: 'Dört mührü ve buzu aynı akışta özgür bırak.',
        en: 'Free four sealed keystones and frost in a single flow.',
      ),
      themeId: PrismThemeId.glacierCrystal,
      targetCores: 3,
      targetFrost: 3,
      targetLocks: 4,
      initialClutter: 17,
      twoStarScore: 1900,
      threeStarScore: 3200,
      moveLimit: 28,
      backgroundVariant: 17,
    ),

    // Opening Trials 19–24: Master Foundations
    QuestStageSpec(
      stageNumber: 19,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Zümrüt Döküm', en: 'Emerald Foundry'),
      subtitle: LocalizedText(
        tr: 'Örs, 2×2 Döküm ve Lazer zincirini tek ritimde birleştir.',
        en: 'Unite Anvil, 2×2 Synthesis, and Lasers in one rhythm.',
      ),
      themeId: PrismThemeId.emeraldCanopy,
      targetCores: 3,
      targetFrost: 3,
      targetLocks: 2,
      initialClutter: 16,
      twoStarScore: 1800,
      threeStarScore: 3200,
      moveLimit: 27,
      backgroundVariant: 18,
    ),
    QuestStageSpec(
      stageNumber: 20,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Şeker Ekseni', en: 'Prismatic Axis'),
      subtitle: LocalizedText(
        tr: '👑 Boss! Dört çekirdeği hizalayıp çapraz lazer zinciri kur.',
        en: '👑 Boss! Align four prism cores for a sweeping laser chain.',
      ),
      themeId: PrismThemeId.atelier,
      targetCores: 4,
      targetFrost: 3,
      targetLocks: 3,
      initialClutter: 18,
      twoStarScore: 2050,
      threeStarScore: 3500,
      moveLimit: 27,
      isBossStage: true,
      backgroundVariant: 19,
    ),
    QuestStageSpec(
      stageNumber: 21,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Derin Kafes', en: 'Abyssal Lattice'),
      subtitle: LocalizedText(
        tr: 'Biyolüminesans kafeste buz ve mühür dengesini çöz.',
        en: 'Master frost and seals inside the bioluminescent lattice.',
      ),
      themeId: PrismThemeId.abyssalReef,
      targetCores: 3,
      targetFrost: 4,
      targetLocks: 3,
      initialClutter: 18,
      twoStarScore: 2100,
      threeStarScore: 3600,
      moveLimit: 28,
      backgroundVariant: 20,
    ),
    QuestStageSpec(
      stageNumber: 22,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Sakura Katedrali', en: 'Blossom Cathedral'),
      subtitle: LocalizedText(
        tr: 'Taç yaprakları altında ustalık katedralini aydınlat.',
        en: 'Illuminate the master cathedral beneath sakura petals.',
      ),
      themeId: PrismThemeId.aurora,
      targetCores: 4,
      targetFrost: 4,
      targetLocks: 3,
      initialClutter: 19,
      twoStarScore: 2250,
      threeStarScore: 3800,
      moveLimit: 29,
      backgroundVariant: 21,
    ),
    QuestStageSpec(
      stageNumber: 23,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Kuzey Tacı', en: 'Borealis Crown'),
      subtitle: LocalizedText(
        tr: 'Kutup ışıkları eşliğinde zorlu sınavı geç.',
        en: 'Conquer the intense trial beneath aurora ribbons.',
      ),
      themeId: PrismThemeId.polarAurora,
      targetCores: 4,
      targetFrost: 4,
      targetLocks: 4,
      initialClutter: 20,
      twoStarScore: 2400,
      threeStarScore: 4100,
      moveLimit: 29,
      backgroundVariant: 22,
    ),
    QuestStageSpec(
      stageNumber: 24,
      chapterNumber: 1,
      title: LocalizedText(tr: 'Büyük Prizma Dökümü', en: 'The Grand Prism Forge'),
      subtitle: LocalizedText(
        tr: 'Tüm elementler bir arada — 1.000 bölümlük yolculuğa hazır mısın?',
        en: 'All elements united — enter the 1,000-stage grand gauntlet!',
      ),
      themeId: PrismThemeId.celestialCrown,
      targetCores: 5,
      targetFrost: 5,
      targetLocks: 4,
      initialClutter: 21,
      twoStarScore: 2600,
      threeStarScore: 4500,
      moveLimit: 31,
      backgroundVariant: 23,
    ),
  ];

  // 40 distinct Turkish prefixes × 25 distinct Turkish nouns = 1,000 unique stage titles.
  static const List<String> _trPrefixes = <String>[
    'Güneşli',
    'Işıltılı',
    'Turkuaz',
    'Mercan',
    'Zümrüt',
    'Safir',
    'Yakut',
    'Ametist',
    'Topaz',
    'Opal',
    'Kehribar',
    'İnci',
    'Gökkuşağı',
    'Kristal',
    'Buzul',
    'Kutup',
    'Bahar',
    'Şafak',
    'Yıldız',
    'Galaksi',
    'Kuyruklu',
    'Sihirli',
    'Parlak',
    'Coşkulu',
    'Festival',
    'Tropik',
    'Büyülü',
    'Efsanevi',
    'Görkemli',
    'Sonsuz',
    'Kızıl',
    'Mavi',
    'Altın',
    'Gümüş',
    'Elmas',
    'Lale',
    'Mimoza',
    'Lavanta',
    'Papatya',
    'Anka',
  ];

  static const List<String> _trNouns = <String>[
    'Kule',
    'Vadi',
    'Köprü',
    'Saray',
    'Bahçe',
    'Lagün',
    'Fener',
    'Tapınak',
    'Kemer',
    'Kale',
    'Şelale',
    'Zirve',
    'Ova',
    'Liman',
    'Sütun',
    'Çember',
    'Labirent',
    'Ayna',
    'Ocak',
    'Körfez',
    'Hazine',
    'Kubbe',
    'Hisar',
    'Taht',
    'Pınar',
  ];

  // 40 distinct English prefixes × 25 distinct English nouns = 1,000 unique stage titles.
  static const List<String> _enPrefixes = <String>[
    'Sunlit',
    'Radiant',
    'Turquoise',
    'Coral',
    'Emerald',
    'Sapphire',
    'Ruby',
    'Amethyst',
    'Topaz',
    'Opal',
    'Amber',
    'Pearl',
    'Rainbow',
    'Crystal',
    'Glacial',
    'Polar',
    'Spring',
    'Dawn',
    'Starlight',
    'Galaxy',
    'Comet',
    'Mystic',
    'Luminous',
    'Vibrant',
    'Festival',
    'Tropical',
    'Enchanted',
    'Mythic',
    'Imperial',
    'Infinite',
    'Crimson',
    'Azure',
    'Golden',
    'Silver',
    'Diamond',
    'Lotus',
    'Mimosa',
    'Lavender',
    'Sunbeam',
    'Phoenix',
  ];

  static const List<String> _enNouns = <String>[
    'Spire',
    'Valley',
    'Bridge',
    'Palace',
    'Garden',
    'Lagoon',
    'Beacon',
    'Temple',
    'Arch',
    'Citadel',
    'Cascade',
    'Summit',
    'Meadow',
    'Harbor',
    'Pillar',
    'Halo',
    'Labyrinth',
    'Mirror',
    'Hearth',
    'Cove',
    'Treasury',
    'Rotunda',
    'Bastion',
    'Sanctum',
    'Fountain',
  ];

  static const List<LocalizedText> _lorePool = <LocalizedText>[
    LocalizedText(
      tr: 'Dar hamle bütçesinde 4+ renk rezonansıyla mühürleri parçala.',
      en: 'Shatter locked seals with 4+ color resonance on a tight move budget.',
    ),
    LocalizedText(
      tr: 'Örs’te 🌈 Joker biriktirip çift katmanlı buz duvarlarını erit.',
      en: 'Temper a 🌈 Wildcard in the Anvil to melt double-glazed frost walls.',
    ),
    LocalizedText(
      tr: '★→★ optik lazer zinciri kurarak tek hamlede çoklu hedef temizle.',
      en: 'Chain ★→★ optical lasers to wipe multiple targets in a single move.',
    ),
    LocalizedText(
      tr: '2×2 kristal senteziyle yeni ★ çekirdek dök ve tahtayı aç.',
      en: 'Synthesize fresh ★ cores via 2×2 color quads to break open the board.',
    ),
    LocalizedText(
      tr: 'Taktik enerjini koru; kritik anda 90° döndürme veya 3×3 Nova kurtarır.',
      en: 'Manage tactical energy — a timely 90° rotate or 3×3 Nova saves the run.',
    ),
    LocalizedText(
      tr: 'Yoğun kristal kafeste her hamleyi iki adım önden planla.',
      en: 'Plan two moves ahead inside this dense crystal fortress.',
    ),
  ];

  static final List<QuestStageSpec> stages = _buildAllStages();

  static List<QuestStageSpec> _buildAllStages() {
    final result = List<QuestStageSpec>.from(_handcrafted24);
    const themes = PrismThemeId.values;
    final usedTr = <String>{for (final s in result) s.title.tr};
    final usedEn = <String>{for (final s in result) s.title.en};

    var nameCursor = 0;
    for (var n = 25; n <= totalStages; n++) {
      final chapter = ((n - 1) ~/ stagesPerChapter) + 1; // 1..10
      final isBoss = n % 10 == 0;
      final isGrandFinal = n == totalStages;

      // Guarantee zero consecutive theme repeats across all 1,000 stages while
      // rotating lively palettes using a coprime stride per chapter.
      final prevTheme = result.last.themeId;
      final stride = const <int>[1, 5, 7, 11][chapter % 4];
      var themeIdx = ((n - 1) * stride + chapter * 3) % themes.length;
      if (themes[themeIdx] == prevTheme) {
        themeIdx = (themeIdx + 1) % themes.length;
      }
      final themeId = themes[themeIdx];

      // Pick guaranteed-unique bilingual poetic title.
      late String trTitle;
      late String enTitle;
      if (isGrandFinal) {
        trTitle = 'Ebedi Prizma Tahtı';
        enTitle = 'Eternal Prism Throne';
      } else {
        while (true) {
          final q = (nameCursor ~/ _trNouns.length) % _trPrefixes.length;
          final r = nameCursor % _trNouns.length;
          final pIdx = (q * 7) % _trPrefixes.length;
          final nIdx = (r * 9 + q * 3) % _trNouns.length;
          nameCursor++;
          final candTr = '${_trPrefixes[pIdx]} ${_trNouns[nIdx]}';
          final candEn = '${_enPrefixes[pIdx]} ${_enNouns[nIdx]}';
          if (!usedTr.contains(candTr) && !usedEn.contains(candEn)) {
            trTitle = candTr;
            enTitle = candEn;
            break;
          }
        }
      }
      usedTr.add(trTitle);
      usedEn.add(enTitle);

      // Progressive hardcore difficulty scaling across stages 25..1000!
      final progress = (n - 25) / (totalStages - 25); // 0.0 -> 1.0
      final wave = (n % 10) == 0 ? 3 : ((n % 5) == 0 ? 2 : (n % 3));

      final cores = isGrandFinal
          ? 10
          : (4 + (progress * 5.5).floor() + (isBoss ? 2 : (wave >= 2 ? 1 : 0)))
                .clamp(4, 11);
      final frost = isGrandFinal
          ? 12
          : (4 + (progress * 6.5).floor() + (isBoss ? 2 : (n % 4 == 0 ? 1 : 0)))
                .clamp(4, 12);
      final locks = isGrandFinal
          ? 10
          : (3 + (progress * 5.5).floor() + (isBoss ? 2 : (n % 3 == 0 ? 1 : 0)))
                .clamp(3, 10);

      // Dense pre-filled board (up to 34/64 cells) — hard to breathe, always solvable.
      final totalTargets = cores + frost + locks;
      final clutter = isGrandFinal
          ? 34
          : math.min(
              34,
              math.max(
                totalTargets + 2,
                18 + (progress * 14).round() + (isBoss ? 3 : 0),
              ),
            );

      // Tight tactical move budget that gets progressively sharper toward Stage 1,000!
      final rawMoves =
          (totalTargets * 1.95).round() +
          15 -
          chapter -
          (isBoss ? 2 : 0) -
          (progress > 0.65 ? 2 : 0);
      final moveLimit = isGrandFinal ? 34 : rawMoves.clamp(18, 42);

      final twoStar = 2400 + n * 18 + (isBoss ? 600 : 0);
      final threeStar = (twoStar * 1.65).round();

      final baseLore = _lorePool[(n * 3 + chapter) % _lorePool.length];
      final subtitle = isGrandFinal
          ? const LocalizedText(
              tr: '👑 1000. FİNAL BOSS! Tüm ustalık mekaniklerini birleştir ve efsane ol!',
              en: '👑 STAGE 1000 FINAL BOSS! Unite every mastery mechanic to claim immortality!',
            )
          : isBoss
          ? LocalizedText(
              tr: '👑 BOSS #$n ($moveLimit hamle)! ${baseLore.tr}',
              en: '👑 BOSS #$n ($moveLimit moves)! ${baseLore.en}',
            )
          : baseLore;

      result.add(
        QuestStageSpec(
          stageNumber: n,
          chapterNumber: chapter,
          title: LocalizedText(tr: trTitle, en: enTitle),
          subtitle: subtitle,
          themeId: themeId,
          targetCores: cores,
          targetFrost: frost,
          targetLocks: locks,
          initialClutter: clutter,
          twoStarScore: twoStar,
          threeStarScore: threeStar,
          moveLimit: moveLimit,
          difficultyTier: chapter,
          isBossStage: isBoss,
          backgroundVariant: n - 1,
        ),
      );
    }
    return List<QuestStageSpec>.unmodifiable(result);
  }

  static QuestStageSpec byNumber(int stageNumber) {
    final clamped = stageNumber.clamp(1, totalStages);
    return stages[clamped - 1];
  }

  static LocalizedText chapterTitle(int chapter) {
    switch (chapter.clamp(1, totalChapters)) {
      case 1:
        return const LocalizedText(
          tr: 'Diyar I (1–100) • Kristal Uyanışı',
          en: 'Realm I (1–100) • Crystal Awakening',
        );
      case 2:
        return const LocalizedText(
          tr: 'Diyar II (101–200) • Tropik Vitray',
          en: 'Realm II (101–200) • Tropical Stained Glass',
        );
      case 3:
        return const LocalizedText(
          tr: 'Diyar III (201–300) • Buzul Labirenti',
          en: 'Realm III (201–300) • Glacial Labyrinth',
        );
      case 4:
        return const LocalizedText(
          tr: 'Diyar IV (301–400) • Mühürlü Hisar',
          en: 'Realm IV (301–400) • Sealed Citadel',
        );
      case 5:
        return const LocalizedText(
          tr: 'Diyar V (401–500) • Lazer Ekseni',
          en: 'Realm V (401–500) • Laser Axis',
        );
      case 6:
        return const LocalizedText(
          tr: 'Diyar VI (501–600) • Zümrüt Dökümhane',
          en: 'Realm VI (501–600) • Emerald Foundry',
        );
      case 7:
        return const LocalizedText(
          tr: 'Diyar VII (601–700) • Yakut Fırtınası',
          en: 'Realm VII (601–700) • Ruby Tempest',
        );
      case 8:
        return const LocalizedText(
          tr: 'Diyar VIII (701–800) • Kutup Katedrali',
          en: 'Realm VIII (701–800) • Aurora Cathedral',
        );
      case 9:
        return const LocalizedText(
          tr: 'Diyar IX (801–900) • Ametist Kuşatma',
          en: 'Realm IX (801–900) • Amethyst Siege',
        );
      default:
        return const LocalizedText(
          tr: 'Diyar X (901–1000) • Ebedi Prizma',
          en: 'Realm X (901–1000) • Eternal Prism',
        );
    }
  }
}
