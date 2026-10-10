import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./hud.bend as U
import ./render.bend as V
import ./screen.bend as P
import ./mem.bend as M

type Fl is Data:
  Fl{ok: Bool, ax: U32, ay: U32, bx: U32, by: U32}

def none() -> U32:
  4294967295

def ui(+g: S.Sim, +i: U32) -> U32:
  U.ui(g, i)

def set(+g: S.Sim, +i: U32, +v: U32) -> S.Sim:
  U.ui.set(g, i, v)

def pass(+g: S.Sim) -> S.Sim:
  set(g, 199, 0)

def sdiv(+a: U32, +b: U32) -> U32:
  +mag = Bool.pick(U32, U32.is_eq(b, 0), 0, (F.abs(a) / F.abs(b) : U32))
  Bool.pick(U32, F.is_neg((a .^. b : U32)), F.neg(mag), mag)

def smod(+a: U32, +m: U32) -> U32:
  Bool.pick(U32, F.is_neg(a), F.neg((F.neg(a) % m : U32)), (a % m : U32))

def half(+v: U32) -> U32:
  sdiv(v, 2)

def mtof(+g: S.Sim, +v: U32) -> U32:
  F.sar(F.mul(v, ui(g, 156)), 16n)

def ftom(+g: S.Sim, +v: U32) -> U32:
  F.mul((v << 16n : U32), ui(g, 157))

def px(+g: S.Sim) -> U32:
  S.m.x(g, S.p.mo(g))

def py(+g: S.Sim) -> U32:
  S.m.y(g, S.p.mo(g))

def corners(+g: S.Sim) -> S.Sim:
  set(set(g, 154, (ui(g, 150) + ui(g, 152) : U32)), 155, (ui(g, 151) + ui(g, 153) : U32))

def clampx(+g: S.Sim) -> S.Sim:
  +mx = ui(g, 150)
  +hw = half(ui(g, 152))
  +c = (mx + hw : U32)
  set(g, 150, Bool.pick(U32, F.gt(c, ui(g, 93)), (ui(g, 93) - hw : U32), Bool.pick(U32, F.lt(c, ui(g, 91)), (ui(g, 91) - hw : U32), mx)))

def clampy(+g: S.Sim) -> S.Sim:
  +my = ui(g, 151)
  +hh = half(ui(g, 153))
  +c = (my + hh : U32)
  set(g, 151, Bool.pick(U32, F.gt(c, ui(g, 94)), (ui(g, 94) - hh : U32), Bool.pick(U32, F.lt(c, ui(g, 92)), (ui(g, 92) - hh : U32), my)))

def winloc(+g: S.Sim) -> S.Sim:
  +moving = Bool.or(U32.is_ne(ui(g, 162), 0), U32.is_ne(ui(g, 163), 0))
  +g1 = C.when(moving, g, +h => set(set(h, 141, 0), 166, 2147483647))
  +g2 = set(set(g1, 150, (ui(g1, 150) + ui(g1, 162) : U32)), 151, (ui(g1, 151) + ui(g1, 163) : U32))
  corners(clampy(clampx(g2)))

def newscale(+g: S.Sim) -> S.Sim:
  +cx = (ui(g, 150) + half(ui(g, 152)) : U32)
  +cy = (ui(g, 151) + half(ui(g, 153)) : U32)
  +w = ftom(g, 320)
  +h = ftom(g, 168)
  corners(set(set(set(set(g, 152, w), 153, h), 150, (cx - half(w) : U32)), 151, (cy - half(h) : U32)))

def save(+g: S.Sim) -> S.Sim:
  set(set(set(set(g, 158, ui(g, 150)), 159, ui(g, 151)), 160, ui(g, 152)), 161, ui(g, 153))

def restore(+g: S.Sim) -> S.Sim:
  +w = ui(g, 160)
  +h = ui(g, 161)
  +fol = U32.is_ne(ui(g, 141), 0)
  +g1 = set(set(set(set(g, 152, w), 153, h), 150, Bool.pick(U32, fol, (px(g) - half(w) : U32), ui(g, 158))), 151, Bool.pick(U32, fol, (py(g) - half(h) : U32), ui(g, 159)))
  +s = F.div(20971520, w)
  corners(set(set(g1, 156, s), 157, F.div(65536, s)))

def scaled(+g: S.Sim, +s: U32) -> S.Sim:
  newscale(set(set(g, 156, s), 157, F.div(65536, s)))

def marks.clear(n: Nat, +g: S.Sim, +i: U32) -> S.Sim:
  match n:
    case 0n:
      set(g, 144, 0)
    case 1n+p:
      marks.clear(p, set(g, (170 + 2 * i : U32), none()), (i + 1 : U32))

def levelinit(+g: S.Sim, +id: U32) -> S.Sim:
  +s0 = F.div(ui(g, 95), 45875)
  +s = Bool.pick(U32, F.gt(s0, ui(g, 96)), ui(g, 95), s0)
  set(set(set(marks.clear(10n, g, 0), 156, s), 157, F.div(65536, s)), 146, id)

def start(+g: S.Sim) -> S.Sim:
  +id = (S.mp.episode(g) * 64 + S.mp.map(g) + 1 : U32)
  +g1 = C.when(U32.is_ne(ui(g, 146), id), g, +h => levelinit(h, id))
  +g2 = set(set(set(set(set(set(set(set(g1, 97, 1), 140, 1), 166, 2147483647), 147, 0), 162, 0), 163, 0), 164, 65536), 165, 65536)
  +w = ftom(g2, 320)
  +h = ftom(g2, 168)
  +g3 = winloc(set(set(set(set(g2, 152, w), 153, h), 150, (px(g2) - half(w) : U32)), 151, (py(g2) - half(h) : U32)))
  save(g3)

def stop(+g: S.Sim) -> S.Sim:
  set(set(g, 140, 0), 97, 1)

def follow(+g: S.Sim) -> S.Sim:
  +x = px(g)
  +y = py(g)
  C.when(Bool.or(U32.is_ne(ui(g, 166), x), U32.is_ne(ui(g, 167), y)), g,
    +h => corners(set(set(set(set(h, 150, (ftom(h, mtof(h, x)) - half(ui(h, 152)) : U32)), 151, (ftom(h, mtof(h, y)) - half(ui(h, 153)) : U32)), 166, x), 167, y)))

def rescale(+g: S.Sim) -> S.Sim:
  +s = F.mul(ui(g, 156), ui(g, 164))
  +g1 = set(set(g, 156, s), 157, F.div(65536, s))
  C.br(F.lt(s, ui(g1, 95)), g1, +h => scaled(h, ui(h, 95)), +h => C.br(F.gt(s, ui(h, 96)), h, +k => scaled(k, ui(k, 96)), +k => newscale(k)))

def ticker(+g: S.Sim) -> S.Sim:
  C.when(U32.is_ne(ui(g, 140), 0), g, +h =>
    +h1 = set(h, 147, (ui(h, 147) + 1 : U32))
    +h2 = C.when(U32.is_ne(ui(h1, 141), 0), h1, +k => follow(k))
    +h3 = C.when(U32.is_ne(ui(h2, 165), 65536), h2, +k => rescale(k))
    C.when(Bool.or(U32.is_ne(ui(h3, 162), 0), U32.is_ne(ui(h3, 163), 0)), h3, +k => winloc(k)))

def addmark(+g: S.Sim) -> S.Sim:
  +n = ui(g, 144)
  +g1 = set(set(g, (170 + 2 * n : U32), (ui(g, 150) + half(ui(g, 152)) : U32)), (171 + 2 * n : U32), (ui(g, 151) + half(ui(g, 153)) : U32))
  set(g1, 144, ((n + 1) % 10 : U32))

def cheat.len(xs: List<&2, U32>) -> U32:
  U32.from_nat(List.length(&2, U32, xs))

def cht(+g: S.Sim, +slot: U32, +seq: List<&2, U32>, +ch: U32) -> S.Sim:
  +p = ui(g, slot)
  +n = cheat.len(seq)
  +want = Maybe.default(&2, U32, List.get(&2, U32, seq, U32.to_nat(p)), 0)
  +p1 = Bool.pick(U32, U32.is_lt(p, n), Bool.pick(U32, U32.is_eq(ch, want), (p + 1 : U32), 0), p)
  +fire = U32.is_ge(p1, n)
  set(set(g, slot, Bool.pick(U32, fire, 0, p1)), 198, C.b2u(fire))

def fired(+g: S.Sim) -> Bool:
  U32.is_ne(ui(g, 198), 0)

def pan(+g: S.Sim, +i: U32, +v: U32) -> S.Sim:
  C.br(U32.is_eq(ui(g, 141), 0), g, +h => set(h, i, v), +h => pass(h))

def toggle(+g: S.Sim, +i: U32, +on: U32, +off: U32) -> S.Sim:
  +v = (ui(g, i) .^. 1 : U32)
  S.p.message.set(set(g, i, v), Bool.pick(U32, U32.is_ne(v, 0), on, off))

def big(+g: S.Sim) -> S.Sim:
  +b = (ui(g, 145) .^. 1 : U32)
  C.br(U32.is_ne(b, 0), set(g, 145, b), +h => scaled(save(h), ui(h, 95)), +h => restore(h))

def keydown(+g: S.Sim, +key: U32) -> S.Sim:
  +p = ftom(g, 4)
  C.br(U32.is_eq(key, 63235), g, +h => pan(h, 162, p),
  +h => C.br(U32.is_eq(key, 63234), h, +k => pan(k, 162, F.neg(p)),
  +h => C.br(U32.is_eq(key, 63232), h, +k => pan(k, 163, p),
  +h => C.br(U32.is_eq(key, 63233), h, +k => pan(k, 163, F.neg(p)),
  +h => C.br(U32.is_eq(key, 45), h, +k => set(set(k, 164, 64250), 165, 66846),
  +h => C.br(U32.is_eq(key, 61), h, +k => set(set(k, 164, 66846), 165, 64250),
  +h => C.br(U32.is_eq(key, 9), h, +k => stop(set(k, 145, 0)),
  +h => C.br(U32.is_eq(key, 48), h, +k => big(k),
  +h => C.br(U32.is_eq(key, 102), h, +k => set(toggle(k, 141, 46, 47), 166, 2147483647),
  +h => C.br(U32.is_eq(key, 103), h, +k => toggle(k, 142, 48, 49),
  +h => C.br(U32.is_eq(key, 109), h, +k => addmark(S.p.message.set(k, (50 + ui(k, 144) : U32))),
  +h => C.br(U32.is_eq(key, 99), h, +k => S.p.message.set(marks.clear(10n, k, 0), 60), +k => pass(k)))))))))))))

def keyup(+g: S.Sim, +key: U32) -> S.Sim:
  +fol = U32.is_ne(ui(g, 141), 0)
  +g1 = C.when(Bool.and(Bool.not(fol), Bool.or(U32.is_eq(key, 63235), U32.is_eq(key, 63234))), g, +h => set(h, 162, 0))
  +g2 = C.when(Bool.and(Bool.not(fol), Bool.or(U32.is_eq(key, 63232), U32.is_eq(key, 63233))), g1, +h => set(h, 163, 0))
  pass(C.when(Bool.or(U32.is_eq(key, 45), U32.is_eq(key, 61)), g2, +h => set(set(h, 164, 65536), 165, 65536)))

def iddt(+g: S.Sim, +ch: U32) -> S.Sim:
  +g1 = cht(g, 190, [105, 100, 100, 116], ch)
  C.when(fired(g1), g1, +h => pass(set(h, 143, ((ui(h, 143) + 1) % 3 : U32))))

def am.respond(+g: S.Sim, +key: U32, +ch: U32, +down: Bool) -> S.Sim:
  C.br(U32.is_eq(ui(g, 140), 0), g, +h => C.br(Bool.and(down, U32.is_eq(key, 9)), h, +k => start(k), +k => pass(k)),
    +h => C.br(down, h, +k => iddt(keydown(k, key), ch), +k => keyup(k, key)))

def god(+g: S.Sim) -> S.Sim:
  +c = (S.p.cheats(g) .^. 2 : U32)
  +on = C.has(c, 2)
  +g1 = S.p.cheats.set(g, c)
  C.br(on, g1, +h => S.p.message.set(S.p.health.set(S.m.health.set(h, S.p.mo(h), 100), 100), 63), +h => S.p.message.set(h, 64))

def arsenal(+g: S.Sim) -> S.Sim:
  +g1 = S.p.own4.set(S.p.own3.set(S.p.own2.set(S.p.own1.set(S.p.own0.set(g, 1), 1), 1), 1), 1)
  +g2 = S.p.own8.set(S.p.own7.set(S.p.own6.set(S.p.own5.set(g1, 1), 1), 1), 1)
  +g3 = S.p.ammo3.set(S.p.ammo2.set(S.p.ammo1.set(S.p.ammo0.set(g2, S.p.max0(g2)), S.p.max1(g2)), S.p.max2(g2)), S.p.max3(g2))
  S.p.armortype.set(S.p.armor.set(g3, 200), 2)

def noclip(+g: S.Sim) -> S.Sim:
  +c = (S.p.cheats(g) .^. 1 : U32)
  S.p.message.set(S.p.cheats.set(g, c), Bool.pick(U32, C.has(c, 1), 67, 68))

def st.cheats(+g: S.Sim, +ch: U32) -> S.Sim:
  +g1 = cht(g, 191, [105, 100, 100, 113, 100], ch)
  C.br(fired(g1), g1, +h => god(h), +h =>
    +h1 = cht(h, 192, [105, 100, 102, 97], ch)
    C.br(fired(h1), h1, +k => S.p.message.set(arsenal(k), 65), +k =>
      +k1 = cht(k, 193, [105, 100, 107, 102, 97], ch)
      C.br(fired(k1), k1, +q => S.p.message.set(S.p.cards.set(arsenal(q), 63), 66), +q =>
        +q1 = Bool.pick(S.Sim, U.com(q), cht(q, 194, [105, 100, 99, 108, 105, 112], ch), cht(q, 194, [105, 100, 115, 112, 105, 115, 112, 111, 112, 100], ch))
        C.when(fired(q1), q1, +z => noclip(z)))))

def respond(+g: S.Sim, +key: U32, +ch: U32, +down: Bool) -> S.Sim:
  +g1 = C.when(Bool.and(Bool.and(down, Bool.not(C.net(g))), U32.is_ne(S.mp.skill(g), 4)), g, +h => st.cheats(h, ch))
  am.respond(set(g1, 199, 1), key, ch, down)

def dots(n: Nat, fr: V.Frame, +x: U32, +y: U32, +sx: U32, +sy: U32, +ax: U32, +ay: U32, +d: U32, +xmaj: Bool, +c: U32) -> V.Frame:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      +step = Bool.not(F.lt(d, 0))
      +nx = Bool.pick(U32, Bool.or(xmaj, step), (x + sx : U32), x)
      +ny = Bool.pick(U32, Bool.or(Bool.not(xmaj), step), (y + sy : U32), y)
      +nd = Bool.pick(U32, xmaj, (Bool.pick(U32, step, (d - ax : U32), d) + ay : U32), (Bool.pick(U32, step, (d - ay : U32), d) + ax : U32))
      dots(p, V.Frame{M.wr(fb, P.at(x, y), c), rom, ram, sd}, nx, ny, sx, sy, ax, ay, nd, xmaj, c)
    case _ f:
      f

def inside(+x: U32, +y: U32) -> Bool:
  Bool.and(Bool.and(Bool.not(F.lt(x, 0)), F.lt(x, 320)), Bool.and(Bool.not(F.lt(y, 0)), F.lt(y, 168)))

def fline(fr: V.Frame, +ax: U32, +ay: U32, +bx: U32, +by: U32, +c: U32) -> V.Frame:
  +dx = (bx - ax : U32)
  +dy = (by - ay : U32)
  +ax2 = (2 * F.abs(dx) : U32)
  +ay2 = (2 * F.abs(dy) : U32)
  +xmaj = F.gt(ax2, ay2)
  +n = (Bool.pick(U32, xmaj, F.abs(dx), F.abs(dy)) + 1 : U32)
  +d = Bool.pick(U32, xmaj, (ay2 - ax2 / 2 : U32), (ax2 - ay2 / 2 : U32))
  U.fwhen(Bool.and(inside(ax, ay), inside(bx, by)), fr, f => dots(U32.to_nat(n), f, ax, ay, Bool.pick(U32, F.lt(dx, 0), none(), 1), Bool.pick(U32, F.lt(dy, 0), none(), 1), ax2, ay2, d, xmaj, c))

def oc(+x: U32, +y: U32) -> U32:
  (Bool.pick(U32, F.lt(y, 0), 8, Bool.pick(U32, F.ge(y, 168), 4, 0)) .|. Bool.pick(U32, F.lt(x, 0), 1, Bool.pick(U32, F.ge(x, 320), 2, 0)) : U32)

def clip.loop?(n: Nat, +ax: U32, +ay: U32, +bx: U32, +by: U32, +o1: U32, +o2: U32) -> Fl:
  match n:
    case 0n:
      Fl{U32.is_eq((o1 .|. o2 : U32), 0), ax, ay, bx, by}
    case 1n+p:
      clip.step(U32.is_eq((o1 .|. o2 : U32), 0), p, ax, ay, bx, by, o1, o2)

def clip.next?(rej: Bool, n: Nat, +ax: U32, +ay: U32, +bx: U32, +by: U32, +o1: U32, +o2: U32) -> Fl:
  match rej:
    case True{}:
      Fl{False{}, ax, ay, bx, by}
    case False{}:
      clip.loop(n, ax, ay, bx, by, o1, o2)

def clip.step?(done: Bool, n: Nat, +ax: U32, +ay: U32, +bx: U32, +by: U32, +o1: U32, +o2: U32) -> Fl:
  match done:
    case True{}:
      Fl{True{}, ax, ay, bx, by}
    case False{}:
      +out = Bool.pick(U32, U32.is_ne(o1, 0), o1, o2)
      +top = C.has(out, 8)
      +bot = C.has(out, 4)
      +right = C.has(out, 2)
      +left = C.has(out, 1)
      +dyv = Bool.pick(U32, Bool.or(top, bot), (ay - by : U32), (by - ay : U32))
      +dxv = (bx - ax : U32)
      +tx = Bool.pick(U32, top, (ax + sdiv((dxv * ay : U32), dyv) : U32), Bool.pick(U32, bot, (ax + sdiv((dxv * (ay - 168) : U32), dyv) : U32), Bool.pick(U32, right, 319, 0)))
      +ty = Bool.pick(U32, top, 0, Bool.pick(U32, bot, 167, Bool.pick(U32, right, (ay + sdiv((dyv * (319 - ax) : U32), dxv) : U32), Bool.pick(U32, left, (ay + sdiv((dyv * F.neg(ax) : U32), dxv) : U32), 0))))
      +first = U32.is_eq(out, o1)
      +n1 = Bool.pick(U32, first, oc(tx, ty), o1)
      +n2 = Bool.pick(U32, first, o2, oc(tx, ty))
      clip.next(U32.is_ne((n1 .&. n2 : U32), 0), n, Bool.pick(U32, first, tx, ax), Bool.pick(U32, first, ty, ay), Bool.pick(U32, first, bx, tx), Bool.pick(U32, first, by, ty), n1, n2)

def clip.go(rej: Bool, +g: S.Sim, +ax: U32, +ay: U32, +bx: U32, +by: U32) -> Fl:
  match rej:
    case True{}:
      Fl{False{}, 0, 0, 0, 0}
    case False{}:
      +fax = mtof(g, (ax - ui(g, 150) : U32))
      +fay = (168 - mtof(g, (ay - ui(g, 151) : U32)) : U32)
      +fbx = mtof(g, (bx - ui(g, 150) : U32))
      +fby = (168 - mtof(g, (by - ui(g, 151) : U32)) : U32)
      +p1 = oc(fax, fay)
      +p2 = oc(fbx, fby)
      clip.next(U32.is_ne((p1 .&. p2 : U32), 0), 8n, fax, fay, fbx, fby, p1, p2)

def clip(+g: S.Sim, +ax: U32, +ay: U32, +bx: U32, +by: U32) -> Fl:
  +mx = ui(g, 150)
  +my = ui(g, 151)
  +mx2 = ui(g, 154)
  +my2 = ui(g, 155)
  +o1y = Bool.pick(U32, F.gt(ay, my2), 8, Bool.pick(U32, F.lt(ay, my), 4, 0))
  +o2y = Bool.pick(U32, F.gt(by, my2), 8, Bool.pick(U32, F.lt(by, my), 4, 0))
  +o1 = (o1y .|. Bool.pick(U32, F.lt(ax, mx), 1, Bool.pick(U32, F.gt(ax, mx2), 2, 0)) : U32)
  +o2 = (o2y .|. Bool.pick(U32, F.lt(bx, mx), 1, Bool.pick(U32, F.gt(bx, mx2), 2, 0)) : U32)
  clip.go(Bool.or(U32.is_ne((o1y .&. o2y : U32), 0), U32.is_ne((o1 .&. o2 : U32), 0)), g, ax, ay, bx, by)

def mline.go(fr: V.Frame, fl: Fl, +c: U32) -> V.Frame:
  match fl:
    case Fl{ok, +ax, +ay, +bx, +by}:
      U.fwhen(ok, fr, f => fline(f, ax, ay, bx, by, c))

def mline(fr: V.Frame, +g: S.Sim, +ax: U32, +ay: U32, +bx: U32, +by: U32, +c: U32) -> V.Frame:
  mline.go(fr, clip(g, ax, ay, bx, by), c)

def gridx.go?(more: Bool, n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +end: U32, +c: U32) -> V.Frame:
  match more:
    case True{}:
      gridx(n, mline(fr, g, x, ui(g, 151), x, (ui(g, 151) + ui(g, 153) : U32), c), g, (x + 8388608 : U32), end, c)
    case False{}:
      fr

def gridx?(n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +end: U32, +c: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      gridx.go(F.lt(x, end), p, fr, g, x, end, c)

def gridy.go?(more: Bool, n: Nat, fr: V.Frame, +g: S.Sim, +y: U32, +end: U32, +c: U32) -> V.Frame:
  match more:
    case True{}:
      gridy(n, mline(fr, g, ui(g, 150), y, (ui(g, 150) + ui(g, 152) : U32), y, c), g, (y + 8388608 : U32), end, c)
    case False{}:
      fr

def gridy?(n: Nat, fr: V.Frame, +g: S.Sim, +y: U32, +end: U32, +c: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      gridy.go(F.lt(y, end), p, fr, g, y, end, c)

def align(+s: U32, +o: U32) -> U32:
  +r = smod((s - o : U32), 8388608)
  Bool.pick(U32, U32.is_ne(r, 0), (s + 8388608 - r : U32), s)

def grid(fr: V.Frame, +g: S.Sim) -> V.Frame:
  f1 = gridx(2048n, fr, g, align(ui(g, 150), S.mp.ox(g)), (ui(g, 150) + ui(g, 152) : U32), 104)
  gridy(2048n, f1, g, align(ui(g, 151), S.mp.oy(g)), (ui(g, 151) + ui(g, 153) : U32), 104)

def wall.color(+g: S.Sim, +i: U32, +fl: U32, +fs: U32, +bs: U32, +cheat: Bool, +allmap: Bool) -> U32:
  +mapped = Bool.or(U32.is_ne(T.get(U32, S.sim.seen(g), i, 0), 0), C.has(fl, 256))
  +never = C.has(fl, 128)
  +col = Bool.pick(U32, U32.is_eq(bs, 65535), 176,
    Bool.pick(U32, U32.is_eq(T.get(U32, S.sim.lspec(g), i, 0), 39), 184,
      Bool.pick(U32, C.has(fl, 32), 176,
        Bool.pick(U32, U32.is_ne(S.s.floor(g, bs), S.s.floor(g, fs)), 64,
          Bool.pick(U32, U32.is_ne(S.s.ceil(g, bs), S.s.ceil(g, fs)), 231, Bool.pick(U32, cheat, 96, none()))))))
  Bool.pick(U32, Bool.or(cheat, mapped), Bool.pick(U32, Bool.and(never, Bool.not(cheat)), none(), col),
    Bool.pick(U32, Bool.and(allmap, Bool.not(never)), 99, none()))

def wall(fr: V.Frame, +g: S.Sim, +i: U32, +cheat: Bool, +allmap: Bool, l: S.RLine) -> V.Frame:
  match l:
    case S.RLine{+x1, +y1, +x2, +y2, dx, dy, +fl, sl, t, b, le, ri, s0, s1, +fs, +bs, tg}:
      +c = wall.color(g, i, fl, fs, bs, cheat, allmap)
      U.fwhen(U32.is_ne(c, none()), fr, f => mline(f, g, x1, y1, x2, y2, c))

def walls(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32, +cheat: Bool, +allmap: Bool) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      walls(p, wall(fr, g, i, cheat, allmap, T.get(S.RLine, S.mp.lines(g), i, S.RLine{0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 65535, 0, 65535, 0})), g, (i + 1 : U32), cheat, allmap)

def rx(+g: S.Sim, +x: U32, +y: U32, +a: U32) -> U32:
  +i = (a >> 19n : U32)
  (F.mul(x, V.sine(S.mp.tb(g), (i + 2048 : U32))) - F.mul(y, V.sine(S.mp.tb(g), i)) : U32)

def ry(+g: S.Sim, +x: U32, +y: U32, +a: U32) -> U32:
  +i = (a >> 19n : U32)
  (F.mul(x, V.sine(S.mp.tb(g), i)) + F.mul(y, V.sine(S.mp.tb(g), (i + 2048 : U32))) : U32)

def sc(+s: U32, +v: U32) -> U32:
  Bool.pick(U32, U32.is_eq(s, 0), v, F.mul(s, v))

def charline(fr: V.Frame, +g: S.Sim, +ax: U32, +ay: U32, +bx: U32, +by: U32, +s: U32, +a: U32, +c: U32, +x: U32, +y: U32) -> V.Frame:
  +sax = sc(s, ax)
  +say = sc(s, ay)
  +sbx = sc(s, bx)
  +sby = sc(s, by)
  mline(fr, g, (rx(g, sax, say, a) + x : U32), (ry(g, sax, say, a) + y : U32), (rx(g, sbx, sby, a) + x : U32), (ry(g, sbx, sby, a) + y : U32), c)

def character(xs: List<&2, U32>, fr: V.Frame, +g: S.Sim, +s: U32, +a: U32, +c: U32, +x: U32, +y: U32) -> V.Frame:
  match xs:
    case +ax <> +ay <> +bx <> +by <> t:
      character(t, charline(fr, g, ax, ay, bx, by, s, a, c, x, y), g, s, a, c, x, y)
    case _:
      fr

def arrow(+cheat: Bool) -> List<&2, U32>:
  +base : List<&2, U32> = [4293918720, 0, 1198372, 0, 1198372, 0, 599186, 299593, 1198372, 0, 599186, 4294667703,
    4293918720, 0, 4293619128, 299593, 4293918720, 0, 4293619128, 4294667703,
    4294218313, 0, 4293918720, 299593, 4294218313, 0, 4293918720, 4294667703]
  +cbase : List<&2, U32> = [4293918720, 0, 1198372, 0, 1198372, 0, 599186, 199728, 1198372, 0, 599186, 4294767568,
    4293918720, 0, 4293619128, 199728, 4293918720, 0, 4293619128, 4294767568,
    4294218313, 0, 4293918720, 199728, 4294218313, 0, 4293918720, 4294767568,
    4294368110, 0, 4294368110, 4294767568, 4294368110, 4294767568, 4294567838, 4294767568,
    4294567838, 4294767568, 4294567838, 299593, 4294767568, 0, 4294767568, 4294767568,
    4294767568, 4294767568, 0, 4294767568, 0, 4294767568, 0, 299593,
    199728, 299593, 199728, 4294796100, 199728, 4294796100, 237177, 4294758651, 237177, 4294758651, 319565, 4294796100]
  Bool.pick(List<&2, U32>, cheat, cbase, base)

def tri() -> List<&2, U32>:
  [4294934528, 4294921421, 65536, 0, 65536, 0, 4294934528, 45875, 4294934528, 45875, 4294934528, 4294921421]

def tlist?(n: Nat, more: Bool, fr: V.Frame, +g: S.Sim, +t: U32) -> V.Frame:
  match n more:
    case 1n+p True{}:
      +nx = S.m.snext(g, t)
      tlist(p, U32.is_ne(nx, 0), character(tri(), fr, g, 1048576, S.m.angle(g, t), 112, S.m.x(g, t), S.m.y(g, t)), g, nx)
    case _ _:
      fr

def things(n: Nat, fr: V.Frame, +g: S.Sim, +s: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +t = S.s.things(g, s)
      things(p, tlist(4096n, U32.is_ne(t, 0), fr, g, t), g, (s + 1 : U32))

def mark(fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame:
  +x = ui(g, (170 + 2 * i : U32))
  +fx = mtof(g, (x - ui(g, 150) : U32))
  +fy = (168 - mtof(g, (ui(g, (171 + 2 * i : U32)) - ui(g, 151) : U32)) : U32)
  U.fwhen(Bool.and(U32.is_ne(x, none()), Bool.and(Bool.and(F.ge(fx, 0), F.le(fx, 315)), Bool.and(F.ge(fy, 0), F.le(fy, 162)))), fr, f => U.patch(f, g, fx, fy, (296 + i : U32)))

def marks(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      marks(p, mark(fr, g, i), g, (i + 1 : U32))

def cross(fr: V.Frame) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      V.Frame{M.wr(fb, P.at(160, 84), 96), rom, ram, sd}

def netcolor(+i: U32) -> U32:
  Bool.pick(U32, U32.is_eq(i, 0), 112, Bool.pick(U32, U32.is_eq(i, 1), 96, Bool.pick(U32, U32.is_eq(i, 2), 64, 176)))

def netplayers(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +m = S.pi.mo(g, i)
      +c = Bool.pick(U32, U32.is_ne(S.pi.pw2(g, i), 0), 246, netcolor(i))
      netplayers(p, U.fwhen(C.ingame(g, i), fr, f => character(arrow(False{}), f, g, 0, S.m.angle(g, m), c, S.m.x(g, m), S.m.y(g, m))), g, (i + 1 : U32))

def players.go(net: Bool, fr: V.Frame, +g: S.Sim, +cheat: Bool) -> V.Frame:
  match net:
    case True{}:
      netplayers(4n, fr, g, 0)
    case False{}:
      +m = S.p.mo(g)
      character(arrow(cheat), fr, g, 0, S.m.angle(g, m), 209, S.m.x(g, m), S.m.y(g, m))

def players(fr: V.Frame, +g: S.Sim, +cheat: Bool) -> V.Frame:
  players.go(C.net(g), fr, g, cheat)

def draw(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +cheat = U32.is_ne(ui(g, 143), 0)
  f1 = U.fwhen(U32.is_ne(ui(g, 142), 0), fr, f => grid(f, g))
  f2 = walls(U32.to_nat(S.mp.nlines(g)), f1, g, 0, cheat, U32.is_ne(S.p.pw4(g), 0))
  f3 = players(f2, g, cheat)
  f4 = U.fwhen(U32.is_eq(ui(g, 143), 2), f3, f => things(U32.to_nat(S.mp.nsec(g)), f, g, 0))
  marks(10n, cross(f4), g, 0)
