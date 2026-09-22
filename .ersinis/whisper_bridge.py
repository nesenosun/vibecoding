#!/usr/bin/env python3
import sys
import os

# ffmpeg ve diğer bağımlılıkların bulunabilmesi için tüm olası yollar eklenir.

_extra_paths = [
    "/opt/homebrew/bin",       # Apple Silicon Homebrew
    "/opt/homebrew/sbin",
    "/usr/local/bin",          # Intel Homebrew
    "/usr/local/sbin",
    "/usr/bin",
    "/bin",
    "/usr/sbin",
    "/sbin",
]
os.environ["PATH"] = ":".join(_extra_paths) + ":" + os.environ.get("PATH", "")

# ── Model cache dizini ────────────────────────────────────────────────────────
home_dir = os.path.expanduser("~")
models_dir = os.path.join(home_dir, "ersinis", ".ersinis", "artemis", "modeller")
os.makedirs(models_dir, exist_ok=True)

os.environ["HF_HOME"] = models_dir
os.environ["HF_HUB_DISABLE_SYMLINKS_WARNING"] = "1"

# ── Model Yönetimi & İndirme / Transkripsiyon İşlemleri ──────────────────────────

# Sadece indirme modu
if len(sys.argv) >= 3 and sys.argv[1] == "--download":
    model_name = sys.argv[2]
    model_folder = model_name.split('/')[-1]
    local_dir = os.path.join(models_dir, model_folder)
    print(f"Model indiriliyor: {model_name} -> {local_dir}")
    try:
        from huggingface_hub import snapshot_download
        snapshot_download(
            repo_id=model_name,
            local_dir=local_dir,
            local_files_only=False
        )
        print("DOWNLOAD_SUCCESS")
        sys.exit(0)
    except Exception as e:
        print(f"Hata: Model indirilemedi: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    if len(sys.argv) < 2:
        print("Kullanım: python3 whisper_bridge.py <ses_dosyası_yolu> [model_adı]", file=sys.stderr)
        sys.exit(1)

    audio_path = sys.argv[1]
    if not os.path.exists(audio_path):
        print(f"Hata: Ses dosyası bulunamadı: {audio_path}", file=sys.stderr)
        sys.exit(1)

    model_name = "mlx-community/whisper-large-v3-turbo"
    if len(sys.argv) >= 3:
        model_name = sys.argv[2]

    model_folder = model_name.split('/')[-1]
    local_model_path = os.path.join(models_dir, model_folder)

    if os.path.isdir(local_model_path):
        model_to_use = local_model_path
    else:
        model_to_use = model_name

    # mlx_whisper import
    try:
        import mlx_whisper
    except ImportError:
        print("Hata: mlx_whisper kütüphanesi kurulu değil. Lütfen 'pip install mlx-whisper' ile yükleyin.", file=sys.stderr)
        sys.exit(1)

    try:
        result = mlx_whisper.transcribe(
            audio_path,
            path_or_hf_repo=model_to_use,
            language="tr"
        )
        text = result.get("text", "").strip()
        print(text)
    except Exception as e:
        print(f"Transkripsiyon hatası: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
