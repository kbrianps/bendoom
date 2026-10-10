import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./geo.bend as G

def ret(+g: S.Sim, +b: Bool) -> S.Sim:
  S.sim.ret.set(g, C.b2u(b))

def me.sound(+g: S.Sim, +sfx: U32) -> S.Sim:
  C.when(U32.is_eq(S.sim.cp(g), C.me(g)), g, +h => S.sim.snd.set(h, sfx <> S.sim.snd(h)))

def got(+g: S.Sim) -> Bool:
  U32.is_ne(S.sim.ret(g), 0)

def ammo(+g: S.Sim, +k: U32) -> U32:
  S.pget(g, (42 + k : U32))

def ammo.set(+g: S.Sim, +k: U32, +v: U32) -> S.Sim:
  S.pput(g, (42 + k : U32), v)

def maxammo(+g: S.Sim, +k: U32) -> U32:
  S.pget(g, (46 + k : U32))

def maxammo.set(+g: S.Sim, +k: U32, +v: U32) -> S.Sim:
  S.pput(g, (46 + k : U32), v)

def own(+g: S.Sim, +w: U32) -> U32:
  S.pget(g, (33 + w : U32))

def own.set(+g: S.Sim, +w: U32, +v: U32) -> S.Sim:
  S.pput(g, (33 + w : U32), v)

def pw(+g: S.Sim, +k: U32) -> U32:
  S.pget(g, (24 + k : U32))

def pw.set(+g: S.Sim, +k: U32, +v: U32) -> S.Sim:
  S.pput(g, (24 + k : U32), v)

def clipammo(+k: U32) -> U32:
  Bool.pick(U32, U32.is_eq(k, 0), 10, Bool.pick(U32, U32.is_eq(k, 1), 4, Bool.pick(U32, U32.is_eq(k, 2), 20, 1)))

def wammo(+w: U32) -> U32:
  Bool.pick(U32, Bool.or(U32.is_eq(w, 1), U32.is_eq(w, 3)), 0,
    Bool.pick(U32, Bool.or(U32.is_eq(w, 2), U32.is_eq(w, 8)), 1,
      Bool.pick(U32, Bool.or(U32.is_eq(w, 5), U32.is_eq(w, 6)), 2, Bool.pick(U32, U32.is_eq(w, 4), 3, 5))))

def pend(+g: S.Sim, +c: Bool, +w: U32) -> S.Sim:
  C.when(c, g, +h => S.p.pending.set(h, w))

def ammo.switch(+g: S.Sim, +k: U32) -> S.Sim:
  +rw = S.p.ready(g)
  +low = Bool.or(U32.is_eq(rw, 0), U32.is_eq(rw, 1))
  C.br(U32.is_eq(k, 0), g, +h => pend(h, U32.is_eq(rw, 0), Bool.pick(U32, U32.is_ne(own(h, 3), 0), 3, 1)),
    +h => C.br(U32.is_eq(k, 1), h, +q => pend(q, Bool.and(low, U32.is_ne(own(q, 2), 0)), 2),
      +q => C.br(U32.is_eq(k, 2), q, +z => pend(z, Bool.and(low, U32.is_ne(own(z, 5), 0)), 5),
        +z => pend(z, Bool.and(U32.is_eq(rw, 0), U32.is_ne(own(z, 4), 0)), 4))))

def giveammo.go(+g: S.Sim, +k: U32, +num: U32) -> S.Sim:
  +n0 = Bool.pick(U32, U32.is_ne(num, 0), (num * clipammo(k) : U32), (clipammo(k) / 2 : U32))
  +sk = S.mp.skill(g)
  +n = Bool.pick(U32, Bool.or(U32.is_eq(sk, 0), U32.is_eq(sk, 4)), (n0 << 1n : U32), n0)
  +old = ammo(g, k)
  +mx = maxammo(g, k)
  +v = (old + n : U32)
  +g1 = ammo.set(g, k, Bool.pick(U32, F.gt(v, mx), mx, v))
  ret(C.when(U32.is_eq(old, 0), g1, +h => ammo.switch(h, k)), True{})

def giveammo(+g: S.Sim, +k: U32, +num: U32) -> S.Sim:
  C.br(Bool.or(U32.is_eq(k, 5), U32.is_eq(ammo(g, k), maxammo(g, k))), g, +h => ret(h, False{}), +h => giveammo.go(h, k, num))

def giveweapon.net(+g: S.Sim, +w: U32) -> S.Sim:
  +a = wammo(w)
  +g1 = own.set(S.p.bonuscount.set(g, (S.p.bonuscount(g) + 6 : U32)), w, 1)
  +g2 = C.when(U32.is_ne(a, 5), g1, +h => giveammo(h, a, 2))
  ret(me.sound(S.p.pending.set(g2, w), 33), False{})

def giveweapon.sp(+g: S.Sim, +w: U32, +dropped: Bool) -> S.Sim:
  +a = wammo(w)
  +g1 = C.br(U32.is_ne(a, 5), g, +h => giveammo(h, a, Bool.pick(U32, dropped, 1, 2)), +h => ret(h, False{}))
  +ga = got(g1)
  +has = U32.is_ne(own(g1, w), 0)
  +g2 = C.when(Bool.not(has), g1, +h => S.p.pending.set(own.set(h, w, 1), w))
  ret(g2, Bool.or(Bool.not(has), ga))

def giveweapon(+g: S.Sim, +w: U32, +dropped: Bool) -> S.Sim:
  C.br(Bool.and(C.net(g), Bool.not(dropped)), g, +h => C.br(U32.is_ne(own(h, w), 0), h, +k => ret(k, False{}), +k => giveweapon.net(k, w)), +h => giveweapon.sp(h, w, dropped))

def health.set(+g: S.Sim, +v: U32) -> S.Sim:
  S.m.health.set(S.p.health.set(g, v), S.p.mo(g), v)

def givebody(+g: S.Sim, +num: U32) -> S.Sim:
  +h0 = S.p.health(g)
  +v = (h0 + num : U32)
  C.br(F.ge(h0, 100), g, +h => ret(h, False{}), +h => ret(health.set(h, Bool.pick(U32, F.gt(v, 100), 100, v)), True{}))

def givearmor(+g: S.Sim, +t: U32) -> S.Sim:
  +hits = (t * 100 : U32)
  C.br(F.ge(S.p.armor(g), hits), g, +h => ret(h, False{}), +h => ret(S.p.armor.set(S.p.armortype.set(h, t), hits), True{}))

def givecard(+g: S.Sim, +b: U32) -> S.Sim:
  +c = S.p.cards(g)
  ret(C.when(Bool.not(C.has(c, b)), g, +h => S.p.cards.set(S.p.bonuscount.set(h, 6), (c .|. b : U32))), True{})

def givepower(+g: S.Sim, +k: U32) -> S.Sim:
  C.br(U32.is_eq(k, 0), g, +h => ret(pw.set(h, 0, 1050), True{}),
    +h => C.br(U32.is_eq(k, 2), h, +q => ret(S.m.flags.set(pw.set(q, 2, 2100), S.p.mo(q), (S.m.flags(q, S.p.mo(q)) .|. 262144 : U32)), True{}),
      +q => C.br(U32.is_eq(k, 5), q, +z => ret(pw.set(z, 5, 4200), True{}),
        +z => C.br(U32.is_eq(k, 3), z, +y => ret(pw.set(y, 3, 2100), True{}),
          +y => C.br(U32.is_eq(k, 1), y, +x => ret(pw.set(givebody(x, 100), 1, 1), True{}),
            +x => C.br(U32.is_ne(pw(x, k), 0), x, +v => ret(v, False{}), +v => ret(pw.set(v, k, 1), True{})))))))

def bonus(+g: S.Sim, +cap: U32, +v: U32) -> U32:
  Bool.pick(U32, F.gt(v, cap), cap, v)

def berserk(+g: S.Sim) -> S.Sim:
  +g1 = givepower(g, 1)
  C.when(Bool.and(got(g1), U32.is_ne(S.p.ready(g1), 0)), g1, +h => S.p.pending.set(h, 0))

def backpack(+g: S.Sim) -> S.Sim:
  +g1 = C.when(U32.is_eq(S.p.backpack(g), 0), g, +h => S.p.backpack.set(maxammo.set(maxammo.set(maxammo.set(maxammo.set(h,
    0, (maxammo(h, 0) * 2 : U32)), 1, (maxammo(h, 1) * 2 : U32)), 2, (maxammo(h, 2) * 2 : U32)), 3, (maxammo(h, 3) * 2 : U32)), 1))
  ret(giveammo(giveammo(giveammo(giveammo(g1, 0, 1), 1, 1), 2, 1), 3, 1), True{})

def megasphere(+g: S.Sim) -> S.Sim:
  C.br(S.mp.commercial(g), g, +h => ret(givearmor(health.set(h, 200), 2), True{}), +h => ret(h, False{}))

def pickup(+g: S.Sim, +sp: U32, +spr: U32) -> S.Sim:
  +dropped = C.has(S.m.flags(g, sp), 131072)
  C.br(U32.is_eq(spr, 55), g, +h => givearmor(h, 1),
  +h => C.br(U32.is_eq(spr, 56), h, +h => givearmor(h, 2),
  +h => C.br(U32.is_eq(spr, 60), h, +h => ret(health.set(h, bonus(h, 200, (S.p.health(h) + 1 : U32))), True{}),
  +h => C.br(U32.is_eq(spr, 61), h, +h => ret(S.p.armortype.set(S.p.armor.set(h, bonus(h, 200, (S.p.armor(h) + 1 : U32))), Bool.pick(U32, U32.is_eq(S.p.armortype(h), 0), 1, S.p.armortype(h))), True{}),
  +h => C.br(U32.is_eq(spr, 70), h, +h => ret(health.set(h, bonus(h, 200, (S.p.health(h) + 100 : U32))), True{}),
  +h => C.br(U32.is_eq(spr, 74), h, +h => megasphere(h),
  +h => C.br(U32.is_eq(spr, 62), h, +h => givecard(h, 1),
  +h => C.br(U32.is_eq(spr, 63), h, +h => givecard(h, 4),
  +h => C.br(U32.is_eq(spr, 64), h, +h => givecard(h, 2),
  +h => C.br(U32.is_eq(spr, 65), h, +h => givecard(h, 8),
  +h => C.br(U32.is_eq(spr, 66), h, +h => givecard(h, 32),
  +h => C.br(U32.is_eq(spr, 67), h, +h => givecard(h, 16),
  +h => C.br(U32.is_eq(spr, 68), h, +h => givebody(h, 10),
  +h => C.br(U32.is_eq(spr, 69), h, +h => givebody(h, 25),
  +h => C.br(U32.is_eq(spr, 71), h, +h => givepower(h, 0),
  +h => C.br(U32.is_eq(spr, 72), h, +h => berserk(h),
  +h => C.br(U32.is_eq(spr, 73), h, +h => givepower(h, 2),
  +h => C.br(U32.is_eq(spr, 75), h, +h => givepower(h, 3),
  +h => C.br(U32.is_eq(spr, 76), h, +h => givepower(h, 4),
  +h => C.br(U32.is_eq(spr, 77), h, +h => givepower(h, 5),
  +h => C.br(U32.is_eq(spr, 78), h, +h => giveammo(h, 0, Bool.pick(U32, dropped, 0, 1)),
  +h => C.br(U32.is_eq(spr, 79), h, +h => giveammo(h, 0, 5),
  +h => C.br(U32.is_eq(spr, 80), h, +h => giveammo(h, 3, 1),
  +h => C.br(U32.is_eq(spr, 81), h, +h => giveammo(h, 3, 5),
  +h => C.br(U32.is_eq(spr, 82), h, +h => giveammo(h, 2, 1),
  +h => C.br(U32.is_eq(spr, 83), h, +h => giveammo(h, 2, 5),
  +h => C.br(U32.is_eq(spr, 84), h, +h => giveammo(h, 1, 1),
  +h => C.br(U32.is_eq(spr, 85), h, +h => giveammo(h, 1, 5),
  +h => C.br(U32.is_eq(spr, 86), h, +h => backpack(h),
  +h => C.br(U32.is_eq(spr, 87), h, +h => giveweapon(h, 6, False{}),
  +h => C.br(U32.is_eq(spr, 88), h, +h => giveweapon(h, 3, dropped),
  +h => C.br(U32.is_eq(spr, 89), h, +h => giveweapon(h, 7, False{}),
  +h => C.br(U32.is_eq(spr, 90), h, +h => giveweapon(h, 4, False{}),
  +h => C.br(U32.is_eq(spr, 91), h, +h => giveweapon(h, 5, False{}),
  +h => C.br(U32.is_eq(spr, 92), h, +h => giveweapon(h, 2, dropped),
  +h => C.br(U32.is_eq(spr, 93), h, +h => giveweapon(h, 8, dropped),
  +h => ret(h, False{})))))))))))))))))))))))))))))))))))))

def taken(+g: S.Sim, +sp: U32) -> S.Sim:
  +g1 = C.when(C.has(S.m.flags(g, sp), 8388608), g, +h => S.p.items.set(h, (S.p.items(h) + 1 : U32)))
  S.p.bonuscount.set(C.remove(G.unset(g1, sp), sp), (S.p.bonuscount(g1) + 6 : U32))

def msg.tab() -> T.Vec<U32>:
  T.from_list(U32, [7, 8, 0, 0, 0, 9, 10, 13, 15, 14, 16, 18, 17, 19, 21, 11, 22, 23, 24, 12, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43])

def keybit(+spr: U32) -> U32:
  T.get(U32, T.from_list(U32, [1, 4, 2, 8, 32, 16]), (spr - 62 : U32), 0)

def msg.of(+spr: U32, +had: Bool, +hp: U32) -> U32:
  +m = T.get(U32, msg.tab(), (spr - 55 : U32), 0)
  Bool.pick(U32, Bool.and(U32.is_ge(spr, 62), U32.is_le(spr, 67)), Bool.pick(U32, had, 0, m),
    Bool.pick(U32, U32.is_eq(spr, 69), Bool.pick(U32, F.lt(hp, 25), 20, 21), m))

def message(+g: S.Sim, +m: U32) -> S.Sim:
  C.when(U32.is_ne(m, 0), g, +h => S.p.message.set(h, m))

def pick.sound(+spr: U32) -> U32:
  Bool.pick(U32, Bool.and(U32.is_ge(spr, 87), U32.is_le(spr, 93)), 33,
    Bool.pick(U32, Bool.or(Bool.or(U32.is_eq(spr, 70), U32.is_eq(spr, 74)), Bool.and(U32.is_ge(spr, 71), U32.is_le(spr, 77))), 93, 32))

def touch.go(+g: S.Sim, +sp: U32) -> S.Sim:
  +spr = S.m.sprite(g, sp)
  +had = C.has(S.p.cards(g), keybit(spr))
  +g1 = pickup(g, sp, spr)
  +card = Bool.and(U32.is_ge(spr, 62), U32.is_le(spr, 67))
  C.br(Bool.and(card, C.net(g1)), g1, +h => ret(message(h, msg.of(spr, had, S.p.health(h))), False{}),
    +h => C.when(got(h), h, +k => me.sound(taken(message(k, msg.of(spr, had, S.p.health(k))), sp), pick.sound(spr))))

def touch(+g: S.Sim, +sp: U32, +t: U32) -> S.Sim:
  +delta = (S.m.z(g, sp) - S.m.z(g, t) : U32)
  +far = Bool.or(F.gt(delta, S.m.height(g, t)), F.lt(delta, 4294443008))
  C.when(Bool.and(Bool.not(far), F.gt(S.m.health(g, t), 0)), g, +h => C.asmo(h, t, +k => touch.go(k, sp)))
