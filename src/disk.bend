import Base
import ./tab.bend as T
import ./state.bend as S
import ./sim.bend as C
import ./hud.bend as U
import ./sys.bend as Y
import ./boot.bend as B
import ./setup.bend as Su
import ./flow.bend as Q
import ./dsg.bend as D

def slotname(+i: U32) -> String:
  String.append("doomsav", String.append(U32.show(i), ".dsg"))

def read.ok(r: Result<&1, &1, U32 & String, List<&2, U32>>) -> List<&2, U32>:
  match r:
    case Done{v}:
      v
    case Fail{e}:
      []

def read.got(p: File & Result<&1, &1, U32 & String, List<&2, U32>>) -> IO(List<&2, U32>):
  (f, r) = p
  +xs = read.ok(r)
  IO.bind(Unit, List<&2, U32>, File.close(f), u => IO.pure(List<&2, U32>, xs))

def read.opened(r: Result<&1, &1, U32 & String, File>, +max: U32) -> IO(List<&2, U32>):
  match r:
    case Done{f}:
      IO.bind(File & Result<&1, &1, U32 & String, List<&2, U32>>, List<&2, U32>, File.read_at(f, 0, max), p => read.got(p))
    case Fail{e}:
      IO.pure(List<&2, U32>, [])

def read(+path: String, +max: U32) -> IO(List<&2, U32>):
  IO.bind(Result<&1, &1, U32 & String, File>, List<&2, U32>, File.open(path, "r"), r => read.opened(r, max))

def slot.flat(n: Nat, +v: T.Vec<U32>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      T.get(U32, v, i, 0) <> slot.flat(p, v, (i + 1 : U32))

def slot.put(n: Nat, +v: T.Vec<U32>, +b: U32, cs: List<&2, U32>) -> T.Vec<U32>:
  match n cs:
    case 1n+p +c <> t:
      slot.put(p, T.set(U32, v, b, c), (b + 1 : U32), t)
    case 1n+p _:
      slot.put(p, T.set(U32, v, b, 0), (b + 1 : U32), [])
    case _ _:
      v

def slot.set(+g: S.Sim, +i: U32, +st: U32, +cs: List<&2, U32>) -> S.Sim:
  +b = (i * 25 : U32)
  S.sim.saves.set(g, slot.put(24n, T.set(U32, S.sim.saves(g), b, st), (b + 1 : U32), cs))

def strings.one(+g: S.Sim, +i: U32, +bs: List<&2, U32>) -> S.Sim:
  +ws = T.from_list(U32, bs)
  +ok = D.ok(ws)
  slot.set(g, i, C.b2u(ok), Bool.pick(List<&2, U32>, ok, D.desc(ws), []))

def strings.go?(n: Nat, +g: S.Sim, +i: U32) -> IO(S.Sim):
  match n:
    case 0n:
      IO.pure(S.Sim, S.sim.act.set(g, 0))
    case 1n+p:
      IO.bind(List<&2, U32>, S.Sim, read(slotname(i), 128), +bs => strings.go(p, strings.one(g, i, bs), (i + 1 : U32)))

def strings(+g: S.Sim) -> IO(S.Sim):
  strings.go(6n, g, 0)

def desc(+g: S.Sim, +i: U32) -> List<&2, U32>:
  slot.flat(24n, S.sim.saves(g), (i * 25 + 1 : U32))

def write(+g: S.Sim) -> IO(S.Sim):
  +i = U.ui(g, 90)
  +g1 = S.sim.saves.set(g, T.set(U32, S.sim.saves(g), (i * 25 : U32), 1))
  IO.bind(Unit, S.Sim, Y.save(slotname(i), D.write(g1, desc(g1, i))), u => IO.pure(S.Sim, S.p.message.set(S.sim.act.set(g1, 0), 69)))

def carry(+g: S.Sim, +ws: T.Vec<U32>) -> T.Vec<U32>:
  T.from_list(U32, [0, D.skill(ws), 0, 1, 0, 0, 0, 4294967295, 4294967295, 0, 0, D.ingame(ws), S.sim.net(g)])

def reloaded(+old: S.Sim, p: S.Sim & Array<U32>) -> IO(S.Sim & Array<U32>):
  (+g, rom) = p
  IO.pure(S.Sim & Array<U32>, (Q.adopt(old, g), rom))

def loaded(+old: S.Sim, +ws: T.Vec<U32>, p: S.Sim & Array<U32>) -> IO(S.Sim & Array<U32>):
  (+g, rom) = p
  +g1 = Q.adopt(old, D.read(g, ws))
  +g2 = U.ui.set(U.ui.set(U.ui.set(U.ui.set(U.ui.set(S.sim.act.set(g1, 0), 100, 0), 127, 0), 118, 1), 140, 0), 129, 0)
  IO.pure(S.Sim & Array<U32>, (g2, rom))

def load.go(ok: Bool, +g: S.Sim, +path: String, +ws: T.Vec<U32>) -> IO(S.Sim & Array<U32>):
  match ok:
    case True{}:
      IO.bind(S.Sim & Array<U32>, S.Sim & Array<U32>, B.boot(path, Q.mapname(U.com(g), D.episode(ws), D.map(ws)), Su.newplayer(), carry(g, ws)), p => loaded(g, ws, p))
    case False{}:
      +g1 = S.sim.act.set(g, 0)
      IO.bind(S.Sim & Array<U32>, S.Sim & Array<U32>, B.boot(path, Q.target(g1), Q.player(g1), Q.carry(g1)), p => reloaded(g1, p))

def load.read(+g: S.Sim, +path: String, +bs: List<&2, U32>) -> IO(S.Sim & Array<U32>):
  +ws = T.from_list(U32, bs)
  load.go(D.ok(ws), g, path, ws)

def load(+g: S.Sim, +path: String) -> IO(S.Sim & Array<U32>):
  IO.bind(List<&2, U32>, S.Sim & Array<U32>, read(slotname(U.ui(g, 90)), 16777216), +bs => load.read(g, path, bs))
