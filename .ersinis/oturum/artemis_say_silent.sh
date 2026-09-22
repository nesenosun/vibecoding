#!/usr/bin/env bash
# ============================================================
# 🎙️ Artemis Sessiz Yanıt Yardımcısı (.ersinis/oturum/artemis_say_silent.sh)
# Kullanım: bash .ersinis/oturum/artemis_say_silent.sh "Mesajın burada"
# ============================================================

set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  TARGET="$(readlink "$SOURCE")"
  case "$TARGET" in
    /*) SOURCE="$TARGET" ;;
    *)  SOURCE="$(dirname "$SOURCE")/$TARGET" ;;
  esac
done
SCRIPT_DIR="$(cd "$(dirname "$SOURCE")" && pwd)"
ACTIVITY_FILE="$SCRIPT_DIR/../hafiza/activity.ndjson"

# --- Mesaj argümanı kontrolü ---
if [ $# -eq 0 ]; then
  echo "Kullanım: bash .ersinis/oturum/artemis_say_silent.sh \"Mesajın burada\""
  exit 1
fi

MSG="$*"
TIMESTAMP=$(date +%s000)

# --- 1. activity.ndjson'a yaz (NDJSON append) ---
if command -v python3 &>/dev/null; then
SAFE_LOG=$(python3 - "$TIMESTAMP" "$MSG" <<'PY'
import json
import sys

timestamp = int(sys.argv[1])
message = sys.argv[2]
payload = {
    "t": timestamp,
    "n": "Artemis",
    "ty": "chat",
    "ta": "Sohbet",
    "s": message,
    "st": "success",
    "+": 0,
    "-": 0,
    "i": "minor",
}
print(json.dumps(payload, ensure_ascii=False))
PY
)
else
  SAFE_MSG=$(printf '%s' "$MSG" | tr '\n' ' ' | sed 's/\\/\\\\/g; s/"/\\"/g')
  SAFE_LOG="{\"t\":${TIMESTAMP},\"n\":\"Artemis\",\"ty\":\"chat\",\"ta\":\"Sohbet\",\"s\":\"${SAFE_MSG}\",\"st\":\"success\",\"+\":0,\"-\":0,\"i\":\"minor\"}"
fi
echo "$SAFE_LOG" >> "$ACTIVITY_FILE"

echo "[Sessiz Mod] Log kaydı başarıyla eklendi."
