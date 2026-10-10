import Base
import ./src/render.bend as V
import ./src/draw.bend as D
import ./src/screen.bend as S
import ./src/boot.bend as B
import ./src/sys.bend as Y

def shot.out(out: String, r: Array<U32> & Array<U32>) -> IO(Unit):
  (fb, rom) = r
  Y.save(out, S.bmp(fb))

def shoot(out: String, p: B.Scene & Array<U32>) -> IO(Unit):
  (s, rom) = p
  match s:
    case B.Scene{+tb, +w}:
      shot.out(out, D.render(tb, w, B.spawn(w), rom))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> out <> t:
      IO.bind(B.Scene & Array<U32>, Unit, B.boot(path, name), s => shoot(out, s))
    case _:
      IO.die(Unit, 2, "usage: shot FILE.wad MAP OUT.bmp")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
