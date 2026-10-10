import Base
import ./render.bend as V
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./geo.bend as G
import ./mobj.bend as O
import ./items.bend as I
import ./spec.bend as X
import ./move.bend as M

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
  C.when(Bool.and(Bool.or(U32.is_ne(fwd, 0), U32.is_ne(side, 0)), U32.is_eq(S.m.state(g4, m), 149)), g4, +h => O.setstate(h, m, 150))

def dec(+v: U32) -> U32:
  Bool.pick(U32, U32.is_ne(v, 0), (v - 1 : U32), 0)

def turntoward(+g: S.Sim, +m: U32, +att: U32) -> S.Sim:
  +a = V.angle(S.mp.tb(g), (S.m.x(g, att) - S.m.x(g, m) : U32), (S.m.y(g, att) - S.m.y(g, m) : U32))
  +ma = S.m.angle(g, m)
  +d = (a - ma : U32)
  C.br(Bool.or(U32.is_lt(d, 59652323), U32.is_gt(d, 4235314973)), g, +h => S.p.damagecount.set(S.m.angle.set(h, m, a), dec(S.p.damagecount(h))),
    +h => S.m.angle.set(h, m, Bool.pick(U32, U32.is_lt(d, 2147483648), (ma + 59652323 : U32), (ma - 59652323 : U32))))

def deaththink(+g: S.Sim) -> S.Sim:
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

def live(+g: S.Sim, +m: U32) -> S.Sim:
  +r = S.m.reaction(g, m)
  +g1 = C.br(U32.is_ne(r, 0), g, +h => S.m.reaction.set(h, m, (r - 1 : U32)), +h => moveplayer(h))
  +g2 = calcheight(g1)
  +g3 = C.when(U32.is_ne(S.s.special(g2, G.mobsec(g2, m)), 0), g2, +h => X.playerin(h))
  +g4 = C.when(C.has(S.p.buttons(g3), 128), g3, +h => S.p.buttons.set(h, 0))
  +b = S.p.buttons(g4)
  +g5 = C.when(C.has(b, 4), g4, +h => newweapon(h, b))
  +g6 = C.br(C.has(b, 2), g5, +h => C.when(U32.is_eq(S.p.usedown(h), 0), h, +k => S.p.usedown.set(M.uselines(k), 1)), +h => S.p.usedown.set(h, 0))
  powers(g6, m)

def playerthink(+g: S.Sim) -> S.Sim:
  +m = S.p.mo(g)
  +fl0 = S.m.flags(g, m)
  +fl1 = Bool.pick(U32, C.has(S.p.cheats(g), 1), (fl0 .|. 4096 : U32), C.clr(fl0, 4096))
  +ja = C.has(fl1, 128)
  +g1 = S.m.flags.set(g, m, Bool.pick(U32, ja, C.clr(fl1, 128), fl1))
  +g2 = C.when(ja, g1, +h => S.p.side.set(S.p.fwd.set(S.p.turn.set(h, 0), 100), 0))
  C.br(U32.is_eq(S.p.state(g2), 1), g2, +h => deaththink(h), +h => live(h, m))
