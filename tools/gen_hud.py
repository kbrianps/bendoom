import re
import sys

src = sys.argv[1]
englsh = open(src + "/d_englsh.h").read()
dstrings = open(src + "/dstrings.c").read()


def cstr(body):
    return "".join(bytes(m, "utf-8").decode("unicode_escape") for m in re.findall(r'"((?:[^"\\]|\\.)*)"', body))


defs = {}
for m in re.finditer(r"#define\s+(\w+)\s+((?:.*\\\n)*.*)", englsh):
    defs[m.group(1)] = m.group(2)


def text(name):
    body = defs[name]
    for k in re.findall(r"\b([A-Z][A-Z0-9_]+)\b", re.sub(r'"(?:[^"\\]|\\.)*"', '', body)):
        if k in defs:
            body = body.replace(k, defs[k])
    return cstr(body)


def endmsgs(name):
    body = re.search(name + r"\[\]\s*=\s*\{(.*?)\};", dstrings, re.S).group(1)
    body = re.sub(r"//.*", "", body)
    return [cstr(x) for x in re.findall(r'((?:"(?:[^"\\]|\\.)*"\s*)+)', body)]

msgs = ["",
    "You need a blue key to activate this object",
    "You need a red key to activate this object",
    "You need a yellow key to activate this object",
    "You need a blue key to open this door",
    "You need a yellow key to open this door",
    "You need a red key to open this door",
    "Picked up the armor.",
    "Picked up the MegaArmor!",
    "Picked up a health bonus.",
    "Picked up an armor bonus.",
    "Supercharge!",
    "MegaSphere!",
    "Picked up a blue keycard.",
    "Picked up a yellow keycard.",
    "Picked up a red keycard.",
    "Picked up a blue skull key.",
    "Picked up a yellow skull key.",
    "Picked up a red skull key.",
    "Picked up a stimpack.",
    "Picked up a medikit that you REALLY need!",
    "Picked up a medikit.",
    "Invulnerability!",
    "Berserk!",
    "Partial Invisibility",
    "Radiation Shielding Suit",
    "Computer Area Map",
    "Light Amplification Visor",
    "Picked up a clip.",
    "Picked up a box of bullets.",
    "Picked up a rocket.",
    "Picked up a box of rockets.",
    "Picked up an energy cell.",
    "Picked up an energy cell pack.",
    "Picked up 4 shotgun shells.",
    "Picked up a box of shotgun shells.",
    "Picked up a backpack full of ammo!",
    "You got the BFG9000!  Oh, yes.",
    "You got the chaingun!",
    "A chainsaw!  Find some meat!",
    "You got the rocket launcher!",
    "You got the plasma gun!",
    "You got the shotgun!",
    "You got the super shotgun!",
]
msgs += [text(n) for n in ["MSGOFF", "MSGON", "AMSTR_FOLLOWON", "AMSTR_FOLLOWOFF", "AMSTR_GRIDON", "AMSTR_GRIDOFF"]]
msgs += ["%s %d" % (text("AMSTR_MARKEDSPOT"), i) for i in range(10)]
msgs += [text(n) for n in ["AMSTR_MARKSCLEARED", "DETAILHI", "DETAILLO", "STSTR_DQDON", "STSTR_DQDOFF", "STSTR_FAADDED",
                           "STSTR_KFAADDED", "STSTR_NCON", "STSTR_NCOFF"]]
assert len(msgs) == 69, len(msgs)

names = ["STBAR", "STARMS"]
names += ["STTNUM%d" % i for i in range(10)] + ["STTPRCNT", "STTMINUS"]
names += ["STYSNUM%d" % i for i in range(10)]
names += ["STGNUM%d" % i for i in range(10)]
names += ["STKEYS%d" % i for i in range(9)]
for p in range(5):
    names += ["STFST%d%d" % (p, j) for j in range(3)]
    names += ["STFTR%d0" % p, "STFTL%d0" % p, "STFOUCH%d" % p, "STFEVL%d" % p, "STFKILL%d" % p]
names += ["STFGOD0", "STFDEAD0"]
names += ["STCFN%03d" % c for c in range(33, 96)]
assert len(names) == 148

fixed = ["WINUM%d" % i for i in range(10)] + ["WIMINUS", "WIPCNT", "WIF", "WIENTER", "WIOSTK", "WIOSTI", "WISCRT2",
         "WICOLON", "WITIME", "WISUCKS", "WIPAR", "WIURH0", "WIURH1", "WISPLAT"]
assert len(fixed) == 24
nanims = [[3] * 10, [1] * 7 + [3, 1], [3] * 6]


def episode(e):
    if e == 4:
        return ["INTERPIC"] + ["CWILV%02d" % i for i in range(32)] + ["-"] * 30
    if e == 3:
        return ["INTERPIC"] + ["WILV3%d" % i for i in range(9)] + ["-"] * 23 + ["-"] * 30
    an = []
    for j, n in enumerate(nanims[e]):
        for i in range(3):
            if i >= n:
                an.append("-")
            elif e == 1 and j == 8:
                an.append("WIA1%02d%02d" % (4, i))
            else:
                an.append("WIA%d%02d%02d" % (e, j, i))
    an += ["-"] * (30 - len(an))
    return ["WIMAP%d" % e] + ["WILV%d%d" % (e, i) for i in range(9)] + ["-"] * 23 + an


menu = ["TITLEPIC", "CREDIT", "HELP1", "HELP2", "HELP",
        "M_DOOM", "M_NGAME", "M_OPTION", "M_LOADG", "M_SAVEG", "M_RDTHIS", "M_QUITG", "M_SKULL1", "M_SKULL2",
        "M_EPISOD", "M_EPI1", "M_EPI2", "M_EPI3", "M_EPI4", "M_NEWG", "M_SKILL",
        "M_JKILL", "M_ROUGH", "M_HURT", "M_ULTRA", "M_NMARE", "M_PAUSE",
        "M_OPTTTL", "M_ENDGAM", "M_MESSG", "M_MSGOFF", "M_MSGON", "M_DETAIL", "M_GDHIGH", "M_GDLOW", "M_SCRNSZ",
        "M_MSENS", "M_SVOL", "M_SFXVOL", "M_MUSVOL", "M_THERML", "M_THERMM", "M_THERMR", "M_THERMO",
        "M_LGTTL", "M_SGTTL", "M_LSLEFT", "M_LSCNTR", "M_LSRGHT"] + ["AMMNUM%d" % i for i in range(10)]

texts = [text("E%dTEXT" % i) for i in range(1, 5)] + [text("C%dTEXT" % i) for i in range(1, 7)]
texts += [text("HUSTR_E%dM%d" % (e, m)) for e in range(1, 5) for m in range(1, 10)]
texts += [text("HUSTR_%d" % i) for i in range(1, 33)]
texts += [text(n) for n in ["CC_ZOMBIE", "CC_SHOTGUN", "CC_HEAVY", "CC_IMP", "CC_DEMON", "CC_LOST", "CC_CACO", "CC_HELL",
                            "CC_BARON", "CC_ARACH", "CC_PAIN", "CC_REVEN", "CC_MANCU", "CC_ARCH", "CC_SPIDER", "CC_CYBER", "CC_HERO"]]
texts += [m + "\n\n" + text("DOSY") for m in endmsgs("doom1_endmsg") + endmsgs("doom2_endmsg")]
texts += [text(n) for n in ["NIGHTMARE", "ENDGAME", "SWSTRING", "MSGOFF", "MSGON", "SAVEDEAD", "EMPTYSTRING", "QSAVESPOT"]]
assert len(texts) == 119, len(texts)

out = ["import Base", ""]
out.append("def hudnames() -> List<&2, String>:")
out.append("  [%s]" % ", ".join('"%s"' % n for n in names))
out.append("")
out.append("def uifixed() -> List<&2, String>:")
out.append("  [%s]" % ", ".join('"%s"' % n for n in fixed))
out.append("")
for e in range(5):
    out.append("def uiep%d() -> List<&2, String>:" % e)
    out.append("  [%s]" % ", ".join('"%s"' % n for n in episode(e)))
    out.append("")
out.append("def uimenu() -> List<&2, String>:")
out.append("  [%s]" % ", ".join('"%s"' % n for n in menu))
out.append("")
out.append("def texts() -> List<&2, List<&2, U32>>:")
out.append("  [%s]" % ", ".join("[%s]" % ", ".join(str(ord(c)) for c in m.upper()) for m in texts))
out.append("")
out.append("def msgtext() -> List<&2, List<&2, U32>>:")
out.append("  [%s]" % ", ".join("[%s]" % ", ".join(str(ord(c)) for c in m.upper()) for m in msgs))
out.append("")
open(sys.argv[2], "w").write("\n".join(out))
