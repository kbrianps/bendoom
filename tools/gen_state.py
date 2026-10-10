import sys

out = ["import Base", "import ./tab.bend as T", "import ./level.bend as L", "import ./world.bend as R",
       "import ./render.bend as V", "import ./mem.bend as M", ""]


def record(name, fields, kind="Data"):
    out.append("type %s is %s:" % (name, kind))
    out.append("  %s{%s}" % (name, ", ".join("%s: %s" % (f, t) for f, t in fields)))
    out.append("")


def reader(prefix, ty, fields, i):
    f, t = fields[i]
    names = ["x%d" % j for j in range(len(fields))]
    plus = "+" if t != "U32" else "+"
    out.append("def %s.%s(+r: %s) -> %s:" % (prefix, f, ty, t))
    out.append("  match r:")
    out.append("    case %s{%s}:" % (ty, ", ".join(names)))
    out.append("      x%d" % i)
    out.append("")


def writer(prefix, ty, fields, i):
    f, t = fields[i]
    names = ["x%d" % j for j in range(len(fields))]
    new = list(names)
    new[i] = "v"
    p = "+" if t == "U32" else ""
    out.append("def %s.%s.set(r: %s, %sv: %s) -> %s:" % (prefix, f, ty, p, t, ty))
    out.append("  match r:")
    out.append("    case %s{%s}:" % (ty, ", ".join(names)))
    out.append("      %s{%s}" % (ty, ", ".join(new)))
    out.append("")


def fields(spec):
    res = []
    for item in spec.split():
        if ":" in item:
            n, t = item.split(":", 1)
            res.append((n, t))
        else:
            res.append((item, "U32"))
    return res


rline = fields("x1 y1 x2 y2 dx dy flags slope top bottom left right side0 side1 fsec bsec tag")
record("RLine", rline)
for i in range(len(rline)):
    reader("ln", "RLine", rline, i)

out.append("type Icpt is Data:\n  Icpt{frac: U32, line: Bool, id: U32}\n")

out.append("""type Th is Data:
  TNone{}
  TMo{}
  TDoor{sec: U32, kind: U32, top: U32, speed: U32, dir: U32, wait: U32, count: U32}
  TPlat{sec: U32, speed: U32, low: U32, high: U32, wait: U32, count: U32, status: U32, old: U32, crush: U32, tag: U32, kind: U32}
  TCeil{sec: U32, kind: U32, bottom: U32, top: U32, speed: U32, crush: U32, dir: U32, tag: U32, old: U32}
  TFloor{sec: U32, kind: U32, crush: U32, dir: U32, special: U32, texture: U32, dest: U32, speed: U32}
  TFlicker{sec: U32, count: U32, max: U32, min: U32}
  TFlash{sec: U32, count: U32, max: U32, min: U32, maxtime: U32, mintime: U32}
  TStrobe{sec: U32, count: U32, min: U32, max: U32, dark: U32, bright: U32}
  TGlow{sec: U32, min: U32, max: U32, dir: U32}
  TDead{}
""")

out.append("type P2 is Data:\n  P2{a: U32, b: U32}\n")

out.append("type Anim is Data:\n  Anim{tex: Bool, ids: List<&2, U32>, base: U32, speed: U32}\n")

tm = fields("thing flags x y top bottom left right floorz ceilz dropoff floatok ceilline spechit:List<&2,U32> mo "
            "best second bestline secondline xmove ymove crush nofit trx try trdx trdy ins:List<&2,Icpt> otop obottom orange olow ok "
            "sz tops bots t2x t2y range aim shootz shooter ltarget ladmg bspot bsrc bdmg corpse vx vy sx sy sdx sdy nil:List<&2,Tm>")
record("Tm", tm)

mp = fields("lines:T.Vec<RLine> seclines:T.Vec<List<&2,U32>> secbox:T.Vec<U32> bmap:T.Vec<U32> ox oy bw bh "
            "mi:T.Vec<U32> st:T.Vec<U32> tb:V.Tabs anims:List<&2,Anim> switches:T.Vec<U32> nswitch "
            "scrolls:List<&2,U32> tex0:T.Vec<M.Info> flat0:T.Vec<U32> theights:T.Vec<U32> nsec nlines "
            "commercial:Bool episode map things:T.Vec<L.Thing> rndt:T.Vec<U32> skill subsec:T.Vec<U32> xtab:T.Vec<U32> utab:T.Vec<U32> "
            "reject:T.Vec<U32> segline:T.Vec<U32> hud:T.Vec<U32> nil:List<&2,Lvl>")
record("Lvl", mp)

sim = fields("w:R.World mp:Lvl lspec:T.Vec<U32> links:T.Vec<U32> valid:T.Vec<U32> vc ths:T.Vec<Th> tn:T.Vec<U32> "
             "tp:T.Vec<U32> free:List<&2,U32> next pl:T.Vec<U32> time rnd plats:T.Vec<U32> ceils:T.Vec<U32> "
             "buttons:T.Vec<U32> exit tm:Tm kills items secrets halt ret "
             "secv:T.Vec<U32> sndt:T.Vec<U32> sndn:T.Vec<U32> brains:T.Vec<U32> nbrain brainon easy snd:List<&2,U32> tic "
             "mrnd wipe stface stcount stprio stlad stold stpainh stpainc stweap strnd hmsg hcount gs act ui:T.Vec<U32> seen:T.Vec<U32> cp ingame net starts:T.Vec<U32> bodyq:T.Vec<U32> bodyn demo:T.Vec<U32> dpos saves:T.Vec<U32> nil:List<&2,Sim>")
record("Sim", sim)

for i in range(len(tm)):
    reader("tmr", "Tm", tm, i)
    writer("tmr", "Tm", tm, i)
for i in range(len(mp)):
    reader("mpr", "Lvl", mp, i)
for i in range(len(sim)):
    reader("sim", "Sim", sim, i)
    writer("sim", "Sim", sim, i)

for f, t in tm:
    out.append("def tm.%s(+g: Sim) -> %s:\n  tmr.%s(sim.tm(g))\n" % (f, t, f))
    p = "+" if t == "U32" else ""
    out.append("def tm.%s.set(+g: Sim, %sv: %s) -> Sim:\n  sim.tm.set(g, tmr.%s.set(sim.tm(g), v))\n" % (f, p, t, f))
for f, t in mp:
    out.append("def mp.%s(+g: Sim) -> %s:\n  mpr.%s(sim.mp(g))\n" % (f, t, f))

out.append("""def mget(+g: Sim, +m: U32, +f: U32) -> U32:
  R.mo(sim.w(g), m, f)

def mput(+g: Sim, +m: U32, +f: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.mo(sim.w(g), m, f, v))

def pget(+g: Sim, +f: U32) -> U32:
  T.get(U32, sim.pl(g), (sim.cp(g) * 64 + f : U32), 0)

def pput(+g: Sim, +f: U32, +v: U32) -> Sim:
  sim.pl.set(g, T.set(U32, sim.pl(g), (sim.cp(g) * 64 + f : U32), v))

def piget(+g: Sim, +i: U32, +f: U32) -> U32:
  T.get(U32, sim.pl(g), (i * 64 + f : U32), 0)

def piput(+g: Sim, +i: U32, +f: U32, +v: U32) -> Sim:
  sim.pl.set(g, T.set(U32, sim.pl(g), (i * 64 + f : U32), v))

def line(+g: Sim, +l: U32) -> RLine:
  T.get(RLine, mp.lines(g), l, RLine{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65535, 65535, 0, 65535, 0})

def sec(+g: Sim, +s: U32) -> R.RSector:
  R.sector(sim.w(g), s)

def side(+g: Sim, +s: U32) -> R.RSide:
  R.side(sim.w(g), s)
""")

mo = "x y z angle sprite frame flags type radius height momx momy momz floorz ceilz sub state tics health movedir movecount target reaction threshold lastlook tracer snext sprev bnext bprev spawn player".split()
assert len(mo) == 32
for i, n in enumerate(mo):
    out.append("def m.%s(+g: Sim, +m: U32) -> U32:\n  mget(g, m, %d)\n" % (n, i))
    out.append("def m.%s.set(+g: Sim, +m: U32, +v: U32) -> Sim:\n  mput(g, m, %d, v)\n" % (n, i))

pl = ("mo state viewz viewheight dvh bob health armor armortype cards usedown attacker damagecount bonuscount "
      "extralight fixedcm cheats secrets kills items fwd side turn buttons pw0 pw1 pw2 pw3 pw4 pw5 refire ready "
      "pending own0 own1 own2 own3 own4 own5 own6 own7 own8 ammo0 ammo1 ammo2 ammo3 max0 max1 max2 max3 backpack "
      "attackdown message psp0st psp0tics psp0sx psp0sy psp1st psp1tics psp1sx psp1sy onground didsecret").split()
assert len(pl) <= 64
for i, n in enumerate(pl):
    out.append("def p.%s(+g: Sim) -> U32:\n  pget(g, %d)\n" % (n, i))
    out.append("def p.%s.set(+g: Sim, +v: U32) -> Sim:\n  pput(g, %d, v)\n" % (n, i))
    out.append("def pi.%s(+g: Sim, +j: U32) -> U32:\n  piget(g, j, %d)\n" % (n, i))
    out.append("def pi.%s.set(+g: Sim, +j: U32, +v: U32) -> Sim:\n  piput(g, j, %d, v)\n" % (n, i))

rsec = "floor ceil fpic cpic light special tag data things".split()
names = ["x%d" % j for j in range(len(rsec))]
for i, n in enumerate(rsec):
    out.append("def sc.%s(+r: R.RSector) -> U32:\n  match r:\n    case R.RSector{%s}:\n      x%d\n" % (n, ", ".join(names), i))
    new = list(names)
    new[i] = "v"
    out.append("def sc.%s.set(r: R.RSector, +v: U32) -> R.RSector:\n  match r:\n    case R.RSector{%s}:\n      R.RSector{%s}\n" % (n, ", ".join(names), ", ".join(new)))
    out.append("def s.%s(+g: Sim, +s: U32) -> U32:\n  sc.%s(sec(g, s))\n" % (n, n))
    out.append("def s.%s.set(+g: Sim, +s: U32, +v: U32) -> Sim:\n  sim.w.set(g, R.set.sector(sim.w(g), s, sc.%s.set(sec(g, s), v)))\n" % (n, n))

rside = "xoff yoff top bottom mid sector".split()
names = ["x%d" % j for j in range(len(rside))]
for i, n in enumerate(rside):
    out.append("def sdr.%s(+r: R.RSide) -> U32:\n  match r:\n    case R.RSide{%s}:\n      x%d\n" % (n, ", ".join(names), i))
    new = list(names)
    new[i] = "v"
    out.append("def sdr.%s.set(r: R.RSide, +v: U32) -> R.RSide:\n  match r:\n    case R.RSide{%s}:\n      R.RSide{%s}\n" % (n, ", ".join(names), ", ".join(new)))
    out.append("def sd.%s(+g: Sim, +s: U32) -> U32:\n  sdr.%s(side(g, s))\n" % (n, n))
    out.append("def sd.%s.set(+g: Sim, +s: U32, +v: U32) -> Sim:\n  sim.w.set(g, R.set.side(sim.w(g), s, sdr.%s.set(side(g, s), v)))\n" % (n, n))

for i, n in enumerate(rline):
    out.append("def l.%s(+g: Sim, +l: U32) -> U32:\n  ln.%s(line(g, l))\n" % (n[0], n[0]))

open(sys.argv[1], "w").write("\n".join(out))
