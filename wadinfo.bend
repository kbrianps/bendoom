import Base
import ./src/wad.bend as W
import ./src/level.bend as L
import ./src/tab.bend as T
import ./src/fixed.bend as F

def mix(h: U32, v: U32) -> U32:
  (h * 31 + v : U32)

def str.go(s: String, h: U32) -> U32:
  match s:
    case SCon{Chr{c}, t}:
      str.go(t, mix(h, c))
    case SNil{}:
      mix(h, 0)

def str(h: U32, s: String) -> U32:
  str.go(s, h)

def box(h: U32, b: L.Box) -> U32:
  match b:
    case L.Box{a, c, d, e}:
      mix(mix(mix(mix(h, a), c), d), e)

def thing(h: U32, x: L.Thing) -> U32:
  match x:
    case L.Thing{a, b, c, d, e}:
      mix(mix(mix(mix(mix(h, a), b), c), d), e)

def line(h: U32, x: L.Line) -> U32:
  match x:
    case L.Line{a, b, c, d, e, f, g}:
      mix(mix(mix(mix(mix(mix(mix(h, a), b), c), d), e), f), g)

def side(h: U32, x: L.Side) -> U32:
  match x:
    case L.Side{a, b, c, d, e, f}:
      mix(str(str(str(mix(mix(h, a), b), c), d), e), f)

def vert(h: U32, x: L.Vertex) -> U32:
  match x:
    case L.Vertex{a, b}:
      mix(mix(h, F.sar(a, 16n)), F.sar(b, 16n))

def seg(h: U32, x: L.Seg) -> U32:
  match x:
    case L.Seg{a, b, c, d, e, f}:
      mix(mix(mix(mix(mix(mix(h, a), b), (c >> 16n : U32)), d), e), F.sar(f, 16n))

def sub(h: U32, x: L.Sub) -> U32:
  match x:
    case L.Sub{a, b}:
      mix(mix(h, a), b)

def child(+c: U32) -> U32:
  Bool.pick(U32, U32.is_eq((c .&. 2147483648 : U32), 0), c, (32768 .|. (c .&. 32767) : U32))

def node(h: U32, x: L.Node) -> U32:
  match x:
    case L.Node{a, b, c, d, r, l, e, f}:
      mix(mix(box(box(mix(mix(mix(mix(h, a), b), c), d), r), l), child(e)), child(f))

def sector(h: U32, x: L.Sector) -> U32:
  match x:
    case L.Sector{a, b, c, d, e, f, g}:
      mix(mix(mix(str(str(mix(mix(h, a), b), c), d), e), f), g)

def word(h: U32, x: U32) -> U32:
  mix(h, x)

def fold(~A: Data, ~f: U32 -> A -> U32, n: Nat, +v: T.Vec<A>, +i: U32, +z: A, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      fold(~A, ~f, p, v, (i + 1 : U32), z, f(h, T.get(A, v, i, z)))

def sum(~A: Data, ~f: U32 -> A -> U32, +v: T.Vec<A>, +z: A) -> String:
  +n = T.size(A, v)
  U32.show(n) ++ ":" ++ U32.show(fold(~A, ~f, U32.to_nat(n), v, 0, z, 0))

def info(lv: L.Level) -> String:
  match lv:
    case L.Level{n, th, li, si, ve, se, ss, no, sc, rj, bm}:
      n
        ++ " things " ++ sum(~L.Thing, ~thing, th, L.Thing{0, 0, 0, 0, 0})
        ++ " lines " ++ sum(~L.Line, ~line, li, L.Line{0, 0, 0, 0, 0, 0, 0})
        ++ " sides " ++ sum(~L.Side, ~side, si, L.Side{0, 0, "", "", "", 0})
        ++ " verts " ++ sum(~L.Vertex, ~vert, ve, L.Vertex{0, 0})
        ++ " segs " ++ sum(~L.Seg, ~seg, se, L.Seg{0, 0, 0, 0, 0, 0})
        ++ " subs " ++ sum(~L.Sub, ~sub, ss, L.Sub{0, 0})
        ++ " nodes " ++ sum(~L.Node, ~node, no, L.Node{0, 0, 0, 0, L.Box{0, 0, 0, 0}, L.Box{0, 0, 0, 0}, 0, 0})
        ++ " sectors " ++ sum(~L.Sector, ~sector, sc, L.Sector{0, 0, "", "", 0, 0, 0})
        ++ " reject " ++ sum(~U32, ~word, rj, 0)
        ++ " blockmap " ++ sum(~U32, ~word, bm, 0)

def each.next(p: W.Wad & L.Level, k: W.Wad -> IO(W.Wad)) -> IO(W.Wad):
  (w, lv) = p
  do IO<W.Wad>:
    IO.print(info(lv))
    k(w)

def each(ms: List<&2, W.Lump>, w: W.Wad) -> IO(W.Wad):
  match ms:
    case W.Lump{n, at, size, k} <> t:
      IO.bind(W.Wad & L.Level, W.Wad, L.load(w, n), p => each.next(p, v => each(t, v)))
    case []:
      IO.pure(W.Wad, w)

def run(w: W.Wad) -> IO(Unit):
  match w:
    case W.Wad{f, m, +d}:
      do IO<Unit>:
        w : W.Wad <- each(W.maps(d), W.Wad{f, m, d})
        W.close(w)

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> t:
      do IO<Unit>:
        w : W.Wad <- W.open(path)
        run(w)
    case _:
      IO.die(Unit, 2, "usage: wadinfo FILE.wad")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
