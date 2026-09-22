## 🤖  Alt-Ajan Orkestrasyonu (OpenCode Kullanımı)
Artemis, karmaşık araştırma, kod analizi ve veri toplama görevlerini paralel yürütebilmek için terminal üzerinden `opencode` aracını bir alt-ajan (sub-agent) olarak kullanmalıdır.

* **TUI (Görsel Arayüz) Engeli:** Artemis'in kullandığı arkaplan terminal ortamı gerçek bir ekran (interaktif TTY) olmadığı için `opencode` doğrudan çalıştırıldığında arayüz çizemez ve kilitlenir.
* **Doğru Kullanım (Zorunlu):** Opencode'u kilitlenmeden, sanal bir ekran (PTY) taklit ederek kullanmak için `script -q /dev/null` komutuyla sarmalanması **zorunludur**.
* **Ücretsiz Model Kuralı (Maliyet):** Projede ASLA ücretli API kullanılmayacağı kuralı gereği, `opencode` çağrılarında muhakkak sonuna `-m` parametresiyle ücretsiz modeller (örn. `opencode-go/deepseek-v4-flash` veya muadili) eklenmelidir.
* **Kullanım Formatları ve Modeller:**
  Ersinis sisteminde şu anda entegre ve ücretsiz çalışan iki temel uzman ajan vardır. İkisi de `script -q /dev/null` ile sanal PTY üzerinden çağrılır.
  
  **1. DeepSeek (Araştırmacı Ajan):**
  Genel araştırma, web taraması, literatür sentezi ve metin üretimi görevlerinde kullanılır.
  ```bash
  script -q /dev/null opencode run "Araştırma hedefin" -m "opencode-go/deepseek-v4-flash"
  ```
  
  **2. Mimo v2.5 (Sistem Analisti / Kodlayıcı Ajan):**
  Proje dosyalarını okuma, hata ayıklama (debugging), performans optimizasyonu ve kod mimarisi (refactoring) görevlerinde kullanılır.
  ```bash
  script -q /dev/null opencode run "Kod/Analiz hedefin" -m "opencode/mimo-v2.5-free"
  ```

* Bu sayede yeni uyanan tüm ana ajanlar, derinlemesine kod analizi veya otonom araştırma gerektiğinde bu iki modeli görevlerine göre (DeepSeek -> Araştırma, Mimo -> Kod Analizi) doğrudan terminalden bir "işçi/alt-ajan" olarak çalıştırıp sonuçlarını beklemeden asıl işlerine odaklanabilirler.

---

## 🤖  Alt-Ajan Orkestrasyonu (AGY CLI Kullanımı)

Artemis, `agy` CLI aracını da bir alt-ajan (sub-agent) olarak kullanabilir. AGY, açık kaynak modeller ve Gemini ailesi ile çalışan bağımsız bir CLI asistanıdır.

* **TUI Engeli Yok:** AGY'nin görsel arayüzü olmadığı için `opencode`'un aksine `script -q /dev/null` sarmalamasına gerek yoktur. Doğrudan çalıştırılabilir. (Not: agy'yi çıktı yakalayan bir subprocess içinden çağırıyorsanız, bilinen bir hata nedeniyle stdout boş gelebilir; bu durumda `script -q /dev/null` sarmalayıcısını yine de kullanın.)
* **Kullanım Formatı:** Tüm AGY alt-ajan çağrıları `--print` (`-p`) kipiyle yapılır. Interaktif kip (`-i`) kullanılmaz.
* **BAYRAK SIRASI (KRİTİK):** `--model` ve `--print-timeout` MUTLAKA `-p`'den ÖNCE yazılmalıdır. `-p`'den sonra yazılırlarsa sessizce yok sayılır ve model varsayılana düşer (hatasız!). Doğru sıra: `agy --model "MODEL" --print-timeout 60s -p "PROMPT"`.
* **Zaman Aşımı:** Uzun sürebilecek görevlerde `--print-timeout` parametresi mutlaka belirtilmelidir (örn. `60s`, `120s`).

### Kullanılabilir Modeller

Model adları `agy models` komutunun verdiği görünen adlarla (akıl yürütme seviyesi parantez içinde) birebir yazılır:

| Model | Kullanım Amacı |
|---|---|
| `Gemini 3.7 Flash (Medium)` | Hız + kod yazımı dengesi — İşçi'nin varsayılan modeli |
| `Gemini 3.1 Pro (Low)` | Derinlemesine analiz, kod yazımı, refactoring |
| `Gemini 3.1 Pro (High)` | Karmaşık akıl yürütme gerektiren kritik görevler |
| `Claude Sonnet 4.6 (Thinking)` | Uzun bağlam/analiz görevleri (Ersinis'in güncel tercihi) |
| `GPT-OSS 120B (Medium)` | Açık kaynak model, yedek seçenek |

### Kullanım Örnekleri

**1. İşçi Varsayılanı (Gemini 3.7 Flash):**
```bash
agy --model "Gemini 3.7 Flash (Medium)" --print-timeout 60s -p "Kod yazım veya düzenleme görevin"
```

**2. Hızlı Sorgu:**
```bash
agy --model "Gemini 3.7 Flash (Medium)" --print-timeout 30s -p "Hızlı özet çıkar: [metin]"
```

**3. Karmaşık Analiz (Gemini 3.1 Pro High):**
```bash
agy --model "Gemini 3.1 Pro (High)" --print-timeout 120s -p "Karmaşık analiz görevin"
```

### Önemli Kurallar

* **Varsayılanlar:** Rol bazlı varsayılanlar ANAYASA tablosundadır (Ersinis=opencode/deepseek-v4-flash, İşçi=agy/Gemini 3.7 Flash Medium); kullanıcı seçimi `hafiza/ajan_tercihi.json` ile bunların üzerine yazar.
* **Zaman Aşımı Kuralı:** Tüm AGY çağrılarında `--print-timeout` belirtilmelidir. Belirtilmezse varsayılan 5 dakikadır.
* **Proje Dizini:** AGY, çağrıldığı dizini çalışma dizini olarak kullanır. Gerektiğinde `--add-dir` ile ek dizinler eklenebilir.
* **Proje Bağlamı:** AGY'ye gönderilen prompt, mevcut oturum bağlamını (hedef, kısıtlamalar, dosya yolları) içerecek kadar detaylı olmalıdır.
