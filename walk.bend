import Base
import ./src/state.bend as S
import ./src/draw.bend as D
import ./src/screen.bend as C
import ./src/boot.bend as B
import ./src/play.bend as P
import ./src/sys.bend as Y
import ./src/fixed.bend as F
import ./src/game.bend as M

def num(+s: String) -> U32:
  Bool.pick(U32, String.eq(String.take(s, 1n), "-"),
    (0 - Maybe.default(&2, U32, U32.read(String.drop(s, 1n)), 0) : U32),
    Maybe.default(&2, U32, U32.read(s), 0))

def place(+g: S.Sim, +x: U32, +y: U32, +a: U32) -> S.Sim:
  +m = S.p.mo(g)
  +g1 = M.teleportmove(g, m, (x << 16n : U32), (y << 16n : U32))
  +g2 = S.m.z.set(S.m.angle.set(g1, m, (a / 45 * 536870912 : U32)), m, S.m.floorz(g1, m))
  S.p.viewz.set(g2, (S.m.z(g2, m) + S.p.viewheight(g2) : U32))

def run(cmds: List<String>, +g: S.Sim) -> S.Sim:
  match cmds:
    case "at" <> x <> y <> a <> t:
      run(t, place(g, num(x), num(y), num(a)))
    case n <> k <> t:
      run(t, P.run.of(P.runs(U32.to_nat(num(n)), True{}, g, num(k), 0)))
    case _:
      g

def shot.out(out: String, r: Array<U32> & Array<U32>) -> IO(Unit):
  (fb, rom) = r
  Y.save(out, C.bmp(fb))

def shoot(out: String, cmds: List<String>, p: S.Sim & Array<U32>) -> IO(Unit):
  (+g0, rom) = p
  +g = run(cmds, g0)
  +m = S.p.mo(g)
  do IO<Unit>:
    IO.print(String.append(U32.show(F.sar(S.m.x(g, m), 16n)), String.append(" ", String.append(U32.show(F.sar(S.m.y(g, m), 16n)), String.append(" ", String.append(U32.show(F.sar(S.m.z(g, m), 16n)), String.append(" ", String.append(U32.show(S.sim.exit(g)), String.append(" hp=", U32.show(S.p.health(g)))))))))))
    shot.out(out, D.render(S.mp.tb(g), S.sim.w(g), B.view(g), rom))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> out <> t:
      IO.bind(S.Sim & Array<U32>, Unit, B.new(path, name), s => shoot(out, t, s))
    case _:
      IO.die(Unit, 2, "usage: walk FILE.wad MAP OUT.bmp [TICS KEYS]...")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
