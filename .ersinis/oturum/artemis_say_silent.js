const fs = require('fs');
const path = require('path');

const scriptDir = __dirname;
const activityFile = path.join(scriptDir, '..', 'hafiza', 'activity.ndjson');

const msg = process.argv.slice(2).join(' ');
if (!msg) {
  console.log('Kullanım: node .ersinis/oturum/artemis_say_silent.js "Mesajın burada"');
  process.exit(1);
}

const payload = {
  t: Date.now(),
  n: 'Artemis',
  ty: 'chat',
  ta: 'Sohbet',
  s: msg,
  st: 'success',
  '+': 0,
  '-': 0,
  i: 'minor'
};

try {
  fs.appendFileSync(activityFile, JSON.stringify(payload) + '\n');
  console.log('[Sessiz Mod] Log kaydı başarıyla eklendi.');
} catch (e) {
  console.error("Log yazılamadı:", e);
}
