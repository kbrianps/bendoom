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
$BEND walk.bend -o "$TMP/walk" >/dev/null 2>&1 || { echo "build walk failed"; exit 1; }
$BEND demo.bend -o "$TMP/demo" >/dev/null 2>&1 || { echo "build demo failed"; exit 1; }

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
image shot freedoom1 E1M1 548d94d5041b28af1152ca9e96b10fb6bc094f680d5d413fbdb65efbbb8a435e
image shot freedoom1 E3M3 fd655f4154e192f5f3bea5863e1c4aa0458255ac1b56fcca798b1641c81dde26
image shot freedoom2 MAP01 20b68c90058b3f10cdafa413a6cd9c367325fb221582e15ec0c5cb5bcbc0b529

walk() {
  local name=$1 want=$2 sha=$3; shift 3
  got=$("$TMP/walk" "$WADS/freedoom1.wad" E1M1 "$TMP/walk.bmp" "$@") &&
    [ "$got" = "$want" ] &&
    echo "$sha  $TMP/walk.bmp" | sha256sum -c --quiet &&
    ok "walk: $name" || bad "walk: $name ($got)"
}
walk "ride the lift down" "710 254 4294967168 0 hp=87" 3eb6a5761aa1826d263214ff9326ae21908f2c489e03b3b399a461905ae1eb36 200 1
walk "open a door" "600 712 4294967168 0 hp=100" bef75a60590d1420ce8f3be2ddf428ab3fb513359d09eaf8ead7bae352b5f498 at 600 712 180 1 0 2 128 40 0
"$TMP/walk" "$WADS/freedoom1.wad" E1M1 "$TMP/exit.bmp" at -370 1296 180 1 0 2 128 10 0 | grep -q " 1 hp=" &&
  ok "walk: exit switch" || bad "walk: exit switch"

demo() {
  local name=$1 wad=$2 ep=$3 map=$4 lump=$5 sha=$6; shift 6
  python3 tests/mklmp.py "$TMP/$name.lmp" "$ep" "$map" "$@" &&
    "$TMP/demo" "$WADS/$wad.wad" "$lump" "$TMP/$name.lmp" | sha256sum | grep -q "^$sha " &&
    ok "demo: $name matches the reference engine tic by tic" || bad "demo: $name"
}
demo "E1M1 walk" freedoom1 1 1 E1M1 59b54c43a21e674e1d2678dea63372f9fc0d34099397494f41d5f70bd9ee19a7 300,50,0,0,0
demo "E1M1 run" freedoom1 1 1 E1M1 35ed2ac1a377ee172359f370bcfdf8759d7753dd4ace6a626b16910cd45323fa 100,50,0,0,0 40,0,0,8,0 200,50,20,0,2 100,-30,0,248,0 300,50,0,4,2
demo "E1M3 run" freedoom1 1 3 E1M3 3fd5a969021596cd11e6b821ad82f3bd90e1224c7af664e339bf54db56cab17a 150,50,0,0,0 60,0,0,6,0 300,50,-10,0,2 300,40,30,252,2
demo "E3M2 to death" freedoom1 3 2 E3M2 e6dbd544d3a14e3a11eca4da52cf9a8d78d404ba9f55a18a18e0a33206a85f3e 400,50,0,2,2 63,50,10,254,2
demo "MAP15 under fire" freedoom2 1 15 MAP15 5b879191d3055f078044353b5f3c86a5441074e875e14b97f8098c2c69b7c07b 200,50,0,0,2 60,0,0,6,0 300,50,-10,0,2 300,40,30,252,2
demo "MAP30 run" freedoom2 1 30 MAP30 1a44cb009b62d5b3ddf0c301fc23eaeffa3ca148d02688414af946ed1a8ca328 200,50,0,0,2 60,0,0,6,0 300,50,-10,0,2 300,40,30,252,2

[ "$FAILS" -eq 0 ] && echo "ALL TESTS PASS" || { echo "$FAILS FAILED"; exit 1; }
