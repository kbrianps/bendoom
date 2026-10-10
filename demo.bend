import Base
import ./src/state.bend as S
import ./src/sim.bend as C
import ./src/boot.bend as B
import ./src/game.bend as K
import ./src/fixed.bend as F

def sx(+b: U32) -> U32:
  Bool.pick(U32, U32.is_ge(b, 128), (b - 256 : U32), b)

def signed(+v: U32) -> String:
  Bool.pick(String, F.is_neg(v), String.append("-", U32.show(F.neg(v))), U32.show(v))

def mix(+h: U32, +v: U32) -> U32:
  (h * 31 + v : U32)

def mo.hash(+g: S.Sim, +m: U32, +h: U32) -> U32:
  +h1 = mix(mix(mix(mix(h, S.m.x(g, m)), S.m.y(g, m)), S.m.z(g, m)), S.m.angle(g, m))
  mix(mix(mix(mix(h1, S.m.state(g, m)), S.m.tics(g, m)), S.m.health(g, m)), S.m.flags(g, m))

def hash(n: Nat, more: Bool, +g: S.Sim, +i: U32, +h: U32) -> U32:
  match n more:
    case 1n+p True{}:
      +nx = C.tnext(g, i)
      hash(p, U32.is_ne(nx, 0), g, nx, Bool.pick(U32, K.alive(g, i), mo.hash(g, i, h), h))
    case _ _:
      h

def count(n: Nat, more: Bool, +g: S.Sim, +i: U32, +c: U32) -> U32:
  match n more:
    case 1n+p True{}:
      +nx = C.tnext(g, i)
      count(p, U32.is_ne(nx, 0), g, nx, (c + C.b2u(K.alive(g, i)) : U32))
    case _ _:
      c

def words(xs: List<&2, String>) -> String:
  match xs:
    case x <> t:
      match t:
        case []:
          x
        case _:
          String.append(x, String.append(" ", words(t)))
    case []:
      ""

def trace(+g: S.Sim) -> String:
  +m = S.p.mo(g)
  +f = C.tnext(g, 0)
  String.append("T ", words([U32.show(S.sim.time(g)), U32.show(S.sim.rnd(g)),
    signed(F.sar(S.m.x(g, m), 16n)), signed(F.sar(S.m.y(g, m), 16n)), signed(F.sar(S.m.z(g, m), 16n)),
    U32.show(S.m.angle(g, m)), signed(S.p.health(g)),
    U32.show(count(65536n, U32.is_ne(f, 0), g, f, 0)), U32.show(hash(65536n, U32.is_ne(f, 0), g, f, 0))]))

def tic(+g: S.Sim, +f: U32, +s: U32, +t: U32, +b: U32) -> S.Sim:
  K.ticker(S.p.buttons.set(S.p.turn.set(S.p.side.set(S.p.fwd.set(g, sx(f)), sx(s)), (t << 8n : U32)), b))

def play?(xs: List<&2, U32>, +g: S.Sim) -> IO(Unit):
  match xs:
    case +f <> +s <> +t <> +b <> rest:
      play.one(U32.is_eq(f, 128), f, s, t, b, rest, g)
    case _:
      IO.pure(Unit, Unit{})

def play.one?(end: Bool, +f: U32, +s: U32, +t: U32, +b: U32, rest: List<&2, U32>, +g: S.Sim) -> IO(Unit):
  match end:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      +g1 = tic(g, f, s, t, b)
      do IO<Unit>:
        IO.print(trace(g1))
        play(rest, g1)

def start(bs: List<&2, U32>, p: S.Sim & Array<U32>) -> IO(Unit):
  (g, rom) = p
  play(List.drop(&2, U32, bs, 13n), g)

def loaded(path: String, name: String, r: File & Result<&1, &1, U32 & String, List<&2, U32>>) -> IO(Unit):
  (f, res) = r
  do IO<Unit>:
    File.close(f)
    bs : List<&2, U32> <- IO.pass(List<&2, U32>, res)
    IO.bind(S.Sim & Array<U32>, Unit, B.new(path, name), p => start(bs, p))

def run(path: String, name: String, lmp: String) -> IO(Unit):
  do IO<Unit>:
    f : File <- IO.try(File, File.open(lmp, "r"))
    r : File & Result<&1, &1, U32 & String, List<&2, U32>> <- File.read_at(f, 0, 4194304)
    loaded(path, name, r)

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> lmp <> t:
      run(path, name, lmp)
    case _:
      IO.die(Unit, 2, "usage: demo FILE.wad MAP DEMO.lmp")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
