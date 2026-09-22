#!/usr/bin/env bash
# ============================================================
# 🌅 Artemis Oturum Açılış Protokolü (Session Open Protocol)
# Versiyon: 2.0 (Temizlenmiş Yapı)
# Çalıştır: bash .ersinis/oturum/session_open.sh
# ============================================================

set -euo pipefail

# ============================================================
# 1. KURULUM VE DOĞRULAMA
# ============================================================
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
  exit 1
fi

ACTIVITY_FILE="$PROJ_ERSINIS/hafiza/activity.ndjson"

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
RESET='\033[0m'

[ -t 1 ] && clear || true
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}║                         ARTEMİS                          ║${RESET}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ============================================================
# 2. TERMİNAL KARŞILAMA VE BAĞLAM ÖZETİ
# ============================================================
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${BOLD}📅 Oturum Başlangıcı:${RESET}  $TIMESTAMP"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# --- Haftalık Özet Oku ---
GUNLUK_LOG=""
if [ -f "$PROJ_ERSINIS/hafiza/aktivite_ozetleri/haftalik_ozet.ndjson" ]; then
  GUNLUK_LOG=$(python3 -c "
import json, os
fpath = '$PROJ_ERSINIS/hafiza/aktivite_ozetleri/haftalik_ozet.ndjson'
if os.path.exists(fpath):
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            lines = [line.strip() for line in f if line.strip()]
        if lines:
            data = json.loads(lines[-1])
            date = data.get('date', '')
            summary = data.get('summary', [])
            print(f'  [{date}]')
            print('\n'.join(f'  - {s}' for s in summary))
    except:
        pass
" 2>/dev/null || true)
fi

echo -e "  ${BOLD}${GREEN}📅 Son Haftalık Özet${RESET}"
if [ -n "$GUNLUK_LOG" ]; then
  echo -e "$GUNLUK_LOG"
else
  echo -e "  Haftalık özet bulunamadı."
fi
echo ""

# --- Aylık Özet Oku ---
AYLIK_LOG=""
if [ -f "$PROJ_ERSINIS/hafiza/aktivite_ozetleri/aylik_ozet.ndjson" ]; then
  AYLIK_LOG=$(python3 -c "
import json, os
fpath = '$PROJ_ERSINIS/hafiza/aktivite_ozetleri/aylik_ozet.ndjson'
if os.path.exists(fpath):
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            lines = [line.strip() for line in f if line.strip()]
        if lines:
            data = json.loads(lines[-1])
            date = data.get('date', '')
            summary = data.get('summary', [])
            print(f'  [{date}]')
            print('\n'.join(f'  - {s}' for s in summary))
    except:
        pass
" 2>/dev/null || true)
fi

echo -e "  ${BOLD}${GREEN}📅 Son Aylık Özet${RESET}"
if [ -n "$AYLIK_LOG" ]; then
  echo -e "$AYLIK_LOG"
else
  echo -e "  Aylık özet bulunamadı."
fi
echo ""

# --- Son 10 Saatlik Gelişim Oku ---
SAATLIK_LOG=""
if [ -f "$PROJ_ERSINIS/hafiza/aktivite_ozetleri/saatlik_ozet.ndjson" ]; then
  SAATLIK_LOG=$(python3 -c "
import json, os
fpath = '$PROJ_ERSINIS/hafiza/aktivite_ozetleri/saatlik_ozet.ndjson'
if os.path.exists(fpath):
    try:
        with open(fpath, 'r', encoding='utf-8') as f:
            lines = [line.strip() for line in f if line.strip()]
        valid_lines = []
        for line in reversed(lines):
            if not line: continue
            data = json.loads(line)
            if data.get('type') == 'constitution_rule': continue
            valid_lines.append(data)
            if len(valid_lines) >= 10: break
        
        valid_lines.reverse()
        out = []
        for data in valid_lines:
            time_range = data.get('time_range', '')
            date = data.get('date', '')
            summary = data.get('summary', [])
            out.append(f'  [{date} {time_range}]')
            out.extend([f'    - {s}' for s in summary])
        print('\n'.join(out))
    except:
        pass
" 2>/dev/null || true)
fi

echo -e "  ${BOLD}${GREEN}⏱️  Son 10 Saatlik Gelişim${RESET}"
if [ -n "$SAATLIK_LOG" ]; then
  echo -e "$SAATLIK_LOG"
else
  echo -e "  Saatlik gelişim özetleri bulunamadı."
fi
echo ""

# ============================================================
# 3. LOG ROTASYONU (Max 50 MB)
# ============================================================
MAX_SIZE=52428800 # 50 MB
if [ -f "$ACTIVITY_FILE" ]; then
  FILE_SIZE=$(wc -c < "$ACTIVITY_FILE" | tr -d ' ')
  if [ "$FILE_SIZE" -ge "$MAX_SIZE" ]; then
    mkdir -p "$PROJ_ERSINIS/arsiv"
    BACKUP_TIME=$(date +%s)
    cp "$ACTIVITY_FILE" "$PROJ_ERSINIS/arsiv/activity_backup_monthly_$BACKUP_TIME.json"
    
    RULE_VAL="Artemis yapay zekasının düşünerek yazılmayan hiçbir kayıt geçerli değildir. Bu sayfaya üzerine düşünülmeden, Artemis'in üzerine mantık yürütmeden hiçbir şey yazılmayacak."
    echo "{\"type\": \"constitution_rule\", \"rule\": \"${RULE_VAL}\"}" > "$ACTIVITY_FILE"
    
    ROTATION_MSG="Boyut tabanlı otonom log rotasyonu gerçekleştirildi (50 MB sınır aşımı). Eski loglar yedeklendi ve dosya sıfırlandı."
    echo "{\"t\":$(date +%s000),\"n\":\"Artemis\",\"ty\":\"other\",\"ta\":\"Sistem\",\"s\":\"${ROTATION_MSG}\",\"st\":\"success\",\"+\":0,\"-\":0,\"i\":\"major\"}" >> "$ACTIVITY_FILE"
  fi
fi

# ============================================================
# 4. SİSTEM VE ORKESTRASYON DURUMU
# ============================================================
# ANAYASA madde 3 gereği: Artemis (Ana Arayüz) doğrudan uyanır ve
# tüm komutlara hazırdır. İhtiyaç halinde kullanıcıdan onay alarak
# Ersinis ve İşçi (Orkestrasyon) ajanlarını başlatır.

TERCIH_FILE="$PROJ_ERSINIS/hafiza/ajan_tercihi.json"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${BOLD}${GREEN}🚀 Artemis (Ana Arayüz) aktif ve komuta hazır.${RESET}"
echo -e "  ${YELLOW}📌 İsteğe bağlı orkestrasyon (Ersinis ve İşçi) bekletiliyor.${RESET}"
if [ -f "$TERCIH_FILE" ]; then
  echo -e "  ${GREEN}✅ Önceki ajan kayıtları hazır. İstendiği an uyandırılabilir.${RESET}"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ============================================================
# 5. OTURUM KESİNLEŞTİRME VE KAPANIŞ
# ============================================================
LOG_MSG="Artemis oturumu açıldı. Orkestrasyon tercihi kontrol edildi."
echo "{\"t\":$(date +%s000),\"n\":\"Artemis\",\"ty\":\"chat\",\"ta\":\"Sistem\",\"s\":\"${LOG_MSG}\",\"st\":\"success\",\"+\":0,\"-\":0,\"i\":\"minor\"}" >> "$ACTIVITY_FILE"

touch "$GLOBAL_ERSINIS/oturum/artemis_active"

echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${YELLOW}║            ⚠️  ARTEMİS AKTİF                             ║${RESET}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${RESET}"
echo -e "  ${BOLD}1.${RESET} Sesli Öncelikli Etkileşim: Asıl yanıtları sesli ver."
echo -e "  ${BOLD}2.${RESET} Kod ve uzun teknik verileri sesli okuma, sessizce dosyalara yaz."
echo -e "  ${BOLD}3.${RESET} Eyleme geçmeden önce yapılacakları kısa bir sesli özetle bildir."
echo -e "  ${BOLD}4.${RESET} Uzun görevlerde her ${BOLD}2 dakikada bir${RESET} sesli özet ver."
echo -e "  ${BOLD}5.${RESET} ${RED}say${RESET} komutunu doğrudan ASLA kullanma. Yalnızca .ersinis/oturum/artemis_say.js kullan."
echo -e "  ${BOLD}6.${RESET} Tüm iletişim ${BOLD}kullanıcının tercih ettiği dilde${RESET} olacak."
echo -e "  ${BOLD}7.${RESET} Senin kimliğin ve Sistem Promptun ${BOLD}.ersinis/ANAYASA.md${RESET} dosyasıdır. Hemen OKU ve KESİN itaat et."
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${BOLD}${GREEN}✅ BU KURALLARI OKUDUM VE UYGULUYORUM.${RESET}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

echo "{\"t\":$(date +%s000),\"n\":\"Artemis\",\"ty\":\"chat\",\"ta\":\"Sistem\",\"s\":\"Artemis aktif: Sesli öncelikli ve kullanıcı dili kuralları aktif.\",\"st\":\"success\",\"+\":0,\"-\":0,\"i\":\"minor\"}" >> "$ACTIVITY_FILE"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${PURPLE}🤖 Artemis tam yetkiyle devrede.${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
