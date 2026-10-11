import Base
import ./tab.bend as T
import ./state.bend as S
import ./world.bend as R
import ./sim.bend as C
import ./geo.bend as G
import ./game.bend as O
import ./level.bend as L
import ./mem.bend as M
import ./fixed.bend as F

def version() -> List<&2, U32>:
  [118, 101, 114, 115, 105, 111, 110, 32, 49, 48, 57, 0, 0, 0, 0, 0]

def b4(+v: U32) -> List<&2, U32>:
  [(v .&. 255 : U32), ((v >> 8n) .&. 255 : U32), ((v >> 16n) .&. 255 : U32), (v >> 24n : U32)]

def b2(+v: U32) -> List<&2, U32>:
  [(v .&. 255 : U32), ((v >> 8n) .&. 255 : U32)]

def ws(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      List.append(&2, U32, b4(x), ws(t))
    case []:
      []

def hs(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      List.append(&2, U32, b2(x), hs(t))
    case []:
      []

def zeros(n: Nat) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      0 <> zeros(p)

def padn(+pos: U32) -> U32:
  ((4 - (pos .&. 3)) .&. 3 : U32)

def pad(+pos: U32) -> List<&2, U32>:
  zeros(U32.to_nat(padn(pos)))

def len(+xs: List<&2, U32>) -> U32:
  U32.from_nat(List.length(&2, U32, xs))

def sar16(+v: U32) -> U32:
  F.sar(v, 16n)

def gtex(+g: S.Sim, +t: U32) -> U32:
  T.get(U32, S.mp.gtex(g), t, 0)

def gflat(+g: S.Sim, +f: U32) -> U32:
  +fl = S.mp.gflat(g)
  T.get(U32, fl, Bool.pick(U32, U32.is_eq(f, M.sky()), (T.size(U32, fl) - 1 : U32), f), 0)

def find(n: Nat, +v: T.Vec<U32>, +x: U32, +i: U32, +z: U32) -> U32:
  match n:
    case 0n:
      z
    case 1n+p:
      Bool.pick(U32, U32.is_eq(T.get(U32, v, i, 4294967295), x), i, find(p, v, x, (i + 1 : U32), z))

def ltex(+g: S.Sim, +t: U32) -> U32:
  +v = S.mp.gtex(g)
  Bool.pick(U32, U32.is_eq(t, 0), 0, find(U32.to_nat(T.size(U32, v)), v, t, 1, 0))

def lflat(+g: S.Sim, +f: U32) -> U32:
  +v = S.mp.gflat(g)
  +n = (T.size(U32, v) - 1 : U32)
  Bool.pick(U32, U32.is_eq(f, T.get(U32, v, n, 4294967295)), M.sky(), find(U32.to_nat(n), v, f, 0, 0))

def header(+g: S.Sim, +desc: List<&2, U32>) -> List<&2, U32>:
  +t = S.sim.time(g)
  +ig = S.sim.ingame(g)
  List.append(&2, U32, List.take(&2, U32, List.append(&2, U32, desc, zeros(24n)), 24n),
    List.append(&2, U32, version(),
      [S.mp.skill(g), S.mp.episode(g), S.mp.map(g), (ig .&. 1 : U32), ((ig >> 1n) .&. 1 : U32), ((ig >> 2n) .&. 1 : U32), ((ig >> 3n) .&. 1 : U32),
        ((t >> 16n) .&. 255 : U32), ((t >> 8n) .&. 255 : U32), (t .&. 255 : U32)]))

def pf(+g: S.Sim, +i: U32, +f: U32) -> U32:
  S.piget(g, i, f)

def pfs(n: Nat, +g: S.Sim, +i: U32, +f: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      pf(g, i, f) <> pfs(p, g, i, (f + 1 : U32))

def cardbits(n: Nat, +c: U32, +k: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      ((c >> U32.to_nat(k)) .&. 1 : U32) <> cardbits(p, c, (k + 1 : U32))

def player(+g: S.Sim, +i: U32) -> List<&2, U32>:
  +cmd : List<&2, U32> = [(pf(g, i, 20) .&. 255 : U32), (pf(g, i, 21) .&. 255 : U32), (pf(g, i, 22) .&. 255 : U32), ((pf(g, i, 22) >> 8n) .&. 255 : U32), 0, 0, 0, (pf(g, i, 23) .&. 255 : U32)]
  +a = ws([0, pf(g, i, 1)])
  +b = ws(List.append(&2, U32, pfs(7n, g, i, 2), List.append(&2, U32, pfs(6n, g, i, 24), List.append(&2, U32, cardbits(6n, pf(g, i, 9), 0), [pf(g, i, 50), 0, 0, 0, 0, pf(g, i, 31), pf(g, i, 32)]))))
  +c = ws(List.append(&2, U32, pfs(9n, g, i, 33), List.append(&2, U32, pfs(8n, g, i, 42),
    [pf(g, i, 51), pf(g, i, 10), pf(g, i, 16), pf(g, i, 30), pf(g, i, 18), pf(g, i, 19), pf(g, i, 17), 0, pf(g, i, 12), pf(g, i, 13), 0, pf(g, i, 14), pf(g, i, 15), 0])))
  +d = ws(List.append(&2, U32, pfs(8n, g, i, 53), [pf(g, i, 62)]))
  List.append(&2, U32, a, List.append(&2, U32, cmd, List.append(&2, U32, b, List.append(&2, U32, c, d))))

def players(n: Nat, +g: S.Sim, +i: U32, +pos: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      +on = C.ingame(g, i)
      +rec = Bool.pick(List<&2, U32>, on, List.append(&2, U32, pad(pos), player(g, i)), [])
      List.append(&2, U32, rec, players(p, g, (i + 1 : U32), (pos + len(rec) : U32)))

def sector(+g: S.Sim, +s: U32) -> List<&2, U32>:
  hs([sar16(S.s.floor(g, s)), sar16(S.s.ceil(g, s)), gflat(g, S.s.fpic(g, s)), gflat(g, S.s.cpic(g, s)), S.s.light(g, s), S.s.special(g, s), S.s.tag(g, s)])

def sectors(n: Nat, +g: S.Sim, +s: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      List.append(&2, U32, sector(g, s), sectors(p, g, (s + 1 : U32)))

def side(+g: S.Sim, +d: U32) -> List<&2, U32>:
  Bool.pick(List<&2, U32>, U32.is_eq(d, 65535), [],
    hs([sar16(S.sd.xoff(g, d)), sar16(S.sd.yoff(g, d)), gtex(g, S.sd.top(g, d)), gtex(g, S.sd.bottom(g, d)), gtex(g, S.sd.mid(g, d))]))

def lflags(+g: S.Sim, +l: U32) -> U32:
  (S.ln.flags(S.line(g, l)) .|. Bool.pick(U32, U32.is_ne(T.get(U32, S.sim.seen(g), l, 0), 0), 256, 0) : U32)

def line(+g: S.Sim, +l: U32) -> List<&2, U32>:
  +ln = S.line(g, l)
  List.append(&2, U32, hs([lflags(g, l), C.lspec(g, l), S.ln.tag(ln)]), List.append(&2, U32, side(g, S.ln.side0(ln)), side(g, S.ln.side1(ln))))

def lines(n: Nat, +g: S.Sim, +l: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      List.append(&2, U32, line(g, l), lines(p, g, (l + 1 : U32)))

def world(+g: S.Sim) -> List<&2, U32>:
  List.append(&2, U32, sectors(U32.to_nat(S.mp.nsec(g)), g, 0), lines(U32.to_nat(S.mp.nlines(g)), g, 0))

def mthing.of(+t: L.Thing) -> List<&2, U32>:
  match t:
    case L.Thing{+x, +y, +a, +k, +o}:
      hs([x, y, a, k, o])

def mthing(+g: S.Sim, +i: U32) -> List<&2, U32>:
  Bool.pick(List<&2, U32>, U32.is_eq(i, 0), zeros(10n), mthing.of(T.get(L.Thing, S.mp.things(g), (i - 1 : U32), L.Thing{0, 0, 0, 0, 0})))

def mobj(+g: S.Sim, +m: U32) -> List<&2, U32>:
  +a = ws([0, 0, 0, S.m.x(g, m), S.m.y(g, m), S.m.z(g, m), 0, 0, S.m.angle(g, m), S.m.sprite(g, m), S.m.frame(g, m), 0, 0, 0,
    S.m.floorz(g, m), S.m.ceilz(g, m), S.m.radius(g, m), S.m.height(g, m), S.m.momx(g, m), S.m.momy(g, m), S.m.momz(g, m), 0,
    S.m.type(g, m), 0, S.m.tics(g, m), S.m.state(g, m), S.m.flags(g, m), S.m.health(g, m), S.m.movedir(g, m), S.m.movecount(g, m), 0,
    S.m.reaction(g, m), S.m.threshold(g, m), S.m.player(g, m), S.m.lastlook(g, m)])
  List.append(&2, U32, a, List.append(&2, U32, mthing(g, S.m.spawn(g, m)), b4(0)))

def rec(+k: U32, +pos: U32, +body: List<&2, U32>) -> List<&2, U32>:
  k <> List.append(&2, U32, pad((pos + 1 : U32)), body)

def th.mobj(+g: S.Sim, +id: U32, +pos: U32, t: S.Th) -> List<&2, U32>:
  match t:
    case S.TMo{}:
      rec(1, pos, mobj(g, id))
    case _:
      []

def th.special(+g: S.Sim, +pos: U32, t: S.Th) -> List<&2, U32>:
  match t:
    case S.TCeil{+sec, +kind, +bottom, +top, +speed, +crush, +dir, +tag, +old}:
      rec(0, pos, ws([0, 0, Bool.pick(U32, U32.is_eq(dir, 0), 0, 1), kind, sec, bottom, top, speed, crush, dir, tag, old]))
    case S.TDoor{+sec, +kind, +top, +speed, +dir, +wait, +count}:
      rec(1, pos, ws([0, 0, 1, kind, sec, top, speed, dir, wait, count]))
    case S.TFloor{+sec, +kind, +crush, +dir, +special, +texture, +dest, +speed}:
      rec(2, pos, List.append(&2, U32, ws([0, 0, 1, kind, crush, sec, dir, special]), List.append(&2, U32, b2(gflat(g, texture)), ws([dest, speed]))))
    case S.TPlat{+sec, +speed, +low, +high, +wait, +count, +status, +old, +crush, +tag, +kind}:
      Bool.pick(List<&2, U32>, U32.is_eq(status, 3), [], rec(3, pos, ws([0, 0, 1, sec, speed, low, high, wait, count, status, old, crush, tag, kind])))
    case S.TFlash{+sec, +count, +max, +min, +maxtime, +mintime}:
      rec(4, pos, ws([0, 0, 1, sec, count, max, min, maxtime, mintime]))
    case S.TStrobe{+sec, +count, +min, +max, +dark, +bright}:
      rec(5, pos, ws([0, 0, 1, sec, count, min, max, dark, bright]))
    case S.TGlow{+sec, +min, +max, +dir}:
      rec(6, pos, ws([0, 0, 1, sec, min, max, dir]))
    case _:
      []

def mobjs?(n: Nat, +g: S.Sim, +id: U32, +pos: U32) -> List<&2, U32>:
  match n:
    case 0n:
      [0]
    case 1n+p:
      +r = th.mobj(g, id, pos, C.th(g, id))
      +nx = C.tnext(g, id)
      List.append(&2, U32, r, mobjs.more(U32.is_eq(nx, 0), p, g, nx, (pos + len(r) : U32)))

def mobjs.more?(stop: Bool, n: Nat, +g: S.Sim, +id: U32, +pos: U32) -> List<&2, U32>:
  match stop:
    case True{}:
      [0]
    case False{}:
      mobjs(n, g, id, pos)

def specials.more?(stop: Bool, n: Nat, +g: S.Sim, +id: U32, +pos: U32) -> List<&2, U32>:
  match stop:
    case True{}:
      [7]
    case False{}:
      specials(n, g, id, pos)

def specials?(n: Nat, +g: S.Sim, +id: U32, +pos: U32) -> List<&2, U32>:
  match n:
    case 0n:
      [7]
    case 1n+p:
      +r = th.special(g, pos, C.th(g, id))
      +nx = C.tnext(g, id)
      List.append(&2, U32, r, specials.more(U32.is_eq(nx, 0), p, g, nx, (pos + len(r) : U32)))

def write(+g: S.Sim, +desc: List<&2, U32>) -> List<&2, U32>:
  +h = header(g, desc)
  +pl = players(4n, g, 0, 50)
  +wd = world(g)
  +p0 = (50 + len(pl) + len(wd) : U32)
  +first = C.tnext(g, 0)
  +mo = mobjs.more(U32.is_eq(first, 0), U32.to_nat(C.maxth()), g, first, p0)
  +sp = specials.more(U32.is_eq(first, 0), U32.to_nat(C.maxth()), g, first, (p0 + len(mo) : U32))
  List.append(&2, U32, h, List.append(&2, U32, pl, List.append(&2, U32, wd, List.append(&2, U32, mo, List.append(&2, U32, sp, [29])))))

def r8(+v: T.Vec<U32>, +p: U32) -> U32:
  T.get(U32, v, p, 0)

def r16(+v: T.Vec<U32>, +p: U32) -> U32:
  L.s((r8(v, p) .|. (r8(v, (p + 1 : U32)) << 8n) : U32))

def r32(+v: T.Vec<U32>, +p: U32) -> U32:
  (r8(v, p) .|. (r8(v, (p + 1 : U32)) << 8n) .|. (r8(v, (p + 2 : U32)) << 16n) .|. (r8(v, (p + 3 : U32)) << 24n) : U32)

def same(n: Nat, +v: T.Vec<U32>, +p: U32, xs: List<&2, U32>) -> Bool:
  match n xs:
    case 1n+q +x <> t:
      Bool.and(U32.is_eq(r8(v, p), x), same(q, v, (p + 1 : U32), t))
    case _ _:
      True{}

def ok(+v: T.Vec<U32>) -> Bool:
  Bool.and(U32.is_ge(T.size(U32, v), 51), same(16n, v, 24, version()))

def desc.go(n: Nat, +v: T.Vec<U32>, +p: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+q:
      r8(v, p) <> desc.go(q, v, (p + 1 : U32))

def desc(+v: T.Vec<U32>) -> List<&2, U32>:
  desc.go(24n, v, 0)

def skill(+v: T.Vec<U32>) -> U32:
  r8(v, 40)

def episode(+v: T.Vec<U32>) -> U32:
  r8(v, 41)

def map(+v: T.Vec<U32>) -> U32:
  r8(v, 42)

def ingame(+v: T.Vec<U32>) -> U32:
  (C.b2u(U32.is_ne(r8(v, 43), 0)) .|. (C.b2u(U32.is_ne(r8(v, 44), 0)) << 1n) .|. (C.b2u(U32.is_ne(r8(v, 45), 0)) << 2n) .|. (C.b2u(U32.is_ne(r8(v, 46), 0)) << 3n) : U32)

def time(+v: T.Vec<U32>) -> U32:
  ((r8(v, 47) << 16n) .|. (r8(v, 48) << 8n) .|. r8(v, 49) : U32)

def pset(+g: S.Sim, +i: U32, +f: U32, +x: U32) -> S.Sim:
  S.piput(g, i, f, x)

def psets(n: Nat, +g: S.Sim, +i: U32, +f: U32, +v: T.Vec<U32>, +p: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+q:
      psets(q, pset(g, i, f, r32(v, p)), i, (f + 1 : U32), v, (p + 4 : U32))

def cards(n: Nat, +v: T.Vec<U32>, +p: U32, +k: U32, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+q:
      cards(q, v, (p + 4 : U32), (k + 1 : U32), (acc .|. (C.b2u(U32.is_ne(r32(v, p), 0)) << U32.to_nat(k)) : U32))

def player.read(+g: S.Sim, +i: U32, +v: T.Vec<U32>, +p: U32) -> S.Sim:
  +g1 = pset(pset(g, i, 0, 0), i, 1, r32(v, (p + 4 : U32)))
  +g2 = pset(pset(pset(pset(g1, i, 20, 0), i, 21, 0), i, 22, 0), i, 23, 0)
  +g3 = psets(6n, psets(7n, g2, i, 2, v, (p + 16 : U32)), i, 24, v, (p + 44 : U32))
  +g4 = pset(pset(pset(pset(g3, i, 9, cards(6n, v, (p + 68 : U32), 0, 0)), i, 50, r32(v, (p + 92 : U32))), i, 31, r32(v, (p + 112 : U32))), i, 32, r32(v, (p + 116 : U32)))
  +g5 = psets(8n, psets(9n, g4, i, 33, v, (p + 120 : U32)), i, 42, v, (p + 156 : U32))
  +q = (p + 188 : U32)
  +g6 = pset(pset(pset(pset(g5, i, 51, r32(v, q)), i, 10, r32(v, (q + 4 : U32))), i, 16, r32(v, (q + 8 : U32))), i, 30, r32(v, (q + 12 : U32)))
  +g7 = pset(pset(pset(pset(g6, i, 18, r32(v, (q + 16 : U32))), i, 19, r32(v, (q + 20 : U32))), i, 17, r32(v, (q + 24 : U32))), i, 52, 0)
  +g8 = pset(pset(pset(g7, i, 12, r32(v, (q + 32 : U32))), i, 13, r32(v, (q + 36 : U32))), i, 11, 0)
  +g9 = pset(pset(g8, i, 14, r32(v, (q + 44 : U32))), i, 15, r32(v, (q + 48 : U32)))
  pset(psets(8n, g9, i, 53, v, (q + 56 : U32)), i, 62, r32(v, (q + 88 : U32)))

def players.read(n: Nat, +g: S.Sim, +i: U32, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  match n:
    case 0n:
      (g, p)
    case 1n+q:
      +on = C.ingame(g, i)
      +at = (p + padn(p) : U32)
      players.read(q, C.when(on, g, +h => player.read(h, i, v, at)), (i + 1 : U32), v, Bool.pick(U32, on, (at + 280 : U32), p))

def sector.read(+g: S.Sim, +s: U32, +v: T.Vec<U32>, +p: U32) -> S.Sim:
  +g1 = S.s.ceil.set(S.s.floor.set(g, s, (r16(v, p) << 16n : U32)), s, (r16(v, (p + 2 : U32)) << 16n : U32))
  +g2 = S.s.cpic.set(S.s.fpic.set(g1, s, lflat(g1, (r16(v, (p + 4 : U32)) .&. 65535 : U32))), s, lflat(g1, (r16(v, (p + 6 : U32)) .&. 65535 : U32)))
  +g3 = S.s.tag.set(S.s.special.set(S.s.light.set(g2, s, (r16(v, (p + 8 : U32)) .&. 65535 : U32)), s, (r16(v, (p + 10 : U32)) .&. 65535 : U32)), s, (r16(v, (p + 12 : U32)) .&. 65535 : U32))
  S.s.things.set(S.s.data.set(g3, s, 0), s, 0)

def sectors.read(n: Nat, +g: S.Sim, +s: U32, +v: T.Vec<U32>, +p: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+q:
      sectors.read(q, sector.read(g, s, v, p), (s + 1 : U32), v, (p + 14 : U32))

def side.read(+g: S.Sim, +d: U32, +v: T.Vec<U32>, +p: U32) -> S.Sim:
  +g1 = S.sd.yoff.set(S.sd.xoff.set(g, d, (r16(v, p) << 16n : U32)), d, (r16(v, (p + 2 : U32)) << 16n : U32))
  S.sd.mid.set(S.sd.bottom.set(S.sd.top.set(g1, d, ltex(g1, (r16(v, (p + 4 : U32)) .&. 65535 : U32))), d, ltex(g1, (r16(v, (p + 6 : U32)) .&. 65535 : U32))), d, ltex(g1, (r16(v, (p + 8 : U32)) .&. 65535 : U32)))

def line.read(+g: S.Sim, +l: U32, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  +ln = S.line(g, l)
  +s0 = S.ln.side0(ln)
  +s1 = S.ln.side1(ln)
  +g1 = S.sim.seen.set(C.lspec.set(g, l, (r16(v, (p + 2 : U32)) .&. 65535 : U32)), T.set(U32, S.sim.seen(g), l, C.b2u(C.has(r16(v, p), 256))))
  +q = (p + 6 : U32)
  +g2 = C.when(U32.is_ne(s0, 65535), g1, +h => side.read(h, s0, v, q))
  +q2 = Bool.pick(U32, U32.is_ne(s0, 65535), (q + 10 : U32), q)
  +g3 = C.when(U32.is_ne(s1, 65535), g2, +h => side.read(h, s1, v, q2))
  (g3, Bool.pick(U32, U32.is_ne(s1, 65535), (q2 + 10 : U32), q2))

def lines.read?(n: Nat, +g: S.Sim, +l: U32, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  match n:
    case 0n:
      (g, p)
    case 1n+q:
      lines.next(q, line.read(g, l, v, p), (l + 1 : U32), v)

def lines.next(n: Nat, r: S.Sim & U32, +l: U32, +v: T.Vec<U32>) -> S.Sim & U32:
  (+g, +p) = r
  lines.read(n, g, l, v, p)

def spawn.is(+t: L.Thing, +x: U32, +y: U32, +a: U32, +k: U32, +o: U32) -> Bool:
  match t:
    case L.Thing{+tx, +ty, +ta, +tk, +to}:
      Bool.and(Bool.and(U32.is_eq(tx, x), U32.is_eq(ty, y)), Bool.and(Bool.and(U32.is_eq(ta, a), U32.is_eq(tk, k)), U32.is_eq(to, o)))

def spawnof(n: Nat, +g: S.Sim, +i: U32, +x: U32, +y: U32, +a: U32, +k: U32, +o: U32) -> U32:
  match n:
    case 0n:
      0
    case 1n+q:
      Bool.pick(U32, spawn.is(T.get(L.Thing, S.mp.things(g), i, L.Thing{0, 0, 0, 0, 0}), x, y, a, k, o), (i + 1 : U32), spawnof(q, g, (i + 1 : U32), x, y, a, k, o))

def spawn.read(+g: S.Sim, +v: T.Vec<U32>, +p: U32) -> U32:
  +k = r16(v, (p + 6 : U32))
  Bool.pick(U32, Bool.and(U32.is_eq(k, 0), U32.is_eq(r16(v, p), 0)), 0,
    spawnof(U32.to_nat(T.size(L.Thing, S.mp.things(g))), g, 0, r16(v, p), r16(v, (p + 2 : U32)), r16(v, (p + 4 : U32)), k, r16(v, (p + 8 : U32))))

def mobj.read(+g: S.Sim, +v: T.Vec<U32>, +p: U32) -> S.Sim:
  +m = C.newid(g)
  +g0 = O.zero(32n, g, m, 0)
  +g1 = S.m.angle.set(S.m.z.set(S.m.y.set(S.m.x.set(g0, m, r32(v, (p + 12 : U32))), m, r32(v, (p + 16 : U32))), m, r32(v, (p + 20 : U32))), m, r32(v, (p + 32 : U32)))
  +g2 = S.m.radius.set(S.m.frame.set(S.m.sprite.set(g1, m, r32(v, (p + 36 : U32))), m, r32(v, (p + 40 : U32))), m, r32(v, (p + 64 : U32)))
  +g3 = S.m.momz.set(S.m.momy.set(S.m.momx.set(S.m.height.set(g2, m, r32(v, (p + 68 : U32))), m, r32(v, (p + 72 : U32))), m, r32(v, (p + 76 : U32))), m, r32(v, (p + 80 : U32)))
  +g4 = S.m.flags.set(S.m.state.set(S.m.tics.set(S.m.type.set(g3, m, r32(v, (p + 88 : U32))), m, r32(v, (p + 96 : U32))), m, r32(v, (p + 100 : U32))), m, r32(v, (p + 104 : U32)))
  +g5 = S.m.movecount.set(S.m.movedir.set(S.m.health.set(g4, m, r32(v, (p + 108 : U32))), m, r32(v, (p + 112 : U32))), m, r32(v, (p + 116 : U32)))
  +g6 = S.m.lastlook.set(S.m.player.set(S.m.threshold.set(S.m.reaction.set(g5, m, r32(v, (p + 124 : U32))), m, r32(v, (p + 128 : U32))), m, r32(v, (p + 132 : U32))), m, r32(v, (p + 136 : U32)))
  +g7 = G.set(S.m.spawn.set(g6, m, spawn.read(g6, v, (p + 140 : U32))), m)
  +s = C.secof(g7, S.m.sub(g7, m))
  +g8 = C.add(S.m.ceilz.set(S.m.floorz.set(g7, m, S.s.floor(g7, s)), m, S.s.ceil(g7, s)), S.TMo{})
  +pl = S.m.player(g8, m)
  C.when(U32.is_ne(pl, 0), g8, +h => S.pi.mo.set(h, (pl - 1 : U32), m))

def mobjs.step?(n: Nat, +g: S.Sim, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  +at = (p + 1 + padn((p + 1 : U32)) : U32)
  mobjs.read(n, mobj.read(g, v, at), v, (at + 154 : U32))

def mobjs.read?(n: Nat, +g: S.Sim, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  match n:
    case 0n:
      (g, p)
    case 1n+q:
      mobjs.cls(U32.is_eq(r8(v, p), 1), q, g, v, p)

def mobjs.cls?(more: Bool, n: Nat, +g: S.Sim, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  match more:
    case True{}:
      mobjs.step(n, g, v, p)
    case False{}:
      (g, (p + 1 : U32))

def owned(+g: S.Sim, +s: U32, t: S.Th) -> S.Sim:
  +id = C.newid(g)
  S.s.data.set(C.add(g, t), s, id)

def special.ceil(+g: S.Sim, +v: T.Vec<U32>, +q: U32) -> S.Sim:
  +id = C.newid(g)
  +s = r32(v, (q + 4 : U32))
  O.addceil(owned(g, s, S.TCeil{s, r32(v, q), r32(v, (q + 8 : U32)), r32(v, (q + 12 : U32)), r32(v, (q + 16 : U32)), r32(v, (q + 20 : U32)), r32(v, (q + 24 : U32)), r32(v, (q + 28 : U32)), r32(v, (q + 32 : U32))}), id)

def special.door(+g: S.Sim, +v: T.Vec<U32>, +q: U32) -> S.Sim:
  +s = r32(v, (q + 4 : U32))
  owned(g, s, S.TDoor{s, r32(v, q), r32(v, (q + 8 : U32)), r32(v, (q + 12 : U32)), r32(v, (q + 16 : U32)), r32(v, (q + 20 : U32)), r32(v, (q + 24 : U32))})

def special.floor(+g: S.Sim, +v: T.Vec<U32>, +q: U32) -> S.Sim:
  +s = r32(v, (q + 8 : U32))
  owned(g, s, S.TFloor{s, r32(v, q), r32(v, (q + 4 : U32)), r32(v, (q + 12 : U32)), r32(v, (q + 16 : U32)), lflat(g, (r16(v, (q + 20 : U32)) .&. 65535 : U32)), r32(v, (q + 22 : U32)), r32(v, (q + 26 : U32))})

def special.plat(+g: S.Sim, +v: T.Vec<U32>, +q: U32) -> S.Sim:
  +id = C.newid(g)
  +s = r32(v, q)
  O.addplat(owned(g, s, S.TPlat{s, r32(v, (q + 4 : U32)), r32(v, (q + 8 : U32)), r32(v, (q + 12 : U32)), r32(v, (q + 16 : U32)), r32(v, (q + 20 : U32)), r32(v, (q + 24 : U32)), r32(v, (q + 28 : U32)), r32(v, (q + 32 : U32)), r32(v, (q + 36 : U32)), r32(v, (q + 40 : U32))}), id)

def special.light(+k: U32, +g: S.Sim, +v: T.Vec<U32>, +q: U32) -> S.Sim:
  +s = r32(v, q)
  Bool.pick(S.Sim, U32.is_eq(k, 4), C.add(g, S.TFlash{s, r32(v, (q + 4 : U32)), r32(v, (q + 8 : U32)), r32(v, (q + 12 : U32)), r32(v, (q + 16 : U32)), r32(v, (q + 20 : U32))}),
    Bool.pick(S.Sim, U32.is_eq(k, 5), C.add(g, S.TStrobe{s, r32(v, (q + 4 : U32)), r32(v, (q + 8 : U32)), r32(v, (q + 12 : U32)), r32(v, (q + 16 : U32)), r32(v, (q + 20 : U32))}),
      C.add(g, S.TGlow{s, r32(v, (q + 4 : U32)), r32(v, (q + 8 : U32)), r32(v, (q + 12 : U32))})))

def special.size(+k: U32) -> U32:
  Bool.pick(U32, U32.is_eq(k, 0), 48, Bool.pick(U32, U32.is_eq(k, 1), 40, Bool.pick(U32, U32.is_eq(k, 2), 42, Bool.pick(U32, U32.is_eq(k, 3), 56, Bool.pick(U32, U32.is_eq(k, 6), 28, 36)))))

def special.one(+k: U32, +g: S.Sim, +v: T.Vec<U32>, +q: U32) -> S.Sim:
  C.br(U32.is_eq(k, 0), g, +h => special.ceil(h, v, q),
    +h => C.br(U32.is_eq(k, 1), h, +a => special.door(a, v, q),
      +a => C.br(U32.is_eq(k, 2), a, +b => special.floor(b, v, q),
        +b => C.br(U32.is_eq(k, 3), b, +c => special.plat(c, v, q), +c => special.light(k, c, v, q)))))

def specials.step?(n: Nat, +k: U32, +g: S.Sim, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  +at = (p + 1 + padn((p + 1 : U32)) : U32)
  specials.read(n, special.one(k, g, v, (at + 12 : U32)), v, (at + special.size(k) : U32))

def specials.cls?(more: Bool, n: Nat, +k: U32, +g: S.Sim, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  match more:
    case True{}:
      specials.step(n, k, g, v, p)
    case False{}:
      (g, (p + 1 : U32))

def specials.read?(n: Nat, +g: S.Sim, +v: T.Vec<U32>, +p: U32) -> S.Sim & U32:
  match n:
    case 0n:
      (g, p)
    case 1n+q:
      specials.cls(U32.is_lt(r8(v, p), 7), q, r8(v, p), g, v, p)

def clear.players(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+q:
      clear.players(q, S.pi.mo.set(g, i, 0), (i + 1 : U32))

def clear(+g: S.Sim) -> S.Sim:
  +w = S.sim.w(g)
  +g1 = S.sim.w.set(g, R.with.mobjs(w, T.new(U32, T.size(U32, R.mobjs(w)), 0)))
  +g2 = S.sim.next.set(S.sim.free.set(S.sim.tp.set(S.sim.tn.set(S.sim.ths.set(g1, T.new(S.Th, C.maxth(), S.TNone{})), T.new(U32, C.maxth(), 0)), T.new(U32, C.maxth(), 0)), []), 1)
  +g3 = S.sim.ceils.set(S.sim.plats.set(S.sim.links.set(g2, T.new(U32, T.size(U32, S.sim.links(g2)), 0)), T.new(U32, 30, 0)), T.new(U32, 30, 0))
  clear.players(4n, S.sim.sndt.set(g3, T.new(U32, T.size(U32, S.sim.sndt(g3)), 0)), 0)

def after.specials(r: S.Sim & U32) -> S.Sim:
  (+g, +p) = r
  g

def after.mobjs(r: S.Sim & U32, +v: T.Vec<U32>) -> S.Sim:
  (+g, +p) = r
  after.specials(specials.read(U32.to_nat(C.maxth()), g, v, p))

def after.world(r: S.Sim & U32, +v: T.Vec<U32>) -> S.Sim:
  (+g, +p) = r
  after.mobjs(mobjs.read(U32.to_nat(C.maxth()), clear(g), v, p), v)

def after.players(r: S.Sim & U32, +v: T.Vec<U32>) -> S.Sim:
  (+g, +p) = r
  +g1 = sectors.read(U32.to_nat(S.mp.nsec(g)), g, 0, v, p)
  after.world(lines.read(U32.to_nat(S.mp.nlines(g1)), g1, 0, v, (p + S.mp.nsec(g1) * 14 : U32)), v)

def read(+g: S.Sim, +v: T.Vec<U32>) -> S.Sim:
  after.players(players.read(4n, S.sim.time.set(g, time(v)), 0, v, 50), v)
