import Base
import ./state.bend as S
import ./sim.bend as C
import ./spec.bend as X
import ./move.bend as M
import ./user.bend as U

def run.of(+g: S.Sim, +id: U32, t: S.Th) -> S.Sim:
  match t:
    case S.TDead{}:
      C.unlink(g, id)
    case S.TMo{}:
      M.mobjthinker(g, id)
    case S.TNone{}:
      g
    case _:
      X.think(g, id, C.th(g, id))

def runthinkers.go(n: Nat, more: Bool, +g: S.Sim, +id: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = run.of(g, id, C.th(g, id))
      +nx = C.tnext(g1, id)
      runthinkers.go(p, U32.is_ne(nx, 0), g1, nx)
    case _ _:
      g

def runthinkers(+g: S.Sim) -> S.Sim:
  +first = C.tnext(g, 0)
  runthinkers.go(65536n, U32.is_ne(first, 0), g, first)

def ticker(+g: S.Sim) -> S.Sim:
  +g1 = X.update(runthinkers(U.playerthink(g)))
  S.sim.time.set(g1, (S.sim.time(g1) + 1 : U32))
