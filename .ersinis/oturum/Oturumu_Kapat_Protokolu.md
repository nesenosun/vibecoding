> [!IMPORTANT]
> **Artemis Anayasa Kuralı:** Artemis yapay zekasının düşünerek yazılmayan hiçbir kayıt geçerli değildir.

# 🔒 Oturumu Kapat Protokolü (Sadeleştirilmiş)

"Oturumu kapat" veya "kapat" komutu alındığında aşağıdaki adımlar **sırayla ve eksiksiz** uygulanır.

---

## Adım 1 — Vektörel Hafıza Güncelle

```bash
python3 .ersinis/hafiza/vector_memory.py --index
```

## Adım 2 — Kapanış Betiğini Çalıştır

```bash
bash .ersinis/oturum/session_close.sh
```
