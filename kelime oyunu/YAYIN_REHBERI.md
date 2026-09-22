# Sıfırdan Yayına: Yeni Başlayan İçin Oyun/Uygulama Yayınlama Rehberi

> Bu rehber, hiçbir şey bilmeyen bir kullanıcının bir fikirden başlayıp oyununu
> internette, Apple'da ve Google'da yayınlaması için gereken tüm adımları sırayla anlatır.
> Her aşama bağımsızdır; bir sonrakine geçmek için öncekini bitirmek yeterlidir.
> Kullanıcının tek başına yapması zorunlu olan tek şeyler: ödeme, kimlik doğrulama ve hukuki onaylar.

---

## Yol Haritası Özeti

| Aşama | Ne yapılır | Süre | Maliyet | Zorluk |
|---|---|---|---|---|
| 0 | Hazırlık: hesaplar, cihaz, kavramlar | 30 dk | 0 | Kolay |
| 1 | Fikri netleştir (tek cümle + MVP) | 1 saat | 0 | Kolay |
| 2 | Yapay zeka ile yaptır (Artemis) | Saatler | 0 | Kolay |
| 3 | Test et ve düzelttir | Saatler | 0 | Kolay |
| 4 | Web'de ücretsiz yayınla (link paylaş) | 1 saat | 0 | Kolay |
| 5 | Firebase ile güçlendir (giriş, skor tablosu) | 1-2 gün | 0 (ücretsiz plan) | Orta |
| 6 | Apple App Store'da yayınla | 1-3 gün | ₺649,99/yıl (uygulama içi) | Orta |
| 7 | Google Play'de yayınla | ~3 hafta | 25 $ (tek seferlik) | Orta/Zor |
| 8 | Güncelle ve büyüt | Sürekli | 0 | Kolay |

---

## Aşama 0 — Hazırlık (30 dakika)

Gerekli hesaplar:
- Bir e-posta adresi (Gmail önerilir; Apple ve Google için ayrı ayrı kullanılabilir)
- Apple ID (iPhone veya iCloud hesabınız varsa zaten vardır) + iki adımlı doğrulama (2FA) açık olmalı
- Google hesabı (Android ve Firebase için)

Gerekli cihaz:
- Mac önerilir (Apple'a yayın için şart; web ve Android için Windows da yeterlidir)
- Telefon (TestFlight ve Google kapalı test denemeleri için)

Kavramlar için bu dosyanın sonundaki "Terimler Sözlüğü" bölümüne bakılabilir.

## Aşama 1 — Fikri Netleştir (1 saat)

Şu üç soruyu cevaplayın:
1. Bu uygulama/oyun kimin için? (anne mi, çocuk mu, öğrenci mi, esnaf mı)
2. Hangi sorunu çözüyor veya hangi keyfi veriyor?
3. İlk sürümde (MVP) olacak 3-5 özellik ne? Gerisi sonraki sürümlere.

Not: İsim seçmeden mağaza başvurusu yapmayın. Apple ve Google'da isim daha önce
alınmış olabilir; kontrol etmek için mağazalarda arama yapın.

Örnek: "Kelime Ustası — 5 harfli Türkçe kelimeyi 6 denemede bul, her yaştan oyuncu için."

## Aşama 2 — Yapay Zeka ile Yapım (saatler)

- Fikri Artemis'e doğal dille anlatın: "Bana şöyle bir oyun yap..."
- Artemis planlar, kodlar ve test eder. Kullanıcıdan kod bilgisi beklenmez.
- Büyük işlerde akış: plan (beyin ajanı) → uygulama (işçi ajan) → denetim (QA)
- Küçük adımlarla ilerleyin, her adımda çalışan bir sürüm isteyin.

## Aşama 3 — Test (saatler)

- Oyunu/uygulamayı kendiniz deneyin; hataları Artemis'e söyleyin, anında düzeltir.
- Farklı ekran boyutlarında (telefon, masaüstü) deneyin.
- İleri seviye: otomatik testler ve hata nöbetçisi (Error Defender) — Artemis halleder.

## Aşama 4 — Web'de Ücretsiz Yayın (1 saat)

En hızlı ve ücretsiz yol. Kimseye hesap parası ödemeden link paylaşılır.

1. Derleme (Artemis yapar):
   ```bash
   flutter build web --release
   ```
2. Yükleme (bir kez üyelik, ücretsiz plan):
   - Netlify: https://www.netlify.com (klasörü sürükle-bırak yeter)
   - GitHub Pages: https://pages.github.com
   - Vercel: https://vercel.com
   - Firebase Hosting: https://firebase.google.com (Aşama 5 ile aynı panelden)
3. Link paylaşın: WhatsApp, Instagram, YouTube açıklaması. QR kod üretilebilir.
4. İsteğe bağlı özel alan adı: ~10-15 $/yıl (.com). .com.tr için ek belge şartları vardır.
5. HTTPS sertifikası ücretsiz ve otomatiktir.

Not: Flutter web oyunları tarayıcıda çalışır; indirme gerekmez. Bu yüzden "tanıtım"
ve "hızlı geri bildirim" için en doğru ilk adımdır.

## Aşama 5 — Firebase ile Güçlendirme (ücretsiz başlangıç)

Firebase nedir: Google'ın uygulama altyapı servisidir. Ücretsiz "Spark" planı
küçük ve orta ölçekli uygulamalar için yeterlidir. Web sitesi: https://firebase.google.com

Ne için kullanılır:
- Authentication: Google/e-posta ile kullanıcı girişi (hesap sistemi)
- Firestore: bulut veritabanı — skor tablosu, kayıtlı ilerleme, kullanıcı profili
- Hosting: web sürümünü ücretsiz yayınlama (Aşama 4 alternatifi)
- Analytics: kullanıcılar ne yapıyor, nerede bırakıyor
- Crashlytics: çökmeleri otomatik raporlama (mobil)
- Cloud Messaging: bildirim gönderme

Ne zaman gerekir:
- Skor tablosu / liderlik tablosu isteniyorsa
- Hesapla giriş, çok oyunculu, bulut kayıt gerekiyorsa
- Kullanıcı davranışını ölçmek istiyorsanız

Adımlar (Artemis yönlendirir):
1. Google hesabıyla Firebase konsoluna gir, "Proje oluştur".
2. Web ve/veya Android/iOS uygulamasını projeye ekle.
3. Yapılandırma dosyasını projeye bağla.
4. İstenen servisi aç (örn. Authentication + Firestore).
5. Güvenlik kurallarını yaz (kim neyi okuyabilir/yazabilir) — bu adım atlanmaz.

Dikkat edilecekler:
- Ücretsiz planın günlük okuma/yazma limitleri vardır; limit aşılırsa ücretli plana geçilir.
- Gizlilik: kullanıcı verisi topluyorsanız gizlilik politikası zorunludur (KVKK/GDPR).
- Veritabanı güvenlik kuralları yanlış yazılırsa veriler açığa çıkar; Artemis yazar, kontrol edin.

## Aşama 6 — Apple App Store'da Yayınla (Türkiye: ₺649,99/yıl)

Ön koşullar:
- Mac bilgisayar (yayın yüklemesi için gerekli)
- Apple ID + iki adımlı doğrulama (2FA)
- Gerçek yasal isim (takma isim başvuruyu geciktirir; satıcı adı olarak görünür)
- Reşit olma (bölgenizdeki yasal yaş)

Adımlar:
1. Apple Developer Program üyeliği: https://developer.apple.com/programs/enroll/
   - Başvuru, iPhone/iPad/Mac'teki "Apple Developer" uygulamasından yapılabilir.
   - Ödeme kendi kredi kartınızla yapılmalı (başkasının kartı gecikme sebebidir).
   - ÜCRET (Türkiye, 2026 güncel): Resmi liste fiyatı 99 $/yıl olmakla birlikte
     Türkiye'de bölgesel fiyat uygulanır:
     - iPhone/iPad'deki Apple Developer UYGULAMASI içinden: ₺649,99/yıl (avantajlı)
     - Web sitesi üzerinden: ~99 $ (yaklaşık ₺1.000 civarı, kura göre değişir)
     - İkisi de AYNI üyeliktir; fark yalnızca ödeme kanalından kaynaklanır.
     - Fiyatlar değişebilir; ödeme ekranında her iki kanalı da kontrol edin.
   - Üyelik yıllık otomatik yenilenir; yenilenmezse uygulamalar mağazadan kaldırılır.
2. App Store Connect'te uygulama kaydı: isim, Bundle ID, kategori, yaş derecelendirmesi.
3. Hazırlık (Artemis hazırlar):
   - 1024x1024 uygulama ikonu
   - Ekran görüntüleri (macOS/iPhone için istenen boyutlar)
   - Açıklama, anahtar kelimeler
   - Destek URL'si ve gizlilik politikası (veri toplamasa bile zorunlu)
   - App Privacy beyanı ("veri toplamıyoruz" demek de bir beyandır)
4. İmzalama: Apple sertifikaları, provisioning; App Store için App Sandbox zorunlu.
5. TestFlight ile gerçek cihazda test.
6. Yükleme: Xcode Organizer veya Transporter.
7. İnceleme: genellikle 24-72 saat. Ret gelirse düzeltilip tekrar gönderilir.
8. Yayın: manuel veya otomatik.

iPhone için: proje şu an macOS + web hedefliyor. iOS hedefi eklemek için:
```bash
flutter create --platforms=ios .
```
Sonrası aynı adımlardır.

## Aşama 7 — Google Play'de Yayınla (25 $ tek seferlik)

Ön koşullar:
- Google hesabı ve Play Console kaydı (kimlik + adres doğrulaması yapılır)
- Android derlemesi (Artemis yapar)

Kritik kural (2026 güncel):
- 13 Kasım 2023 sonrası açılan KİŞİSEL hesaplarda, yayına çıkmadan önce
  "kapalı test" şartı vardır: en az 12 test kullanıcısı, 14 gün KESİNTİSİZ.
- 2026'dan itibaren Google, testçilerin uygulamayı gerçekten KULLANDIĞINI da denetler.
  Sadece kurmak yetmez; kullanım beklenir. (Kurumsal/şirket hesaplarında bu şart yoktur.)
- Başvuru: Play Console'da "Üretim erişimi" başvurusu → 10 soruluk form (~48 saat karar),
  ardından üretim incelemesi 7 güne kadar sürebilir.

Yükleme ve mağaza kaydı:
- Yükleme formatı: AAB (Android App Bundle).
- 31 Ağustos 2026'dan itibaren yeni uygulamalar Android 16 (API 36) hedeflemelidir.
- Mağaza kaydı: açıklama, görseller, içerik derecelendirmesi anketi, hedef kitle,
  veri güvenliği formu, gizlilik politikası linki.
- İmzalama: keystore oluşturulur; Google Play App Signing kullanılır.
- Keystore yedeği MUTLAKA alınmalıdır; kaybolursa uygulama bir daha güncellenemez.

12 testçi nasıl bulunur:
- Aile, arkadaş, yakın çevre (Google hesaplarıyla katılmalıdır)
- WhatsApp/Discord grupları, oyuncu toplulukları
- YouTube izleyicileri (yayında çağrı yapılabilir)
- Plan: 14-15 kişi davet edin ki 1-2 kişi ayrılsa bile sayı düşmesin.

Resmi kural sayfası:
https://support.google.com/googleplay/android-developer/answer/14151465

## Aşama 8 — Güncelleme ve Büyüme

- Sürüm numarası artırılır: örnek `1.0.0+1` → `1.0.1+2` (her mağaza yüklemesinde artmalı)
- Kullanıcı yorumları ve geri bildirimler okunur; en sık istenen özellik eklenir
- ASO (mağaza optimizasyonu): isim, anahtar kelimeler, ekran görüntüleri güncellenir
- Web sürümü her güncellemede yeniden yüklenir (1 komut)

---

## Kim Ne Yapar?

| İş | Kullanıcı | Artemis |
|---|---|---|
| Fikri anlatmak, karar vermek | Zorunlu | Destek |
| Kodu yazmak, düzeltmek | Gerekmez | Yapar |
| İkon, görsel, açıklama, gizlilik metni hazırlamak | Onaylar | Yapar |
| Derleme, imzalama, yükleme komutları | Gerekmez | Yapar |
| Hangi ekranda ne tıklanacağını söylemek | Takip eder | Adım adım yönlendirir |
| Ödeme yapmak | Zorunlu (devredilemez) | Hatırlatır |
| Kimlik doğrulaması | Zorunlu (devredilemez) | Yönlendirir |
| Hukuki onaylar (sözleşmeler) | Zorunlu (devredilemez) | Açıklar |
| Test kullanıcısı bulmak (Google) | Zorunlu | Metin/talimat hazırlar |
| Uygulama ismi ve fiyat kararı | Zorunlu | Öneri sunar |

## Maliyet Özeti

| Kalem | Ücret | Periyot |
|---|---|---|
| Web yayını (Netlify/GitHub Pages/Vercel/Firebase Hosting) | 0 | - |
| Firebase Spark planı | 0 | - |
| Apple Developer Program (Türkiye, uygulama içi) | ₺649,99 | Yıllık |
| Google Play Console | 25 $ | Tek seferlik |
| Özel alan adı (opsiyonel) | ~10-15 $ | Yıllık |

## Sık Yapılan Hatalar

- İsim müsaitliğini kontrol etmeden mağaza başvurusu yapmak
- Gizlilik politikası linkini boş bırakmak (Apple/Google ret sebebi)
- Apple'da takma isim/nick kullanmak (başvuru gecikir)
- Google'da 12 testçiyi tamamlamadan üretim başvurusu yapmak
- Android keystore yedeğini almamak (uygulama bir daha güncellenemez)
- Firebase güvenlik kurallarını yazmadan veritabanını yayına almak
- Web linkini paylaşmadan önce mobil görünümü test etmemek
- Sürüm numarasını artırmadan mağazaya yükleme yapmak (reddedilir)

## Terimler Sözlüğü

| Terim | Anlamı |
|---|---|
| MVP | İlk sürüm; sadece en temel özellikleri içeren çalışan hali |
| Bundle ID | Uygulamanın benzersiz kimliği (örn. com.sirket.uygulama) |
| AAB / APK | Android yükleme dosyası biçimleri (mağaza AAB ister) |
| Sandbox | Uygulamanın sistemden izole çalışması (Apple mağaza şartı) |
| Notarization | Apple'ın uygulamayı tarayıp onayladığı süreç (App Store dışı dağıtım) |
| TestFlight | Apple'ın beta test aracı |
| ASO | Mağaza aramalarında üst sıralara çıkma optimizasyonu |
| Keystore | Android uygulamasının imza anahtarı dosyası (yedeği şart) |
| Firebase | Google'ın kimlik, veritabanı, barındırma servisleri platformu |
| Spark Planı | Firebase'in ücretsiz başlangıç planı |
| 2FA | İki adımlı doğrulama |
| API | Uygulamaların birbiriyle konuşma arayüzü |
| HTTPS | Güvenli web bağlantısı (sertifika ücretsiz ve otomatik) |

## Bu Projenin (Kelime Ustası) Mevcut Durumu

- macOS uygulaması: derlendi ve çalışıyor
- Web sürümü: derlendi, yerel sunucuda açık (http://localhost:8080)
- Yayın öncesi eksikler:
  - [ ] Uygulama adı: `kelime_oyunu` → `Kelime Ustası`
  - [ ] Uygulama ikonu (1024x1024)
  - [ ] Mağaza açıklaması ve ekran görüntüleri
  - [ ] Gizlilik politikası metni
  - [ ] Release imzalama (Apple) ve keystore (Android)
  - [ ] İsim müsaitlik kontrolü (App Store ve Google Play'de "Kelime Ustası")
- Sonraki adım önerisi: Aşama 4 (web yayını, ücretsiz) → sonra Aşama 5 (Firebase skor tablosu)

## Kontrol Listesi (Yazdırılabilir)

- [ ] Aşama 0: Hesaplar ve cihaz hazır
- [ ] Aşama 1: Fikir tek cümlede ve MVP listesi net
- [ ] Aşama 2: Uygulama/oyun çalışıyor
- [ ] Aşama 3: Test edildi, hatalar düzeltildi
- [ ] Aşama 4: Web linki canlı ve paylaşıldı
- [ ] Aşama 5: (Gerekirse) Firebase giriş/skor tablosu eklendi
- [ ] Aşama 6: Apple üyelik ve mağaza kaydı tamam, inceleme sonucu bekleniyor/yayında
- [ ] Aşama 7: Google kayıt, 12 testçi / 14 gün testi tamam, üretim başvurusu yapıldı
- [ ] Aşama 8: Güncelleme planı ve geri bildirim döngüsü kuruldu

---

*Bu rehber Artemis tarafından, Ersinis oturumu içinde hazırlanmıştır. Kurallar
(ücretler, test şartları, API hedefleri) zamanla değişebilir; yayın öncesi resmi
sayfalardan güncel bilgi doğrulanmalıdır.*
