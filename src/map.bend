import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./geo.bend as G
import ./mobj.bend as O
import ./hit.bend as H
import ./items.bend as I

def maxradius() -> U32:
  2097152

def none() -> U32:
  4294967295

def touch(+g: S.Sim, +sp: U32, +toucher: U32) -> S.Sim:
  I.touch(g, sp, toucher)

def near(+g: S.Sim, +th: U32) -> Bool:
  +bd = (S.m.radius(g, th) + S.m.radius(g, S.tm.thing(g)) : U32)
  Bool.and(F.lt(F.abs((S.m.x(g, th) - S.tm.x(g) : U32)), bd), F.lt(F.abs((S.m.y(g, th) - S.tm.y(g) : U32)), bd))

def solid(+g: S.Sim, +fl: U32) -> S.Sim:
  C.when(C.has(fl, 2), g, +h => C.stop(h))

def skullhit(+g: S.Sim, +tm: U32, +th: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +dmg = (((r % 8) + 1) * C.info(g1, S.m.type(g1, tm), 19) : U32)
  +g2 = H.damage(g1, th, tm, tm, dmg)
  +g3 = S.m.flags.set(g2, tm, C.clr(S.m.flags(g2, tm), 16777216))
  +g4 = S.m.momz.set(S.m.momy.set(S.m.momx.set(g3, tm, 0), tm, 0), tm, 0)
  C.stop(O.setstate(g4, tm, C.info(g4, S.m.type(g4, tm), 1)))

def missilehit(+g: S.Sim, +tm: U32, +th: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +dmg = (((r % 8) + 1) * C.info(g1, S.m.type(g1, tm), 19) : U32)
  C.stop(H.damage(g1, th, tm, S.m.target(g1, tm), dmg))

def kin(+a: U32, +b: U32) -> Bool:
  Bool.or(U32.is_eq(a, b), Bool.or(Bool.and(U32.is_eq(a, 17), U32.is_eq(b, 15)), Bool.and(U32.is_eq(a, 15), U32.is_eq(b, 17))))

def missile.shootable(+g: S.Sim, +tm: U32, +th: U32, +fl: U32) -> S.Sim:
  C.br(C.has(fl, 4), g, +h => missilehit(h, tm, th), +h => solid(h, fl))

def missile(+g: S.Sim, +tm: U32, +th: U32, +fl: U32) -> S.Sim:
  +tz = S.m.z(g, tm)
  +hz = S.m.z(g, th)
  +miss = Bool.or(F.gt(tz, (hz + S.m.height(g, th) : U32)), F.lt((tz + S.m.height(g, tm) : U32), hz))
  +src = S.m.target(g, tm)
  +same = Bool.and(U32.is_ne(src, 0), kin(S.m.type(g, src), S.m.type(g, th)))
  C.br(Bool.or(miss, Bool.and(same, U32.is_eq(th, src))), g, +h => h,
    +h => C.br(Bool.and(same, U32.is_ne(S.m.type(h, th), 0)), h, +k => C.stop(k), +k => missile.shootable(k, tm, th, fl)))

def special(+g: S.Sim, +tm: U32, +th: U32, +fl: U32) -> S.Sim:
  +g1 = C.when(C.has(S.tm.flags(g), 2048), g, +h => touch(h, th, tm))
  solid(g1, fl)

def pit.thing.go(+g: S.Sim, +th: U32, +fl: U32) -> S.Sim:
  +tm = S.tm.thing(g)
  +tf = S.m.flags(g, tm)
  C.br(C.has(tf, 16777216), g, +h => skullhit(h, tm, th),
    +h => C.br(C.has(tf, 65536), h, +k => missile(k, tm, th, fl),
      +k => C.br(C.has(fl, 1), k, +q => special(q, tm, th, fl), +q => solid(q, fl))))

def pit.thing(+g: S.Sim, +th: U32) -> S.Sim:
  +fl = S.m.flags(g, th)
  C.when(Bool.and(Bool.and(C.has(fl, 7), near(g, th)), U32.is_ne(th, S.tm.thing(g))), g, +h => pit.thing.go(h, th, fl))

def pit.line.open(+g: S.Sim, +ld: U32) -> S.Sim:
  +g1 = G.opening(g, ld)
  +ot = S.tm.otop(g1)
  +ob = S.tm.obottom(g1)
  +ol = S.tm.olow(g1)
  +g2 = C.when(F.lt(ot, S.tm.ceilz(g1)), g1, +h => S.tm.ceilline.set(S.tm.ceilz.set(h, ot), ld))
  +g3 = C.when(F.gt(ob, S.tm.floorz(g2)), g2, +h => S.tm.floorz.set(h, ob))
  +g4 = C.when(F.lt(ol, S.tm.dropoff(g3)), g3, +h => S.tm.dropoff.set(h, ol))
  C.when(U32.is_ne(C.lspec(g4, ld), 0), g4, +h => S.tm.spechit.set(h, ld <> S.tm.spechit(h)))

def pit.line.of(+g: S.Sim, +ld: U32, +l: S.RLine) -> S.Sim:
  match l:
    case S.RLine{x1, y1, x2, y2, dx, dy, +fl, sl, +lt, +lb, +ll, +lr, s0, s1, fs, +bs, tg}:
      +top = S.tm.top(g)
      +bot = S.tm.bottom(g)
      +left = S.tm.left(g)
      +right = S.tm.right(g)
      +apart = Bool.or(Bool.or(F.le(right, ll), F.ge(left, lr)), Bool.or(F.le(top, lb), F.ge(bot, lt)))
      +tm = S.tm.thing(g)
      +block = Bool.and(Bool.not(C.has(S.m.flags(g, tm), 65536)),
        Bool.or(C.has(fl, 1), Bool.and(U32.is_eq(S.m.player(g, tm), 0), C.has(fl, 2))))
      C.when(Bool.not(Bool.or(apart, U32.is_ne(G.boxside(top, bot, left, right, S.line(g, ld)), 4294967295))), g,
        +h => C.br(Bool.or(U32.is_eq(bs, 65535), block), h, +k => C.stop(k), +k => pit.line.open(k, ld)))

def pit.line(+g: S.Sim, +ld: U32) -> S.Sim:
  pit.line.of(g, ld, S.line(g, ld))

def tm.setup(+g: S.Sim, +m: U32, +x: U32, +y: U32) -> S.Sim:
  +r = S.m.radius(g, m)
  +g1 = S.tm.y.set(S.tm.x.set(S.tm.flags.set(S.tm.thing.set(g, m), S.m.flags(g, m)), x), y)
  +g2 = S.tm.left.set(S.tm.right.set(S.tm.bottom.set(S.tm.top.set(g1, (y + r : U32)), (y - r : U32)), (x + r : U32)), (x - r : U32))
  +s = G.secat(g2, x, y)
  +f = S.s.floor(g2, s)
  +g3 = S.tm.ceilz.set(S.tm.dropoff.set(S.tm.floorz.set(S.tm.ceilline.set(g2, none()), f), f), S.s.ceil(g2, s))
  S.tm.spechit.set(C.vc.bump(g3), [])

def blk(+g: S.Sim, +v: U32, +o: U32) -> U32:
  F.sar((v - o : U32), 23n)

def area.things(+g: S.Sim) -> S.Sim:
  +ox = S.mp.ox(g)
  +oy = S.mp.oy(g)
  G.area(~(+h => +bx => +by => G.bthings(~(+k => +t => pit.thing(k, t)), h, bx, by)), g,
    blk(g, (S.tm.left(g) - maxradius() : U32), ox), blk(g, (S.tm.right(g) + maxradius() : U32), ox),
    blk(g, (S.tm.bottom(g) - maxradius() : U32), oy), blk(g, (S.tm.top(g) + maxradius() : U32), oy))

def area.lines(+g: S.Sim) -> S.Sim:
  +ox = S.mp.ox(g)
  +oy = S.mp.oy(g)
  G.area(~(+h => +bx => +by => G.blines(~(+k => +l => pit.line(k, l)), h, bx, by)), g,
    blk(g, S.tm.left(g), ox), blk(g, S.tm.right(g), ox), blk(g, S.tm.bottom(g), oy), blk(g, S.tm.top(g), oy))

def finish(+g: S.Sim) -> S.Sim:
  C.resume(S.tm.ok.set(g, C.b2u(Bool.not(C.halted(g)))))

def checkpos.scan(+g: S.Sim) -> S.Sim:
  +g1 = area.things(g)
  finish(C.br(C.halted(g1), g1, +k => k, +k => area.lines(k)))

def checkpos(+g: S.Sim, +m: U32, +x: U32, +y: U32) -> S.Sim:
  +g1 = tm.setup(g, m, x, y)
  C.br(C.has(S.m.flags(g1, m), 4096), g1, +h => S.tm.ok.set(h, 1), +h => checkpos.scan(h))

def stomp.go(+g: S.Sim, +th: U32) -> S.Sim:
  +tm = S.tm.thing(g)
  C.br(Bool.and(U32.is_eq(S.m.player(g, tm), 0), U32.is_ne(S.mp.map(g), 30)), g, +h => C.stop(h), +h => H.damage(h, th, tm, tm, 10000))

def pit.stomp(+g: S.Sim, +th: U32) -> S.Sim:
  C.when(Bool.and(Bool.and(C.has(S.m.flags(g, th), 4), near(g, th)), U32.is_ne(th, S.tm.thing(g))), g, +h => stomp.go(h, th))

def teleported(+g: S.Sim, +m: U32, +x: U32, +y: U32) -> S.Sim:
  +g1 = G.unset(g, m)
  +g2 = S.m.ceilz.set(S.m.floorz.set(g1, m, S.tm.floorz(g1)), m, S.tm.ceilz(g1))
  S.tm.ok.set(G.set(S.m.y.set(S.m.x.set(g2, m, x), m, y), m), 1)

def teleportmove(+g: S.Sim, +m: U32, +x: U32, +y: U32) -> S.Sim:
  +g1 = tm.setup(g, m, x, y)
  +ox = S.mp.ox(g1)
  +oy = S.mp.oy(g1)
  +g2 = G.area(~(+h => +bx => +by => G.bthings(~(+k => +t => pit.stomp(k, t)), h, bx, by)), g1,
    blk(g1, (S.tm.left(g1) - maxradius() : U32), ox), blk(g1, (S.tm.right(g1) + maxradius() : U32), ox),
    blk(g1, (S.tm.bottom(g1) - maxradius() : U32), oy), blk(g1, (S.tm.top(g1) + maxradius() : U32), oy))
  C.br(C.halted(g2), g2, +h => S.tm.ok.set(C.resume(h), 0), +h => teleported(h, m, x, y))

def heightclip(+g: S.Sim, +m: U32) -> S.Sim:
  +on = U32.is_eq(S.m.z(g, m), S.m.floorz(g, m))
  +g1 = checkpos(g, m, S.m.x(g, m), S.m.y(g, m))
  +fz = S.tm.floorz(g1)
  +cz = S.tm.ceilz(g1)
  +ht = S.m.height(g1, m)
  +g2 = S.m.ceilz.set(S.m.floorz.set(g1, m, fz), m, cz)
  +z = S.m.z(g2, m)
  +g3 = S.m.z.set(g2, m, Bool.pick(U32, on, fz, Bool.pick(U32, F.gt((z + ht : U32), cz), (cz - ht : U32), z)))
  S.tm.ok.set(g3, C.b2u(Bool.not(F.lt((cz - fz : U32), ht))))

def blood.mom(+g: S.Sim, +b: U32) -> S.Sim:
  +r1 = C.rnd(g)
  +g1 = C.rnd.next(g)
  +r2 = C.rnd(g1)
  +g2 = C.rnd.next(g1)
  +r3 = C.rnd(g2)
  +g3 = C.rnd.next(g2)
  +r4 = C.rnd(g3)
  +g4 = C.rnd.next(g3)
  S.m.momy.set(S.m.momx.set(g4, b, ((r1 - r2) << 12n : U32)), b, ((r3 - r4) << 12n : U32))

def crunch(+g: S.Sim, +th: U32) -> S.Sim:
  +g1 = H.damage(g, th, 0, 0, 10)
  +b = C.newid(g1)
  blood.mom(O.spawn(g1, S.m.x(g1, th), S.m.y(g1, th), (S.m.z(g1, th) + F.quot(S.m.height(g1, th), 2) : U32), 38), b)

def gib(+g: S.Sim, +th: U32) -> S.Sim:
  +g1 = O.setstate(g, th, 895)
  S.m.radius.set(S.m.height.set(S.m.flags.set(g1, th, C.clr(S.m.flags(g1, th), 2)), th, 0), th, 0)

def crushed(+g: S.Sim, +th: U32) -> S.Sim:
  +fl = S.m.flags(g, th)
  C.br(F.le(S.m.health(g, th), 0), g, +h => gib(h, th),
    +h => C.br(C.has(fl, 131072), h, +k => O.remove(k, th),
      +k => C.when(C.has(fl, 4), k, +q => C.when(Bool.and(U32.is_ne(S.tm.crush(q), 0), U32.is_eq((S.sim.time(q) .&. 3 : U32), 0)), S.tm.nofit.set(q, 1), +r => crunch(r, th)))))

def pit.change(+g: S.Sim, +th: U32) -> S.Sim:
  +g1 = heightclip(g, th)
  C.when(U32.is_eq(S.tm.ok(g1), 0), g1, +h => crushed(h, th))

def changesector(+g: S.Sim, +s: U32, +crush: U32) -> S.Sim:
  +g1 = S.tm.crush.set(S.tm.nofit.set(g, 0), crush)
  G.area(~(+h => +bx => +by => G.bthings(~(+k => +t => pit.change(k, t)), h, bx, by)), g1,
    C.secbox(g1, s, 2), C.secbox(g1, s, 3), C.secbox(g1, s, 1), C.secbox(g1, s, 0))
