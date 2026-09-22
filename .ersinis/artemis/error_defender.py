import json
import os
import time

ACTIVITY_LOG = ".ersinis/hafiza/activity.ndjson"
ERROR_REPORT = ".ersinis/artemis/active_errors.json"

# Takip edilecek hata anahtar kelimeleri
ERROR_KEYWORDS = ["ERROR", "EXCEPTION", "FAIL", "FAILED", "CRASH", "Exception"]

def scan_logs():
    if not os.path.exists(ACTIVITY_LOG):
        print(f"⚠️ {ACTIVITY_LOG} bulunamadı.")
        return

    found_errors = []
    print("🔍 Loglar taranıyor...")

    with open(ACTIVITY_LOG, "r", encoding="utf-8") as f:
        for line in f:
            try:
                log = json.loads(line)
                # Log içeriğinde hata kelimelerini ara
                log_str = str(log).upper()
                if any(kw in log_str for kw in ERROR_KEYWORDS):
                    found_errors.append(log)
            except:
                continue

    # Son hataları kaydet (Sadece son 10 hata)
    recent_errors = found_errors[-10:]
    
    with open(ERROR_REPORT, "w", encoding="utf-8") as f:
        json.dump(recent_errors, f, ensure_ascii=False, indent=4)
    
    if recent_errors:
        print(f"🚨 {len(recent_errors)} adet kritik hata tespit edildi! Detaylar: {ERROR_REPORT}")
    else:
        print("✅ Sistem temiz, kritik hata bulunamadı.")

if __name__ == "__main__":
    scan_logs()
