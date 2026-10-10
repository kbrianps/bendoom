import Base
import ./tab.bend as T
import ./world.bend as R
import ./render.bend as V
import ./fixed.bend as F
import ./mem.bend as M
import ./state.bend as S
import ./sim.bend as C
import ./geo.bend as G
import ./mobj.bend as O
import ./hit.bend as H
import ./map.bend as P

def none() -> U32:
  65535

def neg1() -> U32:
  4294967295

def fu() -> U32:
  65536

def vdoorspeed() -> U32:
  131072

def nextsec.of(+l: S.RLine, +s: U32) -> U32:
  Bool.pick(U32, C.has(S.ln.flags(l), 4), Bool.pick(U32, U32.is_eq(S.ln.fsec(l), s), S.ln.bsec(l), S.ln.fsec(l)), none())

def nextsec(+g: S.Sim, +ld: U32, +s: U32) -> U32:
  nextsec.of(S.line(g, ld), s)

def lfold(~f: S.Sim -> U32 -> U32 -> U32 -> U32, +g: S.Sim, +s: U32, xs: List<&2, U32>, +acc: U32) -> U32:
  match xs:
    case +x <> t:
      lfold(~f, g, s, t, f(g, s, acc, x))
    case []:
      acc

def real(+o: U32) -> Bool:
  U32.is_ne(o, none())

def lowfloor.f(+g: S.Sim, +s: U32, +acc: U32, +ld: U32) -> U32:
  +o = nextsec(g, ld, s)
  +v = S.s.floor(g, o)
  Bool.pick(U32, Bool.and(real(o), F.lt(v, acc)), v, acc)

def highfloor.f(+g: S.Sim, +s: U32, +acc: U32, +ld: U32) -> U32:
  +o = nextsec(g, ld, s)
  +v = S.s.floor(g, o)
  Bool.pick(U32, Bool.and(real(o), F.gt(v, acc)), v, acc)

def lowceil.f(+g: S.Sim, +s: U32, +acc: U32, +ld: U32) -> U32:
  +o = nextsec(g, ld, s)
  +v = S.s.ceil(g, o)
  Bool.pick(U32, Bool.and(real(o), F.lt(v, acc)), v, acc)

def highceil.f(+g: S.Sim, +s: U32, +acc: U32, +ld: U32) -> U32:
  +o = nextsec(g, ld, s)
  +v = S.s.ceil(g, o)
  Bool.pick(U32, Bool.and(real(o), F.gt(v, acc)), v, acc)

def minlight.f(+g: S.Sim, +s: U32, +acc: U32, +ld: U32) -> U32:
  +o = nextsec(g, ld, s)
  +v = S.s.light(g, o)
  Bool.pick(U32, Bool.and(real(o), F.lt(v, acc)), v, acc)

def maxlight.f(+g: S.Sim, +s: U32, +acc: U32, +ld: U32) -> U32:
  +o = nextsec(g, ld, s)
  +v = S.s.light(g, o)
  Bool.pick(U32, Bool.and(real(o), F.gt(v, acc)), v, acc)

def lowestfloor(+g: S.Sim, +s: U32) -> U32:
  lfold(~(+a => +b => +c => +d => lowfloor.f(a, b, c, d)), g, s, C.seclines(g, s), S.s.floor(g, s))

def highestfloor(+g: S.Sim, +s: U32) -> U32:
  lfold(~(+a => +b => +c => +d => highfloor.f(a, b, c, d)), g, s, C.seclines(g, s), 4262199296)

def lowestceil(+g: S.Sim, +s: U32) -> U32:
  lfold(~(+a => +b => +c => +d => lowceil.f(a, b, c, d)), g, s, C.seclines(g, s), 2147483647)

def highestceil(+g: S.Sim, +s: U32) -> U32:
  lfold(~(+a => +b => +c => +d => highceil.f(a, b, c, d)), g, s, C.seclines(g, s), 0)

def minlight(+g: S.Sim, +s: U32, +max: U32) -> U32:
  lfold(~(+a => +b => +c => +d => minlight.f(a, b, c, d)), g, s, C.seclines(g, s), max)

def maxlight(+g: S.Sim, +s: U32, +min: U32) -> U32:
  lfold(~(+a => +b => +c => +d => maxlight.f(a, b, c, d)), g, s, C.seclines(g, s), min)

def nexthigh.fin(+cur: U32, +h: U32, +min: U32) -> U32:
  Bool.pick(U32, U32.is_eq(h, 0), cur, min)

def nexthigh.go(+g: S.Sim, +s: U32, xs: List<&2, U32>, +cur: U32, +h: U32, +min: U32) -> U32:
  match xs:
    case +x <> t:
      +o = nextsec(g, x, s)
      +v = S.s.floor(g, o)
      +add = Bool.and(real(o), F.gt(v, cur))
      +h1 = (h + C.b2u(add) : U32)
      +m1 = Bool.pick(U32, add, Bool.pick(U32, Bool.or(U32.is_eq(h, 0), F.lt(v, min)), v, min), min)
      C.pick(U32, U32.is_ge(h1, 20), +u => nexthigh.fin(cur, h1, m1), +u => nexthigh.go(g, s, t, cur, h1, m1))
    case []:
      nexthigh.fin(cur, h, min)

def nexthigh(+g: S.Sim, +s: U32, +cur: U32) -> U32:
  nexthigh.go(g, s, C.seclines(g, s), cur, 0, 0)

def plane(+g: S.Sim, +s: U32, +fc: U32) -> U32:
  Bool.pick(U32, U32.is_eq(fc, 0), S.s.floor(g, s), S.s.ceil(g, s))

def plane.set(+g: S.Sim, +s: U32, +fc: U32, +v: U32) -> S.Sim:
  C.br(U32.is_eq(fc, 0), g, +h => S.s.floor.set(h, s, v), +h => S.s.ceil.set(h, s, v))

def nofit(+g: S.Sim) -> Bool:
  U32.is_ne(S.tm.nofit(g), 0)

def change(+g: S.Sim, +s: U32, +fc: U32, +v: U32, +crush: U32) -> S.Sim:
  P.changesector(plane.set(g, s, fc, v), s, crush)

def mp.past(+g: S.Sim, +s: U32, +fc: U32, +last: U32, +dest: U32, +crush: U32) -> S.Sim:
  +g1 = change(g, s, fc, dest, crush)
  S.sim.ret.set(C.when(nofit(g1), g1, +h => change(h, s, fc, last, crush)), 2)

def mp.step(+g: S.Sim, +s: U32, +fc: U32, +last: U32, +v: U32, +crush: U32, +down: Bool) -> S.Sim:
  +g1 = change(g, s, fc, v, crush)
  +check = Bool.not(Bool.and(U32.is_eq(fc, 1), Bool.not(down)))
  +keep = Bool.and(U32.is_eq(crush, 1), Bool.not(Bool.and(U32.is_eq(fc, 0), down)))
  C.br(Bool.and(check, nofit(g1)), g1,
    +h => S.sim.ret.set(C.when(Bool.not(keep), h, +k => change(k, s, fc, last, crush)), 1),
    +h => S.sim.ret.set(h, 0))

def moveplane(+g: S.Sim, +s: U32, +speed: U32, +dest: U32, +crush: U32, +fc: U32, +dir: U32) -> S.Sim:
  +cur = plane(g, s, fc)
  +down = U32.is_eq(dir, neg1())
  +past = Bool.pick(Bool, down, F.lt((cur - speed : U32), dest), F.gt((cur + speed : U32), dest))
  C.br(past, g, +h => mp.past(h, s, fc, cur, dest, crush),
    +h => mp.step(h, s, fc, cur, Bool.pick(U32, down, (cur - speed : U32), (cur + speed : U32)), crush, down))

def ret(+g: S.Sim) -> U32:
  S.sim.ret(g)

def is.in2(+k: U32, +a: U32, +b: U32) -> Bool:
  Bool.or(U32.is_eq(k, a), U32.is_eq(k, b))

def door.put(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +top: U32, +speed: U32, +dir: U32, +wait: U32, +count: U32) -> S.Sim:
  C.th.set(g, id, S.TDoor{sec, kind, top, speed, dir, wait, count})

def door.end(+g: S.Sim, +id: U32, +sec: U32) -> S.Sim:
  C.remove(S.s.data.set(g, sec, 0), id)

def door.wait0(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +top: U32, +speed: U32, +dir: U32, +wait: U32, +count: U32) -> S.Sim:
  +c = (count - 1 : U32)
  +z = U32.is_eq(c, 0)
  +d = Bool.pick(U32, Bool.and(z, is.in2(kind, 5, 0)), neg1(), Bool.pick(U32, Bool.and(z, U32.is_eq(kind, 1)), 1, dir))
  door.put(g, id, sec, kind, top, speed, d, wait, c)

def door.wait2(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +top: U32, +speed: U32, +dir: U32, +wait: U32, +count: U32) -> S.Sim:
  +c = (count - 1 : U32)
  +go = Bool.and(U32.is_eq(c, 0), U32.is_eq(kind, 4))
  door.put(g, id, sec, Bool.pick(U32, go, 0, kind), top, speed, Bool.pick(U32, go, 1, dir), wait, c)

def door.down.done(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +top: U32, +speed: U32, +dir: U32, +wait: U32, +count: U32) -> S.Sim:
  +r = ret(g)
  C.br(Bool.and(U32.is_eq(r, 2), Bool.or(is.in2(kind, 5, 7), is.in2(kind, 0, 2))), g, +h => door.end(h, id, sec),
    +h => C.when(Bool.and(U32.is_eq(r, 2), U32.is_eq(kind, 1)), h, +k => door.put(k, id, sec, kind, top, speed, 0, wait, 1050)))

def door.down(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +top: U32, +speed: U32, +dir: U32, +wait: U32, +count: U32) -> S.Sim:
  +g1 = moveplane(g, sec, speed, S.s.floor(g, sec), 0, 1, neg1())
  +back = Bool.and(U32.is_eq(ret(g1), 1), Bool.not(is.in2(kind, 7, 2)))
  C.br(back, g1, +h => door.put(h, id, sec, kind, top, speed, 1, wait, count), +h => door.down.done(h, id, sec, kind, top, speed, dir, wait, count))

def door.up(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +top: U32, +speed: U32, +dir: U32, +wait: U32, +count: U32) -> S.Sim:
  +g1 = moveplane(g, sec, speed, top, 0, 1, 1)
  +past = U32.is_eq(ret(g1), 2)
  C.br(Bool.and(past, is.in2(kind, 5, 0)), g1, +h => door.put(h, id, sec, kind, top, speed, 0, wait, wait),
    +h => C.when(Bool.and(past, Bool.or(U32.is_eq(kind, 1), is.in2(kind, 6, 3))), h, +k => door.end(k, id, sec)))

def t.door(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +top: U32, +speed: U32, +dir: U32, +wait: U32, +count: U32) -> S.Sim:
  C.br(U32.is_eq(dir, 0), g, +h => door.wait0(h, id, sec, kind, top, speed, dir, wait, count),
    +h => C.br(U32.is_eq(dir, 2), h, +k => door.wait2(k, id, sec, kind, top, speed, dir, wait, count),
      +k => C.br(U32.is_eq(dir, neg1()), k, +q => door.down(q, id, sec, kind, top, speed, dir, wait, count),
        +q => C.when(U32.is_eq(dir, 1), q, +r => door.up(r, id, sec, kind, top, speed, dir, wait, count)))))

def slot.find(n: Nat, +v: T.Vec<U32>, +x: U32, +i: U32) -> U32:
  match n:
    case 0n:
      none()
    case 1n+p:
      C.pick(U32, U32.is_eq(T.get(U32, v, i, 0), x), +u => i, +u => slot.find(p, v, x, (i + 1 : U32)))

def plat.clear(+g: S.Sim, +k: U32) -> S.Sim:
  S.sim.plats.set(g, T.set(U32, S.sim.plats(g), k, 0))

def plat.remove(+g: S.Sim, +id: U32, +sec: U32) -> S.Sim:
  +k = slot.find(30n, S.sim.plats(g), id, 0)
  C.when(real(k), g, +h => plat.clear(C.remove(S.s.data.set(h, sec, 0), id), k))

def plat.put(+g: S.Sim, +id: U32, +sec: U32, +speed: U32, +low: U32, +high: U32, +wait: U32, +count: U32, +status: U32, +old: U32, +crush: U32, +tag: U32, +kind: U32) -> S.Sim:
  C.th.set(g, id, S.TPlat{sec, speed, low, high, wait, count, status, old, crush, tag, kind})

def plat.up(+g: S.Sim, +id: U32, +sec: U32, +speed: U32, +low: U32, +high: U32, +wait: U32, +count: U32, +status: U32, +old: U32, +crush: U32, +tag: U32, +kind: U32) -> S.Sim:
  +g1 = moveplane(g, sec, speed, high, crush, 0, 1)
  +r = ret(g1)
  C.br(Bool.and(U32.is_eq(r, 1), U32.is_eq(crush, 0)), g1, +h => plat.put(h, id, sec, speed, low, high, wait, wait, 1, old, crush, tag, kind),
    +h => C.when(U32.is_eq(r, 2), h,
      +k => C.br(Bool.or(is.in2(kind, 4, 1), is.in2(kind, 2, 3)), k, +q => plat.remove(q, id, sec),
        +q => plat.put(q, id, sec, speed, low, high, wait, wait, 2, old, crush, tag, kind))))

def plat.down(+g: S.Sim, +id: U32, +sec: U32, +speed: U32, +low: U32, +high: U32, +wait: U32, +count: U32, +status: U32, +old: U32, +crush: U32, +tag: U32, +kind: U32) -> S.Sim:
  +g1 = moveplane(g, sec, speed, low, 0, 0, neg1())
  C.when(U32.is_eq(ret(g1), 2), g1, +h => plat.put(h, id, sec, speed, low, high, wait, wait, 2, old, crush, tag, kind))

def plat.wait(+g: S.Sim, +id: U32, +sec: U32, +speed: U32, +low: U32, +high: U32, +wait: U32, +count: U32, +status: U32, +old: U32, +crush: U32, +tag: U32, +kind: U32) -> S.Sim:
  +c = (count - 1 : U32)
  +st = Bool.pick(U32, U32.is_eq(c, 0), Bool.pick(U32, U32.is_eq(S.s.floor(g, sec), low), 0, 1), status)
  plat.put(g, id, sec, speed, low, high, wait, c, st, old, crush, tag, kind)

def t.plat(+g: S.Sim, +id: U32, +sec: U32, +speed: U32, +low: U32, +high: U32, +wait: U32, +count: U32, +status: U32, +old: U32, +crush: U32, +tag: U32, +kind: U32) -> S.Sim:
  C.br(U32.is_eq(status, 0), g, +h => plat.up(h, id, sec, speed, low, high, wait, count, status, old, crush, tag, kind),
    +h => C.br(U32.is_eq(status, 1), h, +k => plat.down(k, id, sec, speed, low, high, wait, count, status, old, crush, tag, kind),
      +k => C.when(U32.is_eq(status, 2), k, +q => plat.wait(q, id, sec, speed, low, high, wait, count, status, old, crush, tag, kind))))

def ceil.clear(+g: S.Sim, +k: U32) -> S.Sim:
  S.sim.ceils.set(g, T.set(U32, S.sim.ceils(g), k, 0))

def ceil.remove(+g: S.Sim, +id: U32, +sec: U32) -> S.Sim:
  +k = slot.find(30n, S.sim.ceils(g), id, 0)
  C.when(real(k), g, +h => ceil.clear(C.remove(S.s.data.set(h, sec, 0), id), k))

def ceil.put(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +bottom: U32, +top: U32, +speed: U32, +crush: U32, +dir: U32, +tag: U32, +old: U32) -> S.Sim:
  C.th.set(g, id, S.TCeil{sec, kind, bottom, top, speed, crush, dir, tag, old})

def ceil.up(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +bottom: U32, +top: U32, +speed: U32, +crush: U32, +dir: U32, +tag: U32, +old: U32) -> S.Sim:
  +g1 = moveplane(g, sec, speed, top, 0, 1, 1)
  +past = U32.is_eq(ret(g1), 2)
  C.br(Bool.and(past, U32.is_eq(kind, 1)), g1, +h => ceil.remove(h, id, sec),
    +h => C.when(Bool.and(past, Bool.or(U32.is_eq(kind, 5), is.in2(kind, 4, 3))), h, +k => ceil.put(k, id, sec, kind, bottom, top, speed, crush, neg1(), tag, old)))

def ceil.down(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +bottom: U32, +top: U32, +speed: U32, +crush: U32, +dir: U32, +tag: U32, +old: U32) -> S.Sim:
  +g1 = moveplane(g, sec, speed, bottom, crush, 1, neg1())
  +r = ret(g1)
  C.br(U32.is_eq(r, 2), g1,
    +h => C.br(is.in2(kind, 5, 3), h, +k => ceil.put(k, id, sec, kind, bottom, top, fu(), crush, 1, tag, old),
      +k => C.br(U32.is_eq(kind, 4), k, +q => ceil.put(q, id, sec, kind, bottom, top, speed, crush, 1, tag, old),
        +q => C.when(is.in2(kind, 2, 0), q, +z => ceil.remove(z, id, sec)))),
    +h => C.when(Bool.and(U32.is_eq(r, 1), Bool.or(is.in2(kind, 5, 3), U32.is_eq(kind, 2))), h, +k => ceil.put(k, id, sec, kind, bottom, top, 8192, crush, dir, tag, old)))

def t.ceil(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +bottom: U32, +top: U32, +speed: U32, +crush: U32, +dir: U32, +tag: U32, +old: U32) -> S.Sim:
  C.br(U32.is_eq(dir, 1), g, +h => ceil.up(h, id, sec, kind, bottom, top, speed, crush, dir, tag, old),
    +h => C.when(U32.is_eq(dir, neg1()), h, +k => ceil.down(k, id, sec, kind, bottom, top, speed, crush, dir, tag, old)))

def floor.done(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +dir: U32, +special: U32, +texture: U32) -> S.Sim:
  +g1 = S.s.data.set(g, sec, 0)
  +chg = Bool.or(Bool.and(U32.is_eq(dir, 1), U32.is_eq(kind, 11)), Bool.and(U32.is_eq(dir, neg1()), U32.is_eq(kind, 6)))
  +g2 = C.when(chg, g1, +h => S.s.fpic.set(S.s.special.set(h, sec, special), sec, texture))
  C.remove(g2, id)

def t.floor(+g: S.Sim, +id: U32, +sec: U32, +kind: U32, +crush: U32, +dir: U32, +special: U32, +texture: U32, +dest: U32, +speed: U32) -> S.Sim:
  +g1 = moveplane(g, sec, speed, dest, crush, 0, dir)
  C.when(U32.is_eq(ret(g1), 2), g1, +h => floor.done(h, id, sec, kind, dir, special, texture))

def flicker.go(+g: S.Sim, +id: U32, +sec: U32, +max: U32, +min: U32) -> S.Sim:
  +amount = ((C.rnd(g) .&. 3) * 16 : U32)
  +g1 = C.rnd.next(g)
  +l = Bool.pick(U32, F.lt((S.s.light(g1, sec) - amount : U32), min), min, (max - amount : U32))
  C.th.set(S.s.light.set(g1, sec, l), id, S.TFlicker{sec, 4, max, min})

def t.flicker(+g: S.Sim, +id: U32, +sec: U32, +count: U32, +max: U32, +min: U32) -> S.Sim:
  +c = (count - 1 : U32)
  C.br(U32.is_ne(c, 0), g, +h => C.th.set(h, id, S.TFlicker{sec, c, max, min}), +h => flicker.go(h, id, sec, max, min))

def flash.go(+g: S.Sim, +id: U32, +sec: U32, +max: U32, +min: U32, +maxtime: U32, +mintime: U32) -> S.Sim:
  +bright = U32.is_eq(S.s.light(g, sec), max)
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +c = ((r .&. Bool.pick(U32, bright, mintime, maxtime)) + 1 : U32)
  C.th.set(S.s.light.set(g1, sec, Bool.pick(U32, bright, min, max)), id, S.TFlash{sec, c, max, min, maxtime, mintime})

def t.flash(+g: S.Sim, +id: U32, +sec: U32, +count: U32, +max: U32, +min: U32, +maxtime: U32, +mintime: U32) -> S.Sim:
  +c = (count - 1 : U32)
  C.br(U32.is_ne(c, 0), g, +h => C.th.set(h, id, S.TFlash{sec, c, max, min, maxtime, mintime}), +h => flash.go(h, id, sec, max, min, maxtime, mintime))

def t.strobe(+g: S.Sim, +id: U32, +sec: U32, +count: U32, +min: U32, +max: U32, +dark: U32, +bright: U32) -> S.Sim:
  +c = (count - 1 : U32)
  +low = U32.is_eq(S.s.light(g, sec), min)
  +g1 = C.when(U32.is_eq(c, 0), g, +h => S.s.light.set(h, sec, Bool.pick(U32, low, max, min)))
  C.th.set(g1, id, S.TStrobe{sec, Bool.pick(U32, U32.is_eq(c, 0), Bool.pick(U32, low, bright, dark), c), min, max, dark, bright})

def t.glow(+g: S.Sim, +id: U32, +sec: U32, +min: U32, +max: U32, +dir: U32) -> S.Sim:
  +l = S.s.light(g, sec)
  +dn = (l - 8 : U32)
  +up = (l + 8 : U32)
  +bdn = F.le(dn, min)
  +bup = F.ge(up, max)
  C.br(U32.is_eq(dir, neg1()), g,
    +h => C.th.set(S.s.light.set(h, sec, Bool.pick(U32, bdn, l, dn)), id, S.TGlow{sec, min, max, Bool.pick(U32, bdn, 1, dir)}),
    +h => C.when(U32.is_eq(dir, 1), h, +k => C.th.set(S.s.light.set(k, sec, Bool.pick(U32, bup, l, up)), id, S.TGlow{sec, min, max, Bool.pick(U32, bup, neg1(), dir)})))

def think(+g: S.Sim, +id: U32, t: S.Th) -> S.Sim:
  match t:
    case S.TDoor{+sec, +kind, +top, +speed, +dir, +wait, +count}:
      t.door(g, id, sec, kind, top, speed, dir, wait, count)
    case S.TPlat{+sec, +speed, +low, +high, +wait, +count, +status, +old, +crush, +tag, +kind}:
      t.plat(g, id, sec, speed, low, high, wait, count, status, old, crush, tag, kind)
    case S.TCeil{+sec, +kind, +bottom, +top, +speed, +crush, +dir, +tag, +old}:
      t.ceil(g, id, sec, kind, bottom, top, speed, crush, dir, tag, old)
    case S.TFloor{+sec, +kind, +crush, +dir, +special, +texture, +dest, +speed}:
      t.floor(g, id, sec, kind, crush, dir, special, texture, dest, speed)
    case S.TFlicker{+sec, +count, +max, +min}:
      t.flicker(g, id, sec, count, max, min)
    case S.TFlash{+sec, +count, +max, +min, +maxtime, +mintime}:
      t.flash(g, id, sec, count, max, min, maxtime, mintime)
    case S.TStrobe{+sec, +count, +min, +max, +dark, +bright}:
      t.strobe(g, id, sec, count, min, max, dark, bright)
    case S.TGlow{+sec, +min, +max, +dir}:
      t.glow(g, id, sec, min, max, dir)
    case _:
      g

def evloop(~f: S.Sim -> U32 -> U32 -> U32 -> U32 -> S.Sim, n: Nat, more: Bool, +g: S.Sim, +tag: U32, +a: U32, +b: U32, +c: U32, +i: U32, +rtn: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +hit = Bool.and(U32.is_eq(S.s.tag(g, i), tag), U32.is_eq(S.s.data(g, i), 0))
      +g1 = C.when(hit, g, +h => f(h, i, a, b, c))
      evloop(~f, p, U32.is_lt((i + 1 : U32), S.mp.nsec(g1)), g1, tag, a, b, c, (i + 1 : U32), (rtn .|. C.b2u(hit) : U32))
    case _ _:
      S.sim.ret.set(g, rtn)

def ev(~f: S.Sim -> U32 -> U32 -> U32 -> U32 -> S.Sim, +g: S.Sim, +ld: U32, +b: U32, +c: U32) -> S.Sim:
  +n = S.mp.nsec(g)
  evloop(~f, U32.to_nat(n), U32.is_ne(n, 0), g, S.l.tag(g, ld), ld, b, c, 0, 0)

def door.one(+g: S.Sim, +s: U32, +ld: U32, +kind: U32, +u: U32) -> S.Sim:
  +id = C.newid(g)
  +top0 = (lowestceil(g, s) - 262144 : U32)
  +close = is.in2(kind, 2, 7)
  +blaze = Bool.or(is.in2(kind, 5, 6), U32.is_eq(kind, 7))
  +top = Bool.pick(U32, U32.is_eq(kind, 1), S.s.ceil(g, s), top0)
  +dir = Bool.pick(U32, Bool.or(close, U32.is_eq(kind, 1)), neg1(), 1)
  +speed = Bool.pick(U32, blaze, 524288, vdoorspeed())
  S.s.data.set(C.add(g, S.TDoor{s, kind, top, speed, dir, 150, 0}), s, id)

def door(+g: S.Sim, +ld: U32, +kind: U32) -> S.Sim:
  ev(~(+a => +b => +c => +d => +e => door.one(a, b, c, d, e)), g, ld, kind, 0)

def lock.need(+sp: U32) -> U32:
  Bool.pick(U32, is.in2(sp, 99, 133), 9, Bool.pick(U32, is.in2(sp, 134, 135), 36, Bool.pick(U32, is.in2(sp, 136, 137), 18, 0)))

def lock.msg(+need: U32) -> U32:
  Bool.pick(U32, U32.is_eq(need, 9), 1, Bool.pick(U32, U32.is_eq(need, 36), 2, 3))

def lockeddoor(+g: S.Sim, +ld: U32, +kind: U32, +m: U32) -> S.Sim:
  +pl = U32.is_ne(S.m.player(g, m), 0)
  +need = lock.need(C.lspec(g, ld))
  +ok = Bool.or(U32.is_eq(need, 0), C.has(S.p.cards(g), need))
  C.br(Bool.and(pl, ok), g, +h => door(h, ld, kind),
    +h => S.sim.ret.set(C.when(pl, h, +k => S.p.message.set(k, lock.msg(need))), 0))

def vdoor.need(+sp: U32) -> U32:
  Bool.pick(U32, is.in2(sp, 26, 32), 9, Bool.pick(U32, is.in2(sp, 27, 34), 18, Bool.pick(U32, is.in2(sp, 28, 33), 36, 0)))

def vdoor.msg(+need: U32) -> U32:
  Bool.pick(U32, U32.is_eq(need, 9), 4, Bool.pick(U32, U32.is_eq(need, 18), 5, 6))

def vdoor.again(+g: S.Sim, +id: U32, +pl: Bool, t: S.Th) -> S.Sim:
  match t:
    case S.TDoor{+sec, +kind, +top, +speed, +dir, +wait, +count}:
      C.br(U32.is_eq(dir, neg1()), g, +h => door.put(h, id, sec, kind, top, speed, 1, wait, count),
        +h => C.when(pl, h, +k => door.put(k, id, sec, kind, top, speed, neg1(), wait, count)))
    case _:
      g

def vdoor.new(+g: S.Sim, +ld: U32, +sec: U32, +sp: U32) -> S.Sim:
  +id = C.newid(g)
  +open = Bool.or(Bool.or(is.in2(sp, 31, 32), is.in2(sp, 33, 34)), U32.is_eq(sp, 118))
  +blaze = is.in2(sp, 117, 118)
  +kind = Bool.pick(U32, U32.is_eq(sp, 117), 5, Bool.pick(U32, U32.is_eq(sp, 118), 6, Bool.pick(U32, open, 3, 0)))
  +g1 = C.when(open, g, +h => C.lspec.set(h, ld, 0))
  S.s.data.set(C.add(g1, S.TDoor{sec, kind, (lowestceil(g1, sec) - 262144 : U32), Bool.pick(U32, blaze, 524288, vdoorspeed()), 1, 150, 0}), sec, id)

def vdoor.go(+g: S.Sim, +ld: U32, +m: U32, +pl: Bool, +sp: U32) -> S.Sim:
  +sec = S.sd.sector(g, S.l.side1(g, ld))
  +d = S.s.data(g, sec)
  +raise = Bool.or(Bool.or(is.in2(sp, 1, 26), is.in2(sp, 27, 28)), U32.is_eq(sp, 117))
  C.br(Bool.and(U32.is_ne(d, 0), raise), g, +h => vdoor.again(h, d, pl, C.th(h, d)), +h => vdoor.new(h, ld, sec, sp))

def vdoor(+g: S.Sim, +ld: U32, +m: U32) -> S.Sim:
  +pl = U32.is_ne(S.m.player(g, m), 0)
  +sp = C.lspec(g, ld)
  +need = vdoor.need(sp)
  +ok = Bool.or(U32.is_eq(need, 0), Bool.and(pl, C.has(S.p.cards(g), need)))
  C.br(ok, g, +h => vdoor.go(h, ld, m, pl, sp), +h => C.when(pl, h, +k => S.p.message.set(k, vdoor.msg(need))))

def addplat(+g: S.Sim, +id: U32) -> S.Sim:
  +k = slot.find(30n, S.sim.plats(g), 0, 0)
  C.when(real(k), g, +h => S.sim.plats.set(h, T.set(U32, S.sim.plats(h), k, id)))

def addceil(+g: S.Sim, +id: U32) -> S.Sim:
  +k = slot.find(30n, S.sim.ceils(g), 0, 0)
  C.when(real(k), g, +h => S.sim.ceils.set(h, T.set(U32, S.sim.ceils(h), k, id)))

def slots(~f: S.Sim -> U32 -> U32 -> S.Sim, n: Nat, +g: S.Sim, +v: T.Vec<U32>, +k: U32, +tag: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +id = T.get(U32, v, k, 0)
      slots(~f, p, C.when(U32.is_ne(id, 0), g, +h => f(h, id, tag)), v, (k + 1 : U32), tag)

def stasis.of(+g: S.Sim, +id: U32, +tg: U32, t: S.Th) -> S.Sim:
  match t:
    case S.TPlat{+sec, +speed, +low, +high, +wait, +count, +status, +old, +crush, +tag, +kind}:
      C.when(Bool.and(U32.is_eq(tag, tg), U32.is_eq(status, 3)), g, +h => plat.put(h, id, sec, speed, low, high, wait, count, old, old, crush, tag, kind))
    case _:
      g

def stopplat.of(+g: S.Sim, +id: U32, +tg: U32, t: S.Th) -> S.Sim:
  match t:
    case S.TPlat{+sec, +speed, +low, +high, +wait, +count, +status, +old, +crush, +tag, +kind}:
      C.when(Bool.and(U32.is_eq(tag, tg), U32.is_ne(status, 3)), g, +h => plat.put(h, id, sec, speed, low, high, wait, count, 3, status, crush, tag, kind))
    case _:
      g

def stasis(+g: S.Sim, +tag: U32) -> S.Sim:
  slots(~(+h => +i => +t => stasis.of(h, i, t, C.th(h, i))), 30n, g, S.sim.plats(g), 0, tag)

def stopplat(+g: S.Sim, +ld: U32) -> S.Sim:
  slots(~(+h => +i => +t => stopplat.of(h, i, t, C.th(h, i))), 30n, g, S.sim.plats(g), 0, S.l.tag(g, ld))

def plat.one(+g: S.Sim, +s: U32, +ld: U32, +kind: U32, +amount: U32) -> S.Sim:
  +id = C.newid(g)
  +fl = S.s.floor(g, s)
  +r = C.rnd(g)
  +g1 = C.when(U32.is_eq(kind, 0), g, +h => C.rnd.next(h))
  +change = is.in2(kind, 2, 3)
  +low0 = lowestfloor(g1, s)
  +low = Bool.pick(U32, F.gt(low0, fl), fl, low0)
  +high0 = highestfloor(g1, s)
  +high = Bool.pick(U32, U32.is_eq(kind, 3), nexthigh(g1, s, fl), Bool.pick(U32, U32.is_eq(kind, 2), (fl + amount * 65536 : U32), Bool.pick(U32, U32.is_eq(kind, 0), Bool.pick(U32, F.lt(high0, fl), fl, high0), fl)))
  +speed = Bool.pick(U32, change, 32768, Bool.pick(U32, U32.is_eq(kind, 1), 262144, Bool.pick(U32, U32.is_eq(kind, 4), 524288, 65536)))
  +wait = Bool.pick(U32, change, 0, 105)
  +status = Bool.pick(U32, change, 0, Bool.pick(U32, U32.is_eq(kind, 0), (r .&. 1 : U32), 1))
  +g2 = C.when(change, g1, +h => S.s.fpic.set(h, s, S.s.fpic(h, S.sd.sector(h, S.l.side0(h, ld)))))
  +g3 = C.when(U32.is_eq(kind, 3), g2, +h => S.s.special.set(h, s, 0))
  +g4 = C.add(g3, S.TPlat{s, speed, Bool.pick(U32, change, 0, low), high, wait, 0, status, 0, 0, S.l.tag(g3, ld), kind})
  addplat(S.s.data.set(g4, s, id), id)

def plat(+g: S.Sim, +ld: U32, +kind: U32, +amount: U32) -> S.Sim:
  +g1 = C.when(U32.is_eq(kind, 0), g, +h => stasis(h, S.l.tag(h, ld)))
  ev(~(+a => +b => +c => +d => +e => plat.one(a, b, c, d, e)), g1, ld, kind, amount)

def texmin.f(+g: S.Sim, +s: U32, +acc: U32, +ld: U32) -> U32:
  +l = S.line(g, ld)
  +t0 = C.theight(g, S.sd.bottom(g, S.ln.side0(l)))
  +t1 = C.theight(g, S.sd.bottom(g, S.ln.side1(l)))
  +a1 = Bool.pick(U32, F.lt(t0, acc), t0, acc)
  +a2 = Bool.pick(U32, F.lt(t1, a1), t1, a1)
  Bool.pick(U32, C.has(S.ln.flags(l), 4), a2, acc)

def texmin(+g: S.Sim, +s: U32) -> U32:
  lfold(~(+a => +b => +c => +d => texmin.f(a, b, c, d)), g, s, C.seclines(g, s), 2147483647)

def lowerchange.find(+g: S.Sim, +s: U32, +dest: U32, xs: List<&2, U32>, +z: S.P2) -> S.P2:
  match xs:
    case +x <> t:
      +l = S.line(g, x)
      +o = Bool.pick(U32, U32.is_eq(S.ln.fsec(l), s), S.ln.bsec(l), S.ln.fsec(l))
      +hit = Bool.and(C.has(S.ln.flags(l), 4), U32.is_eq(S.s.floor(g, o), dest))
      C.pick(S.P2, hit, +u => S.P2{S.s.fpic(g, o), S.s.special(g, o)}, +u => lowerchange.find(g, s, dest, t, z))
    case []:
      z

def p2.a(+p: S.P2) -> U32:
  match p:
    case S.P2{a, b}:
      a

def p2.b(+p: S.P2) -> U32:
  match p:
    case S.P2{a, b}:
      b

def floor.one(+g: S.Sim, +s: U32, +ld: U32, +kind: U32, +u: U32) -> S.Sim:
  +id = C.newid(g)
  +fl = S.s.floor(g, s)
  +cl = S.s.ceil(g, s)
  +down = Bool.or(is.in2(kind, 0, 1), is.in2(kind, 2, 6))
  +hf = highestfloor(g, s)
  +lf = lowestfloor(g, s)
  +lc0 = lowestceil(g, s)
  +lc = Bool.pick(U32, F.gt(lc0, cl), cl, lc0)
  +nh = nexthigh(g, s, fl)
  +dest = Bool.pick(U32, U32.is_eq(kind, 0), hf,
    Bool.pick(U32, is.in2(kind, 1, 6), lf,
      Bool.pick(U32, U32.is_eq(kind, 2), Bool.pick(U32, U32.is_ne(hf, fl), (hf + 524288 : U32), hf),
        Bool.pick(U32, U32.is_eq(kind, 3), lc,
          Bool.pick(U32, U32.is_eq(kind, 9), (lc - 524288 : U32),
            Bool.pick(U32, is.in2(kind, 10, 4), nh,
              Bool.pick(U32, is.in2(kind, 7, 8), (fl + 1572864 : U32),
                Bool.pick(U32, U32.is_eq(kind, 12), (fl + 33554432 : U32),
                  Bool.pick(U32, U32.is_eq(kind, 5), (fl + texmin(g, s) : U32), fl)))))))))
  +speed = Bool.pick(U32, is.in2(kind, 2, 10), 262144, 65536)
  +chg = Bool.pick(S.P2, U32.is_eq(kind, 6), lowerchange.find(g, s, dest, C.seclines(g, s), S.P2{S.s.fpic(g, s), 0}), S.P2{0, 0})
  +front = S.l.fsec(g, ld)
  +g1 = C.when(U32.is_eq(kind, 8), g, +h => S.s.special.set(S.s.fpic.set(h, s, S.s.fpic(h, front)), s, S.s.special(h, front)))
  +g2 = C.add(g1, S.TFloor{s, kind, C.b2u(U32.is_eq(kind, 9)), Bool.pick(U32, down, neg1(), 1), p2.b(chg), p2.a(chg), dest, speed})
  S.s.data.set(g2, s, id)

def floor(+g: S.Sim, +ld: U32, +kind: U32) -> S.Sim:
  ev(~(+a => +b => +c => +d => +e => floor.one(a, b, c, d, e)), g, ld, kind, 0)

def findtag(n: Nat, +g: S.Sim, +tag: U32, +i: U32) -> U32:
  match n:
    case 0n:
      none()
    case 1n+p:
      C.pick(U32, U32.is_ge(i, S.mp.nsec(g)), +u => none(),
        +u => C.pick(U32, U32.is_eq(S.s.tag(g, i), tag), +v => i, +v => findtag(p, g, tag, (i + 1 : U32))))

def stair.scan(+g: S.Sim, +s: U32, xs: List<&2, U32>, +height: U32, +tex: U32, +size: U32) -> S.P2:
  match xs:
    case +x <> t:
      +l = S.line(g, x)
      +b = S.ln.bsec(l)
      +ok = Bool.and(Bool.and(C.has(S.ln.flags(l), 4), U32.is_eq(S.ln.fsec(l), s)), Bool.and(real(b), U32.is_eq(S.s.fpic(g, b), tex)))
      +h1 = Bool.pick(U32, ok, (height + size : U32), height)
      C.pick(S.P2, Bool.and(ok, U32.is_eq(S.s.data(g, b), 0)), +u => S.P2{b, h1}, +u => stair.scan(g, s, t, h1, tex, size))
    case []:
      S.P2{none(), height}

def stair.add(+g: S.Sim, +s: U32, +height: U32, +speed: U32) -> S.Sim:
  +id = C.newid(g)
  S.s.data.set(C.add(g, S.TFloor{s, 99, 0, 1, 0, 0, height, speed}), s, id)

def stair.climb(n: Nat, +g: S.Sim, +s: U32, +height: U32, +tex: U32, +speed: U32, +size: U32) -> S.Sim:
  match n:
    case 0n:
      S.sim.ret.set(g, s)
    case 1n+p:
      +r = stair.scan(g, s, C.seclines(g, s), height, tex, size)
      +ns = p2.a(r)
      +nh = p2.b(r)
      C.br(real(ns), g, +h => stair.climb(p, stair.add(h, ns, nh, speed), ns, nh, tex, speed, size), +h => S.sim.ret.set(h, s))

def stair.build(+g: S.Sim, +s: U32, +kind: U32) -> S.Sim:
  +speed = Bool.pick(U32, U32.is_eq(kind, 0), 16384, 262144)
  +size = Bool.pick(U32, U32.is_eq(kind, 0), 524288, 1048576)
  +height = (S.s.floor(g, s) + size : U32)
  stair.climb(4096n, stair.add(g, s, height, speed), s, height, S.s.fpic(g, s), speed, size)

def stairs.go(n: Nat, found: Bool, busy: Bool, +g: S.Sim, +tag: U32, +kind: U32, +s: U32, +rtn: U32) -> S.Sim:
  match n found busy:
    case 1n+p True{} True{}:
      +s2 = findtag(65536n, g, tag, (s + 1 : U32))
      stairs.go(p, real(s2), U32.is_ne(S.s.data(g, s2), 0), g, tag, kind, s2, rtn)
    case 1n+p True{} False{}:
      +g2 = stair.build(g, s, kind)
      +s2 = findtag(65536n, g2, tag, (S.sim.ret(g2) + 1 : U32))
      stairs.go(p, real(s2), U32.is_ne(S.s.data(g2, s2), 0), g2, tag, kind, s2, 1)
    case _ _ _:
      S.sim.ret.set(g, rtn)

def stairs(+g: S.Sim, +ld: U32, +kind: U32) -> S.Sim:
  +tag = S.l.tag(g, ld)
  +s = findtag(65536n, g, tag, 0)
  stairs.go(4096n, real(s), U32.is_ne(S.s.data(g, s), 0), g, tag, kind, s, 0)

def donut.find(+g: S.Sim, +s1: U32, xs: List<&2, U32>) -> U32:
  match xs:
    case +x <> t:
      C.pick(U32, U32.is_ne(S.l.bsec(g, x), s1), +u => x, +u => donut.find(g, s1, t))
    case []:
      none()

def donut.add(+g: S.Sim, +s1: U32, +s2: U32, +s3: U32) -> S.Sim:
  +id2 = C.newid(g)
  +g1 = S.s.data.set(C.add(g, S.TFloor{s2, 11, 0, 1, 0, S.s.fpic(g, s3), S.s.floor(g, s3), 32768}), s2, id2)
  +id1 = C.newid(g1)
  S.s.data.set(C.add(g1, S.TFloor{s1, 0, 0, neg1(), 0, 0, S.s.floor(g1, s3), 32768}), s1, id1)

def donut.one(+g: S.Sim, +s1: U32, +ld: U32, +b: U32, +c: U32) -> S.Sim:
  +s2 = nextsec(g, C.first(C.seclines(g, s1), 0), s1)
  +x = donut.find(g, s1, C.seclines(g, s2))
  C.when(real(x), g, +h => donut.add(h, s1, s2, S.l.bsec(h, x)))

def donut(+g: S.Sim, +ld: U32) -> S.Sim:
  ev(~(+a => +b => +c => +d => +e => donut.one(a, b, c, d, e)), g, ld, 0, 0)

def ceil.one(+g: S.Sim, +s: U32, +ld: U32, +kind: U32, +u: U32) -> S.Sim:
  +id = C.newid(g)
  +fl = S.s.floor(g, s)
  +crush = C.b2u(Bool.or(is.in2(kind, 4, 5), U32.is_eq(kind, 3)))
  +bottom = Bool.pick(U32, U32.is_eq(kind, 0), fl, (fl + 524288 : U32))
  +top = C.pick(U32, U32.is_eq(kind, 1), +v => highestceil(g, s), +v => S.s.ceil(g, s))
  +dir = Bool.pick(U32, U32.is_eq(kind, 1), 1, neg1())
  +speed = Bool.pick(U32, U32.is_eq(kind, 4), 131072, fu())
  +g1 = C.add(g, S.TCeil{s, kind, bottom, top, speed, crush, dir, S.s.tag(g, s), 0})
  addceil(S.s.data.set(g1, s, id), id)

def ceilon.of(+g: S.Sim, +id: U32, +tg: U32, t: S.Th) -> S.Sim:
  match t:
    case S.TCeil{+sec, +kind, +bottom, +top, +speed, +crush, +dir, +tag, +old}:
      C.when(Bool.and(U32.is_eq(tag, tg), U32.is_eq(dir, 0)), g, +h => ceil.put(h, id, sec, kind, bottom, top, speed, crush, old, tag, old))
    case _:
      g

def ceiloff.of(+g: S.Sim, +id: U32, +tg: U32, t: S.Th) -> S.Sim:
  match t:
    case S.TCeil{+sec, +kind, +bottom, +top, +speed, +crush, +dir, +tag, +old}:
      C.when(Bool.and(U32.is_eq(tag, tg), U32.is_ne(dir, 0)), g, +h => S.sim.ret.set(ceil.put(h, id, sec, kind, bottom, top, speed, crush, 0, tag, dir), 1))
    case _:
      g

def ceilon(+g: S.Sim, +tag: U32) -> S.Sim:
  slots(~(+h => +i => +t => ceilon.of(h, i, t, C.th(h, i))), 30n, g, S.sim.ceils(g), 0, tag)

def crushstop(+g: S.Sim, +ld: U32) -> S.Sim:
  +g1 = S.sim.ret.set(g, 0)
  slots(~(+h => +i => +t => ceiloff.of(h, i, t, C.th(h, i))), 30n, g1, S.sim.ceils(g1), 0, S.l.tag(g1, ld))

def ceiling(+g: S.Sim, +ld: U32, +kind: U32) -> S.Sim:
  +g1 = C.when(Bool.or(is.in2(kind, 3, 4), U32.is_eq(kind, 5)), g, +h => ceilon(h, S.l.tag(h, ld)))
  ev(~(+a => +b => +c => +d => +e => ceil.one(a, b, c, d, e)), g1, ld, kind, 0)

def each(~f: S.Sim -> U32 -> U32 -> S.Sim, n: Nat, more: Bool, +g: S.Sim, +a: U32, +i: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = f(g, i, a)
      each(~f, p, U32.is_lt((i + 1 : U32), S.mp.nsec(g1)), g1, a, (i + 1 : U32))
    case _ _:
      g

def sectors(~f: S.Sim -> U32 -> U32 -> S.Sim, +g: S.Sim, +a: U32) -> S.Sim:
  +n = S.mp.nsec(g)
  each(~f, U32.to_nat(n), U32.is_ne(n, 0), g, a, 0)

def lightsoff.one(+g: S.Sim, +s: U32, +tag: U32) -> S.Sim:
  C.when(U32.is_eq(S.s.tag(g, s), tag), g, +h => S.s.light.set(h, s, minlight(h, s, S.s.light(h, s))))

def lightsoff(+g: S.Sim, +ld: U32) -> S.Sim:
  sectors(~(+h => +s => +a => lightsoff.one(h, s, a)), g, S.l.tag(g, ld))

def lighton.set(+g: S.Sim, +s: U32, +b: U32) -> S.Sim:
  S.sim.ret.set(S.s.light.set(g, s, b), b)

def lighton.one(+g: S.Sim, +s: U32, +tag: U32) -> S.Sim:
  +b = S.sim.ret(g)
  C.when(U32.is_eq(S.s.tag(g, s), tag), g, +h => lighton.set(h, s, C.pick(U32, U32.is_eq(b, 0), +u => maxlight(h, s, 0), +u => b)))

def lighton(+g: S.Sim, +ld: U32, +bright: U32) -> S.Sim:
  +tag = S.l.tag(g, ld)
  sectors(~(+h => +s => +a => lighton.one(h, s, a)), S.sim.ret.set(g, bright), tag)

def spawn.strobe(+g: S.Sim, +s: U32, +dark: U32, +sync: U32) -> S.Sim:
  +max = S.s.light(g, s)
  +min0 = minlight(g, s, max)
  +min = Bool.pick(U32, U32.is_eq(min0, max), 0, min0)
  +r = C.rnd(g)
  +free = U32.is_eq(sync, 0)
  +g1 = C.when(free, g, +h => C.rnd.next(h))
  +count = Bool.pick(U32, free, ((r .&. 7) + 1 : U32), 1)
  S.s.special.set(C.add(g1, S.TStrobe{s, count, min, max, dark, 5}), s, 0)

def strobe.one(+g: S.Sim, +s: U32, +ld: U32, +b: U32, +c: U32) -> S.Sim:
  spawn.strobe(g, s, 35, 0)

def strobe(+g: S.Sim, +ld: U32) -> S.Sim:
  ev(~(+a => +b => +c => +d => +e => strobe.one(a, b, c, d, e)), g, ld, 0, 0)

def spawn.flash(+g: S.Sim, +s: U32) -> S.Sim:
  +max = S.s.light(g, s)
  +min = minlight(g, s, max)
  +r = C.rnd(g)
  S.s.special.set(C.add(C.rnd.next(g), S.TFlash{s, ((r .&. 64) + 1 : U32), max, min, 64, 7}), s, 0)

def spawn.flicker(+g: S.Sim, +s: U32) -> S.Sim:
  +max = S.s.light(g, s)
  +min = (minlight(g, s, max) + 16 : U32)
  S.s.special.set(C.add(g, S.TFlicker{s, 4, max, min}), s, 0)

def spawn.glow(+g: S.Sim, +s: U32) -> S.Sim:
  +max = S.s.light(g, s)
  +min = minlight(g, s, max)
  S.s.special.set(C.add(g, S.TGlow{s, min, max, neg1()}), s, 0)

def door.in30(+g: S.Sim, +s: U32) -> S.Sim:
  +id = C.newid(g)
  +g1 = C.add(g, S.TDoor{s, 0, S.s.ceil(g, s), vdoorspeed(), 0, 150, 1050})
  S.s.special.set(S.s.data.set(g1, s, id), s, 0)

def door.in5(+g: S.Sim, +s: U32) -> S.Sim:
  +id = C.newid(g)
  +g1 = C.add(g, S.TDoor{s, 4, (lowestceil(g, s) - 262144 : U32), vdoorspeed(), 2, 150, 10500})
  S.s.special.set(S.s.data.set(g1, s, id), s, 0)

def tele.find(n: Nat, more: Bool, +g: S.Sim, +s: U32, +t: U32) -> U32:
  match n more:
    case 1n+p True{}:
      +hit = Bool.and(Bool.and(O.alive(g, t), U32.is_eq(S.m.type(g, t), 41)), U32.is_eq(G.mobsec(g, t), s))
      C.pick(U32, hit, +u => t, +u => tele.find(p, U32.is_ne(C.tnext(g, t), 0), g, s, C.tnext(g, t)))
    case _ _:
      0

def tele.done(+g: S.Sim, +th: U32, +d: U32, +ox: U32, +oy: U32, +oz: U32) -> S.Sim:
  +g1 = S.m.z.set(g, th, S.m.floorz(g, th))
  +pl = U32.is_ne(S.m.player(g1, th), 0)
  +g2 = C.when(pl, g1, +h => S.p.viewz.set(h, (S.m.z(h, th) + S.p.viewheight(h) : U32)))
  +g3 = O.spawn(g2, ox, oy, oz, 39)
  +an = (S.m.angle(g3, d) >> 19n : U32)
  +tb = S.mp.tb(g3)
  +fx = (S.m.x(g3, d) + 20 * V.sine(tb, (an + 2048 : U32)) : U32)
  +fy = (S.m.y(g3, d) + 20 * V.sine(tb, an) : U32)
  +g4 = O.spawn(g3, fx, fy, S.m.z(g3, th), 39)
  +g5 = C.when(pl, g4, +h => S.m.reaction.set(h, th, 18))
  +g6 = S.m.momz.set(S.m.momy.set(S.m.momx.set(S.m.angle.set(g5, th, S.m.angle(g5, d)), th, 0), th, 0), th, 0)
  S.sim.ret.set(g6, 1)

def tele.go(+g: S.Sim, +th: U32, +d: U32) -> S.Sim:
  +ox = S.m.x(g, th)
  +oy = S.m.y(g, th)
  +oz = S.m.z(g, th)
  +g1 = P.teleportmove(g, th, S.m.x(g, d), S.m.y(g, d))
  C.br(U32.is_eq(S.tm.ok(g1), 0), g1, +h => S.sim.ret.set(h, 0), +h => tele.done(h, th, d, ox, oy, oz))

def tele.sec(n: Nat, more: Bool, +g: S.Sim, +tag: U32, +th: U32, +i: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +first = C.tnext(g, 0)
      +d = C.pick(U32, U32.is_eq(S.s.tag(g, i), tag), +u => tele.find(65536n, U32.is_ne(first, 0), g, i, first), +u => 0)
      C.br(U32.is_ne(d, 0), g, +h => tele.go(h, th, d),
        +h => tele.sec(p, U32.is_lt((i + 1 : U32), S.mp.nsec(h)), h, tag, th, (i + 1 : U32)))
    case _ _:
      S.sim.ret.set(g, 0)

def teleport(+g: S.Sim, +ld: U32, +side: U32, +th: U32) -> S.Sim:
  +n = S.mp.nsec(g)
  +skip = Bool.or(C.has(S.m.flags(g, th), 65536), U32.is_eq(side, 1))
  C.br(skip, g, +h => S.sim.ret.set(h, 0), +h => tele.sec(U32.to_nat(n), U32.is_ne(n, 0), h, S.l.tag(h, ld), th, 0))

def exit(+g: S.Sim, +kind: U32) -> S.Sim:
  S.sim.exit.set(g, kind)

def btn(+g: S.Sim, +i: U32, +f: U32) -> U32:
  T.get(U32, S.sim.buttons(g), (i * 4 + f : U32), 0)

def btn.set(+g: S.Sim, +i: U32, +f: U32, +v: U32) -> S.Sim:
  S.sim.buttons.set(g, T.set(U32, S.sim.buttons(g), (i * 4 + f : U32), v))

def btn.pressed(n: Nat, +g: S.Sim, +ld: U32, +i: U32) -> Bool:
  match n:
    case 0n:
      False{}
    case 1n+p:
      Bool.or(Bool.and(U32.is_ne(btn(g, i, 3), 0), U32.is_eq(btn(g, i, 0), ld)), btn.pressed(p, g, ld, (i + 1 : U32)))

def btn.free(n: Nat, +g: S.Sim, +i: U32) -> U32:
  match n:
    case 0n:
      none()
    case 1n+p:
      C.pick(U32, U32.is_eq(btn(g, i, 3), 0), +u => i, +u => btn.free(p, g, (i + 1 : U32)))

def button(+g: S.Sim, +ld: U32, +wh: U32, +tex: U32, +time: U32) -> S.Sim:
  +k = btn.free(16n, g, 0)
  C.when(Bool.and(Bool.not(btn.pressed(16n, g, ld, 0)), real(k)), g,
    +h => btn.set(btn.set(btn.set(btn.set(h, k, 0, ld), k, 1, wh), k, 2, tex), k, 3, time))

def sidetex.set(+g: S.Sim, +sd: U32, +wh: U32, +v: U32) -> S.Sim:
  C.br(U32.is_eq(wh, 0), g, +h => S.sd.top.set(h, sd, v),
    +h => C.br(U32.is_eq(wh, 1), h, +k => S.sd.mid.set(k, sd, v), +k => S.sd.bottom.set(k, sd, v)))

def sw.at(+g: S.Sim, +i: U32) -> U32:
  T.get(U32, S.mp.switches(g), i, 0)

def sw.apply(+g: S.Sim, +ld: U32, +again: Bool, +wh: U32, +i: U32) -> S.Sim:
  +v = sw.at(g, i)
  +nv = sw.at(g, Bool.pick(U32, C.has(i, 1), (i - 1 : U32), (i + 1 : U32)))
  +g1 = sidetex.set(g, S.l.side0(g, ld), wh, nv)
  C.when(again, g1, +h => button(h, ld, wh, v, 35))

def sw.scan(n: Nat, more: Bool, +g: S.Sim, +ld: U32, +again: Bool, +top: U32, +mid: U32, +bot: U32, +i: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +v = sw.at(g, i)
      +w = Bool.pick(U32, U32.is_eq(v, top), 0, Bool.pick(U32, U32.is_eq(v, mid), 1, Bool.pick(U32, U32.is_eq(v, bot), 2, 3)))
      C.br(U32.is_ne(w, 3), g, +h => sw.apply(h, ld, again, w, i),
        +h => sw.scan(p, U32.is_lt((i + 1 : U32), S.mp.nswitch(h)), h, ld, again, top, mid, bot, (i + 1 : U32)))
    case _ _:
      g

def switch(+g: S.Sim, +ld: U32, +again: Bool) -> S.Sim:
  +g1 = C.when(Bool.not(again), g, +h => C.lspec.set(h, ld, 0))
  +sd = S.l.side0(g1, ld)
  +n = S.mp.nswitch(g1)
  sw.scan(U32.to_nat(n), U32.is_ne(n, 0), g1, ld, again, S.sd.top(g1, sd), S.sd.mid(g1, sd), S.sd.bottom(g1, sd), 0)

def raise.both(+g: S.Sim, +ld: U32) -> S.Sim:
  +g1 = ceiling(g, ld, 1)
  +r = ret(g1)
  +g2 = floor(g1, ld, 1)
  S.sim.ret.set(g2, (r .|. ret(g2) : U32))

def run(+g: S.Sim, +ld: U32, +m: U32, +side: U32, +act: U32, +kind: U32, +amt: U32) -> S.Sim:
  C.br(U32.is_eq(act, 1), g, +h => door(h, ld, kind),
  +h => C.br(U32.is_eq(act, 2), h, +h => floor(h, ld, kind),
  +h => C.br(U32.is_eq(act, 3), h, +h => ceiling(h, ld, kind),
  +h => C.br(U32.is_eq(act, 4), h, +h => plat(h, ld, kind, amt),
  +h => C.br(U32.is_eq(act, 5), h, +h => stairs(h, ld, kind),
  +h => C.br(U32.is_eq(act, 6), h, +h => lighton(h, ld, kind),
  +h => C.br(U32.is_eq(act, 7), h, +h => strobe(h, ld),
  +h => C.br(U32.is_eq(act, 8), h, +h => lightsoff(h, ld),
  +h => C.br(is.in2(act, 9, 18), h, +h => teleport(h, ld, side, m),
  +h => C.br(U32.is_eq(act, 10), h, +h => exit(h, 1),
  +h => C.br(U32.is_eq(act, 11), h, +h => exit(h, 2),
  +h => C.br(U32.is_eq(act, 12), h, +h => stopplat(h, ld),
  +h => C.br(U32.is_eq(act, 13), h, +h => crushstop(h, ld),
  +h => C.br(U32.is_eq(act, 14), h, +h => raise.both(h, ld),
  +h => C.br(U32.is_eq(act, 15), h, +h => donut(h, ld),
  +h => C.br(U32.is_eq(act, 16), h, +h => vdoor(h, ld, m),
  +h => C.br(U32.is_eq(act, 17), h, +h => lockeddoor(h, ld, kind, m),
  +h => S.sim.ret.set(h, 0))))))))))))))))))

def code(+tab: T.Vec<U32>, +sp: U32) -> U32:
  Bool.pick(U32, U32.is_lt(sp, 142), T.get(U32, tab, sp, 0), 0)

def act.of(+c: U32) -> U32:
  (c .&. 255 : U32)

def kind.of(+c: U32) -> U32:
  ((c >> 8n) .&. 255 : U32)

def amt.of(+c: U32) -> U32:
  ((c >> 16n) .&. 255 : U32)

def flag(+c: U32, +b: U32) -> Bool:
  C.has((c >> 24n : U32), b)

def missiletype(+k: U32) -> Bool:
  Bool.or(Bool.or(is.in2(k, 33, 34), is.in2(k, 35, 31)), is.in2(k, 32, 16))

def cross.monster(+sp: U32) -> Bool:
  Bool.or(Bool.or(is.in2(sp, 39, 97), is.in2(sp, 125, 126)), Bool.or(is.in2(sp, 4, 10), U32.is_eq(sp, 88)))

def cross.go(+g: S.Sim, +ld: U32, +side: U32, +m: U32, +pl: Bool, +c: U32) -> S.Sim:
  +act = act.of(c)
  +g1 = C.when(Bool.not(Bool.and(U32.is_eq(act, 18), pl)), g, +h => run(h, ld, m, side, act, kind.of(c), amt.of(c)))
  C.when(Bool.and(flag(c, 1), Bool.not(Bool.and(U32.is_eq(act, 18), pl))), g1, +h => C.lspec.set(h, ld, 0))

def cross(+g: S.Sim, +ld: U32, +side: U32, +m: U32) -> S.Sim:
  +pl = U32.is_ne(S.m.player(g, m), 0)
  +sp = C.lspec(g, ld)
  +ok = Bool.or(pl, Bool.and(Bool.not(missiletype(S.m.type(g, m))), cross.monster(sp)))
  +c = code(S.mp.xtab(g), sp)
  C.when(Bool.and(ok, U32.is_ne(c, 0)), g, +h => cross.go(h, ld, side, m, pl, c))

def use.go(+g: S.Sim, +ld: U32, +m: U32, +c: U32) -> S.Sim:
  +act = act.of(c)
  +always = flag(c, 2)
  +g0 = C.when(Bool.and(always, is.in2(act, 10, 11)), g, +h => switch(h, ld, flag(c, 1)))
  +g1 = run(g0, ld, m, 0, act, kind.of(c), amt.of(c))
  +sw = Bool.and(Bool.not(flag(c, 4)), Bool.or(Bool.and(always, Bool.not(is.in2(act, 10, 11))), Bool.and(Bool.not(always), U32.is_ne(ret(g1), 0))))
  C.when(sw, g1, +h => switch(h, ld, flag(c, 1)))

def use(+g: S.Sim, +ld: U32, +side: U32, +m: U32) -> S.Sim:
  +pl = U32.is_ne(S.m.player(g, m), 0)
  +sp = C.lspec(g, ld)
  +ok1 = Bool.or(U32.is_eq(side, 0), U32.is_eq(sp, 124))
  +ok2 = Bool.or(pl, Bool.and(Bool.not(C.has(S.l.flags(g, ld), 32)), Bool.or(is.in2(sp, 1, 32), is.in2(sp, 33, 34))))
  +c = code(S.mp.utab(g), sp)
  C.when(Bool.and(Bool.and(ok1, ok2), Bool.and(U32.is_ne(c, 0), Bool.not(flag(c, 8)))), g, +h => use.go(h, ld, m, c))

def shoot(+g: S.Sim, +ld: U32, +m: U32) -> S.Sim:
  +pl = U32.is_ne(S.m.player(g, m), 0)
  +sp = C.lspec(g, ld)
  +c = code(S.mp.utab(g), sp)
  +ok = Bool.and(Bool.and(flag(c, 8), U32.is_ne(c, 0)), Bool.or(pl, U32.is_eq(sp, 46)))
  C.when(ok, g, +h => switch(run(h, ld, m, 0, act.of(c), kind.of(c), amt.of(c)), ld, flag(c, 1)))

def hurtfloor(+g: S.Sim, +m: U32, +ok: Bool, +dmg: U32) -> S.Sim:
  C.when(Bool.and(ok, U32.is_eq((S.sim.time(g) .&. 31 : U32), 0)), g, +h => H.damage(h, m, 0, 0, dmg))

def slime(+g: S.Sim, +m: U32) -> S.Sim:
  +iron = U32.is_ne(S.p.pw3(g), 0)
  +r = C.rnd(g)
  +g1 = C.when(iron, g, +h => C.rnd.next(h))
  hurtfloor(g1, m, Bool.or(Bool.not(iron), U32.is_lt(r, 5)), 20)

def endlevel(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = hurtfloor(S.p.cheats.set(g, C.clr(S.p.cheats(g), 2)), m, True{}, 20)
  C.when(F.le(S.p.health(g1), 10), g1, +h => exit(h, 1))

def playerin.go(+g: S.Sim, +m: U32, +s: U32, +sp: U32) -> S.Sim:
  +iron = U32.is_ne(S.p.pw3(g), 0)
  C.br(U32.is_eq(sp, 5), g, +h => hurtfloor(h, m, Bool.not(iron), 10),
  +h => C.br(U32.is_eq(sp, 7), h, +h => hurtfloor(h, m, Bool.not(iron), 5),
  +h => C.br(is.in2(sp, 4, 16), h, +h => slime(h, m),
  +h => C.br(U32.is_eq(sp, 9), h, +h => S.s.special.set(S.p.secrets.set(h, (S.p.secrets(h) + 1 : U32)), s, 0),
  +h => C.when(U32.is_eq(sp, 11), h, +h => endlevel(h, m))))))

def playerin(+g: S.Sim) -> S.Sim:
  +m = S.p.mo(g)
  +s = G.mobsec(g, m)
  C.when(U32.is_eq(S.m.z(g, m), S.s.floor(g, s)), g, +h => playerin.go(h, m, s, S.s.special(h, s)))

def nth(xs: List<&2, U32>, +k: U32) -> U32:
  match xs:
    case x <> t:
      Bool.pick(U32, U32.is_eq(k, 0), x, nth(t, (k - 1 : U32)))
    case []:
      0

def len(xs: List<&2, U32>) -> U32:
  match xs:
    case x <> t:
      (1 + len(t) : U32)
    case []:
      0

def anim.frame(+g: S.Sim, +tex: Bool, +id: U32, +f: U32) -> S.Sim:
  +w = S.sim.w(g)
  +mp = S.sim.mp(g)
  S.sim.w.set(g, Bool.pick(R.World, tex, R.set.info(w, id, T.get(M.Info, S.mpr.tex0(mp), (f - 1 : U32), M.Info{0, 0, 0, 0})),
    R.set.flat(w, id, T.get(U32, S.mpr.flat0(mp), f, 0))))

def anim.go(xs: List<&2, U32>, +g: S.Sim, +tex: Bool, +all: List<&2, U32>, +n: U32, +t: U32, +j: U32) -> S.Sim:
  match xs:
    case +x <> r:
      anim.go(r, anim.frame(g, tex, x, nth(all, ((t + j) % n : U32))), tex, all, n, t, (j + 1 : U32))
    case []:
      g

def anim.one(+g: S.Sim, a: S.Anim) -> S.Sim:
  match a:
    case S.Anim{+tex, +ids, +base, +speed}:
      anim.go(ids, g, tex, ids, len(ids), (S.sim.time(g) / speed : U32), 0)

def anims(xs: List<&2, S.Anim>, +g: S.Sim) -> S.Sim:
  match xs:
    case a <> t:
      anims(t, anim.one(g, a))
    case []:
      g

def scrolls(xs: List<&2, U32>, +g: S.Sim) -> S.Sim:
  match xs:
    case +x <> t:
      +sd = S.l.side0(g, x)
      scrolls(t, S.sd.xoff.set(g, sd, (S.sd.xoff(g, sd) + fu() : U32)))
    case []:
      g

def btn.fire(+g: S.Sim, +i: U32) -> S.Sim:
  +g1 = sidetex.set(g, S.l.side0(g, btn(g, i, 0)), btn(g, i, 1), btn(g, i, 2))
  btn.set(btn.set(btn.set(btn.set(g1, i, 0, 0), i, 1, 0), i, 2, 0), i, 3, 0)

def btn.tick(+g: S.Sim, +i: U32) -> S.Sim:
  +t = btn(g, i, 3)
  C.when(U32.is_ne(t, 0), g, +h => C.br(U32.is_eq(t, 1), h, +k => btn.fire(k, i), +k => btn.set(k, i, 3, (t - 1 : U32))))

def buttons(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      buttons(p, btn.tick(g, i), (i + 1 : U32))

def update(+g: S.Sim) -> S.Sim:
  +g1 = anims(S.mp.anims(g), g)
  +g2 = scrolls(S.mp.scrolls(g1), g1)
  buttons(16n, g2, 0)

def spawn.one(+g: S.Sim, +s: U32) -> S.Sim:
  +sp = S.s.special(g, s)
  C.br(U32.is_eq(sp, 1), g, +h => spawn.flash(h, s),
  +h => C.br(U32.is_eq(sp, 2), h, +h => spawn.strobe(h, s, 15, 0),
  +h => C.br(U32.is_eq(sp, 3), h, +h => spawn.strobe(h, s, 35, 0),
  +h => C.br(U32.is_eq(sp, 4), h, +h => S.s.special.set(spawn.strobe(h, s, 15, 0), s, 4),
  +h => C.br(U32.is_eq(sp, 8), h, +h => spawn.glow(h, s),
  +h => C.br(U32.is_eq(sp, 9), h, +h => S.sim.secrets.set(h, (S.sim.secrets(h) + 1 : U32)),
  +h => C.br(U32.is_eq(sp, 10), h, +h => door.in30(h, s),
  +h => C.br(U32.is_eq(sp, 12), h, +h => spawn.strobe(h, s, 35, 1),
  +h => C.br(U32.is_eq(sp, 13), h, +h => spawn.strobe(h, s, 15, 1),
  +h => C.br(U32.is_eq(sp, 14), h, +h => door.in5(h, s),
  +h => C.when(U32.is_eq(sp, 17), h, +h => spawn.flicker(h, s))))))))))))

def spawnspecials(+g: S.Sim) -> S.Sim:
  sectors(~(+h => +s => +a => spawn.one(h, s)), g, 0)
def crosstab() -> List<&2, U32>:
  [0, 0, 16777985, 16777729, 16777217, 16777986, 16778243, 0, 16777221, 0, 16777476, 0, 16777222, 16842502, 0, 0, 16777473, 16777223, 0, 16777218, 0, 0, 16777988, 0, 0, 16777987, 0, 0, 0, 0, 16778498, 0, 0, 0, 0, 16786182, 16777730, 16778754, 16777474, 16777225, 16777230, 0, 0, 0, 16777731, 0, 0, 0, 0, 0, 0, 0, 10, 16777220, 16777228, 0, 16779522, 16777229, 16779010, 16779266, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 515, 771, 13, 513, 257, 1027, 0, 8966, 6, 65286, 258, 2, 1538, 0, 769, 4, 260, 12, 1, 770, 1794, 2050, 2306, 772, 1282, 9, 514, 0, 16777477, 0, 0, 0, 16777224, 1281, 1537, 1793, 16778497, 16778753, 16779009, 0, 0, 0, 0, 0, 0, 0, 0, 16778242, 1028, 16778244, 0, 0, 11, 16777234, 18, 0, 1026, 2562, 16779778, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16778499]

def usetab() -> List<&2, U32>:
  [0, 67108880, 0, 0, 0, 0, 0, 5, 0, 15, 0, 33554442, 0, 0, 2097668, 1573380, 0, 0, 1026, 0, 772, 260, 0, 258, 134218498, 0, 67108880, 67108880, 67108880, 1, 0, 67108880, 67108880, 67108880, 67108880, 0, 0, 0, 0, 0, 0, 3, 16777729, 16777219, 0, 16777218, 150995713, 134218500, 0, 771, 513, 33554443, 0, 0, 0, 2306, 0, 0, 0, 0, 16777474, 16777985, 16843012, 16777217, 16777986, 16779522, 18350596, 18874884, 16777988, 16778242, 16777730, 514, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16778769, 0, 770, 2, 769, 0, 0, 0, 0, 0, 0, 0, 1281, 1537, 1793, 16778497, 16778753, 16779009, 67108880, 67108880, 0, 0, 0, 1028, 16778244, 0, 0, 0, 261, 0, 0, 0, 2562, 16779778, 1553, 16778769, 1553, 16778769, 1553, 50396934, 50340614, 3074, 0]

