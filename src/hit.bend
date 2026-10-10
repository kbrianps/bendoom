import Base
import ./tab.bend as T
import ./render.bend as V
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./geo.bend as G
import ./mobj.bend as O

def drop.kind(+k: U32) -> U32:
  Bool.pick(U32, Bool.or(U32.is_eq(k, 23), U32.is_eq(k, 1)), 63,
    Bool.pick(U32, U32.is_eq(k, 2), 77, Bool.pick(U32, U32.is_eq(k, 10), 73, 0)))

def dropped(+g: S.Sim, +d: U32) -> S.Sim:
  S.m.flags.set(g, d, (S.m.flags(g, d) .|. 131072 : U32))

def drop(+g: S.Sim, +t: U32) -> S.Sim:
  +d = C.newid(g)
  +item = drop.kind(S.m.type(g, t))
  C.when(U32.is_ne(item, 0), g, +h => dropped(O.spawn(h, S.m.x(h, t), S.m.y(h, t), O.onfloor(), item), d))

def kill.tics(+g: S.Sim, +t: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +tc = (S.m.tics(g1, t) - (r .&. 3) : U32)
  S.m.tics.set(g1, t, Bool.pick(U32, F.lt(tc, 1), 1, tc))

def kill(+g: S.Sim, +src: U32, +t: U32) -> S.Sim:
  +k = S.m.type(g, t)
  +f0 = C.clr(S.m.flags(g, t), 16793604)
  +f1 = (Bool.pick(U32, U32.is_eq(k, 18), f0, C.clr(f0, 512)) .|. 1049600 : U32)
  +g1 = S.m.height.set(S.m.flags.set(g, t, f1), t, F.sar(S.m.height(g, t), 2n))
  +g2 = C.when(C.has(f1, 4194304), g1, +h => S.p.kills.set(h, (S.p.kills(h) + 1 : U32)))
  +pl = U32.is_ne(S.m.player(g2, t), 0)
  +g3 = C.when(pl, g2, +h => S.p.state.set(S.m.flags.set(h, t, C.clr(S.m.flags(h, t), 2)), 1))
  +xd = C.info(g3, k, 13)
  +xs = Bool.and(F.lt(S.m.health(g3, t), F.neg(C.info(g3, k, 2))), U32.is_ne(xd, 0))
  +g4 = O.setstate(g3, t, Bool.pick(U32, xs, xd, C.info(g3, k, 12)))
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
  C.when(Bool.and(U32.is_eq(S.m.state(g1, t), C.info(g1, k, 1)), U32.is_ne(see, 0)), g1, +h => O.setstate(h, t, see))

def pain(+g: S.Sim, +t: U32, +src: U32) -> S.Sim:
  +r = C.rnd(g)
  +g1 = C.rnd.next(g)
  +k = S.m.type(g1, t)
  +fl = S.m.flags(g1, t)
  +g2 = C.when(Bool.and(U32.is_lt(r, C.info(g1, k, 8)), Bool.not(C.has(fl, 16777216))), g1,
    +h => O.setstate(S.m.flags.set(h, t, (fl .|. 64 : U32)), t, C.info(h, k, 7)))
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
