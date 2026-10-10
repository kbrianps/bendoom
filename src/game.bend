import Base
import ./fixed.bend as F
import ./geo.bend as G
import ./items.bend as I
import ./level.bend as L
import ./mem.bend as M
import ./render.bend as V
import ./sim.bend as C
import ./state.bend as S
import ./tab.bend as T
import ./world.bend as R

def onfloor() -> U32:
  2147483648

def onceiling() -> U32:
  2147483647

def viewheight() -> U32:
  2686976

def zero(n: Nat, +g: S.Sim, +m: U32, +f: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      zero(p, S.mput(g, m, f, 0), m, (f + 1 : U32))

def place.z(+g: S.Sim, +m: U32, +z: U32, +k: U32) -> S.Sim:
  +fz = S.m.floorz(g, m)
  +cz = S.m.ceilz(g, m)
  S.m.z.set(g, m, Bool.pick(U32, U32.is_eq(z, onfloor()), fz, Bool.pick(U32, U32.is_eq(z, onceiling()), (cz - C.info(g, k, 17) : U32), z)))

def placed(+g: S.Sim, +m: U32, +z: U32, +k: U32) -> S.Sim:
  +g1 = G.set(g, m)
  +s = C.secof(g1, S.m.sub(g1, m))
  +g2 = S.m.ceilz.set(S.m.floorz.set(g1, m, S.s.floor(g1, s)), m, S.s.ceil(g1, s))
  C.add(place.z(g2, m, z, k), S.TMo{})

def spawn(+g: S.Sim, +x: U32, +y: U32, +z: U32, +k: U32) -> S.Sim:
  +m = C.newid(g)
  +st = C.info(g, k, 1)
  +look = (C.rnd(g) % 4 : U32)
  +g0 = zero(32n, C.rnd.next(g), m, 0)
  +g1 = S.m.radius.set(S.m.y.set(S.m.x.set(S.m.type.set(g0, m, k), m, x), m, y), m, C.info(g0, k, 16))
  +g2 = S.m.health.set(S.m.flags.set(S.m.height.set(g1, m, C.info(g1, k, 17)), m, C.info(g1, k, 21)), m, C.info(g1, k, 2))
  +g3 = S.m.lastlook.set(S.m.reaction.set(g2, m, Bool.pick(U32, U32.is_eq(S.mp.skill(g2), 4), 0, C.info(g2, k, 5))), m, look)
  +g4 = S.m.tics.set(S.m.state.set(g3, m, st), m, C.state(g3, st, 2))
  +g5 = S.m.frame.set(S.m.sprite.set(g4, m, C.state(g4, st, 0)), m, C.state(g4, st, 1))
  placed(g5, m, z, k)

def remove(+g: S.Sim, +m: U32) -> S.Sim:
  C.remove(G.unset(g, m), m)

def setstate.one(+g: S.Sim, +m: U32, +s: U32) -> S.Sim:
  +g1 = S.m.tics.set(S.m.state.set(g, m, s), m, C.state(g, s, 2))
  S.m.frame.set(S.m.sprite.set(g1, m, C.state(g1, s, 0)), m, C.state(g1, s, 1))

def setstate.go?(n: Nat, more: Bool, +g: S.Sim, +m: U32, +s: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +dead = U32.is_eq(s, 0)
      +g1 = C.br(dead, g, +h => remove(S.m.state.set(h, m, 0), m), +h => action(setstate.one(h, m, s), m, C.state(h, s, 3)))
      setstate.go(p, Bool.and(Bool.and(Bool.not(dead), alive(g1, m)), U32.is_eq(S.m.tics(g1, m), 0)), g1, m, C.state(g1, s, 4))
    case _ _:
      g

def setstate(+g: S.Sim, +m: U32, +s: U32) -> S.Sim:
  setstate.go(1000n, True{}, g, m, s)

def alive.of(+t: S.Th) -> Bool:
  match t:
    case S.TMo{}:
      True{}
    case _:
      False{}

def alive(+g: S.Sim, +m: U32) -> Bool:
  alive.of(C.th(g, m))

def angle45(+a: U32) -> U32:
  (536870912 * (a / 45) : U32)

def reborn(+g: S.Sim) -> S.Sim:
  +k = S.p.kills(g)
  +i = S.p.items(g)
  +s = S.p.secrets(g)
  +g0 = S.sim.pl.set(g, T.new(U32, 64, 0))
  +g1 = S.p.secrets.set(S.p.items.set(S.p.kills.set(g0, k), i), s)
  +g2 = S.p.state.set(S.p.attackdown.set(S.p.usedown.set(g1, 1), 1), 0)
  +g3 = S.p.pending.set(S.p.ready.set(S.p.health.set(g2, 100), 1), 1)
  +g4 = S.p.ammo0.set(S.p.own1.set(S.p.own0.set(g3, 1), 1), 50)
  S.p.max3.set(S.p.max2.set(S.p.max1.set(S.p.max0.set(g4, 200), 50), 300), 50)

def spawnplayer?(+g: S.Sim, +x: U32, +y: U32, +a: U32) -> S.Sim:
  +g0 = C.when(U32.is_eq(S.p.state(g), 2), g, +h => reborn(h))
  +m = C.newid(g0)
  +g1 = spawn(g0, (x << 16n : U32), (y << 16n : U32), onfloor(), 0)
  +g2 = S.m.health.set(S.m.player.set(S.m.angle.set(g1, m, angle45(a)), m, 1), m, S.p.health(g1))
  +g3 = S.p.damagecount.set(S.p.message.set(S.p.refire.set(S.p.state.set(S.p.mo.set(g2, m), 0), 0), 0), 0)
  st.start(setuppsprites(S.p.viewheight.set(S.p.fixedcm.set(S.p.extralight.set(S.p.bonuscount.set(g3, 0), 0), 0), viewheight())))

def kind(n: Nat, +g: S.Sim, +ed: U32, +i: U32) -> U32:
  match n:
    case 0n:
      65535
    case 1n+p:
      Bool.pick(U32, U32.is_eq(C.info(g, i, 0), ed), i, kind(p, g, ed, (i + 1 : U32)))

def skillbit(+sk: U32) -> U32:
  Bool.pick(U32, U32.is_eq(sk, 0), 1, Bool.pick(U32, U32.is_eq(sk, 4), 4, (1 << U32.to_nat((sk - 1 : U32)) : U32)))

def placething(+g: S.Sim, +i: U32, +x: U32, +y: U32, +a: U32, +opt: U32, +k: U32) -> S.Sim:
  +m = C.newid(g)
  +fl = C.info(g, k, 21)
  +g1 = spawn(g, (x << 16n : U32), (y << 16n : U32), Bool.pick(U32, C.has(fl, 256), onceiling(), onfloor()), k)
  +g2 = S.m.spawn.set(g1, m, (i + 1 : U32))
  +t = S.m.tics(g2, m)
  +g3 = C.when(Bool.and(U32.is_ne(t, 0), Bool.not(F.is_neg(t))), g2, +h => C.rnd.next(S.m.tics.set(h, m, (1 + C.rnd(h) % t : U32))))
  +g4 = C.when(C.has(fl, 4194304), g3, +h => S.sim.kills.set(h, (S.sim.kills(h) + 1 : U32)))
  +g5 = C.when(C.has(fl, 8388608), g4, +h => S.sim.items.set(h, (S.sim.items(h) + 1 : U32)))
  +g6 = S.m.angle.set(g5, m, angle45(a))
  C.when(C.has(opt, 8), g6, +h => S.m.flags.set(h, m, (S.m.flags(h, m) .|. 32 : U32)))

def mapthing.of(+g: S.Sim, +i: U32, +t: L.Thing) -> S.Sim:
  match t:
    case L.Thing{+x, +y, +a, +ty, +opt}:
      +k = kind(137n, g, ty, 0)
      +skip = Bool.or(Bool.or(U32.is_eq(ty, 11), U32.is_le(ty, 4)), Bool.or(C.has(opt, 16), Bool.not(C.has(opt, skillbit(S.mp.skill(g))))))
      +g1 = C.when(U32.is_eq(ty, 1), g, +h => spawnplayer(h, x, y, a))
      C.when(Bool.not(Bool.or(skip, U32.is_eq(k, 65535))), g1, +h => placething(h, i, x, y, a, opt, k))

def newmonster(+ty: U32) -> Bool:
  Bool.or(Bool.or(Bool.or(U32.is_eq(ty, 68), U32.is_eq(ty, 64)), Bool.or(U32.is_eq(ty, 88), U32.is_eq(ty, 89))),
    Bool.or(Bool.or(Bool.or(U32.is_eq(ty, 69), U32.is_eq(ty, 67)), Bool.or(U32.is_eq(ty, 71), U32.is_eq(ty, 84))), Bool.or(U32.is_eq(ty, 65), U32.is_eq(ty, 66))))

def thing.type(+t: L.Thing) -> U32:
  match t:
    case L.Thing{x, y, a, ty, opt}:
      ty

def things(n: Nat, more: Bool, +g: S.Sim, +i: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +t = T.get(L.Thing, S.mp.things(g), i, L.Thing{0, 0, 0, 0, 0})
      +ok = Bool.or(S.mp.commercial(g), Bool.not(newmonster(thing.type(t))))
      +g1 = C.when(ok, g, +h => mapthing.of(h, i, t))
      things(p, ok, g1, (i + 1 : U32))
    case _ _:
      g

def spawnthings(+g: S.Sim) -> S.Sim:
  +n = T.size(L.Thing, S.mp.things(g))
  things(U32.to_nat(n), True{}, g, 0)

def thing.x(+t: L.Thing) -> U32:
  match t:
    case L.Thing{x, y, a, ty, opt}:
      x

def thing.y(+t: L.Thing) -> U32:
  match t:
    case L.Thing{x, y, a, ty, opt}:
      y

def drop.kind(+k: U32) -> U32:
  Bool.pick(U32, Bool.or(U32.is_eq(k, 23), U32.is_eq(k, 1)), 63,
    Bool.pick(U32, U32.is_eq(k, 2), 77, Bool.pick(U32, U32.is_eq(k, 10), 73, 0)))

def dropped(+g: S.Sim, +d: U32) -> S.Sim:
  S.m.flags.set(g, d, (S.m.flags(g, d) .|. 131072 : U32))

def drop(+g: S.Sim, +t: U32) -> S.Sim:
  +d = C.newid(g)
  +item = drop.kind(S.m.type(g, t))
  C.when(U32.is_ne(item, 0), g, +h => dropped(spawn(h, S.m.x(h, t), S.m.y(h, t), onfloor(), item), d))

def kill.tics(+g: S.Sim, +t: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +tc = (S.m.tics(g1, t) - (r .&. 3) : U32)
  S.m.tics.set(g1, t, Bool.pick(U32, F.lt(tc, 1), 1, tc))

def kill?(+g: S.Sim, +src: U32, +t: U32) -> S.Sim:
  +k = S.m.type(g, t)
  +f0 = C.clr(S.m.flags(g, t), 16793604)
  +f1 = (Bool.pick(U32, U32.is_eq(k, 18), f0, C.clr(f0, 512)) .|. 1049600 : U32)
  +g1 = S.m.height.set(S.m.flags.set(g, t, f1), t, F.sar(S.m.height(g, t), 2n))
  +g2 = C.when(C.has(f1, 4194304), g1, +h => S.p.kills.set(h, (S.p.kills(h) + 1 : U32)))
  +pl = U32.is_ne(S.m.player(g2, t), 0)
  +g3 = C.when(pl, g2, +h => setpsp(S.p.state.set(S.m.flags.set(h, t, C.clr(S.m.flags(h, t), 2)), 1), 0, winfo(S.p.ready(h), 2)))
  +xd = C.info(g3, k, 13)
  +xs = Bool.and(F.lt(S.m.health(g3, t), F.neg(C.info(g3, k, 2))), U32.is_ne(xd, 0))
  +g4 = setstate(g3, t, Bool.pick(U32, xs, xd, C.info(g3, k, 12)))
  drop(kill.tics(g4, t), t)

def push.go(+g: S.Sim, +t: U32, +ang: U32, +thrust: U32) -> S.Sim:
  +tb = S.mp.tb(g)
  +a = (ang >> 19n : U32)
  +g1 = S.m.momx.set(g, t, (S.m.momx(g, t) + F.mul(thrust, V.sine(tb, (a + 2048 : U32))) : U32))
  S.m.momy.set(g1, t, (S.m.momy(g1, t) + F.mul(thrust, V.sine(tb, a)) : U32))

def push.flip(+g: S.Sim, +t: U32, +ang: U32, +thrust: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +f = C.has(r, 1)
  push.go(g1, t, Bool.pick(U32, f, (ang + 2147483648 : U32), ang), Bool.pick(U32, f, (thrust * 4 : U32), thrust))

def push(+g: S.Sim, +t: U32, +inf: U32, +dmg: U32) -> S.Sim:
  +ang = V.angle(S.mp.tb(g), (S.m.x(g, t) - S.m.x(g, inf) : U32), (S.m.y(g, t) - S.m.y(g, inf) : U32))
  +thrust = F.quot((dmg * 819200 : U32), C.info(g, S.m.type(g, t), 18))
  +chance = Bool.and(Bool.and(F.lt(dmg, 40), F.gt(dmg, S.m.health(g, t))), F.gt((S.m.z(g, t) - S.m.z(g, inf) : U32), 4194304))
  C.br(chance, g, +h => push.flip(h, t, ang, thrust), +h => push.go(h, t, ang, thrust))

def awake(+g: S.Sim, +t: U32, +src: U32) -> S.Sim:
  +k = S.m.type(g, t)
  +g1 = S.m.threshold.set(S.m.target.set(g, t, src), t, 100)
  +see = C.info(g1, k, 3)
  C.when(Bool.and(U32.is_eq(S.m.state(g1, t), C.info(g1, k, 1)), U32.is_ne(see, 0)), g1, +h => setstate(h, t, see))

def pain(+g: S.Sim, +t: U32, +src: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +k = S.m.type(g1, t)
  +fl = S.m.flags(g1, t)
  +g2 = C.when(Bool.and(U32.is_lt(r, C.info(g1, k, 8)), Bool.not(C.has(fl, 16777216))), g1,
    +h => setstate(S.m.flags.set(h, t, (fl .|. 64 : U32)), t, C.info(h, k, 7)))
  +g3 = S.m.reaction.set(g2, t, 0)
  +ok = Bool.and(Bool.or(U32.is_eq(S.m.threshold(g3, t), 0), U32.is_eq(k, 3)),
    Bool.and(Bool.and(U32.is_ne(src, 0), U32.is_ne(src, t)), U32.is_ne(S.m.type(g3, src), 3)))
  C.when(ok, g3, +h => awake(h, t, src))

def hurt.player(+g: S.Sim, +src: U32, +dmg: U32, +at: U32, +saved: U32, +all: Bool) -> S.Sim:
  +g1 = C.when(U32.is_ne(at, 0), g, +h => S.p.armor.set(S.p.armortype.set(h, Bool.pick(U32, all, 0, at)), (S.p.armor(h) - saved : U32)))
  +hp = (S.p.health(g1) - dmg : U32)
  +dc = (S.p.damagecount(g1) + dmg : U32)
  +g2 = S.p.attacker.set(S.p.health.set(g1, Bool.pick(U32, F.lt(hp, 0), 0, hp)), src)
  S.p.damagecount.set(g2, Bool.pick(U32, F.gt(dc, 100), 100, dc))

def hurt(+g: S.Sim, +t: U32, +src: U32, +dmg: U32, +pl: Bool) -> S.Sim:
  +at = S.p.armortype(g)
  +ar = S.p.armor(g)
  +saved0 = Bool.pick(U32, U32.is_eq(at, 1), F.quot(dmg, 3), F.quot(dmg, 2))
  +all = F.le(ar, saved0)
  +saved = Bool.pick(U32, all, ar, saved0)
  +d = Bool.pick(U32, Bool.and(pl, U32.is_ne(at, 0)), (dmg - saved : U32), dmg)
  +g1 = C.when(pl, g, +h => hurt.player(h, src, d, at, saved, all))
  +hp = (S.m.health(g1, t) - d : U32)
  +g2 = S.m.health.set(g1, t, hp)
  C.br(F.le(hp, 0), g2, +h => kill(h, src, t), +h => pain(h, t, src))

def damage.go(+g: S.Sim, +t: U32, +inf: U32, +src: U32, +dmg0: U32) -> S.Sim:
  +pl = U32.is_ne(S.m.player(g, t), 0)
  +dmg = Bool.pick(U32, Bool.and(pl, U32.is_eq(S.mp.skill(g), 0)), F.sar(dmg0, 1n), dmg0)
  +fl = S.m.flags(g, t)
  +g1 = C.when(C.has(fl, 16777216), g, +h => S.m.momz.set(S.m.momy.set(S.m.momx.set(h, t, 0), t, 0), t, 0))
  +saw = Bool.and(Bool.and(U32.is_ne(src, 0), U32.is_ne(S.m.player(g1, src), 0)), U32.is_eq(S.p.ready(g1), 7))
  +g2 = C.when(Bool.and(Bool.and(U32.is_ne(inf, 0), Bool.not(C.has(fl, 4096))), Bool.not(saw)), g1, +h => push(h, t, inf, dmg))
  +hp = S.m.health(g2, t)
  +s11 = Bool.and(Bool.and(pl, U32.is_eq(S.s.special(g2, G.mobsec(g2, t)), 11)), F.ge(dmg, hp))
  +d = Bool.pick(U32, s11, (hp - 1 : U32), dmg)
  +god = Bool.and(Bool.and(pl, F.lt(d, 1000)), Bool.or(C.has(S.p.cheats(g2), 2), U32.is_ne(S.p.pw0(g2), 0)))
  C.when(Bool.not(god), g2, +h => hurt(h, t, src, d, pl))

def damage(+g: S.Sim, +t: U32, +inf: U32, +src: U32, +dmg: U32) -> S.Sim:
  C.when(Bool.and(C.has(S.m.flags(g, t), 4), F.gt(S.m.health(g, t), 0)), g, +h => damage.go(h, t, inf, src, dmg))

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
  +g2 = damage(g1, th, tm, tm, dmg)
  +g3 = S.m.flags.set(g2, tm, C.clr(S.m.flags(g2, tm), 16777216))
  +g4 = S.m.momz.set(S.m.momy.set(S.m.momx.set(g3, tm, 0), tm, 0), tm, 0)
  C.stop(setstate(g4, tm, C.info(g4, S.m.type(g4, tm), 1)))

def missilehit(+g: S.Sim, +tm: U32, +th: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +dmg = (((r % 8) + 1) * C.info(g1, S.m.type(g1, tm), 19) : U32)
  C.stop(damage(g1, th, tm, S.m.target(g1, tm), dmg))

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
  C.br(Bool.and(U32.is_eq(S.m.player(g, tm), 0), U32.is_ne(S.mp.map(g), 30)), g, +h => C.stop(h), +h => damage(h, th, tm, tm, 10000))

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
  +g1 = damage(g, th, 0, 0, 10)
  +b = C.newid(g1)
  blood.mom(spawn(g1, S.m.x(g1, th), S.m.y(g1, th), (S.m.z(g1, th) + F.quot(S.m.height(g1, th), 2) : U32), 38), b)

def gib(+g: S.Sim, +th: U32) -> S.Sim:
  +g1 = setstate(g, th, 895)
  S.m.radius.set(S.m.height.set(S.m.flags.set(g1, th, C.clr(S.m.flags(g1, th), 2)), th, 0), th, 0)

def crushed(+g: S.Sim, +th: U32) -> S.Sim:
  +fl = S.m.flags(g, th)
  C.br(F.le(S.m.health(g, th), 0), g, +h => gib(h, th),
    +h => C.br(C.has(fl, 131072), h, +k => remove(k, th),
      +k => C.when(C.has(fl, 4), k, +q => C.when(Bool.and(U32.is_ne(S.tm.crush(q), 0), U32.is_eq((S.sim.time(q) .&. 3 : U32), 0)), S.tm.nofit.set(q, 1), +r => crunch(r, th)))))

def pit.change(+g: S.Sim, +th: U32) -> S.Sim:
  +g1 = heightclip(g, th)
  C.when(U32.is_eq(S.tm.ok(g1), 0), g1, +h => crushed(h, th))

def changesector(+g: S.Sim, +s: U32, +crush: U32) -> S.Sim:
  +g1 = S.tm.crush.set(S.tm.nofit.set(g, 0), crush)
  G.area(~(+h => +bx => +by => G.bthings(~(+k => +t => pit.change(k, t)), h, bx, by)), g1,
    C.secbox(g1, s, 2), C.secbox(g1, s, 3), C.secbox(g1, s, 1), C.secbox(g1, s, 0))

def nosec() -> U32:
  65535

def neg1() -> U32:
  4294967295

def fu() -> U32:
  65536

def vdoorspeed() -> U32:
  131072

def nextsec.of(+l: S.RLine, +s: U32) -> U32:
  Bool.pick(U32, C.has(S.ln.flags(l), 4), Bool.pick(U32, U32.is_eq(S.ln.fsec(l), s), S.ln.bsec(l), S.ln.fsec(l)), nosec())

def nextsec(+g: S.Sim, +ld: U32, +s: U32) -> U32:
  nextsec.of(S.line(g, ld), s)

def lfold(~f: S.Sim -> U32 -> U32 -> U32 -> U32, +g: S.Sim, +s: U32, xs: List<&2, U32>, +acc: U32) -> U32:
  match xs:
    case +x <> t:
      lfold(~f, g, s, t, f(g, s, acc, x))
    case []:
      acc

def real(+o: U32) -> Bool:
  U32.is_ne(o, nosec())

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
  changesector(plane.set(g, s, fc, v), s, crush)

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
      nosec()
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
      nosec()
    case 1n+p:
      C.pick(U32, U32.is_ge(i, S.mp.nsec(g)), +u => nosec(),
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
      S.P2{nosec(), height}

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
      nosec()

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
      +hit = Bool.and(Bool.and(alive(g, t), U32.is_eq(S.m.type(g, t), 41)), U32.is_eq(G.mobsec(g, t), s))
      C.pick(U32, hit, +u => t, +u => tele.find(p, U32.is_ne(C.tnext(g, t), 0), g, s, C.tnext(g, t)))
    case _ _:
      0

def tele.done(+g: S.Sim, +th: U32, +d: U32, +ox: U32, +oy: U32, +oz: U32) -> S.Sim:
  +g1 = S.m.z.set(g, th, S.m.floorz(g, th))
  +pl = U32.is_ne(S.m.player(g1, th), 0)
  +g2 = C.when(pl, g1, +h => S.p.viewz.set(h, (S.m.z(h, th) + S.p.viewheight(h) : U32)))
  +g3 = spawn(g2, ox, oy, oz, 39)
  +an = (S.m.angle(g3, d) >> 19n : U32)
  +tb = S.mp.tb(g3)
  +fx = (S.m.x(g3, d) + 20 * V.sine(tb, (an + 2048 : U32)) : U32)
  +fy = (S.m.y(g3, d) + 20 * V.sine(tb, an) : U32)
  +g4 = spawn(g3, fx, fy, S.m.z(g3, th), 39)
  +g5 = C.when(pl, g4, +h => S.m.reaction.set(h, th, 18))
  +g6 = S.m.momz.set(S.m.momy.set(S.m.momx.set(S.m.angle.set(g5, th, S.m.angle(g5, d)), th, 0), th, 0), th, 0)
  S.sim.ret.set(g6, 1)

def tele.go(+g: S.Sim, +th: U32, +d: U32) -> S.Sim:
  +ox = S.m.x(g, th)
  +oy = S.m.y(g, th)
  +oz = S.m.z(g, th)
  +g1 = teleportmove(g, th, S.m.x(g, d), S.m.y(g, d))
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
      nosec()
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
  C.when(Bool.and(ok, U32.is_eq((S.sim.time(g) .&. 31 : U32), 0)), g, +h => damage(h, m, 0, 0, dmg))

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
      anim.go(ids, g, tex, ids, len(ids), ((S.sim.time(g) / speed) + base : U32), 0)

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

def ok(+g: S.Sim) -> Bool:
  U32.is_ne(S.tm.ok(g), 0)

def crossing(n: Nat, xs: List<&2, U32>, +g: S.Sim, +m: U32, +ox: U32, +oy: U32) -> S.Sim:
  match n xs:
    case 1n+p +ld <> t:
      +g1 = S.tm.spechit.set(g, t)
      +side = G.pointside(S.m.x(g1, m), S.m.y(g1, m), S.line(g1, ld))
      +old = G.pointside(ox, oy, S.line(g1, ld))
      +g2 = C.when(Bool.and(U32.is_ne(side, old), U32.is_ne(C.lspec(g1, ld), 0)), g1, +h => cross(h, ld, old, m))
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
  +g1 = checkpos(S.tm.floatok.set(g, 0), m, x, y)
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

def explode?(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = S.m.momz.set(S.m.momy.set(S.m.momx.set(g, m, 0), m, 0), m, 0)
  +g2 = setstate(g1, m, C.info(g1, S.m.type(g1, m), 12))
  +r = C.rnd(g2)
  +g3 = C.rnd.next(g2)
  +t = (S.m.tics(g3, m) - (r .&. 3) : U32)
  +g4 = S.m.tics.set(g3, m, Bool.pick(U32, F.lt(t, 1), 1, t))
  +ds = C.info(g4, S.m.type(g4, m), 14)
  +g5 = S.m.flags.set(g4, m, C.clr(S.m.flags(g4, m), 65536))
  C.when(U32.is_ne(ds, 0), g5, +h => sound(h, m, ds))

def skywall(+g: S.Sim) -> Bool:
  +cl = S.tm.ceilline(g)
  +b = Bool.pick(U32, U32.is_eq(cl, none()), 65535, S.l.bsec(g, cl))
  Bool.and(U32.is_ne(b, 65535), U32.is_eq(S.s.cpic(g, b), C.sky()))

def xy.blocked(+g: S.Sim, +m: U32) -> S.Sim:
  C.br(U32.is_ne(S.m.player(g, m), 0), g, +h => slidemove(h, m),
    +h => C.br(C.has(S.m.flags(h, m), 65536), h, +k => C.br(skywall(k), k, +q => remove(q, m), +q => explode(q, m)),
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
      xy.loop(p, Bool.and(alive(g2, m), Bool.or(U32.is_ne(nx, 0), U32.is_ne(ny, 0))), g2, m, nx, ny)
    case _ _:
      g

def clamp(+v: U32) -> U32:
  Bool.pick(U32, F.gt(v, 1966080), 1966080, Bool.pick(U32, F.lt(v, 4293001216), 4293001216, v))

def friction.stop(+g: S.Sim, +m: U32, +pl: Bool) -> S.Sim:
  +run = U32.is_lt((S.m.state(g, m) - 150 : U32), 4)
  +g1 = C.when(Bool.and(pl, run), g, +h => setstate(h, m, 149))
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
  C.when(alive(g1, m), g1, +h => friction(h, m))

def xymovement(+g: S.Sim, +m: U32) -> S.Sim:
  +still = Bool.and(U32.is_eq(S.m.momx(g, m), 0), U32.is_eq(S.m.momy(g, m), 0))
  C.br(still, g,
    +h => C.when(C.has(S.m.flags(h, m), 16777216), h,
      +k => setstate(S.m.momz.set(S.m.momy.set(S.m.momx.set(S.m.flags.set(k, m, C.clr(S.m.flags(k, m), 16777216)), m, 0), m, 0), m, 0), m, C.info(k, S.m.type(k, m), 1))),
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
  S.p.dvh.set(S.p.viewheight.set(g, vh), F.sar((viewheight() - vh : U32), 3n))

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
      +g1 = spawn(g, S.m.x(g, m), S.m.y(g, m), S.s.floor(g, G.mobsec(g, m)), 39)
      +g2 = spawn(g1, x, y, S.s.floor(g1, G.secat(g1, x, y)), 39)
      +n = C.newid(g2)
      +ty2 = S.m.type(g2, m)
      +g3 = spawn(g2, x, y, Bool.pick(U32, C.has(C.info(g2, ty2, 21), 256), onceiling(), onfloor()), ty2)
      +g4 = S.m.angle.set(S.m.spawn.set(g3, n, S.m.spawn(g3, m)), n, angle45(a))
      +g5 = C.when(C.has(opt, 8), g4, +h => S.m.flags.set(h, n, (S.m.flags(h, n) .|. 32 : U32)))
      remove(S.m.reaction.set(g5, n, 18), m)

def respawn(+g: S.Sim, +m: U32) -> S.Sim:
  +t = T.get(L.Thing, S.mp.things(g), (S.m.spawn(g, m) - 1 : U32), L.Thing{0, 0, 0, 0, 0})
  +x = (thing.x(t) << 16n : U32)
  +y = (thing.y(t) << 16n : U32)
  +g1 = checkpos(g, m, x, y)
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
    +h => C.br(U32.is_eq(t, 1), h, +k => setstate(S.m.tics.set(k, m, 0), m, C.state(k, S.m.state(k, m), 4)), +k => S.m.tics.set(k, m, (t - 1 : U32))),
    +h => C.when(Bool.and(C.has(S.m.flags(h, m), 4194304), U32.is_eq(S.mp.skill(h), 4)), h, +k => nightmare(k, m)))

def mt.z(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = C.when(Bool.or(U32.is_ne(S.m.z(g, m), S.m.floorz(g, m)), U32.is_ne(S.m.momz(g, m), 0)), g, +h => zmovement(h, m))
  C.when(alive(g1, m), g1, +h => mt.tics(h, m))

def mobjthinker(+g: S.Sim, +m: U32) -> S.Sim:
  +moving = Bool.or(Bool.or(U32.is_ne(S.m.momx(g, m), 0), U32.is_ne(S.m.momy(g, m), 0)), C.has(S.m.flags(g, m), 16777216))
  +g1 = C.when(moving, g, +h => xymovement(h, m))
  C.when(alive(g1, m), g1, +h => mt.z(h, m))

def use.ptr(+g: S.Sim, +i: S.Icpt) -> S.Sim:
  match i:
    case S.Icpt{+frac, +isline, +ld}:
      +m = S.tm.mo(g)
      C.br(U32.is_eq(C.lspec(g, ld), 0), g,
        +h => C.when(F.le(S.tm.orange(G.opening(h, ld)), 0), G.opening(h, ld), +k => C.stop(k)),
        +h => C.stop(use(h, ld, Bool.pick(U32, U32.is_eq(G.pointside(S.m.x(h, m), S.m.y(h, m), S.line(h, ld)), 1), 1, 0), m)))

def uselines(+g: S.Sim) -> S.Sim:
  +m = S.p.mo(g)
  +tb = S.mp.tb(g)
  +a = (S.m.angle(g, m) >> 19n : U32)
  +x = S.m.x(g, m)
  +y = S.m.y(g, m)
  C.resume(G.path(~(+h => +i => use.ptr(h, i)), S.tm.mo.set(g, m), False{}, x, y, (x + 64 * V.sine(tb, (a + 2048 : U32)) : U32), (y + 64 * V.sine(tb, a) : U32)))

def vh() -> U32:
  2686976

def thrust(+g: S.Sim, +m: U32, +ang: U32, +mv: U32) -> S.Sim:
  +tb = S.mp.tb(g)
  +a = (ang >> 19n : U32)
  +g1 = S.m.momx.set(g, m, (S.m.momx(g, m) + F.mul(mv, V.sine(tb, (a + 2048 : U32))) : U32))
  S.m.momy.set(g1, m, (S.m.momy(g1, m) + F.mul(mv, V.sine(tb, a)) : U32))

def bobview(+g: S.Sim) -> S.Sim:
  +v = (S.p.viewheight(g) + S.p.dvh(g) : U32)
  +g1 = C.br(F.gt(v, vh()), g, +h => S.p.dvh.set(S.p.viewheight.set(h, vh()), 0), +h => S.p.viewheight.set(h, v))
  +g2 = C.when(F.lt(S.p.viewheight(g1), 1343488), g1,
    +h => C.when(F.le(S.p.dvh(h), 0), S.p.viewheight.set(h, 1343488), +k => S.p.dvh.set(k, 1)))
  +d = S.p.dvh(g2)
  C.when(U32.is_ne(d, 0), g2, +h => S.p.dvh.set(h, Bool.pick(U32, U32.is_eq((d + 16384 : U32), 0), 1, (d + 16384 : U32))))

def calcheight.ground(+g: S.Sim, +m: U32) -> S.Sim:
  +tb = S.mp.tb(g)
  +ang = ((409 * S.sim.time(g)) .&. 8191 : U32)
  +bob = F.mul(F.quot(S.p.bob(g), 2), V.sine(tb, ang))
  +g1 = C.when(U32.is_eq(S.p.state(g), 0), g, +h => bobview(h))
  +vz = (S.m.z(g1, m) + S.p.viewheight(g1) + bob : U32)
  +top = (S.m.ceilz(g1, m) - 262144 : U32)
  S.p.viewz.set(g1, Bool.pick(U32, F.gt(vz, top), top, vz))

def calcheight(+g: S.Sim) -> S.Sim:
  +m = S.p.mo(g)
  +mx = S.m.momx(g, m)
  +my = S.m.momy(g, m)
  +b = F.sar((F.mul(mx, mx) + F.mul(my, my) : U32), 2n)
  +g1 = S.p.bob.set(g, Bool.pick(U32, F.gt(b, 1048576), 1048576, b))
  C.br(Bool.or(C.has(S.p.cheats(g1), 4), U32.is_eq(S.p.onground(g1), 0)), g1,
    +h => S.p.viewz.set(h, (S.m.z(h, m) + S.p.viewheight(h) : U32)),
    +h => calcheight.ground(h, m))

def moveplayer(+g: S.Sim) -> S.Sim:
  +m = S.p.mo(g)
  +fwd = S.p.fwd(g)
  +side = S.p.side(g)
  +g1 = S.m.angle.set(g, m, (S.m.angle(g, m) + (S.p.turn(g) << 16n) : U32))
  +on = F.le(S.m.z(g1, m), S.m.floorz(g1, m))
  +g2 = S.p.onground.set(g1, C.b2u(on))
  +g3 = C.when(Bool.and(U32.is_ne(fwd, 0), on), g2, +h => thrust(h, m, S.m.angle(h, m), (fwd * 2048 : U32)))
  +g4 = C.when(Bool.and(U32.is_ne(side, 0), on), g3, +h => thrust(h, m, (S.m.angle(h, m) - 1073741824 : U32), (side * 2048 : U32)))
  C.when(Bool.and(Bool.or(U32.is_ne(fwd, 0), U32.is_ne(side, 0)), U32.is_eq(S.m.state(g4, m), 149)), g4, +h => setstate(h, m, 150))

def dec(+v: U32) -> U32:
  Bool.pick(U32, U32.is_ne(v, 0), (v - 1 : U32), 0)

def turntoward(+g: S.Sim, +m: U32, +att: U32) -> S.Sim:
  +a = V.angle(S.mp.tb(g), (S.m.x(g, att) - S.m.x(g, m) : U32), (S.m.y(g, att) - S.m.y(g, m) : U32))
  +ma = S.m.angle(g, m)
  +d = (a - ma : U32)
  C.br(Bool.or(U32.is_lt(d, 59652323), U32.is_gt(d, 4235314973)), g, +h => S.p.damagecount.set(S.m.angle.set(h, m, a), dec(S.p.damagecount(h))),
    +h => S.m.angle.set(h, m, Bool.pick(U32, U32.is_lt(d, 2147483648), (ma + 59652323 : U32), (ma - 59652323 : U32))))

def deaththink?(+g: S.Sim) -> S.Sim:
  deaththink.go(movepsprites(g))

def deaththink.go(+g: S.Sim) -> S.Sim:
  +m = S.p.mo(g)
  +v0 = S.p.viewheight(g)
  +v1 = Bool.pick(U32, F.gt(v0, 393216), (v0 - 65536 : U32), v0)
  +g1 = S.p.dvh.set(S.p.viewheight.set(g, Bool.pick(U32, F.lt(v1, 393216), 393216, v1)), 0)
  +g2 = calcheight(S.p.onground.set(g1, C.b2u(F.le(S.m.z(g1, m), S.m.floorz(g1, m)))))
  +att = S.p.attacker(g2)
  +g3 = C.br(Bool.and(U32.is_ne(att, 0), U32.is_ne(att, m)), g2, +h => turntoward(h, m, att), +h => S.p.damagecount.set(h, dec(S.p.damagecount(h))))
  C.when(C.has(S.p.buttons(g3), 2), g3, +h => S.p.state.set(h, 2))

def newweapon(+g: S.Sim, +b: U32) -> S.Sim:
  +w0 = ((b .&. 56) >> 3n : U32)
  +rw = S.p.ready(g)
  +w1 = Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(w0, 0), U32.is_ne(I.own(g, 7), 0)), Bool.not(Bool.and(U32.is_eq(rw, 7), U32.is_ne(S.p.pw1(g), 0)))), 7, w0)
  +w = Bool.pick(U32, Bool.and(Bool.and(S.mp.commercial(g), U32.is_eq(w1, 2)), Bool.and(U32.is_ne(I.own(g, 8), 0), U32.is_ne(rw, 8))), 8, w1)
  C.when(Bool.and(U32.is_ne(I.own(g, w), 0), U32.is_ne(w, rw)), g, +h => S.p.pending.set(h, w))

def colormap(+g: S.Sim) -> U32:
  +inv = S.p.pw0(g)
  +ir = S.p.pw5(g)
  Bool.pick(U32, U32.is_ne(inv, 0), Bool.pick(U32, Bool.or(F.gt(inv, 128), C.has(inv, 8)), 32, 0),
    Bool.pick(U32, U32.is_ne(ir, 0), Bool.pick(U32, Bool.or(F.gt(ir, 128), C.has(ir, 8)), 1, 0), 0))

def powers(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = C.when(U32.is_ne(S.p.pw1(g), 0), g, +h => S.p.pw1.set(h, (S.p.pw1(h) + 1 : U32)))
  +g2 = S.p.pw0.set(g1, dec(S.p.pw0(g1)))
  +iv = S.p.pw2(g2)
  +g3 = C.when(U32.is_ne(iv, 0), g2, +h => C.when(U32.is_eq(iv, 1), S.p.pw2.set(h, 0), +k => S.m.flags.set(k, m, C.clr(S.m.flags(k, m), 262144))))
  +g4 = C.when(F.gt(S.p.pw2(g3), 1), g3, +h => S.p.pw2.set(h, (S.p.pw2(h) - 1 : U32)))
  +g5 = S.p.pw3.set(S.p.pw5.set(g4, dec(S.p.pw5(g4))), dec(S.p.pw3(g4)))
  +g6 = S.p.bonuscount.set(S.p.damagecount.set(g5, dec(S.p.damagecount(g5))), dec(S.p.bonuscount(g5)))
  S.p.fixedcm.set(g6, colormap(g6))

def live?(+g: S.Sim, +m: U32) -> S.Sim:
  +r = S.m.reaction(g, m)
  +g1 = C.br(U32.is_ne(r, 0), g, +h => S.m.reaction.set(h, m, (r - 1 : U32)), +h => moveplayer(h))
  +g2 = calcheight(g1)
  +g3 = C.when(U32.is_ne(S.s.special(g2, G.mobsec(g2, m)), 0), g2, +h => playerin(h))
  +g4 = C.when(C.has(S.p.buttons(g3), 128), g3, +h => S.p.buttons.set(h, 0))
  +b = S.p.buttons(g4)
  +g5 = C.when(C.has(b, 4), g4, +h => newweapon(h, b))
  +g6 = C.br(C.has(b, 2), g5, +h => C.when(U32.is_eq(S.p.usedown(h), 0), h, +k => S.p.usedown.set(uselines(k), 1)), +h => S.p.usedown.set(h, 0))
  powers(movepsprites(g6), m)

def playerthink(+g: S.Sim) -> S.Sim:
  +m = S.p.mo(g)
  +fl0 = S.m.flags(g, m)
  +fl1 = Bool.pick(U32, C.has(S.p.cheats(g), 1), (fl0 .|. 4096 : U32), C.clr(fl0, 4096))
  +ja = C.has(fl1, 128)
  +g1 = S.m.flags.set(g, m, Bool.pick(U32, ja, C.clr(fl1, 128), fl1))
  +g2 = C.when(ja, g1, +h => S.p.side.set(S.p.fwd.set(S.p.turn.set(h, 0), 100), 0))
  C.br(U32.is_eq(S.p.state(g2), 1), g2, +h => deaththink(h), +h => live(h, m))

def run.of(+g: S.Sim, +id: U32, t: S.Th) -> S.Sim:
  match t:
    case S.TDead{}:
      C.unlink(g, id)
    case S.TMo{}:
      mobjthinker(g, id)
    case S.TNone{}:
      g
    case _:
      think(g, id, C.th(g, id))

def runthinkers.go(n: Nat, more: Bool, +g: S.Sim, +id: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = run.of(g, id, C.th(g, id))
      +nx = C.tnext(g1, id)
      runthinkers.go(p, U32.is_ne(nx, 0), g1, nx)
    case _ _:
      g

def runthinkers(+g: S.Sim) -> S.Sim:
  +first = C.tnext(g, 0)
  runthinkers.go(65536n, U32.is_ne(first, 0), g, first)

def ticker?(+g: S.Sim) -> S.Sim:
  +g1 = update(runthinkers(playerthink(S.sim.snd.set(g, []))))
  hu.ticker(st.ticker(S.sim.tic.set(S.sim.time.set(g1, (S.sim.time(g1) + 1 : U32)), (S.sim.tic(g1) + 1 : U32))))

def yes(+g: S.Sim) -> Bool:
  U32.is_eq(S.sim.ret(g), 1)


def sound(+g: S.Sim, +o: U32, +sfx: U32) -> S.Sim:
  S.sim.snd.set(g, (o * 128 + sfx : U32) <> S.sim.snd(g))


def subr(+g: S.Sim) -> U32:
  (C.rnd(g) - C.rnd(C.rnd.next(g)) : U32)


def subr.next(+g: S.Sim) -> S.Sim:
  C.rnd.next(C.rnd.next(g))


def sdiv(+a: U32, +b: U32) -> U32:
  +mag = Bool.pick(U32, U32.is_eq(b, 0), 0, (F.abs(a) / F.abs(b) : U32))
  Bool.pick(U32, F.is_neg((a .^. b : U32)), F.neg(mag), mag)


def tics.rand(+g: S.Sim, +m: U32, +mask: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +t = (S.m.tics(g1, m) - (r .&. mask) : U32)
  S.m.tics.set(g1, m, Bool.pick(U32, F.lt(t, 1), 1, t))


def cosine(+g: S.Sim, +a: U32) -> U32:
  V.sine(S.mp.tb(g), ((a >> 19n) + 2048 : U32))


def sinus(+g: S.Sim, +a: U32) -> U32:
  V.sine(S.mp.tb(g), (a >> 19n : U32))


def toward(+g: S.Sim, +a: U32, +b: U32) -> U32:
  V.angle(S.mp.tb(g), (S.m.x(g, b) - S.m.x(g, a) : U32), (S.m.y(g, b) - S.m.y(g, a) : U32))


def apart(+g: S.Sim, +a: U32, +b: U32) -> U32:
  G.aprox((S.m.x(g, b) - S.m.x(g, a) : U32), (S.m.y(g, b) - S.m.y(g, a) : U32))


def boss(+k: U32) -> Bool:
  Bool.or(U32.is_eq(k, 19), U32.is_eq(k, 21))


def rejected(+g: S.Sim, +s1: U32, +s2: U32) -> Bool:
  +pn = (s1 * S.mp.nsec(g) + s2 : U32)
  C.has(T.get(U32, S.mp.reject(g), (pn >> 3n : U32), 0), (1 << U32.to_nat((pn .&. 7 : U32)) : U32))


def dline(+x: U32, +y: U32, +nx: U32, +ny: U32, +ndx: U32, +ndy: U32) -> U32:
  +l = (F.sar(ndy, 16n) * F.sar((x - nx : U32), 16n) : U32)
  +r = (F.sar((y - ny : U32), 16n) * F.sar(ndx, 16n) : U32)
  Bool.pick(U32, F.lt(r, l), 0, Bool.pick(U32, U32.is_eq(l, r), 2, 1))


def dside(+x: U32, +y: U32, +nx: U32, +ny: U32, +ndx: U32, +ndy: U32) -> U32:
  Bool.pick(U32, U32.is_eq(ndx, 0), Bool.pick(U32, U32.is_eq(x, nx), 2, C.b2u(Bool.pick(Bool, F.le(x, nx), F.gt(ndy, 0), F.lt(ndy, 0)))),
    Bool.pick(U32, U32.is_eq(ndy, 0), Bool.pick(U32, U32.is_eq(x, ny), 2, C.b2u(Bool.pick(Bool, F.le(y, ny), F.lt(ndx, 0), F.gt(ndx, 0)))),
      dline(x, y, nx, ny, ndx, ndy)))


def dside.node(+x: U32, +y: U32, +n: L.Node) -> U32:
  match n:
    case L.Node{+nx, +ny, +ndx, +ndy, rb, lb, r, l}:
      dside(x, y, (nx << 16n : U32), (ny << 16n : U32), (ndx << 16n : U32), (ndy << 16n : U32))


def sight.slopes(+g: S.Sim, +fs: U32, +bs: U32, +x1: U32, +y1: U32, +dx: U32, +dy: U32) -> S.Sim:
  +ff = S.s.floor(g, fs)
  +fb = S.s.floor(g, bs)
  +cf = S.s.ceil(g, fs)
  +cb = S.s.ceil(g, bs)
  +top = Bool.pick(U32, F.lt(cf, cb), cf, cb)
  +bot = Bool.pick(U32, F.gt(ff, fb), ff, fb)
  +sz = S.tm.sz(g)
  +frac = G.intercept(S.tm.sx(g), S.tm.sy(g), S.tm.sdx(g), S.tm.sdy(g), x1, y1, dx, dy)
  +bs0 = S.tm.bots(g)
  +ts0 = S.tm.tops(g)
  +bsl = F.div((bot - sz : U32), frac)
  +tsl = F.div((top - sz : U32), frac)
  +b = Bool.pick(U32, Bool.and(U32.is_ne(ff, fb), F.gt(bsl, bs0)), bsl, bs0)
  +t = Bool.pick(U32, Bool.and(U32.is_ne(cf, cb), F.lt(tsl, ts0)), tsl, ts0)
  +same = Bool.and(U32.is_eq(ff, fb), U32.is_eq(cf, cb))
  C.br(same, g, +h => h,
    +h => C.br(F.ge(bot, top), h, +k => C.stop(k),
      +k => C.when(F.le(t, b), S.tm.bots.set(S.tm.tops.set(k, t), b), +q => C.stop(q))))


def sight.line(+g: S.Sim, +l: S.RLine) -> S.Sim:
  match l:
    case S.RLine{+x1, +y1, +x2, +y2, +dx, +dy, +fl, sl, t, b, le, ri, s0, s1, +fs, +bs, tg}:
      +sx = S.tm.sx(g)
      +sy = S.tm.sy(g)
      +sdx = S.tm.sdx(g)
      +sdy = S.tm.sdy(g)
      +a1 = dside(x1, y1, sx, sy, sdx, sdy)
      +a2 = dside(x2, y2, sx, sy, sdx, sdy)
      +b1 = dside(sx, sy, x1, y1, dx, dy)
      +b2 = dside(S.tm.t2x(g), S.tm.t2y(g), x1, y1, dx, dy)
      C.when(Bool.and(U32.is_ne(a1, a2), U32.is_ne(b1, b2)), g,
        +h => C.br(Bool.not(C.has(fl, 4)), h, +k => C.stop(k), +k => sight.slopes(k, fs, bs, x1, y1, dx, dy)))


def sight.segs(n: Nat, more: Bool, +g: S.Sim, +i: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +ld = T.get(U32, S.mp.segline(g), i, 0)
      +g1 = C.when(Bool.not(C.seen(g, ld)), g, +h => sight.line(C.mark(h, ld), S.line(h, ld)))
      sight.segs(p, Bool.not(C.halted(g1)), g1, (i + 1 : U32))
    case _ _:
      g


def sight.sub.of(+g: S.Sim, +s: L.Sub) -> S.Sim:
  match s:
    case L.Sub{+c, +f}:
      sight.segs(U32.to_nat(c), U32.is_ne(c, 0), g, f)


def sight.sub(+g: S.Sim, +num: U32) -> S.Sim:
  sight.sub.of(g, T.get(L.Sub, R.subs(S.sim.w(g)), num, L.Sub{0, 0}))


def sight.split?(+g: S.Sim, +bsp: U32) -> S.Sim:
  +nd = R.node(S.sim.w(g), bsp)
  +s0 = dside.node(S.tm.sx(g), S.tm.sy(g), nd)
  +side = Bool.pick(U32, U32.is_eq(s0, 2), 0, s0)
  +g1 = sight.node(g, G.child(nd, U32.is_eq(side, 1)))
  C.br(Bool.or(C.halted(g1), U32.is_eq(side, dside.node(S.tm.t2x(g1), S.tm.t2y(g1), nd))), g1, +h => h,
    +h => sight.node(h, G.child(nd, U32.is_eq(side, 0))))


def sight.node?(+g: S.Sim, +bsp: U32) -> S.Sim:
  C.br(C.has(bsp, 32768), g, +h => sight.sub(h, Bool.pick(U32, U32.is_eq(bsp, 4294967295), 0, (bsp .&. 32767 : U32))), +h => sight.split(h, bsp))


def sight.run(+g: S.Sim, +t1: U32, +t2: U32) -> S.Sim:
  +z1 = S.m.z(g, t1)
  +h1 = S.m.height(g, t1)
  +sz = (z1 + h1 - F.sar(h1, 2n) : U32)
  +x1 = S.m.x(g, t1)
  +y1 = S.m.y(g, t1)
  +x2 = S.m.x(g, t2)
  +y2 = S.m.y(g, t2)
  +z2 = S.m.z(g, t2)
  +g1 = S.tm.bots.set(S.tm.tops.set(S.tm.sz.set(g, sz), (z2 + S.m.height(g, t2) - sz : U32)), (z2 - sz : U32))
  +g2 = S.tm.sdy.set(S.tm.sdx.set(S.tm.sy.set(S.tm.sx.set(g1, x1), y1), (x2 - x1 : U32)), (y2 - y1 : U32))
  +g3 = C.vc.bump(S.tm.t2y.set(S.tm.t2x.set(g2, x2), y2))
  +nn = T.size(L.Node, R.nodes(S.sim.w(g3)))
  +g4 = sight.node(g3, (nn - 1 : U32))
  S.sim.ret.set(C.resume(g4), C.b2u(Bool.not(C.halted(g4))))


def checksight(+g: S.Sim, +t1: U32, +t2: U32) -> S.Sim:
  C.br(rejected(g, G.mobsec(g, t1), G.mobsec(g, t2)), g, +h => S.sim.ret.set(h, 0), +h => sight.run(h, t1, t2))


def aim.slopes(+g: S.Sim, +ld: U32, +frac: U32) -> S.Sim:
  +ot = S.tm.otop(g)
  +ob = S.tm.obottom(g)
  +dist = F.mul(S.tm.range(g), frac)
  +fs = S.l.fsec(g, ld)
  +bs = S.l.bsec(g, ld)
  +sz = S.tm.shootz(g)
  +b0 = S.tm.bots(g)
  +t0 = S.tm.tops(g)
  +bsl = F.div((ob - sz : U32), dist)
  +tsl = F.div((ot - sz : U32), dist)
  +b = Bool.pick(U32, Bool.and(U32.is_ne(S.s.floor(g, fs), S.s.floor(g, bs)), F.gt(bsl, b0)), bsl, b0)
  +t = Bool.pick(U32, Bool.and(U32.is_ne(S.s.ceil(g, fs), S.s.ceil(g, bs)), F.lt(tsl, t0)), tsl, t0)
  +g1 = S.tm.bots.set(S.tm.tops.set(g, t), b)
  C.when(F.le(t, b), g1, +h => C.stop(h))


def aim.open(+g: S.Sim, +ld: U32, +frac: U32) -> S.Sim:
  C.br(F.ge(S.tm.obottom(g), S.tm.otop(g)), g, +h => C.stop(h), +h => aim.slopes(h, ld, frac))


def aim.line(+g: S.Sim, +ld: U32, +frac: U32) -> S.Sim:
  C.br(Bool.not(C.has(S.l.flags(g, ld), 4)), g, +h => C.stop(h), +h => aim.open(G.opening(h, ld), ld, frac))


def aim.hit(+g: S.Sim, +th: U32, +frac: U32) -> S.Sim:
  +dist = F.mul(S.tm.range(g), frac)
  +sz = S.tm.shootz(g)
  +z = S.m.z(g, th)
  +tt0 = F.div((z + S.m.height(g, th) - sz : U32), dist)
  +tb0 = F.div((z - sz : U32), dist)
  +bots = S.tm.bots(g)
  +tops = S.tm.tops(g)
  +tt = Bool.pick(U32, F.gt(tt0, tops), tops, tt0)
  +tb = Bool.pick(U32, F.lt(tb0, bots), bots, tb0)
  C.when(Bool.not(Bool.or(F.lt(tt0, bots), F.gt(tb0, tops))), g,
    +h => C.stop(S.tm.ltarget.set(S.tm.aim.set(h, F.quot((tt + tb : U32), 2)), th)))


def aim.thing(+g: S.Sim, +th: U32, +frac: U32) -> S.Sim:
  C.when(Bool.and(U32.is_ne(th, S.tm.shooter(g)), C.has(S.m.flags(g, th), 4)), g, +h => aim.hit(h, th, frac))


def aim.ptr(+g: S.Sim, +i: S.Icpt) -> S.Sim:
  match i:
    case S.Icpt{+frac, +isline, +id}:
      C.br(isline, g, +h => aim.line(h, id, frac), +h => aim.thing(h, id, frac))


def aim(+g: S.Sim, +m: U32, +an: U32, +dist: U32) -> S.Sim:
  +x = S.m.x(g, m)
  +y = S.m.y(g, m)
  +x2 = (x + F.sar(dist, 16n) * cosine(g, an) : U32)
  +y2 = (y + F.sar(dist, 16n) * sinus(g, an) : U32)
  +sz = (S.m.z(g, m) + F.sar(S.m.height(g, m), 1n) + 524288 : U32)
  +g1 = S.tm.bots.set(S.tm.tops.set(S.tm.shootz.set(S.tm.shooter.set(g, m), sz), 40960), 4294926336)
  +g2 = S.tm.ltarget.set(S.tm.range.set(g1, dist), 0)
  +g3 = C.resume(G.path(~(+h => +i => aim.ptr(h, i)), g2, True{}, x, y, x2, y2))
  S.sim.ret.set(g3, Bool.pick(U32, U32.is_ne(S.tm.ltarget(g3), 0), S.tm.aim(g3), 0))


def puff(+g: S.Sim, +x: U32, +y: U32, +z: U32) -> S.Sim:
  +s = subr(g)
  +g1 = subr.next(g)
  +id = C.newid(g1)
  +g2 = tics.rand(S.m.momz.set(spawn(g1, x, y, (z + (s << 10n) : U32), 37), id, 65536), id, 3)
  C.when(U32.is_eq(S.tm.range(g2), 4194304), g2, +h => setstate(h, id, 95))


def blood(+g: S.Sim, +x: U32, +y: U32, +z: U32, +dmg: U32) -> S.Sim:
  +s = subr(g)
  +g1 = subr.next(g)
  +id = C.newid(g1)
  +g2 = tics.rand(S.m.momz.set(spawn(g1, x, y, (z + (s << 10n) : U32), 38), id, 131072), id, 3)
  C.br(Bool.and(F.le(dmg, 12), F.ge(dmg, 9)), g2, +h => setstate(h, id, 91),
    +h => C.when(F.lt(dmg, 9), h, +k => setstate(k, id, 92)))


def shoot.hit(+g: S.Sim, +ld: U32, +frac: U32) -> S.Sim:
  +f = (frac - F.div(262144, S.tm.range(g)) : U32)
  +x = (S.tm.trx(g) + F.mul(S.tm.trdx(g), f) : U32)
  +y = (S.tm.try(g) + F.mul(S.tm.trdy(g), f) : U32)
  +z = (S.tm.shootz(g) + F.mul(S.tm.aim(g), F.mul(f, S.tm.range(g))) : U32)
  +fs = S.l.fsec(g, ld)
  +bs = S.l.bsec(g, ld)
  +skyf = U32.is_eq(S.s.cpic(g, fs), C.sky())
  +skyb = Bool.and(U32.is_ne(bs, 65535), U32.is_eq(S.s.cpic(g, bs), C.sky()))
  +nopuff = Bool.and(skyf, Bool.or(F.gt(z, S.s.ceil(g, fs)), skyb))
  C.stop(C.when(Bool.not(nopuff), g, +h => puff(h, x, y, z)))


def shoot.open(+g: S.Sim, +ld: U32, +frac: U32) -> S.Sim:
  +dist = F.mul(S.tm.range(g), frac)
  +sz = S.tm.shootz(g)
  +a = S.tm.aim(g)
  +fs = S.l.fsec(g, ld)
  +bs = S.l.bsec(g, ld)
  +hitf = Bool.and(U32.is_ne(S.s.floor(g, fs), S.s.floor(g, bs)), F.gt(F.div((S.tm.obottom(g) - sz : U32), dist), a))
  +hitc = Bool.and(U32.is_ne(S.s.ceil(g, fs), S.s.ceil(g, bs)), F.lt(F.div((S.tm.otop(g) - sz : U32), dist), a))
  C.when(Bool.or(hitf, hitc), g, +h => shoot.hit(h, ld, frac))


def shoot.line(+g: S.Sim, +ld: U32, +frac: U32) -> S.Sim:
  +g1 = C.when(U32.is_ne(C.lspec(g, ld), 0), g, +h => shoot(h, ld, S.tm.shooter(h)))
  C.br(Bool.not(C.has(S.l.flags(g1, ld), 4)), g1, +h => shoot.hit(h, ld, frac), +h => shoot.open(G.opening(h, ld), ld, frac))


def shoot.mark(+g: S.Sim, +th: U32, +frac: U32) -> S.Sim:
  +f = (frac - F.div(655360, S.tm.range(g)) : U32)
  +x = (S.tm.trx(g) + F.mul(S.tm.trdx(g), f) : U32)
  +y = (S.tm.try(g) + F.mul(S.tm.trdy(g), f) : U32)
  +z = (S.tm.shootz(g) + F.mul(S.tm.aim(g), F.mul(f, S.tm.range(g))) : U32)
  +d = S.tm.ladmg(g)
  +g1 = C.br(C.has(S.m.flags(g, th), 524288), g, +h => puff(h, x, y, z), +h => blood(h, x, y, z, d))
  +src = S.tm.shooter(g1)
  C.stop(C.when(U32.is_ne(d, 0), g1, +h => damage(h, th, src, src, d)))


def shoot.thing(+g: S.Sim, +th: U32, +frac: U32) -> S.Sim:
  +dist = F.mul(S.tm.range(g), frac)
  +sz = S.tm.shootz(g)
  +z = S.m.z(g, th)
  +a = S.tm.aim(g)
  +over = F.lt(F.div((z + S.m.height(g, th) - sz : U32), dist), a)
  +under = F.gt(F.div((z - sz : U32), dist), a)
  +ok = Bool.and(Bool.and(U32.is_ne(th, S.tm.shooter(g)), C.has(S.m.flags(g, th), 4)), Bool.not(Bool.or(over, under)))
  C.when(ok, g, +h => shoot.mark(h, th, frac))


def shoot.ptr(+g: S.Sim, +i: S.Icpt) -> S.Sim:
  match i:
    case S.Icpt{+frac, +isline, +id}:
      C.br(isline, g, +h => shoot.line(h, id, frac), +h => shoot.thing(h, id, frac))


def lineattack(+g: S.Sim, +m: U32, +an: U32, +dist: U32, +slope: U32, +dmg: U32) -> S.Sim:
  +x = S.m.x(g, m)
  +y = S.m.y(g, m)
  +x2 = (x + F.sar(dist, 16n) * cosine(g, an) : U32)
  +y2 = (y + F.sar(dist, 16n) * sinus(g, an) : U32)
  +sz = (S.m.z(g, m) + F.sar(S.m.height(g, m), 1n) + 524288 : U32)
  +g1 = S.tm.range.set(S.tm.shootz.set(S.tm.ladmg.set(S.tm.shooter.set(g, m), dmg), sz), dist)
  C.resume(G.path(~(+h => +i => shoot.ptr(h, i)), S.tm.aim.set(g1, slope), True{}, x, y, x2, y2))


def rad.hit(+g: S.Sim, +th: U32, +d: U32) -> S.Sim:
  C.when(yes(g), g, +h => damage(h, th, S.tm.bspot(h), S.tm.bsrc(h), (S.tm.bdmg(h) - d : U32)))


def rad.thing(+g: S.Sim, +th: U32) -> S.Sim:
  +k = S.m.type(g, th)
  +sp = S.tm.bspot(g)
  +dx = F.abs((S.m.x(g, th) - S.m.x(g, sp) : U32))
  +dy = F.abs((S.m.y(g, th) - S.m.y(g, sp) : U32))
  +d0 = F.sar((Bool.pick(U32, F.gt(dx, dy), dx, dy) - S.m.radius(g, th) : U32), 16n)
  +d = Bool.pick(U32, F.lt(d0, 0), 0, d0)
  +ok = Bool.and(Bool.and(C.has(S.m.flags(g, th), 4), Bool.not(boss(k))), F.lt(d, S.tm.bdmg(g)))
  C.when(ok, g, +h => rad.hit(checksight(h, th, S.tm.bspot(h)), th, d))


def radius(+g: S.Sim, +spot: U32, +src: U32, +dmg: U32) -> S.Sim:
  +dist = ((dmg + 32) << 16n : U32)
  +ox = S.mp.ox(g)
  +oy = S.mp.oy(g)
  +x = S.m.x(g, spot)
  +y = S.m.y(g, spot)
  +g1 = S.tm.bdmg.set(S.tm.bsrc.set(S.tm.bspot.set(g, spot), src), dmg)
  G.area(~(+h => +by => +bx => G.bthings(~(+k => +t => rad.thing(k, t)), h, bx, by)), g1,
    F.sar((y - dist - oy : U32), 23n), F.sar((y + dist - oy : U32), 23n), F.sar((x - dist - ox : U32), 23n), F.sar((x + dist - ox : U32), 23n))


def missile.check(+g: S.Sim, +th: U32) -> S.Sim:
  +g1 = tics.rand(g, th, 3)
  +g2 = S.m.x.set(g1, th, (S.m.x(g1, th) + F.sar(S.m.momx(g1, th), 1n) : U32))
  +g3 = S.m.y.set(g2, th, (S.m.y(g2, th) + F.sar(S.m.momy(g2, th), 1n) : U32))
  +g4 = S.m.z.set(g3, th, (S.m.z(g3, th) + F.sar(S.m.momz(g3, th), 1n) : U32))
  +g5 = trymove(g4, th, S.m.x(g4, th), S.m.y(g4, th))
  C.when(Bool.not(ok(g5)), g5, +h => explode(h, th))


def missile.aim(+g: S.Sim, +id: U32, +an: U32) -> S.Sim:
  +sp = C.info(g, S.m.type(g, id), 15)
  S.m.momy.set(S.m.momx.set(S.m.angle.set(g, id, an), id, F.mul(sp, cosine(g, an))), id, F.mul(sp, sinus(g, an)))


def missile.spawn(+g: S.Sim, +src: U32, +dest: U32, +k: U32) -> S.Sim:
  +id = C.newid(g)
  +g1 = spawn(g, S.m.x(g, src), S.m.y(g, src), (S.m.z(g, src) + 2097152 : U32), k)
  +ss = C.info(g1, k, 4)
  +g2 = S.m.target.set(C.when(U32.is_ne(ss, 0), g1, +h => sound(h, id, ss)), id, src)
  +an0 = toward(g2, src, dest)
  +shadow = C.has(S.m.flags(g2, dest), 262144)
  +s = subr(g2)
  +g3 = C.when(shadow, g2, +h => subr.next(h))
  +g4 = missile.aim(g3, id, Bool.pick(U32, shadow, (an0 + (s << 20n) : U32), an0))
  +sp = C.info(g4, k, 15)
  +d0 = (apart(g4, src, dest) / sp : U32)
  +d = Bool.pick(U32, F.lt(d0, 1), 1, d0)
  +g5 = S.m.momz.set(g4, id, sdiv((S.m.z(g4, dest) - S.m.z(g4, src) : U32), d))
  S.sim.ret.set(missile.check(g5, id), id)


def xsp(+d: U32) -> U32:
  Bool.pick(U32, U32.is_eq(d, 0), 65536, Bool.pick(U32, Bool.or(U32.is_eq(d, 1), U32.is_eq(d, 7)), 47000,
    Bool.pick(U32, Bool.or(U32.is_eq(d, 2), U32.is_eq(d, 6)), 0, Bool.pick(U32, Bool.or(U32.is_eq(d, 3), U32.is_eq(d, 5)), 4294920296, 4294901760))))


def ysp(+d: U32) -> U32:
  Bool.pick(U32, Bool.or(U32.is_eq(d, 0), U32.is_eq(d, 4)), 0, Bool.pick(U32, Bool.or(U32.is_eq(d, 1), U32.is_eq(d, 3)), 47000,
    Bool.pick(U32, U32.is_eq(d, 2), 65536, Bool.pick(U32, Bool.or(U32.is_eq(d, 5), U32.is_eq(d, 7)), 4294920296, 4294901760))))


def opp(+d: U32) -> U32:
  Bool.pick(U32, U32.is_eq(d, 8), 8, ((d + 4) .&. 7 : U32))


def done(+g: S.Sim) -> Bool:
  U32.is_eq(S.sim.ret(g), 1)


def monsteruse(+g: S.Sim, +ld: U32) -> Bool:
  +sp = C.lspec(g, ld)
  Bool.and(Bool.not(C.has(S.l.flags(g, ld), 32)), Bool.or(is.in2(sp, 1, 32), is.in2(sp, 33, 34)))


def pmove.use(xs: List<&2, U32>, +g: S.Sim, +m: U32, +good: Bool) -> S.Sim:
  match xs:
    case +ld <> t:
      +ok = monsteruse(g, ld)
      pmove.use(t, use(g, ld, 0, m), m, Bool.or(good, ok))
    case []:
      S.sim.ret.set(g, C.b2u(good))


def pmove.float(+g: S.Sim, +m: U32) -> S.Sim:
  +z = S.m.z(g, m)
  +g1 = S.m.z.set(g, m, Bool.pick(U32, F.lt(z, S.tm.floorz(g)), (z + 262144 : U32), (z - 262144 : U32)))
  S.sim.ret.set(S.m.flags.set(g1, m, (S.m.flags(g1, m) .|. 2097152 : U32)), 1)


def pmove.fail(+g: S.Sim, +m: U32) -> S.Sim:
  C.br(Bool.and(C.has(S.m.flags(g, m), 16384), U32.is_ne(S.tm.floatok(g), 0)), g, +h => pmove.float(h, m),
    +h => C.br(List.is_empty(&2, U32, S.tm.spechit(h)), h, +k => S.sim.ret.set(k, 0),
      +k => pmove.use(S.tm.spechit(k), S.m.movedir.set(k, m, 8), m, False{})))


def pmove.ok(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = S.m.flags.set(g, m, C.clr(S.m.flags(g, m), 2097152))
  +g2 = C.when(Bool.not(C.has(S.m.flags(g1, m), 16384)), g1, +h => S.m.z.set(h, m, S.m.floorz(h, m)))
  S.sim.ret.set(g2, 1)


def pmove.go(+g: S.Sim, +m: U32, +d: U32) -> S.Sim:
  +sp = C.info(g, S.m.type(g, m), 15)
  +g1 = trymove(g, m, (S.m.x(g, m) + sp * xsp(d) : U32), (S.m.y(g, m) + sp * ysp(d) : U32))
  C.br(ok(g1), g1, +h => pmove.ok(h, m), +h => pmove.fail(h, m))


def pmove(+g: S.Sim, +m: U32) -> S.Sim:
  +d = S.m.movedir(g, m)
  C.br(U32.is_ge(d, 8), g, +h => S.sim.ret.set(h, 0), +h => pmove.go(h, m, d))


def trywalk(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = pmove(g, m)
  C.when(done(g1), g1, +h => S.m.movecount.set(C.rnd.next(h), m, (C.rnd(h) .&. 15 : U32)))


def walkdir(+g: S.Sim, +m: U32, +d: U32) -> S.Sim:
  trywalk(S.m.movedir.set(g, m, d), m)


def ncd.try(+g: S.Sim, +m: U32, +d: U32, +ok: Bool) -> S.Sim:
  C.br(Bool.or(done(g), Bool.not(ok)), g, +h => h, +h => walkdir(h, m, d))


def ncd.scan(n: Nat, more: Bool, +g: S.Sim, +m: U32, +d: U32, +up: Bool, +ta: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = ncd.try(g, m, d, U32.is_ne(d, ta))
      ncd.scan(p, Bool.not(done(g1)), g1, m, Bool.pick(U32, up, (d + 1 : U32), (d - 1 : U32)), up, ta)
    case _ _:
      g


def ncd.rest(+g: S.Sim, +m: U32, +od: U32, +ta: U32, +d1: U32, +d2: U32) -> S.Sim:
  +g1 = ncd.try(g, m, d1, U32.is_ne(d1, 8))
  +g2 = ncd.try(g1, m, d2, U32.is_ne(d2, 8))
  +g3 = ncd.try(g2, m, od, U32.is_ne(od, 8))
  +g4 = C.br(done(g3), g3, +h => h,
    +h => C.br(C.has(C.rnd(h), 1), C.rnd.next(h), +k => ncd.scan(8n, True{}, k, m, 0, True{}, ta), +k => ncd.scan(8n, True{}, k, m, 7, False{}, ta)))
  +g5 = ncd.try(g4, m, ta, U32.is_ne(ta, 8))
  C.when(Bool.not(done(g5)), g5, +h => S.m.movedir.set(h, m, 8))


def ncd.swap(+g: S.Sim, +m: U32, +od: U32, +ta: U32, +d1: U32, +d2: U32, +dx: U32, +dy: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +sw = Bool.or(U32.is_gt(r, 200), F.gt(F.abs(dy), F.abs(dx)))
  +e1 = Bool.pick(U32, sw, d2, d1)
  +e2 = Bool.pick(U32, sw, d1, d2)
  ncd.rest(g1, m, od, ta, Bool.pick(U32, U32.is_eq(e1, ta), 8, e1), Bool.pick(U32, U32.is_eq(e2, ta), 8, e2))


def ncd.diag(+dx: U32, +dy: U32) -> U32:
  +i = (C.b2u(F.lt(dy, 0)) * 2 + C.b2u(F.gt(dx, 0)) : U32)
  Bool.pick(U32, U32.is_eq(i, 0), 3, Bool.pick(U32, U32.is_eq(i, 1), 1, Bool.pick(U32, U32.is_eq(i, 2), 5, 7)))


def newchasedir(+g: S.Sim, +m: U32) -> S.Sim:
  +od = S.m.movedir(g, m)
  +ta = opp(od)
  +t = S.m.target(g, m)
  +dx = (S.m.x(g, t) - S.m.x(g, m) : U32)
  +dy = (S.m.y(g, t) - S.m.y(g, m) : U32)
  +d1 = Bool.pick(U32, F.gt(dx, 655360), 0, Bool.pick(U32, F.lt(dx, 4294311936), 4, 8))
  +d2 = Bool.pick(U32, F.lt(dy, 4294311936), 6, Bool.pick(U32, F.gt(dy, 655360), 2, 8))
  +dg = ncd.diag(dx, dy)
  +g0 = S.sim.ret.set(g, 0)
  +g1 = C.when(Bool.and(U32.is_ne(d1, 8), U32.is_ne(d2, 8)), g0,
    +h => C.when(U32.is_ne(dg, ta), S.m.movedir.set(h, m, dg), +k => trywalk(k, m)))
  C.br(done(g1), g1, +h => h, +h => ncd.swap(h, m, od, ta, d1, d2, dx, dy))


def behind(+g: S.Sim, +m: U32, +pm: U32) -> Bool:
  +an = (toward(g, m, pm) - S.m.angle(g, m) : U32)
  Bool.and(Bool.and(U32.is_gt(an, 1073741824), U32.is_lt(an, 3221225472)), F.gt(apart(g, m, pm), 4194304))


def look.seen(+g: S.Sim, +m: U32, +all: Bool, +pm: U32) -> S.Sim:
  C.br(Bool.or(Bool.not(yes(g)), Bool.and(Bool.not(all), behind(g, m, pm))), g, +h => S.sim.ret.set(h, 2),
    +h => S.sim.ret.set(S.m.target.set(h, m, pm), 1))


def look.check(+g: S.Sim, +m: U32, +all: Bool) -> S.Sim:
  +pm = S.p.mo(g)
  C.br(F.le(S.p.health(g), 0), g, +h => S.sim.ret.set(h, 2), +h => look.seen(checksight(h, m, pm), m, all, pm))


def look.go(n: Nat, more: Bool, +g: S.Sim, +m: U32, +all: Bool, +c: U32, +stop: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +ll = S.m.lastlook(g, m)
      +inplay = U32.is_eq(ll, 0)
      +end = Bool.and(inplay, Bool.or(U32.is_eq(c, 2), U32.is_eq(ll, stop)))
      +g1 = C.br(end, g, +h => S.sim.ret.set(h, 0), +h => C.br(inplay, h, +k => look.check(k, m, all), +k => S.sim.ret.set(k, 2)))
      +cont = U32.is_eq(S.sim.ret(g1), 2)
      +g2 = C.when(cont, g1, +h => S.m.lastlook.set(h, m, ((S.m.lastlook(h, m) + 1) .&. 3 : U32)))
      look.go(p, cont, g2, m, all, (c + C.b2u(inplay) : U32), stop)
    case _ _:
      g


def lookfor(+g: S.Sim, +m: U32, +all: Bool) -> S.Sim:
  +g1 = look.go(32n, True{}, g, m, all, 0, ((S.m.lastlook(g, m) - 1) .&. 3 : U32))
  C.when(U32.is_eq(S.sim.ret(g1), 2), g1, +h => S.sim.ret.set(h, 0))


def see.sound(+g: S.Sim, +m: U32, +k: U32, +ss: U32) -> S.Sim:
  +r = C.rnd(g)
  +a = Bool.and(U32.is_ge(ss, 36), U32.is_le(ss, 38))
  +b = Bool.and(U32.is_ge(ss, 39), U32.is_le(ss, 40))
  +s = Bool.pick(U32, a, (36 + r % 3 : U32), Bool.pick(U32, b, (39 + r % 2 : U32), ss))
  +g1 = C.when(Bool.or(a, b), g, +h => C.rnd.next(h))
  sound(g1, Bool.pick(U32, boss(k), 0, m), s)


def seeyou(+g: S.Sim, +m: U32) -> S.Sim:
  +k = S.m.type(g, m)
  +ss = C.info(g, k, 4)
  +g1 = C.when(U32.is_ne(ss, 0), g, +h => see.sound(h, m, k, ss))
  setstate(g1, m, C.info(g1, k, 3))


def look.players(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = lookfor(g, m, False{})
  C.when(yes(g1), g1, +h => seeyou(h, m))


def look.ambush(+g: S.Sim, +m: U32) -> S.Sim:
  C.br(yes(g), g, +h => seeyou(h, m), +h => look.players(h, m))


def look.sound(+g: S.Sim, +m: U32, +targ: U32) -> S.Sim:
  +g1 = S.m.target.set(g, m, targ)
  C.br(C.has(S.m.flags(g1, m), 32), g1, +h => look.ambush(checksight(h, m, targ), m), +h => seeyou(h, m))


def a.look(+g: S.Sim, +m: U32) -> S.Sim:
  +g0 = S.m.threshold.set(g, m, 0)
  +targ = T.get(U32, S.sim.sndt(g0), G.mobsec(g0, m), 0)
  +ok = Bool.and(U32.is_ne(targ, 0), C.has(S.m.flags(g0, targ), 4))
  C.br(ok, g0, +h => look.sound(h, m, targ), +h => look.players(h, m))


def face.go(+g: S.Sim, +m: U32, +t: U32) -> S.Sim:
  +g1 = S.m.angle.set(S.m.flags.set(g, m, C.clr(S.m.flags(g, m), 32)), m, toward(g, m, t))
  C.when(C.has(S.m.flags(g1, t), 262144), g1, +h => subr.next(S.m.angle.set(h, m, (S.m.angle(h, m) + (subr(h) << 21n) : U32))))


def a.face(+g: S.Sim, +m: U32) -> S.Sim:
  +t = S.m.target(g, m)
  C.when(U32.is_ne(t, 0), g, +h => face.go(h, m, t))


def meleerange(+g: S.Sim, +m: U32) -> S.Sim:
  +t = S.m.target(g, m)
  +far = F.ge(apart(g, m, t), (2883584 + C.info(g, S.m.type(g, t), 16) : U32))
  C.br(Bool.or(U32.is_eq(t, 0), far), g, +h => S.sim.ret.set(h, 0), +h => checksight(h, m, t))


def mr.roll(+g: S.Sim, +d: U32) -> S.Sim:
  +r = C.rnd(g)
  S.sim.ret.set(C.rnd.next(g), C.b2u(Bool.not(F.lt(r, d))))


def mr.dist(+g: S.Sim, +m: U32) -> S.Sim:
  +k = S.m.type(g, m)
  +d0 = (apart(g, S.m.target(g, m), m) - 4194304 : U32)
  +d1 = F.sar(Bool.pick(U32, U32.is_eq(C.info(g, k, 10), 0), (d0 - 8388608 : U32), d0), 16n)
  +far = Bool.and(U32.is_eq(k, 3), F.gt(d1, 896))
  +near = Bool.and(U32.is_eq(k, 5), F.lt(d1, 196))
  +d2 = Bool.pick(U32, U32.is_eq(k, 5), F.sar(d1, 1n), d1)
  +d3 = Bool.pick(U32, Bool.or(boss(k), U32.is_eq(k, 18)), F.sar(d2, 1n), d2)
  +d4 = Bool.pick(U32, F.gt(d3, 200), 200, d3)
  +d5 = Bool.pick(U32, Bool.and(U32.is_eq(k, 21), F.gt(d4, 160)), 160, d4)
  C.br(Bool.or(far, near), g, +h => S.sim.ret.set(h, 0), +h => mr.roll(h, d5))


def mr.check(+g: S.Sim, +m: U32) -> S.Sim:
  C.br(C.has(S.m.flags(g, m), 64), g, +h => S.sim.ret.set(S.m.flags.set(h, m, C.clr(S.m.flags(h, m), 64)), 1),
    +h => C.br(U32.is_ne(S.m.reaction(h, m), 0), h, +k => S.sim.ret.set(k, 0), +k => mr.dist(k, m)))


def missilerange(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = checksight(g, m, S.m.target(g, m))
  C.br(yes(g1), g1, +h => mr.check(h, m), +h => h)


def chase.active(+g: S.Sim, +m: U32) -> S.Sim:
  +s = C.info(g, S.m.type(g, m), 20)
  C.when(U32.is_ne(s, 0), g, +h => C.when(U32.is_lt(C.rnd(h), 3), C.rnd.next(h), +k => sound(k, m, s)))


def chase.step(+g: S.Sim, +m: U32) -> S.Sim:
  C.br(yes(g), g, +h => h, +h => newchasedir(h, m))


def chase.move(+g: S.Sim, +m: U32) -> S.Sim:
  +mc = (S.m.movecount(g, m) - 1 : U32)
  +g1 = S.m.movecount.set(g, m, mc)
  +g2 = C.br(F.lt(mc, 0), g1, +h => newchasedir(h, m), +h => chase.step(pmove(h, m), m))
  chase.active(g2, m)


def chase.flag(+g: S.Sim, +m: U32) -> S.Sim:
  S.m.flags.set(g, m, (S.m.flags(g, m) .|. 128 : U32))


def chase.fire(+g: S.Sim, +m: U32, +ms: U32) -> S.Sim:
  C.br(yes(g), g, +h => chase.flag(setstate(h, m, ms), m), +h => chase.move(h, m))


def chase.missile(+g: S.Sim, +m: U32) -> S.Sim:
  +ms = C.info(g, S.m.type(g, m), 11)
  +wait = Bool.and(U32.is_lt(S.mp.skill(g), 4), U32.is_ne(S.m.movecount(g, m), 0))
  C.br(Bool.or(U32.is_eq(ms, 0), wait), g, +h => chase.move(h, m), +h => chase.fire(missilerange(h, m), m, ms))


def chase.hit(+g: S.Sim, +m: U32, +ms: U32) -> S.Sim:
  +as = C.info(g, S.m.type(g, m), 6)
  setstate(C.when(U32.is_ne(as, 0), g, +h => sound(h, m, as)), m, ms)


def chase.near(+g: S.Sim, +m: U32, +ms: U32) -> S.Sim:
  C.br(yes(g), g, +h => chase.hit(h, m, ms), +h => chase.missile(h, m))


def chase.melee(+g: S.Sim, +m: U32) -> S.Sim:
  +ms = C.info(g, S.m.type(g, m), 10)
  C.br(U32.is_eq(ms, 0), g, +h => chase.missile(h, m),
    +h => chase.near(meleerange(h, m), m, ms))


def chase.attack(+g: S.Sim, +m: U32) -> S.Sim:
  C.br(C.has(S.m.flags(g, m), 128), g,
    +h => C.when(U32.is_ne(S.mp.skill(h), 4), S.m.flags.set(h, m, C.clr(S.m.flags(h, m), 128)), +k => newchasedir(k, m)),
    +h => chase.melee(h, m))


def chase.relook(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = lookfor(g, m, True{})
  C.when(Bool.not(yes(g1)), g1, +h => setstate(h, m, C.info(h, S.m.type(h, m), 1)))


def chase.turn(+g: S.Sim, +m: U32) -> S.Sim:
  +md = S.m.movedir(g, m)
  +a = (S.m.angle(g, m) .&. 3758096384 : U32)
  +delta = (a - (md << 29n) : U32)
  +a2 = Bool.pick(U32, F.gt(delta, 0), (a - 536870912 : U32), Bool.pick(U32, F.lt(delta, 0), (a + 536870912 : U32), a))
  C.when(U32.is_lt(md, 8), g, +h => S.m.angle.set(h, m, a2))


def a.chase(+g: S.Sim, +m: U32) -> S.Sim:
  +rt = S.m.reaction(g, m)
  +g1 = C.when(U32.is_ne(rt, 0), g, +h => S.m.reaction.set(h, m, (rt - 1 : U32)))
  +th = S.m.threshold(g1, m)
  +t = S.m.target(g1, m)
  +lost = Bool.or(U32.is_eq(t, 0), F.le(S.m.health(g1, t), 0))
  +g2 = C.when(U32.is_ne(th, 0), g1, +h => S.m.threshold.set(h, m, Bool.pick(U32, lost, 0, (th - 1 : U32))))
  +g3 = chase.turn(g2, m)
  +t2 = S.m.target(g3, m)
  C.br(Bool.or(U32.is_eq(t2, 0), Bool.not(C.has(S.m.flags(g3, t2), 4))), g3, +h => chase.relook(h, m), +h => chase.attack(h, m))


def melee.hit(+g: S.Sim, +m: U32, +sfx: U32, +dmg: U32) -> S.Sim:
  +g1 = C.when(U32.is_ne(sfx, 0), g, +h => sound(h, m, sfx))
  damage(g1, S.m.target(g1, m), m, m, dmg)


def melee.or(+g: S.Sim, +m: U32, +sfx: U32, +mod: U32, +mul: U32, +k: U32) -> S.Sim:
  +r = C.rnd(g)
  C.br(yes(g), g, +h => melee.hit(C.rnd.next(h), m, sfx, ((r % mod + 1) * mul : U32)),
    +h => C.when(U32.is_ne(k, 0), h, +q => missile.spawn(q, m, S.m.target(q, m), k)))


def attack.melee(+g: S.Sim, +m: U32, +face: Bool, +sfx: U32, +mod: U32, +mul: U32, +k: U32) -> S.Sim:
  +g1 = C.when(face, g, +h => a.face(h, m))
  melee.or(meleerange(g1, m), m, sfx, mod, mul, k)


def targeted(+g: S.Sim, +m: U32, f: S.Sim -> S.Sim) -> S.Sim:
  C.br(U32.is_eq(S.m.target(g, m), 0), g, +h => h, f)


def bullet(+g: S.Sim, +m: U32, +ba: U32, +slope: U32) -> S.Sim:
  +s = subr(g)
  +g1 = subr.next(g)
  +r = C.rnd(g1)
  lineattack(C.rnd.next(g1), m, (ba + (s << 20n) : U32), 134217728, slope, ((r % 5 + 1) * 3 : U32))


def a.posattack(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.face(g, m)
  +ba = S.m.angle(g1, m)
  +g2 = aim(g1, m, ba, 134217728)
  bullet(sound(g2, m, 1), m, ba, S.sim.ret(g2))


def shots(n: Nat, +g: S.Sim, +m: U32, +ba: U32, +slope: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      shots(p, bullet(g, m, ba, slope), m, ba, slope)


def a.sposattack(+g: S.Sim, +m: U32, +n: U32) -> S.Sim:
  +g1 = a.face(sound(g, m, 2), m)
  +ba = S.m.angle(g1, m)
  +g2 = aim(g1, m, ba, 134217728)
  shots(U32.to_nat(n), g2, m, ba, S.sim.ret(g2))


def refire.seen(+g: S.Sim, +m: U32, +see: U32) -> S.Sim:
  C.when(Bool.not(yes(g)), g, +h => setstate(h, m, see))


def refire.go(+g: S.Sim, +m: U32) -> S.Sim:
  +t = S.m.target(g, m)
  +see = C.info(g, S.m.type(g, m), 3)
  C.br(Bool.or(U32.is_eq(t, 0), F.le(S.m.health(g, t), 0)), g, +h => setstate(h, m, see),
    +h => refire.seen(checksight(h, m, t), m, see))


def a.refire(+g: S.Sim, +m: U32, +chance: U32) -> S.Sim:
  +g1 = a.face(g, m)
  +r = C.rnd(g1)
  C.br(U32.is_lt(r, chance), C.rnd.next(g1), +h => h, +h => refire.go(h, m))


def a.missile(+g: S.Sim, +m: U32, +k: U32) -> S.Sim:
  missile.spawn(a.face(g, m), m, S.m.target(g, m), k)


def a.tracer.steer(+g: S.Sim, +m: U32, +dest: U32) -> S.Sim:
  +exact = toward(g, m, dest)
  +a0 = S.m.angle(g, m)
  +dn = U32.is_gt((exact - a0 : U32), 2147483648)
  +am = (a0 - 201326592 : U32)
  +ap = (a0 + 201326592 : U32)
  +a1 = Bool.pick(U32, dn, Bool.pick(U32, U32.is_lt((exact - am : U32), 2147483648), exact, am), Bool.pick(U32, U32.is_gt((exact - ap : U32), 2147483648), exact, ap))
  +a2 = Bool.pick(U32, U32.is_eq(exact, a0), a0, a1)
  +sp = C.info(g, S.m.type(g, m), 15)
  +g1 = S.m.momy.set(S.m.momx.set(S.m.angle.set(g, m, a2), m, F.mul(sp, cosine(g, a2))), m, F.mul(sp, sinus(g, a2)))
  +d0 = (apart(g1, m, dest) / sp : U32)
  +d = Bool.pick(U32, F.lt(d0, 1), 1, d0)
  +slope = sdiv((S.m.z(g1, dest) + 2621440 - S.m.z(g1, m) : U32), d)
  +mz = S.m.momz(g1, m)
  S.m.momz.set(g1, m, Bool.pick(U32, F.lt(slope, mz), (mz - 8192 : U32), (mz + 8192 : U32)))


def a.tracer.go(+g: S.Sim, +m: U32) -> S.Sim:
  +x = S.m.x(g, m)
  +y = S.m.y(g, m)
  +z = S.m.z(g, m)
  +g1 = puff(g, x, y, z)
  +id = C.newid(g1)
  +g2 = tics.rand(S.m.momz.set(spawn(g1, (x - S.m.momx(g1, m) : U32), (y - S.m.momy(g1, m) : U32), z, 7), id, 65536), id, 3)
  +dest = S.m.tracer(g2, m)
  C.when(Bool.and(U32.is_ne(dest, 0), F.gt(S.m.health(g2, dest), 0)), g2, +h => a.tracer.steer(h, m, dest))


def a.tracer(+g: S.Sim, +m: U32) -> S.Sim:
  C.when(U32.is_eq((S.sim.tic(g) .&. 3 : U32), 0), g, +h => a.tracer.go(h, m))


def a.skelmissile.go(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.face(g, m)
  +g2 = missile.spawn(S.m.z.set(g1, m, (S.m.z(g1, m) + 1048576 : U32)), m, S.m.target(g1, m), 6)
  +mo = S.sim.ret(g2)
  +g3 = S.m.z.set(g2, m, (S.m.z(g2, m) - 1048576 : U32))
  +g4 = S.m.y.set(S.m.x.set(g3, mo, (S.m.x(g3, mo) + S.m.momx(g3, mo) : U32)), mo, (S.m.y(g3, mo) + S.m.momy(g3, mo) : U32))
  S.m.tracer.set(g4, mo, S.m.target(g4, m))


def vile.hit(+g: S.Sim, +th: U32) -> S.Sim:
  +h0 = S.m.height(g, th)
  +g1 = S.tm.corpse.set(S.m.momy.set(S.m.momx.set(g, th, 0), th, 0), th)
  +g2 = checkpos(S.m.height.set(g1, th, (h0 << 2n : U32)), th, S.m.x(g1, th), S.m.y(g1, th))
  +ok = U32.is_ne(S.tm.ok(g2), 0)
  +g3 = S.m.height.set(g2, th, F.sar(S.m.height(g2, th), 2n))
  C.when(ok, g3, +h => C.stop(h))


def vile.check(+g: S.Sim, +th: U32) -> S.Sim:
  +k = S.m.type(g, th)
  +md = (C.info(g, k, 16) + C.info(g, 3, 16) : U32)
  +near = Bool.and(F.le(F.abs((S.m.x(g, th) - S.tm.vx(g) : U32)), md), F.le(F.abs((S.m.y(g, th) - S.tm.vy(g) : U32)), md))
  +ok = Bool.and(Bool.and(C.has(S.m.flags(g, th), 1048576), U32.is_eq(S.m.tics(g, th), 4294967295)), Bool.and(U32.is_ne(C.info(g, k, 22), 0), near))
  C.when(ok, g, +h => vile.hit(h, th))


def vile.raise(+g: S.Sim, +m: U32) -> S.Sim:
  +c = S.tm.corpse(g)
  +temp = S.m.target(g, m)
  +g1 = S.m.target.set(a.face(S.m.target.set(g, m, c), m), m, temp)
  +g2 = sound(setstate(g1, m, 266), c, 31)
  +k = S.m.type(g2, c)
  +g3 = setstate(g2, c, C.info(g2, k, 22))
  +g4 = S.m.height.set(g3, c, (S.m.height(g3, c) << 2n : U32))
  S.m.target.set(S.m.health.set(S.m.flags.set(g4, c, C.info(g4, k, 21)), c, C.info(g4, k, 2)), c, 0)


def vile.scan(+g: S.Sim, +m: U32, +d: U32) -> S.Sim:
  +sp = C.info(g, S.m.type(g, m), 15)
  +vx = (S.m.x(g, m) + sp * xsp(d) : U32)
  +vy = (S.m.y(g, m) + sp * ysp(d) : U32)
  +ox = S.mp.ox(g)
  +oy = S.mp.oy(g)
  +g1 = G.area(~(+h => +bx => +by => G.bthings(~(+k => +t => vile.check(k, t)), h, bx, by)), S.tm.vy.set(S.tm.vx.set(g, vx), vy),
    F.sar((vx - ox - 4194304 : U32), 23n), F.sar((vx - ox + 4194304 : U32), 23n), F.sar((vy - oy - 4194304 : U32), 23n), F.sar((vy - oy + 4194304 : U32), 23n))
  C.br(C.halted(g1), C.resume(g1), +h => vile.raise(h, m), +h => a.chase(h, m))


def a.vilechase(+g: S.Sim, +m: U32) -> S.Sim:
  +d = S.m.movedir(g, m)
  C.br(U32.is_ne(d, 8), g, +h => vile.scan(h, m, d), +h => a.chase(h, m))


def fire.move(+g: S.Sim, +m: U32, +dest: U32) -> S.Sim:
  +an = S.m.angle(g, dest)
  +g1 = G.unset(g, m)
  +g2 = S.m.x.set(g1, m, (S.m.x(g1, dest) + F.mul(1572864, cosine(g1, an)) : U32))
  +g3 = S.m.z.set(S.m.y.set(g2, m, (S.m.y(g2, dest) + F.mul(1572864, sinus(g2, an)) : U32)), m, S.m.z(g2, dest))
  G.set(g3, m)


def fire.seen(+g: S.Sim, +m: U32, +dest: U32) -> S.Sim:
  C.when(yes(g), g, +h => fire.move(h, m, dest))


def a.fire(+g: S.Sim, +m: U32) -> S.Sim:
  +dest = S.m.tracer(g, m)
  C.when(U32.is_ne(dest, 0), g, +h => fire.seen(checksight(h, S.m.target(h, m), dest), m, dest))


def a.viletarget(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.face(g, m)
  +t = S.m.target(g1, m)
  +f = C.newid(g1)
  +g2 = spawn(g1, S.m.x(g1, t), S.m.x(g1, t), S.m.z(g1, t), 4)
  +g3 = S.m.tracer.set(S.m.target.set(S.m.tracer.set(g2, m, f), f, m), f, t)
  a.fire(g3, f)


def vile.blast(+g: S.Sim, +m: U32) -> S.Sim:
  +t = S.m.target(g, m)
  +g1 = damage(sound(g, m, 82), t, m, m, 20)
  +g2 = S.m.momz.set(g1, t, (65536000 / C.info(g1, S.m.type(g1, t), 18) : U32))
  +an = S.m.angle(g2, m)
  +fire = S.m.tracer(g2, m)
  C.when(U32.is_ne(fire, 0), g2, +h => radius(S.m.y.set(S.m.x.set(h, fire, (S.m.x(h, t) - F.mul(1572864, cosine(h, an)) : U32)), fire, (S.m.y(h, t) - F.mul(1572864, sinus(h, an)) : U32)), fire, m, 70))


def a.vileattack(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.face(g, m)
  +g2 = checksight(g1, m, S.m.target(g1, m))
  C.when(yes(g2), g2, +h => vile.blast(h, m))


def fat.turn(+g: S.Sim, +mo: U32, +da: U32) -> S.Sim:
  missile.aim(g, mo, (S.m.angle(g, mo) + da : U32))


def a.fat1(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.face(g, m)
  +g2 = S.m.angle.set(g1, m, (S.m.angle(g1, m) + 134217728 : U32))
  +g3 = missile.spawn(missile.spawn(g2, m, S.m.target(g2, m), 9), m, S.m.target(g2, m), 9)
  fat.turn(g3, S.sim.ret(g3), 134217728)


def a.fat2(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.face(g, m)
  +g2 = S.m.angle.set(g1, m, (S.m.angle(g1, m) - 134217728 : U32))
  +g3 = missile.spawn(missile.spawn(g2, m, S.m.target(g2, m), 9), m, S.m.target(g2, m), 9)
  fat.turn(g3, S.sim.ret(g3), 4026531840)


def a.fat3(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.face(g, m)
  +g2 = missile.spawn(g1, m, S.m.target(g1, m), 9)
  +g3 = fat.turn(g2, S.sim.ret(g2), 4227858432)
  +g4 = missile.spawn(g3, m, S.m.target(g3, m), 9)
  fat.turn(g4, S.sim.ret(g4), 67108864)


def skullattack.go(+g: S.Sim, +m: U32) -> S.Sim:
  +dest = S.m.target(g, m)
  +g1 = a.face(sound(S.m.flags.set(g, m, (S.m.flags(g, m) .|. 16777216 : U32)), m, C.info(g, S.m.type(g, m), 6)), m)
  +an = S.m.angle(g1, m)
  +g2 = S.m.momy.set(S.m.momx.set(g1, m, F.mul(1310720, cosine(g1, an))), m, F.mul(1310720, sinus(g1, an)))
  +d0 = (apart(g2, m, dest) / 1310720 : U32)
  +d = Bool.pick(U32, F.lt(d0, 1), 1, d0)
  S.m.momz.set(g2, m, sdiv((S.m.z(g2, dest) + F.sar(S.m.height(g2, dest), 1n) - S.m.z(g2, m) : U32), d))


def a.skullattack(+g: S.Sim, +m: U32) -> S.Sim:
  targeted(g, m, +h => skullattack.go(h, m))


def count.type(n: Nat, more: Bool, +g: S.Sim, +k: U32, +i: U32, +acc: U32) -> U32:
  match n more:
    case 1n+p True{}:
      +hit = Bool.and(alive(g, i), U32.is_eq(S.m.type(g, i), k))
      +nx = C.tnext(g, i)
      count.type(p, U32.is_ne(nx, 0), g, k, nx, (acc + C.b2u(hit) : U32))
    case _ _:
      acc


def others(n: Nat, more: Bool, +g: S.Sim, +m: U32, +k: U32, +i: U32) -> Bool:
  match n more:
    case 1n+p True{}:
      +hit = Bool.and(Bool.and(alive(g, i), U32.is_ne(i, m)), Bool.and(U32.is_eq(S.m.type(g, i), k), F.gt(S.m.health(g, i), 0)))
      +nx = C.tnext(g, i)
      Bool.or(hit, others(p, Bool.and(Bool.not(hit), U32.is_ne(nx, 0)), g, m, k, nx))
    case _ _:
      False{}


def anyother(+g: S.Sim, +m: U32) -> Bool:
  +f = C.tnext(g, 0)
  others(65536n, U32.is_ne(f, 0), g, m, S.m.type(g, m), f)


def skull.launch(+g: S.Sim, +m: U32, +s: U32) -> S.Sim:
  +g1 = trymove(g, s, S.m.x(g, s), S.m.y(g, s))
  C.br(ok(g1), g1, +h => a.skullattack(S.m.target.set(h, s, S.m.target(h, m)), s), +h => damage(h, s, m, m, 10000))


def skull.shoot(+g: S.Sim, +m: U32, +an: U32) -> S.Sim:
  +pre = (262144 + 3 * (C.info(g, S.m.type(g, m), 16) + C.info(g, 18, 16)) / 2 : U32)
  +x = (S.m.x(g, m) + F.mul(pre, cosine(g, an)) : U32)
  +y = (S.m.y(g, m) + F.mul(pre, sinus(g, an)) : U32)
  +s = C.newid(g)
  skull.launch(spawn(g, x, y, (S.m.z(g, m) + 524288 : U32), 18), m, s)


def a.painshoot(+g: S.Sim, +m: U32, +an: U32) -> S.Sim:
  +f = C.tnext(g, 0)
  +n = count.type(65536n, U32.is_ne(f, 0), g, 18, f, 0)
  C.when(U32.is_le(n, 20), g, +h => skull.shoot(h, m, an))


def a.fall(+g: S.Sim, +m: U32) -> S.Sim:
  S.m.flags.set(g, m, C.clr(S.m.flags(g, m), 2))


def a.painattack(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.face(g, m)
  a.painshoot(g1, m, S.m.angle(g1, m))


def a.paindie(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.fall(g, m)
  +g2 = a.painshoot(g1, m, (S.m.angle(g1, m) + 1073741824 : U32))
  +g3 = a.painshoot(g2, m, (S.m.angle(g2, m) + 2147483648 : U32))
  a.painshoot(g3, m, (S.m.angle(g3, m) + 3221225472 : U32))


def a.scream(+g: S.Sim, +m: U32) -> S.Sim:
  +k = S.m.type(g, m)
  +ds = C.info(g, k, 14)
  +r = C.rnd(g)
  +a = Bool.and(U32.is_ge(ds, 59), U32.is_le(ds, 61))
  +b = Bool.and(U32.is_ge(ds, 62), U32.is_le(ds, 63))
  +s = Bool.pick(U32, a, (59 + r % 3 : U32), Bool.pick(U32, b, (62 + r % 2 : U32), ds))
  +g1 = C.when(Bool.or(a, b), g, +h => C.rnd.next(h))
  C.when(U32.is_ne(ds, 0), g1, +h => sound(h, Bool.pick(U32, boss(k), 0, m), s))


def a.pain(+g: S.Sim, +m: U32) -> S.Sim:
  +s = C.info(g, S.m.type(g, m), 9)
  C.when(U32.is_ne(s, 0), g, +h => sound(h, m, s))


def a.playerscream(+g: S.Sim, +m: U32) -> S.Sim:
  sound(g, m, Bool.pick(U32, Bool.and(S.mp.commercial(g), F.lt(S.m.health(g, m), 4294967246)), 58, 57))


def floor.tag(+g: S.Sim, +tag: U32, +kind: U32) -> S.Sim:
  +n = S.mp.nsec(g)
  evloop(~(+a => +b => +c => +d => +e => floor.one(a, b, c, d, e)), U32.to_nat(n), U32.is_ne(n, 0), g, tag, 0, kind, 0, 0, 0)


def door.tag(+g: S.Sim, +tag: U32, +kind: U32) -> S.Sim:
  +n = S.mp.nsec(g)
  evloop(~(+a => +b => +c => +d => +e => door.one(a, b, c, d, e)), U32.to_nat(n), U32.is_ne(n, 0), g, tag, 0, kind, 0, 0, 0)


def boss.qualifies(+g: S.Sim, +k: U32) -> Bool:
  +ep = S.mp.episode(g)
  +mp = S.mp.map(g)
  Bool.pick(Bool, S.mp.commercial(g), Bool.and(U32.is_eq(mp, 7), Bool.or(U32.is_eq(k, 8), U32.is_eq(k, 20))),
    Bool.pick(Bool, U32.is_eq(ep, 1), Bool.and(U32.is_eq(mp, 8), U32.is_eq(k, 15)),
      Bool.pick(Bool, U32.is_eq(ep, 2), Bool.and(U32.is_eq(mp, 8), U32.is_eq(k, 21)),
        Bool.pick(Bool, U32.is_eq(ep, 3), Bool.and(U32.is_eq(mp, 8), U32.is_eq(k, 19)),
          Bool.pick(Bool, U32.is_eq(ep, 4), Bool.or(Bool.and(U32.is_eq(mp, 6), U32.is_eq(k, 21)), Bool.and(U32.is_eq(mp, 8), U32.is_eq(k, 19))),
            U32.is_eq(mp, 8))))))


def boss.victory(+g: S.Sim, +k: U32) -> S.Sim:
  +ep = S.mp.episode(g)
  +mp = S.mp.map(g)
  C.br(S.mp.commercial(g), g, +h => C.br(U32.is_eq(k, 8), h, +q => floor.tag(q, 666, 1), +q => floor.tag(q, 667, 5)),
    +h => C.br(U32.is_eq(ep, 1), h, +q => floor.tag(q, 666, 1),
      +q => C.br(Bool.and(U32.is_eq(ep, 4), U32.is_eq(mp, 6)), q, +r => door.tag(r, 666, 6),
        +r => C.br(Bool.and(U32.is_eq(ep, 4), U32.is_eq(mp, 8)), r, +s => floor.tag(s, 666, 1), +s => exit(s, 1)))))


def a.bossdeath(+g: S.Sim, +m: U32) -> S.Sim:
  +k = S.m.type(g, m)
  +ok = Bool.and(Bool.and(boss.qualifies(g, k), F.gt(S.p.health(g), 0)), Bool.not(anyother(g, m)))
  C.when(ok, g, +h => boss.victory(h, k))


def a.keendie(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = a.fall(g, m)
  C.when(Bool.not(anyother(g1, m)), g1, +h => door.tag(h, 666, 3))


def brain.find(n: Nat, more: Bool, +g: S.Sim, +i: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +hit = Bool.and(alive(g, i), U32.is_eq(S.m.type(g, i), 27))
      +nb = S.sim.nbrain(g)
      +g1 = C.when(Bool.and(hit, U32.is_lt(nb, 32)), g, +h => S.sim.nbrain.set(S.sim.brains.set(h, T.set(U32, S.sim.brains(h), nb, i)), (nb + 1 : U32)))
      +nx = C.tnext(g1, i)
      brain.find(p, U32.is_ne(nx, 0), g1, nx)
    case _ _:
      g


def a.brainawake(+g: S.Sim, +m: U32) -> S.Sim:
  +g1 = S.sim.brainon.set(S.sim.nbrain.set(g, 0), 0)
  +f = C.tnext(g1, 0)
  sound(brain.find(65536n, U32.is_ne(f, 0), g1, f), 0, 96)


def brain.boom(+g: S.Sim, +x: U32, +y: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +id = C.newid(g1)
  +g2 = spawn(g1, x, y, (128 + r * 131072 : U32), 33)
  +r2 = C.rnd(g2)
  +g3 = setstate(S.m.momz.set(C.rnd.next(g2), id, (r2 * 512 : U32)), id, 799)
  tics.rand(g3, id, 7)


def brain.row(n: Nat, more: Bool, +g: S.Sim, +x: U32, +end: U32, +y: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = brain.boom(g, x, y)
      +nx = (x + 524288 : U32)
      brain.row(p, F.lt(nx, end), g1, nx, end, y)
    case _ _:
      g


def a.brainscream(+g: S.Sim, +m: U32) -> S.Sim:
  +x = S.m.x(g, m)
  +x0 = (x - 12845056 : U32)
  +end = (x + 20971520 : U32)
  sound(brain.row(128n, F.lt(x0, end), g, x0, end, (S.m.y(g, m) - 20971520 : U32)), 0, 98)


def a.brainexplode(+g: S.Sim, +m: U32) -> S.Sim:
  +s = subr(g)
  brain.boom(subr.next(g), (S.m.x(g, m) + s * 2048 : U32), S.m.y(g, m))


def brain.shot(+g: S.Sim, +m: U32, +targ: U32) -> S.Sim:
  +g1 = missile.spawn(g, m, targ, 28)
  +mo = S.sim.ret(g1)
  +g2 = S.m.target.set(g1, mo, targ)
  +tc = C.state(g2, S.m.state(g2, mo), 2)
  +rt = sdiv(sdiv((S.m.y(g2, targ) - S.m.y(g2, m) : U32), S.m.momy(g2, mo)), tc)
  sound(S.m.reaction.set(g2, mo, rt), 0, 94)


def a.brainspit(+g: S.Sim, +m: U32) -> S.Sim:
  +e = (S.sim.easy(g) .^. 1 : U32)
  +g1 = S.sim.easy.set(g, e)
  +n = S.sim.nbrain(g1)
  +on = S.sim.brainon(g1)
  +targ = T.get(U32, S.sim.brains(g1), on, 0)
  +skip = Bool.or(Bool.and(U32.is_le(S.mp.skill(g1), 1), U32.is_eq(e, 0)), U32.is_eq(n, 0))
  C.when(Bool.not(skip), g1, +h => brain.shot(S.sim.brainon.set(h, ((on + 1) % n : U32)), m, targ))


def fly.type(+r: U32) -> U32:
  Bool.pick(U32, U32.is_lt(r, 50), 11, Bool.pick(U32, U32.is_lt(r, 90), 12, Bool.pick(U32, U32.is_lt(r, 120), 13,
    Bool.pick(U32, U32.is_lt(r, 130), 22, Bool.pick(U32, U32.is_lt(r, 160), 14, Bool.pick(U32, U32.is_lt(r, 162), 3,
      Bool.pick(U32, U32.is_lt(r, 172), 5, Bool.pick(U32, U32.is_lt(r, 192), 20, Bool.pick(U32, U32.is_lt(r, 222), 8,
        Bool.pick(U32, U32.is_lt(r, 246), 17, 15))))))))))


def fly.spawn(+g: S.Sim, +m: U32) -> S.Sim:
  +t = S.m.target(g, m)
  +x = S.m.x(g, t)
  +y = S.m.y(g, t)
  +z = S.m.z(g, t)
  +fog = C.newid(g)
  +g1 = sound(spawn(g, x, y, z, 29), fog, 35)
  +r = C.rnd(g1)
  +g2 = C.rnd.next(g1)
  +n = C.newid(g2)
  +g3 = lookfor(spawn(g2, x, y, z, fly.type(r)), n, True{})
  +g4 = C.when(yes(g3), g3, +h => setstate(h, n, C.info(h, S.m.type(h, n), 3)))
  remove(teleportmove(g4, n, S.m.x(g4, n), S.m.y(g4, n)), m)


def a.spawnfly(+g: S.Sim, +m: U32) -> S.Sim:
  +rt = (S.m.reaction(g, m) - 1 : U32)
  C.when(U32.is_eq(rt, 0), S.m.reaction.set(g, m, rt), +h => fly.spawn(h, m))


def bfg.dmg.sum(n: Nat, +g: S.Sim, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      bfg.dmg.sum(p, C.rnd.next(g), (acc + (C.rnd(g) .&. 7) + 1 : U32))


def rnd.skip(n: Nat, +g: S.Sim) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      rnd.skip(p, C.rnd.next(g))


def bfg.zap(+g: S.Sim, +m: U32, +lt: U32) -> S.Sim:
  +src = S.m.target(g, m)
  +g1 = spawn(g, S.m.x(g, lt), S.m.y(g, lt), (S.m.z(g, lt) + F.sar(S.m.height(g, lt), 2n) : U32), 42)
  +d = bfg.dmg.sum(15n, g1, 0)
  damage(rnd.skip(15n, g1), lt, src, src, d)


def bfg.rays(n: Nat, +g: S.Sim, +m: U32, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +an = (S.m.angle(g, m) - 536870912 + 26843545 * i : U32)
      +g1 = aim(g, S.m.target(g, m), an, 67108864)
      +lt = S.tm.ltarget(g1)
      bfg.rays(p, C.when(U32.is_ne(lt, 0), g1, +h => bfg.zap(h, m, lt)), m, (i + 1 : U32))


def a.bfgspray(+g: S.Sim, +m: U32) -> S.Sim:
  bfg.rays(40n, g, m, 0)


def rsound.mark(+g: S.Sim, +s: U32, +blocks: U32, +tgt: U32) -> S.Sim:
  +g1 = S.sim.secv.set(g, T.set(U32, S.sim.secv(g), s, S.sim.vc(g)))
  +g2 = S.sim.sndn.set(g1, T.set(U32, S.sim.sndn(g1), s, (blocks + 1 : U32)))
  S.sim.sndt.set(g2, T.set(U32, S.sim.sndt(g2), s, tgt))


def rsound.open?(+g: S.Sim, +ld: U32, +s: U32, +blocks: U32, +tgt: U32) -> S.Sim:
  +fl = S.l.flags(g, ld)
  +fs = S.l.fsec(g, ld)
  +other = Bool.pick(U32, U32.is_eq(fs, s), S.l.bsec(g, ld), fs)
  C.br(F.le(S.tm.orange(g), 0), g, +h => h,
    +h => C.br(C.has(fl, 64), h, +k => C.when(U32.is_eq(blocks, 0), k, +q => rsound(q, other, 1, tgt)), +k => rsound(k, other, blocks, tgt)))


def rsound.line?(+g: S.Sim, +ld: U32, +s: U32, +blocks: U32, +tgt: U32) -> S.Sim:
  C.br(C.has(S.l.flags(g, ld), 4), g, +h => rsound.open(G.opening(h, ld), ld, s, blocks, tgt), +h => h)


def rsound.lines?(xs: List<&2, U32>, +g: S.Sim, +s: U32, +blocks: U32, +tgt: U32) -> S.Sim:
  match xs:
    case +ld <> t:
      rsound.lines(t, rsound.line(g, ld, s, blocks, tgt), s, blocks, tgt)
    case []:
      g


def rsound?(+g: S.Sim, +s: U32, +blocks: U32, +tgt: U32) -> S.Sim:
  +seen = Bool.and(U32.is_eq(T.get(U32, S.sim.secv(g), s, 0), S.sim.vc(g)), F.le(T.get(U32, S.sim.sndn(g), s, 0), (blocks + 1 : U32)))
  C.br(seen, g, +h => h, +h => rsound.lines(C.seclines(h, s), rsound.mark(h, s, blocks, tgt), s, blocks, tgt))


def noise(+g: S.Sim, +tgt: U32, +em: U32) -> S.Sim:
  rsound(C.vc.bump(g), G.mobsec(g, em), 0, tgt)


def action(+g: S.Sim, +m: U32, +a: U32) -> S.Sim:
  C.br(U32.is_lt(a, 23), g, +h => h,
    +h => C.br(U32.is_le(a, 48), h,
      +h => C.br(U32.is_le(a, 35), h,
        +h => C.br(U32.is_le(a, 29), h,
          +h => C.br(U32.is_le(a, 26), h,
            +h => C.br(U32.is_le(a, 24), h,
              +h => C.br(U32.is_le(a, 23), h,
                +h => a.bfgspray(h, m),
                +h => radius(h, m, S.m.target(h, m), 128)),
              +h => C.br(U32.is_le(a, 25), h,
                +h => a.pain(h, m),
                +h => a.playerscream(h, m))),
            +h => C.br(U32.is_le(a, 28), h,
              +h => C.br(U32.is_le(a, 27), h,
                +h => a.fall(h, m),
                +h => sound(h, m, 31)),
              +h => a.look(h, m))),
          +h => C.br(U32.is_le(a, 32), h,
            +h => C.br(U32.is_le(a, 31), h,
              +h => C.br(U32.is_le(a, 30), h,
                +h => a.chase(h, m),
                +h => a.face(h, m)),
              +h => targeted(h, m, +k => a.posattack(k, m))),
            +h => C.br(U32.is_le(a, 34), h,
              +h => C.br(U32.is_le(a, 33), h,
                +h => a.scream(h, m),
                +h => targeted(h, m, +k => a.sposattack(k, m, 3))),
              +h => a.vilechase(h, m)))),
        +h => C.br(U32.is_le(a, 42), h,
          +h => C.br(U32.is_le(a, 39), h,
            +h => C.br(U32.is_le(a, 37), h,
              +h => C.br(U32.is_le(a, 36), h,
                +h => sound(h, m, 54),
                +h => targeted(h, m, +k => a.viletarget(k, m))),
              +h => C.br(U32.is_le(a, 38), h,
                +h => targeted(h, m, +k => a.vileattack(k, m)),
                +h => a.fire(sound(h, m, 92), m))),
            +h => C.br(U32.is_le(a, 41), h,
              +h => C.br(U32.is_le(a, 40), h,
                +h => a.fire(h, m),
                +h => a.fire(sound(h, m, 91), m)),
              +h => a.tracer(h, m))),
          +h => C.br(U32.is_le(a, 45), h,
            +h => C.br(U32.is_le(a, 44), h,
              +h => C.br(U32.is_le(a, 43), h,
                +h => targeted(h, m, +k => a.face(sound(k, m, 56), m)),
                +h => targeted(h, m, +k => attack.melee(k, m, True{}, 53, 10, 6, 0))),
              +h => targeted(h, m, +k => a.skelmissile.go(k, m))),
            +h => C.br(U32.is_le(a, 47), h,
              +h => C.br(U32.is_le(a, 46), h,
                +h => sound(a.face(h, m), m, 99),
                +h => a.fat1(h, m)),
              +h => a.fat2(h, m))))),
      +h => C.br(U32.is_le(a, 61), h,
        +h => C.br(U32.is_le(a, 55), h,
          +h => C.br(U32.is_le(a, 52), h,
            +h => C.br(U32.is_le(a, 50), h,
              +h => C.br(U32.is_le(a, 49), h,
                +h => a.fat3(h, m),
                +h => a.bossdeath(h, m)),
              +h => C.br(U32.is_le(a, 51), h,
                +h => targeted(h, m, +k => a.sposattack(k, m, 1)),
                +h => a.refire(h, m, 40))),
            +h => C.br(U32.is_le(a, 54), h,
              +h => C.br(U32.is_le(a, 53), h,
                +h => targeted(h, m, +k => attack.melee(k, m, True{}, 55, 8, 3, 31)),
                +h => targeted(h, m, +k => attack.melee(k, m, True{}, 0, 10, 4, 0))),
              +h => targeted(h, m, +k => attack.melee(k, m, True{}, 0, 6, 10, 32)))),
          +h => C.br(U32.is_le(a, 58), h,
            +h => C.br(U32.is_le(a, 57), h,
              +h => C.br(U32.is_le(a, 56), h,
                +h => targeted(h, m, +k => attack.melee(k, m, False{}, 55, 8, 10, 16)),
                +h => a.skullattack(h, m)),
              +h => a.chase(sound(h, m, 85), m)),
            +h => C.br(U32.is_le(a, 60), h,
              +h => C.br(U32.is_le(a, 59), h,
                +h => a.refire(h, m, 10),
                +h => a.chase(sound(h, m, 79), m)),
              +h => targeted(h, m, +k => a.missile(k, m, 36))))),
        +h => C.br(U32.is_le(a, 68), h,
          +h => C.br(U32.is_le(a, 65), h,
            +h => C.br(U32.is_le(a, 63), h,
              +h => C.br(U32.is_le(a, 62), h,
                +h => a.chase(sound(h, m, 84), m),
                +h => targeted(h, m, +k => a.missile(k, m, 33))),
              +h => C.br(U32.is_le(a, 64), h,
                +h => targeted(h, m, +k => a.painattack(k, m)),
                +h => a.paindie(h, m))),
            +h => C.br(U32.is_le(a, 67), h,
              +h => C.br(U32.is_le(a, 66), h,
                +h => a.keendie(h, m),
                +h => sound(h, 0, 97)),
              +h => a.brainscream(h, m))),
          +h => C.br(U32.is_le(a, 71), h,
            +h => C.br(U32.is_le(a, 70), h,
              +h => C.br(U32.is_le(a, 69), h,
                +h => exit(h, 1),
                +h => a.brainawake(h, m)),
              +h => a.brainspit(h, m)),
            +h => C.br(U32.is_le(a, 73), h,
              +h => C.br(U32.is_le(a, 72), h,
                +h => a.spawnfly(sound(h, m, 95), m),
                +h => a.spawnfly(h, m)),
              +h => a.brainexplode(h, m)))))))


def winfo(+w: U32, +f: U32) -> U32:
  T.get(U32, T.from_list(U32, [5, 4, 3, 2, 5, 0, 0, 12, 11, 10, 13, 17, 1, 20, 19, 18, 21, 30, 0, 51, 50, 49, 52, 55,
    3, 59, 58, 57, 60, 63, 2, 76, 75, 74, 77, 79, 2, 83, 82, 81, 84, 88, 5, 70, 69, 67, 71, 0, 1, 34, 33, 32, 35, 47]), (w * 6 + f : U32), 0)


def nochange() -> U32:
  10


def bottom() -> U32:
  8388608


def top() -> U32:
  2097152


def psp(+g: S.Sim, +pos: U32, +f: U32) -> U32:
  S.pget(g, (53 + pos * 4 + f : U32))


def psp.set(+g: S.Sim, +pos: U32, +f: U32, +v: U32) -> S.Sim:
  S.pput(g, (53 + pos * 4 + f : U32), v)


def pammo(+g: S.Sim, +w: U32) -> U32:
  I.ammo(g, I.wammo(w))


def useammo(+g: S.Sim, +n: U32) -> S.Sim:
  +k = I.wammo(S.p.ready(g))
  I.ammo.set(g, k, (I.ammo(g, k) - n : U32))


def psp.enter(+g: S.Sim, +pos: U32, +st: U32) -> S.Sim:
  +g1 = psp.set(psp.set(g, pos, 0, st), pos, 1, C.state(g, st, 2))
  +m1 = C.state(g1, st, 5)
  C.when(U32.is_ne(m1, 0), g1, +h => psp.set(psp.set(h, pos, 2, (m1 << 16n : U32)), pos, 3, (C.state(h, st, 6) << 16n : U32)))


def psp.go?(n: Nat, more: Bool, +g: S.Sim, +pos: U32, +st: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      C.br(U32.is_eq(st, 0), g, +h => psp.set(h, pos, 0, 0),
        +h => psp.after(p, pact(psp.enter(h, pos, st), pos, C.state(h, st, 3)), pos))
    case _ _:
      g


def psp.after?(n: Nat, +g: S.Sim, +pos: U32) -> S.Sim:
  +cur = psp(g, pos, 0)
  psp.go(n, Bool.and(U32.is_ne(cur, 0), U32.is_eq(psp(g, pos, 1), 0)), g, pos, C.state(g, cur, 4))


def setpsp?(+g: S.Sim, +pos: U32, +st: U32) -> S.Sim:
  psp.go(1000n, True{}, g, pos, st)


def bringup?(+g: S.Sim) -> S.Sim:
  +p0 = S.p.pending(g)
  +pw = Bool.pick(U32, U32.is_eq(p0, nochange()), S.p.ready(g), p0)
  +g1 = C.when(U32.is_eq(pw, 7), g, +h => sound(h, S.p.mo(h), 10))
  setpsp(psp.set(S.p.pending.set(g1, nochange()), 0, 3, bottom()), 0, winfo(pw, 1))


def setuppsprites?(+g: S.Sim) -> S.Sim:
  +g1 = psp.set(psp.set(g, 0, 0, 0), 1, 0, 0)
  bringup(S.p.pending.set(g1, S.p.ready(g1)))


def ammo.pick(+g: S.Sim) -> U32:
  +com = S.mp.commercial(g)
  Bool.pick(U32, Bool.and(U32.is_ne(I.own(g, 5), 0), U32.is_ne(I.ammo(g, 2), 0)), 5,
    Bool.pick(U32, Bool.and(Bool.and(U32.is_ne(I.own(g, 8), 0), U32.is_gt(I.ammo(g, 1), 2)), com), 8,
      Bool.pick(U32, Bool.and(U32.is_ne(I.own(g, 3), 0), U32.is_ne(I.ammo(g, 0), 0)), 3,
        Bool.pick(U32, Bool.and(U32.is_ne(I.own(g, 2), 0), U32.is_ne(I.ammo(g, 1), 0)), 2,
          Bool.pick(U32, U32.is_ne(I.ammo(g, 0), 0), 1,
            Bool.pick(U32, U32.is_ne(I.own(g, 7), 0), 7,
              Bool.pick(U32, Bool.and(U32.is_ne(I.own(g, 4), 0), U32.is_ne(I.ammo(g, 3), 0)), 4,
                Bool.pick(U32, Bool.and(U32.is_ne(I.own(g, 6), 0), U32.is_gt(I.ammo(g, 2), 40)), 6, 0))))))))


def checkammo?(+g: S.Sim) -> S.Sim:
  +w = S.p.ready(g)
  +k = I.wammo(w)
  +cnt = Bool.pick(U32, U32.is_eq(w, 6), 40, Bool.pick(U32, U32.is_eq(w, 8), 2, 1))
  +ok = Bool.or(U32.is_eq(k, 5), U32.is_ge(I.ammo(g, k), cnt))
  C.br(ok, g, +h => S.sim.ret.set(h, 1),
    +h => S.sim.ret.set(setpsp(S.p.pending.set(h, ammo.pick(h)), 0, winfo(w, 2)), 0))


def fireweapon.go?(+g: S.Sim) -> S.Sim:
  +mo = S.p.mo(g)
  +g1 = setpsp(setstate(g, mo, 154), 0, winfo(S.p.ready(g), 4))
  noise(g1, mo, mo)


def fireweapon?(+g: S.Sim) -> S.Sim:
  +g1 = checkammo(g)
  C.when(yes(g1), g1, +h => fireweapon.go(h))


def ready.bob(+g: S.Sim, +pos: U32) -> S.Sim:
  +tb = S.mp.tb(g)
  +bob = S.p.bob(g)
  +a = ((128 * S.sim.time(g)) .&. 8191 : U32)
  +g1 = psp.set(g, pos, 2, (65536 + F.mul(bob, V.sine(tb, (a + 2048 : U32))) : U32))
  psp.set(g1, pos, 3, (top() + F.mul(bob, V.sine(tb, (a .&. 4095 : U32))) : U32))


def ready.fire?(+g: S.Sim, +pos: U32) -> S.Sim:
  +w = S.p.ready(g)
  C.br(C.has(S.p.buttons(g), 1), g,
    +h => C.br(Bool.or(U32.is_eq(S.p.attackdown(h), 0), Bool.and(U32.is_ne(w, 4), U32.is_ne(w, 6))), h,
      +k => fireweapon(S.p.attackdown.set(k, 1)),
      +k => ready.bob(k, pos)),
    +h => ready.bob(S.p.attackdown.set(h, 0), pos))


def w.weaponready?(+g: S.Sim, +pos: U32) -> S.Sim:
  +mo = S.p.mo(g)
  +ms = S.m.state(g, mo)
  +g1 = C.when(Bool.or(U32.is_eq(ms, 154), U32.is_eq(ms, 155)), g, +h => setstate(h, mo, 149))
  +g2 = C.when(Bool.and(U32.is_eq(S.p.ready(g1), 7), U32.is_eq(psp(g1, pos, 0), 67)), g1, +h => sound(h, mo, 11))
  C.br(Bool.or(U32.is_ne(S.p.pending(g2), nochange()), U32.is_eq(S.p.health(g2), 0)), g2,
    +h => setpsp(h, 0, winfo(S.p.ready(h), 2)),
    +h => ready.fire(h, pos))


def w.refire?(+g: S.Sim) -> S.Sim:
  +go = Bool.and(Bool.and(C.has(S.p.buttons(g), 1), U32.is_eq(S.p.pending(g), nochange())), U32.is_ne(S.p.health(g), 0))
  C.br(go, g, +h => fireweapon(S.p.refire.set(h, (S.p.refire(h) + 1 : U32))), +h => checkammo(S.p.refire.set(h, 0)))


def w.lower?(+g: S.Sim, +pos: U32) -> S.Sim:
  +sy = (psp(g, pos, 3) + 393216 : U32)
  +g1 = psp.set(g, pos, 3, sy)
  C.br(F.lt(sy, bottom()), g1, +h => h,
    +h => C.br(U32.is_eq(S.p.state(h), 1), h, +k => psp.set(k, pos, 3, bottom()),
      +k => C.br(U32.is_eq(S.p.health(k), 0), k, +q => setpsp(q, 0, 0),
        +q => bringup(S.p.ready.set(q, S.p.pending(q))))))


def w.raise?(+g: S.Sim, +pos: U32) -> S.Sim:
  +sy = (psp(g, pos, 3) - 393216 : U32)
  +g1 = psp.set(g, pos, 3, sy)
  C.when(F.le(sy, top()), g1, +h => setpsp(psp.set(h, pos, 3, top()), 0, winfo(S.p.ready(h), 3)))


def w.gunflash?(+g: S.Sim) -> S.Sim:
  setpsp(setstate(g, S.p.mo(g), 155), 1, winfo(S.p.ready(g), 5))


def melee.slope(+g: S.Sim, +mo: U32, +an: U32, +dist: U32, +dmg: U32) -> S.Sim:
  +g1 = aim(g, mo, an, dist)
  +lt = S.tm.ltarget(g1)
  S.sim.ret.set(lineattack(g1, mo, an, dist, S.sim.ret(g1), dmg), lt)


def w.punch.hit(+g: S.Sim, +mo: U32, +lt: U32) -> S.Sim:
  C.when(U32.is_ne(lt, 0), g, +h => S.m.angle.set(sound(h, mo, 83), mo, toward(h, mo, lt)))


def w.punch(+g: S.Sim) -> S.Sim:
  +mo = S.p.mo(g)
  +d0 = (((C.rnd(g) % 10) + 1) << 1n : U32)
  +g1 = C.rnd.next(g)
  +dmg = Bool.pick(U32, U32.is_ne(S.p.pw1(g1), 0), (d0 * 10 : U32), d0)
  +an = (S.m.angle(g1, mo) + (subr(g1) << 18n) : U32)
  +g2 = melee.slope(subr.next(g1), mo, an, 4194304, dmg)
  w.punch.hit(g2, mo, S.sim.ret(g2))


def saw.turn(+g: S.Sim, +mo: U32, +lt: U32) -> S.Sim:
  +an = toward(g, mo, lt)
  +ma = S.m.angle(g, mo)
  +d = (an - ma : U32)
  +na = Bool.pick(U32, U32.is_gt(d, 2147483648),
    Bool.pick(U32, U32.is_lt(d, 4241280205), (an + 51130563 : U32), (ma - 53687091 : U32)),
    Bool.pick(U32, U32.is_gt(d, 53687091), (an - 51130563 : U32), (ma + 53687091 : U32)))
  +g1 = S.m.angle.set(sound(g, mo, 13), mo, na)
  S.m.flags.set(g1, mo, (S.m.flags(g1, mo) .|. 128 : U32))


def w.saw(+g: S.Sim) -> S.Sim:
  +mo = S.p.mo(g)
  +dmg = (2 * ((C.rnd(g) % 10) + 1) : U32)
  +g1 = C.rnd.next(g)
  +an = (S.m.angle(g1, mo) + (subr(g1) << 18n) : U32)
  +g2 = melee.slope(subr.next(g1), mo, an, 4194305, dmg)
  +lt = S.sim.ret(g2)
  C.br(U32.is_eq(lt, 0), g2, +h => sound(h, mo, 12), +h => saw.turn(h, mo, lt))


def aim.try(+g: S.Sim, +mo: U32, +an: U32, f: S.Sim -> S.Sim) -> S.Sim:
  +g1 = aim(S.tm.vx.set(g, an), mo, an, 67108864)
  C.br(U32.is_ne(S.tm.ltarget(g1), 0), g1, +h => h, f)


def bulletslope(+g: S.Sim, +mo: U32) -> S.Sim:
  +an = S.m.angle(g, mo)
  aim.try(g, mo, an, +h => aim.try(h, mo, (an + 67108864 : U32), +k => aim.try(k, mo, (an - 67108864 : U32), +q => q)))


def gunshot(+g: S.Sim, +mo: U32, +acc: Bool, +slope: U32) -> S.Sim:
  +dmg = (5 * ((C.rnd(g) % 3) + 1) : U32)
  +g1 = C.rnd.next(g)
  +a0 = S.m.angle(g1, mo)
  C.br(acc, g1, +h => lineattack(h, mo, a0, 134217728, slope, dmg),
    +h => lineattack(subr.next(h), mo, (a0 + (subr(h) << 18n) : U32), 134217728, slope, dmg))


def gunshots(n: Nat, +g: S.Sim, +mo: U32, +slope: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      gunshots(p, gunshot(g, mo, False{}, slope), mo, slope)


def pellets(n: Nat, +g: S.Sim, +mo: U32, +slope: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +dmg = (5 * ((C.rnd(g) % 3) + 1) : U32)
      +g1 = C.rnd.next(g)
      +an = (S.m.angle(g1, mo) + (subr(g1) << 19n) : U32)
      +g2 = subr.next(g1)
      +sl = (slope + (subr(g2) << 5n) : U32)
      pellets(p, lineattack(subr.next(g2), mo, an, 134217728, sl, dmg), mo, slope)


def fire.prep?(+g: S.Sim, +n: U32, +flash: U32) -> S.Sim:
  +mo = S.p.mo(g)
  +g1 = useammo(setstate(g, mo, 155), n)
  bulletslope(setpsp(g1, 1, flash), mo)


def w.firepistol?(+g: S.Sim) -> S.Sim:
  +g1 = fire.prep(sound(g, S.p.mo(g), 1), 1, winfo(S.p.ready(g), 5))
  gunshot(g1, S.p.mo(g1), U32.is_eq(S.p.refire(g1), 0), S.sim.ret(g1))


def w.fireshotgun?(+g: S.Sim) -> S.Sim:
  +g1 = fire.prep(sound(g, S.p.mo(g), 2), 1, winfo(S.p.ready(g), 5))
  gunshots(7n, g1, S.p.mo(g1), S.sim.ret(g1))


def w.fireshotgun2?(+g: S.Sim) -> S.Sim:
  +g1 = fire.prep(sound(g, S.p.mo(g), 4), 2, winfo(S.p.ready(g), 5))
  pellets(20n, g1, S.p.mo(g1), S.sim.ret(g1))


def w.firecgun.go?(+g: S.Sim, +pos: U32) -> S.Sim:
  +g1 = fire.prep(g, 1, (winfo(S.p.ready(g), 5) + psp(g, pos, 0) - 52 : U32))
  gunshot(g1, S.p.mo(g1), U32.is_eq(S.p.refire(g1), 0), S.sim.ret(g1))


def w.firecgun?(+g: S.Sim, +pos: U32) -> S.Sim:
  +g1 = sound(g, S.p.mo(g), 1)
  C.when(U32.is_ne(pammo(g1, S.p.ready(g1)), 0), g1, +h => w.firecgun.go(h, pos))


def pmissile.aim(+g: S.Sim, +mo: U32) -> S.Sim:
  +an = S.m.angle(g, mo)
  aim.try(g, mo, an, +h => aim.try(h, mo, (an + 67108864 : U32), +k => aim.try(k, mo, (an - 67108864 : U32), +q => S.sim.ret.set(S.tm.vx.set(q, an), 0))))


def pmissile(+g: S.Sim, +mo: U32, +k: U32) -> S.Sim:
  +g1 = pmissile.aim(g, mo)
  +an = S.tm.vx(g1)
  +slope = S.sim.ret(g1)
  +id = C.newid(g1)
  +g2 = spawn(g1, S.m.x(g1, mo), S.m.y(g1, mo), (S.m.z(g1, mo) + 2097152 : U32), k)
  +ss = C.info(g2, k, 4)
  +g3 = S.m.target.set(C.when(U32.is_ne(ss, 0), g2, +h => sound(h, id, ss)), id, mo)
  +sp = C.info(g3, k, 15)
  +g4 = missile.aim(g3, id, an)
  missile.check(S.m.momz.set(g4, id, F.mul(sp, slope)), id)


def w.fireplasma?(+g: S.Sim) -> S.Sim:
  +g0 = useammo(g, 1)
  +r = (C.rnd(g0) .&. 1 : U32)
  +g1 = setpsp(C.rnd.next(g0), 1, (winfo(S.p.ready(g0), 5) + r : U32))
  pmissile(g1, S.p.mo(g1), 34)


def pact?(+g: S.Sim, +pos: U32, +a: U32) -> S.Sim:
  C.br(U32.is_le(a, 11), g,
    +h => C.br(U32.is_le(a, 5), h,
      +h => C.br(U32.is_le(a, 2), h,
        +h => C.br(U32.is_le(a, 1), h,
          +h => C.when(U32.is_eq(a, 1), h, +k => S.p.extralight.set(k, 0)),
          +h => w.weaponready(h, pos)),
        +h => C.br(U32.is_le(a, 3), h,
          +h => w.lower(h, pos),
          +h => C.br(U32.is_le(a, 4), h, +k => w.raise(k, pos), +k => w.punch(k)))),
      +h => C.br(U32.is_le(a, 8), h,
        +h => C.br(U32.is_le(a, 6), h,
          +h => w.refire(h),
          +h => C.br(U32.is_le(a, 7), h, +k => w.firepistol(k), +k => S.p.extralight.set(k, 1))),
        +h => C.br(U32.is_le(a, 9), h,
          +h => w.fireshotgun(h),
          +h => C.br(U32.is_le(a, 10), h, +k => S.p.extralight.set(k, 2), +k => w.fireshotgun2(k))))),
    +h => C.br(U32.is_le(a, 16), h,
      +h => C.br(U32.is_le(a, 13), h,
        +h => C.br(U32.is_le(a, 12), h, +k => checkammo(k), +k => sound(k, S.p.mo(k), 5)),
        +h => C.br(U32.is_le(a, 14), h,
          +h => sound(h, S.p.mo(h), 7),
          +h => C.br(U32.is_le(a, 15), h, +k => w.refire(sound(k, S.p.mo(k), 6)), +k => w.firecgun(k, pos)))),
      +h => C.br(U32.is_le(a, 19), h,
        +h => C.br(U32.is_le(a, 17), h,
          +h => w.gunflash(h),
          +h => C.br(U32.is_le(a, 18), h, +k => pmissile(useammo(k, 1), S.p.mo(k), 33), +k => w.saw(k))),
        +h => C.br(U32.is_le(a, 20), h,
          +h => w.fireplasma(h),
          +h => C.br(U32.is_le(a, 21), h, +k => sound(k, S.p.mo(k), 9), +k => pmissile(useammo(k, 40), S.p.mo(k), 35))))))


def psp.tick?(+g: S.Sim, +pos: U32) -> S.Sim:
  +st = psp(g, pos, 0)
  +tc = psp(g, pos, 1)
  C.when(Bool.and(U32.is_ne(st, 0), U32.is_ne(tc, 4294967295)), g,
    +h => C.br(U32.is_eq(tc, 1), psp.set(h, pos, 1, 0), +k => setpsp(k, pos, C.state(k, psp(k, pos, 0), 4)), +k => psp.set(k, pos, 1, (tc - 1 : U32))))


def movepsprites?(+g: S.Sim) -> S.Sim:
  +g1 = psp.tick(psp.tick(g, 0), 1)
  psp.set(psp.set(g1, 1, 2, psp(g1, 0, 2)), 1, 3, psp(g1, 0, 3))


def owned(n: Nat, +g: S.Sim, +i: U32, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      owned(p, g, (i + 1 : U32), (acc .|. (C.b2u(U32.is_ne(I.own(g, i), 0)) << U32.to_nat(i)) : U32))


def armsmask(n: Nat, +g: S.Sim, +i: U32, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      armsmask(p, g, (i + 1 : U32), (acc .|. (C.b2u(U32.is_ne(S.pget(g, (34 + i : U32)), 0)) << U32.to_nat(i)) : U32))

def st.start(+g: S.Sim) -> S.Sim:
  +g1 = S.sim.hcount.set(S.sim.stweap.set(S.sim.stold.set(S.sim.stface.set(g, 0), 4294967295), owned(9n, g, 0, 0)), 0)
  S.sim.ui.set(g1, T.set(U32, T.set(U32, S.sim.ui(g1), 97, 0), 98, armsmask(6n, g1, 0, 0)))


def st.pain(+g: S.Sim) -> S.Sim:
  +h0 = S.p.health(g)
  +h = Bool.pick(U32, F.gt(h0, 100), 100, h0)
  C.when(U32.is_ne(h, S.sim.stpainh(g)), g, +k => S.sim.stpainh.set(S.sim.stpainc.set(k, (8 * (sdiv(((100 - h) * 5 : U32), 101)) : U32)), h))


def st.face(+g: S.Sim, +prio: U32, +count: U32, +off: U32) -> S.Sim:
  +g1 = st.pain(g)
  S.sim.stprio.set(S.sim.stcount.set(S.sim.stface.set(g1, (S.sim.stpainc(g1) + off : U32)), count), prio)


def st.dead(+g: S.Sim) -> S.Sim:
  C.when(Bool.and(U32.is_lt(S.sim.stprio(g), 10), U32.is_eq(S.p.health(g), 0)), g,
    +h => S.sim.stcount.set(S.sim.stface.set(S.sim.stprio.set(h, 9), 41), 1))


def st.grin(+g: S.Sim) -> S.Sim:
  +now = owned(9n, g, 0, 0)
  +grin = U32.is_ne(now, S.sim.stweap(g))
  C.when(Bool.and(U32.is_lt(S.sim.stprio(g), 9), U32.is_ne(S.p.bonuscount(g), 0)), g,
    +h => C.when(grin, S.sim.stweap.set(h, now), +k => st.face(k, 8, 70, 6)))


def st.much(+g: S.Sim) -> Bool:
  F.gt((S.p.health(g) - S.sim.stold(g) : U32), 20)


def st.turn(+g: S.Sim) -> S.Sim:
  +mo = S.p.mo(g)
  +bga = toward(g, mo, S.p.attacker(g))
  +ma = S.m.angle(g, mo)
  +gt = U32.is_gt(bga, ma)
  +diff = Bool.pick(U32, gt, (bga - ma : U32), (ma - bga : U32))
  +i = Bool.pick(Bool, gt, U32.is_gt(diff, 2147483648), U32.is_le(diff, 2147483648))
  st.face(g, 7, 35, Bool.pick(U32, U32.is_lt(diff, 536870912), 7, Bool.pick(U32, i, 3, 4)))


def st.hit(+g: S.Sim) -> S.Sim:
  +att = S.p.attacker(g)
  C.when(Bool.and(Bool.and(U32.is_lt(S.sim.stprio(g), 8), U32.is_ne(S.p.damagecount(g), 0)), Bool.and(U32.is_ne(att, 0), U32.is_ne(att, S.p.mo(g)))), g,
    +h => C.br(st.much(h), h, +k => st.face(k, 7, 35, 5), +k => st.turn(k)))


def st.hurt(+g: S.Sim) -> S.Sim:
  C.when(Bool.and(U32.is_lt(S.sim.stprio(g), 7), U32.is_ne(S.p.damagecount(g), 0)), g,
    +h => C.br(st.much(h), h, +k => st.face(k, 7, 35, 5), +k => st.face(k, 6, 35, 7)))


def st.rampage(+g: S.Sim) -> S.Sim:
  +lad = S.sim.stlad(g)
  C.when(U32.is_lt(S.sim.stprio(g), 6), g,
    +h => C.br(U32.is_ne(S.p.attackdown(h), 0), h,
      +k => C.br(U32.is_eq(lad, 4294967295), k, +q => S.sim.stlad.set(q, 70),
        +q => C.br(U32.is_eq(lad, 1), q, +z => S.sim.stlad.set(st.face(z, 5, 1, 7), 1), +z => S.sim.stlad.set(z, (lad - 1 : U32)))),
      +k => S.sim.stlad.set(k, 4294967295)))


def st.god(+g: S.Sim) -> S.Sim:
  C.when(Bool.and(U32.is_lt(S.sim.stprio(g), 5), Bool.or(C.has(S.p.cheats(g), 2), U32.is_ne(S.p.pw0(g), 0))), g,
    +h => S.sim.stcount.set(S.sim.stface.set(S.sim.stprio.set(h, 4), 40), 1))


def st.idle(+g: S.Sim) -> S.Sim:
  +g1 = C.when(U32.is_eq(S.sim.stcount(g), 0), g, +h => st.face(h, 0, 17, (S.sim.strnd(h) % 3 : U32)))
  S.sim.stcount.set(g1, (S.sim.stcount(g1) - 1 : U32))


def st.ticker(+g: S.Sim) -> S.Sim:
  +r = ((S.sim.mrnd(g) + 1) .&. 255 : U32)
  +g1 = S.sim.strnd.set(S.sim.mrnd.set(g, r), T.get(U32, S.mp.rndt(g), r, 0))
  +g2 = st.idle(st.god(st.rampage(st.hurt(st.hit(st.grin(st.dead(g1)))))))
  +g3 = S.sim.stold.set(g2, S.p.health(g2))
  +w = S.sim.wipe(g3)
  C.when(U32.is_ne(w, 0), S.sim.wipe.set(g3, (w - 1 : U32)), +h => C.when(U32.is_eq(w, 1), h, +k => S.sim.mrnd.set(k, ((S.sim.mrnd(k) + 64) .&. 255 : U32))))


def hu.ui(+g: S.Sim, +i: U32) -> U32:
  T.get(U32, S.sim.ui(g), i, 0)

def hu.set(+g: S.Sim, +i: U32, +v: U32) -> S.Sim:
  S.sim.ui.set(g, T.set(U32, S.sim.ui(g), i, v))

def hu.ticker(+g: S.Sim) -> S.Sim:
  +c = S.sim.hcount(g)
  +g0 = S.sim.hcount.set(g, Bool.pick(U32, U32.is_ne(c, 0), (c - 1 : U32), 0))
  +g1 = C.when(U32.is_eq(c, 1), g0, +h => hu.set(h, 117, 0))
  +m = S.p.message(g1)
  +dont = U32.is_ne(hu.ui(g1, 116), 0)
  +take = Bool.and(Bool.or(U32.is_eq(hu.ui(g1, 115), 0), dont), Bool.and(U32.is_ne(m, 0), Bool.or(U32.is_eq(hu.ui(g1, 117), 0), dont)))
  C.when(take, g1, +h => hu.set(hu.set(S.p.message.set(S.sim.hcount.set(S.sim.hmsg.set(h, m), 140), 0), 117, C.b2u(dont)), 116, 0))
