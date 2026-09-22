# Yapay Zeka İçin Şema (JSON) Oluşturma Rehberi

Bu rehber, Artemis veya diğer yapay zeka ajanlarının Flutter arayüzünde görüntülenebilen uyumlu ağaç şemaları (schema/node diagram) üretebilmesi için gereken katı kuralları içerir. 

Eğer kullanıcı senden bir şema çizmeni (bir akışı `.json` dosyası olarak görselleştirmeni) isterse, aşağıdaki kurallara **harfiyen uymak zorundasın**. Aksi takdirde Flutter uygulamasının JSON okuyucusu (parser) çöker.

## 1. Veri Tipleri (ÇOK KRİTİK)
Dart/Flutter tarafındaki veri sınıfları sıkı (strict) tiplidir. Sayısal koordinat ve boyut değerleri kesinlikle `double` (ondalıklı sayı) olarak bekler.
- **YANLIŞ:** `"px": 4000` (Tam sayı int, çökmeye neden olur)
- **DOĞRU:** `"px": 4000.0` (Ondalıklı sayı float/double)
`px`, `py`, `width`, ve `height` özelliklerinin hepsi `.0` veya `.5` gibi ondalıklı formatta yazılmalıdır.

## 2. Metin Formatı
Kutucukların içinde görünecek olan `"text"` özelliğinde alt satıra geçme (`\n`) karakterlerini kullanmaktan kaçın. Mümkün olduğunca tek satırlık, sade metinler yaz. Özel karakterler json-decode esnasında hataya yol açabilir.

## 3. JSON Kodlaması (Minify)
Şema dosyasını yazarken okunabilirlik için `indent=4` (girintileme) YAPMA. Uygulama okuyucusu tek satıra sıkıştırılmış (minified) JSON dizilerini çok daha stabil ayrıştırır.

## 4. Düğüm (Node) Özellikleri
Her bir düğüm (kutu) aşağıdaki yapıyı tam olarak barındırmalıdır:
```json
{
  "id": "e2ba3473-...",         // (String) Eşsiz bir UUIDv4
  "px": 4000.0,                 // (Float) X koordinatı
  "py": 5000.0,                 // (Float) Y koordinatı
  "text": "Kutu İsmi",          // (String) Görünen metin
  "targets": ["uuid-1", ...],   // (Array of Strings) Okların gideceği diğer node ID'leri. Hedef yoksa boş array []
  "width": 250.0,               // (Float) Kutunun genişliği
  "height": 100.0,              // (Float) Kutunun yüksekliği
  "borderColorHex": 4282664004  // (Int) Sınır rengi (varsayılan: 4282664004)
}
```

## Örnek Python Scripti
Aşağıdaki betik formatı şemalar üretmek için en güvenli yoldur. Şema üretmen gerektiğinde `run_command` ile bu tarz bir Python betiği çalıştırarak dosyayı oluştur.

```python
import json
import uuid

def create_node(px, py, text, targets=None, width=250.0, height=100.0):
    return {
        "id": str(uuid.uuid4()),
        "px": float(px),
        "py": float(py),
        "text": text,
        "targets": targets or [],
        "width": float(width),
        "height": float(height),
        "borderColorHex": 4282664004
    }

# Node'ları oluştur (Koordinatlara dikkat ederek soldan sağa veya yukarıdan aşağıya dizin)
n1 = create_node(4000.0, 5000.0, "Başlangıç Noktası")
n2 = create_node(4400.0, 5000.0, "Hedef Nokta")

# Bağlantıları (okları) kur
n1["targets"] = [n2["id"]]

nodes = [n1, n2]

# Tek satır (minified) olarak dosyaya kaydet
with open("semalar/ornek_sema.json", "w", encoding="utf-8") as f:
    json.dump(nodes, f, separators=(",", ":"), ensure_ascii=False)
```

**Son Hatırlatma:** `semalar` klasörü altına yazacağın her `.json` dosyası otomatik olarak arayüzde görünür olacaktır. Sadece float sayı kurallarına uyduğundan emin ol.
