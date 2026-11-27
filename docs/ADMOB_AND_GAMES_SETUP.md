# PRISM FORGE — Google AdMob Gelir & Mağaza Kurulum Rehberi

## 1. Gelir Mimarisi (Oyuncu Dostu + Maksimum ARPDAU)

PRISM FORGE içine **`google_mobile_ads: ^6.0.0`** SDK'sı, **Google UMP (GDPR/EEA/UK Gizlilik Onayı)**, **iOS ATT & 43 resmi SKAdNetwork ağı** ve **3 katmanlı gelir stratejisi** tam olarak entegre edilmiştir ([`PlatformAdService`](../lib/services/ad_service.dart), [`AdFrequencyPolicy`](../lib/engine/ad_policy.dart)):

| Reklam Formatı | Yerleşim | Politika & Koruma |
|---|---|---|
| **Ödüllü Video #1 — Son Nefes Kurtarma** (`rescueRevive`) | Oyun Bitti / Süre Doldu ekranında merkez 3×3 alanı temizler + **%100 Enerji** (+20 sn Hız Modu) verir | Tur başına en fazla **1 kez**, tamamen oyuncu onaylı (`opt-in`), en yüksek eCPM |
| **Ödüllü Video #2 — +100% Nova Enerjisi** (`energyBoost`) | Enerji çubuğundaki altın **`+100%`** düğmesi — anında 3×3 Kuantum Nova doldurur | Tur başına en fazla **2 kez**, izlenince 90 sn geçiş reklamı koruması açılır |
| **Ödüllü Video #3 — Örs Hızlı Döküm** (`instantTemper`) | Örs'te bekleyen parçayı 3 tur beklemeden anında **`🌈 Joker ★`** yapar | Tur başına en fazla **1 kez**, taktik dengeyi bozmadan yüksek ödüllü izlenme sağlar |
| **Akıllı Geçiş Reklamı (Interstitial)** | Yalnızca bölüm/tur sonunda "Sonraki Bölüm / Tekrar Oyna" geçişinde | **1. tur tamamen reklamsız**, en az **120 saniye** bekleme süresi + herhangi bir Ödüllü Video sonrası **90 saniye dokunulmazlık** |
| **Uyarlanabilir Banner (Anchored Adaptive)** | Alt bilgi çubuğunun altında izole güvenli bant | 3 parça tepsisi ve Örs dokunma alanından ayrı — yanlış tıklama ihlali riski sıfır |

> **Ses & Gizlilik Koruması:** Tam ekran reklamlar açıldığında oyun sesleri otomatik susturulur ve reklam kapanınca geri açılır. Avrupa Birliği (EEA) / Birleşik Krallık kullanıcılarına Google UMP rıza formu gösterilir ve **Kupa Vitrini** içinde **"Reklam Gizliliği"** düğmesi otomatik aktifleşir.

---

## 2. Kendi AdMob Hesabınızdan Canlı Gelir Almak (Tek Seferlik 2 Dakikalık Kurulum)

Kod şu anda hesabınızın geliştirme/test sürecinde askıya alınmaması için **Google'ın resmi test ID'leri** ile güvenli olarak derlenir. Gerçek para kazanmayı açmak için:

### Adım 1 — Google AdMob Panelinde Uygulama & 3 Birim Oluşturun
1. [admob.google.com](https://admob.google.com) adresinde oturum açın (**Android** ve **iOS** için ayrı uygulama ekleyin).
2. Her platform için 3 reklam birimi oluşturun:
   - **Banner** (Uyarlanabilir / Anchored Adaptive)
   - **Geçiş Reklamı** (Interstitial)
   - **Ödüllü Reklam** (Rewarded)

### Adım 2 — GitHub Repository Secrets'a 8 ID'yi Ekleyin
GitHub deponuzda **Settings → Secrets and variables → Actions → New repository secret** yolundan aşağıdaki gizli anahtarları ekleyin (kaynak koda yazmanıza gerek yoktur; CI her derlemede otomatik enjekte eder!):

| GitHub Secret Adı | Örnek Değer | Kullanıldığı Yer |
|---|---|---|
| `ADMOB_ANDROID_APP_ID` | `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` | `AndroidManifest.xml` (`manifestPlaceholder`) |
| `ADMOB_ANDROID_BANNER_ID` | `ca-app-pub-XXXXXXXXXXXXXXXX/1111111111` | Android Adaptive Banner |
| `ADMOB_ANDROID_INTERSTITIAL_ID` | `ca-app-pub-XXXXXXXXXXXXXXXX/2222222222` | Android Interstitial |
| `ADMOB_ANDROID_REWARDED_ID` | `ca-app-pub-XXXXXXXXXXXXXXXX/3333333333` | Android Rewarded (3 yerleşim) |
| `ADMOB_IOS_APP_ID` | `ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ` | `Info.plist` (`GADApplicationIdentifier`) |
| `ADMOB_IOS_BANNER_ID` | `ca-app-pub-XXXXXXXXXXXXXXXX/4444444444` | iOS Adaptive Banner |
| `ADMOB_IOS_INTERSTITIAL_ID` | `ca-app-pub-XXXXXXXXXXXXXXXX/5555555555` | iOS Interstitial |
| `ADMOB_IOS_REWARDED_ID` | `ca-app-pub-XXXXXXXXXXXXXXXX/6666666666` | iOS Rewarded (3 yerleşim) |

### Adım 3 — `app-ads.txt` Dosyasını Yayınlayın (Gelir Kaybını Önlemek İçin Kritik!)
Geliştirici web sitenizin kök dizinine (`https://siteniz.com/app-ads.txt`) [`docs/app-ads.txt.template`](./app-ads.txt.template) içindeki satırı kendi `pub-XXXXXXXXXXXXXXXX` kimliğinizle yükleyin ve Play Store / App Store mağaza sayfanıza bu web sitesi URL'sini girin.

### Adım 4 — Yerel Mağaza Derlemesi Almak İsterseniz
```bash
# Android Google Play Store (.aab)
ADMOB_ANDROID_APP_ID="ca-app-pub-XXXX~YYYY" \
flutter build appbundle --release \
  --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-XXXX/1111 \
  --dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=ca-app-pub-XXXX/2222 \
  --dart-define=ADMOB_ANDROID_REWARDED_ID=ca-app-pub-XXXX/3333

# iOS App Store (.ipa)
echo "ADMOB_IOS_APP_ID = ca-app-pub-XXXX~ZZZZ" > ios/Flutter/AdMob.xcconfig
flutter build ipa --release \
  --dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-XXXX/4444 \
  --dart-define=ADMOB_IOS_INTERSTITIAL_ID=ca-app-pub-XXXX/5555 \
  --dart-define=ADMOB_IOS_REWARDED_ID=ca-app-pub-XXXX/6666
```

---

## 3. Google / Apple Girişi Neden İsteğe Bağlı? (Mağaza Stratejisi)
- Oyuncu **0. saniyede misafir olarak** hemen oynar (ilk açılışta %40–60 kullanıcı kaybı yaşanmaz).
- **Kupa Vitrini** içinde isteğe bağlı **iOS Game Center / Android Google Play Games** bağlantısı bulunur ([`PlatformGamesService`](../lib/services/achievements_service.dart)).
- App Store **Guideline 5.1.1(v)** zorunlu hesap silme yükümlülüğü olmadan **12 Başarım** ve yerel rekorlar sorunsuz çalışır.
