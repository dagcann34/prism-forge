# PRISM FORGE — AdMob Reklamları + Game Center / Google Play Games Kurulum Rehberi

## 1. Google / Apple Giriş Neden Zorunlu Olmamalı? (Mağaza Stratejisi)

PRISM FORGE gibi akış odaklı bir mobil bulmaca oyununda açılışa **Google / Apple e-posta girişi** koymak:
- İlk açılışta oyuncu kaybını **%40–60** artırır.
- Apple App Store **Guideline 5.1.1(v)** gereği zorunlu **Sign in with Apple + Uygulama İçi Hesap Silme** ekranı ve sunucu tarafı doğrulama gerektirir.

**Bunun yerine uygulanan altın standart:**
- Oyuncu **0. saniyede misafir olarak** hemen oynar (sıfır giriş duvarı).
- **Kupa & Profil** ekranında isteğe bağlı **iOS Game Center** / **Android Google Play Games** bağlantısı bulunur ([PlatformGamesService](../lib/services/achievements_service.dart)): şifre yok, hesap silme yükümlülüğü yok, doğal OS liderlik tablosu ve **12 Başarım** doğrudan çalışır.

---

## 2. AdMob Reklam Mimarisi ([ad_service.dart](../lib/services/ad_service.dart))

Geliri maksimize ederken oyuncu deneyimini ve AdMob/App Store politikalarını koruyan 3 katman:

| Format | Yerleşim | Politika & Koruma |
|---|---|---|
| **Ödüllü Video (Rewarded)** | Oyun Bitti ekranında **"Son Nefes (3×3 Kurtarma + 100% Enerji)"** (oyun başına en fazla 1 kez) ve isteğe bağlı **"+100% Enerji"** | Tamamen oyuncu onaylı (`opt-in`), en yüksek eCPM |
| **Akıllı Geçiş (Interstitial)** | Yalnızca tur sonunda | İlk 2 turda **asla** gösterilmez; en az **180 saniye** bekleme süresi ([`AdFrequencyPolicy`](../lib/services/ad_service.dart)) |
| **Uyarlanabilir Banner** | En alt bilgi çubuğunun altında izole güvenli bant | 3 parça tepsisi ve Örs dokunma alanından ayrı (yanlış tıklama ihlali riski sıfır) |

---

## 3. Gerçek AdMob ID'lerini Bağlama (Yayına Çıkarken 4 Adım)

1. `pubspec.yaml` içine ekleyin:
   ```yaml
   dependencies:
     google_mobile_ads: ^5.2.0
   ```
2. **Android (`android/app/src/main/AndroidManifest.xml`):** `<application>` içine AdMob App ID ekleyin:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
   ```
3. **iOS (`ios/Runner/Info.plist`):** `GADApplicationIdentifier`, `NSUserTrackingUsageDescription` (ATT izni — isteğe bağlı; reddedilse bile kişiselleştirilmemiş reklam çalışır) ve Google'ın `SKAdNetworkItems` listesini ekleyin.
4. **Derleme sırasında canlı Reklam Birimi ID'lerini verin** (kaynak koda yazmadan!):
   ```bash
   flutter build appbundle --release \
     --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-... \
     --dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=ca-app-pub-... \
     --dart-define=ADMOB_ANDROID_REWARDED_ID=ca-app-pub-...
   ```
   *(Varsayılan olarak Google'ın resmi test ID'leri tanımlıdır — geliştirme sırasında hesabınızın banlanmasını önler.)*
