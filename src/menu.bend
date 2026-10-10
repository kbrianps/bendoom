import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./hud.bend as U
import ./render.bend as V
import ./hudtext.bend as H

def text(+i: U32) -> List<&2, U32>:
  T.get(List<&2, U32>, T.from_list(List<&2, U32>, H.texts()), i, [])

def none() -> U32:
  4294967295

def ui(+g: S.Sim, +i: U32) -> U32:
  U.ui(g, i)

def set(+g: S.Sim, +i: U32, +v: U32) -> S.Sim:
  U.ui.set(g, i, v)

def retail(+g: S.Sim) -> Bool:
  U32.is_eq(U.mode(g), 2)

def items() -> T.Vec<U32>:
  T.from_list(U32, [1, 253, 1, 110, 1, 254, 2, 111, 1, 255, 3, 108, 1, 256, 4, 115, 1, 257, 5, 114, 1, 258, 6, 113, 0, 0, 0, 0, 0, 0, 0, 0, 1, 262, 7, 107, 1, 263, 7, 116, 1, 264, 7, 105, 1, 265, 7, 116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 268, 8, 105, 1, 269, 8, 104, 1, 270, 8, 104, 1, 271, 8, 117, 1, 272, 8, 110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 275, 9, 101, 1, 276, 10, 109, 1, 279, 11, 103, 2, 282, 12, 115, 4294967295, 0, 0, 0, 2, 283, 13, 109, 4294967295, 0, 0, 0, 1, 284, 14, 115, 1, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 285, 17, 115, 4294967295, 0, 0, 0, 2, 286, 18, 109, 4294967295, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 49, 0, 0, 19, 50, 0, 0, 19, 51, 0, 0, 19, 52, 0, 0, 19, 53, 0, 0, 19, 54, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 20, 49, 1, 0, 20, 50, 1, 0, 20, 51, 1, 0, 20, 52, 1, 0, 20, 53, 1, 0, 20, 54, 0, 0, 0, 0, 0, 0, 0, 0, 1, 253, 1, 110, 1, 254, 2, 111, 1, 255, 3, 108, 1, 256, 4, 115, 1, 258, 6, 113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

def tm(+g: S.Sim, +m: U32) -> U32:
  Bool.pick(U32, Bool.and(U32.is_eq(m, 0), U.com(g)), 9, m)

def item(+g: S.Sim, +m: U32, +i: U32, +f: U32) -> U32:
  T.get(U32, items(), ((tm(g, m) * 8 + i) * 4 + f : U32), 0)

def count(+g: S.Sim, +m: U32) -> U32:
  T.get(U32, T.from_list(U32, [Bool.pick(U32, U.com(g), 5, 6), Bool.pick(U32, retail(g), 4, 3), 5, 8, 1, 1, 4, 6, 6]), m, 1)

def mx(+g: S.Sim, +m: U32) -> U32:
  T.get(U32, T.from_list(U32, [97, 48, 48, 60, Bool.pick(U32, Bool.or(U.com(g), retail(g)), 330, 280), 330, 80, 80, 80]), m, 0)

def my(+g: S.Sim, +m: U32) -> U32:
  T.get(U32, T.from_list(U32, [Bool.pick(U32, U.com(g), 72, 64), 63, 63, 37, Bool.pick(U32, U.com(g), 165, Bool.pick(U32, retail(g), 175, 185)), 175, 64, 54, 54]), m, 0)

def prev(+g: S.Sim, +m: U32) -> U32:
  T.get(U32, T.from_list(U32, [none(), 0, Bool.pick(U32, U.com(g), 0, 1), 0, 0, 4, 3, 0, 0]), m, none())

def active(+g: S.Sim) -> Bool:
  U32.is_ne(ui(g, 100), 0)

def pass(+g: S.Sim) -> S.Sim:
  set(g, 199, 0)

def help(+g: S.Sim, +m: U32) -> S.Sim:
  C.when(Bool.or(U32.is_eq(m, 4), U32.is_eq(m, 5)), g, +h => set(h, 97, 1))

def setup(+g: S.Sim, +m: U32) -> S.Sim:
  set(set(help(g, m), 101, m), 102, ui(g, (130 + m : U32)))

def last.on(+g: S.Sim) -> S.Sim:
  set(g, (130 + ui(g, 101) : U32), ui(g, 102))

def clear(+g: S.Sim) -> S.Sim:
  set(g, 100, 0)

def startcp(+g: S.Sim) -> S.Sim:
  C.when(U32.is_eq(ui(g, 100), 0), g, +h => set(set(set(h, 100, 1), 101, 0), 102, ui(h, 130)))

def startmsg(+g: S.Sim, +t: U32, +r: U32, +inp: U32) -> S.Sim:
  set(set(set(set(set(g, 108, ui(g, 100)), 105, (t + 1 : U32)), 107, r), 106, inp), 100, 1)

def title(+g: S.Sim) -> S.Sim:
  set(set(g, 124, none()), 125, 1)

def newgame(+g: S.Sim, +sk: U32, +ep: U32) -> S.Sim:
  set(set(S.sim.act.set(g, 2), 120, ep), 121, sk)

def quitmsg(+g: S.Sim) -> S.Sim:
  startmsg(g, (Bool.pick(U32, U.com(g), 103, 95) + S.sim.tic(g) % 8 : U32), 3, 1)

def endgame(+g: S.Sim) -> S.Sim:
  C.when(U32.is_ne(ui(g, 118), 0), g, +h => startmsg(h, 112, 2, 1))

def messages(+g: S.Sim) -> S.Sim:
  +off = (ui(g, 115) .^. 1 : U32)
  set(set(S.p.message.set(g, Bool.pick(U32, U32.is_ne(off, 0), 44, 45)), 115, off), 116, 1)

def detail(+g: S.Sim) -> S.Sim:
  +d = (ui(g, 110) .^. 1 : U32)
  set(S.p.message.set(g, Bool.pick(U32, U32.is_eq(d, 0), 61, 62)), 110, d)

def slider(+g: S.Sim, +i: U32, +choice: U32, +top: U32) -> S.Sim:
  +v = ui(g, i)
  Bool.pick(S.Sim, U32.is_eq(choice, 0), set(g, i, Bool.pick(U32, U32.is_ne(v, 0), (v - 1 : U32), v)), set(g, i, Bool.pick(U32, U32.is_lt(v, top), (v + 1 : U32), v)))

def savegame(+g: S.Sim) -> S.Sim:
  C.br(U32.is_eq(ui(g, 118), 0), g, +h => startmsg(h, 116, 0, 0), +h => C.when(U32.is_eq(S.sim.gs(h), 0), h, +k => setup(k, 8)))

def episode(+g: S.Sim, +choice: U32) -> S.Sim:
  +c = Bool.pick(U32, Bool.and(U32.is_eq(U.mode(g), 1), U32.is_gt(choice, 2)), 0, choice)
  C.br(Bool.and(U32.is_eq(U.mode(g), 0), U32.is_ne(choice, 0)), g, +h => setup(startmsg(h, 113, 0, 0), 4), +h => setup(set(h, 109, c), 2))

def skill(+g: S.Sim, +choice: U32) -> S.Sim:
  C.br(U32.is_eq(choice, 4), g, +h => startmsg(h, 111, 1, 1), +h => clear(newgame(h, choice, (ui(h, 109) + 1 : U32))))

def route(+g: S.Sim, +r: U32, +choice: U32) -> S.Sim:
  C.br(U32.is_eq(r, 1), g, +h => setup(h, Bool.pick(U32, U.com(h), 2, 1)),
  +h => C.br(U32.is_eq(r, 2), h, +k => setup(k, 3),
  +h => C.br(U32.is_eq(r, 3), h, +k => setup(k, 7),
  +h => C.br(U32.is_eq(r, 4), h, +k => savegame(k),
  +h => C.br(U32.is_eq(r, 5), h, +k => setup(k, 4),
  +h => C.br(U32.is_eq(r, 6), h, +k => quitmsg(k),
  +h => C.br(U32.is_eq(r, 7), h, +k => episode(k, choice),
  +h => C.br(U32.is_eq(r, 8), h, +k => skill(k, choice),
  +h => C.br(U32.is_eq(r, 9), h, +k => endgame(k),
  +h => C.br(U32.is_eq(r, 10), h, +k => messages(k),
  +h => C.br(U32.is_eq(r, 11), h, +k => detail(k),
  +h => C.br(U32.is_eq(r, 12), h, +k => slider(k, 112, choice, 8),
  +h => C.br(U32.is_eq(r, 13), h, +k => slider(k, 111, choice, 9),
  +h => C.br(U32.is_eq(r, 14), h, +k => setup(k, 6),
  +h => C.br(U32.is_eq(r, 15), h, +k => setup(k, Bool.pick(U32, Bool.or(U.com(k), retail(k)), 0, 5)),
  +h => C.br(U32.is_eq(r, 16), h, +k => setup(k, 0),
  +h => C.br(U32.is_eq(r, 17), h, +k => slider(k, 113, choice, 15),
  +h => C.when(U32.is_eq(r, 18), h, +k => slider(k, 114, choice, 15)))))))))))))))))))

def msg.route(+g: S.Sim, +r: U32, +key: U32) -> S.Sim:
  +yes = U32.is_eq(key, 121)
  C.br(Bool.and(yes, U32.is_eq(r, 1)), g, +h => clear(newgame(h, 4, (ui(h, 109) + 1 : U32))),
    +h => C.br(Bool.and(yes, U32.is_eq(r, 2)), h, +k => title(clear(last.on(k))),
      +k => C.when(Bool.and(yes, U32.is_eq(r, 3)), k, +q => set(q, 119, 1))))

def msg.key(+g: S.Sim, +key: U32) -> S.Sim:
  +ok = Bool.or(U32.is_eq(ui(g, 106), 0), Bool.or(Bool.or(U32.is_eq(key, 32), U32.is_eq(key, 27)), Bool.or(U32.is_eq(key, 121), U32.is_eq(key, 110))))
  C.br(ok, g, +h => clear(msg.route(set(set(h, 100, ui(h, 108)), 105, 0), ui(h, 107), key)), +h => pass(h))

def down(n: Nat, +g: S.Sim, +m: U32, +i: U32) -> U32:
  match n:
    case 0n:
      i
    case 1n+p:
      +j = Bool.pick(U32, U32.is_gt((i + 1 : U32), (count(g, m) - 1 : U32)), 0, (i + 1 : U32))
      Bool.pick(U32, U32.is_eq(item(g, m, j, 0), none()), down(p, g, m, j), j)

def up(n: Nat, +g: S.Sim, +m: U32, +i: U32) -> U32:
  match n:
    case 0n:
      i
    case 1n+p:
      +j = Bool.pick(U32, U32.is_eq(i, 0), (count(g, m) - 1 : U32), (i - 1 : U32))
      Bool.pick(U32, U32.is_eq(item(g, m, j, 0), none()), up(p, g, m, j), j)

def alpha(n: Nat, +g: S.Sim, +m: U32, +i: U32, +cnt: U32, +ch: U32) -> U32:
  match n:
    case 0n:
      none()
    case 1n+p:
      +j = (i % cnt : U32)
      Bool.pick(U32, U32.is_eq(item(g, m, j, 3), ch), j, alpha(p, g, m, (i + 1 : U32), cnt, ch))

def found(+g: S.Sim, +j: U32) -> S.Sim:
  Bool.pick(S.Sim, U32.is_eq(j, none()), pass(g), set(g, 102, j))

def menu.key(+g: S.Sim, +key: U32, +ch: U32) -> S.Sim:
  +m = ui(g, 101)
  +i = ui(g, 102)
  +st = item(g, m, i, 0)
  +r = item(g, m, i, 2)
  +cnt = count(g, m)
  C.br(U32.is_eq(key, 63233), g, +h => set(h, 102, down(8n, h, m, i)),
  +h => C.br(U32.is_eq(key, 63232), h, +k => set(k, 102, up(8n, k, m, i)),
  +h => C.br(U32.is_eq(key, 63234), h, +k => C.when(Bool.and(U32.is_ne(r, 0), U32.is_eq(st, 2)), k, +q => route(q, r, 0)),
  +h => C.br(U32.is_eq(key, 63235), h, +k => C.when(Bool.and(U32.is_ne(r, 0), U32.is_eq(st, 2)), k, +q => route(q, r, 1)),
  +h => C.br(U32.is_eq(key, 13), h, +k => C.when(Bool.and(U32.is_ne(r, 0), U32.is_ne(st, 0)), k, +q => route(last.on(q), r, Bool.pick(U32, U32.is_eq(st, 2), 1, i))),
  +h => C.br(U32.is_eq(key, 27), h, +k => clear(last.on(k)),
  +h => C.br(U32.is_eq(key, 127), h, +k => C.when(U32.is_ne(prev(k, m), none()), last.on(k), +q => setup(q, prev(q, m))),
  +h => C.br(U32.is_ne(ch, 0), h, +k => found(k, alpha(U32.to_nat(cnt), k, m, (i + 1 : U32), cnt, ch)), +k => pass(k)))))))))

def fkey(+g: S.Sim, +f: U32) -> S.Sim:
  C.br(U32.is_eq(f, 0), g, +h => set(set(set(startcp(h), 97, 1), 101, Bool.pick(U32, retail(h), 5, 4)), 102, 0),
  +h => C.br(U32.is_eq(f, 1), h, +k => savegame(startcp(k)),
  +h => C.br(U32.is_eq(f, 2), h, +k => setup(startcp(k), 7),
  +h => C.br(U32.is_eq(f, 3), h, +k => set(set(startcp(k), 101, 6), 102, 0),
  +h => C.br(U32.is_eq(f, 4), h, +k => detail(k),
  +h => C.br(U32.is_eq(f, 5), h, +k => C.when(Bool.and(U32.is_ne(ui(k, 118), 0), U32.is_eq(S.sim.gs(k), 0)), k, +q => C.when(F.lt(ui(q, 126), 0), q, +z => set(setup(startcp(z), 8), 126, 4294967294))),
  +h => C.br(U32.is_eq(f, 6), h, +k => endgame(k),
  +h => C.br(U32.is_eq(f, 7), h, +k => messages(k),
  +h => C.br(U32.is_eq(f, 8), h, +k => C.when(F.lt(ui(k, 126), 0), k, +q => startmsg(q, 118, 0, 0)),
  +h => C.br(U32.is_eq(f, 9), h, +k => quitmsg(k), +k => pass(k)))))))))))

def idle.key(+g: S.Sim, +key: U32) -> S.Sim:
  C.br(Bool.or(U32.is_eq(key, 45), U32.is_eq(key, 61)), g, +h => C.br(U32.is_ne(ui(h, 140), 0), h, +k => pass(k), +k => slider(k, 112, Bool.pick(U32, U32.is_eq(key, 61), 1, 0), 8)),
    +h => C.br(Bool.and(U32.is_ge(key, 63236), U32.is_le(key, 63245)), h, +k => fkey(k, (key - 63236 : U32)),
      +k => C.br(U32.is_eq(key, 27), k, +q => startcp(q), +q => pass(q))))

def respond(+g: S.Sim, +key: U32) -> S.Sim:
  +ch = Bool.pick(U32, U32.is_lt(key, 128), key, 0)
  C.br(U32.is_ne(ui(g, 105), 0), set(g, 199, 1), +h => msg.key(h, key),
    +h => C.br(U32.is_eq(ui(h, 100), 0), h, +k => idle.key(k, key), +k => menu.key(k, key, ch)))

def close(+g: S.Sim) -> S.Sim:
  C.br(Bool.and(Bool.and(U32.is_ne(ui(g, 100), 0), U32.is_ne(ui(g, 105), 0)), U32.is_eq(ui(g, 107), 3)), g, +h => set(h, 119, 1), +h => quitmsg(h))

def ticker(+g: S.Sim) -> S.Sim:
  +c = (ui(g, 103) - 1 : U32)
  C.br(F.le(c, 0), g, +h => set(set(h, 104, (ui(h, 104) .^. 1 : U32)), 103, 8), +h => set(h, 103, c))

def thermo.mid(n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      thermo.mid(p, U.patch(fr, g, x, y, 288), g, (x + 8 : U32), y)

def thermo(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32, +w: U32, +dot: U32) -> V.Frame:
  f1 = thermo.mid(U32.to_nat(w), U.patch(fr, g, x, y, 287), g, (x + 8 : U32), y)
  U.patch(U.patch(f1, g, (x + 8 + 8 * w : U32), y, 289), g, (x + 8 + dot * 8 : U32), y, 290)

def thermo.cntr(n: Nat, fr: V.Frame, +g: S.Sim, +x: U32, +y: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      thermo.cntr(p, U.patch(fr, g, x, y, 294), g, (x + 8 : U32), y)

def border(fr: V.Frame, +g: S.Sim, +x: U32, +y: U32) -> V.Frame:
  U.patch(thermo.cntr(24n, U.patch(fr, g, (x - 8 : U32), (y + 7 : U32), 293), g, x, (y + 7 : U32)), g, (x + 192 : U32), (y + 7 : U32), 295)

def slots(n: Nat, fr: V.Frame, +g: S.Sim, +y: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      slots(p, U.write(text(117), 32n, border(fr, g, 80, y), g, 80, 80, y), g, (y + 16 : U32))

def options(fr: V.Frame, +g: S.Sim) -> V.Frame:
  f1 = U.patch(U.patch(U.patch(fr, g, 108, 15, 274), g, 235, 69, (280 + ui(g, 110) : U32)), g, 180, 53, Bool.pick(U32, U32.is_ne(ui(g, 115), 0), 277, 278))
  thermo(thermo(f1, g, 60, 133, 10, ui(g, 111)), g, 60, 101, 9, ui(g, 112))

def routine(fr: V.Frame, +g: S.Sim, +m: U32) -> V.Frame:
  U.fsel(U32.is_eq(m, 0), fr, f => U.patch(f, g, 94, 2, 252),
  f => U.fsel(U32.is_eq(m, 1), f, q => U.patch(q, g, 54, 38, 261),
  q => U.fsel(U32.is_eq(m, 2), q, z => U.patch(U.patch(z, g, 96, 14, 266), g, 54, 38, 267),
  z => U.fsel(U32.is_eq(m, 3), z, a => options(a, g),
  a => U.fsel(U32.is_eq(m, 4), a, b => U.patch(b, g, 0, 0, Bool.pick(U32, U.com(g), 251, Bool.pick(U32, retail(g), 249, 250))),
  b => U.fsel(U32.is_eq(m, 5), b, c => U.patch(c, g, 0, 0, 249),
  c => U.fsel(U32.is_eq(m, 6), c, d => thermo(thermo(U.patch(d, g, 60, 38, 284), g, 80, 80, 16, ui(g, 113)), g, 80, 112, 16, ui(g, 114)),
  d => slots(6n, U.patch(d, g, 72, 28, Bool.pick(U32, U32.is_eq(m, 7), 255, 256)), g, 54))))))))

def names(n: Nat, fr: V.Frame, +g: S.Sim, +m: U32, +i: U32, +x: U32, +y: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +l = item(g, m, i, 1)
      names(p, U.fwhen(U32.is_ne(l, 0), fr, f => U.patch(f, g, x, y, l)), g, m, (i + 1 : U32), x, (y + 16 : U32))

def menu.draw(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +m = ui(g, 101)
  +x = mx(g, m)
  +y = my(g, m)
  f1 = names(U32.to_nat(count(g, m)), routine(fr, g, m), g, m, 0, x, y)
  U.patch(f1, g, (x - 32 : U32), (y - 5 + ui(g, 102) * 16 : U32), (259 + ui(g, 104) : U32))

def nls(cs: List<&2, U32>) -> U32:
  match cs:
    case +c <> t:
      (Bool.pick(U32, U32.is_eq(c, 10), 1, 0) + nls(t) : U32)
    case []:
      0

def line.take(cs: List<&2, U32>) -> List<&2, U32>:
  match cs:
    case +c <> t:
      Bool.pick(List<&2, U32>, U32.is_eq(c, 10), [], c <> line.take(t))
    case []:
      []

def line.drop(cs: List<&2, U32>) -> List<&2, U32>:
  match cs:
    case +c <> +t:
      Bool.pick(List<&2, U32>, U32.is_eq(c, 10), t, line.drop(t))
    case []:
      []

def line.draw(fr: V.Frame, +g: S.Sim, +ln: List<&2, U32>, +y: U32) -> V.Frame:
  U.fr.let(U.strwidth(ln, fr, g, 0), f => +w => U.write(ln, 80n, f, g, (160 - w / 2 : U32), (160 - w / 2 : U32), y))

def lines(n: Nat, +cs: List<&2, U32>, fr: V.Frame, +g: S.Sim, +y: U32, +h: U32) -> V.Frame:
  match n cs:
    case 1n+p _ <> _:
      lines(p, line.drop(cs), line.draw(fr, g, line.take(cs), y), g, (y + h : U32), h)
    case _ _:
      fr

def msg.draw(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +cs = text((ui(g, 105) - 1 : U32))
  U.fr.let(U.hword(fr, g, 85, 2), f => +h => lines(64n, cs, f, g, (100 - (h * (1 + nls(cs))) / 2 : U32), h))

def draw(fr: V.Frame, +g: S.Sim) -> V.Frame:
  U.fsel(U32.is_ne(ui(g, 105), 0), fr, f => msg.draw(f, g), f => U.fwhen(U32.is_ne(ui(g, 100), 0), f, q => menu.draw(q, g)))
