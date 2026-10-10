import sys

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

out = ["import Base", ""]
out.append("def hudnames() -> List<&2, String>:")
out.append("  [%s]" % ", ".join('"%s"' % n for n in names))
out.append("")
out.append("def msgtext() -> List<&2, List<&2, U32>>:")
out.append("  [%s]" % ", ".join("[%s]" % ", ".join(str(ord(c)) for c in m.upper()) for m in msgs))
out.append("")
open(sys.argv[1], "w").write("\n".join(out))
