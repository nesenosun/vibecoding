#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  \. "$NVM_DIR/nvm.sh" --no-use 2>/dev/null
  NVM_NODE=$(ls "$NVM_DIR/versions/node" 2>/dev/null | sort -rV | head -1)
  [ -n "$NVM_NODE" ] && export PATH="$NVM_DIR/versions/node/$NVM_NODE/bin:$PATH"
fi
[ -d "$HOME/.volta/bin" ] && export PATH="$HOME/.volta/bin:$PATH"

BROWSER_DIR="$HOME/ersinis/.ersinis/artemis/artemis_browser"
SERVER_JS="$BROWSER_DIR/server.js"
NODE_MODULES="$BROWSER_DIR/node_modules"
ACTION="${1:-start}"
URL="${2:-https://gemini.google.com}"

start_server() {
  if ! lsof -i :8083 >/dev/null 2>&1; then
    cd "$BROWSER_DIR"
    NODE_PATH="$NODE_MODULES" node server.js > server.log 2>&1 &
    sleep 2
  fi
}

start_browser() {
  kill -9 $(lsof -i :9221 -t 2>/dev/null) >/dev/null 2>&1 || true
  start_server
  cd "$BROWSER_DIR"
  
  NODE_PATH="$NODE_MODULES" node -e "
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
puppeteer.use(StealthPlugin());

(async () => {
  try {
    const browser = await puppeteer.launch({
      headless: false,
      executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
      userDataDir: './browser_profiles/profile_1',
      ignoreDefaultArgs: ['--enable-automation'],
      args: [
        '--remote-debugging-port=9221'
      ]
    });
    const pages = await browser.pages();
    const page = pages.length > 0 ? pages[0] : await browser.newPage();
    await page.goto('$URL');
  } catch (error) {
    console.error(error);
  }
})();
  " &
}

stop_browser() {
  kill -9 $(lsof -i :9221 -t 2>/dev/null) >/dev/null 2>&1 || true
  kill -9 $(lsof -i :8083 -t 2>/dev/null) >/dev/null 2>&1 || true
}

case "$ACTION" in
  start) start_browser ;;
  stop) stop_browser ;;
  *) exit 1 ;;
esac
