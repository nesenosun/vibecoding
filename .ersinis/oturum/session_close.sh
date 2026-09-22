#!/usr/bin/env bash
# ============================================================
# 🧠 Ersinis Oturum Kapanış Protokolü (Universal)
# Versiyon: 2.0
# Bu betik her macOS kullanıcısı için evrensel standartlarda çalışır.
# ============================================================

set -euo pipefail

# --- 1. Dinamik Yol Yönetimi ---
# Betiğin bulunduğu global klasör (örn: ~/ersinis/.ersinis/oturum)
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


# Aktif proje dizini (CWD veya parametre)
PROJ_DIR="${1:-$(pwd)}"

IS_VALID_PROJECT=false
PROJ_ERSINIS=""

if [ -d "$PROJ_DIR/.ersinis" ]; then
  IS_VALID_PROJECT=true
  PROJ_ERSINIS="$PROJ_DIR/.ersinis"
elif [ -f "$PROJ_DIR/ANAYASA.md" ] && [ -d "$PROJ_DIR/hafiza" ]; then
  IS_VALID_PROJECT=true
  PROJ_ERSINIS="$PROJ_DIR"
fi

if [ "$IS_VALID_PROJECT" = false ]; then
  RED='\033[0;31m'
  RESET='\033[0m'
  echo -e "${RED}⚠️  Hata: Çalışma dizini geçerli bir Ersinis projesi değil (.ersinis bulunamadı veya ANAYASA.md eksik).${RESET}"
  echo -e "   Çalıştığın dizin: $PROJ_DIR"
  exit 1
fi

ACTIVITY_FILE="$PROJ_ERSINIS/hafiza/activity.ndjson"
PROJECT_MEMORY="$PROJ_ERSINIS/hafiza/project_memory.md"

# --- 2. Renk Kodları ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║     🧠 Ersinis Oturum Kapanış Protokolü Başladı     ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

# --- 3. Temel Kontroller ---
if [ ! -f "$ACTIVITY_FILE" ]; then
  touch "$ACTIVITY_FILE"
fi

if [ ! -f "$PROJECT_MEMORY" ]; then
  echo -e "${YELLOW}⚠️  Hafıza dosyası (project_memory.md) bulunamadı.${RESET}"
  exit 1
fi

# --- 4. Olay Analizi ---
echo -e "${GREEN}📖 Oturum olayları analiz ediliyor...${RESET}"

# Son olayları oku (10.000 satır sınırı performans içindir)
IMPORTANT_EVENTS=$(tail -n 10000 "$ACTIVITY_FILE" 2>/dev/null | grep -E '"i"\s*:\s*"(major|moderate)"' | grep -E '"ty"\s*:\s*"(edit|delete|write|shell)"' || true)

EVENT_COUNT=0
if [ -n "$IMPORTANT_EVENTS" ]; then
  EVENT_COUNT=$(printf '%s\n' "$IMPORTANT_EVENTS" | grep -c '"ty"' 2>/dev/null || true)
fi
echo -e "   → ${EVENT_COUNT} önemli olay tespit edildi."

# --- 5. Dosya Değişiklik Listesi ---
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
CHANGED_FILES=$(echo "$IMPORTANT_EVENTS" | grep -oE '"ta"\s*:\s*"[^"]+"' | sed 's/"ta"[[:space:]]*:[[:space:]]*"//;s/"//' | xargs -I{} basename {} | sort -u | head -30 || true)

FILE_LIST=""
if [ -n "$CHANGED_FILES" ]; then
  while IFS= read -r f; do
    FILE_LIST="$FILE_LIST\n  - \`$f\`"
  done <<< "$CHANGED_FILES"
fi

# --- 6. Rapor Sunumu ---
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}✅ OTURUM KAPANIŞ RAPORU — $TIMESTAMP${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "   📂 Önemli olay sayısı : ${EVENT_COUNT}"
if [ -n "$FILE_LIST" ]; then
  echo -e "   📝 Değiştirilen dosyalar:$FILE_LIST"
fi
echo ""

# Kritik kararları ve görevleri göster
grep "\[KRİTİK\]" "$PROJECT_MEMORY" 2>/dev/null | tail -3 | sed 's/^/   ⚠️  KRİTİK: /' || true
grep "\[GÖREV\]" "$PROJECT_MEMORY" 2>/dev/null | tail -3 | sed 's/^/   📌 GÖREV: /' || true

# --- 7. Sesli Kapanış (Sessiz mod kontrolüyle) ---
VOICE_MSG="Oturum kapanış protokolü tamamlandı. İyi çalışmalar."

if [ -f "$SCRIPT_DIR/artemis_say.js" ]; then
    ARTEMIS_SAY="$SCRIPT_DIR/artemis_say.js"
else
    ARTEMIS_SAY="$GLOBAL_ERSINIS/oturum/artemis_say.js"
fi

if [ -f "$ARTEMIS_SAY" ]; then
    node "$ARTEMIS_SAY" "$VOICE_MSG" &
elif command -v say &>/dev/null; then
    say "$VOICE_MSG" &
fi

# --- 8. Vektörel Hafıza Güncelleme ---
VECTOR_PY="$GLOBAL_ERSINIS/hafiza/vector_memory.py"
if [ -f "$VECTOR_PY" ]; then
  echo -e "${GREEN}🔍 Vektörel hafıza güncelleniyor...${RESET}"
  python3 "$VECTOR_PY" --index >/dev/null 2>&1 || true
fi

# --- 9. Ajan Daemonlarını Kapat (Stateful HTTP) ---
# ANAYASA madde 2 ile açılan ajan daemonları (ersinis/isci)
# 8001/8002 portlarını dinler. Oturum kapanışında üç katmanlı temizlik uygulanır:
#   1) .agent_pids dosyasındaki PID'leri kapat
#   2) .agent_<name>_daemon.pid dosyalarını oku ve kapat
#   3) 8001/8002 portlarını hâlâ dinleyen süreçleri lsof ile yakala
AGENT_PIDS_FILE="$GLOBAL_ERSINIS/ajanlar/run/agent_pids"
declare -a AGENT_NAMES=("ersinis" "isci")
declare -a AGENT_PORTS=(8001 8002)
KILLED_COUNT=0

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}🛑 Ajan daemonları kapatılıyor...${RESET}"

# 1) .agent_pids dosyasındaki PID'leri kapat
if [ -f "$AGENT_PIDS_FILE" ]; then
  while IFS= read -r PID; do
    PID="$(echo "$PID" | tr -d '[:space:]')"
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      kill "$PID" 2>/dev/null || true
      KILLED_COUNT=$((KILLED_COUNT + 1))
      echo -e "  ${GREEN}✅ PID ${PID} durduruldu${RESET} (.agent_pids)"
    fi
  done < "$AGENT_PIDS_FILE"
  rm -f "$AGENT_PIDS_FILE"
fi

# 2) .agent_<name>_daemon.pid dosyalarını oku ve kapat
for AGENT in "${AGENT_NAMES[@]}"; do
  PID_FILE="$GLOBAL_ERSINIS/ajanlar/run/${AGENT}.pid"
  if [ -f "$PID_FILE" ]; then
    PID="$(tr -d '[:space:]' < "$PID_FILE" 2>/dev/null || true)"
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      kill "$PID" 2>/dev/null || true
      KILLED_COUNT=$((KILLED_COUNT + 1))
      echo -e "  ${GREEN}✅ ${AGENT} daemon (PID ${PID}) durduruldu${RESET}"
    fi
    rm -f "$PID_FILE"
  fi
done

# 3) Portları hâlâ dinleyen süreçleri yakala (yedeğe karşı, orphan süreçler)
if command -v lsof >/dev/null 2>&1; then
  for PORT in "${AGENT_PORTS[@]}"; do
    PORT_PIDS="$(lsof -ti tcp:"${PORT}" -sTCP:LISTEN 2>/dev/null || true)"
    if [ -n "$PORT_PIDS" ]; then
      for PID in $PORT_PIDS; do
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
          kill "$PID" 2>/dev/null || true
          KILLED_COUNT=$((KILLED_COUNT + 1))
          echo -e "  ${GREEN}✅ Port ${PORT} dinleyen PID ${PID} durduruldu${RESET}"
        fi
      done
    fi
  done
else
  echo -e "  ${YELLOW}⚠️  lsof bulunamadı: port tabanlı temizlik atlandı${RESET}"
fi

# 4) Zarif kapanış için kısa bekleme, hâlâ ayaktaysa SIGKILL
sleep 1
for PORT in "${AGENT_PORTS[@]}"; do
  if command -v lsof >/dev/null 2>&1; then
    PORT_PIDS="$(lsof -ti tcp:"${PORT}" -sTCP:LISTEN 2>/dev/null || true)"
    if [ -n "$PORT_PIDS" ]; then
      for PID in $PORT_PIDS; do
        kill -9 "$PID" 2>/dev/null || true
        echo -e "  ${YELLOW}⚠️  Port ${PORT} PID ${PID} force-kill edildi${RESET}"
      done
    fi
  fi
done

if [ "$KILLED_COUNT" -eq 0 ]; then
  echo -e "  ${YELLOW}• Ayakta olan ajan daemonu bulunamadı (zaten kapalı).${RESET}"
else
  echo -e "  ${GREEN}✓ Toplam ${KILLED_COUNT} ajan daemon süreci durduruldu.${RESET}"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# --- 10. Aktiflik Temizliği ---
rm -f "$GLOBAL_ERSINIS/oturum/artemis_active"

echo -e "${GREEN}✓ Oturum güvenli bir şekilde kapatıldı.${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
