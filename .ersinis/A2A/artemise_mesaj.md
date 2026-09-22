# 🤖 Artemis'ten Artemis'e Mesajlaşma Protokolü

Bu doküman, bir cihazdaki Artemis'in (örneğin Mac) diğer cihazdaki Artemis'e (örneğin Windows) nasıl mesaj gönderdiğini ve bu sistemin mimarisini açıklamaktadır.

## 🔗 Sistemin Çalışma Mantığı

Ersinis uygulaması, cihazlar arasında P2P (Peer-to-Peer) veri aktarımı sağlamak için **WebRTC Data Channel** altyapısını kullanır. Ancak Artemis bir yapay zeka ajanı olarak (cli/terminal tabanlı) doğrudan Flutter'ın içindeki Dart bellek alanına erişemez. Bu köprüyü kurmak için yerel bir Webhook (HTTP Sunucusu) kullanılır.

Mimari şu şekilde işler:

1. **Webhook Sunucusu:**
   Flutter tarafındaki `WebRTCService` (`lib/services/webrtc_service.dart`), uygulama başlatıldığında arkaplanda **`localhost:3000`** portunda çalışan yerel bir HTTP sunucusu açar.
   Bu sunucu sadece `POST /send` isteklerini dinler.

2. **Ajanın Mesaj Göndermesi (Curl):**
   Artemis (Terminal Ajanı), karşı cihaza bir mesaj veya komut göndermek istediğinde basit bir HTTP POST isteği yapar. Mesaj içeriği (body) doğrudan iletilmek istenen metindir.

   Örnek Komut:
   ```bash
   curl -X POST -H "Content-Type: text/plain" -d "Merhaba Karşı Artemis! Nasılsın?" http://localhost:3000/send
   ```

3. **Verinin WebRTC'ye Aktarılması:**
   `WebRTCService` bu POST isteğini alır almaz, gelen *body* metnini `sendMessage(content)` fonksiyonuna iletir.
   `sendMessage`, metni paketleyerek aktif olan WebRTC Data Channel üzerinden doğrudan karşı taraftaki cihaza fırlatır.

4. **Karşı Tarafın Veriyi Alması:**
   Karşı cihazdaki `WebRTCService`'in `onDataChannel` -> `onMessage` dinleyicisi bu mesajı yakalar.
   Gelen mesaj güvenlikten geçirilir (_sanitizeMessage_) ve yapay zekanın (Artemis'in) okuyabilmesi için `_injectToAI()` metodu aracılığıyla `.ersinis/artemis/input.txt` dosyasına yazılır.
   Dosyadaki bu değişiklik, FileWatcher (Dosya İzleyici) aracılığıyla anında algılanarak karşı cihazdaki Artemis'in PTY/Terminal arayüzüne basılır. Böylece diğer ajan mesajı almış olur.

## ⚠️ Dikkat Edilmesi Gerekenler (Gelecek Ajanlar İçin)

* **Port Çakışması:** WebRTC servisi kapanırken `_webhookServer?.close();` komutu ile sunucunun kapatıldığından emin olunmalıdır. Aksi halde `Address already in use` hatası alınır (bu kural 25 Temmuz 2026'da koda eklenmiştir).
* **Format:** Mesaj gönderirken karmaşık JSON formatları yerine doğrudan metin (plain text) gönderimi de çalışır, ancak sistem mesajları veya dosya meta verileri için `[SYS]:` gibi prefixler veya stringleştirilmiş JSON kullanmak iyi bir standarttır.
* **Bağlantı Şartı:** Bu webhook'un mesajı karşıya iletebilmesi için, iki uygulamanın WebRTC üzerinden başarıyla bağlanmış ve **DataChannel'ın açık (Open)** durumda olması şarttır.

## 📁 Dosya Gönderimi

Terminaldeki ajan, karşı cihaza bir dosya göndermek istediğinde, sadece dosyanın **mutlak yolunu (absolute path)** webhook'un `/send_file` rotasına göndermelidir:

```bash
curl -X POST -H "Content-Type: text/plain" -d "~/Projeler/ornek-proje/.ersinis/ortak_klasor/test_raporu.pdf" http://localhost:3000/send_file
```

Sistem bu yolu okur, `File` nesnesi oluşturur ve uygulamanın WebRTC alt yapısındaki `sendFile()` metodunu otomatik olarak tetikler. **Gelen dosyalar HER ZAMAN karşı cihazdaki `.ersinis/ortak_klasor/` dizinine kaydedilir. Bir ajan karşıdan dosya bekliyorsa veya bir dosyanın ulaştığı bildirilmişse, işlemi gerçekleştirmek için İLK OLARAK bu klasöre bakmalıdır.**

## 🤝 Ajanlar Arası (A2A) Soru-Cevap Kalıbı

Gelen her CLI girdisi `activity.ndjson` dosyasına işlendiğinden dolayı ajanların birbirleriyle konuşmaları (geçmişe dönük özet çıkartma açısından) büyük bir avantajdır. Ekstra karmaşık bir JSON sistemine gerek yoktur; mesajlar sanki kullanıcı atıyormuş gibi terminale düşer. Ancak ajanlar arası konuşmayı ayırt etmek için kesin bir **Soru Kalıbı** uygulanmalıdır.

Kullanıcı "diğer ajan", "windows'a sor", "evdeki ajana bak", "işteki artemisden iste" vb. bir komut verdiğinde gönderilecek mesajın formatı ŞU ŞEKİLDE OLMALIDIR:

1. Mesaj ZORUNLU olarak **"Ben Artemis"** diyerek başlamalıdır.
2. Soru veya istek iletilmelidir.
3. Mesajın sonuna ZORUNLU olarak **"Lütfen .ersinis/A2A/artemise_mesaj.md dosyasına uygun cevaplayınız."** cümlesi eklenmelidir.
4. **Uzunluk Sınırı ve Uyanma Tetikleyicisi (Kritik):** Karşı ajana gönderilecek metin (soru veya cevap) **600 karakteri geçiyorsa**, metin doğrudan gönderilmemelidir. Bunun yerine mesaj `.ersinis/ortak_klasor/` dizininde bir `.md` dosyası olarak kaydedilmeli ve `curl localhost:3000/send_file` komutuyla DOSYA OLARAK gönderilmelidir. **DİKKAT:** Sadece dosya göndermek karşı ajanı UYANDIRMAZ! Dosyayı gönderdikten HEMEN SONRA, karşı ajanı uyandırmak için mutlaka `curl localhost:3000/send` ile kısa bir mesaj atılmalıdır: "Ben Artemis. İstediğin cevabı/soruyu [Dosya Adı] dosyası olarak gönderdim, lütfen ortak klasörü kontrol et. Lütfen .ersinis/A2A/artemise_mesaj.md dosyasına uygun cevaplayınız."
5. **Cevap Beklemek YASAKTIR:** Ajan soruyu (`curl` ile) gönderdikten sonra işlemi bitirmeli ve ASLA cevap gelmesini (sleep, while döngüsü vb. ile) beklememelidir. Sistem tamamen reaktif (olay güdümlü) çalışır; cevap geldiğinde sisteme yeni bir girdi düşecek ve ajan otomatik olarak sıfırdan uyandırılacaktır.

**Örnek Soru Gönderim Komutu:**
```bash
curl -X POST -H "Content-Type: text/plain" -d "Ben Artemis. [Soru içeriği buraya]. Lütfen .ersinis/A2A/artemise_mesaj.md dosyasına uygun cevaplayınız." http://localhost:3000/send
```

**Yanıtlayan Ajanın Görevi:**
Kendisine gelen mesajın "Ben Artemis" ile başladığını ve sonundaki `.ersinis/A2A/artemise_mesaj.md` uyarısını gören ajan, o anda sorunun normal bir kullanıcıdan değil, KARŞI CİHAZDAKİ DİĞER AJANDAN geldiğini anlar. Bu durumda cevap verirken, kendi terminalindeki kullanıcısına hitap etmez; cevabını doğrudan `curl -X POST -H "Content-Type: text/plain" -d "Cevap içeriği" http://localhost:3000/send` komutu aracılığıyla diğer ajana (geriye) gönderir.
