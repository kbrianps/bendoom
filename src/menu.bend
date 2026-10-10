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

def beep(+g: S.Sim, +sfx: U32) -> S.Sim:
  S.sim.snd.set(g, sfx <> S.sim.snd(g))

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
  set(set(set(set(set(set(set(S.sim.act.set(g, 2), 120, ep), 121, sk), 127, 0), 128, 1), 148, 1), 149, 0), 169, 0)

def quitmsg(+g: S.Sim) -> S.Sim:
  startmsg(g, (Bool.pick(U32, U.com(g), 103, 95) + S.sim.tic(g) % 8 : U32), 3, 1)

def endgame(+g: S.Sim) -> S.Sim:
  C.br(U32.is_ne(ui(g, 118), 0), g, +h => startmsg(h, 112, 2, 1), +h => beep(h, 34))

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
  C.br(U32.is_eq(ui(g, 118), 0), g, +h => startmsg(h, 116, 0, 0), +h => C.when(U32.is_eq(S.sim.gs(h), 0), h, +k => setup(S.sim.act.set(k, 5), 8)))

def loadgame(+g: S.Sim) -> S.Sim:
  C.br(C.net(g), g, +h => startmsg(h, 119, 0, 0), +h => setup(S.sim.act.set(h, 5), 7))

def slot(+g: S.Sim, +i: U32, +k: U32) -> U32:
  T.get(U32, S.sim.saves(g), (i * 25 + k : U32), 0)

def slot.set(+g: S.Sim, +i: U32, +k: U32, +v: U32) -> S.Sim:
  S.sim.saves.set(g, T.set(U32, S.sim.saves(g), (i * 25 + k : U32), v))

def chars(n: Nat, +g: S.Sim, +i: U32, +k: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      +c = slot(g, i, k)
      Bool.pick(List<&2, U32>, U32.is_eq(c, 0), [], c <> chars(p, g, i, (k + 1 : U32)))

def str(+g: S.Sim, +i: U32) -> List<&2, U32>:
  chars(24n, g, i, 1)

def copy(n: Nat, +g: S.Sim, +from: U32, +to: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      copy(p, S.sim.saves.set(g, T.set(U32, S.sim.saves(g), to, T.get(U32, S.sim.saves(g), from, 0))), (from + 1 : U32), (to + 1 : U32))

def blank(n: Nat, +g: S.Sim, +i: U32, +k: U32) -> S.Sim:
  match n:
    case 0n:
      g
    case 1n+p:
      blank(p, slot.set(g, i, k, 0), i, (k + 1 : U32))

def saveselect(+g: S.Sim, +i: U32) -> S.Sim:
  +g1 = copy(24n, set(set(g, 89, 1), 90, i), (i * 25 + 1 : U32), 150)
  +g2 = C.when(U32.is_eq(slot(g1, i, 0), 0), g1, +h => blank(24n, h, i, 1))
  S.sim.saves.set(g2, T.set(U32, S.sim.saves(g2), 174, U32.from_nat(List.length(&2, U32, str(g2, i)))))

def dosave(+g: S.Sim, +i: U32) -> S.Sim:
  +g1 = clear(S.sim.act.set(set(g, 90, i), 7))
  C.when(U32.is_eq(ui(g1, 126), 4294967294), g1, +h => set(h, 126, i))

def doload(+g: S.Sim, +i: U32) -> S.Sim:
  clear(S.sim.act.set(set(g, 90, i), 6))

def episode(+g: S.Sim, +choice: U32) -> S.Sim:
  +c = Bool.pick(U32, Bool.and(U32.is_eq(U.mode(g), 1), U32.is_gt(choice, 2)), 0, choice)
  C.br(Bool.and(U32.is_eq(U.mode(g), 0), U32.is_ne(choice, 0)), g, +h => setup(startmsg(h, 113, 0, 0), 4), +h => setup(set(h, 109, c), 2))

def skill(+g: S.Sim, +choice: U32) -> S.Sim:
  C.br(U32.is_eq(choice, 4), g, +h => startmsg(h, 111, 1, 1), +h => clear(newgame(h, choice, (ui(h, 109) + 1 : U32))))

def route(+g: S.Sim, +r: U32, +choice: U32) -> S.Sim:
  C.br(U32.is_eq(r, 1), g, +h => setup(h, Bool.pick(U32, U.com(h), 2, 1)),
  +h => C.br(U32.is_eq(r, 2), h, +k => setup(k, 3),
  +h => C.br(U32.is_eq(r, 3), h, +k => loadgame(k),
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
  +h => C.br(U32.is_eq(r, 18), h, +k => slider(k, 114, choice, 15),
  +h => C.br(U32.is_eq(r, 19), h, +k => doload(k, choice),
  +h => C.when(U32.is_eq(r, 20), h, +k => saveselect(k, choice)))))))))))))))))))))

def msg.route(+g: S.Sim, +r: U32, +key: U32) -> S.Sim:
  +yes = U32.is_eq(key, 121)
  C.br(Bool.and(yes, U32.is_eq(r, 1)), g, +h => clear(newgame(h, 4, (ui(h, 109) + 1 : U32))),
    +h => C.br(Bool.and(yes, U32.is_eq(r, 2)), h, +k => title(clear(last.on(k))),
      +k => C.br(Bool.and(yes, U32.is_eq(r, 3)), k, +q => set(q, 119, 1),
        +q => C.br(Bool.and(yes, U32.is_eq(r, 4)), q, +z => dosave(z, ui(z, 126)),
          +z => C.when(Bool.and(yes, U32.is_eq(r, 5)), z, +w => doload(w, ui(w, 126)))))))

def msg.key(+g: S.Sim, +key: U32) -> S.Sim:
  +ok = Bool.or(U32.is_eq(ui(g, 106), 0), Bool.or(Bool.or(U32.is_eq(key, 32), U32.is_eq(key, 27)), Bool.or(U32.is_eq(key, 121), U32.is_eq(key, 110))))
  C.br(ok, g, +h => beep(clear(msg.route(set(set(h, 100, ui(h, 108)), 105, 0), ui(h, 107), key)), 24), +h => pass(h))

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
  Bool.pick(S.Sim, U32.is_eq(j, none()), pass(g), beep(set(g, 102, j), 19))

def status(+g: S.Sim, +m: U32, +i: U32) -> U32:
  Bool.pick(U32, Bool.and(U32.is_eq(m, 7), U32.is_lt(i, 6)), slot(g, i, 0), item(g, m, i, 0))

def menu.key(+g: S.Sim, +key: U32, +ch: U32) -> S.Sim:
  +m = ui(g, 101)
  +i = ui(g, 102)
  +st = status(g, m, i)
  +r = item(g, m, i, 2)
  +cnt = count(g, m)
  C.br(U32.is_eq(key, 63233), g, +h => beep(set(h, 102, down(8n, h, m, i)), 19),
  +h => C.br(U32.is_eq(key, 63232), h, +k => beep(set(k, 102, up(8n, k, m, i)), 19),
  +h => C.br(U32.is_eq(key, 63234), h, +k => C.when(Bool.and(U32.is_ne(r, 0), U32.is_eq(st, 2)), k, +q => route(beep(q, 22), r, 0)),
  +h => C.br(U32.is_eq(key, 63235), h, +k => C.when(Bool.and(U32.is_ne(r, 0), U32.is_eq(st, 2)), k, +q => route(beep(q, 22), r, 1)),
  +h => C.br(U32.is_eq(key, 13), h, +k => C.when(Bool.and(U32.is_ne(r, 0), U32.is_ne(st, 0)), k, +q => beep(route(last.on(q), r, Bool.pick(U32, U32.is_eq(st, 2), 1, i)), Bool.pick(U32, U32.is_eq(st, 2), 22, 1))),
  +h => C.br(U32.is_eq(key, 27), h, +k => beep(clear(last.on(k)), 24),
  +h => C.br(U32.is_eq(key, 127), h, +k => C.when(U32.is_ne(prev(k, m), none()), last.on(k), +q => beep(setup(q, prev(q, m)), 23)),
  +h => C.br(U32.is_ne(ch, 0), h, +k => found(k, alpha(U32.to_nat(cnt), k, m, (i + 1 : U32), cnt, ch)), +k => pass(k)))))))))

def fkey(+g: S.Sim, +f: U32) -> S.Sim:
  C.br(U32.is_eq(f, 0), g, +h => set(set(set(startcp(h), 97, 1), 101, Bool.pick(U32, retail(h), 5, 4)), 102, 0),
  +h => C.br(U32.is_eq(f, 1), h, +k => savegame(startcp(k)),
  +h => C.br(U32.is_eq(f, 2), h, +k => loadgame(startcp(k)),
  +h => C.br(U32.is_eq(f, 3), h, +k => set(set(startcp(k), 101, 6), 102, 0),
  +h => C.br(U32.is_eq(f, 4), h, +k => detail(k),
  +h => C.br(U32.is_eq(f, 5), h, +k => C.br(U32.is_eq(ui(k, 118), 0), k, +w => beep(w, 34), +w => C.when(U32.is_eq(S.sim.gs(w), 0), w, +q => C.br(F.lt(ui(q, 126), 0), q, +z => set(setup(S.sim.act.set(startcp(z), 5), 8), 126, 4294967294), +z => startmsg(z, 121, 4, 1)))),
  +h => C.br(U32.is_eq(f, 6), h, +k => endgame(k),
  +h => C.br(U32.is_eq(f, 7), h, +k => messages(k),
  +h => C.br(U32.is_eq(f, 8), h, +k => C.br(C.net(k), k, +q => startmsg(q, 120, 0, 0), +q => C.br(F.lt(ui(q, 126), 0), q, +z => startmsg(z, 118, 0, 0), +z => startmsg(z, 123, 5, 1))),
  +h => C.br(U32.is_eq(f, 9), h, +k => quitmsg(k), +k => pass(k)))))))))))

def idle.key(+g: S.Sim, +key: U32) -> S.Sim:
  C.br(Bool.or(U32.is_eq(key, 45), U32.is_eq(key, 61)), g, +h => C.br(U32.is_ne(ui(h, 140), 0), h, +k => pass(k), +k => beep(slider(k, 112, Bool.pick(U32, U32.is_eq(key, 61), 1, 0), 8), 22)),
    +h => C.br(Bool.and(U32.is_ge(key, 63236), U32.is_le(key, 63245)), h, +k => fkey(beep(k, 23), (key - 63236 : U32)),
      +k => C.br(U32.is_eq(key, 27), k, +q => beep(startcp(q), 23), +q => pass(q))))

def upper(+c: U32) -> U32:
  Bool.pick(U32, Bool.and(U32.is_ge(c, 97), U32.is_le(c, 122)), (c - 32 : U32), c)

def cnt.set(+g: S.Sim, +v: U32) -> S.Sim:
  S.sim.saves.set(g, T.set(U32, S.sim.saves(g), 174, v))

def typed(+g: S.Sim, +c: U32) -> S.Sim:
  +i = ui(g, 90)
  +n = T.get(U32, S.sim.saves(g), 174, 0)
  +ok = Bool.and(Bool.or(U32.is_eq(c, 32), Bool.and(U32.is_ge(c, 33), U32.is_le(c, 95))), U32.is_lt(n, 23))
  C.when(ok, g, +z => cnt.set(slot.set(z, i, (n + 1 : U32), c), (n + 1 : U32)))

def save.key(+g: S.Sim, +key: U32) -> S.Sim:
  +i = ui(g, 90)
  +n = T.get(U32, S.sim.saves(g), 174, 0)
  C.br(U32.is_eq(key, 127), g, +h => C.when(U32.is_gt(n, 0), h, +k => cnt.set(slot.set(k, i, n, 0), (n - 1 : U32))),
    +h => C.br(U32.is_eq(key, 27), h, +k => set(copy(24n, k, 150, (i * 25 + 1 : U32)), 89, 0),
      +k => C.br(U32.is_eq(key, 13), k, +q => C.when(U32.is_ne(slot(q, i, 1), 0), set(q, 89, 0), +z => dosave(z, i)),
        +q => C.when(U32.is_lt(key, 128), q, +z => typed(z, upper(key))))))

def respond.go(+g: S.Sim, +key: U32, +ch: U32) -> S.Sim:
  C.br(U32.is_ne(ui(g, 105), 0), set(g, 199, 1), +h => msg.key(h, key),
    +h => C.br(U32.is_eq(ui(h, 100), 0), h, +k => idle.key(k, key), +k => menu.key(k, key, ch)))

def respond(+g: S.Sim, +key: U32) -> S.Sim:
  +ch = Bool.pick(U32, U32.is_lt(key, 128), key, 0)
  C.br(U32.is_ne(ui(g, 89), 0), set(g, 199, 1), +h => save.key(h, key),
    +h => respond.go(h, key, ch))

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

def label(+g: S.Sim, +i: U32) -> List<&2, U32>:
  Bool.pick(List<&2, U32>, Bool.or(U32.is_ne(slot(g, i, 0), 0), Bool.and(U32.is_ne(ui(g, 89), 0), U32.is_eq(ui(g, 90), i))), str(g, i), text(117))

def slots(n: Nat, fr: V.Frame, +g: S.Sim, +i: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      +y = (54 + 16 * i : U32)
      slots(p, U.write(label(g, i), 32n, border(fr, g, 80, y), g, 80, 80, y), g, (i + 1 : U32))

def cursor(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +i = ui(g, 90)
  U.fwhen(U32.is_ne(ui(g, 89), 0), fr, f => U.fr.let(U.strwidth(str(g, i), f, g, 0), q => +w => U.write([95], 2n, q, g, (80 + w : U32), (80 + w : U32), (54 + 16 * i : U32))))

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
  d => cursor(slots(6n, U.patch(d, g, 72, 28, Bool.pick(U32, U32.is_eq(m, 7), 255, 256)), g, 0), g))))))))

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

def msg.text(+g: S.Sim, +t: U32) -> List<&2, U32>:
  Bool.pick(List<&2, U32>, Bool.or(U32.is_eq(t, 121), U32.is_eq(t, 123)), List.append(&2, U32, text(t), List.append(&2, U32, str(g, ui(g, 126)), text((t + 1 : U32)))), text(t))

def msg.draw(fr: V.Frame, +g: S.Sim) -> V.Frame:
  +cs = msg.text(g, (ui(g, 105) - 1 : U32))
  U.fr.let(U.hword(fr, g, 85, 2), f => +h => lines(64n, cs, f, g, (100 - (h * (1 + nls(cs))) / 2 : U32), h))

def draw(fr: V.Frame, +g: S.Sim) -> V.Frame:
  U.fsel(U32.is_ne(ui(g, 105), 0), fr, f => msg.draw(f, g), f => U.fwhen(U32.is_ne(ui(g, 100), 0), f, q => menu.draw(q, g)))
