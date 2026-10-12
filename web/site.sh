#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
FREEDOOM=freedoom-0.13.0
FREEDOOM_SHA=3f9b264f3e3ce503b4fb7f6bdcb1f419d93c7b546f4df3e874dd878db9688f59
CACHE=tests/.cache
OUT=web/site/bendoom
if [ ! -f "$CACHE/$FREEDOOM/freedoom1.wad" ]; then
  mkdir -p "$CACHE"
  curl -fsSL -o "$CACHE/$FREEDOOM.zip" \
    "https://github.com/freedoom/freedoom/releases/download/v0.13.0/$FREEDOOM.zip"
  echo "$FREEDOOM_SHA  $CACHE/$FREEDOOM.zip" | sha256sum -c --quiet
  unzip -q -o "$CACHE/$FREEDOOM.zip" -d "$CACHE"
fi
rm -rf web/site
mkdir -p "$OUT"
web/build.sh "$OUT/doom.js"
cp web/index.html "$OUT/index.html"
cp web/favicon.png web/apple-touch-icon.png "$OUT/"
cp docs/e1m1.png "$OUT/preview.png"
gzip -9 -n -c "$CACHE/$FREEDOOM/freedoom1.wad" > "$OUT/freedoom1.wad.gz"
cp "$CACHE/$FREEDOOM/COPYING.txt" "$OUT/FREEDOOM-COPYING.txt"
echo "wrote $OUT"
