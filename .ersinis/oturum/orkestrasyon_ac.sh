#!/usr/bin/env bash
# ============================================================
# 🛰️  Orkestrasyon Açılış Scripti (Orkestrasyon_ac.sh)
# ANAYASA madde 3 gereği: Kullanıcının .ersinis/hafiza/ajan_tercihi.json
# dosyasındaki seçimlerine göre ersinis ve isci ajan daemonlarını ayağa kaldırır.
#
# Kullanım:
#   bash .ersinis/oturum/orkestrasyon_ac.sh          # tercih dosyasına göre aç
#   bash .ersinis/oturum/orkestrasyon_ac.sh --close  # kapat
# ============================================================

set -euo pipefail

# --- Yol yönetimi ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_ERSINIS=""
CUR="$SCRIPT_DIR"
while [ -n "$CUR" ]; do
  if [ -f "$CUR/ANAYASA.md" ] && [ -d "$CUR/hafiza" ]; then
    GLOBAL_ERSINIS="$CUR"
    break
  fi
  NEXT="$(dirname "$CUR")"
  [ "$NEXT" = "$CUR" ] && break
  CUR="$NEXT"
done
[ -z "$GLOBAL_ERSINIS" ] && GLOBAL_ERSINIS="$SCRIPT_DIR"

PROJ_ERSINIS="$(pwd)/.ersinis"
[ -d "$PROJ_ERSINIS" ] || PROJ_ERSINIS="$GLOBAL_ERSINIS"

TERCIH_FILE="$PROJ_ERSINIS/hafiza/ajan_tercihi.json"
DAEMON_SCRIPT="$GLOBAL_ERSINIS/ajanlar/betikler/agent_daemon.py"
AGENT_LOG_DIR="$GLOBAL_ERSINIS/ajanlar/loglar"
AGENT_PIDS_FILE="$GLOBAL_ERSINIS/ajanlar/run/agent_pids"
ACTIVITY_FILE="$PROJ_ERSINIS/hafiza/activity.ndjson"

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

mkdir -p "$AGENT_LOG_DIR"

# --- Kapatma modu ---
if [ "${1:-}" = "--close" ]; then
  echo -e "${CYAN}🛑 Orkestrasyon kapatılıyor...${RESET}"
  if [ -f "$AGENT_PIDS_FILE" ]; then
    while IFS= read -r PID; do
      PID="$(echo "$PID" | tr -d '[:space:]')"
      [ -n "$PID" ] && kill "$PID" 2>/dev/null || true
    done < "$AGENT_PIDS_FILE"
    rm -f "$AGENT_PIDS_FILE"
  fi
  for AGENT in ersinis isci; do
    PID_FILE="$GLOBAL_ERSINIS/ajanlar/run/${AGENT}.pid"
    if [ -f "$PID_FILE" ]; then
      PID="$(tr -d '[:space:]' < "$PID_FILE" 2>/dev/null || true)"
      [ -n "$PID" ] && kill "$PID" 2>/dev/null || true
      rm -f "$PID_FILE"
    fi
  done
  echo -e "${GREEN}✅ Orkestrasyon kapatıldı.${RESET}"
  exit 0
fi

# --- Tercih dosyasını oku ---
if [ ! -f "$TERCIH_FILE" ]; then
  echo -e "${RED}❌ Tercih dosyası bulunamadı: $TERCIH_FILE${RESET}"
  echo -e "   Önce Artemis'e orkestrasyon modunu seçip ajan tercihlerini kaydettirin."
  exit 1
fi

TERCIH="$(python3 -c "
import json,sys
d=json.load(open('$TERCIH_FILE',encoding='utf-8'))
print(json.dumps(d))
")"

MODE="$(echo "$TERCIH" | python3 -c "import json,sys; print(json.load(sys.stdin).get('mod',''))")"

if [ "$MODE" != "orkestrasyon" ] && [ "$MODE" != "tam" ]; then
  echo -e "${YELLOW}⚠️  Tercih dosyasındaki mod 'orkestrasyon' değil ('$MODE'). Ajanlar açılmıyor.${RESET}"
  exit 0
fi

ERSINIS_CLI="$(echo "$TERCIH" | python3 -c "import json,sys; d=json.load(sys.stdin).get('ersinis',{}); print(d.get('cli') or '')")"
ERSINIS_MODEL="$(echo "$TERCIH" | python3 -c "import json,sys; d=json.load(sys.stdin).get('ersinis',{}); print(d.get('model') or '')")"
ISCI_CLI="$(echo "$TERCIH" | python3 -c "import json,sys; d=json.load(sys.stdin).get('isci',{}); print(d.get('cli') or '')")"
ISCI_MODEL="$(echo "$TERCIH" | python3 -c "import json,sys; d=json.load(sys.stdin).get('isci',{}); print(d.get('model') or '')")"

# Boşsa varsayılanları kullan
[ -z "$ERSINIS_CLI" ] && ERSINIS_CLI="opencode"
[ -z "$ERSINIS_MODEL" ] && ERSINIS_MODEL="opencode-go/deepseek-v4-flash"
[ -z "$ISCI_CLI" ] && ISCI_CLI="agy"
[ -z "$ISCI_MODEL" ] && ISCI_MODEL="Gemini 3.7 Flash (Medium)"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${BOLD}${GREEN}🛰️  Orkestrasyon Açılıyor${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

: > "$AGENT_PIDS_FILE"

start_agent() {
  local AGENT="$1" PORT="$2" CLI="$3" MODEL="$4"
  local HEALTH_URL="http://127.0.0.1:${PORT}/health"
  local OUT_LOG="$AGENT_LOG_DIR/agent_${AGENT}.out"
  local PID=""

  for attempt in 1 2 3; do
    if curl -s --max-time 2 "$HEALTH_URL" >/dev/null 2>&1; then
      if [ -n "$PID" ]; then
        echo "$PID" >> "$AGENT_PIDS_FILE"
      else
        [ -f "$GLOBAL_ERSINIS/ajanlar/run/${AGENT}.pid" ] && cat "$GLOBAL_ERSINIS/ajanlar/run/${AGENT}.pid" >> "$AGENT_PIDS_FILE" || true
      fi
      echo -e "  ${GREEN}✅ ${AGENT}${RESET} → hazır (zaten açık)"
      return 0
    fi

    [ -n "$PID" ] && kill -9 "$PID" 2>/dev/null || true
    nohup python3 "$DAEMON_SCRIPT" --agent "$AGENT" --cli "$CLI" --model "$MODEL" >>"$OUT_LOG" 2>&1 &
    PID=$!
    sleep 2
  done

  if curl -s --max-time 2 "$HEALTH_URL" >/dev/null 2>&1; then
    echo "$PID" >> "$AGENT_PIDS_FILE"
    echo -e "  ${GREEN}✅ ${AGENT}${RESET} → hazır (cli=$CLI, model=$MODEL)"
  else
    echo -e "  ${RED}❌ ${AGENT}${RESET} → 3 denemede başlatılamadı!"
    kill -9 "$PID" 2>/dev/null || true
    return 1
  fi
}

start_agent "ersinis" "8001" "$ERSINIS_CLI" "$ERSINIS_MODEL" || true
start_agent "isci" "8002" "$ISCI_CLI" "$ISCI_MODEL" || true

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

MSG="Orkestrasyon açılışı tamamlandı. Ersinis ve isci ajanları seçilen modellerle ayağa kaldırıldı."
echo "{\"t\":$(date +%s000),\"n\":\"Artemis\",\"ty\":\"chat\",\"ta\":\"Sistem\",\"s\":\"${MSG}\",\"st\":\"success\",\"+\":0,\"-\":0,\"i\":\"major\"}" >> "$ACTIVITY_FILE"