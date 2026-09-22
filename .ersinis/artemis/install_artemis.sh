#!/usr/bin/env bash
# ============================================================
# 🚀 Artemis Protokolü Kurulum ve Kopyalama Betiği (install_artemis.sh)
# Versiyon: 1.1
# Kullanım: bash .ersinis/artemis/install_artemis.sh /hedef/proje/yolu
# ============================================================

TARGET_DIR="$1"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Renkler
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

if [ -z "$TARGET_DIR" ]; then
  echo -e "${RED}❌ Hata: Lütfen hedef proje dizinini parametre olarak belirtin.${NC}"
  echo -e "Kullanım: bash .ersinis/artemis/install_artemis.sh /path/to/target/project"
  exit 1
fi

# Mutlak yola çevir
if [[ ! "$TARGET_DIR" =~ ^/ ]]; then
  TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)"
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo -e "${RED}❌ Hata: Belirtilen hedef dizin mevcut değil: $TARGET_DIR${NC}"
  exit 1
fi

echo -e "${CYAN}🚀 Artemis Protokolü Kurulumu Başlatılıyor...${NC}"
echo -e "   Kaynak: ${BOLD}$SOURCE_DIR${NC}"
echo -e "   Hedef:  ${BOLD}$TARGET_DIR${NC}"
echo ""

# Hedefte .ersinis dizini oluştur
mkdir -p "$TARGET_DIR/.ersinis/artemis"

# Kopyalanacak dosyalar (SOURCE_DIR zaten .ersinis kökünü gösterir)
FILES=(
  "ANAYASA.md"
  "oturum/session_open.sh"
  "oturum/session_close.sh"
  "oturum/artemis_say.js"
  "oturum/artemis_say_silent.js"
  "hafiza/weekly_summary.sh"
)

# Klasör bazlı kopyalama (artemis altındaki hafıza ve mimari dosyaları)
echo -e "   📂 Klasör Kopyalanıyor: artemis"
cp -R "$SOURCE_DIR/artemis/"* "$TARGET_DIR/.ersinis/artemis/" 2>/dev/null || true

# Global klasörleri yeni projeye kopyaladıysa temizle
rm -rf "$TARGET_DIR/.ersinis/artemis/modeller"

# Artemis_memory.md'yi temiz şablonla sıfırla (eski proje hafızası bulaşmasın)
cat > "$TARGET_DIR/.ersinis/artemis/Artemis_memory.md" << 'MEMEOF'
# 🧠 Artemis Dahili Asistan Hafızası (Artemis_memory.md)

Bu dosya, Artemis ve kullanıcı arasındaki iş birliğinin kalıcı dahili belleğidir.

## 🆔 Kimlik ve Asistan Rolü
- **İsim:** Artemis
- **Karakter:** Yardımsever, teknik odaklı, sesli asistan yeteneklerine sahip senior peer-programmer.

## ⚙️ Dahili Sistem Ayarları
- **Loglama:** Yerel NDJSON (`.ersinis/hafiza/activity.ndjson`).
- **Seslendirme:** macOS `say` komutu (`artemis_say.js` üzerinden).

## 📌 Hatırlanması Gerekenler
- Kullanıcıya her zaman doğal dilde sesli özet verilir.
- Yanıtlar seslendirilmeden önce `.ersinis/hafiza/activity.ndjson` güncellenir.

## 🕐 Son Oturum Kaydı
- Son Oturum Kapanışı: İlk oturum
- Oturumda Değiştirilen Dosya Sayısı: 0
MEMEOF
echo -e "   ✅ Artemis_memory.md temiz şablonla sıfırlandı"

# planlar/ klasörünü .ersinis içine kopyala
mkdir -p "$TARGET_DIR/.ersinis/planlar"
echo -e "   📂 Klasör Kopyalanıyor: .ersinis/planlar"
cp -R "$SOURCE_DIR/planlar/"* "$TARGET_DIR/.ersinis/planlar/" 2>/dev/null || true
echo -e "   ✅ .ersinis/planlar/ kopyalandı"

# semalar/ klasörünü .ersinis içine kopyala
mkdir -p "$TARGET_DIR/.ersinis/semalar"
echo -e "   📂 Klasör Kopyalanıyor: .ersinis/semalar"
cp -R "$SOURCE_DIR/semalar/"* "$TARGET_DIR/.ersinis/semalar/" 2>/dev/null || true
echo -e "   ✅ .ersinis/semalar/ kopyalandı"

# Dosyaları kopyala ve içindeki kaynak yolları hedef yollarla değiştir
for file in "${FILES[@]}"; do
  # Hedef dosya yolu
  if [ "$file" == "ANAYASA.md" ]; then
    dest_file="$TARGET_DIR/.ersinis/ANAYASA.md"
  else
    dest_file="$TARGET_DIR/.ersinis/$file"
  fi

  mkdir -p "$(dirname "$dest_file")"

  echo -e "   📄 Kopyalanıyor: $file"
  cp "$SOURCE_DIR/$file" "$dest_file" 2>/dev/null || { echo -e "${RED}   ⚠️  Kaynak bulunamadı: $SOURCE_DIR/$file${NC}"; continue; }

  # Sabit yolları hedef dizine göre güncelle (macOS sed uyumlu)
  sed -i '' "s|$SOURCE_DIR|$TARGET_DIR|g" "$dest_file" 2>/dev/null || \
  sed -i "s|$SOURCE_DIR|$TARGET_DIR|g" "$dest_file" # Linux Fallback
done

# project_memory.md şablonunu oluştur (eğer hedefte yoksa)
MEMORY_DEST="$TARGET_DIR/.ersinis/hafiza/project_memory.md"
if [ ! -f "$MEMORY_DEST" ]; then
  echo -e "   💾 Yeni project_memory.md şablonu oluşturuluyor..."
  cp "$SOURCE_DIR/hafiza/project_memory.md" "$MEMORY_DEST" 2>/dev/null || true
  # Sabit yolları güncelle
  sed -i '' "s|$SOURCE_DIR|$TARGET_DIR|g" "$MEMORY_DEST" 2>/dev/null || \
  sed -i "s|$SOURCE_DIR|$TARGET_DIR|g" "$MEMORY_DEST"
fi

# activity.ndjson oluştur (eğer hedefte yoksa boş olarak)
ACTIVITY_DEST="$TARGET_DIR/.ersinis/hafiza/activity.ndjson"
if [ ! -f "$ACTIVITY_DEST" ]; then
  echo -e "   📝 Yeni activity.ndjson oluşturuluyor..."
  touch "$ACTIVITY_DEST"
fi

# Çalıştırma yetkilerini ver
chmod +x "$TARGET_DIR/.ersinis/"*.sh "$TARGET_DIR/.ersinis/oturum/"*.sh "$TARGET_DIR/.ersinis/hafiza/"*.sh 2>/dev/null || true

# Artemis Browser bağımlılıklarını kur (npm install)
if [ -d "$TARGET_DIR/.ersinis/artemis/artemis_browser" ]; then
  echo -e "${YELLOW}📦 Artemis Browser bağımlılıkları kuruluyor (npm install)...${NC}"
  (cd "$TARGET_DIR/.ersinis/artemis/artemis_browser" && npm install --no-audit --no-fund --quiet) || {
    echo -e "${RED}⚠️  Uyarı: npm install başarısız oldu. Lütfen manuel olarak '$TARGET_DIR/.ersinis/artemis/artemis_browser' dizininde 'npm install' çalıştırın.${NC}"
  }
fi

echo ""
echo -e "${GREEN}✅ Artemis Protokolü başarıyla kuruldu!${NC}"
echo -e "Şimdi hedef projeye gidip şu adımları yapabilirsin:"
echo -e "   1. ${CYAN}cd $TARGET_DIR${NC}"
echo -e "   2. ${CYAN}bash .ersinis/oturum/session_open.sh${NC} (Oturumu başlatmak için)"
echo ""
