import Base
import ./src/hud.bend as U
import ./src/state.bend as S
import ./src/draw.bend as D
import ./src/screen.bend as C
import ./src/boot.bend as B
import ./src/sys.bend as Y

def shot.out(out: String, r: Array<U32> & Array<U32>) -> IO(Unit):
  (fb, rom) = r
  Y.save(out, C.bmp(fb))

def shoot(out: String, p: S.Sim & Array<U32>) -> IO(Unit):
  (+g, rom) = p
  shot.out(out, U.render(g, rom))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> out <> t:
      IO.bind(S.Sim & Array<U32>, Unit, B.new(path, name), s => shoot(out, s))
    case _:
      IO.die(Unit, 2, "usage: shot FILE.wad MAP OUT.bmp")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
