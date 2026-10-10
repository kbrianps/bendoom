import Base
import ./tab.bend as T
import ./level.bend as L
import ./world.bend as R
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./geo.bend as G

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

def setstate.go(n: Nat, more: Bool, +g: S.Sim, +m: U32, +s: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +dead = U32.is_eq(s, 0)
      +g1 = C.br(dead, g, +h => remove(S.m.state.set(h, m, 0), m), +h => setstate.one(h, m, s))
      setstate.go(p, Bool.and(Bool.not(dead), U32.is_eq(S.m.tics(g1, m), 0)), g1, m, C.state(g1, s, 4))
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

def spawnplayer(+g: S.Sim, +x: U32, +y: U32, +a: U32) -> S.Sim:
  +g0 = C.when(U32.is_eq(S.p.state(g), 2), g, +h => reborn(h))
  +m = C.newid(g0)
  +g1 = spawn(g0, (x << 16n : U32), (y << 16n : U32), onfloor(), 0)
  +g2 = S.m.health.set(S.m.player.set(S.m.angle.set(g1, m, angle45(a)), m, 1), m, S.p.health(g1))
  +g3 = S.p.damagecount.set(S.p.message.set(S.p.refire.set(S.p.state.set(S.p.mo.set(g2, m), 0), 0), 0), 0)
  S.p.viewheight.set(S.p.fixedcm.set(S.p.extralight.set(S.p.bonuscount.set(g3, 0), 0), 0), viewheight())

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
