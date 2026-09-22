> [!IMPORTANT]
> **Artemis Anayasa Kuralı:** Artemis yapay zekasının düşünerek yazılmayan hiçbir kayıt geçerli değildir.

# 📋 Saatlik Özet Çıkarma Protokolü

Kullanıcı Artemis'e "saatlik özet çıkar", "sıradaki saati özetle" veya "günümüze kadar özetleri çıkar" gibi bir talimat verdiğinde (veya oturum kapatma protokolü tetiklendiğinde), Artemis aşağıdaki yönergeyi harfiyen uygular.

Süreç tamamen Artemis tarafından yürütülür. Özetçi ajanı yoktur.

---

## 📡 Adım 1 — Logları Çekmek
Artemis bizzat kendi terminal aracını kullanarak sıradaki saatin loglarını `.ersinis/hafiza/activity.ndjson` dosyasından çeker.

- Özetlenecek yeni veri yoksa (son özetin bitiş anından sonra hiç kayıt yoksa), kullanıcıya bilgi ver ve işlemi sonlandır.
- Loglar varsa bunları kopyala ve Adım 2'ye geç.

## 🧠 Adım 2 — Özetleme (Artemis Bizzat Yapar)
Artemis çektiği logları kendi zekasıyla analiz eder ve özetler. Bu adımda hiçbir betik, regex veya şablon motoru kullanılmaz; tüm analiz ve yazma sürecini Artemis kendisi yürütür.

### Özetleme Kuralları (Çok Kritik)
1. **Hedef kitle ajanlardır:** İnsanlara veya yöneticilere rapor verilmiyor. "Teknik istişare gerçekleştirildi", "donanım altyapısı kapsamında" gibi süslü, şişirilmiş, bürokratik ve akademik kelimeler kesinlikle yasaktır.
2. **Boş logları şişirme:** Loglarda sadece sistemin açıldığı yazıyorsa sadece "Artemis açıldı" yaz. Kod dışı genel bir konu konuşulmuşsa (örneğin SSD formatı), "Kullanıcı SSD formatı hakkında soru sordu, kod değişikliği yok." yaz. Olmayan bir işlemi varmış gibi destanlaştırarak hafızayı çöple doldurma.
3. **Kod değişiklikleri:** Projede gerçekten kod değişikliği yapılmışsa gelecekteki ajanın işine yarayacak şu bilgileri net ve düz bir dille yaz: Hangi dosyada değişiklik yapıldı? Ne yapıldı? Neden yapıldı? (Hangi sorunu çözmek için?)
4. **Kısa ve net ol:** Gelecekteki bir ajan bu özeti okuduğunda saniyeler içinde o saatte projede ne değiştiğini (veya değişmediğini) anlamalı.
5. **Şablon cümle yasağı:** "Şu dosyalarda çalışıldı", "X adet sohbet yapıldı" gibi şablon cümleler yasaktır. Yapılan iş doğal ve net Türkçe ile anlatılır (Örn: "Firebase entegrasyonu sağlandı", "USDT cüzdan simülasyonu eklendi").

### Boş Dilim Koruması
İlgili 1 saatlik blok içinde kullanıcıyla hiçbir sohbet (`ty: "chat"`) edilmemişse ve hiçbir dosya değişikliği yapılmamışsa, o saat dilimi için kesinlikle hiçbir kayıt oluşturulmaz ve dosyaya yazılmaz.

### Biçimlendirme
- `summary` dizisindeki her cümle maksimum **180 karakter** olmalıdır.
- Değişen klasörler `changed_directories`, değiştirilen dosyalar `updated_files` alanına eklenir.

## ⚙️ Adım 3 — Yazma ve Raporlama
- Üretilen özet `.ersinis/hafiza/aktivite_ozetleri/saatlik_ozet.ndjson` dosyasının sonuna kronolojik olarak eklenir (NDJSON formatında tek satır).
- Bittiğinde Ersin'e sesli (`node .ersinis/oturum/artemis_say.js`) ve yazılı olarak hangi saat aralığının özetlendiği raporlanır.

## 🔄 Çoklu Döngü
Eğer "tümünü çıkar" dendi ise, özetlenecek yeni kayıt kalmayana kadar Adım 1, 2, 3 sırayla tekrarlanır.

---

## 📦 Çıktı Formatı (NDJSON, tek satır)
```json
{"timestamp": 1234567890123, "time_range": "HH:MM - HH:MM", "date": "YYYY-MM-DD", "summary": ["Madde 1.", "Madde 2."], "metadata": {"session_active": true, "changed_directories": ["klasor"], "updated_files": ["dosya.dart"]}}
```