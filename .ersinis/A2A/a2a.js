#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const http = require('http');

function getWebhookPort() {
  const portFile = path.join(process.cwd(), '.ersinis', 'temp', 'active_webhook_port');
  if (fs.existsSync(portFile)) {
    try {
      const data = JSON.parse(fs.readFileSync(portFile, 'utf8'));
      if (data && data.port) {
        if (data.pid) {
          try {
            process.kill(data.pid, 0);
            return data.port;
          } catch (_) {
            try { fs.unlinkSync(portFile); } catch (e) {}
          }
        } else {
          return data.port;
        }
      }
    } catch (_) {}
  }
  return 3000;
}

const port = getWebhookPort();
const [,, cmd, ...args] = process.argv;

if (!cmd) {
  console.log(`Kullanım: node a2a.js <komut> [parametreler] (Aktif Port: ${port})`);
  console.log(`Komutlar:
  status                   - Bağlantı durumunu göster
  devices                  - Eşleşmiş cihazları listele
  connect [deviceId]       - Cihaza otonom WebRTC bağlantısı aç
  disconnect               - Bağlantıyı sonlandır
  start-remote-cli         - Karşı bilgisayardaki Artemis CLI'ı başlat
  send <mesaj>             - Karşıya anlık mesaj gönder
  send-file <dosyaYolu>    - Karşıya dosya gönder
  port                     - Aktif webhook portunu yazdır`);
  process.exit(0);
}

function request(method, reqPath, body, callback) {
  const req = http.request({
    hostname: '127.0.0.1',
    port: port,
    path: reqPath,
    method: method,
    headers: {
      'Content-Type': 'text/plain',
      ...(body ? { 'Content-Length': Buffer.byteLength(body) } : {})
    }
  }, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => callback(res.statusCode, data));
  });

  req.on('error', (e) => {
    console.error(`[A2A Hata] Webhook'a ulaşılamadı (Port: ${port}): ${e.message}`);
    process.exit(1);
  });

  if (body) req.write(body);
  req.end();
}

switch (cmd) {
  case 'port':
    console.log(port);
    break;
  case 'status':
    request('GET', '/status', null, (code, data) => console.log(data));
    break;
  case 'devices':
    request('GET', '/devices', null, (code, data) => console.log(data));
    break;
  case 'connect':
    const deviceId = args[0] || '';
    request('POST', '/connect', deviceId, (code, data) => console.log(data));
    break;
  case 'disconnect':
    request('POST', '/disconnect', null, (code, data) => console.log(data));
    break;
  case 'start-remote-cli':
    request('POST', '/start_remote_cli', null, (code, data) => console.log(data));
    break;
  case 'send':
    const msg = args.join(' ');
    if (!msg) {
      console.error('Hata: Gönderilecek mesaj belirtilmedi.');
      process.exit(1);
    }
    request('POST', '/send', msg, (code, data) => console.log(data));
    break;
  case 'send-file':
    const filePath = args[0];
    if (!filePath) {
      console.error('Hata: Gönderilecek dosya yolu belirtilmedi.');
      process.exit(1);
    }
    request('POST', '/send_file', path.resolve(filePath), (code, data) => console.log(data));
    break;
  default:
    console.error(`Bilinmeyen komut: ${cmd}`);
    process.exit(1);
}
