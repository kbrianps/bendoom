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
image shot freedoom1 E1M1 01a5fc5231cc17f6504ee81c37ce14a95403a8286f740468487fae7463ee06f2
image shot freedoom1 E3M3 a79be90140ad33621cfd930687caef2d299014c6f79e620397a4fade0ead1e89
image shot freedoom2 MAP01 4adf0261725738994fc57387648ba730cd0c42babd6d510c477d9ebce28a0394

walk() {
  local name=$1 want=$2 sha=$3; shift 3
  got=$("$TMP/walk" "$WADS/freedoom1.wad" E1M1 "$TMP/walk.bmp" "$@") &&
    [ "$got" = "$want" ] &&
    echo "$sha  $TMP/walk.bmp" | sha256sum -c --quiet &&
    ok "walk: $name" || bad "walk: $name ($got)"
}
walk "ride the lift down" "710 254 4294967168 0 hp=87" 51ecde4841d443674961f82b7b6817a03a44779ad435ded8ba4c1fb81ceac4a4 200 1
walk "open a door" "600 712 4294967168 0 hp=100" 2f00b97101a6f4c3cd4822bde4217c4a3c9c30938ddb509b92f279568714a840 at 600 712 180 1 0 2 128 40 0
"$TMP/walk" "$WADS/freedoom1.wad" E1M1 "$TMP/exit.bmp" at -370 1296 180 1 0 2 128 10 0 | grep -q " 1 hp=" &&
  ok "walk: exit switch" || bad "walk: exit switch"

demo() {
  local name=$1 wad=$2 ep=$3 map=$4 lump=$5 sha=$6; shift 6
  python3 tests/mklmp.py "$TMP/demo.lmp" "$ep" "$map" "$@" &&
    "$TMP/demo" "$WADS/$wad.wad" "$lump" "$TMP/demo.lmp" ${GIVE:-} | sha256sum | grep -q "^$sha " &&
    ok "demo: $name matches the reference engine tic by tic" || bad "demo: $name"
}
demo "E1M1 walk" freedoom1 1 1 E1M1 703260c72dea907d0a9be07f29134444938cb441a82f3d186aa573b756a845fe 300,50,0,0,0
demo "E1M1 run" freedoom1 1 1 E1M1 5dbd1d26138f59f00f5f332a6d8e3741a92c0a373a333c02ef51e8f1f05386aa 100,50,0,0,0 40,0,0,8,0 200,50,20,0,2 100,-30,0,248,0 300,50,0,4,2
demo "E1M3 run" freedoom1 1 3 E1M3 9af111046c0dc2f3b66b18038235a122691d21a4149e7b882793ff233d2dcc61 150,50,0,0,0 60,0,0,6,0 300,50,-10,0,2 300,40,30,252,2
demo "E3M2 to death" freedoom1 3 2 E3M2 0ab4f368311106771a7167f9667f0144c91bb60e256fd66112e97c5dced03f05 400,50,0,2,2 63,50,10,254,2
demo "MAP15 under fire" freedoom2 1 15 MAP15 8a7962a725215d64b70b829789313036cdb274dcc7e9e4a0260c4e1956bcd710 200,50,0,0,2 60,0,0,6,0 300,50,-10,0,2 300,40,30,252,2
demo "MAP30 run" freedoom2 1 30 MAP30 32ec3da5ce94fa123915dd2c3ea81c10a5c3decb43af1fcec3e247e3be1572f1 200,50,0,0,2 60,0,0,6,0 300,50,-10,0,2 300,40,30,252,2
demo "E1M1 pistol fight" freedoom1 1 1 E1M1 608671ffca4c76c4fc7d2164f4dc90cd4fc80ec32b12756a1af05568e30a2ec3 40,0,0,0,1 100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 300,50,0,4,3
GIVE=give demo "MAP01 every weapon" freedoom2 1 1 MAP01 df54c15d868df895bc4bce94f93b13ec657b4e20979c17eea855fcf7287c5a82 30,0,0,0,20 40,0,0,0,1 30,0,0,0,68 40,50,0,0,1 30,0,0,0,28 60,0,0,4,1 30,0,0,0,36 30,0,0,0,1 30,0,0,0,44 60,30,0,0,1
GIVE=give demo "MAP01 saw, fist, plasma" freedoom2 1 1 MAP01 85d6f180d4c69db941b35a61cba88edd02f2bf5fcc009df39eef142eabb0e7f6 30,0,0,0,52 60,0,0,0,1 30,0,0,0,4 60,50,0,0,1 30,0,0,0,60 80,50,0,0,1 30,0,0,0,12 60,0,0,8,1

python3 tests/mklmp.py "$TMP/demo.lmp" 1 1 40,0,0,0,1 100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 300,50,0,4,3 &&
  "$TMP/demo" "$WADS/freedoom1.wad" E1M1 "$TMP/demo.lmp" 330 "$TMP/frame.bmp" >/dev/null &&
  echo "11d7119724f8c49dcf7ca7d1961600f5934f6aeabfcb3322a7e4e76d66c3cb7f  $TMP/frame.bmp" | sha256sum -c --quiet &&
  ok "demo: E1M1 pistol fight frame 330 with weapon and status bar" || bad "demo: E1M1 pistol fight frame 330"

[ "$FAILS" -eq 0 ] && echo "ALL TESTS PASS" || { echo "$FAILS FAILED"; exit 1; }
