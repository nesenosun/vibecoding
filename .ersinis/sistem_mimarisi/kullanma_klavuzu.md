# 📘 ERSİNİS KULLANMA KILAVUZU

> **Bu kılavuz kimin için:** Ersinis uygulamasını ilk kez kuran veya bir özelliği nasıl kullanacağını unutan kullanıcı içindir.
> **Nasıl kullanılır:** Baştan sona okuyabilirsin ya da takıldığın yerde ilgili bölümü açıp bakabilirsin.
> **Ajan desteği:** Bir bölümü anlamadıysan, bu dosyayı yapay zekâ ajanına (Artemis) okutup o bölümü sana anlatmasını isteyebilirsin: *"Artemis, .ersinis/sistem_mimarisi/kullanma_klavuzu.md'nin 7. bölümünü bana açıkla."*

---

## 1. 🤔 Ersinis Nedir? (30 Saniyelik Özet)

Ersinis; kod editörü, terminal, tarayıcı, dosya gezgini, hafıza sistemi ve çoklu ajan yönetimini tek pencerede birleştiren masaüstü bir **yapay zekâ kokpitidir**.

Temel fikri çok basittir: Sen kod yazmazsın. Sen **yönetirsin**.

- Pencerenin kalbinde **Artemis** diye bir ana ajan vardır. Ona konuşur (yazılı veya sesli), işleri ona devredersin.
- Artemis gerektiğinde arka planda ek yardımcı ajanlar (**Ersinis** = beyin/denetmen, **İşçi** = kod yazarı) kaldırır ve işi onlara dağıtır.
- Uygulama hiçbir yapay zekâ API'sini doğrudan çağırmaz; tüm zekâyı terminal süreçleri olan CLI araçları üzerinden yürütür. Bu sayede model bağımsızdır: "Alt ajan DeepSeek olsun" dersin, olur.

---

## 2. 💻 Kurulum ve Gereksinimler

### Zorunlu Gereksinimler

| Gereksinim | Detay |
|---|---|
| İşletim Sistemi | macOS 12+ veya Windows 10+ |
| RAM | Minimum 4 GB (8 GB önerilir) |
| Depolama | En az 500 MB |
| İzinler | Kamera, Mikrofon, Konuşma Tanıma izinlerini ver |

### Tüm Özellikler İçin Önerilen Araçlar

```bash
brew install python ffmpeg node
```

| Program | Ne için gerekli |
|---|---|
| Python 3 | Vektörel hafıza (anlamsal arama), ses tanıma köprüsü |
| FFmpeg | Ses dönüştürme (Whisper için) |
| Node.js | Tarayıcı otomasyonu ve seslendirme betikleri |

> Windows'ta `brew` yerine `choco install python ffmpeg node` kullanabilirsin.

---

## 3. 🚀 İlk Açılış: Artemis'i Uyandırma

Ersinis'i açtığında Artemis henüz uyanmamıştır. Uyandırması çok kolaydır:

1. Proje klasöründe bulunan **`baslat.md`** dosyasını aç.
2. Terminaline veya Artemis'e şu emri ver:
   > *"baslat.md dosyasını oku ve Artemis protokolünü başlat."*
3. Artemis sırasıyla şunları yapar:
   - `bash .ersinis/oturum/session_open.sh` ile oturumu açar,
   - `.ersinis/ANAYASA.md` (davranış kuralları) dosyasını okur,
   - Anayasanın yönlendirmesiyle `.ersinis/sistem_mimarisi/ersinis_sistemi.md` (ortam bilgisi) dosyasını okur,
   - Dilini `~/ersinis/.ersinis/ersinis_box.gs` dosyasından öğrenir ve seninle o dilde konuşmaya başlar.

### Oturum Kapatma

İşin bitince temiz kapanış için:
```bash
bash .ersinis/oturum/session_close.sh
```
Bu betik açık ajanları güvenle kapatır ve hafızayı kaydeder.

---

## 4. 🖥️ Arayüz Turu (Kokpit Düzeni)

```
┌─────────────────┬──────────────────────────────┬────────────────────┐
│   SOL PANEL     │        ORTA PANEL            │    SAĞ PANEL       │
│   Dosya         │  Sekmeli Çalışma Alanı:      │  İşlemler Paneli:  │
│   Gezgini       │  • Terminal                  │  • Sohbet          │
│   (Git renk     │  • Monaco Kod Editörü        │  • İşlem kaydı     │
│   kodlamalı,    │  • Entegre Tarayıcı          │  • Hafıza          │
│   arama dahil)  │  • Artemis Tuval (Canvas)    │  • Bağlantı (A2A)  │
│                 │  • Dosya/Medya Görüntüleyici │  • GitHub          │
└─────────────────┴──────────────────────────────┴────────────────────┘
```

- **Sol panel:** Projedeki dosyalar. Değişen dosyalar Git renk kodlamasıyla anında işaretlenir.
- **Orta panel:** Sekmeler arasında geçiş yaparak aynı ekranda kod yazabilir, terminal çalıştırabilir, internete bakabilirsin. Sol üstteki **kırmızı saat butonu** otonom uyanma sayacını başlatır (Bölüm 7).
- **Sağ panel:** Sohbet paneli (Artemis'le konuştuğun yer), işlem kaydı, hafıza görüntüleyici, A2A bağlantısı ve GitHub entegrasyonu.

---

## 5. 🗣️ Artemis ile Çalışmak

### Görev Verme

Sohbet panelinden yazarak veya mikrofonla seslenerek emir verirsin:

- *"Bu hatayı çöz."*
- *"Projeye giriş ekranı ekle."*
- *"Şu dosyayı refaktör et."*

Önemli sonuçları Artemis sana **sesli olarak** bildirir (macOS TTS). Uzun kod çıktılarını sesli okumaz, ekrana/dosyaya yazar.

### Orkestrasyon: Yardımcı Ajanları Uyandırma

Açılışta Artemis sana şunu sorar: *"Diğer ajanları (Ersinis ve İşçi) ayağa kaldırayım mı?"*

- **"Hayır"** dersen → Artemis tüm işleri tek başına yapar (satır limiti yok). Bu günlük kullanım için gayet yeterlidir.
- **"Evet"** dersen → Artemis hangi model olacağını sorar. Seçimin `.ersinis/hafiza/ajan_tercihi.json` dosyasına kaydedilir, sonraki oturumlarda tekrar sorulmaz.

Roller şöyledir:

| Ajan | Rol | Varsayılan |
|---|---|---|
| **Artemis** | Komuta, planlama, seninle iletişim | Uygulama içi |
| **Ersinis** | Beyin + QA denetmeni (mimari danışmanlık, kalite kontrol) | Port 8001, CLI: `opencode` |
| **İşçi** | Kas (büyük kod yazımı, çok dosyalı düzenleme) | Port 8002, CLI: `agy` |

Orkestrasyon açıkken büyük işler şu zincirle yürür: **Planla (Artemis) → Uygula (İşçi) → Denetle (Ersinis)**. Denetimden geçmeyen iş İşçi'ye geri döner.

> ⚠️ Kritik mimari dosyalarda (`.ersinis/` altyapısı) değişiklik gerekirse Artemis senden onay ister.

### Ajanların Modelini Değiştirme

*"Alt ajanlar DeepSeek olsun"* demen yeterli. Desteklenen CLI örnekleri: `opencode`, `agy`, `deepseek`, `gemini`. Terminalde çalışan herhangi bir AI CLI'sini saniyeler içinde alt ajan olarak tanıtabilirsin.

---

## 6. 🧠 Hafıza Sistemi (En Özgün Özellik)

Ersinis, klasik RAG yerine **hiyerarşik damıtma** kullanır:

```
activity.ndjson (ham kayıt akışı)
      │  Özetçi Ajan periyodik süzer
      ▼
Saatlik → Günlük → Haftalık → Aylık → project_memory.md
                                          │
                                          ▼
                          vector_memory.db (anlamsal arama)
```

Yani sistem, insan beyni gibi detayları unutup önemli kararları hatırlar. Her oturumda projeyi sıfırdan anlatmazsın.

### Hafıza Panelini Kullanma

1. Sağ menüdeki **Hafıza ikonuna** (3. ikon) tıkla.
2. Saatlik/günlük bazda neyi hatırladığını tek ekranda görürsün.

### Yapay Zekânın Hafızasını Düzeltme

Artemis yanlış bir şey hatırlıyorsa:
1. Hafıza panelinde ilgili anıya tıkla.
2. Metni doğrudan düzenle ve kaydet.

> Düzeltilmiş hafıza artık sistemin resmi gerçeğidir; ajan üzerine yazmaz.

### Anlamsal Arama

Haftalar önce aldığın bir mimari kararı hatırlamıyor musun?
- Sohbet panelindeki **büyüteç ikonuna** tıklayıp serbestçe ara. Kelimesi kelimesine eşleşmese de anlama göre bulur (örn. "kimlik doğrulama" aratınca "login akışı" kararını getirir).

### Proje Gelişim Karnesi (Haftalık Özet)

Projeye birkaç gün ara verip geri döndüğünde, yapay zekâya sormadan son günlerde nelerin yapıldığını tek bakışta görebilmek için raporlama betiğini kullanabilirsin. Terminalde şu komutu çalıştırarak son 1 haftanın özetini (alınan kritik kararlar, kaç satır kod eklendiği/silindiği, toplam işlem sayısı) renkli bir karne olarak listeleyebilirsin:

```bash
bash .ersinis/hafiza/weekly_summary.sh
```
*(Son 3 günün raporunu almak için komutun sonuna `3` yazabilirsin.)*

---

## 7. ⏰ Otonom Uyanma (Sen Yokken Çalışsın)

Artemis'i bilgisayar başında yokken de çalıştıran sistem budur.

### Kullanımı (Arayüzden)

1. Sol üstteki **kırmızı saat/uyandırma butonuna** bas → geri sayım başlar.
2. Sayaç sıfırlandığında Artemis uyanır, ilk iş olarak `.ersinis/uyanma/bekleyen_gorevler.md` dosyasındaki **en üstteki `[ ]` görevi** yapar, `[x]` olarak işaretler ve tekrar uyur.
3. Görev listesi boşalırsa sayaç otomatik kapanır.

### Kullanımı (Terminalden)

```bash
# Sayacı başlat (süre zorunlu: 1m, 30s, 1h):
bash .ersinis/uyanma/counter.sh start 10m

# Duraklat / devam ettir / durdur:
bash .ersinis/uyanma/counter.sh pause
bash .ersinis/uyanma/counter.sh resume
bash .ersinis/uyanma/counter.sh stop
```

### Görev Eklemek

`.ersinis/uyanma/bekleyen_gorevler.md` dosyasını aç ve formatta yaz:

```markdown
- [ ] Testleri çalıştır ve hataları raporla.
- [ ] README'yi İngilizceye çevir.
```

> Not: Her uyanışta yalnızca **1 görev** yapılır. 3 görev varsa sayaç 3 kez sıfırlanmalı. Bu bilinçli bir tasarım (kontrol sende kalır).

### 🔎 Nasıl Çalışır (Deneme Notu)

> [!IMPORTANT]
> **`counter.sh` betiği kendisi bir zamanlayıcı kurmaz.** Gerçek geri sayım, uygulamanın içindeki **Flutter sayacına** aittir. Terminalden `counter.sh start 10m` yazdığında betik yalnızca hafızaya (`activity.ndjson`) bir **sinyal kaydı** yazar; uygulama bu kaydı okuyup sayacı başlatır/durdurur. Bu yüzden:
> - Terminalden verilen sayaç komutlarının (start / stop / pause / resume) etki etmesi için **Ersinis uygulamasının açık olması** gerekir.
> - Uygulama kapalıyken betik tek başına çalıştırılırsa geri sayım başlamaz; yalnızca log kaydı düşer.
> - *(26 Ağustos 2026'da yapılan canlı denemede bu davranış doğrulanmıştır: `counter.sh start 10m` çalıştı, log kaydı oluştu, ancak arka planda hiçbir zamanlanmış görev kurulmadığı gözlemlendi.)*

---

## 8. 🛠️ Error Defender (Otonom Hata Nöbetçisi)

Arka planda `.ersinis/hafiza/activity.ndjson` dosyasını tarayan bir nöbetçi vardır. İçerisinde belirli anahtar kelimeleri (ERROR, EXCEPTION, FAIL vb.) arayarak bulduğu son 10 kritik hatayı `.ersinis/artemis/active_errors.json` dosyasına raporlar.

### Manuel Tetikleme

Bu nöbetçiyi terminalden manuel olarak tetikleyebilirsiniz:

```bash
python3 .ersinis/artemis/error_defender.py
```

Nöbetçi komut satırı argümanı kabul etmez, her çalıştırıldığında doğrudan sistem loglarındaki son hataları tarayıp kaydeder.

---

## 9. 🎨 Artemis Tuvali (AI ile Şema Çizdirme)

Tuval; kutu (node) ve ok (edge)lerden oluşan sonsuz bir çizim yüzeyidir. Mimari diyagramları hem elle çizebilir hem de **AI'ya çizdirebilirsin**.

### Elle Çizme

1. Orta panelden **Tuval** sekmesine geç.
2. Kutu ekle, sürükle; kutuların bağlantı noktalarına tıklayarak oklar çiz.
3. Seçili öğeye renk paletinden renk ver.
4. Üst menüdeki **kaydet** ikonu şemayı `.ersinis/semalar/` klasörüne JSON olarak kaydeder; klasör ikonuyla geri yüklersin.

### AI'ya Çizdirme (Adım Adım)

1. Şu emri ver:
   > *".ersinis/semalar/SEMA_OLUSTURMA_REHBERI.md dosyasını oku ve bana sistemimin mimari şemasını çiz."*
2. Artemis rehberdeki sıkı JSON formatına uygun dosyayı `semalar/` klasörüne kaydeder.
3. Tuval'de **klasör ikonuna** tıkla → şema ekranda!

### PNG Almak

Üst çubuktaki **kamera ikonuna** tıkla → yüksek çözünürlüklü PNG, `.ersinis/semalar/sema_gorselleri/` klasörüne kaydedilir. Sunumlara birebir.

---

## 10. 📂 Dosya Gezgini ve Editör

- **Git entegrasyonu:** Değişen dosyalar renk kodlarıyla anında görünür (yeşil=yeni, sarı=değişti vb.). Dosya watcher her değişikliği aktivite akışına yansıtır.
- **Sürükle-bırak:** Dosyaları fareyle tutup başka klasöre taşıyabilirsin; yeni dosya/klasör oluşturma tek tık.
- **Akıllı editör:** VS Code'un Monaco motoru kullanılır. Arka plandaki "Warm-Up Editor" havuzu sayesinde sekme geçişleri anlıktır.
- **İkon renklendirmesi:** Dosyalar uzantıya göre renklenir (Dart mavi, JSON sarı...). Gizli dosyaları göster/gizle düğmesi de mevcut.

---

## 11. 🌐 Entegre Tarayıcı

Orta panelde sekmelerden tarayıcıyı açarsın; sol tarafta kodun, sağda dokümantasyon — alt-tab derdi yok.

Bonus: Artemis hem ekrandaki kodu hem tarayıcıdaki sayfayı aynı anda görebilir. *"Şu dokümandaki API'ye göre endpoint ekle"* demen yeterli.

---

## 12. 🎬 Medya İstasyonu

Dosya gezgininde tıkladığın medya dosyaları kokpit içinde açılır, harici programa gerek kalmaz:

- **Video:** `.mp4`, `.mov`, `.mkv` → entegre video oynatıcı.
- **Görsel:** `.png`, `.jpg`, `.webp` → görüntüleyici + **yerleşik fotoğraf editörü** (kırpma, filtre, bulanıklaştırma, çizim, emoji/metin ekleme).
- **Ses:** `.mp3`, `.wav`, `.m4a` → arka plan ses çalar; kod yazarken müzik dinleyebilirsin.

---

## 13. 📡 Cihazlar Arası Bağlantı (WebRTC A2A Ağı)

Ev PC'n ile ofis Mac'in arasında sunucusuz P2P köprü kurabilirsin: uzak ekran izleme, dosya transferi ve karşı cihazdaki ajana komut gönderme.

### Bağlantı Kurulumu (Çift Emniyet)

1. **Her iki cihazda da** Ersinis'i aç ve aynı Google hesabınla giriş yap.
2. Sağ paneldeki **Çift Emniyetli Bağlantı** bölümünden iki cihaza da **aynı eşleştirme şifresini** gir.
3. Şifreler eşleştiğinde, karşı taraftan kimsenin bağlantıyı "Kabul Et"mesine gerek kalmadan doğrudan ve otomatik olarak bağlanırsınız.

### Neler Yapabilirsin?

- **Ekran/Kamera:** Uzak cihazın masaüstünü veya kamerasını yeni sekmede canlı izle.
- **Komut:** *Tünel İletişimi* kutusundan karşı ajana emir ver: *"Şu projeyi derle ve bitince bana sonuçları yolla."*
- **Dosya:** Ataç ikonuyla doğrudan, şifreli, hızlı transfer. Gelen dosyalar `.ersinis/ortak_klasor/` dizinine düşer.

### Ajanlar Birbiriyle Nasıl Konuşur?

İki cihazdaki Artemis'ler `.ersinis/A2A/artemise_mesaj.md` protokolüne uygun şekilde birbirlerine mesaj atıp ortak görev yürütebilir. Teknik detaya ihtiyacın olursa bu dosyayı ajanına okut.

> Güvenlik notu: Bağlantının iki emniyeti vardır (Google kimliği + eşleştirme şifresi). Şifreyi güçlü seç ve kimseyle paylaşma.

---

## 14. ⚙️ Ayarlar

| Ayar | Nerede | Ne yapar |
|---|---|---|
| Uygulama dili | Ayarlar menüsü | 8 dil anında değişir: TR, EN, DE, FR, RU, ZH, JA, HI |
| Tema | Ayarlar menüsü | Açık/koyu tema |
| Whisper ses tanıma | Ayarlar → global dizine model indir | %100 çevrimdışı ses tanıma (macOS). İndirmezsen OS'un yerleşik STT'si kullanılır |
| Alt ajan modelleri | Sohbetten söyle veya `.ersinis/hafiza/ajan_tercihi.json` | Hangi CLI/modelin hangi rolde çalışacağı |

> Gizlilik: Hafıza, log ve ses verilerin tamamen yereldir; sadece LLM'e giden metin/kod sorguları internete çıkar.

---

## 15. ❓ Sık Takılınan Durumlar (SSS)

**S: Artemis yanıt vermiyor / uyandıramıyorum.**
C: Proje klasöründe `.ersinis/` dizini var mı kontrol et. Varsa `bash .ersinis/oturum/session_open.sh` komutunu manuel çalıştır.

**S: Artemis farklı dilde konuşuyor.**
C: `~/ersinis/.ersinis/ersinis_box.gs` dosyasındaki `"language"` alanını değiştir (`tr` yap). Ya da sohbette *"benimle Türkçe konuş"* de — kullanıcının isteği her zaman üstündür.

**S: Otonom görev yapılmadı.**
C: `.ersinis/uyanma/bekleyen_gorevler.md` dosyasında görev `- [ ]` formatında mı? En üstteki `[x]` (tamamlanmış) görevin altındakiler bekler. Ayrıca her uyanışta sadece 1 görev yapılır.

**S: Sayaç çalışıyor ama durdurmak istiyorum.**
C: `bash .ersinis/uyanma/counter.sh stop`

**S: Hafızada yanlış bilgi var.**
C: Sağ panel → Hafıza ikonu → ilgili anıya tıkla → elle düzelt. Düzelttiğin bilgi resmi gerçek olur.

**S: Eski bir kararı hatırlamıyor.**
C: Büyüteç ikonundan anlamsal arama yap. Bulamazsa konuyu kısaca tekrar anlat; yeni oturumda damıtılarak hafızaya işlenir.

**S: Uzak cihaz bağlanmıyor.**
C: Kontrol listesi: (1) İki cihazda da aynı Google hesabı açık mı? (2) Eşleştirme şifreleri birebir aynı mı? (3) Karşı cihazda Ersinis çalışıyor mu?

**S: Şema JSON'u tuvale yüklenmiyor.**
C: Dosya `SEMA_OLUSTURMA_REHBERI.md` formatına uymuyor olabilir (koordinatlar ondalıklı olmalı: `4000.0`). AI'ya yeniden ürettirmek en kolayı.

---

## 16. 🗂️ Hızlı Referans: Dosya Haritası

```
<proje-kökü>/
├── baslat.md                  ← Artemis'i uyandıran tetikleyici
└── .ersinis/                  ← Otonom ajan altyapısı
    ├── ANAYASA.md             ← Ajanın bağlayıcı davranış kuralları
    ├── whisper_bridge.py      ← Yerleşik ses tanıma köprüsü
    ├── hafiza/                ← Kalıcı hafıza (log, özetler, vektör DB, görevler)
    ├── ortak_klasor/          ← Cihazlar arası transfer dizini
    ├── oturum/                ← session_open/close.sh, artemis_say.js (ses kanalı)
    ├── sistem_mimarisi/       ← Sistem ortam bilgisi belgeleri (ersinis_sistemi.md)
    │   └── kullanma_klavuzu.md ← BU DOSYA
    ├── ajanlar/               ← Alt ajan promptları, daemon'lar, rehberler
    ├── artemis/               ← error_defender.py, common_fixes.json, gelen mesajlar
    ├── A2A/                   ← Cihazlar arası mesajlaşma protokolü
    ├── semalar/               ← Tuval şemaları (JSON) + çizim rehberi
    ├── uyanma/                ← counter.sh + bekleyen_gorevler.md
    └── temp/                  ← Geçici dosyalar (ajanlar buraya yazar, iş bitince silinir)
```

---

## 17. 🤖 Ajandan Bilgi Almak (Hazır Sorular)

Herhangi bir konuda detay istersen bu kalıpları kullan:

- *"Artemis, .ersinis/sistem_mimarisi/kullanma_klavuzu.md'nin [X]. bölümünü bana açıkla."*
- *".ersinis/sistem_mimarisi/ersinis_sistemi.md dosyasını oku ve hafıza sisteminin nasıl çalıştığını özetle."*
- *".ersinis/A2A/artemise_mesaj.md dosyasına bak ve iki cihaz arasında dosya nasıl gönderilir anlat."*
- *"Hafızamdaki son haftalık özetin özetini oku bana."*

---

*Bu kılavuz 27 Ağustos 2026 itibarıyla mevcut sistem dosyalarından derlenmiştir. Uygulama güncellendiğinde güncellenmelidir.*
