import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./render.bend as V
import ./screen.bend as P
import ./mem.bend as M
import ./state.bend as S
import ./hudtext.bend as H
import ./sim.bend as C
import ./draw.bend as D

def addr(+g: S.Sim, +i: U32) -> U32:
  T.get(U32, S.mp.hud(g), (i + 3 : U32), 0)

def mode(+g: S.Sim) -> U32:
  T.get(U32, S.mp.hud(g), 1, 0)

def has31(+g: S.Sim) -> Bool:
  U32.is_ne(T.get(U32, S.mp.hud(g), 2, 0), 0)

def palbase(+g: S.Sim) -> U32:
  T.get(U32, S.mp.hud(g), 0, M.pal())

def word(fr: V.Frame, +a: U32) -> V.Frame & U32:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame & U32, M.rd(rom, a), r1 => +b0 =>
        M.let(V.Frame & U32, M.rd(r1, (a + 1 : U32)), r2 => +b1 =>
          (V.Frame{fb, r2, ram, sd}, (b0 .|. (b1 << 8n) : U32))))

def dword(fr: V.Frame, +a: U32) -> V.Frame & U32:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame & U32, M.rd(rom, a), r1 => +b0 =>
        M.let(V.Frame & U32, M.rd(r1, (a + 1 : U32)), r2 => +b1 =>
          M.let(V.Frame & U32, M.rd(r2, (a + 2 : U32)), r3 => +b2 =>
            M.let(V.Frame & U32, M.rd(r3, (a + 3 : U32)), r4 => +b3 =>
              (V.Frame{fb, r4, ram, sd}, (b0 .|. (b1 << 8n) .|. (b2 << 16n) .|. (b3 << 24n) : U32))))))

def fr.let(r: V.Frame & U32, k: V.Frame -> U32 -> V.Frame) -> V.Frame:
  (fr, v) = r
  k(fr, v)

def fr.let2(r: V.Frame & U32, k: V.Frame -> U32 -> V.Frame & U32) -> V.Frame & U32:
  (fr, v) = r
  k(fr, v)

def fr.lt(-R: Type, r: V.Frame & U32, k: V.Frame -> U32 -> R) -> R:
  (fr, v) = r
  k(fr, v)

def fwhen(c: Bool, fr: V.Frame, k: V.Frame -> V.Frame) -> V.Frame:
  match c:
    case True{}:
      k(fr)
    case False{}:
      fr

def put(ok: Bool, fb: Array<U32>, +x: U32, +y: U32, +c: U32) -> Array<U32>:
  match ok:
    case True{}:
      M.wr(fb, P.at(x, y), c)
    case False{}:
      fb

def pix(n: Nat, fr: V.Frame, +x: U32, +y: U32, +q: U32) -> V.Frame:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, q), r1 => +c =>
        pix(p, V.Frame{put(Bool.and(U32.is_lt(x, 320), U32.is_lt(y, 200)), fb, x, y, c), r1, ram, sd}, x, (y + 1 : U32), (q + 1 : U32)))
    case _ f:
      f

def posts?(n: Nat, fr: V.Frame, +x: U32, +y: U32, +q: U32) -> V.Frame:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, q), r1 => +td =>
        M.let(V.Frame, M.rd(r1, (q + 1 : U32)), r2 => +len =>
          posts.go(U32.is_eq(td, 255), p, V.Frame{fb, r2, ram, sd}, x, y, q, td, len)))
    case _ f:
      f

def posts.go?(stop: Bool, n: Nat, fr: V.Frame, +x: U32, +y: U32, +q: U32, +td: U32, +len: U32) -> V.Frame:
  match stop:
    case True{}:
      fr
    case False{}:
      posts(n, pix(U32.to_nat(len), fr, x, (y + td : U32), (q + 3 : U32)), x, y, (q + len + 4 : U32))

def cols(n: Nat, fr: V.Frame, +x: U32, +y: U32, +p: U32, +c: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+k:
      fr.let(dword(fr, (p + 8 + 4 * c : U32)), f => +off =>
        cols(k, posts(256n, f, (x + c : U32), y, (p + off : U32)), x, y, p, (c + 1 : U32)))

def patch.at(fr: V.Frame, +x: U32, +y: U32, +p: U32) -> V.Frame:
  fr.let(word(fr, p), f1 => +w =>
    fr.let(word(f1, (p + 4 : U32)), f2 => +l =>
      fr.let(word(f2, (p + 6 : U32)), f3 => +t =>
        cols(U32.to_nat(w), f3, (x - V.s16(l) : U32), (y - V.s16(t) : U32), p, 0))))

def patch(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +i: U32) -> V.Frame:
  +a = addr(g, i)
  fwhen(U32.is_ne(a, 0), fr, f => patch.at(f, x, y, a))

def width(fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame & U32:
  word(fr, addr(g, i))

def hword(fr: V.Frame, +g: S.Sim, +i: U32, +off: U32) -> V.Frame & U32:
  word(fr, (addr(g, i) + off : U32))

def patch.col(fr: V.Frame, +x: U32, +p: U32, +c: U32) -> V.Frame:
  fr.let(dword(fr, (p + 8 + 4 * c : U32)), f => +off => posts(256n, f, x, 0, (p + off : U32)))

def fcols(n: Nat, fr: V.Frame, +x: U32, +y: U32, +p: U32, +c: U32, +w: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+k:
      fr.let(dword(fr, (p + 8 + 4 * (w - 1 - c) : U32)), f => +off =>
        fcols(k, posts(256n, f, (x + c : U32), y, (p + off : U32)), x, y, p, (c + 1 : U32), w))

def patch.flip(fr: V.Frame, +x: U32, +y: U32, +p: U32) -> V.Frame:
  fr.let(word(fr, p), f1 => +w =>
    fr.let(word(f1, (p + 4 : U32)), f2 => +l =>
      fr.let(word(f2, (p + 6 : U32)), f3 => +t =>
        fcols(U32.to_nat(w), f3, (x - V.s16(l) : U32), (y - V.s16(t) : U32), p, 0, w))))

def digits(n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +num: U32, +w: U32, +base: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      fwhen(U32.is_ne(num, 0), fr, f => digits(p, patch(f, g, (x - w : U32), y, (base + num % 10 : U32)), g, (x - w : U32), y, (num / 10 : U32), w, base))

def num.go(z: Bool, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +num: U32, +n: Nat, +base: U32, +w: U32) -> V.Frame:
  match z:
    case True{}:
      patch(fr, g, (x - w : U32), y, base)
    case False{}:
      digits(n, fr, g, x, y, num, w, base)

def num(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +num: U32, +n: Nat, +base: U32) -> V.Frame:
  fwhen(U32.is_ne(num, 1994), fr, f => fr.let(width(f, g, base), f1 => +w => num.go(U32.is_eq(num, 0), f1, g, x, y, num, n, base, w)))

def ui(+g: S.Sim, +i: U32) -> U32:
  T.get(U32, S.sim.ui(g), i, 0)


def ui.set(+g: S.Sim, +i: U32, +v: U32) -> S.Sim:
  S.sim.ui.set(g, T.set(U32, S.sim.ui(g), i, v))


def com(+g: S.Sim) -> Bool:
  U32.is_eq(mode(g), 3)


def fsel(c: Bool, fr: V.Frame, a: V.Frame -> V.Frame, b: V.Frame -> V.Frame) -> V.Frame:
  match c:
    case True{}:
      a(fr)
    case False{}:
      b(fr)


def fsel2(c: Bool, fr: V.Frame, a: V.Frame -> V.Frame & U32, b: V.Frame -> V.Frame & U32) -> V.Frame & U32:
  match c:
    case True{}:
      a(fr)
    case False{}:
      b(fr)


def pw(fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame & U32:
  width(fr, g, i)


def write?(cs: List<&2, U32>, n: Nat, fr: V.Frame, +g: S.Sim, +x0: U32, +x: U32, +y: U32) -> V.Frame:
  match cs n:
    case +c <> t 1n+p:
      write.nl(U32.is_eq(c, 10), Bool.and(U32.is_ge(c, 33), U32.is_le(c, 96)), t, p, fr, g, x0, x, y, (85 + c - 33 : U32))
    case _ _:
      fr


def write.nl?(nl: Bool, glyph: Bool, cs: List<&2, U32>, n: Nat, fr: V.Frame, +g: S.Sim, +x0: U32, +x: U32, +y: U32, +i: U32) -> V.Frame:
  match nl:
    case True{}:
      write(cs, n, fr, g, x0, x0, (y + 11 : U32))
    case False{}:
      write.ch(glyph, cs, n, fr, g, x0, x, y, i)


def write.fit?(ok: Bool, cs: List<&2, U32>, n: Nat, fr: V.Frame, +g: S.Sim, +x0: U32, +x: U32, +y: U32, +i: U32, +w: U32) -> V.Frame:
  match ok:
    case True{}:
      write(cs, n, patch(fr, g, x, y, i), g, x0, (x + w : U32), y)
    case False{}:
      fr


def write.ch?(glyph: Bool, cs: List<&2, U32>, n: Nat, fr: V.Frame, +g: S.Sim, +x0: U32, +x: U32, +y: U32, +i: U32) -> V.Frame:
  match glyph:
    case True{}:
      fr.let(pw(fr, g, i), f => +w => write.fit(U32.is_le((x + w : U32), 320), cs, n, f, g, x0, x, y, i, w))
    case False{}:
      write(cs, n, fr, g, x0, (x + 4 : U32), y)


def strwidth?(cs: List<&2, U32>, fr: V.Frame, +g: S.Sim, +acc: U32) -> V.Frame & U32:
  match cs:
    case +c <> t:
      strwidth.ch(Bool.and(U32.is_ge(c, 33), U32.is_le(c, 96)), t, fr, g, acc, (85 + c - 33 : U32))
    case []:
      (fr, acc)


def strwidth.ch?(glyph: Bool, cs: List<&2, U32>, fr: V.Frame, +g: S.Sim, +acc: U32, +i: U32) -> V.Frame & U32:
  match glyph:
    case True{}:
      fr.let2(pw(fr, g, i), f => +w => strwidth(cs, f, g, (acc + w : U32)))
    case False{}:
      strwidth(cs, fr, g, (acc + 4 : U32))


def ammo.k(+w: U32) -> U32:
  Bool.pick(U32, Bool.or(U32.is_eq(w, 1), U32.is_eq(w, 3)), 0,
    Bool.pick(U32, Bool.or(U32.is_eq(w, 2), U32.is_eq(w, 8)), 1,
      Bool.pick(U32, Bool.or(U32.is_eq(w, 5), U32.is_eq(w, 6)), 2, Bool.pick(U32, U32.is_eq(w, 4), 3, 5))))

def ready.ammo(+g: S.Sim) -> U32:
  +k = ammo.k(S.p.ready(g))
  Bool.pick(U32, U32.is_eq(k, 5), 1994, S.pget(g, (42 + k : U32)))

def armsmask(n: Nat, +g: S.Sim, +i: U32, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      armsmask(p, g, (i + 1 : U32), (acc .|. (C.b2u(U32.is_ne(S.pget(g, (34 + i : U32)), 0)) << U32.to_nat(i)) : U32))

def dirty(+g: S.Sim) -> U32:
  Bool.pick(U32, U32.is_ne(T.get(U32, S.sim.ui(g), 97, 0), 0), 63, (armsmask(6n, g, 0, 0) .^. T.get(U32, S.sim.ui(g), 98, 0) : U32))

def rpix(n: Nat, fr: V.Frame, +x: U32, +y: U32, +q: U32, +y0: U32, +y1: U32) -> V.Frame:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, q), r1 => +c =>
        rpix(p, V.Frame{put(Bool.and(U32.is_ge(y, y0), U32.is_lt(y, y1)), fb, x, y, c), r1, ram, sd}, x, (y + 1 : U32), (q + 1 : U32), y0, y1))
    case _ f:
      f

def rposts?(n: Nat, fr: V.Frame, +x: U32, +y: U32, +q: U32, +y0: U32, +y1: U32) -> V.Frame:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, q), r1 => +td =>
        M.let(V.Frame, M.rd(r1, (q + 1 : U32)), r2 => +len =>
          rposts.go(U32.is_eq(td, 255), p, V.Frame{fb, r2, ram, sd}, x, y, q, td, len, y0, y1)))
    case _ f:
      f

def rposts.go?(stop: Bool, n: Nat, fr: V.Frame, +x: U32, +y: U32, +q: U32, +td: U32, +len: U32, +y0: U32, +y1: U32) -> V.Frame:
  match stop:
    case True{}:
      fr
    case False{}:
      rposts(n, rpix(U32.to_nat(len), fr, x, (y + td : U32), (q + 3 : U32), y0, y1), x, y, (q + len + 4 : U32), y0, y1)

def rcols(n: Nat, fr: V.Frame, +x: U32, +y: U32, +p: U32, +c: U32, +y0: U32, +y1: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+k:
      fr.let(dword(fr, (p + 8 + 4 * c : U32)), f => +off =>
        rcols(k, rposts(256n, f, (x + c : U32), y, (p + off : U32), y0, y1), x, y, p, (c + 1 : U32), y0, y1))

def backing.go(fr: V.Frame, +g: S.Sim, +x0: U32, +y0: U32, +w: U32, +h: U32) -> V.Frame:
  +a = addr(g, 0)
  fwhen(U32.is_ne(a, 0), fr, f => rcols(U32.to_nat(w), f, 0, 168, a, x0, y0, (y0 + h : U32)))

def backing(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +i: U32) -> V.Frame:
  fr.let(word(fr, addr(g, i)), f1 => +w =>
    fr.let(word(f1, (addr(g, i) + 2 : U32)), f2 => +h =>
      fr.let(word(f2, (addr(g, i) + 4 : U32)), f3 => +l =>
        fr.let(word(f3, (addr(g, i) + 6 : U32)), f4 => +t =>
          backing.go(f4, g, (x - V.s16(l) : U32), (y - V.s16(t) : U32), w, h)))))

def arms(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32, +d: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +own = U32.is_ne(S.pget(g, (34 + i : U32)), 0)
      +x = (111 + (i % 3) * 12 : U32)
      +y = (172 + (i / 3) * 10 : U32)
      +refresh = U32.is_ne(T.get(U32, S.sim.ui(g), 97, 0), 0)
      f1 = fwhen(U32.is_ne((d .&. (1 << U32.to_nat(i)) : U32), 0), fr, f => backing(f, g, x, y, Bool.pick(U32, Bool.and(own, refresh), (16 + i : U32), (26 + i : U32))))
      arms(p, patch(f1, g, x, y, Bool.pick(U32, own, (16 + i : U32), (26 + i : U32))), g, (i + 1 : U32), d)

def keybox(+c: U32, +i: U32) -> U32:
  Bool.pick(U32, U32.is_ne((c .&. (8 << U32.to_nat(i)) : U32), 0), (i + 3 : U32),
    Bool.pick(U32, U32.is_ne((c .&. (1 << U32.to_nat(i)) : U32), 0), i, 4294967295))

def keys(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +k = keybox(S.p.cards(g), i)
      keys(p, fwhen(U32.is_ne(k, 4294967295), fr, f => patch(f, g, 239, (171 + 10 * i : U32), (34 + k : U32))), g, (i + 1 : U32))

def ammoy(+k: U32) -> U32:
  Bool.pick(U32, U32.is_eq(k, 0), 173, Bool.pick(U32, U32.is_eq(k, 1), 179, Bool.pick(U32, U32.is_eq(k, 2), 191, 185)))

def ammos(n: Nat, fr: V.Frame, +g: S.Sim, +k: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      f1 = num(fr, g, 288, ammoy(k), S.pget(g, (42 + k : U32)), 3n, 14)
      ammos(p, num(f1, g, 314, ammoy(k), S.pget(g, (46 + k : U32)), 3n, 14), g, (k + 1 : U32))

def statusbar(fr: V.Frame, +g: S.Sim) -> V.Frame:
  f1 = patch(fr, g, 0, 168, 0)
  f2 = num(f1, g, 44, 171, ready.ammo(g), 3n, 2)
  f3 = ammos(4n, f2, g, 0)
  f4 = num(patch(f3, g, 90, 171, 12), g, 90, 171, S.p.health(g), 3n, 2)
  f5 = num(patch(f4, g, 221, 171, 12), g, 221, 171, S.p.armor(g), 3n, 2)
  f6 = arms(6n, patch(f5, g, 104, 168, 1), g, 0, dirty(g))
  keys(3n, patch(f6, g, 143, 168, (43 + S.sim.stface(g) : U32)), g, 0)

def text?(cs: List<&2, U32>, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32) -> V.Frame:
  match cs:
    case +c <> t:
      +glyph = Bool.and(U32.is_ne(c, 32), Bool.and(U32.is_ge(c, 33), U32.is_le(c, 95)))
      text.go(glyph, t, fr, g, x, y, (85 + c - 33 : U32))
    case []:
      fr

def text.go?(glyph: Bool, cs: List<&2, U32>, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +i: U32) -> V.Frame:
  match glyph:
    case True{}:
      fr.let(width(fr, g, i), f => +w =>
        text.fit(U32.is_gt((x + w : U32), 320), cs, f, g, x, y, i, w))
    case False{}:
      text.space(U32.is_ge((x + 4 : U32), 320), cs, fr, g, (x + 4 : U32), y)

def text.fit?(over: Bool, cs: List<&2, U32>, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +i: U32, +w: U32) -> V.Frame:
  match over:
    case True{}:
      fr
    case False{}:
      text(cs, patch(fr, g, x, y, i), g, (x + w : U32), y)

def text.space?(over: Bool, cs: List<&2, U32>, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32) -> V.Frame:
  match over:
    case True{}:
      fr
    case False{}:
      text(cs, fr, g, x, y)

def message(fr: V.Frame, +g: S.Sim) -> V.Frame:
  fwhen(U32.is_ne(S.sim.hcount(g), 0), fr,
    f => text(T.get(List<&2, U32>, T.from_list(List<&2, U32>, H.msgtext()), S.sim.hmsg(g), []), f, g, 0, 0))

def palette(+g: S.Sim) -> U32:
  +dc = S.p.damagecount(g)
  +st = S.p.pw1(g)
  +bz = (12 - (st >> 6n) : U32)
  +cnt = Bool.pick(U32, Bool.and(U32.is_ne(st, 0), F.gt(bz, dc)), bz, dc)
  +bc = S.p.bonuscount(g)
  +rs = S.p.pw3(g)
  Bool.pick(U32, U32.is_ne(cnt, 0), (U32.min(((cnt + 7) >> 3n : U32), 7) + 1 : U32),
    Bool.pick(U32, U32.is_ne(bc, 0), (U32.min(((bc + 7) >> 3n : U32), 3) + 9 : U32),
      Bool.pick(U32, Bool.or(F.gt(rs, 128), U32.is_ne((rs .&. 8 : U32), 0)), 13, 0)))

def draw(fr: V.Frame, +g: S.Sim) -> V.Frame:
  message(statusbar(fr, g), g)

def psp.cm(+g: S.Sim, +frm: U32) -> U32:
  +iv = S.p.pw2(g)
  +fx = S.p.fixedcm(g)
  +ll0 = ((S.s.light(g, C.secof(g, S.m.sub(g, S.p.mo(g)))) >> 4n) + S.p.extralight(g) : U32)
  +ll = Bool.pick(U32, F.lt(ll0, 0), 0, Bool.pick(U32, F.gt(ll0, 15), 15, ll0))
  Bool.pick(U32, Bool.or(F.gt(iv, 128), U32.is_ne((iv .&. 8 : U32), 0)), M.none(),
    Bool.pick(U32, U32.is_ne(fx, 0), (fx * 256 : U32),
      Bool.pick(U32, U32.is_ne((frm .&. 32768 : U32), 0), 0, (V.lightmap(ll, 192512) * 256 : U32))))

def psp.of(+g: S.Sim, +pos: U32, +rest: List<&2, D.PSp>) -> List<&2, D.PSp>:
  +b = (53 + pos * 4 : U32)
  +st = S.pget(g, b)
  +frm = C.state(g, st, 1)
  Bool.pick(List<&2, D.PSp>, U32.is_eq(st, 0), rest, D.PSp{C.state(g, st, 0), frm, S.pget(g, (b + 2 : U32)), S.pget(g, (b + 3 : U32)), psp.cm(g, frm)} <> rest)

def psps(+g: S.Sim) -> List<&2, D.PSp>:
  psp.of(g, 0, psp.of(g, 1, []))

def view(+g: S.Sim) -> V.View:
  +m = S.p.mo(g)
  V.View{S.m.x(g, m), S.m.y(g, m), S.p.viewz(g), S.m.angle(g, m), S.p.extralight(g)}

def scene(+g: S.Sim, rom: Array<U32>) -> V.Frame:
  D.render.with(S.mp.tb(g), S.sim.w(g), view(g), psps(g), rom)

def pal(+g: S.Sim) -> U32:
  (palbase(g) + 256 * palette(g) : U32)

def render(+g: S.Sim, rom: Array<U32>) -> Array<U32> & Array<U32>:
  D.out.at(draw(scene(g, rom), g), pal(g))
