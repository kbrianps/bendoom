import Base
import ./bytes.bend as B
import ./tab.bend as T
import ./wad.bend as W

type Thing is Data:
  Thing{x: U32, y: U32, angle: U32, kind: U32, flags: U32}

type Line is Data:
  Line{v1: U32, v2: U32, flags: U32, special: U32, tag: U32, front: U32, back: U32}

type Side is Data:
  Side{xoff: U32, yoff: U32, upper: String, lower: String, middle: String, sector: U32}

type Vertex is Data:
  Vertex{x: U32, y: U32}

type Seg is Data:
  Seg{v1: U32, v2: U32, angle: U32, line: U32, side: U32, offset: U32}

type Sub is Data:
  Sub{count: U32, first: U32}

type Box is Data:
  Box{top: U32, bottom: U32, left: U32, right: U32}

type Node is Data:
  Node{x: U32, y: U32, dx: U32, dy: U32, rbox: Box, lbox: Box, right: U32, left: U32}

type Sector is Data:
  Sector{floor: U32, ceil: U32, floorpic: String, ceilpic: String, light: U32, special: U32, tag: U32}

type Level is Data:
  Level{
    name: String,
    things: T.Vec<Thing>,
    lines: T.Vec<Line>,
    sides: T.Vec<Side>,
    verts: T.Vec<Vertex>,
    segs: T.Vec<Seg>,
    subs: T.Vec<Sub>,
    nodes: T.Vec<Node>,
    sectors: T.Vec<Sector>,
    reject: T.Vec<U32>,
    blockmap: T.Vec<U32>}

def s(+w: U32) -> U32:
  B.s16(w)

def things(ws: List<&2, U32>) -> List<&2, Thing>:
  match ws:
    case x <> y <> a <> k <> f <> t:
      Thing{s(x), s(y), a, k, f} <> things(t)
    case _:
      []

def lines(ws: List<&2, U32>) -> List<&2, Line>:
  match ws:
    case a <> b <> f <> sp <> tg <> fr <> bk <> t:
      Line{a, b, f, sp, tg, fr, bk} <> lines(t)
    case _:
      []

def sides(ws: List<&2, U32>) -> List<&2, Side>:
  match ws:
    case x <> y <> u0 <> u1 <> u2 <> u3 <> l0 <> l1 <> l2 <> l3 <> m0 <> m1 <> m2 <> m3 <> sc <> t:
      Side{s(x), s(y), B.name(u0, u1, u2, u3), B.name(l0, l1, l2, l3), B.name(m0, m1, m2, m3), sc} <> sides(t)
    case _:
      []

def verts(ws: List<&2, U32>) -> List<&2, Vertex>:
  match ws:
    case x <> y <> t:
      Vertex{s(x), s(y)} <> verts(t)
    case _:
      []

def segs(ws: List<&2, U32>) -> List<&2, Seg>:
  match ws:
    case a <> b <> an <> li <> sd <> of <> t:
      Seg{a, b, an, li, sd, s(of)} <> segs(t)
    case _:
      []

def subs(ws: List<&2, U32>) -> List<&2, Sub>:
  match ws:
    case c <> f <> t:
      Sub{c, f} <> subs(t)
    case _:
      []

def nodes(ws: List<&2, U32>) -> List<&2, Node>:
  match ws:
    case x <> y <> dx <> dy <> a0 <> a1 <> a2 <> a3 <> b0 <> b1 <> b2 <> b3 <> r <> l <> t:
      Node{s(x), s(y), s(dx), s(dy), Box{s(a0), s(a1), s(a2), s(a3)}, Box{s(b0), s(b1), s(b2), s(b3)}, r, l} <> nodes(t)
    case _:
      []

def sectors(ws: List<&2, U32>) -> List<&2, Sector>:
  match ws:
    case f <> c <> p0 <> p1 <> p2 <> p3 <> q0 <> q1 <> q2 <> q3 <> li <> sp <> tg <> t:
      Sector{s(f), s(c), B.name(p0, p1, p2, p3), B.name(q0, q1, q2, q3), li, sp, tg} <> sectors(t)
    case _:
      []

def parts() -> List<&2, String>:
  ["THINGS", "LINEDEFS", "SIDEDEFS", "VERTEXES", "SEGS", "SSECTORS", "NODES", "SECTORS", "REJECT", "BLOCKMAP"]

def vec(-A: Data, xs: List<&2, A>) -> T.Vec<A>:
  T.from_list(A, xs)

def build(name: String, bss: List<&2, List<&2, U32>>) -> Level:
  match bss:
    case th <> li <> si <> ve <> se <> ss <> no <> sc <> rj <> bm <> t:
      Level{name,
        vec(Thing, things(B.words(th))),
        vec(Line, lines(B.words(li))),
        vec(Side, sides(B.words(si))),
        vec(Vertex, verts(B.words(ve))),
        vec(Seg, segs(B.words(se))),
        vec(Sub, subs(B.words(ss))),
        vec(Node, nodes(B.words(no))),
        vec(Sector, sectors(B.words(sc))),
        vec(U32, rj),
        vec(U32, B.words(bm))}
    case _:
      Level{name, vec(Thing, []), vec(Line, []), vec(Side, []), vec(Vertex, []), vec(Seg, []), vec(Sub, []), vec(Node, []), vec(Sector, []), vec(U32, []), vec(U32, [])}

def load.fin(name: String, p: W.Wad & List<&2, List<&2, U32>>) -> IO(W.Wad & Level):
  (w, bss) = p
  IO.pure(W.Wad & Level, (w, build(name, bss)))

def load(w: W.Wad, +name: String) -> IO(W.Wad & Level):
  match w:
    case W.Wad{file, +d}:
      IO.bind(W.Wad & List<&2, List<&2, U32>>, W.Wad & Level,
        W.lumps(W.parts(List.take(&2, W.Lump, W.from(name, d), 11n), parts()), W.Wad{file, d}),
        p => load.fin(name, p))
