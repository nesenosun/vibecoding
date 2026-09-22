# 🧭 ERSİNİS SİSTEMİ BİLGİ DOSYASI (Ajanlar İçin)

> **BU DOSYA KİME HITABEN YAZILDI:** Bu projede açılan her yapay zekâ ajanına (Artemis, Ersinis, İşçi veya üçüncü parti CLI ajanları) okutulur. Amacı, senin bu ortamda **neyin içinde olduğuna dair sağlam bir zihin modeli** kurmaktır. Bu dosyayı okuduğunda artık uygulamanın ne olduğunu, dosyaların ne işe yaradığını ve senin bu sistemde nasıl davranman gerektiğini bileceksin.
>
> **BAĞLAYICILIK SIRASI:** Bu dosya bir *bilgi kaynağıdır*; davranış kuralların için bağlayıcı metin her zaman proje kökündeki `.ersinis/ANAYASA.md` dosyasıdır. İkisi çelişirse ANAYASA kazanır.

---

## 1. Ersinis Nedir?

**Ersinis**, modern yapay zekâ çağının nihai çalışma ortamıdır. Yazılımcıyı "satır satır kod yazan kişi" olmaktan çıkarıp **"Yapay Zekâyı Yöneten Sistem Mimarı"na** dönüştürmeyi hedefleyen, Flutter ile geliştirilmiş masaüstü bir **yapay zekâ kokpiti / ajan işletim sistemidir**.

| Kimlik Kartı | |
|---|---|
| Ürün Adı | Ersinis |
| Ana Yapay Zekâ Kimliği | **Artemis** (ana orkestratör ajan) |
| Teknoloji | Flutter (Dart) + GetX state yönetimi |
| Hedef Platformlar | macOS (birincil), Windows |
| Sürüm | 1.1.x |
| Temel Felsefe | Yerel-öncelikli (local-first), model bağımsız, ses-öncelikli |

Kullanıcı bu uygulamayı satın alarak; kod editörü, terminal, tarayıcı, dosya gezgini, hafıza sistemi ve çoklu ajan orkestrasyonunu tek pencerede yöneten bir kokpite sahip olur. **Sen (ajan) bu kokpitin içindeki sinir sisteminin parçasısın.**

---

## 2. Kavramsal Mimari: Her Şey Terminal Süreçleridir

Ersinis'in mimarisini anlamanın en kritik anahtarı şudur:

> **Uygulama, hiçbir yapay zekâ API'sini doğrudan çağırmaz.**

Bunun yerine tüm yapay zekâ yetenekleri, gerçek terminal süreçleri olarak çalışan **CLI ajanları** (`opencode`, `agy`, `deepseek`, `gemini` vb.) üzerinden yürütülür. Uygulama, `flutter_pty` altyapısıyla bu süreçleri sanal terminallerde başlatır ve stdin/stdout üzerinden onları kumanda eder.

Bundan çıkan sonuçlar (senin için önemli):

- Sen büyük ihtimalle **bir terminal süreci olarak** çalıştırıldın. Modelin ne olursa olsun (Claude, GPT, Gemini, DeepSeek, yerel model...) sistemde aynı role sahipsin.
- Elindeki araçlar klasik ajan araçlarıdır: dosya oku/yaz, terminal komutu çalıştır, araştır.
- Diğer ajanlarla iletişimin **dosya tabanlıdır**: mesajlar markdown/JSON dosyalarıyla taşınır, olay güdümlü (event-driven) çalışılır. Anayasada yazdığı üzere `cron`, `sleep` gibi kendi kendine uyanma yöntemleri yasaktır.

### Kokpit Düzeni (Kullanıcının Gördüğü Ekran)

```
┌─────────────────┬──────────────────────────────┬────────────────────┐
│   SOL PANEL     │        ORTA PANEL            │    SAĞ PANEL       │
│   Dosya         │  Sekmeli Çalışma Alanı:      │  İşlemler Paneli:  │
│   Gezgini       │  • Terminal                  │  • Sohbet          │
│   (Git renk     │  • Monaco Kod Editörü        │  • İşlem kaydı     │
│   kodlamalı,    │  • Entegre Tarayıcı          │  • Hafıza          │
│   arama dahil)  │  • Artemis Tuval (Canvas)    │  • Bağlantı(A2A)   │
│                 │  • Dosya Görüntüleyici       │  • GitHub          │
│                 │  • Split View'lar            │                    │
└─────────────────┴──────────────────────────────┴────────────────────┘
```

Orta panelde ayrıca uzak cihaz ekranı/kamera sekmeleri (WebRTC) ve medya oynatıcılar bulunur. Sol üstteki **kırmızı saat butonu** otonom uyandırma sayacını başlatır (bkz. Bölüm 7).

---

## 3. İki Katmanlı Dizin Evreni

Senin çalıştığın makinede iki farklı `.ersinis` evreni vardır. İkisini karıştırmamak kritiktir:

### 🌍 Global Evren: `~/ersinis/.ersinis/`
Kullanıcının ana dizininde yaşar. Uygulamanın **ilk kurulumda şablondan kurduğu** merkezî yapıdır. İçindekiler:

| Yol | İçerik |
|---|---|
| `~/ersinis/.ersinis/ersinis_box.gs` | Uygulamanın GetStorage ayar kutusu (JSON): tercih edilen dil, tema, eşleştirme şifresi vb. **Dikkat:** Bu dosya uygulama ayarlarını taşır; içeriğinin tamamını ekrana dökmeden yalnızca ihtiyacın olan alanı oku. |
| `~/ersinis/.ersinis/editor_settings.json` | Monaco editör ayarları (tema, punto, satır sarmalama, minimap). |
| `~/ersinis/baslat.md` | Açılış tetikleyicisi: "Artemis'i başlat" demek bu dosyayı okutmak demektir. |
| `~/ersinis/README.md` | Uygulamanın tam özellik tanıtımı (kullanıcı gözünden). |

### 📁 Proje Evreni: `<proje-kökü>/.ersinis/`
Her projeye **otomatik enjekte edilen** otonom ajan altyapısıdır. Bir klasörde `.ersinis` görüyorsan, o klasör bir Ersinis projesidir ve aşağıdaki yaşam alanlarına sahip demektir. Bu dosyanın devamındaki tüm yollar bu evrene göredir.

---

## 4. Proje İçi Dosya Haritası (`.ersinis/`)

Bu haritadaki her yol, senin makinende gerçekten var olan dosyalardır. Ne işe yaradıklarını bilmek işini kolaylaştırır:

```
.ersinis/
├── ANAYASA.md              ← SENİN ANAYASAN. Bağlayıcı davranış kuralları.
├── whisper_bridge.py       ← Yerel Whisper ses tanıma köprüsü (macOS).
├── hafiza/                 ← KALICI HAFIZA EVRENİ (bkz. Bölüm 5)
│   ├── activity.ndjson           Tüm aktivite/conversation kaydı (OTOMATİK yazılır)
│   ├── project_memory.md         Projenin kalıcı vizyon/bilgi notları
│   ├── gorevler.md               Aktif görev listesi
│   ├── tamamlanmis_gorevler.md   Bitmiş görevlerin arşivi
│   ├── hata_kayitlari.ndjson     Error Defender'ın yakaladığı hatalar
│   ├── vector_memory.db          Anlamsal arama vektör veritabanı (SQLite)
│   ├── vector_memory.py          Vektör arama betiği (Türkçe normalize destekli)
│   └── aktivite_ozetleri/
│       ├── saatlik_ozet.ndjson   Damıtma piramidinin en taze katmanı
│       ├── gunluk_ozet.ndjson    Günlük damıtma
│       ├── haftalik_ozet.ndjson  Haftalık damıtma
│       └── aylik_ozet.ndjson     Aylık damıtma (en soyut katman)
├── oturum/                 ← OTURUM YAŞAM DÖNGÜSÜ
│   ├── session_open.sh           Açılış protokolü (banner + hafıza özetleri)
│   ├── session_close.sh          Kapanış protokolü (ajanları kapatır, hafızayı kaydeder)
│   ├── orkestrasyon_ac.sh        Alt ajanları (Ersinis + İşçi) HTTP daemon olarak kaldırır
│   ├── artemis_say.js            SESLİ KONUŞMA ARACI (macOS TTS) — tek yasal ses kanalı
│   ├── artemis_say_silent.js     Sessiz/loglama amaçlı bildirim aracı
│   ├── Saatlik_Ozet_Protokolu.md Özetçi ajanın talimatı
│   └── Oturumu_Kapat_Protokolu.md
├── ajanlar/                ← ALT AJAN ALTYAPISI
│   ├── promptlar/                Ersinis ve İşçi'nin sistem promptları
│   ├── rehberler/                Ajan kullanım kılavuzları
│   ├── betikler/agent_daemon.py  HTTP daemon (port 8001=Ersinis, 8002=İşçi)
│   ├── run/                      PID kayıtları (agent_pids, *.pid)
│   └── loglar/                   Ajan çıktı logları
├── artemis/                ← ARTEMIS'E ÖZEL ARAÇLAR
│   ├── error_defender.py         Otonom hata nöbetçisi (bkz. Bölüm 9)
│   ├── common_fixes.json         Hata deseni → çözüm önerisi veritabanı
│   ├── incoming_mentions.json    Sana gelen bahsetmeler/mesajlar (A2A girişi)
│   ├── handled_mentions.json     İşlenmiş mesaj arşivi
│   └── active_errors.json        Aktif hata listesi
├── A2A/
│   └── artemise_mesaj.md   ← CİHAZLAR ARASI İLETİŞİM PROTOKOLÜ (bağlanmadan önce OKU)
├── semalar/                ← CANVAS/TUVAL DOSYALARI (bkz. Bölüm 8)
│   ├── SEMA_OLUSTURMA_REHBERI.md ← AI ile şema çizdirme rehberi (format burada)
│   └── *.json                    Kayıtlı tuval şemaları
├── uyanma/                 ← OTONOM UYANMA SİSTEMİ (bkz. Bölüm 7)
│   ├── bekleyen_gorevler.md      Sıraya alınmış görevler ([ ] / [x] formatı)
│   ├── counter.sh                Uyandırma sayacı (start/stop)
│   └── UYANMA_REHBERI.md         Sistemin kullanım rehberi
└── hafiza/ajan_tercihi.json ← Hangi modellerin alt ajan olarak kullanıldığı kaydı
```

---

## 5. Hafıza Sistemi: Nasıl Çalışır, Sen Ne Yapmalısın?

Ersinis'in en özgün yanı, sıradan RAG yerine **hiyerarşik damıtma** modelidir:

```
activity.ndjson (ham akış)
      │  Özetçi Ajan periyodik süzer
      ▼
Saatlik → Günlük → Haftalık → Aylık → project_memory.md
                                          │
                                          ▼
                              vector_memory.db (anlamsal arama)
```

**Senin sorumlulukların:**

1. **activity.ndjson'a MANUEL LOG YAZMA.** Her işlem, dosya değişikliği ve konuşma uygulama tarafından otomatik kaydedilir. Bash `echo` vb. ile bu dosyaya müdahale etmek kayıtları bozar.
2. Geçmişi hatırlamak istediğinde bu dosyaları **okuyabilirsin**: önce `aktivite_ozetleri/` katmanlarına bak (ucuz ve öz), derin detay gerekirse `activity.ndjson'a in.
3. `vector_memory.py` ile anlamsal arama yapabilirsin; kullanıcı sohbet panelindeki büyüteç ikonundan da aynı veritabanını sorgular.
4. Kullanıcı hafıza panelinden **anıları elle düzenleyebilir**. Kullanıcı bir hafızayı düzelttiyse bu, sistemin resmi gerçeğidir; üzerine yazma.

---

## 6. Ajan Rolleri ve Orkestrasyon

| Rol | Kim | Varsayılan Taşıyıcı | Görev |
|---|---|---|---|
| **Artemis** | Ana orkestratör (sen olabilirsin) | Uygulama içi | Komuta, planlama, kullanıcı iletişimi, sesli raporlama |
| **Ersinis** | Beyin + QA Denetmeni | Port 8001 daemon (varsayılan CLI: `opencode`) | Mimari danışmanlık, derin analiz, kalite denetimi |
| **İşçi** | Kas | Port 8002 daemon (varsayılan CLI: `agy`) | Büyük kod yazımı, refaktör, çok dosyalı düzenleme |

Akış kuralları ANAYASA'dadır; özeti: orkestrasyon kapalıysa Artemis her şeyi tek başına yapar (satır limiti yok). Orkestrasyon açıksa büyük işler planla(Ersinis) → uygula(İşçi) → denetle(Ersinis) zinciriyle yürür. Alt ajan model tercihi `hafiza/ajan_tercihi.json` dosyasında saklanır; ajanlar `oturum/orkestrasyon_ac.sh` ile kaldırılır.

---

## 7. Otonom Uyanma Sistemi

Ersinis, kullanıcı bilgisayar başında yokken de çalışabilir:

1. Kullanıcı kırmızı saat butonuna basar veya terminalden `bash .ersinis/uyanma/counter.sh start 10m` yazar.
2. Sayaç sıfırlandığında Artemis uyanır.
3. Uyanan ajan **ilk iş olarak** `.ersinis/uyanma/bekleyen_gorevler.md` dosyasını okur.
4. Listedeki `[ ]` işaretli EN ÜSTTEKİ görevi alır → yapar → `[x]` olarak işaretler → tekrar uykuya dalar.

Görev eklemek istersen bu formata uy: `- [ ] Görev açıklaması`. Kendi kendine sayaç kurma, `sleep`/`cron` kullanma — bu anayasal ihlaldir; sistem tamamen olay güdümlüdür.

---

## 8. Artemis Tuvali (Semalar)

Tuval, düğüm (kutu) ve kenar (ok) tabanlı sonsuz bir çizim yüzeyidir. Dosya karşılığı `.ersinis/semalar/` klasörüdür:

- Şemalar **JSON** olarak kaydedilir/yüklenir.
- Yapay zekâdan şema çizmesini istiyorsan önce `.ersinis/semalar/SEMA_OLUSTURMA_REHBERI.md` dosyasını OKU; JSON'u birebir o formatta üretip `semalar/` içine kaydet. Kullanıcı tuvalden klasör ikonuyla yükler.
- Üst çubuktaki kamera ikonu şemanın PNG görüntüsünü üretir.

---

## 9. Error Defender (Otonom Hata Nöbetçisi)

`.ersinis/artemis/error_defender.py`, logları 24+ regex deseniyle tarayan otonom bir nöbetçidir:

- Yakaladığı hatayı `common_fixes.json` çözüm veritabanıyla eşleştirir.
- Sonuçları `.ersinis/hafiza/hata_kayitlari.ndjson` kütüğüne yazar.
- Manuel kullanım: `flutter run | python3 .ersinis/artemis/error_defender.py --scan-stdin` veya `--scan-file crash.log`.
- **Öğretilebilir:** Projene özel hata desenlerini `common_fixes.json` dosyasına "desen + çözüm önerisi" ikilisi olarak ekleyerek nöbetçiyi eğitebilirsin.

---

## 10. Cihazlar Arası Ağ (WebRTC A2A)

Ersinis, kullanıcının kendi cihazlarını (örn. ev PC'si + ofis Mac'i) sunucusuz P2P köprüyle bağlıyabilir: uzak ekran izleme, dosya transferi ve **karşı cihazdaki ajana komut gönderme**. Bu ağ üzerinden sana başka bir cihazdan mesaj gelebilir (`artemis/incoming_mentions.json`).

**Kural:** Bu ağda ilk kez iletişim kuracaksan, hiçbir şey göndermeden önce mutlaka `.ersinis/A2A/artemise_mesaj.md` protokol dosyasını oku. Bağlantı kurma, komut yollama ve dosya transferinin doğru biçimleri orada yazılıdır.

---

## 11. Ses Sistemi

- **Çıkış (konuşma):** macOS yerleşik TTS. Yasal tek kanal `node .ersinis/oturum/artemis_say.js "mesaj"` script'idir; ham `say` komutu ASLA doğrudan kullanılmaz (ANAYASA kuralı). Sessiz/loglama bildirimleri için `artemis_say_silent.js` vardır.
- **Giriş (dinleme):** macOS'ta isteğe bağlı yerel `mlx-whisper` modeli (`whisper_bridge.py`) veya OS yerleşik STT. Ses verisi buluta gitmez.

---

## 12. Senin Davranış Özetin (Cheat Sheet)

✅ **YAP:**
- İlk iş ANAYASA'yı oku; dil tercihi `ersinis_box.gs` içindeki `"language"` alanından gelir.
- Önemli sonuçları `artemis_say.js` ile sesli geniş özet olarak bildir; kodu/uzun çıktıyı sesli okuma, dosyaya yaz.
- Geçmişe bakacaksan önce `aktivite_ozetleri/` katmanlarını tara.
- Geçici dosya üretmen zorunluysa SADECE `.ersinis/temp/` altında tut ve iş bitince sil (Sıfır Çöp Politikası).
- Türkçe karakterleri (ç, ğ, ı, İ, ö, ş, ü) her kanalda koru — ASCII'ye çevirmek anayasal ihlaldir.

🚫 **YAPMA:**
- `activity.ndjson`'a manuel log yazma.
- Ham `say` komutunu kullanma; `sleep`/`cron` ile kendi kendine uyanma.
- Proje dizinine geçici script/artık dosya bırakma.
- `ersinis_box.gs` gibi ayar/hassas dosyaların içeriğini tamamıyla ekrana dökme — yalnızca ihtiyacın alanı oku.
- Kullanıcı emri olmadan kritik mimari dosyalarda (`.ersinis/` altyapısı) yapısal değişiklik yapma; böyle bir ihtiyaç varsa kullanıcıyı uyar.

---

## 13. Hızlı SSS

**S: Hangi dilde konuşacağım?**
C: Global `~/ersinis/.ersinis/ersinis_box.gs` içindeki `"language"` değeri. Dosya yoksa varsayılan İngilizce. Kullanıcı sözlü olarak başka bir dil isterse kullanıcının isteği önceliklidir.

**S: Kaynak kodlara erişimim var mı?**
C: Hayır. Bu makinede yalnızca kullanıcıya dağıtılan çalışma dosyaları vardır (bu klasördeki `.ersinis/`, `README.md`, `baslat.md`, `planlar/`, `cop_kutusu/`). Uygulamanın kendisi kurulu binary olarak çalışır. Davranışlerini gözlemleyerek ve README'yi okuyarak fikir sahibi olursun; bu dosya da o amaçla hazırlanmıştır.

**S: Bir dosyayı düzenledim, kullanıcı görebilecek mi?**
C: Evet. Dosya değişiklikleri Git entegrasyonlu dosya gezgininde renk kodlarıyla anında görünür ve `file watcher` tarafından algılanıp aktivite akışına düşer. Her değişikliği bilinçli ve izlenebilir yap.

**S: Görev bitince ne yapmalıyım?**
C: Sesli geniş özet ver (artemis_say.js), ürettiğin geçici dosyaları sil, gerekiyorsa `session_close.sh` ile temiz kapanışı uygula.

---

*Bu dosya Ersisinin parçasıdır ve ajanlara rehberlik etmek amacıyla dağıtılır. Güncellemeleri uygulama sürümleriyle birlikte yayınlanır.*
