#!/usr/bin/env bash
# ============================================================
# 📅 Artemis Haftalık Özet Protokolü (weekly_summary.sh)
# Versiyon: 1.0
# Kullanım: bash .ersinis/hafiza/weekly_summary.sh [gün_sayısı]
# ============================================================

DAYS=${1:-7}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_MEMORY="$PROJECT_DIR/.ersinis/hafiza/project_memory.md"
ACTIVITY_JSON="$PROJECT_DIR/.ersinis/hafiza/activity.ndjson"

# Renkler (Modern ve Premium Arayüz İçin HSL Uyarıları)
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

[ -t 1 ] && clear || true
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║         📊 ARTEMİS — KOKPİT RAPORU (SON $DAYS GÜN)          ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Tarih Hesaplama (macOS Uyumlu)
if ! START_DATE=$(date -v-${DAYS}d +%Y-%m-%d 2>/dev/null); then
  # Linux Fallback
  START_DATE=$(date -d "$DAYS days ago" +%Y-%m-%d 2>/dev/null || echo "")
fi

echo -e "📅 Rapor Başlangıcı:  ${BOLD}$START_DATE${NC} (Son $DAYS Gün)"
echo -e "⏱️  Rapor Tarihi:      ${BOLD}$(date '+%Y-%m-%d %H:%M')${NC}"
echo ""

# --- 1. Bellek Dosyasındaki Değişiklikleri Analiz Et ---
echo -e "${CYAN}🎯 Kronolojik Gelişmeler (project_memory.md):${NC}"
echo -e "--------------------------------------------------"

FOUND_MEMORY=0
if [ -f "$PROJECT_MEMORY" ]; then
  # project_memory.md dosyasındaki kronolojik kayıtları tara
  # Örnek format: - **[2026-05-22 17:09]:** ...
  while IFS= read -r line; do
    # Satır kronolojik kayıt satırı mı?
    if [[ "$line" =~ ^-[[:space:]]\*\*\[([0-9]{4}-[0-9]{2}-[0-9]{2})[[:space:]]([0-9]{2}:[0-9]{2})\]:\*\*(.*)$ ]]; then
      ENTRY_DATE="${BASH_REMATCH[1]}"
      ENTRY_TIME="${BASH_REMATCH[2]}"
      ENTRY_CONTENT="${BASH_REMATCH[3]}"
      
      # Tarih karşılaştırması yapalım (tarihleri YYYYMMDD biçimine getirerek)
      DATE_STR_1=$(echo "$ENTRY_DATE" | tr -d '-')
      DATE_STR_2=$(echo "$START_DATE" | tr -d '-')
      
      if [ "$DATE_STR_1" -ge "$DATE_STR_2" ]; then
        FOUND_MEMORY=1
        # KRİTİK, GEÇİCİ, GÖREV etiketlerini renklendir
        HIGHLIGHTED_CONTENT="$ENTRY_CONTENT"
        HIGHLIGHTED_CONTENT=$(echo "$HIGHLIGHTED_CONTENT" | sed "s/\[KRİTİK\]/${RED}${BOLD}[KRİTİK]${NC}/g")
        HIGHLIGHTED_CONTENT=$(echo "$HIGHLIGHTED_CONTENT" | sed "s/\[GEÇİCİ\]/${YELLOW}${BOLD}[GEÇİCİ]${NC}/g")
        HIGHLIGHTED_CONTENT=$(echo "$HIGHLIGHTED_CONTENT" | sed "s/\[GÖREV\]/${CYAN}${BOLD}[GÖREV]${NC}/g")
        
        echo -e "  📌 [${YELLOW}$ENTRY_DATE $ENTRY_TIME${NC}]: $HIGHLIGHTED_CONTENT"
      fi
    fi
  done < "$PROJECT_MEMORY"
fi

if [ $FOUND_MEMORY -eq 0 ]; then
  echo -e "  ${YELLOW}Bu tarih aralığında project_memory.md üzerinde kayıt bulunamadı.${NC}"
fi
echo ""

# --- 2. Activity.json İstatistiklerini Çıkar ---
echo -e "${CYAN}📈 Aktivite Analizi (activity.json):${NC}"
echo -e "--------------------------------------------------"

if [ -f "$ACTIVITY_JSON" ]; then
  CHAT_COUNT=0
  EDIT_COUNT=0
  SHELL_COUNT=0
  TOTAL_ADD=0
  TOTAL_DEL=0
  
  # Başlangıç tarihinin saniye karşılığını bir kez hesapla (performans ve set -e güvenliği için döngü dışına alındı)
  START_SEC=$(date -j -f "%Y-%m-%d" "$START_DATE" "+%s" 2>/dev/null || true)
  if [ -z "$START_SEC" ] || [ "$START_SEC" -eq 0 ] 2>/dev/null; then
    START_SEC=$(date -d "$START_DATE" "+%s" 2>/dev/null || echo "0")
  fi
  
  # NDJSON satır satır okunur
  while IFS= read -r line; do
    # Basit bir json parser mantığı (grep yerine sed/awk veya jq kullanılabilir ama harici bağımlılıkları azaltalım)
    # Tipi belirle
    TYPE=$(echo "$line" | sed -n 's/.*"ty":"\([^"]*\)".*/\1/p')
    
    # Zaman damgasını saniye cinsinden al
    TIMESTAMP=$(echo "$line" | sed -n 's/.*"t":\([0-9]*\).*/\1/p')
    if [ -z "$TIMESTAMP" ]; then
      # ISO formatında olabilir veya timestamp alanı olabilir
      TIMESTAMP_STR=$(echo "$line" | sed -n 's/.*"timestamp":"\([^"]*\)".*/\1/p')
      if [ ! -z "$TIMESTAMP_STR" ]; then
        # ISO string'i saniyeye çevir (macOS)
        TIMESTAMP=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$TIMESTAMP_STR" "+%s" 2>/dev/null)
        [ -z "$TIMESTAMP" ] && TIMESTAMP=$(date -j -f "%Y-%m-%d %H:%M:%S" "$TIMESTAMP_STR" "+%s" 2>/dev/null)
      fi
    else
      # Milisaniyeyi saniyeye çevir
      TIMESTAMP=$((TIMESTAMP / 1000))
    fi
    
    # Eğer timestamp varsa ve son N gün içindeyse say
    if [ ! -z "$TIMESTAMP" ]; then
      if [ "$TIMESTAMP" -ge "$START_SEC" ]; then
        case "$TYPE" in
          chat)
            CHAT_COUNT=$((CHAT_COUNT + 1))
            ;;
          edit|write)
            EDIT_COUNT=$((EDIT_COUNT + 1))
            # Ekleme/Silme satır sayılarını al
            ADD=$(echo "$line" | sed -n 's/.*"+":\([0-9]*\).*/\1/p')
            DEL=$(echo "$line" | sed -n 's/.*"-":\([0-9]*\).*/\1/p')
            [ ! -z "$ADD" ] && TOTAL_ADD=$((TOTAL_ADD + ADD))
            [ ! -z "$DEL" ] && TOTAL_DEL=$((TOTAL_DEL + DEL))
            ;;
          shell)
            SHELL_COUNT=$((SHELL_COUNT + 1))
            ;;
        esac
      fi
    fi
  done < "$ACTIVITY_JSON"
  
  echo -e "  💬 Sohbet Girişleri:    ${BOLD}$CHAT_COUNT${NC} mesaj"
  echo -e "  📝 Dosya Değişiklikleri: ${BOLD}$EDIT_COUNT${NC} işlem (${GREEN}+$TOTAL_ADD${NC} satır, ${RED}-$TOTAL_DEL${NC} satır)"
  echo -e "  💻 Terminal Komutları:   ${BOLD}$SHELL_COUNT${NC} komut"
else
  echo -e "  ${YELLOW}activity.json dosyası bulunamadı.${NC}"
fi

echo ""
echo -e "${PURPLE}==================================================${NC}"
echo ""
