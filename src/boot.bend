import Base
import ./wad.bend as W
import ./level.bend as L
import ./load.bend as D
import ./tab.bend as T
import ./world.bend as R
import ./render.bend as V
import ./automap.bend as A

type Scene is Data:
  Scene{tabs: V.Tabs, world: R.World}

def start(ts: List<&2, L.Thing>) -> L.Thing:
  match ts:
    case L.Thing{x, y, a, +k, f} <> t:
      Bool.pick(L.Thing, U32.is_eq(k, 1), L.Thing{x, y, a, k, f}, start(t))
    case []:
      L.Thing{0, 0, 0, 1, 0}

def things(n: Nat, +v: T.Vec<L.Thing>, +i: U32) -> List<&2, L.Thing>:
  match n:
    case 0n:
      []
    case 1n+p:
      T.get(L.Thing, v, i, L.Thing{0, 0, 0, 0, 0}) <> things(p, v, (i + 1 : U32))

def eye() -> U32:
  2686976

def view(+w: R.World, t: L.Thing) -> V.View:
  match t:
    case L.Thing{+x, +y, a, k, f}:
      V.View{(x << 16n : U32), (y << 16n : U32), (V.floor.at(w, (x << 16n : U32), (y << 16n : U32)) + eye() : U32), (536870912 * (a / 45) : U32), 0}

def spawn(+w: R.World) -> V.View:
  match w:
    case R.World{si, sg, su, no, sc, tx, +th}:
      view(w, start(things(U32.to_nat(T.size(L.Thing, th)), th, 0)))

def textured(+lv: L.Level, +tb: V.Tabs, p: W.Wad & D.Texs) -> IO(Scene):
  (w, ts) = p
  do IO<Scene>:
    W.close(w)
    IO.pure(Scene, Scene{tb, R.build(lv, ts)})

def level(+pal: List<&2, U32>, +cm: List<&2, U32>, p: W.Wad & L.Level) -> IO(Scene):
  (w, lv) = p
  match lv:
    case L.Level{n, th, li, +si, ve, se, ss, no, sc, rj, bm}:
      IO.bind(W.Wad & D.Texs, Scene, D.textures(w, si), q => textured(lv, V.tabs(A.palette(pal), cm), q))

def got(+name: String, p: W.Wad & List<&2, List<&2, U32>>) -> IO(Scene):
  (w, bss) = p
  match bss:
    case pal <> cm <> t:
      IO.bind(W.Wad & L.Level, Scene, L.load(w, name), q => level(pal, cm, q))
    case _:
      IO.die(Scene, 1, "no PLAYPAL or COLORMAP")

def boot(path: String, +name: String) -> IO(Scene):
  do IO<Scene>:
    w : W.Wad <- W.open(path)
    p : W.Wad & List<&2, List<&2, U32>> <- W.get(w, ["PLAYPAL", "COLORMAP"])
    got(name, p)
