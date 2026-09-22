# ⏰ Artemis Otonom Uyanma Rehberi (Anayasa)

Bu belge, Artemis'in otonom uyanma, görev icra etme ve raporlama sistemine dair TEK geçerli rehberdir.

## 1. Sayaç Komutları

```bash
# Sayacı başlat (süre zorunlu: 1m, 30s, 1h):
nohup bash .ersinis/uyanma/counter.sh start 1m > /dev/null 2>&1 &

# Sayacı duraklat:
nohup bash .ersinis/uyanma/counter.sh pause > /dev/null 2>&1 &

# Duraklatılan sayacı devam ettir:
nohup bash .ersinis/uyanma/counter.sh resume > /dev/null 2>&1 &

# Sayacı tamamen kapat:
nohup bash .ersinis/uyanma/counter.sh stop > /dev/null 2>&1 &
```

## 2. Uyanma Mekanizması

- **Tek Kaynak Flutter Sayacıdır:** Artemis kendi kendine uyanmak için arka planda kod çalıştıramaz.
- **Sürekli Döngü:** Sayaç sıfırlandığında otomatik yeniden başlar.
- **Bildirim:** Sayaç sıfırlanınca terminale mesaj gönderilir: `.ersinis/uyanma/bekleyen_gorevler.md` dosyasını oku.

## 3. Kesin Yasaklar

- Arka plan servisi (`cron`, `sleep` döngüsü) kurmak YASAK.
- Uyanma için betik (script) yazıp işi devretmek YASAK.
- Kendi başına otonom eylem YASAK. Sadece listedeki 1 görev yapılır.

## 4. Görev İcra Kuralları

1. `.ersinis/uyanma/bekleyen_gorevler.md` dosyasını oku.
2. En üstteki `[ ]` görevi al ve çöz.
3. Görevi `[x]` yaparak işaretle.
4. Hiç görev kalmadıysa sayacı DERHAL kapat.

## 5. Raporlama

- **Sesli:** `nohup bash .ersinis/oturum/artemis_say.sh "mesaj" > /dev/null 2>&1 &`
- **Sessiz:** `nohup bash .ersinis/oturum/artemis_say_silent.sh "mesaj" > /dev/null 2>&1 &`

Tüm loglar bu iki araç üzerinden akmalıdır. Doğrudan `.ndjson` düzenlemek yasaktır.
