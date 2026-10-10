#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")"
BEND=${BEND:-bend}
CACHE=${CACHE:-tests/.cache}
FREEDOOM=freedoom-0.13.0
FREEDOOM_SHA=3f9b264f3e3ce503b4fb7f6bdcb1f419d93c7b546f4df3e874dd878db9688f59
TMP=$(mktemp -d)
FAILS=0
trap 'rm -rf "$TMP"' EXIT

ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; FAILS=$((FAILS + 1)); }

if [ ! -f "$CACHE/$FREEDOOM/freedoom1.wad" ]; then
  mkdir -p "$CACHE"
  curl -fsSL -o "$CACHE/$FREEDOOM.zip" \
    "https://github.com/freedoom/freedoom/releases/download/v0.13.0/$FREEDOOM.zip" || exit 1
  echo "$FREEDOOM_SHA  $CACHE/$FREEDOOM.zip" | sha256sum -c --quiet || exit 1
  unzip -q -o "$CACHE/$FREEDOOM.zip" -d "$CACHE" || exit 1
fi
WADS="$CACHE/$FREEDOOM"

$BEND wadinfo.bend -o "$TMP/wadinfo" >/dev/null 2>&1 || { echo "build wadinfo failed"; exit 1; }
$BEND automap.bend -o "$TMP/automap" >/dev/null 2>&1 || { echo "build automap failed"; exit 1; }
$BEND shot.bend -o "$TMP/shot" >/dev/null 2>&1 || { echo "build shot failed"; exit 1; }

for wad in freedoom1 freedoom2; do
  python3 tests/wadinfo.py "$WADS/$wad.wad" > "$TMP/$wad.want"
  "$TMP/wadinfo" "$WADS/$wad.wad" > "$TMP/$wad.got"
  n=$(wc -l < "$TMP/$wad.want")
  [ "$n" -gt 0 ] && diff -q "$TMP/$wad.want" "$TMP/$wad.got" >/dev/null &&
    ok "$wad.wad: all $n maps read as the reference reads them" || bad "$wad.wad maps"
done

image() {
  "$TMP/$1" "$WADS/$2.wad" "$3" "$TMP/$1-$3.bmp" &&
    echo "$4  $TMP/$1-$3.bmp" | sha256sum -c --quiet &&
    ok "$1 of $3" || bad "$1 of $3"
}
image automap freedoom1 E1M1 ca6f083a70a9de12621b0d5091353234ef2eed3733b23aa128c548d88ae3a85e
image automap freedoom1 E4M7 28cdab142d2b33cb8ee3999b66dcf9fe0c6e1a564d2fa15feba7ffe21a25d833
image automap freedoom2 MAP01 b3751262f55ae35c9d7d76d93f7910ef52cf67f39820960c83a85735962c16ba
image shot freedoom1 E1M1 305eb022edb41763a581722f630573f18156e4a953b58237bec74eb9074cd63a
image shot freedoom1 E3M3 835aef2ebb4deb5d5710e849eca6877e4c2c19b236de995c5bcf216892d3d827
image shot freedoom2 MAP01 4a97935d9e7f2e37a363e83aa1905bbf830a0467cd0bed023f22a5257c8570b7

[ "$FAILS" -eq 0 ] && echo "ALL TESTS PASS" || { echo "$FAILS FAILED"; exit 1; }
