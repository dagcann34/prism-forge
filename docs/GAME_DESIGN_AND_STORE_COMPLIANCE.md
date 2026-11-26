# PRISM FORGE (Prizma Döküm) — Oyun Tasarımı ve App Store 4.3 / Google Play Uyumluluk Rehberi

## 1. Neden App Store Guideline 4.3 (Spam) ve Google Play Klon Reddi Yemez?

Apple App Store **Guideline 4.3 (Design – Spam)** ve Google Play **Tekrarlayan İçerik / Klon** incelemeleri genellikle şu hatalardan dolayı ret verir:
- Mağaza başlığında veya paket adında başka bir oyunun markasını çağrıştıran genel kelimeler ("Block Blast", "Woodoku" vb.) kullanmak.
- Tek bir sonsuz 8×8 moddan ibaret, renklerin işlevsiz olduğu ve özgün mekanik sunmayan şablon oyunlar yüklemek.
- Reklam/SDK ağırlıklı, görsel kimliği jenerik şablonlar kullanmak.

**PRISM FORGE (Prizma Döküm)** bu risklerin tamamını mimari düzeyde ortadan kaldırır:

| Alan | Klasik Blok Klonları | PRISM FORGE (Prizma Döküm) |
|---|---|---|
| **Marka & Bundle ID** | `blockblast.*` jenerik adlar | `com.prismforge.app` — Özgün **Prizma Döküm / PRISM FORGE** kristal ışık kimliği |
| **Renk Mekaniği** | Renkler tamamen süs | **Prizma Rezonansı:** 4+ aynı renkli temizlik `×1.5` puan verir **ve kilitli taşları kırar** |
| **Özel Blok Ekosistemi** | Yok | **★ Prizma Çekirdeği** (2 hücrelik Çapraz Şok Dalgası), **❄ Buzlu Blok** (2 vuruş), **🔒 Kilitli Taş** (yalnızca Rezonans/Şok/Nova ile açılır) |
| **Taktik Enerji Sistemi** | Saf rastgele şans | Temizliklerden dolan enerji ile **90° Döndür (35%)** ve **Kuantum Nova 3×3 (100%)** + **Adil Tepsi Yöneticisi** |
| **Oyun Modları** | Tek mod | **4 farklı mod:** ∞ Sonsuz Akış, ★ 24 Mimari Bölümlü Prizma Görevi (4 Chapter + Yıldız), 📅 Ortak Tohumlu Günlük Meydan Okuma (`YYYY-MM-DD`), ⚡ 90sn Hız Düellosu |
| **Ses & Gizlilik** | Ağır reklam/takip SDK'ları | **%100 Çevrimdışı**, sıfır reklam/izleyici, `NSPrivacyTracking = false`, `PrivacyInfo.xcprivacy` hazır, sıfır harici bağımlılık, prosedürel pentatonik ses sentezi + native Haptics |

---

## 2. Mağaza Metadata Önerisi (App Review İçin)

- **TR Uygulama Adı:** `Prizma Döküm: Kristal Bulmaca`
- **TR Alt Başlık:** `Renk Rezonansı ve Taktik Prizma`
- **EN Uygulama Adı:** `Prism Forge: Crystal Tactics`
- **EN Alt Başlık:** `Color Resonance & Prism Puzzle`
- **Kaçınılacak Anahtar Kelimeler:** Başlıkta ve açıklamada rakip marka adları (`Block Blast`, `Tetris`, `Woodoku`) **kesinlikle geçmemelidir**.

---

## 3. Teknik Doğrulama & Mağaza Derleme Komutları

```bash
# 1. Saf Dart kural motoru & 24 bölüm testi
dart run tool/verify_engine.dart

# 2. Flutter statik analiz & widget testleri
flutter analyze
flutter test

# 3. Android Play Store paketi (.aab)
# (Önce android/key.properties.example dosyasını android/key.properties olarak kopyalayıp keystore bilgilerinizi girin)
flutter build appbundle --release

# 4. iOS App Store arşivi (.ipa)
flutter build ipa --release
```
