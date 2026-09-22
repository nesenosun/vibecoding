const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const scriptDir = __dirname;
const activityFile = path.join(scriptDir, '..', 'hafiza', 'activity.ndjson');
const lockPath = path.join(scriptDir, 'artemis_is_speaking.lock');

const msg = process.argv[2];
const outFile = process.argv[3] || '';

const STALE_MS = 120000;
const SAY_TIMEOUT_MS = 120000;
const MAX_WAIT_MS = 300000;

if (!msg) {
  console.log('Kullanım: node .ersinis/oturum/artemis_say.js "Mesaj"');
  process.exit(1);
}

fs.mkdirSync(scriptDir, { recursive: true });

function logActivity(status, text) {
  const payload = {
    t: Date.now(),
    n: 'Artemis',
    ty: 'chat',
    ta: 'Sohbet',
    s: text,
    st: status,
    '+': 0,
    '-': 0,
    i: 'minor'
  };
  try {
    fs.appendFileSync(activityFile, JSON.stringify(payload) + '\n');
  } catch (e) {}
}

logActivity('success', msg);

if (fs.existsSync(path.join(scriptDir, '.artemis_sessiz'))) {
  process.exit(0);
}

let child = null;

function release() {
  try {
    fs.unlinkSync(lockPath);
  } catch (e) {}
}

function pidAlive(pid) {
  if (!pid) return false;
  try {
    process.kill(pid, 0);
    return true;
  } catch (e) {
    return e.code === 'EPERM';
  }
}

function isStale() {
  try {
    const stat = fs.statSync(lockPath);
    if (Date.now() - stat.mtimeMs > STALE_MS) return true;
    let pid = null;
    try {
      const data = JSON.parse(fs.readFileSync(lockPath, 'utf8'));
      if (data && data.pid) pid = data.pid;
    } catch (e) {}
    if (pid && !pidAlive(pid)) return true;
    return false;
  } catch (e) {
    return true;
  }
}

function acquire(callback) {
  const start = Date.now();
  const tryAcquire = () => {
    try {
      const fd = fs.openSync(lockPath, 'wx');
      fs.writeSync(fd, JSON.stringify({ pid: process.pid, ts: Date.now() }));
      fs.closeSync(fd);
      return callback();
    } catch (e) {
      if (e.code !== 'EEXIST') return callback();
      if (isStale()) {
        release();
        return tryAcquire();
      }
      if (Date.now() - start > MAX_WAIT_MS) {
        logActivity('error', 'Ses kuyruğu zaman aşımına uğradı, konuşma atlandı.');
        process.exit(1);
      }
      setTimeout(tryAcquire, 500);
    }
  };
  tryAcquire();
}

function updateLock(pid) {
  try {
    fs.writeFileSync(lockPath, JSON.stringify({ pid: pid, ts: Date.now() }));
  } catch (e) {}
}

function onInterrupt() {
  if (child) {
    try {
      child.kill('SIGKILL');
    } catch (e) {}
  }
  release();
  process.exit(130);
}

process.on('SIGINT', onInterrupt);
process.on('SIGTERM', onInterrupt);

acquire(() => {
  updateLock(process.pid);

  const args = outFile ? ['-o', outFile, msg] : [msg];
  child = spawn('say', args, { stdio: 'ignore' });
  child.on('spawn', () => {
    updateLock(child.pid);
  });

  let timedOut = false;
  const timer = setTimeout(() => {
    timedOut = true;
    try {
      child.kill('SIGKILL');
    } catch (e) {}
  }, SAY_TIMEOUT_MS);

  child.on('error', (err) => {
    clearTimeout(timer);
    release();
    logActivity('error', 'Seslendirme başlatılamadı: ' + err.message);
    process.exit(1);
  });

  child.on('exit', (code, signal) => {
    clearTimeout(timer);
    release();
    if (timedOut) {
      logActivity('error', 'Seslendirme 120 saniye sınırını aştı, süreç durduruldu.');
      process.exit(1);
    }
    if (code !== 0 && code !== null) {
      logActivity('error', 'say komutu beklenmeyen şekilde sonlandı (kod: ' + code + ', sinyal: ' + signal + ').');
    }
    if (outFile) {
      console.log('[Artemis] Ses dosyası kaydedildi: ' + outFile);
    }
    process.exit(0);
  });
});