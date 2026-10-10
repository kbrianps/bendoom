import Base
import ./tab.bend as T
import ./level.bend as L
import ./load.bend as D
import ./gfx.bend as G
import ./mem.bend as M
import ./sprite.bend as P

type RSide is Data:
  RSide{xoff: U32, yoff: U32, top: U32, bottom: U32, mid: U32, sector: U32}

type RSeg is Data:
  RSeg{x1: U32, y1: U32, x2: U32, y2: U32, angle: U32, offset: U32, flags: U32, side: U32, back: U32}

type RSector is Data:
  RSector{floor: U32, ceil: U32, fpic: U32, cpic: U32, light: U32, special: U32, tag: U32, data: U32, things: U32}

type RThing is Data:
  RThing{x: U32, y: U32, z: U32, angle: U32, sprite: U32, frame: U32, flags: U32}

type World is Data:
  World{
    sides: T.Vec<RSide>,
    segs: T.Vec<RSeg>,
    subs: T.Vec<L.Sub>,
    nodes: T.Vec<L.Node>,
    sectors: T.Vec<RSector>,
    texs: T.Vec<M.Info>,
    sky: M.Info,
    frames: T.Vec<P.SFrame>,
    flats: T.Vec<U32>,
    mo: T.Vec<U32>}

def maxmobjs() -> U32:
  8192

def stride() -> U32:
  32

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

def flat(fs: List<&2, String>, +s: String, +i: U32) -> U32:
  match fs:
    case f <> t:
      Bool.pick(U32, String.eq(f, s), i, flat(t, s, (i + 1 : U32)))
    case []:
      M.sky()

def rsector(+fs: List<&2, String>, d: L.Sector) -> RSector:
  match d:
    case L.Sector{f, c, fp, cp, li, sp, tg}:
      RSector{(f << 16n : U32), (c << 16n : U32), flat(fs, fp, 0), flat(fs, cp, 0), li, sp, tg, 0, 0}

def rsectors(n: Nat, +secs: T.Vec<L.Sector>, +fs: List<&2, String>, +i: U32) -> List<&2, RSector>:
  match n:
    case 0n:
      []
    case 1n+p:
      rsector(fs, T.get(L.Sector, secs, i, L.Sector{0, 0, "", "", 0, 0, 0})) <> rsectors(p, secs, fs, (i + 1 : U32))

def build(lv: L.Level, t: D.Texs, ly: M.Layout, +fm: T.Vec<P.SFrame>) -> World:
  match lv t ly:
    case L.Level{n, th, +li, +si, +ve, +se, +ss, +no, +sc, rj, bm} D.Texs{+names, ts, +sky, +fl, fd, hs, ta, fa, sw, tbs, fbs} M.Layout{+infos, +bases, size}:
      +tv = T.from_list(M.Info, infos)
      World{
        T.from_list(RSide, rsides(U32.to_nat(T.size(L.Side, si)), si, names, 0)),
        T.from_list(RSeg, rsegs(U32.to_nat(T.size(L.Seg, se)), se, ve, li, si, 0)),
        ss, no,
        T.from_list(RSector, rsectors(U32.to_nat(T.size(L.Sector, sc)), sc, fl, 0)),
        tv,
        T.get(M.Info, tv, (tex(names, sky) - 1 : U32), M.Info{0, 0, 0, 4294967295}),
        fm,
        T.from_list(U32, bases),
        T.new(U32, (maxmobjs() * stride() : U32), 0)}

def sides(+w: World) -> T.Vec<RSide>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      si

def segs(+w: World) -> T.Vec<RSeg>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      sg

def subs(+w: World) -> T.Vec<L.Sub>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      su

def nodes(+w: World) -> T.Vec<L.Node>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      no

def sectors(+w: World) -> T.Vec<RSector>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      sc

def texs(+w: World) -> T.Vec<M.Info>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      tx

def sky(+w: World) -> M.Info:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      sk

def frames(+w: World) -> T.Vec<P.SFrame>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      fm

def flats(+w: World) -> T.Vec<U32>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      fl

def mobjs(+w: World) -> T.Vec<U32>:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      mo

def side(+w: World, +i: U32) -> RSide:
  T.get(RSide, sides(w), i, RSide{0, 0, 0, 0, 0, 0})

def seg(+w: World, +i: U32) -> RSeg:
  T.get(RSeg, segs(w), i, RSeg{0, 0, 0, 0, 0, 0, 0, 0, 65535})

def sector(+w: World, +i: U32) -> RSector:
  T.get(RSector, sectors(w), i, RSector{0, 0, 0, 0, 0, 0, 0, 0, 0})

def sub(+w: World, +i: U32) -> L.Sub:
  T.get(L.Sub, subs(w), i, L.Sub{0, 0})

def node(+w: World, +i: U32) -> L.Node:
  T.get(L.Node, nodes(w), i, L.Node{0, 0, 0, 0, L.Box{0, 0, 0, 0}, L.Box{0, 0, 0, 0}, 0, 0})

def info(+w: World, +id: U32) -> M.Info:
  T.get(M.Info, texs(w), (id - 1 : U32), M.Info{0, 0, 0, 4294967295})

def flatbase(+w: World, +id: U32) -> U32:
  T.get(U32, flats(w), id, 0)

def sframe(+w: World, +c: U32) -> P.SFrame:
  T.get(P.SFrame, frames(w), c, P.SFrame{False{}, 0, 0, 0, 0, 0, 0, 0, 0, 0})

def mo(+w: World, +m: U32, +f: U32) -> U32:
  T.get(U32, mobjs(w), (m * stride() + f : U32), 0)

def thing(+w: World, +m: U32) -> RThing:
  RThing{mo(w, m, 0), mo(w, m, 1), mo(w, m, 2), mo(w, m, 3), mo(w, m, 4), mo(w, m, 5), mo(w, m, 6)}

def chain(n: Nat, stop: Bool, +w: World, +m: U32) -> List<&2, U32>:
  match n stop:
    case 1n+p False{}:
      +nx = mo(w, m, 26)
      m <> chain(p, U32.is_eq(nx, 0), w, nx)
    case _ _:
      []

def sec.things(+s: RSector) -> U32:
  match s:
    case RSector{f, c, fp, cp, li, sp, tg, d, th}:
      th

def secthings(+w: World, +s: U32) -> List<&2, U32>:
  +th = sec.things(sector(w, s))
  chain(U32.to_nat(maxmobjs()), U32.is_eq(th, 0), w, th)

def with.sides(w: World, si: T.Vec<RSide>) -> World:
  match w:
    case World{x, sg, su, no, sc, tx, sk, fm, fl, mo}:
      World{si, sg, su, no, sc, tx, sk, fm, fl, mo}

def with.sectors(w: World, sc: T.Vec<RSector>) -> World:
  match w:
    case World{si, sg, su, no, x, tx, sk, fm, fl, mo}:
      World{si, sg, su, no, sc, tx, sk, fm, fl, mo}

def with.texs(w: World, tx: T.Vec<M.Info>) -> World:
  match w:
    case World{si, sg, su, no, sc, x, sk, fm, fl, mo}:
      World{si, sg, su, no, sc, tx, sk, fm, fl, mo}

def with.flats(w: World, fl: T.Vec<U32>) -> World:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, x, mo}:
      World{si, sg, su, no, sc, tx, sk, fm, fl, mo}

def with.mobjs(w: World, mo: T.Vec<U32>) -> World:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, x}:
      World{si, sg, su, no, sc, tx, sk, fm, fl, mo}

def set.side(w: World, +i: U32, d: RSide) -> World:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      World{T.set(RSide, si, i, d), sg, su, no, sc, tx, sk, fm, fl, mo}

def set.sector(w: World, +i: U32, s: RSector) -> World:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      World{si, sg, su, no, T.set(RSector, sc, i, s), tx, sk, fm, fl, mo}

def set.info(w: World, +id: U32, t: M.Info) -> World:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      World{si, sg, su, no, sc, T.set(M.Info, tx, (id - 1 : U32), t), sk, fm, fl, mo}

def set.flat(w: World, +id: U32, b: U32) -> World:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      World{si, sg, su, no, sc, tx, sk, fm, T.set(U32, fl, id, b), mo}

def set.mo(w: World, +m: U32, +f: U32, v: U32) -> World:
  match w:
    case World{si, sg, su, no, sc, tx, sk, fm, fl, mo}:
      World{si, sg, su, no, sc, tx, sk, fm, fl, T.set(U32, mo, (m * stride() + f : U32), v)}

def seg.side(+s: RSeg) -> U32:
  match s:
    case RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      sd

def side.sec(+d: RSide) -> U32:
  match d:
    case RSide{x, y, t, b, m, s}:
      s

def side.of.seg(+w: World, +s: L.Sub) -> U32:
  match s:
    case L.Sub{n, f}:
      side.sec(side(w, seg.side(seg(w, f))))
