import Base
import ./tab.bend as T
import ./level.bend as L
import ./load.bend as D
import ./gfx.bend as G

type RSide is Data:
  RSide{xoff: U32, yoff: U32, top: U32, bottom: U32, mid: U32, sector: U32}

type RSeg is Data:
  RSeg{x1: U32, y1: U32, x2: U32, y2: U32, angle: U32, offset: U32, flags: U32, side: U32, back: U32}

type World is Data:
  World{
    sides: T.Vec<RSide>,
    segs: T.Vec<RSeg>,
    subs: T.Vec<L.Sub>,
    nodes: T.Vec<L.Node>,
    sectors: T.Vec<L.Sector>,
    texs: T.Vec<G.Tex>,
    things: T.Vec<L.Thing>}

def index(xs: List<&2, String>, +s: String, +i: U32) -> U32:
  match xs:
    case x <> t:
      Bool.pick(U32, String.eq(x, s), i, index(t, s, (i + 1 : U32)))
    case []:
      0

def tex(+names: List<&2, String>, +s: String) -> U32:
  index(names, s, 1)

def rside(+names: List<&2, String>, d: L.Side) -> RSide:
  match d:
    case L.Side{x, y, u, l, m, s}:
      RSide{(x << 16n : U32), (y << 16n : U32), tex(names, u), tex(names, l), tex(names, m), s}

def rsides(n: Nat, +sides: T.Vec<L.Side>, +names: List<&2, String>, +i: U32) -> List<&2, RSide>:
  match n:
    case 0n:
      []
    case 1n+p:
      rside(names, T.get(L.Side, sides, i, L.Side{0, 0, "", "", "", 0})) <> rsides(p, sides, names, (i + 1 : U32))

def vert(+vs: T.Vec<L.Vertex>, +i: U32) -> L.Vertex:
  T.get(L.Vertex, vs, i, L.Vertex{0, 0})

def line(+ls: T.Vec<L.Line>, +i: U32) -> L.Line:
  T.get(L.Line, ls, i, L.Line{0, 0, 0, 0, 0, 0, 0})

def side.sector.of(d: L.Side) -> U32:
  match d:
    case L.Side{x, y, u, l, m, s}:
      s

def side.sector(+sides: T.Vec<L.Side>, +i: U32) -> U32:
  side.sector.of(T.get(L.Side, sides, i, L.Side{0, 0, "", "", "", 0}))

def rseg.of(+sides: T.Vec<L.Side>, a: L.Vertex, b: L.Vertex, +an: U32, +of: U32, +sd: U32, l: L.Line) -> RSeg:
  match a b l:
    case L.Vertex{ax, ay} L.Vertex{bx, by} L.Line{v1, v2, +fl, sp, tg, +fr, +bk}:
      RSeg{(ax << 16n : U32), (ay << 16n : U32), (bx << 16n : U32), (by << 16n : U32), (an << 16n : U32), (of << 16n : U32), fl,
        Bool.pick(U32, U32.is_eq(sd, 0), fr, bk),
        Bool.pick(U32, U32.is_eq((fl .&. 4 : U32), 0), 65535, side.sector(sides, Bool.pick(U32, U32.is_eq(sd, 0), bk, fr)))}

def rseg(+vs: T.Vec<L.Vertex>, +ls: T.Vec<L.Line>, +sides: T.Vec<L.Side>, s: L.Seg) -> RSeg:
  match s:
    case L.Seg{a, b, an, li, +sd, of}:
      rseg.of(sides, vert(vs, a), vert(vs, b), an, of, sd, line(ls, li))

def rsegs(n: Nat, +segs: T.Vec<L.Seg>, +vs: T.Vec<L.Vertex>, +ls: T.Vec<L.Line>, +sides: T.Vec<L.Side>, +i: U32) -> List<&2, RSeg>:
  match n:
    case 0n:
      []
    case 1n+p:
      rseg(vs, ls, sides, T.get(L.Seg, segs, i, L.Seg{0, 0, 0, 0, 0, 0})) <> rsegs(p, segs, vs, ls, sides, (i + 1 : U32))

def build(lv: L.Level, t: D.Texs) -> World:
  match lv t:
    case L.Level{n, +th, +li, +si, +ve, +se, +ss, +no, +sc, rj, bm} D.Texs{+names, +ts}:
      World{
        T.from_list(RSide, rsides(U32.to_nat(T.size(L.Side, si)), si, names, 0)),
        T.from_list(RSeg, rsegs(U32.to_nat(T.size(L.Seg, se)), se, ve, li, si, 0)),
        ss, no, sc, ts, th}
