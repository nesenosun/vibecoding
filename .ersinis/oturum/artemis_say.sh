#!/usr/bin/env bash
# Artemis Sesli Yanıt Betiği
set -euo pipefail
MESSAGE="$1"
OUT_FILE="${2:-}"

# Dinamik Yol Yönetimi
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

# Log activity to memory
printf '{"t":%s,"n":"Artemis","ty":"chat","ta":"Sohbet","s":"%s","st":"success","+":0,"-":0,"i":"minor"}\n' "$(date +%s000)" "$MESSAGE" >> "$ACTIVITY_FILE"

# Ses Kuyruğu (Kilit) Yönetimi - Eşzamanlı konuşmaları sıraya sokmak için
LOCK_FILE="/tmp/artemis_say.lock"

# Eğer başka bir say işlemi varsa veya lock dosyası mevcutsa bekle
while [ -f "$LOCK_FILE" ]; do
  # Stale lock koruması: Kilidi tutan PID sistemde aktif değilse kilidi kaldır
  if [ -s "$LOCK_FILE" ]; then
    LOCK_PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$LOCK_PID" ] && ! ps -p "$LOCK_PID" >/dev/null 2>&1; then
      rm -f "$LOCK_FILE"
      break
    fi
  fi
  sleep 0.1
done

# Kilidi al (Kendi PID'imizi yaz)
echo $$ > "$LOCK_FILE"

# İşlem bittiğinde kilidi kaldırmayı garanti et
cleanup() {
  rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# Speak using macOS say command if not in silent mode
if [ ! -f "$SCRIPT_DIR/.artemis_sessiz" ] && command -v say >/dev/null 2>&1; then
  touch /tmp/artemis_is_speaking
  if [ -n "$OUT_FILE" ]; then
    say -o "$OUT_FILE" "$MESSAGE"
    echo "[Artemis] Ses dosyası kaydedildi: $OUT_FILE"
  else
    say "$MESSAGE"
  fi
  rm -f /tmp/artemis_is_speaking
fi
