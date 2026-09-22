#!/usr/bin/env bash
# ============================================================
# ⏰ Artemis Uyanma Sayacı Yönetimi (Mac)
# Kullanım: 
#   bash .ersinis/uyanma/counter.sh start 1m
#   bash .ersinis/uyanma/counter.sh stop
#   bash .ersinis/uyanma/counter.sh pause
#   bash .ersinis/uyanma/counter.sh resume
# ============================================================

if [ $# -eq 0 ]; then
  echo "Hata: Argüman belirtin (start [süre], stop, pause, resume)"
  exit 1
fi

COMMAND=$1

# Ses komutlarının logu ezmesini engellemek için ses oynatımının bitmesini bekle
LOCK_FILE="/tmp/artemis_say.lock"
while [ -f "$LOCK_FILE" ]; do
  sleep 0.5
done
sleep 1

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$COMMAND" in
  start)
    if [ -z "$2" ]; then
      echo "Hata: Başlatma komutu için süre belirtin (örn: 1m, 30s)"
      exit 1
    fi
    SURE=$2
    bash "$DIR/../oturum/artemis_say_silent.sh" "uyanma aç: $SURE"
    echo "[Sayac] $SURE için uyanma sinyali gönderildi."
    ;;
  stop)
    bash "$DIR/../oturum/artemis_say_silent.sh" "uyanmayı kapat"
    echo "[Sayac] Uyanma sayacını kapatma sinyali gönderildi."
    ;;
  pause)
    bash "$DIR/../oturum/artemis_say_silent.sh" "uyanmayı duraklat"
    echo "[Sayac] Uyanma sayacını duraklatma sinyali gönderildi."
    ;;
  resume)
    bash "$DIR/../oturum/artemis_say_silent.sh" "uyanmayı devam ettir"
    echo "[Sayac] Uyanma sayacını kaldığı yerden devam ettirme sinyali gönderildi."
    ;;
  *)
    echo "Hata: Geçersiz komut ($COMMAND). (start, stop, pause, resume kullanın)"
    exit 1
    ;;
esac
