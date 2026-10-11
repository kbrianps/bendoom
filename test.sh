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
SOUNDFONT="$CACHE/TimGM6mb.sf2"
SOUNDFONT_SHA=82475b91a76de15cb28a104707d3247ba932e228bada3f47bba63c6b31aaf7a1
if [ ! -f "$SOUNDFONT" ]; then
  curl -fsSL -o "$SOUNDFONT" \
    "https://raw.githubusercontent.com/craffel/pretty-midi/0.2.10/pretty_midi/TimGM6mb.sf2" || exit 1
fi
echo "$SOUNDFONT_SHA  $SOUNDFONT" | sha256sum -c --quiet || exit 1

$BEND wadinfo.bend -o "$TMP/wadinfo" >/dev/null 2>&1 || { echo "build wadinfo failed"; exit 1; }
$BEND automap.bend -o "$TMP/automap" >/dev/null 2>&1 || { echo "build automap failed"; exit 1; }
$BEND shot.bend -o "$TMP/shot" >/dev/null 2>&1 || { echo "build shot failed"; exit 1; }
$BEND walk.bend -o "$TMP/walk" >/dev/null 2>&1 || { echo "build walk failed"; exit 1; }
$BEND demo.bend -o "$TMP/demo" >/dev/null 2>&1 || { echo "build demo failed"; exit 1; }
$BEND song.bend -o "$TMP/song" >/dev/null 2>&1 || { echo "build song failed"; exit 1; }

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

sound() {
  local name=$1 wad=$2 ep=$3 map=$4 lump=$5 sha=$6; shift 6
  python3 tests/mklmp.py "$TMP/demo.lmp" "$ep" "$map" "$@" &&
    "$TMP/demo" "$WADS/$wad.wad" "$lump" "$TMP/demo.lmp" ${GIVE:-} sound | sha256sum | grep -q "^$sha " &&
    ok "sound: $name starts the reference engine's sounds tic by tic" || bad "sound: $name"
}
sound "E1M1 run" freedoom1 1 1 E1M1 780bc51ddb2d41284a41c06c017b982fd706735def5942b5387118f1c3445e30 100,50,0,0,0 40,0,0,8,0 200,50,20,0,2 100,-30,0,248,0 300,50,0,4,2
sound "MAP15 under fire" freedoom2 1 15 MAP15 8707678daab3ef8c64113da0fa8ae876d55361b25e6604f2da271c10838d85c8 200,50,0,0,2 60,0,0,6,0 300,50,-10,0,2 300,40,30,252,2
sound "E1M1 pistol fight" freedoom1 1 1 E1M1 9526bbb4e97709b49afe3c303dd6e5d33fd74314c728f28511ae8554a70916f3 40,0,0,0,1 100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 300,50,0,4,3
GIVE=give sound "MAP01 every weapon" freedoom2 1 1 MAP01 729a6aaed25290a022a8cbaeab608b63928c83bd0e286a3d60ac51a45f649290 30,0,0,0,20 40,0,0,0,1 30,0,0,0,68 40,50,0,0,1 30,0,0,0,28 60,0,0,4,1 30,0,0,0,36 30,0,0,0,1 30,0,0,0,44 60,30,0,0,1

song() {
  "$TMP/song" "$WADS/$1.wad" "$2" "$3" "$TMP/song.wav" &&
    echo "$4  $TMP/song.wav" | sha256sum -c --quiet &&
    ok "music: $3 seconds of $2" || bad "music: $2"
}
song freedoom1 D_E1M1 10 78b9c6a66cb7c4e7ae16396d80b8b98338b7ce09b3eaca8a26e1fbca3c1bfcfe
song freedoom1 D_INTER 80 16a078aab1e54868eac11c0a738b3634786249847e57143fdceaee0cbed2f113
song freedoom2 D_RUNNIN 10 b9b50ec44823dcebe8c2939d1a4b86b4c03e0945c8ae0263d02b820e8de40516

gmsong() {
  local what=$1 wad=$2 lump=$3 secs=$4 sha=$5; shift 5
  "$TMP/song" "$WADS/$wad.wad" "$@" -soundfont "$SOUNDFONT" "$lump" "$secs" "$TMP/gm.wav" &&
    echo "$sha  $TMP/gm.wav" | sha256sum -c --quiet &&
    ok "General MIDI: $secs seconds of $what" || bad "General MIDI: $what"
}
gmsong "D_E1M1" freedoom1 D_E1M1 10 71a5dcb2aec6d334f233fe6d6c8e167d4993088b114953de7fd73b47b4e30931
gmsong "D_INTER, looping" freedoom1 D_INTER 80 045c8c42b80528de3d691737d95c87ab176393786c0dd043e76423f2a4e96f83
python3 tests/mkmus.py "$WADS/freedoom1.wad" D_E1M1 "$TMP/mus.wad" &&
  gmsong "D_E1M1 as a MUS lump" freedoom1 D_E1M1 20 5c0f8328571aba3e79457ef9990989ba65914758680ed8532acc868d0afa40a5 -file "$TMP/mus.wad" || bad "build the MUS PWAD"

python3 tests/mklmp.py "$TMP/demo.lmp" 1 1 40,0,0,0,1 100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 300,50,0,4,3 &&
  "$TMP/demo" "$WADS/freedoom1.wad" E1M1 "$TMP/demo.lmp" 330 "$TMP/frame.bmp" >/dev/null &&
  echo "11d7119724f8c49dcf7ca7d1961600f5934f6aeabfcb3322a7e4e76d66c3cb7f  $TMP/frame.bmp" | sha256sum -c --quiet &&
  ok "demo: E1M1 pistol fight frame 330 with weapon and status bar" || bad "demo: E1M1 pistol fight frame 330"

python3 tests/mkpwad.py "$WADS/freedoom1.wad" "$TMP/e1m4.wad" plain E1M4 E1M1 &&
  python3 tests/mkpwad.py "$WADS/freedoom1.wad" "$TMP/xnod.wad" xnod E1M1 E1M1 &&
  python3 tests/mkpwad.py "$WADS/freedoom1.wad" "$TMP/znod.wad" znod E1M1 E1M1 || bad "build the test PWADs"
pwad() {
  local name=$1 pw=$2 sha=$3 segs=$4 file=$5; shift 5
  python3 tests/mklmp.py "$TMP/demo.lmp" 1 1 $segs &&
    "$TMP/demo" "$WADS/freedoom1.wad" -file "$TMP/$pw" E1M1 "$TMP/demo.lmp" "$@" > "$TMP/pwad.out" &&
    echo "$sha  $TMP/$file" | sha256sum -c --quiet &&
    ok "pwad: $name" || bad "pwad: $name"
}
pwad "E1M4 loaded over E1M1 matches the reference engine tic by tic" e1m4.wad 1af90345749c93892a49f1640a0c1805f75b1fe6a6b14c882b41c7ffc8369862 "100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 200,50,0,4,3" pwad.out
pwad "E1M4 loaded over E1M1, frame 300 as the reference draws it" e1m4.wad c160f66e83080a381f8638204898533f7f47095cd0c28b593ca9fb503529c099 "100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 200,50,0,4,3" pw300.bmp 300 "$TMP/pw300.bmp"
pwad "E1M1 with ZDoom compressed nodes plays as with the original nodes" znod.wad 608671ffca4c76c4fc7d2164f4dc90cd4fc80ec32b12756a1af05568e30a2ec3 "40,0,0,0,1 100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 300,50,0,4,3" pwad.out
pwad "E1M1 with ZDoom extended nodes draws as with the original nodes" xnod.wad 11d7119724f8c49dcf7ca7d1961600f5934f6aeabfcb3322a7e4e76d66c3cb7f "40,0,0,0,1 100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 300,50,0,4,3" xn330.bmp 330 "$TMP/xn330.bmp"

IWAD="$PWD/$WADS/freedoom1.wad"
mkdir -p "$TMP/sv" &&
  python3 tests/mklmp.py "$TMP/demo.lmp" 1 1 40,0,0,0,1 100,50,0,0,1 40,0,0,8,1 200,50,20,0,3 100,-30,0,248,1 300,50,0,4,3 &&
  (cd "$TMP/sv" && "$TMP/demo" "$IWAD" E1M1 "$TMP/demo.lmp" savegame 200 >/dev/null) &&
  echo "486c825704c9c8585453319cf0da37959f787a0f81e31ca9dacebf1b1973fdb6  $TMP/sv/doomsav0.dsg" | sha256sum -c --quiet &&
  ok "save: E1M1 pistol fight saved at tic 200 in vanilla's .dsg layout" || bad "save: E1M1 pistol fight at tic 200"
(cd "$TMP/sv" && "$TMP/demo" "$IWAD" E1M1 title loadgame | head -200 > "$TMP/load.out") || true
echo "ba568e70c5799928045fc94c545acefb404ac015586877bbabbd4358b654ef05  $TMP/load.out" | sha256sum -c --quiet &&
  ok "load: that save plays on as the reference engine plays its own save, tic by tic" || bad "load: E1M1 save from tic 200"

frame() {
  local name=$1 wad=$2 ep=$3 map=$4 lump=$5 file=$6 sha=$7 segs=$8; shift 8
  python3 tests/mklmp.py "$TMP/demo.lmp" "$ep" "$map" $segs &&
    "$TMP/demo" "$WADS/$wad.wad" "$lump" "$TMP/demo.lmp" "$@" >/dev/null &&
    echo "$sha  $TMP/$file" | sha256sum -c --quiet &&
    ok "frame: $name" || bad "frame: $name"
}
frame "E1M1 menu to the load screen, water flat animated" freedoom1 1 1 E1M1 mn.bmp 4a700fed48470ad701c53a6f837ca1a90444ed87bb6eaa4274b8039d212d8999 "220,30,0,0,0" \
  keys 10 27 1 11 27 0 20 63233 1 21 63233 0 30 63233 1 31 63233 0 40 13 1 41 13 0 50 63233 1 51 63233 0 60 63233 1 61 63233 0 end 60 "$TMP/mn.bmp"
frame "E1M1 automap with grid, mark and zoom while turning" freedoom1 1 1 E1M1 am_120.bmp c28d5445b7301efac832e555253f684f16910bfb38c51880c094a316b1a9afd7 "120,40,0,3,0" \
  keys 5 9 1 6 9 0 50 103 1 51 103 0 60 109 1 61 109 0 70 45 1 76 45 0 end every 40 "$TMP/am"
frame "E1M1 intermission" freedoom1 1 1 E1M1 wi.bmp 02f3e161aa90a002ef38360f15edc3a2d0f02c31686ed034223851cbb4501ccf "400,0,0,0,0" \
  exit 40 300 "$TMP/wi.bmp"
frame "E1M8 finale text" freedoom1 1 8 E1M8 fin_650.bmp 0832b232c7ebfd7285d8d101560dbd782ea911bfd66451f66b077f4f5a34dc2c "250,0,0,0,0 1,0,0,0,2 60,0,0,0,0 1,0,0,0,2 60,0,0,0,0 1,0,0,0,2 400,0,0,0,0" \
  exit 40 650 "$TMP/fin_650.bmp"
frame "E1M1 invulnerability inverts the whole view" freedoom1 1 1 E1M1 inv.bmp 14946278df246296621663f77405a18263662f7ef4292be578fe32d65ebe1692 "60,25,0,0,0" \
  keys 5 105 1 6 105 0 7 100 1 8 100 0 9 98 1 10 98 0 11 101 1 12 101 0 13 104 1 14 104 0 15 111 1 16 111 0 17 108 1 18 108 0 19 100 1 20 100 0 21 118 1 22 118 0 end 30 "$TMP/inv.bmp"
frame "E1M1 light amplification lights the whole view" freedoom1 1 1 E1M1 amp.bmp b7bf4fcad6a0f1bfdaff0089cd8446fe724a563e74d44fb45a12c055a088749f "60,25,0,0,0" \
  keys 5 105 1 6 105 0 7 100 1 8 100 0 9 98 1 10 98 0 11 101 1 12 101 0 13 104 1 14 104 0 15 111 1 16 111 0 17 108 1 18 108 0 19 100 1 20 100 0 21 108 1 22 108 0 end 60 "$TMP/amp.bmp"
frame "E1M2 invisible weapon, fuzz carried from E1M1" freedoom1 1 1 E1M1 fz_166.bmp ce764d595fe54ceaa2e3dc8b51f78f81d294f0e6a073cccda579caffd7325f17 "60,25,0,0,0 5,0,0,0,1 25,0,0,0,0 5,0,0,0,1 25,0,0,0,0 5,0,0,0,1 25,0,0,0,0 5,0,0,0,1 25,0,0,0,0 50,25,0,4,0" \
  exit 40 keys 5 105 1 6 105 0 7 100 1 8 100 0 9 98 1 10 98 0 11 101 1 12 101 0 13 104 1 14 104 0 15 111 1 16 111 0 17 108 1 18 108 0 19 100 1 20 100 0 21 105 1 22 105 0 136 105 1 137 105 0 138 100 1 139 100 0 140 98 1 141 98 0 142 101 1 143 101 0 144 104 1 145 104 0 146 111 1 147 111 0 148 108 1 149 108 0 150 100 1 151 100 0 152 105 1 153 105 0 end every 166 "$TMP/fz"

frame "MAP01 screen sizes and detail, status bar back from full screen" freedoom2 1 1 MAP01 sy_160.bmp ead8af6e03c01eb7246a5830ac5424d25a006d60eba00154f143090f71b56418 "160,25,0,2,1" \
  keys 5 45 1 6 45 0 7 45 1 8 45 0 9 45 1 10 45 0 11 45 1 12 45 0 15 63240 1 16 63240 0 30 27 1 31 27 0 40 27 1 41 27 0 60 61 1 61 61 0 62 61 1 63 61 0 64 61 1 65 61 0 66 61 1 67 61 0 68 61 1 69 61 0 90 63240 1 91 63240 0 110 45 1 111 45 0 end every 160 "$TMP/sy"
frame "E1M1 low detail small view with fuzz, help and automap" freedoom1 1 1 E1M1 lw_96.bmp a008e24724b21a315d12cf33e705db430382b57e4b24e5c39208de83b95a14b9 "60,25,0,0,1 80,30,0,4,1" \
  keys 3 105 1 4 105 0 5 100 1 6 100 0 7 98 1 8 98 0 9 101 1 10 101 0 11 104 1 12 104 0 13 111 1 14 111 0 15 108 1 16 108 0 17 100 1 18 100 0 19 105 1 20 105 0 25 63240 1 26 63240 0 30 45 1 31 45 0 32 45 1 33 45 0 40 63236 1 41 63236 0 50 27 1 51 27 0 60 9 1 61 9 0 70 45 1 71 45 0 80 9 1 81 9 0 90 61 1 91 61 0 100 63236 1 101 63236 0 102 63236 1 103 63236 0 110 27 1 111 27 0 120 61 1 121 61 0 122 61 1 123 61 0 124 61 1 125 61 0 end every 96 "$TMP/lw"

[ "$FAILS" -eq 0 ] && echo "ALL TESTS PASS" || { echo "$FAILS FAILED"; exit 1; }
