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
import ./game.bend as O
import ./sprite.bend as P

type BB is Data:
  BB{top: U32, bottom: U32, left: U32, right: U32}

def vx(+v: L.Vertex) -> U32:
  match v:
    case L.Vertex{x, y}:
      x

def vy(+v: L.Vertex) -> U32:
  match v:
    case L.Vertex{x, y}:
      y

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

def rlines.go(n: Nat, +ls: T.Vec<L.Line>, +vs: T.Vec<L.Vertex>, +sides: T.Vec<L.Side>, +i: U32, acc: List<&2, S.RLine>) -> List<&2, S.RLine>:
  match n:
    case 0n:
      List.reverse(&2, S.RLine, acc)
    case 1n+p:
      rlines.go(p, ls, vs, sides, (i + 1 : U32), rline(vs, sides, R.line(ls, i)) <> acc)

def rlines(n: Nat, +ls: T.Vec<L.Line>, +vs: T.Vec<L.Vertex>, +sides: T.Vec<L.Side>, +i: U32) -> List<&2, S.RLine>:
  rlines.go(n, ls, vs, sides, i, [])

def nullline() -> S.RLine:
  S.RLine{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65535, 0, 65535, 0}

def special(+l: L.Line) -> U32:
  match l:
    case L.Line{a, b, fl, +sp, tg, fr, bk}:
      sp

def specials.go(n: Nat, +ls: T.Vec<L.Line>, +i: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      specials.go(p, ls, (i + 1 : U32), special(R.line(ls, i)) <> acc)

def specials(n: Nat, +ls: T.Vec<L.Line>, +i: U32) -> List<&2, U32>:
  specials.go(n, ls, i, [])

def scrollers.go(n: Nat, +ls: T.Vec<L.Line>, +i: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      scrollers.go(p, ls, (i + 1 : U32), Bool.pick(List<&2, U32>, U32.is_eq(special(R.line(ls, i)), 48), i <> acc, acc))

def scrollers(n: Nat, +ls: T.Vec<L.Line>, +i: U32) -> List<&2, U32>:
  scrollers.go(n, ls, i, [])

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
      [blk.hi(t, oy, bh), blk.lo(bo, oy), blk.lo(l, ox), blk.hi(r, ox, bw), F.sar((l + r : U32), 1n), F.sar((t + bo : U32), 1n)]

def secboxes.go(n: Nat, +ls: T.Vec<S.RLine>, +sl: T.Vec<List<&2, U32>>, +ox: U32, +oy: U32, +bw: U32, +bh: U32, +i: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      +b = boxof(ls, T.get(List<&2, U32>, sl, i, []), BB{2147483648, 2147483647, 2147483647, 2147483648})
      secboxes.go(p, ls, sl, ox, oy, bw, bh, (i + 1 : U32), T.onto(U32, blocks(b, ox, oy, bw, bh), acc))

def secboxes(n: Nat, +ls: T.Vec<S.RLine>, +sl: T.Vec<List<&2, U32>>, +ox: U32, +oy: U32, +bw: U32, +bh: U32, +i: U32) -> List<&2, U32>:
  secboxes.go(n, ls, sl, ox, oy, bw, bh, i, [])

def subsecs.go(n: Nat, +w: R.World, +i: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      subsecs.go(p, w, (i + 1 : U32), R.side.of.seg(w, R.sub(w, i)) <> acc)

def subsecs(n: Nat, +w: R.World, +i: U32) -> List<&2, U32>:
  subsecs.go(n, w, i, [])

def texid.go(+names: List<&2, String>, xs: List<&2, String>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      texid.go(names, t, R.tex(names, x) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def texid(+names: List<&2, String>, xs: List<&2, String>) -> List<&2, U32>:
  texid.go(names, xs, [])

def flatid.go(+fl: List<&2, String>, xs: List<&2, String>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      flatid.go(fl, t, R.flat(fl, x, 0) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def flatid(+fl: List<&2, String>, xs: List<&2, String>) -> List<&2, U32>:
  flatid.go(fl, xs, [])

def tanims.go(+names: List<&2, String>, xss: List<&2, List<&2, String>>, bs: List<&2, U32>, acc: List<&2, S.Anim>) -> List<&2, S.Anim>:
  match xss bs:
    case xs <> t b <> u:
      tanims.go(names, t, u, S.Anim{True{}, texid(names, xs), b, 8} <> acc)
    case _ _:
      List.reverse(&2, S.Anim, acc)

def tanims(+names: List<&2, String>, xss: List<&2, List<&2, String>>, bs: List<&2, U32>) -> List<&2, S.Anim>:
  tanims.go(names, xss, bs, [])

def fanims.go(+fl: List<&2, String>, xss: List<&2, List<&2, String>>, bs: List<&2, U32>, acc: List<&2, S.Anim>) -> List<&2, S.Anim>:
  match xss bs:
    case xs <> t b <> u:
      fanims.go(fl, t, u, S.Anim{False{}, flatid(fl, xs), b, 8} <> acc)
    case _ _:
      List.reverse(&2, S.Anim, acc)

def fanims(+fl: List<&2, String>, xss: List<&2, List<&2, String>>, bs: List<&2, U32>) -> List<&2, S.Anim>:
  fanims.go(fl, xss, bs, [])

def digit(+s: String, n: Nat) -> U32:
  (P.at(s, n) - 48 : U32)

def episode(+name: String) -> U32:
  Bool.pick(U32, String.starts_with(name, "MAP"), 1, digit(name, 1n))

def mapnum(+name: String) -> U32:
  Bool.pick(U32, String.starts_with(name, "MAP"), (digit(name, 3n) * 10 + digit(name, 4n) : U32), digit(name, 3n))

def tm0() -> S.Tm:
  S.Tm{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4294967295, [], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, []}

def segline(+s: L.Seg) -> U32:
  match s:
    case L.Seg{v1, v2, a, li, sd, of}:
      li

def seglines.go(n: Nat, +se: T.Vec<L.Seg>, +i: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      seglines.go(p, se, (i + 1 : U32), segline(T.get(L.Seg, se, i, L.Seg{0, 0, 0, 0, 0, 0})) <> acc)

def seglines(n: Nat, +se: T.Vec<L.Seg>, +i: U32) -> List<&2, U32>:
  seglines.go(n, se, i, [])

def halve(n: Nat, +st: T.Vec<U32>, +i: U32) -> T.Vec<U32>:
  match n:
    case 0n:
      st
    case 1n+p:
      +a = (i * 7 + 2 : U32)
      halve(p, T.set(U32, st, a, (T.get(U32, st, a, 0) >> 1n : U32)), (i + 1 : U32))

def fast.states(+sk: U32, +st: T.Vec<U32>) -> T.Vec<U32>:
  Bool.pick(T.Vec<U32>, U32.is_eq(sk, 4), halve(13n, st, 477), st)

def fast.info(+sk: U32, +mi: T.Vec<U32>) -> T.Vec<U32>:
  Bool.pick(T.Vec<U32>, U32.is_eq(sk, 4), T.set(U32, T.set(U32, T.set(U32, mi, 383, 1310720), 751, 1310720), 728, 1310720), mi)

def lvl(+lv: L.Level, +t: D.Texs, +w: R.World, +tb: V.Tabs, +hud: T.Vec<U32>, +sk: U32) -> S.Lvl:
  match lv t:
    case L.Level{+name, +th, +li, +si, +ve, +se, ss, no, +sc, +rj, +bm} D.Texs{+names, ts, sky, +fl, fd, +hs, +ta, +fa, +sw, +tbs, +fbs, +gt, +gf}:
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
        fast.info(sk, T.from_list(U32, I.mobjinfo())), fast.states(sk, T.from_list(U32, I.states())), tb,
        List.append(&2, S.Anim, fanims(fl, fa, fbs), tanims(names, ta, tbs)), swv, T.size(U32, swv), scrollers(U32.to_nat(nl), li, 0),
        R.texs(w), R.flats(w), T.from_list(U32, hs), ns, nl, com, episode(name), mapnum(name), th, X.rndtable(), sk,
        T.from_list(U32, subsecs(U32.to_nat(T.size(L.Sub, R.subs(w))), w, 0)),
        T.from_list(U32, O.crosstab()), T.from_list(U32, O.usetab()),
        rj, T.from_list(U32, seglines(U32.to_nat(T.size(L.Seg, se)), se, 0)), hud, T.from_list(U32, gt), T.from_list(U32, gf), []}

def skynum(+lv: L.Level, +sky: U32) -> U32:
  match lv:
    case L.Level{+n, th, li, si, ve, se, ss, no, sc, rj, bm}:
      +map = mapnum(n)
      Bool.pick(U32, U32.is_ne(sky, 0), sky, Bool.pick(U32, String.starts_with(n, "MAP"), Bool.pick(U32, U32.is_lt(map, 12), 1, Bool.pick(U32, U32.is_lt(map, 21), 2, 3)), episode(n)))

type Bx is Data:
  Bx{x0: U32, y0: U32, x1: U32, y1: U32}

def amb.one(+b: Bx, +v: L.Vertex) -> Bx:
  match b v:
    case Bx{+a, +c, +e, +f} L.Vertex{+x, +y}:
      +px = x
      +py = y
      Bx{Bool.pick(U32, F.lt(px, a), px, a), Bool.pick(U32, F.lt(py, c), py, c),
        Bool.pick(U32, Bool.and(Bool.not(F.lt(px, a)), F.gt(px, e)), px, e), Bool.pick(U32, Bool.and(Bool.not(F.lt(py, c)), F.gt(py, f)), py, f)}

def amb(n: Nat, +vs: T.Vec<L.Vertex>, +i: U32, +b: Bx) -> Bx:
  match n:
    case 0n:
      b
    case 1n+p:
      amb(p, vs, (i + 1 : U32), amb.one(b, T.get(L.Vertex, vs, i, L.Vertex{0, 0})))

def sets(xs: List<&2, U32>, +v: T.Vec<U32>) -> T.Vec<U32>:
  match xs:
    case +i <> +x <> t:
      sets(t, T.set(U32, v, i, x))
    case _:
      v

def ui0(+sky: U32, +b: Bx) -> T.Vec<U32>:
  match b:
    case Bx{+x0, +y0, +x1, +y1}:
      +a = F.div(20971520, (x1 - x0 : U32))
      +c = F.div(11010048, (y1 - y0 : U32))
      sets([99, sky, 91, x0, 92, y0, 93, x1, 94, y1, 95, Bool.pick(U32, F.lt(a, c), a, c), 96, F.div(11010048, 2097152),
        103, 10, 111, 5, 112, 7, 113, 8, 114, 8, 126, 4294967295, 132, 2, 141, 1, 156, 13107, 164, 65536, 165, 65536], T.new(U32, 256, 0))

def blank(+lv: L.Level, +w: R.World, +mp: S.Lvl, +pl: T.Vec<U32>, +rnd: U32, +mrnd: U32, +wipe: U32, +sky: U32, +cv: T.Vec<U32>) -> S.Sim:
  match lv:
    case L.Level{n, th, +li, si, ve, se, ss, no, +sc, rj, bm}:
      +nl = T.size(L.Line, li)
      +ns = T.size(L.Sector, sc)
      S.Sim{w, mp, T.from_list(U32, specials(U32.to_nat(nl), li, 0)), T.new(U32, (S.mpr.bw(mp) * S.mpr.bh(mp) : U32), 0), T.new(U32, nl, 0), 1,
        T.new(S.Th, C.maxth(), S.TNone{}), T.new(U32, C.maxth(), 0), T.new(U32, C.maxth(), 0), [], 1, pl, 0, rnd,
        T.new(U32, 30, 0), T.new(U32, 30, 0), T.new(U32, 64, 0), 0, tm0(), 0, 0, 0, 0, 0,
        T.new(U32, ns, 0), T.new(U32, ns, 0), T.new(U32, ns, 0), T.new(U32, 32, 0), 0, 0, 0, [], T.get(U32, cv, 10, 0),
        mrnd, wipe, 0, T.get(U32, cv, 5, 0), T.get(U32, cv, 6, 0), T.get(U32, cv, 7, 4294967295), 4294967295, T.get(U32, cv, 8, 4294967295), T.get(U32, cv, 9, 0), 0, 0, 0, 0, 0, 0, ui0(sky, amb(U32.to_nat(T.size(L.Vertex, ve)), ve, 0, Bx{2147483647, 2147483647, 2147483649, 2147483649})), T.new(U32, nl, 0),
        0, T.get(U32, cv, 11, 1), T.get(U32, cv, 12, 0), T.new(U32, 12, 0), T.new(U32, 32, 0), 0, T.new(U32, 1, 128), 0, T.new(U32, 176, 0), []}

def pstart(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +g1 = S.pi.secrets.set(S.pi.items.set(S.pi.kills.set(g, i, 0), i, 0), i, 0)
      +g2 = C.when(Bool.and(C.ingame(g1, i), U32.is_eq(S.pi.state(g1, i), 1)), g1, +h => S.pi.state.set(h, i, 2))
      pstart(p, g2, (i + 1 : U32))

def start(+g: S.Sim) -> S.Sim:
  O.spawnspecials(O.spawnthings(pstart(4n, g, 0)))

def sim(+lv: L.Level, +t: D.Texs, +w: R.World, +tb: V.Tabs, +hud: T.Vec<U32>, +pl: T.Vec<U32>, +cv: T.Vec<U32>) -> S.Sim:
  start(blank(lv, w, lvl(lv, t, w, tb, hud, T.get(U32, cv, 1, 2)), pl, T.get(U32, cv, 0, 0), T.get(U32, cv, 2, 0), T.get(U32, cv, 3, 2), skynum(lv, T.get(U32, cv, 4, 0)), cv))

def newplayer() -> T.Vec<U32>:
  T.set(U32, T.set(U32, T.set(U32, T.set(U32, T.new(U32, 256, 0), 1, 2), 65, 2), 129, 2), 193, 2)
