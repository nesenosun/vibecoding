# 🤖 Ajan Rehberi

> Bu rehber, sistemde kullanılabilir tüm CLI ajanlarını ve her birinin nasıl açılacağını tanımlar. Artemis, orkestrasyon modunda kullanıcının seçtiği ajanları bu rehbere bakarak ayağa kaldırır.

## 🧭 Kullanılabilir Ajanlar

| Ajan | Açıklama | Örnek CLI Komutu | Desteklenen Model Örnekleri (2026 Güncel) | Varsayılan Port |
|---|---|---|---|---|
| **opencode** | Çok yönlü kod ajanı; dosya okuyup düzenleyebilir, terminal kullanabilir. | `script -q /dev/null opencode run "PROMPT" -m "MODEL"` | `deepseek-v4-pro`, `deepseek-v4-flash` | 8001 (Ersinis) |
| **claude** | Anthropic'in kod ajanı; derin analiz ve uzun bağlam. | `claude -p "PROMPT" -m "MODEL"` | `claude-sonnet-5` (varsayılan), `claude-opus-5`, `claude-fable-5` | — |
| **codex** | OpenAI'nin kod ajanı; güçlü kod yazma ve düzenleme. | `codex exec "PROMPT" --model "MODEL"` | `gpt-5.6-sol` (varsayılan), `gpt-5.6-terra`, `gpt-5.6-luna` | — |
| **agy** | Google Antigravity CLI; çok modelli (Gemini, Claude, GPT-OSS) genel görev ajanı. | `agy --model "MODEL" --print-timeout 60s -p "PROMPT"` | `Gemini 3.7 Flash (Medium)`, `Gemini 3.1 Pro (High)` | 8002 (İşçi) |
| **gemini** | Google'ın resmî CLI ajanı. | `gemini -p "PROMPT"` | `gemini-2.5-pro` (varsayılan), `gemini-2.5-flash` | — |

## 🔌 Rol - Ajan Eşleştirme

Orkestrasyon modunda iki rol atanır:

| Rol | Varsayılan Port | Varsayılan Model (tercih yoksa) |
|---|---|---|
| **ersinis** (Bilgi & QA) | 8001 | `deepseek-v4-flash` (opencode) |
| **isci** (Kod uygulayıcı) | 8002 | `Gemini 3.7 Flash (Medium)` (agy) |

## 🚀 Ajan Ayağa Kaldırma

Ajanlar `.ersinis/oturum/orkestrasyon_ac.sh` ile başlatılır. Bu script `.ersinis/hafiza/ajan_tercihi.json` dosyasındaki seçimleri okur ve her rol için `agent_daemon.py`'yi aşağıdaki şekilde çalıştırır:

```bash
python3 .ersinis/ajanlar/betikler/agent_daemon.py --agent ersinis --cli opencode --model "deepseek-v4-flash"
python3 .ersinis/ajanlar/betikler/agent_daemon.py --agent isci --cli agy --model "Gemini 3.7 Flash (Medium)"
```

## 🔧 Daemon Uç Noktaları

Her ajan aynı şemayı kullanır:

- `GET  /health` — sağlık kontrolü
- `GET  /state` — hafıza özeti
- `POST /reset` — hafızayı sıfırla
- `POST /message` — `{"prompt":"..."}` → ajanı çalıştır

## ⚠️ Önemli Notlar

- **Ücretli API yasağı:** Seçilen ajan/model yalnızca kullanıcının erişimine açık olduğu hizmetlerden seçilmelidir. Bakiye/limit sorunu yaşanırsa kullanıcı bilgilendirilir.
- **agy bayrak sırası:** `--model` ve `--print-timeout` mutlaka `-p`'den ÖNCE yazılmalıdır; aksi halde agy modeli sessizce yok sayıp varsayılanla devam eder (hata vermez!).
- **Türkçe karakter kuralı:** Tüm CLI çağrılarında ve raporlarda Türkçe karakterler korunur (ANAYASA madde 6).
- **Geçici dosyalar:** Tüm ara çıktılar `.ersinis/temp/` altında tutulur (ANAYASA madde 4).