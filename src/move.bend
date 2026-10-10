import Base
import ./tab.bend as T
import ./level.bend as L
import ./render.bend as V
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./geo.bend as G
import ./mobj.bend as O
import ./map.bend as P
import ./spec.bend as X

def fu() -> U32:
  65536

def none() -> U32:
  4294967295

def ok(+g: S.Sim) -> Bool:
  U32.is_ne(S.tm.ok(g), 0)

def crossing(n: Nat, xs: List<&2, U32>, +g: S.Sim, +m: U32, +ox: U32, +oy: U32) -> S.Sim:
  match n xs:
    case 1n+p +ld <> t:
      +g1 = S.tm.spechit.set(g, t)
      +side = G.pointside(S.m.x(g1, m), S.m.y(g1, m), S.line(g1, ld))
      +old = G.pointside(ox, oy, S.line(g1, ld))
      +g2 = C.when(Bool.and(U32.is_ne(side, old), U32.is_ne(C.lspec(g1, ld), 0)), g1, +h => X.cross(h, ld, old, m))
      crossing(p, S.tm.spechit(g2), g2, m, ox, oy)
    case _ _:
      g

def trymove.go(+g: S.Sim, +m: U32, +x: U32, +y: U32) -> S.Sim:
  +ox = S.m.x(g, m)
  +oy = S.m.y(g, m)
  +g1 = G.unset(g, m)
  +g2 = S.m.y.set(S.m.x.set(S.m.ceilz.set(S.m.floorz.set(g1, m, S.tm.floorz(g1)), m, S.tm.ceilz(g1)), m, x), m, y)
  +g3 = G.set(g2, m)
  +g4 = C.when(Bool.not(C.has(S.m.flags(g3, m), 36864)), g3, +h => crossing(4096n, S.tm.spechit(h), h, m, ox, oy))
  S.tm.ok.set(g4, 1)

def trymove.fit(+g: S.Sim, +m: U32, +x: U32, +y: U32) -> S.Sim:
  +fl = S.m.flags(g, m)
  +fz = S.tm.floorz(g)
  +cz = S.tm.ceilz(g)
  +ht = S.m.height(g, m)
  +z = S.m.z(g, m)
  +noclip = C.has(fl, 4096)
  +tele = C.has(fl, 32768)
  +nofit = F.lt((cz - fz : U32), ht)
  +low = Bool.and(Bool.not(tele), F.lt((cz - z : U32), ht))
  +step = Bool.and(Bool.not(tele), F.gt((fz - z : U32), 1572864))
  +drop = Bool.and(Bool.not(C.has(fl, 17408)), F.gt((fz - S.tm.dropoff(g) : U32), 1572864))
  +bad = Bool.and(Bool.not(noclip), Bool.or(Bool.or(nofit, low), Bool.or(step, drop)))
  +g1 = C.when(Bool.and(Bool.not(noclip), Bool.not(nofit)), g, +h => S.tm.floatok.set(h, 1))
  C.br(bad, g1, +h => S.tm.ok.set(h, 0), +h => trymove.go(h, m, x, y))

def trymove(+g: S.Sim, +m: U32, +x: U32, +y: U32) -> S.Sim:
  +g1 = P.checkpos(S.tm.floatok.set(g, 0), m, x, y)
  C.when(ok(g1), g1, +h => trymove.fit(h, m, x, y))

def slide.block(+g: S.Sim, +frac: U32, +ld: U32) -> S.Sim:
  +best = S.tm.best(g)
  C.stop(C.when(F.lt(frac, best), g, +h => S.tm.bestline.set(S.tm.best.set(S.tm.secondline.set(S.tm.second.set(h, best), S.tm.bestline(h)), frac), ld)))

def slide.two(+g: S.Sim, +m: U32, +frac: U32, +ld: U32) -> S.Sim:
  +g1 = G.opening(g, ld)
  +ht = S.m.height(g1, m)
  +z = S.m.z(g1, m)
  +bad = Bool.or(Bool.or(F.lt(S.tm.orange(g1), ht), F.lt((S.tm.otop(g1) - z : U32), ht)), F.gt((S.tm.obottom(g1) - z : U32), 1572864))
  C.when(bad, g1, +h => slide.block(h, frac, ld))

def slide.ptr(+g: S.Sim, +i: S.Icpt) -> S.Sim:
  match i:
    case S.Icpt{+frac, +isline, +ld}:
      +m = S.tm.mo(g)
      C.br(C.has(S.l.flags(g, ld), 4), g, +h => slide.two(h, m, frac, ld),
        +h => C.when(U32.is_eq(G.pointside(S.m.x(h, m), S.m.y(h, m), S.line(h, ld)), 0), h, +k => slide.block(k, frac, ld)))

def slide.path(+g: S.Sim, +x: U32, +y: U32, +dx: U32, +dy: U32) -> S.Sim:
  C.resume(G.path(~(+h => +i => slide.ptr(h, i)), g, False{}, x, y, (x + dx : U32), (y + dy : U32)))

def lead(+p: U32, +r: U32, +mom: U32) -> U32:
  Bool.pick(U32, F.gt(mom, 0), (p + r : U32), (p - r : U32))

def trail(+p: U32, +r: U32, +mom: U32) -> U32:
  Bool.pick(U32, F.gt(mom, 0), (p - r : U32), (p + r : U32))

def slide.trace(+g: S.Sim, +m: U32) -> S.Sim:
  +x = S.m.x(g, m)
  +y = S.m.y(g, m)
  +r = S.m.radius(g, m)
  +mx = S.m.momx(g, m)
  +my = S.m.momy(g, m)
  +lx = lead(x, r, mx)
  +ly = lead(y, r, my)
  +tx = trail(x, r, mx)
  +ty = trail(y, r, my)
  +g1 = slide.path(S.tm.best.set(S.tm.mo.set(g, m), 65537), lx, ly, mx, my)
  +g2 = slide.path(g1, tx, ly, mx, my)
  slide.path(g2, lx, ty, mx, my)

def stairstep(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = trymove(g, m, S.m.x(g, m), (S.m.y(g, m) + S.m.momy(g, m) : U32))
  S.sim.ret.set(C.when(Bool.not(ok(g1)), g1, +h => trymove(h, m, (S.m.x(h, m) + S.m.momx(h, m) : U32), S.m.y(h, m))), 0)

def hitslide.angled(+g: S.Sim, +m: U32, +l: S.RLine) -> S.Sim:
  +tb = S.mp.tb(g)
  +xm = S.tm.xmove(g)
  +ym = S.tm.ymove(g)
  +side = G.pointside(S.m.x(g, m), S.m.y(g, m), l)
  +la0 = V.angle(tb, S.ln.dx(l), S.ln.dy(l))
  +la = Bool.pick(U32, U32.is_eq(side, 1), (la0 + 2147483648 : U32), la0)
  +d0 = (V.angle(tb, xm, ym) - la : U32)
  +d = Bool.pick(U32, U32.is_gt(d0, 2147483648), (d0 + 2147483648 : U32), d0)
  +li = (la >> 19n : U32)
  +di = (d >> 19n : U32)
  +nl = F.mul(G.aprox(xm, ym), V.sine(tb, (di + 2048 : U32)))
  S.tm.ymove.set(S.tm.xmove.set(g, F.mul(nl, V.sine(tb, (li + 2048 : U32)))), F.mul(nl, V.sine(tb, li)))

def hitslide(+g: S.Sim, +m: U32, +ld: U32) -> S.Sim:
  +sl = S.l.slope(g, ld)
  C.br(U32.is_eq(sl, 0), g, +h => S.tm.ymove.set(h, 0),
    +h => C.br(U32.is_eq(sl, 1), h, +k => S.tm.xmove.set(k, 0), +k => hitslide.angled(k, m, S.line(k, ld))))

def slide.clip(+g: S.Sim, +m: U32, +b: U32) -> S.Sim:
  +g1 = S.tm.ymove.set(S.tm.xmove.set(g, F.mul(S.m.momx(g, m), b)), F.mul(S.m.momy(g, m), b))
  +g2 = hitslide(g1, m, S.tm.bestline(g1))
  +xm = S.tm.xmove(g2)
  +ym = S.tm.ymove(g2)
  +g3 = S.m.momy.set(S.m.momx.set(g2, m, xm), m, ym)
  +g4 = trymove(g3, m, (S.m.x(g3, m) + xm : U32), (S.m.y(g3, m) + ym : U32))
  S.sim.ret.set(g4, C.b2u(Bool.not(ok(g4))))

def slide.rest(+g: S.Sim, +m: U32, +best: U32) -> S.Sim:
  +b0 = (65536 - (best + 2048) : U32)
  +b = Bool.pick(U32, F.gt(b0, 65536), 65536, b0)
  C.br(F.le(b, 0), g, +h => S.sim.ret.set(h, 0), +h => slide.clip(h, m, b))

def slide.part(+g: S.Sim, +m: U32, +best: U32) -> S.Sim:
  +g1 = trymove(g, m, (S.m.x(g, m) + F.mul(S.m.momx(g, m), best) : U32), (S.m.y(g, m) + F.mul(S.m.momy(g, m), best) : U32))
  C.br(ok(g1), g1, +h => slide.rest(h, m, best), +h => stairstep(h, m))

def slide.step(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = slide.trace(g, m)
  +best0 = S.tm.best(g1)
  +best = (best0 - 2048 : U32)
  C.br(U32.is_eq(best0, 65537), g1, +h => stairstep(h, m),
    +h => C.br(F.gt(best, 0), h, +k => slide.part(k, m, best), +k => slide.rest(k, m, best)))

def slide.go(n: Nat, +g: S.Sim, +m: U32) -> S.Sim:
  match n:
    case 0n:
      stairstep(g, m)
    case 1n+p:
      +g1 = slide.step(g, m)
      C.br(U32.is_eq(S.sim.ret(g1), 1), g1, +h => slide.go(p, h, m), +h => h)

def slidemove(+g: S.Sim, +m: U32) -> S.Sim:
  slide.go(2n, g, m)

def explode(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = S.m.momz.set(S.m.momy.set(S.m.momx.set(g, m, 0), m, 0), m, 0)
  +g2 = O.setstate(g1, m, C.info(g1, S.m.type(g1, m), 12))
  +r = C.rnd(g2)
  +g3 = C.rnd.next(g2)
  +t = (S.m.tics(g3, m) - (r .&. 3) : U32)
  +g4 = S.m.tics.set(g3, m, Bool.pick(U32, F.lt(t, 1), 1, t))
  S.m.flags.set(g4, m, C.clr(S.m.flags(g4, m), 65536))

def skywall(+g: S.Sim) -> Bool:
  +cl = S.tm.ceilline(g)
  +b = Bool.pick(U32, U32.is_eq(cl, none()), 65535, S.l.bsec(g, cl))
  Bool.and(U32.is_ne(b, 65535), U32.is_eq(S.s.cpic(g, b), C.sky()))

def xy.blocked(+g: S.Sim, +m: U32) -> S.Sim:
  C.br(U32.is_ne(S.m.player(g, m), 0), g, +h => slidemove(h, m),
    +h => C.br(C.has(S.m.flags(h, m), 65536), h, +k => C.br(skywall(k), k, +q => O.remove(q, m), +q => explode(q, m)),
      +k => S.m.momy.set(S.m.momx.set(k, m, 0), m, 0)))

def xy.loop(n: Nat, more: Bool, +g: S.Sim, +m: U32, +xm: U32, +ym: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +half = Bool.or(F.gt(xm, 983040), F.gt(ym, 983040))
      +tx = (S.m.x(g, m) + Bool.pick(U32, half, F.quot(xm, 2), xm) : U32)
      +ty = (S.m.y(g, m) + Bool.pick(U32, half, F.quot(ym, 2), ym) : U32)
      +nx = Bool.pick(U32, half, F.sar(xm, 1n), 0)
      +ny = Bool.pick(U32, half, F.sar(ym, 1n), 0)
      +g1 = trymove(g, m, tx, ty)
      +g2 = C.when(Bool.not(ok(g1)), g1, +h => xy.blocked(h, m))
      xy.loop(p, Bool.and(O.alive(g2, m), Bool.or(U32.is_ne(nx, 0), U32.is_ne(ny, 0))), g2, m, nx, ny)
    case _ _:
      g

def clamp(+v: U32) -> U32:
  Bool.pick(U32, F.gt(v, 1966080), 1966080, Bool.pick(U32, F.lt(v, 4293001216), 4293001216, v))

def friction.stop(+g: S.Sim, +m: U32, +pl: Bool) -> S.Sim:
  +run = U32.is_lt((S.m.state(g, m) - 150 : U32), 4)
  +g1 = C.when(Bool.and(pl, run), g, +h => O.setstate(h, m, 149))
  S.m.momy.set(S.m.momx.set(g1, m, 0), m, 0)

def friction.apply(+g: S.Sim, +m: U32, +pl: Bool) -> S.Sim:
  +mx = S.m.momx(g, m)
  +my = S.m.momy(g, m)
  +still = Bool.and(Bool.and(F.gt(mx, 4294963200), F.lt(mx, 4096)), Bool.and(F.gt(my, 4294963200), F.lt(my, 4096)))
  +idle = Bool.or(Bool.not(pl), Bool.and(U32.is_eq(S.p.fwd(g), 0), U32.is_eq(S.p.side(g), 0)))
  C.br(Bool.and(still, idle), g, +h => friction.stop(h, m, pl),
    +h => S.m.momy.set(S.m.momx.set(h, m, F.mul(mx, 59392)), m, F.mul(my, 59392)))

def friction(+g: S.Sim, +m: U32) -> S.Sim:
  +pl = U32.is_ne(S.m.player(g, m), 0)
  +fl = S.m.flags(g, m)
  +mx = S.m.momx(g, m)
  +my = S.m.momy(g, m)
  +fast = Bool.or(Bool.or(F.gt(mx, 16384), F.lt(mx, 4294950912)), Bool.or(F.gt(my, 16384), F.lt(my, 4294950912)))
  +slidecorpse = Bool.and(Bool.and(C.has(fl, 1048576), fast), U32.is_ne(S.m.floorz(g, m), S.s.floor(g, G.mobsec(g, m))))
  +skip = Bool.or(Bool.or(C.has(fl, 16842752), F.gt(S.m.z(g, m), S.m.floorz(g, m))), slidecorpse)
  C.br(Bool.and(pl, C.has(S.p.cheats(g), 4)), g, +h => S.m.momy.set(S.m.momx.set(h, m, 0), m, 0),
    +h => C.when(Bool.not(skip), h, +k => friction.apply(k, m, pl)))

def xy.go(+g: S.Sim, +m: U32) -> S.Sim:
  +mx = clamp(S.m.momx(g, m))
  +my = clamp(S.m.momy(g, m))
  +g1 = xy.loop(64n, True{}, S.m.momy.set(S.m.momx.set(g, m, mx), m, my), m, mx, my)
  C.when(O.alive(g1, m), g1, +h => friction(h, m))

def xymovement(+g: S.Sim, +m: U32) -> S.Sim:
  +still = Bool.and(U32.is_eq(S.m.momx(g, m), 0), U32.is_eq(S.m.momy(g, m), 0))
  C.br(still, g,
    +h => C.when(C.has(S.m.flags(h, m), 16777216), h,
      +k => O.setstate(S.m.momz.set(S.m.momy.set(S.m.momx.set(S.m.flags.set(k, m, C.clr(S.m.flags(k, m), 16777216)), m, 0), m, 0), m, 0), m, C.info(k, S.m.type(k, m), 1))),
    +h => xy.go(h, m))

def z.float(+g: S.Sim, +m: U32) -> S.Sim:
  +t = S.m.target(g, m)
  +z = S.m.z(g, m)
  +dist = G.aprox((S.m.x(g, m) - S.m.x(g, t) : U32), (S.m.y(g, m) - S.m.y(g, t) : U32))
  +delta = ((S.m.z(g, t) + F.sar(S.m.height(g, m), 1n)) - z : U32)
  +down = Bool.and(F.lt(delta, 0), F.lt(dist, F.neg((delta * 3 : U32))))
  +up = Bool.and(F.gt(delta, 0), F.lt(dist, (delta * 3 : U32)))
  S.m.z.set(g, m, Bool.pick(U32, down, (z - 262144 : U32), Bool.pick(U32, up, (z + 262144 : U32), z)))

def z.ceil.hit(+g: S.Sim, +m: U32, +fl: U32) -> S.Sim:
  +g1 = C.when(F.gt(S.m.momz(g, m), 0), g, +h => S.m.momz.set(h, m, 0))
  +g2 = S.m.z.set(g1, m, (S.m.ceilz(g1, m) - S.m.height(g1, m) : U32))
  +g3 = C.when(C.has(fl, 16777216), g2, +h => S.m.momz.set(h, m, F.neg(S.m.momz(h, m))))
  C.when(Bool.and(C.has(fl, 65536), Bool.not(C.has(fl, 4096))), g3, +h => explode(h, m))

def z.ceil(+g: S.Sim, +m: U32) -> S.Sim:
  +fl = S.m.flags(g, m)
  +over = F.gt((S.m.z(g, m) + S.m.height(g, m) : U32), S.m.ceilz(g, m))
  C.when(over, g, +h => z.ceil.hit(h, m, fl))

def z.floor(+g: S.Sim, +m: U32, +pl: Bool) -> S.Sim:
  +fl = S.m.flags(g, m)
  +g1 = C.when(C.has(fl, 16777216), g, +h => S.m.momz.set(h, m, F.neg(S.m.momz(h, m))))
  +mz = S.m.momz(g1, m)
  +g2 = C.when(F.lt(mz, 0), g1, +h => S.m.momz.set(C.when(Bool.and(pl, F.lt(mz, 4294443008)), h, +k => S.p.dvh.set(k, F.sar(mz, 3n))), m, 0))
  +g3 = S.m.z.set(g2, m, S.m.floorz(g2, m))
  C.br(Bool.and(C.has(fl, 65536), Bool.not(C.has(fl, 4096))), g3, +h => explode(h, m), +h => z.ceil(h, m))

def z.air(+g: S.Sim, +m: U32) -> S.Sim:
  +mz = S.m.momz(g, m)
  +g1 = C.when(Bool.not(C.has(S.m.flags(g, m), 512)), g, +h => S.m.momz.set(h, m, Bool.pick(U32, U32.is_eq(mz, 0), 4294836224, (mz - 65536 : U32))))
  z.ceil(g1, m)

def z.view(+g: S.Sim, +m: U32) -> S.Sim:
  +vh = (S.p.viewheight(g) - (S.m.floorz(g, m) - S.m.z(g, m)) : U32)
  S.p.dvh.set(S.p.viewheight.set(g, vh), F.sar((O.viewheight() - vh : U32), 3n))

def zmovement(+g: S.Sim, +m: U32) -> S.Sim:
  +pl = U32.is_ne(S.m.player(g, m), 0)
  +below = F.lt(S.m.z(g, m), S.m.floorz(g, m))
  +g1 = C.when(Bool.and(pl, below), g, +h => z.view(h, m))
  +g2 = S.m.z.set(g1, m, (S.m.z(g1, m) + S.m.momz(g1, m) : U32))
  +fl = S.m.flags(g2, m)
  +g3 = C.when(Bool.and(Bool.and(C.has(fl, 16384), U32.is_ne(S.m.target(g2, m), 0)), Bool.not(C.has(fl, 18874368))), g2, +h => z.float(h, m))
  C.br(F.le(S.m.z(g3, m), S.m.floorz(g3, m)), g3, +h => z.floor(h, m, pl), +h => z.air(h, m))

def respawn.go(+g: S.Sim, +m: U32, +t: L.Thing, +x: U32, +y: U32) -> S.Sim:
  match t:
    case L.Thing{+tx, +ty, +a, +k, +opt}:
      +g1 = O.spawn(g, S.m.x(g, m), S.m.y(g, m), S.s.floor(g, G.mobsec(g, m)), 39)
      +g2 = O.spawn(g1, x, y, S.s.floor(g1, G.secat(g1, x, y)), 39)
      +n = C.newid(g2)
      +ty2 = S.m.type(g2, m)
      +g3 = O.spawn(g2, x, y, Bool.pick(U32, C.has(C.info(g2, ty2, 21), 256), O.onceiling(), O.onfloor()), ty2)
      +g4 = S.m.angle.set(S.m.spawn.set(g3, n, S.m.spawn(g3, m)), n, O.angle45(a))
      +g5 = C.when(C.has(opt, 8), g4, +h => S.m.flags.set(h, n, (S.m.flags(h, n) .|. 32 : U32)))
      O.remove(S.m.reaction.set(g5, n, 18), m)

def respawn(+g: S.Sim, +m: U32) -> S.Sim:
  +t = T.get(L.Thing, S.mp.things(g), (S.m.spawn(g, m) - 1 : U32), L.Thing{0, 0, 0, 0, 0})
  +x = (O.thing.x(t) << 16n : U32)
  +y = (O.thing.y(t) << 16n : U32)
  +g1 = P.checkpos(g, m, x, y)
  C.when(ok(g1), g1, +h => respawn.go(h, m, t, x, y))

def nightmare(+g: S.Sim, +m: U32) -> S.Sim:
  +c = (S.m.movecount(g, m) + 1 : U32)
  +g1 = S.m.movecount.set(g, m, c)
  +r = C.rnd(g1)
  C.when(Bool.and(F.ge(c, 420), U32.is_eq((S.sim.time(g1) .&. 31 : U32), 0)), g1,
    +h => C.when(U32.is_le(r, 4), C.rnd.next(h), +k => respawn(k, m)))

def mt.tics(+g: S.Sim, +m: U32) -> S.Sim:
  +t = S.m.tics(g, m)
  C.br(U32.is_ne(t, 4294967295), g,
    +h => C.br(U32.is_eq(t, 1), h, +k => O.setstate(S.m.tics.set(k, m, 0), m, C.state(k, S.m.state(k, m), 4)), +k => S.m.tics.set(k, m, (t - 1 : U32))),
    +h => C.when(Bool.and(C.has(S.m.flags(h, m), 4194304), U32.is_eq(S.mp.skill(h), 4)), h, +k => nightmare(k, m)))

def mt.z(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = C.when(Bool.or(U32.is_ne(S.m.z(g, m), S.m.floorz(g, m)), U32.is_ne(S.m.momz(g, m), 0)), g, +h => zmovement(h, m))
  C.when(O.alive(g1, m), g1, +h => mt.tics(h, m))

def mobjthinker(+g: S.Sim, +m: U32) -> S.Sim:
  +moving = Bool.or(Bool.or(U32.is_ne(S.m.momx(g, m), 0), U32.is_ne(S.m.momy(g, m), 0)), C.has(S.m.flags(g, m), 16777216))
  +g1 = C.when(moving, g, +h => xymovement(h, m))
  C.when(O.alive(g1, m), g1, +h => mt.z(h, m))

def use.ptr(+g: S.Sim, +i: S.Icpt) -> S.Sim:
  match i:
    case S.Icpt{+frac, +isline, +ld}:
      +m = S.tm.mo(g)
      C.br(U32.is_eq(C.lspec(g, ld), 0), g,
        +h => C.when(F.le(S.tm.orange(G.opening(h, ld)), 0), G.opening(h, ld), +k => C.stop(k)),
        +h => C.stop(X.use(h, ld, Bool.pick(U32, U32.is_eq(G.pointside(S.m.x(h, m), S.m.y(h, m), S.line(h, ld)), 1), 1, 0), m)))

def uselines(+g: S.Sim) -> S.Sim:
  +m = S.p.mo(g)
  +tb = S.mp.tb(g)
  +a = (S.m.angle(g, m) >> 19n : U32)
  +x = S.m.x(g, m)
  +y = S.m.y(g, m)
  C.resume(G.path(~(+h => +i => use.ptr(h, i)), S.tm.mo.set(g, m), False{}, x, y, (x + 64 * V.sine(tb, (a + 2048 : U32)) : U32), (y + 64 * V.sine(tb, a) : U32)))
