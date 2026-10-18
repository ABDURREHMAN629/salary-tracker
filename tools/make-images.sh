#!/usr/bin/env bash
# Regenerates the website images in assets/ with headless Chrome (or Edge):
#   screenshot-summary.png, screenshot-days.png  (app with sample data from demo-data.js)
#   og-image.png                                 (1200x630 link preview, from og-image.html)
#   icon-512.png                                 (from logo.svg)
#
#   bash tools/make-images.sh
set -euo pipefail
cd "$(dirname "$0")/.."

BROWSER="/c/Program Files/Google/Chrome/Application/chrome.exe"
[ -x "$BROWSER" ] || BROWSER="/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
win() { cygpath -w "$1"; }
url() { echo "file:///$(cygpath -m "$1")" | sed 's/ /%20/g'; }

shot() { # shot <out.png> <width> <height> <url> [scale]
  "$BROWSER" --headless=new --disable-gpu --hide-scrollbars --no-first-run \
    --user-data-dir="$(win "$TMP/profile")" --force-device-scale-factor="${5:-1}" \
    --default-background-color=00000000 --virtual-time-budget=8000 \
    --window-size="$2,$3" --screenshot="$(win "$PWD/$1")" "$4" >/dev/null 2>&1
  echo "  $1"
}

echo "Making images..."
# App copy with sample data injected before the app script runs, plus a helper that opens September 2026
sed -e 's#<script>#<script src="DEMO_DATA"></script><script>#' \
    -e 's#</body>#<script src="DEMO_SHOW"></script></body>#' app/index.html \
  | sed -e "s#DEMO_DATA#$(url "$PWD/tools/demo-data.js")#" -e "s#DEMO_SHOW#$(url "$PWD/tools/demo-show.js")#" \
  > "$TMP/demo.html"

# Browser windows can't be narrower than ~500px, so the app is shown in a phone-sized iframe
phone() { # phone <name> <hash>
  echo "<html><body style=\"margin:0\"><iframe src=\"demo.html$2\" style=\"border:0;width:412px;height:892px;display:block\"></iframe></body></html>" > "$TMP/$1.html"
  url "$TMP/$1.html"
}
shot assets/screenshot-summary.png 412 892 "$(phone summary '')" 2
shot assets/screenshot-days.png 412 892 "$(phone days '#period1')" 2
shot assets/og-image.png 1200 630 "$(url "$PWD/tools/og-image.html")"

cat > "$TMP/icon.html" <<EOF
<html><body style="margin:0;background:transparent"><img src="$(url "$PWD/assets/logo.svg")" style="width:100vw;height:100vh;display:block"></body></html>
EOF
shot assets/icon-512.png 512 512 "$(url "$TMP/icon.html")"
echo "Done."
