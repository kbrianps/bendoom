import Base
import ./src/wad.bend as W
import ./src/level.bend as L
import ./src/automap.bend as A
import ./src/bmp.bend as P
import ./src/sys.bend as Y

def draw(out: String, pal: List<&2, U32>, p: W.Wad & L.Level) -> IO(Unit):
  (w, lv) = p
  do IO<Unit>:
    W.close(w)
    Y.save(out, P.encode(A.size(), A.size(), P.own(Array.to_list(~U32, A.render(lv, A.palette(pal))))))

def level(+name: String, out: String, p: W.Wad & List<&2, U32>) -> IO(Unit):
  (w, pal) = p
  IO.bind(W.Wad & L.Level, Unit, L.load(w, name), q => draw(out, pal, q))

def run(+name: String, out: String, w: W.Wad) -> IO(Unit):
  match w:
    case W.Wad{f, +d}:
      IO.bind(W.Wad & List<&2, U32>, Unit, W.lump(W.Wad{f, d}, W.part(d, "PLAYPAL")), p => level(name, out, p))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> out <> t:
      do IO<Unit>:
        w : W.Wad <- W.open(path)
        run(name, out, w)
    case _:
      IO.die(Unit, 2, "usage: automap FILE.wad MAP OUT.bmp")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
