import Base
import ./tab.bend as T
import ./level.bend as L
import ./load.bend as D
import ./world.bend as R
import ./render.bend as V
import ./fixed.bend as F
import ./mem.bend as M
import ./tables.bend as X
import ./info.bend as I
import ./state.bend as S
import ./sim.bend as C
import ./mobj.bend as O
import ./spec.bend as E
import ./sprite.bend as P

type BB is Data:
  BB{top: U32, bottom: U32, left: U32, right: U32}

def vx(+v: L.Vertex) -> U32:
  match v:
    case L.Vertex{x, y}:
      (x << 16n : U32)

def vy(+v: L.Vertex) -> U32:
  match v:
    case L.Vertex{x, y}:
      (y << 16n : U32)

def smax(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, F.gt(a, b), a, b)

def smin(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, F.lt(a, b), a, b)

def slope(+dx: U32, +dy: U32) -> U32:
  Bool.pick(U32, U32.is_eq(dx, 0), 1, Bool.pick(U32, U32.is_eq(dy, 0), 0, Bool.pick(U32, F.gt(F.div(dy, dx), 0), 2, 3)))

def rline(+vs: T.Vec<L.Vertex>, +sides: T.Vec<L.Side>, l: L.Line) -> S.RLine:
  match l:
    case L.Line{+a, +b, +fl, sp, +tg, +fr, +bk}:
      +x1 = vx(R.vert(vs, a))
      +y1 = vy(R.vert(vs, a))
      +x2 = vx(R.vert(vs, b))
      +y2 = vy(R.vert(vs, b))
      +dx = (x2 - x1 : U32)
      +dy = (y2 - y1 : U32)
      +bs = Bool.pick(U32, U32.is_eq(bk, 65535), 65535, R.side.sector(sides, bk))
      S.RLine{x1, y1, x2, y2, dx, dy, fl, slope(dx, dy), smax(y1, y2), smin(y1, y2), smin(x1, x2), smax(x1, x2), fr, bk, R.side.sector(sides, fr), bs, tg}

def rlines(n: Nat, +ls: T.Vec<L.Line>, +vs: T.Vec<L.Vertex>, +sides: T.Vec<L.Side>, +i: U32) -> List<&2, S.RLine>:
  match n:
    case 0n:
      []
    case 1n+p:
      rline(vs, sides, R.line(ls, i)) <> rlines(p, ls, vs, sides, (i + 1 : U32))

def nullline() -> S.RLine:
  S.RLine{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65535, 0, 65535, 0}

def special(+l: L.Line) -> U32:
  match l:
    case L.Line{a, b, fl, +sp, tg, fr, bk}:
      sp

def specials(n: Nat, +ls: T.Vec<L.Line>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      special(R.line(ls, i)) <> specials(p, ls, (i + 1 : U32))

def scrollers(n: Nat, +ls: T.Vec<L.Line>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      +rest = scrollers(p, ls, (i + 1 : U32))
      Bool.pick(List<&2, U32>, U32.is_eq(special(R.line(ls, i)), 48), i <> rest, rest)

def push(+v: T.Vec<List<&2, U32>>, +s: U32, +i: U32) -> T.Vec<List<&2, U32>>:
  T.set(List<&2, U32>, v, s, i <> T.get(List<&2, U32>, v, s, []))

def group.line(+v: T.Vec<List<&2, U32>>, +i: U32, +l: S.RLine) -> T.Vec<List<&2, U32>>:
  +f = S.ln.fsec(l)
  +b = S.ln.bsec(l)
  +v1 = push(v, f, i)
  Bool.pick(T.Vec<List<&2, U32>>, Bool.and(U32.is_ne(b, 65535), U32.is_ne(b, f)), push(v1, b, i), v1)

def group(n: Nat, +ls: T.Vec<S.RLine>, +i: U32, +v: T.Vec<List<&2, U32>>) -> T.Vec<List<&2, U32>>:
  match n:
    case 0n:
      v
    case 1n+p:
      group(p, ls, (i - 1 : U32), group.line(v, i, T.get(S.RLine, ls, i, nullline())))

def addbox(+b: BB, +x: U32, +y: U32) -> BB:
  match b:
    case BB{+t, +bo, +l, +r}:
      +nl = F.lt(x, l)
      +nb = F.lt(y, bo)
      BB{Bool.pick(U32, Bool.and(Bool.not(nb), F.gt(y, t)), y, t), Bool.pick(U32, nb, y, bo),
        Bool.pick(U32, nl, x, l), Bool.pick(U32, Bool.and(Bool.not(nl), F.gt(x, r)), x, r)}

def boxof(+ls: T.Vec<S.RLine>, xs: List<&2, U32>, +b: BB) -> BB:
  match xs:
    case +x <> t:
      +l = T.get(S.RLine, ls, x, nullline())
      boxof(ls, t, addbox(addbox(b, S.ln.x1(l), S.ln.y1(l)), S.ln.x2(l), S.ln.y2(l)))
    case []:
      b

def blk.hi(+v: U32, +o: U32, +n: U32) -> U32:
  +k = F.sar((v - o + 2097152 : U32), 23n)
  Bool.pick(U32, F.ge(k, n), (n - 1 : U32), k)

def blk.lo(+v: U32, +o: U32) -> U32:
  +k = F.sar((v - o - 2097152 : U32), 23n)
  Bool.pick(U32, F.lt(k, 0), 0, k)

def blocks(+b: BB, +ox: U32, +oy: U32, +bw: U32, +bh: U32) -> List<&2, U32>:
  match b:
    case BB{+t, +bo, +l, +r}:
      [blk.hi(t, oy, bh), blk.lo(bo, oy), blk.lo(l, ox), blk.hi(r, ox, bw)]

def secboxes(n: Nat, +ls: T.Vec<S.RLine>, +sl: T.Vec<List<&2, U32>>, +ox: U32, +oy: U32, +bw: U32, +bh: U32, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      +b = boxof(ls, T.get(List<&2, U32>, sl, i, []), BB{2147483648, 2147483647, 2147483647, 2147483648})
      List.append(&2, U32, blocks(b, ox, oy, bw, bh), secboxes(p, ls, sl, ox, oy, bw, bh, (i + 1 : U32)))

def subsecs(n: Nat, +w: R.World, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      R.side.of.seg(w, R.sub(w, i)) <> subsecs(p, w, (i + 1 : U32))

def texid(+names: List<&2, String>, xs: List<&2, String>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      R.tex(names, x) <> texid(names, t)
    case []:
      []

def flatid(+fl: List<&2, String>, xs: List<&2, String>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      R.flat(fl, x, 0) <> flatid(fl, t)
    case []:
      []

def tanims(+names: List<&2, String>, xss: List<&2, List<&2, String>>) -> List<&2, S.Anim>:
  match xss:
    case xs <> t:
      S.Anim{True{}, texid(names, xs), 0, 8} <> tanims(names, t)
    case []:
      []

def fanims(+fl: List<&2, String>, xss: List<&2, List<&2, String>>) -> List<&2, S.Anim>:
  match xss:
    case xs <> t:
      S.Anim{False{}, flatid(fl, xs), 0, 8} <> fanims(fl, t)
    case []:
      []

def digit(+s: String, n: Nat) -> U32:
  (P.at(s, n) - 48 : U32)

def episode(+name: String) -> U32:
  Bool.pick(U32, String.starts_with(name, "MAP"), 1, digit(name, 1n))

def mapnum(+name: String) -> U32:
  Bool.pick(U32, String.starts_with(name, "MAP"), (digit(name, 3n) * 10 + digit(name, 4n) : U32), digit(name, 3n))

def tm0() -> S.Tm:
  S.Tm{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4294967295, [], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], 0, 0, 0, 0, 0, []}

def lvl(+lv: L.Level, +t: D.Texs, +w: R.World, +tb: V.Tabs) -> S.Lvl:
  match lv t:
    case L.Level{+name, +th, +li, +si, +ve, se, ss, no, +sc, rj, +bm} D.Texs{+names, ts, sky, +fl, fd, +hs, +ta, +fa, +sw}:
      +nl = T.size(L.Line, li)
      +ns = T.size(L.Sector, sc)
      +ls = T.from_list(S.RLine, rlines(U32.to_nat(nl), li, ve, si, 0))
      +sl = group(U32.to_nat(nl), ls, (nl - 1 : U32), T.new(List<&2, U32>, ns, []))
      +ox = (L.s(T.get(U32, bm, 0, 0)) << 16n : U32)
      +oy = (L.s(T.get(U32, bm, 1, 0)) << 16n : U32)
      +bw = T.get(U32, bm, 2, 0)
      +bh = T.get(U32, bm, 3, 0)
      +swv = T.from_list(U32, texid(names, sw))
      +com = String.starts_with(name, "MAP")
      S.Lvl{ls, sl, T.from_list(U32, secboxes(U32.to_nat(ns), ls, sl, ox, oy, bw, bh, 0)), bm, ox, oy, bw, bh,
        T.from_list(U32, I.mobjinfo()), T.from_list(U32, I.states()), tb,
        List.append(&2, S.Anim, fanims(fl, fa), tanims(names, ta)), swv, T.size(U32, swv), scrollers(U32.to_nat(nl), li, 0),
        R.texs(w), R.flats(w), T.from_list(U32, hs), ns, nl, com, episode(name), mapnum(name), th, X.rndtable(), 2,
        T.from_list(U32, subsecs(U32.to_nat(T.size(L.Sub, R.subs(w))), w, 0)),
        T.from_list(U32, E.crosstab()), T.from_list(U32, E.usetab()), []}

def blank(+lv: L.Level, +w: R.World, +mp: S.Lvl, +pl: T.Vec<U32>, +rnd: U32) -> S.Sim:
  match lv:
    case L.Level{n, th, +li, si, ve, se, ss, no, sc, rj, bm}:
      +nl = T.size(L.Line, li)
      S.Sim{w, mp, T.from_list(U32, specials(U32.to_nat(nl), li, 0)), T.new(U32, (S.mpr.bw(mp) * S.mpr.bh(mp) : U32), 0), T.new(U32, nl, 0), 1,
        T.new(S.Th, C.maxth(), S.TNone{}), T.new(U32, C.maxth(), 0), T.new(U32, C.maxth(), 0), [], 1, pl, 0, rnd,
        T.new(U32, 30, 0), T.new(U32, 30, 0), T.new(U32, 64, 0), 0, tm0(), 0, 0, 0, 0, 0, []}

def start(+g: S.Sim) -> S.Sim:
  +g1 = S.p.secrets.set(S.p.items.set(S.p.kills.set(g, 0), 0), 0)
  E.spawnspecials(O.spawnthings(g1))

def sim(+lv: L.Level, +t: D.Texs, +w: R.World, +tb: V.Tabs, +pl: T.Vec<U32>, +rnd: U32) -> S.Sim:
  start(blank(lv, w, lvl(lv, t, w, tb), pl, rnd))

def newplayer() -> T.Vec<U32>:
  T.set(U32, T.new(U32, 64, 0), 1, 2)
