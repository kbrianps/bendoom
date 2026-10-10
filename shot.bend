import Base
import ./src/render.bend as V
import ./src/screen.bend as S
import ./src/boot.bend as B
import ./src/sys.bend as Y

def shoot(out: String, s: B.Scene) -> IO(Unit):
  match s:
    case B.Scene{+tb, +w}:
      Y.save(out, S.bmp(V.render(tb, w, B.spawn(w))))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> out <> t:
      IO.bind(B.Scene, Unit, B.boot(path, name), s => shoot(out, s))
    case _:
      IO.die(Unit, 2, "usage: shot FILE.wad MAP OUT.bmp")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
