import Base
import ./tab.bend as T
import ./level.bend as L
import ./world.bend as R
import ./fixed.bend as F
import ./state.bend as S

def fu() -> U32:
  65536

def maxint() -> U32:
  2147483647

def minint() -> U32:
  2147483648

def maxth() -> U32:
  8192

def has(+x: U32, +b: U32) -> Bool:
  U32.is_ne((x .&. b : U32), 0)

def clr(+x: U32, +b: U32) -> U32:
  (x .&. U32.not(b) : U32)

def b2u(+b: Bool) -> U32:
  Bool.pick(U32, b, 1, 0)

def when(c: Bool, g: S.Sim, f: S.Sim -> S.Sim) -> S.Sim:
  match c:
    case True{}:
      f(g)
    case False{}:
      g

def br(c: Bool, g: S.Sim, t: S.Sim -> S.Sim, e: S.Sim -> S.Sim) -> S.Sim:
  match c:
    case True{}:
      t(g)
    case False{}:
      e(g)

def pick(-A: Data, c: Bool, t: Unit -> A, e: Unit -> A) -> A:
  match c:
    case True{}:
      t(Unit{})
    case False{}:
      e(Unit{})

def withp(+i: U32, +g: S.Sim, f: S.Sim -> S.Sim) -> S.Sim:
  +c = S.sim.cp(g)
  S.sim.cp.set(f(S.sim.cp.set(g, i)), c)

def pof(+g: S.Sim, +m: U32) -> U32:
  +p = S.m.player(g, m)
  Bool.pick(U32, U32.is_eq(p, 0), S.sim.cp(g), (p - 1 : U32))

def asmo(+g: S.Sim, +m: U32, f: S.Sim -> S.Sim) -> S.Sim:
  withp(pof(g, m), g, f)

def me(+g: S.Sim) -> U32:
  T.get(U32, S.sim.ui(g), 169, 0)

def ingame(+g: S.Sim, +i: U32) -> Bool:
  has(S.sim.ingame(g), (1 << U32.to_nat(i) : U32))

def net(+g: S.Sim) -> Bool:
  U32.is_ne(S.sim.net(g), 0)

def rnd(+g: S.Sim) -> U32:
  T.get(U32, S.mp.rndt(g), ((S.sim.rnd(g) + 1) .&. 255 : U32), 0)

def rnd.next(+g: S.Sim) -> S.Sim:
  S.sim.rnd.set(g, ((S.sim.rnd(g) + 1) .&. 255 : U32))

def halted(+g: S.Sim) -> Bool:
  U32.is_ne(S.sim.halt(g), 0)

def stop(+g: S.Sim) -> S.Sim:
  S.sim.halt.set(g, 1)

def resume(+g: S.Sim) -> S.Sim:
  S.sim.halt.set(g, 0)

def info(+g: S.Sim, +k: U32, +f: U32) -> U32:
  T.get(U32, S.mp.mi(g), (k * 23 + f : U32), 0)

def state(+g: S.Sim, +s: U32, +f: U32) -> U32:
  T.get(U32, S.mp.st(g), (s * 7 + f : U32), 0)

def th(+g: S.Sim, +id: U32) -> S.Th:
  T.get(S.Th, S.sim.ths(g), id, S.TNone{})

def th.set(+g: S.Sim, +id: U32, t: S.Th) -> S.Sim:
  S.sim.ths.set(g, T.set(S.Th, S.sim.ths(g), id, t))

def tnext(+g: S.Sim, +id: U32) -> U32:
  T.get(U32, S.sim.tn(g), id, 0)

def tprev(+g: S.Sim, +id: U32) -> U32:
  T.get(U32, S.sim.tp(g), id, 0)

def tnext.set(+g: S.Sim, +id: U32, +v: U32) -> S.Sim:
  S.sim.tn.set(g, T.set(U32, S.sim.tn(g), id, v))

def tprev.set(+g: S.Sim, +id: U32, +v: U32) -> S.Sim:
  S.sim.tp.set(g, T.set(U32, S.sim.tp(g), id, v))

def first(xs: List<&2, U32>, +z: U32) -> U32:
  match xs:
    case x <> t:
      x
    case []:
      z

def newid(+g: S.Sim) -> U32:
  first(S.sim.free(g), S.sim.next(g))

def claim(+g: S.Sim, fs: List<&2, U32>, +n: U32) -> S.Sim:
  match fs:
    case x <> t:
      S.sim.free.set(g, t)
    case []:
      S.sim.next.set(g, (n + 1 : U32))

def link(+g: S.Sim, +id: U32) -> S.Sim:
  +last = tprev(g, 0)
  +g1 = tnext.set(tnext.set(g, last, id), id, 0)
  tprev.set(tprev.set(g1, id, last), 0, id)

def add(+g: S.Sim, t: S.Th) -> S.Sim:
  +id = newid(g)
  +g1 = claim(g, S.sim.free(g), S.sim.next(g))
  link(th.set(g1, id, t), id)

def remove(+g: S.Sim, +id: U32) -> S.Sim:
  th.set(g, id, S.TDead{})

def unlink(+g: S.Sim, +id: U32) -> S.Sim:
  +nx = tnext(g, id)
  +pv = tprev(g, id)
  +g1 = tprev.set(tnext.set(g, pv, nx), nx, pv)
  S.sim.free.set(th.set(g1, id, S.TNone{}), id <> S.sim.free(g1))

def vc.bump(+g: S.Sim) -> S.Sim:
  S.sim.vc.set(g, (S.sim.vc(g) + 1 : U32))

def seen(+g: S.Sim, +l: U32) -> Bool:
  U32.is_eq(T.get(U32, S.sim.valid(g), l, 0), S.sim.vc(g))

def mark(+g: S.Sim, +l: U32) -> S.Sim:
  S.sim.valid.set(g, T.set(U32, S.sim.valid(g), l, S.sim.vc(g)))

def lspec(+g: S.Sim, +l: U32) -> U32:
  T.get(U32, S.sim.lspec(g), l, 0)

def lspec.set(+g: S.Sim, +l: U32, +v: U32) -> S.Sim:
  S.sim.lspec.set(g, T.set(U32, S.sim.lspec(g), l, v))

def link.at(+g: S.Sim, +i: U32) -> U32:
  T.get(U32, S.sim.links(g), i, 0)

def link.set(+g: S.Sim, +i: U32, +v: U32) -> S.Sim:
  S.sim.links.set(g, T.set(U32, S.sim.links(g), i, v))

def bmap(+g: S.Sim, +i: U32) -> U32:
  T.get(U32, S.mp.bmap(g), i, 65535)

def secof(+g: S.Sim, +ss: U32) -> U32:
  T.get(U32, S.mp.subsec(g), ss, 0)

def seclines(+g: S.Sim, +s: U32) -> List<&2, U32>:
  T.get(List<&2, U32>, S.mp.seclines(g), s, [])

def secbox(+g: S.Sim, +s: U32, +k: U32) -> U32:
  T.get(U32, S.mp.secbox(g), (s * 6 + k : U32), 0)

def sorg(+g: S.Sim, +s: U32, +k: U32) -> U32:
  T.get(U32, S.mp.secbox(g), (s * 6 + 4 + k : U32), 0)

def theight(+g: S.Sim, +t: U32) -> U32:
  T.get(U32, S.mp.theights(g), t, 0)

def sky() -> U32:
  4294967295
