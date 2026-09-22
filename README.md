## 🤔 ersinis Nedir?

**ersinis**, modern yapay zeka çağının nihai çalışma ortamıdır.

Yazılımcıyı *"satır satır kod yazan kişi"* olmaktan çıkarıp **"Yapay Zekayı Yöneten Sistem Mimarı"**na dönüştürmek için tasarlanmıştır.

| Rakipler | ersinis |
|---|---|
| Dosya Aç → Hatayı Kopyala → Tarayıcıda Arat → AI'a Anlat → Geri Yapıştır | `"Artemis, bu hatayı çöz"` *(Tek komut)* |
| Her oturumda bağlamı tekrar anlatırsın | Projeyi, mimariyi ve geçmiş kararları **hiç unutmaz** |
| Bilgisayar başında olman gerekir | Belirlediğin saatte **uyanan**, bitince **uyuyan** otonom sistem |
| Sesli komut yok | Eller serbest, **çevrimdışı** ses tanıma |

---

## ✨ Temel Özellikler

### 🎤 1. Eller Serbest "Mini Mikrofon" Modu
**Ekranınızı kaplamaz, iş akışınızı bölmez.** Siz favori IDE'nizde kod yazarken, tarayıcıda araştırma yaparken veya başka işlerle meşgulken, Artemis mini bir pencerede arka planda sizi dinler ve anında destek sağlar.
- **Yazılımcılar İçin Üretkenlik:** Terminal komutları çalıştırmak, kod mimarisi hakkında soru sormak veya karmaşık görevleri delege etmek için ellerinizi klavyeden kaldırmanıza gerek kalmaz; her şeyi sadece sesinizle yönetirsiniz.
- **%100 Gizlilik:** Tamamen çevrimdışı yerel Whisper altyapısı sayesinde sesli komutlarınız hiçbir bulut sunucusuna gönderilmez, proje verileriniz bilgisayarınızda güvende kalır.

### 🌐 2. Çift Panelli Entegre Web Tarayıcı
**Odak noktanızı kaybetmeden araştırın ve geliştirin.** Sürekli pencereler arası geçiş yapmanın (alt-tab) getirdiği bilişsel yükten kurtulun.
- **Kesintisiz İş Akışı:** Sol panelde kodunuzu yazarken, sağ paneldeki entegre tarayıcıda API dokümantasyonlarını inceleyebilir veya dilediğiniz kaynağı okuyabilirsiniz. Sekme değiştirmeye son.
- **Bütünleşik Yapay Zeka Desteği:** Artemis, ekranda hem kodunuzu hem de tarayıcıdaki sayfayı aynı anda algılayabilir. Gördüğünüz bir dokümantasyona göre anında kod yazdırabilir veya hata çözümü isteyebilirsiniz.

### 🧠 3. Otonom Hiyerarşik Hafıza Sistemi
ersinis, sıradan bir Vektörel/RAG sisteminden çok daha fazlasını kullanır. Projenizi basitçe veritabanına kaydetmek yerine, eylemlerinizi bir insan beyni gibi **zamanla damıtarak** kalıcı anılara dönüştürür.
- **Zaman Döngülü Damıtma (Hiyerarşi):** Çalışırken arka planda biriken tüm konuşmalarınız ve kodlarınız (`activity.ndjson`), projedeki "Özetçi Ajan" tarafından periyodik olarak süzülür: **Saatlik → Günlük → Haftalık → Aylık → Proje Hafızası**. Sistem gereksiz detayları unutur, geriye sadece önemli kararlar ve proje vizyonu kalır.
- **Görsel Hafıza Yönetimi:** Sağ menüdeki **Hafıza** ikonuna (3. ikon) tıklayarak, yapay zekanın sizi nasıl anladığını ve geçmişte neleri hatırladığını saatlik/günlük bazda tek bir ekrandan görebilirsiniz.
- **Yapay Zekanın Zihnine Doğrudan Müdahale:** Eğer asistanın yanlış bir çıkarım yaptığını düşünürseniz, arayüzden ilgili anıya tıklayıp **yapay zekanın hafızasını kendi ellerinizle yeniden yazabilirsiniz.** Tüm veriler yerel `.ersinis/hafiza/` klasöründedir, buluta tek bir byte bile gitmez.
- **Manuel Anlamsal Arama (Vektörel DB Sorgusu):** Hiyerarşik olarak damıtılan bu özetler son aşamada `.ersinis/hafiza/vector_memory.db` dosyasına vektör olarak işlenir. Kullanıcı dilerse sohbet panelindeki arama (büyüteç) ikonuna tıklayarak bu devasa hafızada manuel sorgular yapabilir. Kelimesi kelimesine hatırlamadığınız haftalar önceki bir mimari kararı bile "anlamsal" (semantik) olarak aratıp anında yüzeye çıkartabilirsiniz.

### 📝 4. Bütüncül Proje Farkındalığı & Akıllı Editör
- **Bütüncül Proje Bağlamı:** Klasik asistan eklentileri sadece "aktif sekmeye" hapsolurken, Artemis `ProjectService` üzerinden çalışma alanınızın köküne bağlıdır. Bir komut verdiğinizde sadece ekrandaki koda değil; klasör ağacınıza, bağlantılı dosyalara ve `.ersinis` içerisindeki proje hafızasına (project_memory.md) bütüncül bir şekilde hakimdir.
- **Akıllı Editör (Monaco Havuz Mimarisi):** VS Code'un kalbinde yatan Monaco motoru ile native bir geliştirme deneyimi sunulur. Ancak ersinis bunu bir adım öteye taşır: Arka planda sürekli hazır bekleyen 2 adet **"Warm-Up Editor"** havuzu sayesinde dosyalar arası geçişlerde webview yükleme süresi sıfıra indirilmiştir. Ayrıca `FlutterBridge` teknolojisi ile işletim sisteminizin yerleşik kopyala/yapıştır (pano) özellikleri kusursuzca çalışır.

### 🛠️ 5. Otonom Hata Ayıklama (Error Defender)
Arka planda sessizce devriye gezen **Error Defender** (`.ersinis/artemis/error_defender.py`) isimli otonom bir nöbetçi script bulunur.
- **Nasıl Çalışır?** Projenizin loglarını (`.ersinis/hafiza/activity.ndjson`) tarar. İçerisinde belirli kritik hata anahtar kelimelerini (ERROR, EXCEPTION, FAIL vb.) arayarak tespit ettiği son 10 hatayı anında `.ersinis/artemis/active_errors.json` kütüğüne raporlar.
- **Nasıl Kullanılır (Kullanıcı Müdahalesi):** Normalde otonom çalışır ancak dilediğiniz zaman terminalde manuel olarak da tetikleyebilirsiniz: `python3 .ersinis/artemis/error_defender.py`. Sistem herhangi bir komut satırı argümanı gerektirmeden doğrudan aktif loglarınızı tarar.

### ⏰ 6. Periyodik Uyanma & Görev Otomasyonu
Artemis'i tam otonom bir asistana dönüştüren temel özellik "Periyodik Uyanma" sistemidir. Siz bilgisayar başında olmasanız bile o çalışmaya devam eder.
- **Nasıl Çalışır (Arayüz):** Ekranın sol üst köşesinde, başlık çubuğunda (Title Bar) yer alan **"Kırmızı Saat/Uyandırma"** butonuna tıkladığınızda sistem geri sayıma başlar. Geri sayım (Flutter tarafından) yönetilir ve sıfırlandığında sistem otomatik olarak Artemis'i uyandırır.
- **Görev Otomasyonu:** Uyanan Artemis, ilk iş olarak proje kök dizinindeki `.ersinis/uyanma/bekleyen_gorevler.md` dosyasını okur. Listede `[ ]` olarak işaretlenmiş en üstteki görevi alır, yapar, `[x]` olarak işaretler ve uykuya döner. Sayaç tekrar sıfırlandığında sıradaki göreve geçer.
- **Sayaç Yönetimi:** Arka planda `cron` gibi eski usul servisler kullanmak yerine ersinis, kendi iç sayaç köprüsünü kullanır. Terminalden `bash .ersinis/uyanma/counter.sh start 10m` yazarak (veya doğrudan arayüzden) sayacı tetikleyebilir, duraklatabilir veya görevler bitince otomatik kapanmasını sağlayabilirsiniz.

### 🔒 7. %100 Veri Gizliliği (Offline-First Yaklaşımı)
Uygulama, kurumsal projelerinizi ve kişisel verilerinizi en üst düzeyde korumak üzere tasarlanmıştır. 
- **Yerel Hafıza:** Artemis'in oluşturduğu tüm vektörel veritabanları, saatlik/günlük proje özetleri ve aktivite logları yalnızca kendi bilgisayarınızdaki `.ersinis/hafiza` klasöründe tutulur. Hiçbir hafıza veya kod parçası bulut veritabanlarına sızmaz.
- **Çevrimdışı Ses Tanıma:** İşletim sisteminize göre mikrofon verileriniz tamamen cihazınızda (offline) işlenir, hiçbir bulut sunucusuna sızmaz:
  - **macOS:** Ayarlar bölümünden gelişmiş `mlx-whisper` modelini (global dizine) indirip kullanabilirsiniz. Eğer indirmek istemezseniz sistemin yerleşik Speech-to-Text (STT) motoru kullanılır.
  - **Windows:** Henüz Whisper desteği bulunmadığından, varsayılan olarak cihazın yerleşik Flutter Speech-to-Text (STT) altyapısı devrededir.
- **Kapalı Devre Mimari:** Yalnızca LLM (Yapay Zeka) modellerine gönderilen zorunlu metin/kod sorguları (API üzerinden) internete çıkar, bunun dışındaki tüm orkestrasyon yerel bilgisayarınızın işlem gücüyle halledilir.

### 🤖 8. Çoklu Ajan Mimarisi (Multi-Agent Orchestration)
Artemis sadece tek bir yapay zeka değildir, o bir **"Ana Orkestratör"**dür. Büyük bir görev aldığında veya otonom uyandığında işi tek başına yapmak yerine görev dağılımı yapar.
- **Otonom PTY Alt Ajanları:** Artemis uyandığında, görevin boyutuna göre arka planda terminal sekmesi (PTY) üzerinden alt ajanları paralel olarak ayağa kaldırır. Her ajan bağımsız olarak çalışır ve Artemis bu ajanların çıktılarını harmanlar.
- **Görev ve Rol Dağılımı:** Ajanların spesifik rolleri vardır. Örneğin biri "Mimar" olarak güvenlik ve temiz kod denetimi yaparken, diğeri "Kütüphaneci" olarak context (bağlam) taraması yapar, bir diğeri ise "Uygulamacı" olarak kodu yazar.
- **%100 Sınırsız ve Özelleştirilebilir:** Alt ajanlar sisteme gömülü (hard-coded) değildir. Kullanıcı kendi yapay zekasına "Alt ajanlar için DeepSeek kullan" derse DeepSeek CLI çalıştırılır, "Cloud Code (Gemini) kullan" derse Gemini çalıştırılır. Sistem tüm ayarlarını `assets/ersinis_config.yaml` dosyasından okur. Terminalde çalışan *herhangi bir* yapay zeka CLI aracını kendi alt ajanınız olarak saniyeler içinde sisteme tanıtabilirsiniz. Sınır yoktur.

### 🎨 9. Artemis Tuval (Sonsuz Canvas & Akış Şeması)
Algoritmik diyagramlar, mimari tasarımlar ve proje akış şemaları oluşturabileceğiniz yerleşik bir "Sonsuz Tuval" modülüdür. Adeta bir mini kullanma kılavuzu gibi özetlemek gerekirse:
- **Kutular (Node'lar) ve Bağlantılar:** Sağ menüden Tuval sekmesine geçtiğinizde sınırları olmayan bir ızgarayla karşılaşırsınız. Ekrana yeni bilgi kutuları ekleyip sürükleyebilir, bu kutuların bağlantı noktalarına (Anchor) tıklayarak aralarında akıllı oklar (Edge) çizebilirsiniz.
- **Renklendirme ve Özelleştirme:** Her kutunun ve okun rengini dilediğiniz gibi değiştirebilirsiniz. Bir düğümü veya bağlantıyı seçtiğinizde beliren renk paletinden (Kırmızı, Mavi, Yeşil, Altın Sarısı vb.) projenizin hiyerarşisine uygun renklendirmeler yapabilirsiniz.
- **JSON Formatında Kayıt:** Yaptığınız şemaları üst menüdeki kaydet butonuna basarak doğrudan projenizin `.ersinis/semalar/` klasörüne JSON dosyası olarak kaydedebilir, daha sonra klasör ikonuna tıklayarak istediğiniz şemayı tekrar yükleyebilirsiniz.
- **Yapay Zeka ile Otonom Şema Çizimi:** Kendiniz çizmekle uğraşmak istemiyor musunuz? Projenizin `.ersinis/semalar/` klasöründe yer alan `SEMA_OLUSTURMA_REHBERI.md` dosyasını Artemis'e okutun ve "Bana sistemimin mimari şemasını çiz" deyin. Artemis rehberdeki formata uyarak sizin yerinize şemanın JSON kodlarını üretip doğrudan kaydeder. Ardından Tuval'den klasör ikonuna tıklayarak şemanızı saniyeler içinde ekranda görebilirsiniz!
- **Tek Tıkla Ekran Görüntüsü (Screenshot):** Üst çubuktaki kamera ikonuna tıkladığınızda, çiziminizin yüksek çözünürlüklü bir PNG ekran görüntüsü otomatik olarak alınır ve proje dizininizdeki `.ersinis/semalar/sema_gorselleri/` klasörüne yedeklenir. Sunumlarda kullanmak için birebirdir!

### 📂 10. Gelişmiş Dosya Gezgini (Smart File Explorer)
Projenizi işletim sisteminin dosya yöneticisine (Finder/Explorer) veya başka bir IDE'ye ihtiyaç duymadan doğrudan Artemis'in kokpiti içinden yönetebilirsiniz.
- **Gerçek Zamanlı (Real-Time) Git Entegrasyonu:** Arka planda `git status` mekanizması sürekli çalışarak projenizde değişen, eklenen veya silinen tüm dosyaları anında algılar ve renk kodlamasıyla arayüze yansıtır.
- **Sürükle & Bırak (Drag-and-Drop):** Dosya ve klasörleri fareyle tutup doğrudan başka bir klasörün içine saniyeler içinde taşıyabilirsiniz. Yeni dosya ve klasörleri tek tıkla oluşturabilirsiniz.
- **JetBrains / VSCode İkon Renklendirmesi:** Dosyalar uzantılarına göre (Örn: Dart mavi, JSON sarı, YAML mor) endüstri standardı Android Studio ikon renkleriyle listelenir. Bu sayede kalabalık bir projede aradığınız dosyayı göz ucuyla bile anında bulursunuz. Gizli dosyaları gösterme/gizleme özelliği de mevcuttur.

### 🎬 11. Entegre Medya İstasyonu (All-in-One Cockpit)
Uygulama geliştirirken görsel veya işitsel materyalleri incelemek için harici araçlara (VLC, QuickTime, Fotoğraflar vb.) geçiş yapmanıza gerek yoktur. Ersinis, dosya gezgininde tıkladığınız medya dosyalarını anında tanır ve kendi içinde çalıştırır.
- **Video Oynatıcı:** `.mp4`, `.mov`, `.mkv` gibi video dosyalarına tıkladığınızda, kod editörü sekmesi yerine entegre bir video oynatıcı (Chewie destekli) açılır. Eğitim veya demo videolarını doğrudan kokpit içinden izleyebilirsiniz.
- **Gelişmiş Görsel İnceleme ve Akıllı Editör:** `.png`, `.jpg`, `.webp` gibi tasarımlara tıklandığında yüksek çözünürlüklü bir resim görüntüleyici açılır. Ayrıca yeni eklenen **Yerleşik Akıllı Fotoğraf Editörü** modülü sayesinde, adeta minik bir Photoshop™ kullanıyormuş gibi dışarıdan hiçbir araca ihtiyaç duymadan uygulama içinden görsellerinizi anında düzenleyebilirsiniz (Kırpma, Filtreler, Bulanıklaştırma, Serbest Çizim, Emoji ve Metin ekleme). Değişiklikler anında proje dizininize yedeklenir.
- **Arka Plan Ses Çalar:** `.mp3`, `.wav`, `.m4a` gibi ses dosyalarına tıkladığınızda, Artemis'in dahili ses servisi anında devreye girer. Projenize ait ses efektlerini veya müzikleri siz kod yazarken arka planda dinleyebilirsiniz.

### 🌍 12. Çoklu Dil Desteği
Ersinis, sadece yerel değil, küresel çapta kullanım için tasarlandı. Ayarlar menüsünden uygulamanın dilini anında değiştirebilirsiniz. Şu anda sisteme tam entegre olarak desteklenen **8 farklı dil** seçeneği mevcuttur:
- 🇹🇷 Türkçe (`tr_TR`)
- 🇺🇸 İngilizce (`en_US`)
- 🇩🇪 Almanca (`de_DE`)
- 🇫🇷 Fransızca (`fr_FR`)
- 🇷🇺 Rusça (`ru_RU`)
- 🇨🇳 Çince (`zh_CN`)
- 🇯🇵 Japonca (`ja_JP`)
- 🇮🇳 Hintçe (`hi_IN`)

*Not: Gelecek güncellemelerde GetX çeviri altyapısı sayesinde desteklenen dil sayısının hızla artırılması planlanmaktadır.*

### 📡 13. WebRTC Ajan Ağı (A2A) ve Uzaktan Yönetim
Kendi cihazlarınız (örneğin evdeki Windows masaüstü bilgisayarınız ile ofisteki Mac bilgisayarınız) arasında doğrudan, sunucusuz (P2P) ve yüksek güvenlikli bir iletişim köprüsü kurabilirsiniz.
- **Onaysız, Anında Bağlantı:** Her iki cihazınızda da aynı Google hesabı ile giriş yaptıysanız ve sağ paneldeki *Çift Emniyetli Bağlantı* bölümünden **aynı eşleştirme şifresini** belirlediyseniz, cihazlar ağda birbirini anında bulur. Evdeki bilgisayarınızın açık ve Ersinis'in çalışıyor olması yeterlidir; karşı taraftan kimsenin bağlantıyı "Kabul Et"mesine gerek kalmadan doğrudan erişim sağlarsınız.
- **Kamera ve Masaüstü Görüntüleme:** Bağlantı kurulduktan sonra beliren ikonlara tıklayarak, uzaktaki cihazınızın kamerasını veya anlık masaüstü ekranını Ersinis'in içindeki yeni bir sekmede canlı olarak izleyebilirsiniz.
- **Karşı Ajana (Artemis'e) Komut Gönderme:** Alt bölümdeki *Tünel İletişimi* kutusu sadece mesajlaşmak için değildir. Buradan uzaktaki cihazın yapay zekasına komutlar gönderebilirsiniz. Örneğin ofisteyken evdeki bilgisayarınıza, "Şu projeyi derle ve bitince bana sonuçları yolla" diyebilirsiniz.
- **Ajanlar Arası İletişim (A2A):** Sistemdeki `.ersinis/ANAYASA.md` kuralları ve `artemise_mesaj.md` iletişim protokolleri sayesinde iki farklı cihazdaki Artemis'ler, aralarında sohbet edebilir ve senkronize ortak görevler yürütebilir.
- **Yüksek Hızlı Dosya Transferi:** Ataç ikonuna tıklayarak bilgisayarlarınız arasında arada bir bulut sunucusu olmadan (doğrudan) şifrelenmiş, yüksek hızda dosya transferleri gerçekleştirebilirsiniz. Gönderim durumu ilerleme çubuğuyla anlık gösterilir.

### 🐙 14. Yerleşik GitHub Panel
Kokpitten çıkmadan projenizi GitHub ile tam senkronize tutun. Sağ paneldeki GitHub sekmesi hesabınıza güvenli bağlanmanızı ve tüm Git operasyonlarını tek ekrandan yönetmenizi sağlar.
- **OAuth 2.0 ile Tek Tıkla Giriş:** GitHub Device Flow ile hesabınıza güvenli bağlanın; token'lar şifreli saklanır.
- **Commit, Push ve Branch Yönetimi:** Değişen dosyaları (staged/unstaged) renk kodlu olarak görün, commit mesajı yazıp tek tıkla push edin. Dallar arasında geçiş yapın ve ahead/behind durumunu takip edin.
- **Akıllı Git Durum Takibi:** Dosya değişiklikleri periyodik olarak izlenir ve arayüze anında yansıtılır.

---

## 🔗 İletişim

| Kanal | Adres |
|---|---|
| Web Sitesi | [ersinis.web.app](https://ersinis.web.app/) |
| GitHub | [github.com/nesenosun/ersinis-app](https://github.com/nesenosun/ersinis-app) |
| X (Twitter) | [@nesenosun](https://x.com/nesenosun) |
| YouTube (Arşiv & Süreç) | [youtube.com/@sinermis](https://www.youtube.com/@sinermis) |
| E-posta | [nesenosun@gmail.com](mailto:nesenosun@gmail.com) |
| Gizlilik Politikası | [ersinis.web.app/privacy.html](https://ersinis.web.app/privacy.html) |

---

## 💻 Sistem Gereksinimleri

### Zorunlu (Uygulamanın Açılması İçin)

| Gereksinim | Detay |
|---|---|
| İşletim Sistemi | macOS 12.0+ veya Windows 10+ |
| RAM | Minimum 4 GB (8 GB önerilir) |
| Depolama | En az 500 MB |
| İzinler | Kamera, Mikrofon, Konuşma Tanıma |

### Önerilen (Tüm Özellikler İçin)

```bash
brew install python ffmpeg node
```

| Program | Özellik |
|---|---|
| Python 3 | Vektörel Hafıza (RAG), Ses Tanıma |
| FFmpeg | Ses dönüştürme (Whisper için) |
| Node.js | Tarayıcı otomasyonu (Puppeteer) |
