import re
import sys

src = sys.argv[1]
text = open(src + "/sounds.c").read()
body = re.search(r"sfxinfo_t S_sfx\[\]\s*=\s*\{(.*?)\n\};", text, re.S).group(1)
entries = re.findall(r'SOUND(?:_LINK)?\("(\w+)",\s*(\d+)(?:,\s*sfx_(\w+))?', body)
names = [n for n, p, l in entries]
lumps = []
prios = []
for n, p, l in entries:
    lumps.append("DS" + (l or n).upper())
    prios.append(int(p))
assert len(lumps) == 109

out = ["import Base", ""]
out.append("def lumps() -> List<&2, String>:")
out.append("  [" + ", ".join('"%s"' % s for s in lumps[1:]) + "]")
out.append("")
out.append("def prios() -> List<&2, U32>:")
out.append("  [" + ", ".join(str(p) for p in prios) + "]")
out.append("")
open(sys.argv[2], "w").write("\n".join(out))
