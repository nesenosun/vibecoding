#!/usr/bin/env python3
# ============================================================
# 🛰️  Artemis Ajan Daemonu (Stateful HTTP Sunucu)
# ------------------------------------------------------------
# Her ajanı (Ersinis / İşçi) arka planda sürekli dinleyen
# bir REST sunucusuna dönüştürür. Stateless "her istekte yeniden
# çalışan script" mantığının yerine, oturum boyunca ayakta kalan
# ve hafıza (state) tutan daemon yapısı gelir.
#
# Kullanım:
#   python3 agent_daemon.py --agent ersinis
#   python3 agent_daemon.py --agent isci
#
# Uç noktalar (her ajan için aynı şema):
#   GET  /health       -> {"status":"ok","agent":...,"uptime_sec":N}
#   GET  /state        -> mevcut hafıza özeti
#   POST /reset        -> hafızayı sıfırla (sistem promptu korunur)
#   POST /message      -> {"prompt":"..."} -> ajanı çalıştır, yanıt döndür
#
# Bu betik standart kütüphane dışında bağımlılık içermez.
# ============================================================

import argparse
import json
import logging
import logging.handlers
import os
import shutil
import subprocess
import sys
import threading
import time
import traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# --- Ajan konfigürasyonu (ANAYASA madde 3 ile uyumlu) ---
# Dış CLI çağrıları ANAYASA'da tanımlı komutları birebir mirror eder.
# {prompt} yer tutucusu, sistem promptu + kullanıcı talebinden oluşan
# tam prompt metniyle değiştirilir.
#
# Ajan Rehberi (.ersinis/ajanlar/ajan_rehberi.md) ile eşleşen CLI
# şablonları. --cli argümanı ile seçilen ajanın şablonu kullanılır,
# --model argümanı ile model belirlenir.
CLI_TEMPLATES = {
    "opencode": ["script", "-q", "/dev/null", "opencode", "run", "{prompt}", "-m", "{model}"],
    "claude": ["claude", "-p", "{prompt}"],
    "codex": ["codex", "exec", "{prompt}"],
    "agy": ["agy", "--model", "{model}", "--print-timeout", "300s", "-p", "{prompt}"],
    "gemini": ["gemini", "-p", "{prompt}"],
}

AGENT_CONFIG = {
    "ersinis": {
        "port": 8001,
        "system_prompt_file": "ajanlar/promptlar/ersinis_sistem_promptu.md",
        "default_cli": "opencode",
        "default_model": "opencode-go/deepseek-v4-flash",
        "timeout_sec": 600,
    },
    "isci": {
        "port": 8002,
        "system_prompt_file": "ajanlar/promptlar/isci_sistem_promptu.md",
        "default_cli": "agy",
        "default_model": "Gemini 3.7 Flash (Medium)",
        "timeout_sec": 1800,
    },
}


# ============================================================
# 🔒 State (Hafıza) yönetimi
# ============================================================
# Loglama tercihleri: tüm daemon çıktısı (başlangıç, istekler, hatalar)
# `.ersinis/loglar/agent_<agent>.log` dosyasına yazılır. /tmp KULLANILMAZ.
LOG_DIR_NAME = "loglar"
class AgentState:
    """Thread-safe, oturum boyunca yaşayan ajan hafızası."""

    HISTORY_CAP = 200  # bellek patlamasını önlemek için son N etkileşim

    def __init__(self, agent, system_prompt):
        self.agent = agent
        self.system_prompt = system_prompt
        self.start_time = time.time()
        self.history = []  # list[dict]: {t, ok, duration_ms, chars, error?, response?}
        self.lock = threading.Lock()
        self.busy = False

    def reset(self):
        with self.lock:
            self.history = []
            self.start_time = time.time()
            self.busy = False

    def set_busy(self, val):
        with self.lock:
            self.busy = val

    def append(self, entry):
        with self.lock:
            self.history.append(entry)
            if len(self.history) > self.HISTORY_CAP:
                self.history = self.history[-self.HISTORY_CAP:]

    def snapshot(self):
        with self.lock:
            last = self.history[-1] if self.history else None
            return {
                "agent": self.agent,
                "uptime_sec": int(time.time() - self.start_time),
                "system_prompt_chars": len(self.system_prompt),
                "messages": len(self.history),
                "busy": self.busy,
                "last_error": (last.get("error") if (last and not last.get("ok")) else None),
                "last_response_head": ((last or {}).get("response", "")[:500] if last else None),
            }


# ============================================================
# 🧠 Çalıştırıcı: sistem promptu + talep → CLI → yanıt
# ============================================================
def run_agent(agent, cli_template, system_prompt, user_prompt, timeout_sec):
    """Configdeki CLI şablonunu Çalıştır, stdout'u yakala.

    Returns: (ok: bool, response: str, error: str|None, duration_ms: int)
    """
    full_prompt = (
        f"{system_prompt}\n\n"
        f"---\n"
        f"👤 KULLANICI / ARTEMİS TALEBİ:\n{user_prompt}\n"
    )
    cmd = [arg.replace("{prompt}", full_prompt) for arg in cli_template]
    t0 = time.time()
    try:
        # CLI aracı proje kökünde çalışmalı; aksi halde dosya erişimi bozulur.
        proc = subprocess.run(
            cmd,
            cwd=os.getcwd(),
            capture_output=True,
            text=True,
            timeout=timeout_sec,
        )
        duration = int((time.time() - t0) * 1000)
        out = (proc.stdout or "").strip()
        err = (proc.stderr or "").strip()
        if proc.returncode != 0:
            tail = (err or out)[-2000:]
            return False, out, f"CLI exit={proc.returncode}: {tail}", duration
        if not out:
            return False, "", "CLI boş yanıt döndürdü", duration
        return True, out, None, duration
    except subprocess.TimeoutExpired as e:
        duration = int((time.time() - t0) * 1000)
        out = (e.stdout or "")
        if isinstance(out, bytes):
            out = out.decode("utf-8", "replace")
        return False, (out or "").strip(), f"zaman aşımı ({timeout_sec}s)", duration
    except FileNotFoundError as e:
        return False, "", f"CLI bulunamadı: {e}", 0
    except Exception as e:
        return False, "", f"istisna: {e}\n{traceback.format_exc()}", 0


# ============================================================
# 🌐 HTTP istek işleyici
# ============================================================
class AgentHandler(BaseHTTPRequestHandler):
    # Banner sessizleştirme: stdout'a basmaz, daemon log dosyasına yazar.
    def log_message(self, fmt, *args):
        logger = getattr(self.server, "agent_logger", None)
        if logger is not None:
            logger.info("%s - %s", self.address_string(), fmt % args)

    # --- yardımcılar ---
    def _send_json(self, code, obj):
        body = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self):
        length = int(self.headers.get("Content-Length", 0))
        if length == 0:
            return {}
        raw = self.rfile.read(length)
        try:
            return json.loads(raw.decode("utf-8"))
        except Exception:
            return None  # hata sinyali

    def _state(self):
        return self.server.agent_state

    # --- rotalar ---
    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path == "/health":
            st = self._state().snapshot()
            self._send_json(200, {"status": "ok", **st})
            return
        if path == "/state":
            self._send_json(200, self._state().snapshot())
            return
        self._send_json(404, {"error": "bilinmeyen uç nokta", "path": path})

    def do_POST(self):
        path = self.path.split("?", 1)[0]
        state = self._state()

        if path == "/reset":
            state.reset()
            self._send_json(200, {"status": "ok", "msg": "hafıza sıfırlandı",
                                  "agent": state.agent})
            return

        if path == "/message":
            if state.busy:
                self._send_json(409, {"error": "ajan meşgul", "agent": state.agent})
                return
            payload = self._read_json()
            if payload is None:
                self._send_json(400, {"error": "geçersiz JSON"})
                return
            prompt = (payload.get("prompt") or "").strip()
            if not prompt:
                self._send_json(400, {"error": "prompt boş"})
                return

            cfg = AGENT_CONFIG[state.agent]
            state.set_busy(True)
            try:
                ok, response, error, duration = run_agent(
                    state.agent, cfg["cli"], state.system_prompt,
                    prompt, cfg["timeout_sec"],
                )
                entry = {
                    "t": int(time.time() * 1000),
                    "ok": ok,
                    "duration_ms": duration,
                    "chars": len(response or ""),
                    "response": response,
                }
                if error:
                    entry["error"] = error
                state.append(entry)
                self._send_json(200 if ok else 500, {
                    "agent": state.agent,
                    "ok": ok,
                    "response": response,
                    "error": error,
                    "duration_ms": duration,
                })
            finally:
                state.set_busy(False)
            return

        self._send_json(404, {"error": "bilinmeyen uç nokta", "path": path})


# ============================================================
# 🚀 Bootstrap
# ============================================================
def resolve_ersinis_dir():
    # Betik .ersinis/ajanlar/betikler/ içindedir; .ersinis kökü iki seviye yukarıda.
    here = os.path.dirname(os.path.abspath(__file__))
    return os.path.dirname(os.path.dirname(here))


def resolve_log_dir(ersinis_dir):
    """Tüm test/daemon logları /tmp yerine .ersinis/loglar/ altında tutulur."""
    log_dir = os.path.join(ersinis_dir, "ajanlar", "loglar")
    os.makedirs(log_dir, exist_ok=True)
    return log_dir


def setup_logging(agent, log_dir):
    """Daemon stdout/stderr'ini .ersinis/loglar/ajanlar/agent_<agent>.log'a yönlendir.

    Hem konsola hem dosyaya yazar; test sırasında /tmp'ye yazma izin hatası
    alınmaması için log kökünü .ersinis altında sabitler.
    """
    log_path = os.path.join(log_dir, f"agent_{agent}.log")
    logger = logging.getLogger(f"agent_daemon.{agent}")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    fmt = logging.Formatter(
        "%(asctime)s %(levelname)s [%(name)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    fh = logging.handlers.RotatingFileHandler(
        log_path, maxBytes=5 * 1024 * 1024,
        backupCount=3, encoding="utf-8",
    )
    fh.setFormatter(fmt)
    logger.addHandler(fh)
    sh = logging.StreamHandler(sys.stdout)
    sh.setFormatter(fmt)
    logger.addHandler(sh)
    logger.info(f"log dosyası: .ersinis/ajanlar/loglar/agent_{agent}.log")
    return logger, log_path


def load_system_prompt(ersinis_dir, fname, logger=None):
    path = os.path.join(ersinis_dir, fname)
    if not os.path.isfile(path):
        msg = f"sistem promptu bulunamadı: .ersinis/{fname}"
        if logger:
            logger.error(msg)
        else:
            sys.stderr.write(f"[daemon] {msg}\n")
        sys.exit(2)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def reserve_pid_file(agent, port, logger=None):
    """Daemon PID bilgisini .ersinis/ajanlar/run/<agent>.pid dosyasına yazar.

    Bu dosyayı session_open.sh doğrudan kullanmaz (o kendi .agent_pids
    dosyasını tutar) ama debugging ve dış araçlar için yararlıdır.
    """
    ersinis_dir = resolve_ersinis_dir()
    pid_file = os.path.join(ersinis_dir, "ajanlar", "run", f"{agent}.pid")
    with open(pid_file, "w") as f:
        f.write(str(os.getpid()))
    if logger:
        logger.info(f"pid dosyası: .ersinis/ajanlar/run/{agent}.pid (pid={os.getpid()}, port={port})")
    return pid_file


def resolve_cli(cli_name, model):
    """Rehberdeki CLI şablonunu seç; {model} yer tutucusunu doldur."""
    template = CLI_TEMPLATES.get(cli_name)
    if template is None:
        raise ValueError(f"bilinmeyen CLI: {cli_name}")
    return [arg.replace("{model}", model) for arg in template]


def main():
    ap = argparse.ArgumentParser(description="Artemis ajan daemonu (stateful HTTP sunucu)")
    ap.add_argument("--agent", required=True, choices=list(AGENT_CONFIG.keys()),
                    help="çalıştırılacak ajan: ersinis | isci")
    ap.add_argument("--host", default="127.0.0.1", help="bağlanacağı arayüz")
    ap.add_argument("--cli", choices=list(CLI_TEMPLATES.keys()), default=None,
                    help="kullanılacak CLI ajanı (ajan_rehberi.md): opencode | claude | codex | agy | gemini")
    ap.add_argument("--model", default=None, help="kullanılacak model adı")
    args = ap.parse_args()

    cfg = AGENT_CONFIG[args.agent]
    cli_name = args.cli or cfg["default_cli"]
    model = args.model or cfg["default_model"]
    cfg["cli"] = resolve_cli(cli_name, model)
    cfg["cli_name"] = cli_name
    cfg["model"] = model

    ersinis_dir = resolve_ersinis_dir()
    log_dir = resolve_log_dir(ersinis_dir)
    logger, _ = setup_logging(args.agent, log_dir)
    system_prompt = load_system_prompt(ersinis_dir, cfg["system_prompt_file"], logger)

    state = AgentState(args.agent, system_prompt)
    reserve_pid_file(args.agent, cfg["port"], logger)

    httpd = ThreadingHTTPServer((args.host, cfg["port"]), AgentHandler)
    httpd.agent_state = state
    httpd.agent_logger = logger
    httpd.daemon_threads = True

    logger.info(f"{args.agent} dinleniyor: http://{args.host}:{cfg['port']} (cli={cli_name}, model={model})")

    # SIGTERM/SIGINT'te zarif kapanış. httpd.shutdown() aynı Thread
    # içinde (serve_forever) çağrılırsa deadlock yapar; bu yüzden ayrı
    # Thread'de tetiklenir.
    def _shutdown(signum, frame):
        logger.info(f"sinyal alındı ({signum}), kapatılıyor")
        threading.Thread(target=httpd.shutdown, daemon=True).start()
    import signal
    signal.signal(signal.SIGTERM, _shutdown)
    signal.signal(signal.SIGINT, _shutdown)

    try:
        httpd.serve_forever()
    finally:
        logger.info(f"{args.agent} kapatıldı.")


if __name__ == "__main__":
    main()