#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
BEND=${BEND:-bend}
OUT=${1:-web/doom.js}
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
$BEND doom.bend -o "$TMP/doom.js"
python3 - "$TMP/doom.js" web/shell.js "$OUT" <<'PY'
import sys
src, shell, out = sys.argv[1:]
code = open(src).read().rstrip()
end = "cli(process.argv.slice(1));\nio_exit($main$, null);"
if not code.endswith(end):
    sys.exit("build.sh: unexpected ending in the emitted doom.js")
open(out, "w").write(code[: -len(end)] + open(shell).read())
PY
echo "wrote $OUT"
