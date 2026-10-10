import re
import sys

src = sys.argv[1]
info_c = open(src + "/info.c").read()
info_h = open(src + "/info.h").read()
sounds_h = open(src + "/sounds.h").read()
mobj_h = open(src + "/p_mobj.h").read()


def enum(text, name):
    end = re.search(r"\}\s*" + name + r"\s*;", text).start()
    start = text.rindex("{", 0, text.rindex("typedef enum", 0, end) + 20)
    body = text[start + 1:end]
    body = re.sub(r"//.*", "", body)
    return [t.strip().split("=")[0].strip() for t in body.split(",") if t.strip()]


env = {"FRACUNIT": 65536, "NULL": 0}
for i, n in enumerate(enum(info_h, "spritenum_t")):
    env[n] = i
for i, n in enumerate(enum(info_h, "statenum_t")):
    env[n] = i
for i, n in enumerate(enum(sounds_h, "sfxenum_t")):
    env[n] = i
for n, v in re.findall(r"(MF_\w+)\s*=\s*(0x[0-9a-fA-F]+|\d+)", mobj_h):
    env[n] = int(v, 0)

states_body = re.search(r"state_t\s+states\[NUMSTATES\]\s*=\s*\{(.*?)\n\};", info_c, re.S).group(1)
actions = ["NULL"]
states = []
for m in re.finditer(r"\{(\w+),(\d+),(-?\d+),\{(\w+)\},(\w+),(-?\d+),(-?\d+)\}", states_body):
    spr, frame, tics, act, nxt, m1, m2 = m.groups()
    if act not in actions:
        actions.append(act)
    states += [env[spr], int(frame), int(tics) & 0xFFFFFFFF, actions.index(act), env[nxt], int(m1) & 0xFFFFFFFF, int(m2) & 0xFFFFFFFF]

mobj_body = re.search(r"mobjinfo_t\s+mobjinfo\[NUMMOBJTYPES\]\s*=\s*\{(.*)\n\};", info_c, re.S).group(1)
mobjs = []
for block in re.findall(r"\{\s*//[^\n]*\n(.*?)\n\s*\}", mobj_body, re.S):
    for line in block.split("\n"):
        expr = re.sub(r"//.*", "", line).strip().rstrip(",")
        if expr:
            mobjs.append(eval(expr, {}, env) & 0xFFFFFFFF)

sprnames = re.findall(r'"(\w{4})"', re.search(r"sprnames\[NUMSPRITES\]\s*=\s*\{(.*?)\};", info_c, re.S).group(1))


def chunks(xs, n=512):
    return [xs[i:i + n] for i in range(0, len(xs), n)]


def emit(name, xs, ty="U32", show=str):
    out = []
    parts = chunks(xs)
    for i, part in enumerate(parts):
        out.append("def %s.c%d() -> List<&2, %s>:\n  [%s]\n" % (name, i, ty, ", ".join(map(show, part))))
    expr = "%s.c%d()" % (name, len(parts) - 1)
    for i in reversed(range(len(parts) - 1)):
        expr = "List.append(&2, %s, %s.c%d(), %s)" % (ty, name, i, expr)
    out.append("def %s() -> List<&2, %s>:\n  %s\n" % (name, ty, expr))
    return out


out = ["import Base\n"]
out += emit("sprnames", sprnames, "String", lambda s: '"%s"' % s)
out += emit("actions", actions, "String", lambda s: '"%s"' % s)
out += emit("states", states)
out += emit("mobjinfo", mobjs)
out.append("def nstates() -> U32:\n  %d\n" % (len(states) // 7))
out.append("def ntypes() -> U32:\n  %d\n" % (len(mobjs) // 23))
open(sys.argv[2], "w").write("\n".join(out))
print(len(sprnames), len(states) // 7, len(mobjs) // 23, len(actions))
