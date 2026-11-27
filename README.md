# PRISM FORGE (Prizma Döküm)

Özgün kristal optik mekaniklerine sahip, çevrimdışı öncelikli **Flutter iOS & Android** taktiksel bulmaca oyunu (`com.prismforge.app`).

## İmza Mekanikler (*Örs → Döküm → Lazer Döngüsü*)
- **Altın Prizma Örsü (*Prism Anvil*):** Her hamlede 1 kez ücretsiz parça sakla/takas et; 3 turda **🌈 Gökkuşağı Joker Cam + ★ Prizma Çekirdeğine** dönüşür.
- **2×2 Kristal Döküm (*Prism Synthesis*):** Aynı renkten 2×2 kare kenetleyerek tahtada yeni `★` Prizma Çekirdeği dök ve içindeki `❄` Buzu çatlat.
- **★→★ Kırılım Zinciri (*Optical Chain-Refraction*):** Hizalı `★` çekirdekler arasında altın lazer ışını sıçratarak `🔒` Mühürlü Taşları ve `❄` Buzları parçala.
- **Prizma Rezonansı (`×1.5`) & Coşku (*Prism Fever ×2*):** 4+ aynı renkli temizlik `×1.5` puan verir ve mühürleri kırar; 3 ardışık temizlik Gökkuşağı Coşkusunu (`×2`) ateşler.
- **Taktik Enerji Çubuğu:** `90° Döndür (35%)`, `Kuantum Nova 3×3 (100%)` ve **Adil Tepsi Yöneticisi**.
- **4 Oyun Modu:** `∞ Sonsuz Akış`, `★ 24 Mimari Bölüm` (4 Chapter), `📅 Günlük Meydan Okuma` (`YYYY-MM-DD`), `⚡ 90s Hız Düellosu`.
- **4 Cıvıl Cıvıl Tema:** `🌴 Tropik Mercan`, `🍬 Şeker Vitray`, `🌸 Bahar Bahçesi`, `🎡 Karnaval Neon`.
- **12 Başarım & Kupa Vitrini + AdMob Mimarisi:** Zorunlu giriş duvarı olmadan isteğe bağlı Game Center / Play Games senkronizasyonu, Ödüllü *Son Nefes* kurtarma, 180sn frekans kilitli akıllı geçiş reklamı ve güvenli alt banner alanı.

## Hızlı Doğrulama & Derleme

```bash
# Saf Dart kural motoru, 24 bölüm, AdMob politikası & 12 Başarım testi
dart run tool/verify_engine.dart

# Flutter analiz & widget testleri
flutter pub get
flutter analyze
flutter test

# Android Release APK & iOS Simulator
flutter build apk --release
flutter build ios --simulator --no-codesign
```

## Dokümantasyon
- [Oyun Tasarımı & App Store 4.3 / Google Play Uyumluluğu](docs/GAME_DESIGN_AND_STORE_COMPLIANCE.md)
- [AdMob & Game Center / Google Play Games Kurulum Rehberi](docs/ADMOB_AND_GAMES_SETUP.md)
