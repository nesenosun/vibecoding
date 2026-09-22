#!/usr/bin/env python3
import os
import sys
import json
import sqlite3
import math
import re
from datetime import datetime

# Dinamik Yol Yönetimi
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)

if os.path.basename(current_dir) == "artemis" and os.path.basename(parent_dir) == ".ersinis":
    DB_FILE = os.path.join(parent_dir, "hafiza", "vector_memory.db")
    ACTIVITY_FILE = os.path.join(parent_dir, "hafiza", "activity.ndjson")
else:
    project_root = current_dir
    while project_root and project_root != os.path.dirname(project_root):
        if os.path.exists(os.path.join(project_root, ".ersinis")):
            break
        project_root = os.path.dirname(project_root)
    DB_FILE = os.path.join(project_root, ".ersinis", "hafiza", "vector_memory.db")
    ACTIVITY_FILE = os.path.join(project_root, ".ersinis", "hafiza", "activity.ndjson")

# Türkçe stop words (arama kalitesini artırmak için filtrelenecek kelimeler)
STOP_WORDS = {
    've', 'veya', 'ile', 'da', 'de', 'ki', 'bir', 'bu', 'şu', 'o', 'için', 'gibi',
    'en', 'daha', 'kadar', 'ise', 'olan', 'olarak', 'tarafından', 'son', 'ilk',
    'yeni', 'eski', 'icin', 'olan', 'olarak', 'tarafindan', 'ile', 'mi', 'mu', 'mı'
}

def clean_text(text):
    """Metni temizler, küçük harfe çevirir, Türkçe karakterleri normalize eder."""
    if not text:
        return ""
    text = text.lower()
    # Türkçe karakterlerin küçük harf karşılıkları
    replacements = {
        'ı': 'i', 'ğ': 'g', 'ü': 'u', 'ş': 's', 'ö': 'o', 'ç': 'c',
        'I': 'i', 'İ': 'i', 'Ğ': 'g', 'Ü': 'u', 'Ş': 's', 'Ö': 'o', 'Ç': 'c'
    }
    for char, replacement in replacements.items():
        text = text.replace(char, replacement)
    
    # Sadece harf, rakam ve boşlukları tut, noktalama işaretlerini kaldır
    text = re.sub(r'[^\w\s]', ' ', text)
    # Birden fazla boşluğu teke indir
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def get_word_freq(text):
    """Metindeki kelimelerin frekans (bag of words) sözlüğünü oluşturur."""
    cleaned = clean_text(text)
    # Stop words kelimeleri ve 2 harften kısa kelimeleri filtrele
    words = [w for w in cleaned.split() if w not in STOP_WORDS and len(w) > 1]
    
    freq = {}
    for w in words:
        freq[w] = freq.get(w, 0) + 1
    return freq

def get_embedding(text):
    """
    Orijinal get_embedding arayüzü ile uyumlu olması için korunmuştur.
    Ollama yerine yerel kelime frekans sözlüğünü (dict) döner.
    """
    return get_word_freq(text)

def init_db():
    """SQLite veritabanını ilklendirir."""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS memory_index (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            agent TEXT,
            type TEXT,
            target TEXT,
            summary TEXT,
            content TEXT UNIQUE,
            embedding TEXT
        )
    """)
    conn.commit()
    conn.close()

def cosine_similarity(v1, v2):
    """
    İki kelime frekans sözlüğü arasındaki Cosine Similarity değerini hesaplar.
    v1 ve v2 birer sözlüktür (örn: {"artemis": 2, "oturum": 1})
    """
    if not v1 or not v2:
        return 0.0
    
    # Kesişen kelimeleri bul
    intersection = set(v1.keys()) & set(v2.keys())
    
    # Dot product
    dot_product = sum(v1[word] * v2[word] for word in intersection)
    
    # Norm A ve Norm B
    norm_a = math.sqrt(sum(val ** 2 for val in v1.values()))
    norm_b = math.sqrt(sum(val ** 2 for val in v2.values()))
    
    if norm_a == 0.0 or norm_b == 0.0:
        return 0.0
        
    return dot_product / (norm_a * norm_b)

def index_activity():
    """activity.ndjson dosyasındaki yeni logları veritabanına indeksler."""
    if not os.path.exists(ACTIVITY_FILE):
        print(f"Hata: {ACTIVITY_FILE} bulunamadi.")
        return

    init_db()
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()

    # Zaten indekslenmiş olan içerikleri çek (mükerrer olmasın diye)
    cursor.execute("SELECT content FROM memory_index")
    indexed_contents = {row[0] for row in cursor.fetchall()}

    new_records = []
    with open(ACTIVITY_FILE, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            if not line.strip():
                continue
            try:
                log = json.loads(line)
                
                # Sadece anlamlı logları al (chat mesajları ve major/moderate olaylar)
                log_type = log.get("ty", "other")
                summary = log.get("s", "")
                impact = log.get("i", "minor")
                
                if not summary:
                    continue
                
                if log_type != "chat" and impact not in {"major", "moderate"}:
                    continue
                
                # İndekslenecek formatlanmış metni önce oluştur
                timestamp_str = ""
                if log.get("t"):
                    timestamp_str = datetime.fromtimestamp(log["t"] / 1000).strftime("%Y-%m-%d %H:%M")
                
                agent = log.get("n", "Sistem")
                target = log.get("ta", "")
                
                content_to_embed = f"[{timestamp_str}] {agent} | {log_type.upper()} | Target: {target} | Olay: {summary}"
                
                # Mükerrer kontrolü
                if content_to_embed in indexed_contents:
                    continue
                
                new_records.append({
                    "timestamp": timestamp_str,
                    "agent": agent,
                    "type": log_type,
                    "target": target,
                    "summary": summary,
                    "content": content_to_embed
                })
            except Exception:
                continue

    if not new_records:
        print("Indekslenecek yeni log kaydi bulunamadi.")
        conn.close()
        return

    print(f"{len(new_records)} yeni log kaydi tespit edildi. Kelime frekans analizleri cikariliyor...")
    
    indexed_count = 0
    for rec in new_records:
        emb = get_embedding(rec["content"])
        if emb:
            try:
                cursor.execute("""
                    INSERT OR IGNORE INTO memory_index (timestamp, agent, type, target, summary, content, embedding)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                """, (rec["timestamp"], rec["agent"], rec["type"], rec["target"], rec["summary"], rec["content"], json.dumps(emb)))
                indexed_count += 1
            except Exception as e:
                print(f"Veritabani yazma hatasi: {e}", file=sys.stderr)
                
    conn.commit()
    conn.close()
    print(f"Basariyla {indexed_count} yeni log kaydi yerel hafizaya indekslendi.")

def search_memory(query, limit=5):
    """Verilen sorguya en yakın hafıza kayıtlarını getirir."""
    if not os.path.exists(DB_FILE):
        print("Hata: Hafiza veritabani henüz olusturulmamis. Önce indeksleme yapmalisiniz.")
        return

    query_emb = get_embedding(query)
    if not query_emb:
        print("Hata: Sorgu metni bos veya analiz edilemedi.")
        return

    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT timestamp, agent, type, target, summary, content, embedding FROM memory_index")
    rows = cursor.fetchall()
    conn.close()

    results = []
    for row in rows:
        timestamp, agent, log_type, target, summary, content, emb_json = row["timestamp"], row["agent"], row["type"], row["target"], row["summary"], row["content"], row["embedding"]
        try:
            emb = json.loads(emb_json)
            # Cosine similarity hesapla
            sim = cosine_similarity(query_emb, emb)
            results.append({
                "timestamp": timestamp,
                "agent": agent,
                "type": log_type,
                "target": target,
                "summary": summary,
                "content": content,
                "similarity": sim
            })
        except Exception:
            continue

    # Benzerlik oranına göre sırala (Benzerlik > 0.05 olanları)
    results = sorted(results, key=lambda x: x["similarity"], reverse=True)
    filtered_results = [r for r in results if r["similarity"] > 0.05][:limit]

    if not filtered_results:
        print("\n[Yerel Arama Sonucu] Hicbir eslesme bulunamadi.")
        return

    print(f"\n🔍 '{query}' sorgusu icin yerel hafizadan en yakin {len(filtered_results)} sonuc:")
    print("=" * 70)
    for i, res in enumerate(filtered_results, 1):
        print(f"{i}. [{res['timestamp']}] {res['agent']} ({res['type'].upper()}) - Benzerlik: %{res['similarity']*100:.1f}")
        print(f"   Hedef : {res['target']}")
        print(f"   Olay  : {res['summary']}")
        print("-" * 70)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Kullanim:")
        print("  Indekslemek icin: python3 vector_memory.py --index")
        print("  Aramak icin:      python3 vector_memory.py --query \"arama sorgusu\" [--limit N]")
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "--index":
        index_activity()
    elif cmd == "--query" and len(sys.argv) > 2:
        query_text = sys.argv[2]
        limit_val = 5
        if "--limit" in sys.argv:
            try:
                idx = sys.argv.index("--limit")
                limit_val = int(sys.argv[idx + 1])
            except Exception:
                pass
        search_memory(query_text, limit_val)
    else:
        print("Gecersiz parametreler.")
        sys.exit(1)
