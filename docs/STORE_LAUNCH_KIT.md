# PRISM FORGE (Prizma Döküm) — Mağaza Yayın & Canlı Gelir Kiti (Google Play + App Store)

Bu belge, **Google Play Console**, **Apple App Store Connect** ve **Google AdMob** formlarını tek seferde hatasız doldurmanız için kopyala-yapıştır hazır cevapları içerir.

---

## 1. Canlı Bağlantılar (GitHub Pages)
- **Web Sitesi / Pazarlama URL:** `https://dagcann34.github.io/prism-forge/`
- **Gizlilik Politikası URL (Zorunlu):** `https://dagcann34.github.io/prism-forge/privacy.html`
- **Destek URL (App Store Zorunlu):** `https://dagcann34.github.io/prism-forge/support.html`
- **Paket / Bundle ID:** `com.prismforge.app`

> **`app-ads.txt` İpucu:** AdMob, geliştirici web sitenizin kök alan adında (`/app-ads.txt`) arama yapar. Özel bir alan adınız varsa `https://siteniz.com/app-ads.txt` olarak yayınlayın; ücretsiz GitHub çözümü için `dagcann34.github.io` adında public bir GitHub reposu açıp köküne `app-ads.txt` koymanız yeterlidir (`https://dagcann34.github.io/app-ads.txt`).

---

## 2. AdMob + Android İmzalama Secret'larını Tek Komutla Yükleme

1. **Android Upload Keystore oluşturun** (yalnızca ilk kez, güvenli yedekleyin):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias prismforge
   base64 -w 0 upload-keystore.jks > keystore.b64
   ```
2. **GitHub CLI ile tüm 12 Secret'ı yükleyin** (AdMob panelinizden aldığınız kendi ID'lerinizle):
   ```bash
   REPO="dagcann34/prism-forge"
   gh secret set ADMOB_ANDROID_APP_ID          -R "$REPO" -b "ca-app-pub-XXXX~YYYY"
   gh secret set ADMOB_ANDROID_BANNER_ID       -R "$REPO" -b "ca-app-pub-XXXX/1111"
   gh secret set ADMOB_ANDROID_INTERSTITIAL_ID -R "$REPO" -b "ca-app-pub-XXXX/2222"
   gh secret set ADMOB_ANDROID_REWARDED_ID     -R "$REPO" -b "ca-app-pub-XXXX/3333"
   gh secret set ADMOB_IOS_APP_ID              -R "$REPO" -b "ca-app-pub-XXXX~ZZZZ"
   gh secret set ADMOB_IOS_BANNER_ID           -R "$REPO" -b "ca-app-pub-XXXX/4444"
   gh secret set ADMOB_IOS_INTERSTITIAL_ID     -R "$REPO" -b "ca-app-pub-XXXX/5555"
   gh secret set ADMOB_IOS_REWARDED_ID         -R "$REPO" -b "ca-app-pub-XXXX/6666"
   gh secret set ANDROID_KEYSTORE_BASE64       -R "$REPO" < keystore.b64
   gh secret set ANDROID_KEYSTORE_PASSWORD     -R "$REPO" -b "SIFRENIZ"
   gh secret set ANDROID_KEY_ALIAS             -R "$REPO" -b "prismforge"
   gh secret set ANDROID_KEY_PASSWORD          -R "$REPO" -b "SIFRENIZ"
   ```
3. **Tek tıkla canlı Play Store `.aab` üretin:**
   GitHub → **Actions → PRISM FORGE CI → Run workflow** düğmesine basın. Çıkan `prism-forge-android-aab` dosyasını doğrudan Google Play Console'a yükleyin!

---

## 3. Mağaza Metinleri (Kopyala-Yapıştır)

### Türkçe (TR)
- **Uygulama Adı (30 karakter):** `Prizma Döküm — Taktik Bulmaca`
- **Kısa Açıklama (80 karakter):** `Renk rezonansı, Prizma Örsü ve lazer zincirli yeni nesil blok bulmaca!`
- **Tam Açıklama:**
  > Klasik blok bulmacaları unut! **Prizma Döküm (PRISM FORGE)** renkleri dekor olmaktan çıkarıp taktik güce dönüştürür:
  >
  > • **Prizma Rezonansı (×1.5):** Bir satır veya sütunu 4+ aynı renkli blokla temizle, ekstra puan + enerji kazan ve Kilitli Mühürleri parçala!
  > • **Altın Prizma Örsü:** Kritik parçanı örse bırak; 3 hamle sonra gökkuşağı **🌈 Joker + ★ Çekirdek** olarak dökülsün!
  > • **★→★ Optik Lazer Zinciri:** Hizalanmış Prizma Çekirdekleri birbirine lazer yansıtarak zincirleme patlama yaratır.
  > • **2×2 Prizma Sentezi:** Aynı renkten 2×2 kare oluştur, anında yeni ★ Çekirdek üret.
  > • **Taktik Enerji Çubuğu:** Şansa değil beceriye dayalı! Parçayı 90° döndür veya %100 Kuantum Nova ile 3×3 alanı buharlaştır.
  > • **24 Özgün Bölüm & 12 Canlı Tema:** Her bölüm sonunda atmosfer, renk paleti ve cam parçacık efektleri evrilir.
  > • **4 Oyun Modu:** Görev (24 Bölüm), Sonsuz Akış, Günlük Meydan Okuma ve 90 sn Hız Modu. Çevrimdışı oyna, sıfır zorunlu üyelik!

### English (EN)
- **App Name (30 chars):** `PRISM FORGE: Tactical Puzzle`
- **Subtitle / Short Desc:** `Color Resonance, Prism Anvil & laser chains in a next-gen block puzzle!`
- **Keywords (iOS 100 chars):** `block puzzle,prism,color match,strategy,tactical,offline puzzle,brain teaser,crystal,combo,arcade`

---

## 4. Google Play Veri Güvenliği (Data Safety) & App Store Gizlilik Etiketi Cevapları

Uygulama kendi sunucusuna kişisel veri göndermez; yalnızca **Google AdMob SDK** için şu kutucukları işaretleyin:

| Form Alanı | Google Play Data Safety | Apple App Store Privacy |
|---|---|---|
| Uygulama veri topluyor/paylaşıyor mu? | **Evet** (yalnızca 3. taraf reklam SDK — Google AdMob) | **Yes** |
| **Cihaz veya diğer kimlikler (Device ID)** | Toplanır & Paylaşılır • Amaç: Reklamcılık, Dolandırıcılık Önleme | **Device ID** • Third-Party Advertising • Used for Tracking (**Yes**), Not Linked to Identity |
| **Uygulama Etkinliği (App Interactions)** | Toplanır • Amaç: Reklamcılık, Analiz | **Product Interaction** & **Advertising Data** • Third-Party Advertising • Not Linked |
| **Kilitlenme Günlükleri / Teşhis (Diagnostics)** | Toplanır • Amaç: Uygulama İşlevselliği | **Crash Data** • App Functionality • Not Linked |
| **Aktarım sırasında şifreleme** | **Evet (HTTPS/TLS)** | — |
| **Kullanıcı hesabı / hesap silme gerekli mi?** | **Hayır** (hesap oluşturma yok) | **No** (no account creation) |
| **İçerik Derecelendirmesi (IARC / App Store)** | **PEGI 3 / Everyone (E)** — Şiddet/kumar/sohbet yok | **4+** |
| **Reklam İçeriyor mu?** | **Evet** ("Contains ads") | — |
