import Base
import ./bytes.bend as B
import ./tab.bend as T
import ./wad.bend as W
import ./fixed.bend as F
import ./tables.bend as X
import ./inflate.bend as Z

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

def things.go(ws: List<&2, U32>, acc: List<&2, Thing>) -> List<&2, Thing>:
  match ws:
    case x <> y <> a <> k <> f <> t:
      things.go(t, Thing{s(x), s(y), a, k, f} <> acc)
    case _:
      List.reverse(&2, Thing, acc)

def things(ws: List<&2, U32>) -> List<&2, Thing>:
  things.go(ws, [])

def lines.go(ws: List<&2, U32>, acc: List<&2, Line>) -> List<&2, Line>:
  match ws:
    case a <> b <> f <> sp <> tg <> fr <> bk <> t:
      lines.go(t, Line{a, b, f, sp, tg, fr, bk} <> acc)
    case _:
      List.reverse(&2, Line, acc)

def lines(ws: List<&2, U32>) -> List<&2, Line>:
  lines.go(ws, [])

def sides.go(ws: List<&2, U32>, acc: List<&2, Side>) -> List<&2, Side>:
  match ws:
    case x <> y <> u0 <> u1 <> u2 <> u3 <> l0 <> l1 <> l2 <> l3 <> m0 <> m1 <> m2 <> m3 <> sc <> t:
      sides.go(t, Side{s(x), s(y), B.name(u0, u1, u2, u3), B.name(l0, l1, l2, l3), B.name(m0, m1, m2, m3), sc} <> acc)
    case _:
      List.reverse(&2, Side, acc)

def sides(ws: List<&2, U32>) -> List<&2, Side>:
  sides.go(ws, [])

def verts.go(ws: List<&2, U32>, acc: List<&2, Vertex>) -> List<&2, Vertex>:
  match ws:
    case x <> y <> t:
      verts.go(t, Vertex{(s(x) << 16n : U32), (s(y) << 16n : U32)} <> acc)
    case _:
      List.reverse(&2, Vertex, acc)

def verts(ws: List<&2, U32>) -> List<&2, Vertex>:
  verts.go(ws, [])

def segs.go(ws: List<&2, U32>, acc: List<&2, Seg>) -> List<&2, Seg>:
  match ws:
    case a <> b <> an <> li <> sd <> of <> t:
      segs.go(t, Seg{a, b, (an << 16n : U32), li, sd, (s(of) << 16n : U32)} <> acc)
    case _:
      List.reverse(&2, Seg, acc)

def segs(ws: List<&2, U32>) -> List<&2, Seg>:
  segs.go(ws, [])

def subs.go(ws: List<&2, U32>, acc: List<&2, Sub>) -> List<&2, Sub>:
  match ws:
    case c <> f <> t:
      subs.go(t, Sub{c, f} <> acc)
    case _:
      List.reverse(&2, Sub, acc)

def subs(ws: List<&2, U32>) -> List<&2, Sub>:
  subs.go(ws, [])

def child(+c: U32) -> U32:
  Bool.pick(U32, U32.is_eq((c .&. 32768 : U32), 0), c, (2147483648 .|. (c .&. 32767) : U32))

def nodes.go(ws: List<&2, U32>, acc: List<&2, Node>) -> List<&2, Node>:
  match ws:
    case x <> y <> dx <> dy <> a0 <> a1 <> a2 <> a3 <> b0 <> b1 <> b2 <> b3 <> r <> l <> t:
      nodes.go(t, Node{s(x), s(y), s(dx), s(dy), Box{s(a0), s(a1), s(a2), s(a3)}, Box{s(b0), s(b1), s(b2), s(b3)}, child(r), child(l)} <> acc)
    case _:
      List.reverse(&2, Node, acc)

def nodes(ws: List<&2, U32>) -> List<&2, Node>:
  nodes.go(ws, [])

def sectors.go(ws: List<&2, U32>, acc: List<&2, Sector>) -> List<&2, Sector>:
  match ws:
    case f <> c <> p0 <> p1 <> p2 <> p3 <> q0 <> q1 <> q2 <> q3 <> li <> sp <> tg <> t:
      sectors.go(t, Sector{s(f), s(c), B.name(p0, p1, p2, p3), B.name(q0, q1, q2, q3), li, sp, tg} <> acc)
    case _:
      List.reverse(&2, Sector, acc)

def sectors(ws: List<&2, U32>) -> List<&2, Sector>:
  sectors.go(ws, [])

def parts() -> List<&2, String>:
  ["THINGS", "LINEDEFS", "SIDEDEFS", "VERTEXES", "SEGS", "SSECTORS", "NODES", "SECTORS", "REJECT", "BLOCKMAP"]

def vec(-A: Data, xs: List<&2, A>) -> T.Vec<A>:
  T.from_list(A, xs)

def le4(+a: U32, +b: U32, +c: U32, +d: U32) -> U32:
  (a .|. (b << 8n) .|. (c << 16n) .|. (d << 24n) : U32)

def le2(+a: U32, +b: U32) -> U32:
  s((a .|. (b << 8n) : U32))

def word(+bs: List<&2, U32>) -> U32:
  match bs:
    case a <> b <> c <> d <> t:
      le4(a, b, c, d)
    case _:
      0

def at(+bs: List<&2, U32>, +n: U32) -> List<&2, U32>:
  List.drop(&2, U32, bs, U32.to_nat(n))

def xverts.go(n: Nat, bs: List<&2, U32>, acc: List<&2, Vertex>) -> List<&2, Vertex>:
  match n bs:
    case 1n+p a <> b <> c <> d <> e <> f <> g <> h <> t:
      xverts.go(p, t, Vertex{le4(a, b, c, d), le4(e, f, g, h)} <> acc)
    case _ _:
      List.reverse(&2, Vertex, acc)

def xverts(n: Nat, bs: List<&2, U32>) -> List<&2, Vertex>:
  xverts.go(n, bs, [])

def xsubs.go(n: Nat, bs: List<&2, U32>, +first: U32, acc: List<&2, Sub>) -> List<&2, Sub>:
  match n bs:
    case 1n+p +a <> +b <> +c <> +d <> t:
      xsubs.go(p, t, (first + le4(a, b, c, d) : U32), Sub{le4(a, b, c, d), first} <> acc)
    case _ _:
      List.reverse(&2, Sub, acc)

def xsubs(n: Nat, bs: List<&2, U32>, +first: U32) -> List<&2, Sub>:
  xsubs.go(n, bs, first, [])

def xsegs.go(n: Nat, bs: List<&2, U32>, acc: List<&2, Seg>) -> List<&2, Seg>:
  match n bs:
    case 1n+p a0 <> a1 <> a2 <> a3 <> b0 <> b1 <> b2 <> b3 <> l0 <> l1 <> sd <> t:
      xsegs.go(p, t, Seg{le4(a0, a1, a2, a3), le4(b0, b1, b2, b3), 0, (l0 .|. (l1 << 8n) : U32), sd, 0} <> acc)
    case _ _:
      List.reverse(&2, Seg, acc)

def xsegs(n: Nat, bs: List<&2, U32>) -> List<&2, Seg>:
  xsegs.go(n, bs, [])

def xnodes.go(n: Nat, bs: List<&2, U32>, acc: List<&2, Node>) -> List<&2, Node>:
  match n bs:
    case 1n+p x0 <> x1 <> y0 <> y1 <> u0 <> u1 <> v0 <> v1 <> a0 <> a1 <> a2 <> a3 <> a4 <> a5 <> a6 <> a7 <> b0 <> b1 <> b2 <> b3 <> b4 <> b5 <> b6 <> b7 <> r0 <> r1 <> r2 <> r3 <> q0 <> q1 <> q2 <> q3 <> t:
      xnodes.go(p, t, Node{le2(x0, x1), le2(y0, y1), le2(u0, u1), le2(v0, v1), Box{le2(a0, a1), le2(a2, a3), le2(a4, a5), le2(a6, a7)}, Box{le2(b0, b1), le2(b2, b3), le2(b4, b5), le2(b6, b7)}, le4(r0, r1, r2, r3), le4(q0, q1, q2, q3)} <> acc)
    case _ _:
      List.reverse(&2, Node, acc)

def xnodes(n: Nat, bs: List<&2, U32>) -> List<&2, Node>:
  xnodes.go(n, bs, [])

def slope(+num: U32, +den: U32) -> U32:
  Bool.pick(U32, U32.is_lt(den, 512), 2048, U32.min(((num << 3n) / U32.max((den >> 8n : U32), 1) : U32), 2048))

def octant(+nx: Bool, +ny: Bool, +big: Bool, +t: U32) -> U32:
  Bool.pick(U32, nx,
    Bool.pick(U32, ny,
      Bool.pick(U32, big, (2147483648 + t : U32), (3221225472 - 1 - t : U32)),
      Bool.pick(U32, big, (2147483648 - 1 - t : U32), (1073741824 + t : U32))),
    Bool.pick(U32, ny,
      Bool.pick(U32, big, (0 - t : U32), (3221225472 + t : U32)),
      Bool.pick(U32, big, t, (1073741824 - 1 - t : U32))))

def angle.of(+ta: T.Vec<U32>, +x: U32, +y: U32, +ax: U32, +ay: U32) -> U32:
  +big = U32.is_gt(ax, ay)
  octant(F.is_neg(x), F.is_neg(y), big, T.get(U32, ta, Bool.pick(U32, big, slope(ay, ax), slope(ax, ay)), 0))

def angle(+ta: T.Vec<U32>, +x: U32, +y: U32) -> U32:
  angle.of(ta, x, y, F.abs(x), F.abs(y))

def isqrt(n: Nat, +v: U32, +r: U32, +bit: U32) -> U32:
  match n:
    case 0n:
      r
    case 1n+p:
      +ge = U32.is_ge(v, (r + bit : U32))
      isqrt(p, Bool.pick(U32, ge, (v - r - bit : U32), v), Bool.pick(U32, ge, ((r >> 1n) + bit : U32), (r >> 1n : U32)), (bit >> 2n : U32))

def offset(+dx: U32, +dy: U32) -> U32:
  +v = (dx * dx + dy * dy : U32)
  Bool.pick(U32, F.is_neg(v), 0, (isqrt(16n, v, 0, 1073741824) << 16n : U32))

def vx(+v: Vertex) -> U32:
  match v:
    case Vertex{x, y}:
      x

def vy(+v: Vertex) -> U32:
  match v:
    case Vertex{x, y}:
      y

def lv(+l: Line, +back: Bool) -> U32:
  match l:
    case Line{a, b, f, sp, tg, fr, bk}:
      Bool.pick(U32, back, b, a)

def xseg(+ta: T.Vec<U32>, +vs: T.Vec<Vertex>, +ls: T.Vec<Line>, s: Seg) -> Seg:
  match s:
    case Seg{+a, +b, an, +li, +sd, of}:
      +va = T.get(Vertex, vs, a, Vertex{0, 0})
      +vb = T.get(Vertex, vs, b, Vertex{0, 0})
      +vn = T.get(Vertex, vs, lv(T.get(Line, ls, li, Line{0, 0, 0, 0, 0, 0, 0}), U32.is_ne(sd, 0)), Vertex{0, 0})
      Seg{a, b, angle(ta, (vx(vb) - vx(va) : U32), (vy(vb) - vy(va) : U32)), li, sd,
        offset(F.sar((vx(va) - vx(vn) : U32), 16n), F.sar((vy(va) - vy(vn) : U32), 16n))}

def xsegs.fix.go(xs: List<&2, Seg>, +ta: T.Vec<U32>, +vs: T.Vec<Vertex>, +ls: T.Vec<Line>, acc: List<&2, Seg>) -> List<&2, Seg>:
  match xs:
    case s <> t:
      xsegs.fix.go(t, ta, vs, ls, xseg(ta, vs, ls, s) <> acc)
    case []:
      List.reverse(&2, Seg, acc)

def xsegs.fix(xs: List<&2, Seg>, +ta: T.Vec<U32>, +vs: T.Vec<Vertex>, +ls: T.Vec<Line>) -> List<&2, Seg>:
  xsegs.fix.go(xs, ta, vs, ls, [])

def magic(+bs: List<&2, U32>) -> U32:
  match bs:
    case a <> b <> c <> d <> t:
      Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(b, 78), U32.is_eq(c, 79)), U32.is_eq(d, 68)), Bool.pick(U32, U32.is_eq(a, 88), 1, Bool.pick(U32, U32.is_eq(a, 90), 2, 0)), 0)
    case _:
      0

def payload(z: Bool, +bs: List<&2, U32>) -> List<&2, U32>:
  match z:
    case True{}:
      Z.inflate(at(bs, 4), 2)
    case False{}:
      at(bs, 4)

def extended(name: String, th: List<&2, U32>, li: List<&2, U32>, si: List<&2, U32>, ve: List<&2, U32>, +bs: List<&2, U32>, sc: List<&2, U32>, rj: List<&2, U32>, bm: List<&2, U32>) -> Level:
  +ls = vec(Line, lines(B.words(li)))
  +nv = word(at(bs, 4))
  +b1 = at(bs, (8 + nv * 8 : U32))
  +ns = word(b1)
  +b2 = at(b1, (4 + ns * 4 : U32))
  +ng = word(b2)
  +b3 = at(b2, (4 + ng * 11 : U32))
  +vs = vec(Vertex, List.append(&2, Vertex, List.take(&2, Vertex, verts(B.words(ve)), U32.to_nat(word(bs))), xverts(U32.to_nat(nv), at(bs, 8))))
  Level{name,
    vec(Thing, things(B.words(th))),
    ls,
    vec(Side, sides(B.words(si))),
    vs,
    vec(Seg, xsegs.fix(xsegs(U32.to_nat(ng), at(b2, 4)), X.tantoangle(), vs, ls)),
    vec(Sub, xsubs(U32.to_nat(ns), at(b1, 4), 0)),
    vec(Node, xnodes(U32.to_nat(word(b3)), at(b3, 4))),
    vec(Sector, sectors(B.words(sc))),
    vec(U32, rj),
    vec(U32, B.words(bm))}

def classic(name: String, th: List<&2, U32>, li: List<&2, U32>, si: List<&2, U32>, ve: List<&2, U32>, se: List<&2, U32>, ss: List<&2, U32>, no: List<&2, U32>, sc: List<&2, U32>, rj: List<&2, U32>, bm: List<&2, U32>) -> Level:
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

def pick.go(plain: Bool, +k: U32, name: String, th: List<&2, U32>, li: List<&2, U32>, si: List<&2, U32>, ve: List<&2, U32>, se: List<&2, U32>, ss: List<&2, U32>, no: List<&2, U32>, sc: List<&2, U32>, rj: List<&2, U32>, bm: List<&2, U32>) -> Level:
  match plain:
    case True{}:
      classic(name, th, li, si, ve, se, ss, no, sc, rj, bm)
    case False{}:
      extended(name, th, li, si, ve, payload(U32.is_eq(k, 2), no), sc, rj, bm)

def pick(+k: U32, name: String, th: List<&2, U32>, li: List<&2, U32>, si: List<&2, U32>, ve: List<&2, U32>, se: List<&2, U32>, ss: List<&2, U32>, no: List<&2, U32>, sc: List<&2, U32>, rj: List<&2, U32>, bm: List<&2, U32>) -> Level:
  pick.go(U32.is_eq(k, 0), k, name, th, li, si, ve, se, ss, no, sc, rj, bm)

def build(name: String, bss: List<&2, List<&2, U32>>) -> Level:
  match bss:
    case th <> li <> si <> ve <> se <> ss <> +no <> sc <> rj <> bm <> t:
      pick(magic(no), name, th, li, si, ve, se, ss, no, sc, rj, bm)
    case _:
      Level{name, vec(Thing, []), vec(Line, []), vec(Side, []), vec(Vertex, []), vec(Seg, []), vec(Sub, []), vec(Node, []), vec(Sector, []), vec(U32, []), vec(U32, [])}

def load.fin(name: String, p: W.Wad & List<&2, List<&2, U32>>) -> IO(W.Wad & Level):
  (w, bss) = p
  IO.pure(W.Wad & Level, (w, build(name, bss)))

def load(w: W.Wad, +name: String) -> IO(W.Wad & Level):
  match w:
    case W.Wad{file, m, +d}:
      IO.bind(W.Wad & List<&2, List<&2, U32>>, W.Wad & Level,
        W.lumps(W.parts(List.take(&2, W.Lump, W.from(name, d), 11n), parts()), W.Wad{file, m, d}),
        p => load.fin(name, p))
