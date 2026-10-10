import math
import re
import sys


def table(text, name):
    body = re.search(name + r"\[\d*\]\s*=\s*\{(.*?)\};", text, re.S).group(1)
    body = re.sub(r"/\*.*?\*/", "", body, flags=re.S)
    body = re.sub(r"//[^\n]*", "", body)
    return [int(x, 0) for x in re.findall(r"0x[0-9a-fA-F]+|\d+", body)]


music = open(sys.argv[1] + "/i_oplmusic.c").read()
chip = open(sys.argv[1] + "/opl3.c").read()
logsin = table(chip, "logsinrom")
expo = table(chip, "exprom")
freq = table(music, "frequency_curve")
vmt = table(music, "volume_mapping_table")
assert len(logsin) == 256 and len(expo) == 256 and len(freq) == 668 and len(vmt) == 128

wave = []
for wf in range(4):
    for p in range(1024):
        c2 = logsin[(p & 0xFF) ^ 0xFF] if p & 0x100 else logsin[p & 0xFF]
        if wf == 0:
            v = (0x8000 if p & 0x200 else 0) | c2
        elif wf == 1:
            v = 0x1000 if p & 0x200 else c2
        elif wf == 2:
            v = c2
        else:
            v = 0x1000 if p & 0x100 else logsin[p & 0xFF]
        wave.append(v)

ratio = 49716 / 11025
incstep = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 1, 0], [1, 1, 1, 0]]
dec = []
att = []
for r in range(64):
    hi = min(r >> 2, 15)
    lo = r & 3
    if r < 4:
        dec.append(0)
        att.append(0)
        continue
    d = 4.0 if hi == 15 else 2.0 ** (hi - 13) * (4 + lo) / 4
    dec.append(round(d * ratio * 65536))
    if hi == 15:
        att.append(65536)
        continue
    if hi < 12:
        rate = 2.0 ** (hi - 13) * (4 + lo) / 4 * math.log(7 / 8)
    else:
        total = 0.0
        for t in range(4):
            for state in (0, 1):
                s = (hi & 3) + incstep[lo][t]
                if s & 4:
                    s = 3
                if s == 0:
                    s = state
                if s > 0:
                    total += math.log(1 - 2.0 ** -(4 - s))
        rate = total / 8
    att.append(min(65536, round((1 - math.exp(ratio * rate)) * 65536)))

out = ["import Base", ""]
for name, xs in [("wave", wave), ("expo", expo), ("freq", freq), ("vmt", vmt), ("dec", dec), ("att", att)]:
    parts = [xs[i:i + 256] for i in range(0, len(xs), 256)]
    for i, part in enumerate(parts):
        out.append("def %s.c%d() -> List<&2, U32>:" % (name, i))
        out.append("  [" + ", ".join(str(x) for x in part) + "]")
        out.append("")
    expr = "%s.c%d()" % (name, len(parts) - 1)
    for i in reversed(range(len(parts) - 1)):
        expr = "List.append(&2, U32, %s.c%d(), %s)" % (name, i, expr)
    out.append("def %s() -> List<&2, U32>:" % name)
    out.append("  " + expr)
    out.append("")
open(sys.argv[2], "w").write("\n".join(out))
