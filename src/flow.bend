import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./game.bend as K
import ./hud.bend as U
import ./render.bend as V
import ./draw.bend as D
import ./screen.bend as P
import ./mem.bend as M
import ./world.bend as R
import ./hudtext.bend as H
import ./menu.bend as Mn
import ./am.bend as Am
import ./setup.bend as Su

type Cast is Data:
  Cast{num: U32, tics: U32, st: U32, death: U32, frames: U32, melee: U32, atk: U32}

def sdiv2(+x: U32) -> U32:
  Bool.pick(U32, F.lt(x, 0), (0 - ((0 - x) / 2) : U32), (x / 2 : U32))

def b2u(+b: Bool) -> U32:
  Bool.pick(U32, b, 1, 0)

def mrand(+g: S.Sim) -> S.Sim:
  S.sim.mrnd.set(g, ((S.sim.mrnd(g) + 1) .&. 255 : U32))

def mval(+g: S.Sim) -> U32:
  T.get(U32, S.mp.rndt(g), S.sim.mrnd(g), 0)

def wipe(+g: S.Sim) -> S.Sim:
  S.sim.mrnd.set(g, ((S.sim.mrnd(g) + 64) .&. 255 : U32))

def text(+i: U32) -> List<&2, U32>:
  T.get(List<&2, U32>, T.from_list(List<&2, U32>, H.texts()), i, [])

def anims(+e: U32) -> T.Vec<U32>:
  T.from_list(U32, Bool.pick(List<&2, U32>, U32.is_eq(e, 0),
    [0, 11, 3, 224, 104, 0, 0, 11, 3, 184, 160, 0, 0, 11, 3, 112, 136, 0, 0, 11, 3, 72, 112, 0, 0, 11, 3, 88, 96, 0,
     0, 11, 3, 64, 48, 0, 0, 11, 3, 192, 40, 0, 0, 11, 3, 136, 16, 0, 0, 11, 3, 80, 16, 0, 0, 11, 3, 64, 24, 0],
    Bool.pick(List<&2, U32>, U32.is_eq(e, 1),
      [2, 11, 1, 128, 136, 1, 2, 11, 1, 128, 136, 2, 2, 11, 1, 128, 136, 3, 2, 11, 1, 128, 136, 4, 2, 11, 1, 128, 136, 5,
       2, 11, 1, 128, 136, 6, 2, 11, 1, 128, 136, 7, 2, 11, 3, 192, 144, 8, 2, 11, 1, 128, 136, 8],
      [0, 11, 3, 104, 168, 0, 0, 11, 3, 40, 136, 0, 0, 11, 3, 160, 96, 0, 0, 11, 3, 104, 80, 0, 0, 11, 3, 120, 32, 0,
       0, 8, 3, 40, 0, 0])))

def nanims(+e: U32) -> U32:
  Bool.pick(U32, U32.is_eq(e, 0), 10, Bool.pick(U32, U32.is_eq(e, 1), 9, 6))

def an(+g: S.Sim, +i: U32, +f: U32) -> U32:
  T.get(U32, anims(U.ui(g, 12)), (i * 6 + f : U32), 0)

def lnode(+e: U32, +n: U32, +f: U32) -> U32:
  T.get(U32, T.from_list(U32, [185, 164, 148, 143, 69, 122, 209, 102, 116, 89, 166, 55, 71, 56, 135, 29, 71, 24,
    254, 25, 97, 50, 188, 64, 128, 78, 214, 92, 133, 130, 208, 136, 148, 140, 235, 158,
    156, 168, 48, 154, 174, 95, 265, 75, 130, 48, 279, 23, 198, 48, 140, 25, 281, 136]), (e * 18 + n * 2 + f : U32), 0)

def animated(+g: S.Sim) -> Bool:
  Bool.and(Bool.not(U.com(g)), U32.is_le(U.ui(g, 12), 2))

def anim.rand(+g: S.Sim, +i: U32) -> S.Sim:
  +g1 = mrand(g)
  U.ui.set(g1, (31 + 2 * i : U32), (U.ui(g1, 0) + 1 + mval(g1) % an(g1, i, 1) : U32))

def anim.init(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +g1 = U.ui.set(g, (30 + 2 * i : U32), 4294967295)
      anim.init(p, C.br(U32.is_eq(an(g1, i, 0), 0), g1, +h => anim.rand(h, i), +h => U.ui.set(h, (31 + 2 * i : U32), (U.ui(h, 0) + 1 : U32))), (i + 1 : U32))

def anims.init(+g: S.Sim) -> S.Sim:
  C.when(animated(g), g, +h => anim.init(U32.to_nat(nanims(U.ui(h, 12))), h, 0))

def anim.fire(+g: S.Sim, +i: U32) -> S.Sim:
  +per = an(g, i, 1)
  +na = an(g, i, 2)
  +ctr = U.ui(g, (30 + 2 * i : U32))
  +b = U.ui(g, 0)
  C.br(U32.is_eq(an(g, i, 0), 0), g,
    +h => U.ui.set(U.ui.set(h, (30 + 2 * i : U32), Bool.pick(U32, F.ge((ctr + 1 : U32), na), 0, (ctr + 1 : U32))), (31 + 2 * i : U32), (b + per : U32)),
    +h => C.when(Bool.and(Bool.not(Bool.and(U32.is_eq(U.ui(h, 3), 0), U32.is_eq(i, 7))), U32.is_eq(U.ui(h, 14), an(h, i, 5))), h,
      +k => U.ui.set(U.ui.set(k, (30 + 2 * i : U32), Bool.pick(U32, U32.is_eq((ctr + 1 : U32), na), ctr, (ctr + 1 : U32))), (31 + 2 * i : U32), (b + per : U32))))

def anim.step(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      anim.step(p, C.when(U32.is_eq(U.ui(g, 0), U.ui(g, (31 + 2 * i : U32))), g, +h => anim.fire(h, i)), (i + 1 : U32))

def anims.update(+g: S.Sim) -> S.Sim:
  C.when(animated(g), g, +h => anim.step(U32.to_nat(nanims(U.ui(h, 12))), h, 0))

def pars(+c: Bool, +ep: U32, +map: U32) -> U32:
  +cp = T.from_list(U32, [30, 90, 120, 120, 90, 150, 120, 120, 270, 90, 210, 150, 150, 150, 210, 150, 420, 150, 210, 150,
    240, 150, 180, 150, 150, 300, 330, 420, 300, 180, 120, 30])
  +dp = T.from_list(U32, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 30, 75, 120, 90, 165, 180, 180, 30, 165,
    0, 90, 90, 90, 120, 90, 360, 240, 30, 170, 0, 90, 45, 90, 150, 90, 90, 165, 30, 135])
  Bool.pick(U32, c, T.get(U32, cp, (map - 1 : U32), 0), Bool.pick(U32, U32.is_lt(ep, 4), T.get(U32, dp, (ep * 10 + map : U32), 0), T.get(U32, cp, map, 0)))

def back9(+ep: U32) -> U32:
  Bool.pick(U32, U32.is_eq(ep, 1), 3, Bool.pick(U32, U32.is_eq(ep, 2), 5, Bool.pick(U32, U32.is_eq(ep, 3), 6, 2)))

def wi.next(+c: Bool, +secret: Bool, +ep: U32, +map: U32) -> U32:
  Bool.pick(U32, c,
    Bool.pick(U32, secret, Bool.pick(U32, U32.is_eq(map, 15), 30, Bool.pick(U32, U32.is_eq(map, 31), 31, (map - 1 : U32))),
      Bool.pick(U32, Bool.or(U32.is_eq(map, 31), U32.is_eq(map, 32)), 15, map)),
    Bool.pick(U32, secret, 8, Bool.pick(U32, U32.is_eq(map, 9), back9(ep), map)))

def max1(+v: U32) -> U32:
  Bool.pick(U32, U32.is_eq(v, 0), 1, v)

def wi.stats(+g: S.Sim) -> S.Sim:
  +g1 = U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(g, 3, 0), 2, 0), 4, 1), 5, 4294967295), 6, 4294967295)
  anims.init(U.ui.set(U.ui.set(U.ui.set(U.ui.set(g1, 7, 4294967295), 8, 4294967295), 9, 4294967295), 10, 35))

def wi.plrs(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +g1 = U.ui.set(U.ui.set(U.ui.set(g, (77 + i : U32), S.pi.kills(g, i)), (81 + i : U32), S.pi.items(g, i)), (85 + i : U32), S.pi.secrets(g, i))
      wi.plrs(p, U.ui.set(U.ui.set(U.ui.set(g1, (61 + i : U32), 0), (65 + i : U32), 0), (69 + i : U32), 0), (i + 1 : U32))

def wi.netstats(+g: S.Sim) -> S.Sim:
  anims.init(U.ui.set(U.ui.set(U.ui.set(U.ui.set(g, 3, 0), 2, 0), 4, 1), 10, 35))

def wi.begin(+g: S.Sim) -> S.Sim:
  C.br(C.net(g), g, +h => wi.netstats(h), +h => wi.stats(h))

def wi.start(+g: S.Sim) -> S.Sim:
  +c = U.com(g)
  +map = U.ui(g, 25)
  +ep = U.ui(g, 26)
  +e0 = (ep - 1 : U32)
  +epsd = Bool.pick(U32, Bool.and(U32.is_ne(U.mode(g), 2), U32.is_gt(e0, 2)), (e0 - 3 : U32), e0)
  +g1 = U.ui.set(U.ui.set(U.ui.set(U.ui.set(g, 12, epsd), 13, (map - 1 : U32)), 14, wi.next(c, U32.is_ne(U.ui(g, 24), 0), ep, map)), 15, S.p.didsecret(g))
  +g2 = U.ui.set(U.ui.set(U.ui.set(U.ui.set(g1, 16, max1(S.sim.kills(g1))), 17, max1(S.sim.items(g1))), 18, max1(S.sim.secrets(g1))), 19, (35 * pars(c, ep, map) : U32))
  +g3 = U.ui.set(U.ui.set(U.ui.set(U.ui.set(g2, 20, S.p.kills(g2)), 21, S.p.items(g2)), 22, S.p.secrets(g2)), 23, S.sim.time(g2))
  wipe(wi.begin(wi.plrs(4n, U.ui.set(U.ui.set(S.sim.gs.set(g3, 1), 0, 0), 1, 0), 0)))

def fin.text(+c: Bool, +ep: U32, +map: U32) -> U32:
  Bool.pick(U32, c,
    Bool.pick(U32, U32.is_eq(map, 6), 4, Bool.pick(U32, U32.is_eq(map, 11), 5, Bool.pick(U32, U32.is_eq(map, 20), 6,
      Bool.pick(U32, U32.is_eq(map, 30), 7, Bool.pick(U32, U32.is_eq(map, 15), 8, 9))))),
    (ep - 1 : U32))

def finale.start(+g: S.Sim) -> S.Sim:
  +t = fin.text(U.com(g), U.ui(g, 26), U.ui(g, 25))
  +g1 = U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(S.sim.gs.set(S.sim.act.set(g, 0), 2), 140, 0), 50, 0), 51, 0), 52, t), 53, U32.from_nat(List.length(&2, U32, text(t))))
  wipe(g1)

def finishpl(+g: S.Sim) -> S.Sim:
  +g1 = S.p.pw5.set(S.p.pw4.set(S.p.pw3.set(S.p.pw2.set(S.p.pw1.set(S.p.pw0.set(g, 0), 0), 0), 0), 0), 0)
  +m = S.p.mo(g1)
  +g2 = S.m.flags.set(g1, m, C.clr(S.m.flags(g1, m), 262144))
  S.p.bonuscount.set(S.p.damagecount.set(S.p.fixedcm.set(S.p.extralight.set(S.p.cards.set(g2, 0), 0), 0), 0), 0)

def finishall(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      finishall(p, C.when(C.ingame(g, i), g, +h => C.withp(i, h, +k => finishpl(k))), (i + 1 : U32))

def secretall(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      secretall(p, S.pi.didsecret.set(g, i, 1), (i + 1 : U32))

def completed(+g: S.Sim) -> S.Sim:
  +g1 = U.ui.set(finishall(4n, g, 0), 140, 0)
  +c = U.com(g1)
  +map = S.mp.map(g1)
  +secret = Bool.and(U32.is_eq(S.sim.exit(g1), 2), Bool.or(Bool.not(c), U.has31(g1)))
  +g2 = U.ui.set(U.ui.set(U.ui.set(g1, 24, b2u(secret)), 25, map), 26, S.mp.episode(g1))
  C.br(Bool.and(Bool.not(c), U32.is_eq(map, 8)), g2, +h => finale.start(h),
    +h => wi.start(C.when(Bool.and(Bool.not(c), U32.is_eq(map, 9)), h, +k => secretall(4n, k, 0))))

def worlddone(+g: S.Sim) -> S.Sim:
  +secret = U32.is_ne(U.ui(g, 24), 0)
  +g1 = C.when(secret, S.sim.act.set(g, 1), +h => S.p.didsecret.set(h, 1))
  +map = U.ui(g1, 25)
  +fin = Bool.and(U.com(g1), Bool.or(Bool.and(secret, Bool.or(U32.is_eq(map, 15), U32.is_eq(map, 31))),
    Bool.or(Bool.or(U32.is_eq(map, 6), U32.is_eq(map, 11)), Bool.or(U32.is_eq(map, 20), U32.is_eq(map, 30)))))
  C.when(fin, g1, +h => finale.start(h))

def wi.accel.one(+g: S.Sim) -> S.Sim:
  +b = S.p.buttons(g)
  +atk = U32.is_ne((b .&. 1 : U32), 0)
  +use = U32.is_ne((b .&. 2 : U32), 0)
  +hit = Bool.or(Bool.and(atk, U32.is_eq(S.p.attackdown(g), 0)), Bool.and(use, U32.is_eq(S.p.usedown(g), 0)))
  S.p.usedown.set(S.p.attackdown.set(C.when(hit, g, +h => U.ui.set(h, 2, 1)), b2u(atk)), b2u(use))

def wi.accel.go(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      wi.accel.go(p, C.when(C.ingame(g, i), g, +h => C.withp(i, h, +k => wi.accel.one(k))), (i + 1 : U32))

def wi.accel(+g: S.Sim) -> S.Sim:
  wi.accel.go(4n, g, 0)

def beep(+g: S.Sim, +sfx: U32) -> S.Sim:
  S.sim.snd.set(g, sfx <> S.sim.snd(g))

def tick4(+g: S.Sim) -> S.Sim:
  C.when(U32.is_eq((U.ui(g, 0) .&. 3 : U32), 0), g, +h => beep(h, 1))

def pct(+have: U32, +max: U32) -> U32:
  ((have * 100) / max : U32)

def wi.all(+g: S.Sim) -> S.Sim:
  +g1 = U.ui.set(U.ui.set(U.ui.set(U.ui.set(g, 2, 0), 5, pct(U.ui(g, 20), U.ui(g, 16))), 6, pct(U.ui(g, 21), U.ui(g, 17))), 7, pct(U.ui(g, 22), U.ui(g, 18)))
  beep(U.ui.set(U.ui.set(U.ui.set(g1, 8, (U.ui(g1, 23) / 35 : U32)), 9, (U.ui(g1, 19) / 35 : U32)), 4, 10), 82)

def wi.count(+g: S.Sim, +slot: U32, +have: U32, +max: U32) -> S.Sim:
  +v = (U.ui(g, slot) + 2 : U32)
  +top = pct(have, max)
  +g1 = tick4(g)
  Bool.pick(S.Sim, F.ge(v, top), beep(U.ui.set(U.ui.set(g1, slot, top), 4, (U.ui(g1, 4) + 1 : U32)), 82), U.ui.set(g1, slot, v))

def wi.times(+g: S.Sim) -> S.Sim:
  +tt = (U.ui(g, 23) / 35 : U32)
  +pt = (U.ui(g, 19) / 35 : U32)
  +t1 = (U.ui(g, 8) + 3 : U32)
  +t2 = Bool.pick(U32, F.ge(t1, tt), tt, t1)
  +p1 = (U.ui(g, 9) + 3 : U32)
  +g1 = U.ui.set(tick4(g), 8, t2)
  +done = F.ge(t2, tt)
  Bool.pick(S.Sim, F.ge(p1, pt), C.when(done, U.ui.set(U.ui.set(g1, 9, pt), 4, Bool.pick(U32, done, (U.ui(g1, 4) + 1 : U32), U.ui(g1, 4))), +h => beep(h, 82)), U.ui.set(g1, 9, p1))

def wi.nostate(+g: S.Sim) -> S.Sim:
  U.ui.set(U.ui.set(U.ui.set(g, 3, 2), 2, 0), 1, 10)

def wi.shownext(+g: S.Sim) -> S.Sim:
  anims.init(U.ui.set(U.ui.set(U.ui.set(g, 3, 1), 2, 0), 1, 140))

def wi.pause(+g: S.Sim) -> S.Sim:
  +c = (U.ui(g, 10) - 1 : U32)
  Bool.pick(S.Sim, U32.is_eq(c, 0), U.ui.set(U.ui.set(g, 4, (U.ui(g, 4) + 1 : U32)), 10, 35), U.ui.set(g, 10, c))

def wi.update(+g: S.Sim) -> S.Sim:
  +g1 = anims.update(g)
  +g2 = C.when(Bool.and(U32.is_ne(U.ui(g1, 2), 0), U32.is_ne(U.ui(g1, 4), 10)), g1, +h => wi.all(h))
  +sp = U.ui(g2, 4)
  C.br(U32.is_eq(sp, 2), g2, +h => wi.count(h, 5, U.ui(h, 20), U.ui(h, 16)),
    +h => C.br(U32.is_eq(sp, 4), h, +k => wi.count(k, 6, U.ui(k, 21), U.ui(k, 17)),
      +k => C.br(U32.is_eq(sp, 6), k, +q => wi.count(q, 7, U.ui(q, 22), U.ui(q, 18)),
        +q => C.br(U32.is_eq(sp, 8), q, +z => wi.times(z),
          +z => C.br(U32.is_eq(sp, 10), z, +y => C.when(U32.is_ne(U.ui(y, 2), 0), y, +x => C.br(U.com(x), beep(x, 3), +w => wi.nostate(w), +w => wi.shownext(w))),
            +y => C.when(U32.is_ne((sp .&. 1 : U32), 0), y, +x => wi.pause(x)))))))

def wi.netall(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +g1 = C.when(C.ingame(g, i), g, +h =>
        U.ui.set(U.ui.set(U.ui.set(h, (61 + i : U32), pct(U.ui(h, (77 + i : U32)), U.ui(h, 16))), (65 + i : U32), pct(U.ui(h, (81 + i : U32)), U.ui(h, 17))), (69 + i : U32), pct(U.ui(h, (85 + i : U32)), U.ui(h, 18))))
      wi.netall(p, g1, (i + 1 : U32))

def wi.netcount.one(+g: S.Sim, +slot: U32, +top: U32) -> S.Sim:
  +v = (U.ui(g, slot) + 2 : U32)
  U.ui.set(g, slot, Bool.pick(U32, F.ge(v, top), top, v))

def wi.netcount(n: Nat, +g: S.Sim, +i: U32, +slot: U32, +src: U32, +max: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +g1 = C.when(C.ingame(g, i), g, +h => wi.netcount.one(h, (slot + i : U32), pct(U.ui(h, (src + i : U32)), U.ui(h, max))))
      wi.netcount(p, g1, (i + 1 : U32), slot, src, max)

def wi.netstill(n: Nat, +g: S.Sim, +i: U32, +slot: U32, +src: U32, +max: U32) -> Bool:
  match n:
    case 0n:
      False{}
    case 1n+p:
      Bool.or(Bool.and(C.ingame(g, i), F.lt(U.ui(g, (slot + i : U32)), pct(U.ui(g, (src + i : U32)), U.ui(g, max)))), wi.netstill(p, g, (i + 1 : U32), slot, src, max))

def wi.netstep(+g: S.Sim, +slot: U32, +src: U32, +max: U32, +next: U32) -> S.Sim:
  +g1 = wi.netcount(4n, tick4(g), 0, slot, src, max)
  C.when(Bool.not(wi.netstill(4n, g1, 0, slot, src, max)), g1, +h => beep(U.ui.set(h, 4, next), 82))

def wi.netupdate(+g: S.Sim) -> S.Sim:
  +g1 = anims.update(g)
  +g2 = C.when(Bool.and(U32.is_ne(U.ui(g1, 2), 0), U32.is_ne(U.ui(g1, 4), 10)), g1, +h => beep(U.ui.set(U.ui.set(wi.netall(4n, h, 0), 2, 0), 4, 10), 82))
  +sp = U.ui(g2, 4)
  C.br(U32.is_eq(sp, 2), g2, +h => wi.netstep(h, 61, 77, 16, 3),
    +h => C.br(U32.is_eq(sp, 4), h, +k => wi.netstep(k, 65, 81, 17, 5),
      +k => C.br(U32.is_eq(sp, 6), k, +q => wi.netstep(q, 69, 85, 18, 9),
        +q => C.br(U32.is_eq(sp, 10), q, +y => C.when(U32.is_ne(U.ui(y, 2), 0), y, +x => C.br(U.com(x), beep(x, 3), +w => wi.nostate(w), +w => wi.shownext(w))),
          +y => C.when(U32.is_ne((sp .&. 1 : U32), 0), y, +x => wi.pause(x))))))

def wi.nextloc(+g: S.Sim) -> S.Sim:
  +g1 = anims.update(g)
  +c = (U.ui(g1, 1) - 1 : U32)
  +g2 = U.ui.set(g1, 1, c)
  C.br(Bool.or(U32.is_eq(c, 0), U32.is_ne(U.ui(g2, 2), 0)), g2, +h => wi.nostate(h), +h => U.ui.set(h, 11, b2u(U32.is_lt((c .&. 31 : U32), 20))))

def wi.noupdate(+g: S.Sim) -> S.Sim:
  +g1 = anims.update(g)
  +c = (U.ui(g1, 1) - 1 : U32)
  C.br(U32.is_eq(c, 0), U.ui.set(g1, 1, c), +h => worlddone(h), +h => h)

def wi.ticker(+g: S.Sim) -> S.Sim:
  +g1 = wi.accel(U.ui.set(g, 0, (U.ui(g, 0) + 1 : U32)))
  +st = U.ui(g1, 3)
  C.br(U32.is_eq(st, 0), g1, +h => C.br(C.net(h), h, +k => wi.netupdate(k), +k => wi.update(k)), +h => C.br(U32.is_eq(st, 1), h, +k => wi.nextloc(k), +k => wi.noupdate(k)))

def ctype(+num: U32) -> U32:
  T.get(U32, T.from_list(U32, [1, 2, 10, 11, 12, 18, 14, 17, 15, 20, 22, 5, 8, 3, 19, 21, 0]), num, 0)

def cinfo(+g: S.Sim, +num: U32, +f: U32) -> U32:
  C.info(g, ctype(num), f)

def cast.get(+g: S.Sim) -> Cast:
  Cast{U.ui(g, 54), U.ui(g, 55), U.ui(g, 56), U.ui(g, 57), U.ui(g, 58), U.ui(g, 59), U.ui(g, 60)}

def cast.put(+g: S.Sim, +c: Cast) -> S.Sim:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(g, 54, num), 55, tics), 56, st), 57, death), 58, frames), 59, melee), 60, atk)

def cast.fin(+g: S.Sim, +c: Cast) -> Cast:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      +t = C.state(g, st, 2)
      Cast{num, Bool.pick(U32, U32.is_eq(t, 4294967295), 15, t), st, death, frames, melee, atk}

def cast.stop(+g: S.Sim, +c: Cast) -> Cast:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      Cast{num, tics, cinfo(g, num, 3), death, 0, melee, 0}

def cast.attack(+g: S.Sim, +c: Cast) -> Cast:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      +ml = cinfo(g, num, 10)
      +mi = cinfo(g, num, 11)
      +s = Bool.pick(U32, U32.is_ne(melee, 0), ml, mi)
      +nm = (melee .^. 1 : U32)
      Cast{num, tics, Bool.pick(U32, U32.is_eq(s, 0), Bool.pick(U32, U32.is_ne(nm, 0), ml, mi), s), death, frames, nm, 1}

def cast.after?(+g: S.Sim, +c: Cast) -> Cast:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      +c1 = Bool.pick(Cast, U32.is_eq(frames, 12), cast.attack(g, Cast{num, tics, st, death, frames, melee, atk}), Cast{num, tics, st, death, frames, melee, atk})
      cast.fin(g, cast.end(g, c1))

def cast.end(+g: S.Sim, +c: Cast) -> Cast:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      +stop = Bool.and(U32.is_ne(atk, 0), Bool.or(U32.is_eq(frames, 24), U32.is_eq(st, cinfo(g, num, 3))))
      Bool.pick(Cast, stop, cast.stop(g, Cast{num, tics, st, death, frames, melee, atk}), Cast{num, tics, st, death, frames, melee, atk})

def cast.next(+g: S.Sim, +c: Cast) -> Cast:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      +ended = Bool.or(U32.is_eq(C.state(g, st, 2), 4294967295), U32.is_eq(C.state(g, st, 4), 0))
      +n1 = Bool.pick(U32, U32.is_eq((num + 1 : U32), 17), 0, (num + 1 : U32))
      Bool.pick(Cast, ended, cast.after(g, Cast{n1, tics, cinfo(g, n1, 3), 0, 0, melee, atk}),
        Bool.pick(Cast, U32.is_eq(st, 154), cast.fin(g, cast.stop(g, Cast{num, tics, st, death, frames, melee, atk})),
          cast.after(g, Cast{num, tics, C.state(g, st, 4), death, (frames + 1 : U32), melee, atk})))

def cast.tick(+g: S.Sim, +c: Cast) -> Cast:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      +t1 = (tics - 1 : U32)
      Bool.pick(Cast, F.gt(t1, 0), Cast{num, t1, st, death, frames, melee, atk}, cast.next(g, Cast{num, t1, st, death, frames, melee, atk}))

def cast.sfx(+st: U32) -> U32:
  Bool.pick(U32, U32.is_eq(st, 154), 4, Bool.pick(U32, U32.is_eq(st, 185), 1, Bool.pick(U32, U32.is_eq(st, 218), 2, Bool.pick(U32, U32.is_eq(st, 256), 54, Bool.pick(U32, U32.is_eq(st, 336), 56, Bool.pick(U32, U32.is_eq(st, 338), 53, Bool.pick(U32, U32.is_eq(st, 340), 107, Bool.pick(U32, U32.is_eq(st, 383), 16, Bool.pick(U32, U32.is_eq(st, 380), 16, Bool.pick(U32, U32.is_eq(st, 377), 16, Bool.pick(U32, U32.is_eq(st, 417), 2, Bool.pick(U32, U32.is_eq(st, 418), 2, Bool.pick(U32, U32.is_eq(st, 419), 2, Bool.pick(U32, U32.is_eq(st, 454), 55, Bool.pick(U32, U32.is_eq(st, 486), 52, Bool.pick(U32, U32.is_eq(st, 538), 16, Bool.pick(U32, U32.is_eq(st, 567), 16, Bool.pick(U32, U32.is_eq(st, 505), 16, Bool.pick(U32, U32.is_eq(st, 590), 51, Bool.pick(U32, U32.is_eq(st, 616), 2, Bool.pick(U32, U32.is_eq(st, 617), 2, Bool.pick(U32, U32.is_eq(st, 648), 8, Bool.pick(U32, U32.is_eq(st, 685), 14, Bool.pick(U32, U32.is_eq(st, 687), 14, Bool.pick(U32, U32.is_eq(st, 689), 14, Bool.pick(U32, U32.is_eq(st, 710), 51, 0))))))))))))))))))))))))))

def cast.sound(+g: S.Sim, +c: Cast) -> U32:
  match c:
    case Cast{+num, +tics, +st, +death, +frames, +melee, +atk}:
      +ended = Bool.or(U32.is_eq(C.state(g, st, 2), 4294967295), U32.is_eq(C.state(g, st, 4), 0))
      +n1 = Bool.pick(U32, U32.is_eq((num + 1 : U32), 17), 0, (num + 1 : U32))
      Bool.pick(U32, F.gt((tics - 1 : U32), 0), 0, Bool.pick(U32, ended, cinfo(g, n1, 4), Bool.pick(U32, U32.is_eq(st, 154), 0, cast.sfx(C.state(g, st, 4)))))

def cast.start(+g: S.Sim) -> S.Sim:
  +s = cinfo(g, 0, 3)
  U.ui.set(cast.put(wipe(g), Cast{0, C.state(g, s, 2), s, 0, 0, 0, 0}), 50, 2)

def cast.death(+g: S.Sim) -> S.Sim:
  +num = U.ui(g, 54)
  +s = cinfo(g, num, 12)
  +ds = cinfo(g, num, 14)
  C.when(U32.is_eq(U.ui(g, 57), 0), g, +h => cast.put(C.when(U32.is_ne(ds, 0), h, +k => beep(k, ds)), Cast{num, C.state(h, s, 2), s, 1, 0, U.ui(h, 59), 0}))

def anybtn(n: Nat, +g: S.Sim, +i: U32) -> Bool:
  match n:
    case 0n:
      False{}
    case 1n+p:
      Bool.or(Bool.and(C.ingame(g, i), U32.is_ne(S.pi.buttons(g, i), 0)), anybtn(p, g, (i + 1 : U32)))

def finale.ticker(+g: S.Sim) -> S.Sim:
  +c = U.com(g)
  +g1 = C.when(Bool.and(c, Bool.and(U32.is_gt(U.ui(g, 51), 50), anybtn(4n, g, 0))), g,
    +h => C.br(U32.is_eq(U.ui(h, 25), 30), h, +k => cast.start(k), +k => S.sim.act.set(k, 1)))
  +g2 = U.ui.set(g1, 51, (U.ui(g1, 51) + 1 : U32))
  +stage = U.ui(g2, 50)
  +cnt = U.ui(g2, 51)
  +bun = Bool.and(Bool.and(Bool.not(c), U32.is_eq(stage, 1)), Bool.and(U32.is_eq(U.ui(g2, 26), 3), Bool.and(Bool.and(U32.is_ge(cnt, 1185), U32.is_le(cnt, 1210)), U32.is_eq(((cnt - 1180) % 5 : U32), 0))))
  +g3 = C.when(bun, g2, +h => beep(h, 1))
  C.br(U32.is_eq(stage, 2), g3, +h => cast.put(C.when(U32.is_ne(cast.sound(h, cast.get(h)), 0), h, +k => beep(k, cast.sound(k, cast.get(k)))), cast.tick(h, cast.get(h))),
    +h => C.when(Bool.and(Bool.not(c), Bool.and(U32.is_eq(stage, 0), U32.is_gt(U.ui(h, 51), (U.ui(h, 53) * 3 + 250 : U32)))), h,
      +k => wipe(U.ui.set(U.ui.set(k, 51, 0), 50, 1))))

def page(+g: S.Sim, +t: U32, +p: U32) -> S.Sim:
  U.ui.set(U.ui.set(S.sim.gs.set(g, 3), 122, t), 123, p)

def advance?(n: Nat, +g: S.Sim) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +ds = ((U.ui(g, 124) + 1) % Bool.pick(U32, U32.is_eq(U.mode(g), 2), 7, 6) : U32)
      +g1 = S.sim.act.set(U.ui.set(U.ui.set(U.ui.set(g, 125, 0), 118, 0), 124, ds), 0)
      +c = U.com(g1)
      C.br(Bool.or(U32.is_eq((ds .&. 1 : U32), 1), U32.is_eq(ds, 6)), g1, +h => S.sim.act.set(U.ui.set(U.ui.set(h, 122, 100000), 131, Bool.pick(U32, U32.is_eq(ds, 6), 4, ((ds + 1) / 2 : U32))), 4),
        +h => C.br(U32.is_eq(ds, 0), h, +k => page(k, Bool.pick(U32, c, 385, 170), 247),
          +k => C.br(U32.is_eq(ds, 2), k, +q => page(q, 200, 248),
            +q => page(q, Bool.pick(U32, c, 385, 200), Bool.pick(U32, c, 247, Bool.pick(U32, U32.is_eq(U.mode(q), 2), 248, 250))))))

def page.ticker(+g: S.Sim) -> S.Sim:
  +t = (U.ui(g, 122) - 1 : U32)
  U.ui.set(C.when(F.lt(t, 0), g, +h => U.ui.set(h, 125, 1)), 122, t)

def level.ticker(+g: S.Sim) -> S.Sim:
  +paused = Bool.and(Bool.and(Bool.and(U32.is_ne(U.ui(g, 100), 0), U32.is_eq(U.ui(g, 127), 0)), U32.is_ne(S.sim.time(g), 0)), Bool.not(C.net(g)))
  Am.ticker(C.br(paused, g, +h => K.hu.ticker(K.st.ticker(S.sim.tic.set(h, (S.sim.tic(h) + 1 : U32)))), +h => K.ticker(h)))

def other.ticker(+g: S.Sim, +gs: U32) -> S.Sim:
  +g1 = C.br(U32.is_eq(gs, 1), g, +k => wi.ticker(k), +k => C.br(U32.is_eq(gs, 2), k, +q => finale.ticker(q), +q => page.ticker(q)))
  S.sim.tic.set(g1, (S.sim.tic(g1) + 1 : U32))

def sx(+b: U32) -> U32:
  Bool.pick(U32, U32.is_ge(b, 128), (b - 256 : U32), b)

def demo.byte(+g: S.Sim, +i: U32) -> U32:
  T.get(U32, S.sim.demo(g), i, 128)

def demo.end(+g: S.Sim) -> S.Sim:
  +g1 = S.sim.ingame.set(S.sim.net.set(U.ui.set(U.ui.set(g, 127, 0), 169, 0), 0), 1)
  C.br(U32.is_ne(U.ui(g1, 129), 0), g1, +h => U.ui.set(h, 119, 1), +h => U.ui.set(h, 125, 1))

def demo.set(+g: S.Sim, +i: U32, +pos: U32) -> S.Sim:
  +g1 = S.pi.side.set(S.pi.fwd.set(g, i, sx(demo.byte(g, pos))), i, sx(demo.byte(g, (pos + 1 : U32))))
  +g2 = S.pi.buttons.set(S.pi.turn.set(g1, i, (demo.byte(g1, (pos + 2 : U32)) << 8n : U32)), i, demo.byte(g1, (pos + 3 : U32)))
  S.sim.dpos.set(g2, (pos + 4 : U32))

def demo.read(+g: S.Sim, +i: U32) -> S.Sim:
  +pos = S.sim.dpos(g)
  C.br(U32.is_eq(demo.byte(g, pos), 128), g, +h => demo.end(h), +h => demo.set(h, i, pos))

def demo.cmds(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +on = Bool.and(U32.is_ne(U.ui(g, 127), 0), C.ingame(g, i))
      demo.cmds(p, C.when(on, g, +h => demo.read(h, i)), (i + 1 : U32))

def demo.start(+g: S.Sim, +bs: T.Vec<U32>) -> S.Sim:
  +b = S.sim.dpos.set(S.sim.demo.set(g, bs), 13)
  +mask = (C.b2u(U32.is_ne(T.get(U32, bs, 9, 0), 0)) .|. (C.b2u(U32.is_ne(T.get(U32, bs, 10, 0), 0)) << 1n) .|. (C.b2u(U32.is_ne(T.get(U32, bs, 11, 0), 0)) << 2n) .|. (C.b2u(U32.is_ne(T.get(U32, bs, 12, 0), 0)) << 3n) : U32)
  +g1 = U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(b, 120, T.get(U32, bs, 2, 1)), 121, T.get(U32, bs, 1, 2)), 128, T.get(U32, bs, 3, 1)), 148, mask), 149, C.b2u(U32.is_ne((mask .&. 14 : U32), 0))), 127, 1), 169, (T.get(U32, bs, 8, 0) .&. 3 : U32))
  S.sim.act.set(g1, 2)

def demo.loaded(+g: S.Sim, +bs: List<&2, U32>) -> S.Sim:
  +g1 = S.sim.act.set(g, 0)
  C.br(U32.is_lt(U32.from_nat(List.length(&2, U32, bs)), 14), g1, +h => U.ui.set(h, 125, 1), +h => demo.start(U.ui.set(h, 129, 0), T.from_list(U32, bs)))

def reborns(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      +due = Bool.and(Bool.and(C.net(g), U32.is_eq(S.sim.gs(g), 0)), Bool.and(C.ingame(g, i), U32.is_eq(S.pi.state(g, i), 2)))
      reborns(p, C.when(due, g, +h => K.doreborn(h, i)), (i + 1 : U32))

def tick?(+g: S.Sim) -> S.Sim:
  +g0 = reborns(4n, Mn.ticker(C.when(U32.is_ne(U.ui(g, 125), 0), g, +h => advance(8n, h))), 0)
  +g1a = C.when(Bool.and(U32.is_eq(S.sim.gs(g0), 0), U32.is_ne(S.sim.exit(g0), 0)), g0, +h => completed(h))
  +g1 = demo.cmds(4n, g1a, 0)
  +gs = S.sim.gs(g1)
  C.when(Bool.not(quit(g1)), g1, +q => C.br(U32.is_eq(gs, 0), q, +h => level.ticker(h), +h => other.ticker(h, gs)))

def eaten(+g: S.Sim) -> Bool:
  U32.is_ne(U.ui(g, 199), 0)

def game.respond(+g: S.Sim, +key: U32, +ch: U32, +down: Bool) -> S.Sim:
  +gs = S.sim.gs(g)
  +attract = Bool.and(Bool.and(down, U32.is_eq(S.sim.act(g), 0)), Bool.or(U32.is_eq(gs, 3), Bool.and(U32.is_ne(U.ui(g, 127), 0), U32.is_eq(U.ui(g, 129), 0))))
  C.br(attract, g, +q => U.ui.set(Mn.startcp(q), 199, 1),
    +q => C.br(U32.is_eq(gs, 0), q, +h => Am.respond(h, key, ch, down),
      +h => C.when(Bool.and(down, Bool.and(U32.is_eq(gs, 2), U32.is_eq(U.ui(h, 50), 2))), h, +k => U.ui.set(cast.death(k), 199, 1))))

def respond(+g: S.Sim, +key: U32, +down: Bool) -> S.Sim:
  +ch = Bool.pick(U32, U32.is_lt(key, 128), key, 0)
  +g0 = C.br(down, U.ui.set(g, 199, 0), +h => Mn.respond(h, key), +h => h)
  C.when(Bool.not(eaten(g0)), g0, +h => game.respond(h, key, ch, down))

def close(+g: S.Sim) -> S.Sim:
  Mn.close(g)

def quit(+g: S.Sim) -> Bool:
  U32.is_ne(U.ui(g, 119), 0)

def digit(+d: U32) -> String:
  T.get(String, T.from_list(String, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]), d, "0")

def demo.lump(+g: S.Sim) -> String:
  String.append("DEMO", digit(U.ui(g, 131)))

def mapname(+c: Bool, +ep: U32, +map: U32) -> String:
  Bool.pick(String, c, String.append("MAP", String.append(digit((map / 10 : U32)), digit((map % 10 : U32)))),
    String.append("E", String.append(digit(ep), String.append("M", digit(map)))))

def nextname(+g: S.Sim) -> String:
  mapname(U.com(g), U.ui(g, 26), (U.ui(g, 14) + 1 : U32))

def here(+g: S.Sim) -> String:
  mapname(U.com(g), S.mp.episode(g), S.mp.map(g))

def pending(+g: S.Sim) -> U32:
  +a = S.sim.act(g)
  Bool.pick(U32, U32.is_eq(a, 1), 1, Bool.pick(U32, U32.is_eq(a, 2), 3, Bool.pick(U32, U32.is_ge(a, 4), a,
    Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(S.sim.gs(g), 0), U32.is_eq(S.p.state(g), 2)), Bool.not(C.net(g))), 2, 0))))

def target(+g: S.Sim) -> String:
  +p = pending(g)
  Bool.pick(String, U32.is_eq(p, 1), nextname(g), Bool.pick(String, U32.is_eq(p, 3), mapname(U.com(g), U.ui(g, 120), U.ui(g, 128)), here(g)))

def player(+g: S.Sim) -> T.Vec<U32>:
  Bool.pick(T.Vec<U32>, U32.is_eq(pending(g), 3), Su.newplayer(), S.sim.pl(g))

def carry(+g: S.Sim) -> T.Vec<U32>:
  +ng = U32.is_eq(pending(g), 3)
  T.from_list(U32, [Bool.pick(U32, ng, 0, S.sim.rnd(g)), Bool.pick(U32, ng, U.ui(g, 121), S.mp.skill(g)), Bool.pick(U32, ng, 0, S.sim.mrnd(g)), 1,
    Bool.pick(U32, ng, 0, U.ui(g, 99)), S.sim.stcount(g), S.sim.stprio(g), S.sim.stlad(g), S.sim.stpainh(g), S.sim.stpainc(g), S.sim.tic(g), Bool.pick(U32, ng, U.ui(g, 148), S.sim.ingame(g)), Bool.pick(U32, ng, U.ui(g, 149), S.sim.net(g))])

def adopt.go(n: Nat, +old: S.Sim, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      adopt.go(p, old, U.ui.set(g, i, U.ui(old, i)), (i + 1 : U32))

def adopt(+old: S.Sim, +g: S.Sim) -> S.Sim:
  +ng = U32.is_eq(pending(old), 3)
  +g1 = U.ui.set(U.ui.set(adopt.go(156n, old, g, 100), 116, 0), 117, 0)
  +g2 = S.sim.cp.set(S.sim.saves.set(S.sim.dpos.set(S.sim.demo.set(g1, S.sim.demo(old)), S.sim.dpos(old)), S.sim.saves(old)), U.ui(old, 169))
  C.when(ng, g2, +h => U.ui.set(U.ui.set(h, 118, Bool.pick(U32, U32.is_eq(U.ui(h, 127), 0), 1, 0)), 140, 0))

def boot.title(+g: S.Sim) -> S.Sim:
  Mn.title(page(g, 0, 247))

def boot.warp(+g: S.Sim) -> S.Sim:
  U.ui.set(g, 118, 1)

def blank(rom: Array<U32>) -> V.Frame:
  V.Frame{P.blank(), rom, V.fresh(), []}

def ph(fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame & U32:
  U.hword(fr, g, i, 2)

def center(fr: V.Frame, +g: S.Sim, +y: U32, +i: U32) -> V.Frame:
  U.fr.let(U.pw(fr, g, i), f => +w => U.patch(f, g, ((320 - w) / 2 : U32), y, i))

def wi.bg?(fr: V.Frame, +g: S.Sim) -> V.Frame:
  wi.anims(U32.to_nat(nanims(U.ui(g, 12))), U.patch(fr, g, 0, 0, 172), g, 0)

def wi.anims(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +ctr = U.ui(g, (30 + 2 * i : U32))
      f1 = U.fwhen(Bool.and(animated(g), U32.is_ne(ctr, 4294967295)), fr, f => U.patch(f, g, an(g, i, 3), an(g, i, 4), (205 + i * 3 + ctr : U32)))
      wi.anims(p, f1, g, (i + 1 : U32))

def wi.lf(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +ln = (173 + U.ui(g, 13) : U32)
  U.fwhen(Bool.or(Bool.not(U.com(g)), U32.is_lt(U.ui(g, 13), 32)), fr, f =>
    U.fr.let(ph(center(f, g, 2, ln), g, ln), f1 => +h => center(f1, g, (2 + (5 * h) / 4 : U32), 160)))

def wi.el(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +ln = (173 + U.ui(g, 14) : U32)
  U.fr.let(ph(center(fr, g, 2, 161), g, ln), f1 => +h => center(f1, g, (2 + (5 * h) / 4 : U32), ln))

def wi.digits(n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +v: U32, +fw: U32) -> V.Frame & U32:
  match n:
    case 0n:
      (fr, x)
    case 1n+p:
      +x1 = (x - fw : U32)
      wi.digits(p, U.patch(fr, g, x1, y, (148 + v % 10 : U32)), g, x1, y, (v / 10 : U32), fw)

def ndigits(n: Nat, +v: U32, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      Bool.pick(U32, U32.is_eq(v, 0), acc, ndigits(p, (v / 10 : U32), (acc + 1 : U32)))

def wi.num.go(r: V.Frame & U32, +g: S.Sim, +y: U32, +neg: Bool) -> V.Frame & U32:
  (fr, +x) = r
  U.fsel2(neg, fr, f => (U.patch(f, g, (x - 8 : U32), y, 158), (x - 8 : U32)), f => (f, x))

def wi.num?(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +n: U32, +d: U32) -> V.Frame & U32:
  +neg = F.lt(n, 0)
  +v = Bool.pick(U32, neg, (0 - n : U32), n)
  +dd = Bool.pick(U32, U32.is_ne(d, 4294967295), d, Bool.pick(U32, U32.is_eq(n, 0), 1, ndigits(12n, v, 0)))
  wi.num.ret(U32.is_eq(v, 1994), fr, g, x, y, v, dd, neg)

def wi.num.ret(stop: Bool, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +v: U32, +dd: U32, +neg: Bool) -> V.Frame & U32:
  match stop:
    case True{}:
      (fr, 0)
    case False{}:
      U.fr.let2(U.pw(fr, g, 148), f => +fw => wi.num.go(wi.digits(U32.to_nat(dd), f, g, x, y, v, fw), g, y, neg))

def drop(r: V.Frame & U32) -> V.Frame:
  (fr, x) = r
  fr

def wi.pct(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +p: U32) -> V.Frame:
  U.fwhen(Bool.not(F.lt(p, 0)), fr, f => drop(wi.num(U.patch(f, g, x, y, 159), g, x, y, p, 4294967295)))

def wi.time.go?(n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +t: U32, +div: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      U.fr.let(wi.num(fr, g, x, y, ((t / div) % 60 : U32), 2), f => +x1 =>
        U.fr.let(U.pw(f, g, 165), f2 => +cw =>
          wi.time.more(p, f2, g, (x1 - cw : U32), y, t, (div * 60 : U32))))

def wi.time.more?(n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +t: U32, +div: U32) -> V.Frame:
  f1 = U.fwhen(Bool.or(U32.is_eq(div, 60), U32.is_ne((t / div : U32), 0)), fr, f => U.patch(f, g, x, y, 165))
  U.fwhen(U32.is_ne((t / div : U32), 0), f1, f => wi.time.go(n, f, g, x, y, t, div))

def wi.time?(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +t: U32) -> V.Frame:
  U.fwhen(Bool.not(F.lt(t, 0)), fr, f =>
    U.fsel(U32.is_le(t, 3599), f, q => wi.time.go(4n, q, g, x, y, t, 1), q => q))

def wi.sucks(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +t: U32) -> V.Frame:
  U.fwhen(Bool.and(Bool.not(F.lt(t, 0)), U32.is_gt(t, 3599)), fr, f => U.fr.let(U.pw(f, g, 167), f1 => +w => U.patch(f1, g, (x - w : U32), y, 167)))

def wi.drawtime?(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +t: U32) -> V.Frame:
  wi.sucks(wi.time(fr, g, x, y, t), g, x, y, t)

def wi.drawstats?(fr: V.Frame, +g: S.Sim) -> V.Frame:
  U.fr.let(ph(wi.lf(wi.bg(fr, g), g), g, 148), f => +h =>
    wi.drawstats.go(f, g, ((3 * h) / 2 : U32)))

def wi.drawstats.go(fr: V.Frame, +g: S.Sim, +lh: U32) -> V.Frame:
  f1 = wi.pct(U.patch(fr, g, 50, 50, 162), g, 270, 50, U.ui(g, 5))
  f2 = wi.pct(U.patch(f1, g, 50, (50 + lh : U32), 163), g, 270, (50 + lh : U32), U.ui(g, 6))
  f3 = wi.pct(U.patch(f2, g, 50, (50 + 2 * lh : U32), 164), g, 270, (50 + 2 * lh : U32), U.ui(g, 7))
  f4 = wi.drawtime(U.patch(f3, g, 16, 168, 166), g, 144, 168, U.ui(g, 8))
  U.fwhen(U32.is_lt(U.ui(g, 12), 3), f4, f => wi.drawtime(U.patch(f, g, 176, 168, 168), g, 304, 168, U.ui(g, 9)))

def wi.netrow(fr: V.Frame, +g: S.Sim, +i: U32, +x: U32, +y: U32, +pw: U32) -> V.Frame:
  U.fr.let(U.pw(fr, g, (310 + i : U32)), f0 => +w =>
    f1 = U.patch(f0, g, (x - w : U32), y, (310 + i : U32))
    f2 = U.fwhen(U32.is_eq(i, 0), f1, f => U.patch(f, g, (x - w : U32), y, 44))
    f3 = wi.pct(f2, g, (x + 64 - pw : U32), (y + 10 : U32), U.ui(g, (61 + i : U32)))
    f4 = wi.pct(f3, g, (x + 128 - pw : U32), (y + 10 : U32), U.ui(g, (65 + i : U32)))
    wi.pct(f4, g, (x + 192 - pw : U32), (y + 10 : U32), U.ui(g, (69 + i : U32))))

def wi.netrows(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32, +x: U32, +y: U32, +pw: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +ig = C.ingame(g, i)
      wi.netrows(p, U.fwhen(ig, fr, f => wi.netrow(f, g, i, x, y, pw)), g, (i + 1 : U32), x, Bool.pick(U32, ig, (y + 33 : U32), y), pw)

def wi.netright(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +i: U32) -> V.Frame:
  U.fr.let(U.pw(fr, g, i), f => +w => U.patch(f, g, (x - w : U32), y, i))

def wi.drawnet?(fr: V.Frame, +g: S.Sim) -> V.Frame:
  f0 = wi.lf(wi.bg(fr, g), g)
  U.fr.let(U.pw(f0, g, 44), f1 => +sw =>
    +x = (32 + sw / 2 + 32 : U32)
    f2 = wi.netright(wi.netright(wi.netright(f1, g, (x + 64 : U32), 50, 162), g, (x + 128 : U32), 50, 163), g, (x + 192 : U32), 50, 314)
    U.fr.let(ph(f2, g, 162), f3 => +kh =>
      U.fr.let(U.pw(f3, g, 159), f4 => +pw =>
        wi.netrows(4n, f4, g, 0, x, (50 + kh : U32), pw))))

def fits?(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +i: U32) -> V.Frame & Bool:
  U.fr.lt(V.Frame & Bool, U.pw(fr, g, i), f1 => +w =>
    U.fr.lt(V.Frame & Bool, ph(f1, g, i), f2 => +h =>
      U.fr.lt(V.Frame & Bool, U.hword(f2, g, i, 4), f3 => +lo =>
        U.fr.lt(V.Frame & Bool, U.hword(f3, g, i, 6), f4 => +to =>
          fits.go(f4, (x - V.s16(lo) : U32), (y - V.s16(to) : U32), w, h)))))

def fits.go(fr: V.Frame, +l: U32, +t: U32, +w: U32, +h: U32) -> V.Frame & Bool:
  (fr, Bool.and(Bool.and(F.ge(l, 0), F.lt((l + w : U32), 320)), Bool.and(F.ge(t, 0), F.lt((t + h : U32), 200))))

def onnode.try?(r: V.Frame & Bool, +g: S.Sim, +x: U32, +y: U32, +i: U32, +alt: U32) -> V.Frame:
  (fr, +ok) = r
  U.fsel(ok, fr, f => U.patch(f, g, x, y, i), f => onnode.alt(U32.is_ne(alt, 0), f, g, x, y, alt))

def onnode.alt?(go: Bool, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +i: U32) -> V.Frame:
  match go:
    case True{}:
      onnode.last(fits(fr, g, x, y, i), g, x, y, i)
    case False{}:
      fr

def onnode.last(r: V.Frame & Bool, +g: S.Sim, +x: U32, +y: U32, +i: U32) -> V.Frame:
  (fr, +ok) = r
  U.fwhen(ok, fr, f => U.patch(f, g, x, y, i))

def onnode?(fr: V.Frame, +g: S.Sim, +n: U32, +i: U32, +alt: U32) -> V.Frame:
  +e = U.ui(g, 12)
  +x = lnode(e, n, 0)
  +y = lnode(e, n, 1)
  onnode.try(fits(fr, g, x, y, i), g, x, y, i, alt)

def splats(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      splats(p, onnode(fr, g, i, 171, 0), g, (i + 1 : U32))

def wi.drawnext?(fr: V.Frame, +g: S.Sim, +ptr: Bool) -> V.Frame:
  f1 = wi.bg(fr, g)
  +c = U.com(g)
  U.fsel(Bool.and(Bool.not(c), U32.is_gt(U.ui(g, 12), 2)), f1, f => wi.el(f, g), f => wi.drawnext.go(f, g, ptr, c))

def wi.drawnext.go(fr: V.Frame, +g: S.Sim, +ptr: Bool, +c: Bool) -> V.Frame:
  +last = Bool.pick(U32, U32.is_eq(U.ui(g, 13), 8), (U.ui(g, 14) - 1 : U32), U.ui(g, 13))
  f1 = U.fwhen(Bool.not(c), fr, f =>
    U.fwhen(ptr, U.fwhen(U32.is_ne(U.ui(g, 15), 0), splats(U32.to_nat((last + 1 : U32)), f, g, 0), q => onnode(q, g, 8, 171, 0)), q => onnode(q, g, U.ui(g, 14), 169, 170)))
  U.fwhen(Bool.or(Bool.not(c), U32.is_ne(U.ui(g, 14), 30)), f1, f => wi.el(f, g))

def wi.draw(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +st = U.ui(g, 3)
  U.fsel(U32.is_eq(st, 0), fr, f => U.fsel(C.net(g), f, q => wi.drawnet(q, g), q => wi.drawstats(q, g)),
    f => wi.drawnext(f, g, Bool.or(U32.is_eq(st, 2), U32.is_ne(U.ui(g, 11), 0))))

def flat.row(n: Nat, fr: V.Frame, +a: U32, +x: U32, +y: U32) -> V.Frame:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, (a + ((y .&. 63) << 6n) + (x .&. 63) : U32)), r1 => +c =>
        flat.row(p, V.Frame{M.wr(fb, P.at(x, y), c), r1, ram, sd}, a, (x + 1 : U32), y))
    case _ f:
      f

def flat.fill(n: Nat, fr: V.Frame, +a: U32, +y: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      flat.fill(p, flat.row(320n, fr, a, 0, y), a, (y + 1 : U32))

def f.text(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +cnt = (U.ui(g, 51) - 10 : U32)
  +n = Bool.pick(U32, F.lt(cnt, 0), 0, (cnt / 3 : U32))
  U.write(text(U.ui(g, 52)), U32.to_nat(n), flat.fill(200n, fr, U.addr(g, 235), 0), g, 10, 10, 10)

def bunny.cols(n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +sc: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +c = (x + sc : U32)
      bunny.cols(p, U.fsel(U32.is_lt(c, 320), fr, f => U.patch.col(f, x, U.addr(g, 238), c), f => U.patch.col(f, x, U.addr(g, 237), (c - 320 : U32))), g, (x + 1 : U32), sc)

def bunny(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +cnt = U.ui(g, 51)
  +s0 = (320 - sdiv2((cnt - 230 : U32)) : U32)
  +s1 = Bool.pick(U32, F.gt(s0, 320), 320, Bool.pick(U32, F.lt(s0, 0), 0, s0))
  f1 = bunny.cols(320n, fr, g, 0, s1)
  +st = Bool.pick(U32, U32.is_lt(cnt, 1180), 0, U32.min(((cnt - 1180) / 5 : U32), 6))
  U.fwhen(U32.is_ge(cnt, 1130), f1, f => U.patch(f, g, 108, 68, (239 + st : U32)))

def f.art(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +ep = U.ui(g, 26)
  U.fsel(U32.is_eq(ep, 3), fr, f => bunny(f, g), f => U.patch(f, g, 0, 0, 236))

def f.cast.sprite(fr: V.Frame, +g: S.Sim, +st: U32) -> V.Frame:
  +sf = R.sframe(S.sim.w(g), (C.state(g, st, 0) * 32 + (C.state(g, st, 1) .&. 31) : U32))
  +l = V.sf.lump(sf, 0)
  U.fsel(V.sf.flip(sf, 0), fr, f => U.patch.flip(f, 160, 170, l), f => U.patch.at(f, 160, 170, l))

def f.cast?(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +name = text((78 + U.ui(g, 54) : U32))
  f1 = U.patch(fr, g, 0, 0, 246)
  U.fr.let(U.strwidth(name, f1, g, 0), f => +w =>
    f.cast.sprite(U.write(name, 64n, f, g, (160 - w / 2 : U32), (160 - w / 2 : U32), 180), g, U.ui(g, 56)))

def f.draw?(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +st = U.ui(g, 50)
  U.fsel(U32.is_eq(st, 0), fr, f => f.text(f, g), f => U.fsel(U32.is_eq(st, 1), f, q => f.art(q, g), q => f.cast(q, g)))

def screen(fr: V.Frame, +g: S.Sim) -> V.Frame:
  U.fsel(U32.is_eq(S.sim.gs(g), 1), fr, f => wi.draw(f, g), f => f.draw(f, g))

def title.id(+g: S.Sim) -> U32:
  Bool.pick(U32, U.com(g), (45 + S.mp.map(g) : U32), (10 + (S.mp.episode(g) - 1) * 9 + S.mp.map(g) - 1 : U32))

def am.title(fr: V.Frame, +g: S.Sim) -> V.Frame:
  U.fr.let(U.hword(fr, g, 85, 2), f => +h => U.text(text(title.id(g)), f, g, 0, (167 - h : U32)))

def other(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +gs = S.sim.gs(g)
  U.fsel(U32.is_eq(gs, 0), fr, f => am.title(U.draw(Am.draw(f, g), g), g),
    f => U.fsel(U32.is_eq(gs, 3), f, q => U.patch(q, g, 0, 0, U.ui(g, 123)), q => screen(q, g)))

def see(+g: S.Sim, +si: U32) -> S.Sim:
  +l = T.get(U32, S.mp.segline(g), si, 4294967295)
  C.when(U32.is_ne(l, 4294967295), g, +h => S.sim.seen.set(h, T.set(U32, S.sim.seen(h), l, 1)))

def mapped(n: Nat, fr: V.Frame, +g: S.Sim, +d: U32) -> V.Frame & S.Sim:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame & S.Sim, M.rd(ram, M.ds(d, 11)), r1 => +si =>
        mapped(p, V.Frame{fb, rom, r1, sd}, see(g, si), (d + 1 : U32)))
    case _ f:
      (f, g)

def mapped.start(fr: V.Frame, +g: S.Sim) -> V.Frame & S.Sim:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame & S.Sim, M.rd(ram, M.ndrawsegs()), r1 => +n => mapped(U32.to_nat(n), V.Frame{fb, rom, r1, sd}, g, 0))

def view.out(r: V.Frame & S.Sim) -> S.Sim & (Array<U32> & Array<U32>):
  (fr, +g) = r
  (g, D.out.at(Mn.draw(U.draw(fr, g), g), U.pal(g)))

def render.go(view: Bool, +g: S.Sim, rom: Array<U32>) -> S.Sim & (Array<U32> & Array<U32>):
  match view:
    case True{}:
      view.out(mapped.start(U.scene(g, rom), g))
    case False{}:
      (g, D.out.at(Mn.draw(other(blank(rom), g), g), Bool.pick(U32, U32.is_eq(S.sim.gs(g), 0), U.pal(g), U.palbase(g))))

def render(+g: S.Sim, rom: Array<U32>) -> S.Sim & (Array<U32> & Array<U32>):
  render.go(Bool.and(U32.is_eq(S.sim.gs(g), 0), U32.is_eq(U.ui(g, 140), 0)), g, rom)

def image.out(r: S.Sim & (Array<U32> & Array<U32>)) -> Array<U32> & Array<U32>:
  (g, p) = r
  p

def image(+g: S.Sim, rom: Array<U32>) -> Array<U32> & Array<U32>:
  image.out(render(g, rom))
