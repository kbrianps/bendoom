import re
import sys

tables_c, random_c = sys.argv[1], sys.argv[2]


def values(src, name):
    body = re.search(name + r"\[\d+\]\s*=\s*\{(.*?)\};", src, re.S).group(1)
    return [int(v, 0) & 0xFFFFFFFF for v in re.findall(r"-?(?:0x[0-9a-fA-F]+|\d+)", body)]


def chunks(xs, n=512):
    return [xs[i:i + n] for i in range(0, len(xs), n)]


def emit(name, xs):
    out = []
    parts = chunks(xs)
    for i, part in enumerate(parts):
        out.append("def %s.c%d() -> List<&2, U32>:\n  [%s]\n" % (name, i, ", ".join(map(str, part))))
    expr = "%s.c%d()" % (name, len(parts) - 1)
    for i in reversed(range(len(parts) - 1)):
        expr = "List.append(&2, U32, %s.c%d(), %s)" % (name, i, expr)
    out.append("def %s() -> T.Vec<U32>:\n  T.from_list(U32, %s)\n" % (name, expr))
    return out


tables = open(tables_c).read()
random = open(random_c).read()
out = ["import Base\nimport ./tab.bend as T\n"]
out += emit("finetangent", values(tables, "finetangent"))
out += emit("finesine", values(tables, "finesine"))
out += emit("tantoangle", values(tables, "tantoangle"))
out += emit("rndtable", values(random, "rndtable"))
open(sys.argv[3], "w").write("\n".join(out))
