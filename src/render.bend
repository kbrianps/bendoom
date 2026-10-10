import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./tables.bend as X
import ./level.bend as L
import ./gfx.bend as G
import ./world.bend as R
import ./screen.bend as S

type Tabs is Data:
  Tabs{sine: T.Vec<U32>, tangent: T.Vec<U32>, tanto: T.Vec<U32>, v2x: T.Vec<U32>, x2a: T.Vec<U32>, clip: U32, cmaps: T.Vec<T.Vec<U32>>}

type View is Data:
  View{x: U32, y: U32, z: U32, angle: U32, extra: U32}

type Range is Data:
  Range{first: U32, last: U32}

type Cut is Data:
  Cut{ok: Bool, a1: U32, a2: U32}

type Frame is Type:
  Frame{fb: Array<U32>, ceil: T.Vec<U32>, floor: T.Vec<U32>, solid: List<&2, Range>}

type Wall is Data:
  Wall{mt: U32, tt: U32, bt: U32, mmid: U32, tmid: U32, bmid: U32, center: U32, offset: U32, dist: U32, light: U32,
    markc: Bool, markf: Bool, sky: Bool, sstep: U32, tstep: U32, bstep: U32, hstep: U32, lstep: U32}

type Cols is Data:
  Cols{x: U32, scale: U32, top: U32, bot: U32, high: U32, low: U32}

type Item is Data:
  Visit{num: U32}
  Check{num: U32, box: L.Box}

type St is Type:
  St{frame: Frame, stack: List<&2, Item>}

def ang90() -> U32:
  1073741824

def ang180() -> U32:
  2147483648

def ang270() -> U32:
  3221225472

def sky() -> String:
  "F_SKY1"

def sine(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, m}:
      T.get(U32, s, i, 0)

def tangent(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, m}:
      T.get(U32, t, i, 0)

def tanto(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, m}:
      T.get(U32, a, i, 0)

def v2x(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, m}:
      T.get(U32, v, i, 0)

def x2a(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, m}:
      T.get(U32, x, i, 0)

def clipangle(+tb: Tabs) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, m}:
      c

def cmap(+tb: Tabs, +i: U32) -> T.Vec<U32>:
  match tb:
    case Tabs{s, t, a, v, x, c, m}:
      T.get(T.Vec<U32>, m, i, T.from_list(U32, []))

def raw(+t: U32, +focal: U32) -> U32:
  Bool.pick(U32, F.gt(t, 131072), 4294967295,
    Bool.pick(U32, F.lt(t, 4294836224), 321,
      F.max(F.min(F.sar((10485760 - F.mul(t, focal) + 65535 : U32), 16n), 321), 4294967295)))

def raws(+n: Nat, +tan: T.Vec<U32>, +i: U32, +focal: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      raw(T.get(U32, tan, i, 0), focal) <> raws(p, tan, (i + 1 : U32), focal)

def above(+xs: List<&2, U32>, +x: U32) -> U32:
  match xs:
    case +r <> t:
      (Bool.pick(U32, F.gt(r, x), 1, 0) + above(t, x) : U32)
    case []:
      0

def x2as(+n: Nat, +rs: List<&2, U32>, +x: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      ((above(rs, x) << 19n) - ang90() : U32) <> x2as(p, rs, (x + 1 : U32))

def v2xs(+rs: List<&2, U32>) -> List<&2, U32>:
  match rs:
    case +r <> t:
      Bool.pick(U32, U32.is_eq(r, 4294967295), 0, Bool.pick(U32, U32.is_eq(r, 321), 320, r)) <> v2xs(t)
    case []:
      []

def colormap(+pal: T.Vec<U32>, +bs: List<&2, U32>) -> List<&2, U32>:
  match bs:
    case b <> t:
      T.get(U32, pal, b, 0) <> colormap(pal, t)
    case []:
      []

def colormaps(+n: Nat, +pal: T.Vec<U32>, +bs: List<&2, U32>) -> List<&2, T.Vec<U32>>:
  match n:
    case 0n:
      []
    case 1n+p:
      T.from_list(U32, colormap(pal, List.take(&2, U32, bs, 256n))) <> colormaps(p, pal, List.drop(&2, U32, bs, 256n))

def tabs.of(+sine: T.Vec<U32>, +tan: T.Vec<U32>, +cm: T.Vec<T.Vec<U32>>, +rs: List<&2, U32>) -> Tabs:
  +x2 = T.from_list(U32, x2as(321n, rs, 0))
  Tabs{sine, tan, X.tantoangle(), T.from_list(U32, v2xs(rs)), x2, T.get(U32, x2, 0, 0), cm}

def tabs(+pal: T.Vec<U32>, +cmaps: List<&2, U32>) -> Tabs:
  +tan = X.finetangent()
  tabs.of(X.finesine(), tan, T.from_list(T.Vec<U32>, colormaps(34n, pal, cmaps)), raws(4096n, tan, 0, F.div(10485760, T.get(U32, tan, 3072, 0))))

def slope(+num: U32, +den: U32) -> U32:
  Bool.pick(U32, U32.is_lt(den, 512), 2048, U32.min(((num << 3n) / U32.max((den >> 8n : U32), 1) : U32), 2048))

def octant(+nx: Bool, +ny: Bool, +big: Bool, +t: U32) -> U32:
  Bool.pick(U32, nx,
    Bool.pick(U32, ny,
      Bool.pick(U32, big, (ang180() + t : U32), (ang270() - 1 - t : U32)),
      Bool.pick(U32, big, (ang180() - 1 - t : U32), (ang90() + t : U32))),
    Bool.pick(U32, ny,
      Bool.pick(U32, big, (0 - t : U32), (ang270() + t : U32)),
      Bool.pick(U32, big, t, (ang90() - 1 - t : U32))))

def angle.of(+tb: Tabs, +x: U32, +y: U32, +ax: U32, +ay: U32) -> U32:
  +big = U32.is_gt(ax, ay)
  Bool.pick(U32, Bool.and(U32.is_eq(x, 0), U32.is_eq(y, 0)), 0,
    octant(F.is_neg(x), F.is_neg(y), big, tanto(tb, Bool.pick(U32, big, slope(ay, ax), slope(ax, ay)))))

def angle(+tb: Tabs, +x: U32, +y: U32) -> U32:
  angle.of(tb, x, y, F.abs(x), F.abs(y))

def dist.of(+tb: Tabs, +a: U32, +b: U32) -> U32:
  F.div(a, sine(tb, ((tanto(tb, U32.min((F.div(b, a) >> 5n : U32), 2048)) + ang90()) >> 19n : U32)))

def dist(+tb: Tabs, +dx: U32, +dy: U32) -> U32:
  dist.of(tb, U32.max(F.abs(dx), F.abs(dy)), U32.min(F.abs(dx), F.abs(dy)))

def scale.clamp(+s: U32) -> U32:
  Bool.pick(U32, F.gt(s, 4194304), 4194304, Bool.pick(U32, F.lt(s, 256), 256, s))

def scale.if(+ok: Bool, +num: U32, +den: U32) -> U32:
  match ok:
    case True{}:
      scale.clamp(F.div(num, den))
    case False{}:
      4194304

def scale.of(+num: U32, +den: U32) -> U32:
  scale.if(F.gt(den, F.sar(num, 16n)), num, den)

def scale(+tb: Tabs, +vis: U32, +va: U32, +normal: U32, +dist: U32) -> U32:
  scale.of(F.mul(10485760, sine(tb, ((ang90() + vis - normal) >> 19n : U32))), F.mul(dist, sine(tb, ((ang90() + vis - va) >> 19n : U32))))

def side.of(+x: U32, +y: U32, +nx: U32, +ny: U32, +ndx: U32, +ndy: U32) -> Bool:
  +dx = (x - nx : U32)
  +dy = (y - ny : U32)
  Bool.pick(Bool, U32.is_eq(ndx, 0), Bool.pick(Bool, F.le(x, nx), F.gt(ndy, 0), F.lt(ndy, 0)),
    Bool.pick(Bool, U32.is_eq(ndy, 0), Bool.pick(Bool, F.le(y, ny), F.lt(ndx, 0), F.gt(ndx, 0)),
      Bool.pick(Bool, F.is_neg((ndy .^. ndx .^. dx .^. dy : U32)), F.is_neg((ndy .^. dx : U32)),
        Bool.not(F.lt(F.mul(dy, F.sar(ndx, 16n)), F.mul(F.sar(ndy, 16n), dx))))))

def side(+v: View, +n: L.Node) -> Bool:
  match v n:
    case View{x, y, z, a, e} L.Node{nx, ny, ndx, ndy, rb, lb, r, l}:
      side.of(x, y, (nx << 16n : U32), (ny << 16n : U32), (ndx << 16n : U32), (ndy << 16n : U32))

def cut(+clip: U32, +a1: U32, +a2: U32, +span: U32) -> Cut:
  +c2 = (clip * 2 : U32)
  +t1 = (a1 + clip : U32)
  +t2 = (clip - a2 : U32)
  +o1 = U32.is_gt(t1, c2)
  +o2 = U32.is_gt(t2, c2)
  Cut{Bool.not(Bool.or(Bool.and(o1, U32.is_ge((t1 - c2 : U32), span)), Bool.and(o2, U32.is_ge((t2 - c2 : U32), span)))),
    Bool.pick(U32, o1, clip, a1), Bool.pick(U32, o2, (0 - clip : U32), a2)}

def covered(+rs: List<&2, Range>, +x1: U32, +x2: U32) -> Bool:
  match rs:
    case Range{+f, +l} <> t:
      Bool.pick(Bool, F.lt(l, x2), covered(t, x1, x2), Bool.and(F.ge(x1, f), F.le(x2, l)))
    case []:
      False{}

def bbox.sx(+ok: Bool, +rs: List<&2, Range>, +s1: U32, +s2: U32) -> Bool:
  Bool.and(ok, Bool.and(Bool.not(U32.is_eq(s1, s2)), Bool.not(covered(rs, s1, (s2 - 1 : U32)))))

def bbox.xs(+tb: Tabs, +rs: List<&2, Range>, +c: Cut) -> Bool:
  match c:
    case Cut{ok, a1, a2}:
      bbox.sx(ok, rs, v2x(tb, ((a1 + ang90()) >> 19n : U32)), v2x(tb, ((a2 + ang90()) >> 19n : U32)))

def bbox.angles(+tb: Tabs, +rs: List<&2, Range>, +a1: U32, +a2: U32) -> Bool:
  Bool.or(U32.is_ge((a1 - a2 : U32), ang180()), bbox.xs(tb, rs, cut(clipangle(tb), a1, a2, (a1 - a2 : U32))))

def coord(+b: L.Box, +k: U32) -> U32:
  match b:
    case L.Box{t, bo, le, r}:
      (Bool.pick(U32, U32.is_eq(k, 0), t, Bool.pick(U32, U32.is_eq(k, 1), bo, Bool.pick(U32, U32.is_eq(k, 2), le, r))) << 16n : U32)

def checkcoord() -> T.Vec<U32>:
  T.from_list(U32, [3, 0, 2, 1, 3, 0, 2, 0, 3, 1, 2, 0, 0, 0, 0, 0, 2, 0, 2, 1, 0, 0, 0, 0, 3, 1, 3, 0, 0, 0, 0, 0, 2, 0, 3, 1, 2, 1, 3, 1, 2, 1, 3, 0])

def bbox.at(+tb: Tabs, +v: View, +rs: List<&2, Range>, +b: L.Box, +pos: U32) -> Bool:
  match v:
    case View{x, y, z, a, e}:
      bbox.angles(tb, rs,
        (angle(tb, (coord(b, T.get(U32, checkcoord(), (pos * 4 : U32), 0)) - x : U32), (coord(b, T.get(U32, checkcoord(), (pos * 4 + 1 : U32), 0)) - y : U32)) - a : U32),
        (angle(tb, (coord(b, T.get(U32, checkcoord(), (pos * 4 + 2 : U32), 0)) - x : U32), (coord(b, T.get(U32, checkcoord(), (pos * 4 + 3 : U32), 0)) - y : U32)) - a : U32))

def bbox.pos(+v: View, +b: L.Box) -> U32:
  match v b:
    case View{x, y, z, a, e} L.Box{t, bo, le, r}:
      (Bool.pick(U32, F.ge(y, (t << 16n : U32)), 0, Bool.pick(U32, F.gt(y, (bo << 16n : U32)), 1, 2)) * 4
        + Bool.pick(U32, F.le(x, (le << 16n : U32)), 0, Bool.pick(U32, F.lt(x, (r << 16n : U32)), 1, 2)) : U32)

def bbox.if(+inside: Bool, +tb: Tabs, +v: View, +rs: List<&2, Range>, +b: L.Box, +pos: U32) -> Bool:
  match inside:
    case True{}:
      True{}
    case False{}:
      bbox.at(tb, v, rs, b, pos)

def bbox(+tb: Tabs, +v: View, +rs: List<&2, Range>, +b: L.Box) -> Bool:
  bbox.if(U32.is_eq(bbox.pos(v, b), 5), tb, v, rs, b, bbox.pos(v, b))

def gap.put(+f: U32, +l: U32, +rest: List<&2, Range>) -> List<&2, Range>:
  Bool.pick(List<&2, Range>, F.le(f, l), Range{f, l} <> rest, rest)

def gaps(+rs: List<&2, Range>, +cur: U32, +last: U32) -> List<&2, Range>:
  match rs:
    case Range{+f, +l} <> t:
      gap.put(cur, F.min(last, (f - 1 : U32)), gaps(t, Bool.pick(U32, U32.is_eq(l, 2147483647), cur, F.max(cur, (l + 1 : U32))), last))
    case []:
      []

def left(+rs: List<&2, Range>, +f: U32) -> Bool:
  match rs:
    case Range{+rf, +rl} <> t:
      Bool.and(Bool.not(U32.is_eq(f, 2147483649)), F.lt(rl, (f - 1 : U32)))
    case []:
      False{}

def right(+rs: List<&2, Range>, +l: U32) -> Bool:
  match rs:
    case Range{+rf, +rl} <> t:
      Bool.and(Bool.not(U32.is_eq(l, 2147483647)), F.gt(rf, (l + 1 : U32)))
    case []:
      True{}

def merge.go(+rs: List<&2, Range>, +lt: Bool, +gt: Bool, +f: U32, +l: U32) -> List<&2, Range>:
  match rs lt gt:
    case h <> +t True{} _:
      h <> merge.go(t, left(t, f), right(t, l), f, l)
    case +h <> t False{} True{}:
      Range{f, l} <> h <> t
    case Range{+hf, +hl} <> +t False{} False{}:
      merge.go(t, left(t, F.min(f, hf)), right(t, F.max(l, hl)), F.min(f, hf), F.max(l, hl))
    case [] _ _:
      [Range{f, l}]

def merge(+rs: List<&2, Range>, +f: U32, +l: U32) -> List<&2, Range>:
  merge.go(rs, left(rs, f), right(rs, l), f, l)

def nodes(+w: R.World) -> T.Vec<L.Node>:
  match w:
    case R.World{si, sg, su, no, sc, tx, th}:
      no

def seg(+w: R.World, +i: U32) -> R.RSeg:
  match w:
    case R.World{si, sg, su, no, sc, tx, th}:
      T.get(R.RSeg, sg, i, R.RSeg{0, 0, 0, 0, 0, 0, 0, 0, 65535})

def rside(+w: R.World, +i: U32) -> R.RSide:
  match w:
    case R.World{si, sg, su, no, sc, tx, th}:
      T.get(R.RSide, si, i, R.RSide{0, 0, 0, 0, 0, 0})

def sector(+w: R.World, +i: U32) -> L.Sector:
  match w:
    case R.World{si, sg, su, no, sc, tx, th}:
      T.get(L.Sector, sc, i, L.Sector{0, 0, "", "", 0, 0, 0})

def sub(+w: R.World, +i: U32) -> L.Sub:
  match w:
    case R.World{si, sg, su, no, sc, tx, th}:
      T.get(L.Sub, su, i, L.Sub{0, 0})

def node(+w: R.World, +i: U32) -> L.Node:
  T.get(L.Node, nodes(w), i, L.Node{0, 0, 0, 0, L.Box{0, 0, 0, 0}, L.Box{0, 0, 0, 0}, 0, 0})

def tex(+w: R.World, +id: U32) -> G.Tex:
  match w:
    case R.World{si, sg, su, no, sc, tx, th}:
      T.get(G.Tex, tx, (id - 1 : U32), G.Tex{0, 0, T.from_list(T.Vec<U32>, [])})

def tex.height(+t: G.Tex) -> U32:
  match t:
    case G.Tex{m, h, cs}:
      h

def tex.col(+t: G.Tex, +c: U32) -> T.Vec<U32>:
  match t:
    case G.Tex{m, h, cs}:
      T.get(T.Vec<U32>, cs, (c .&. m : U32), T.from_list(U32, []))

def texh(+w: R.World, +id: U32) -> U32:
  tex.height(tex(w, id))

def side.sector(+d: R.RSide) -> U32:
  match d:
    case R.RSide{xo, yo, t, b, m, s}:
      s

def seg.front(+w: R.World, +s: R.RSeg) -> U32:
  match s:
    case R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      side.sector(rside(w, sd))

def lightmap(+light: U32, +scale: U32) -> U32:
  +lv = (((15 - light) * 4 : U32) - U32.min((scale >> 12n : U32), 47) / 2 : U32)
  Bool.pick(U32, F.lt(lv, 0), 0, Bool.pick(U32, F.gt(lv, 31), 31, lv))

def paint(n: Nat, fb: Array<U32>, +x: U32, +y: U32, +frac: U32, +step: U32, +col: T.Vec<U32>, +cm: T.Vec<U32>) -> Array<U32>:
  match n:
    case 0n:
      fb
    case 1n+p:
      paint(p, S.put(fb, x, y, T.get(U32, cm, T.get(U32, col, ((frac >> 16n) .&. 127 : U32), 0), 0)), x, (y + 1 : U32), (frac + step : U32), step, col, cm)

def fill(n: Nat, fb: Array<U32>, +x: U32, +y: U32, +c: U32) -> Array<U32>:
  match n:
    case 0n:
      fb
    case 1n+p:
      fill(p, S.put(fb, x, y, c), x, (y + 1 : U32), c)

def count(+yl: U32, +yh: U32) -> Nat:
  Bool.pick(Nat, F.lt(yh, yl), 0n, U32.to_nat((yh - yl + 1 : U32)))

def column(go: Bool, fb: Array<U32>, +w: R.World, +id: U32, +tc: U32, +x: U32, +yl: U32, +yh: U32, +mid: U32, +step: U32, +cm: T.Vec<U32>) -> Array<U32>:
  match go:
    case True{}:
      paint(count(yl, yh), fb, x, yl, (mid + (yl - 100) * step : U32), step, tex.col(tex(w, id), tc), cm)
    case False{}:
      fb

def plane(go: Bool, fb: Array<U32>, +x: U32, +y0: U32, +y1: U32, +c: U32) -> Array<U32>:
  match go:
    case True{}:
      fill(count(y0, y1), fb, x, y0, c)
    case False{}:
      fb

def wcol.a(fb: Array<U32>, +ceil: T.Vec<U32>, +floor: T.Vec<U32>, +solid: List<&2, Range>, +tb: Tabs, +w: R.World, +wl: Wall, +cl: Cols) -> Frame:
  match wl cl:
    case Wall{mt, tt, bt, mmid, tmid, bmid, center, offset, dist, light, markc, markf, sky, sstep, tstep, bstep, hstep, lstep} Cols{x, scale, topf, botf, high, low}:
      +c0 = T.get(U32, ceil, x, 0)
      +f0 = T.get(U32, floor, x, 0)
      +yl = F.max(F.sar((topf + 4095 : U32), 12n), (c0 + 1 : U32))
      +yh = F.min(F.sar(botf, 12n), (f0 - 1 : U32))
      +tc = F.sar((offset - F.mul(tangent(tb, ((center + x2a(tb, x)) >> 19n : U32)), dist) : U32), 16n)
      +cm = cmap(tb, lightmap(light, scale))
      +isc = (4294967295 / scale : U32)
      +pc = Bool.pick(U32, sky, T.get(U32, cmap(tb, 0), 200, 0), T.get(U32, cm, 104, 0))
      +pf = T.get(U32, cm, 77, 0)
      +hasmid = Bool.not(U32.is_eq(mt, 0))
      +tm = F.min(F.sar(high, 12n), (f0 - 1 : U32))
      +c1 = Bool.pick(U32, hasmid, 200, Bool.pick(U32, U32.is_eq(tt, 0), Bool.pick(U32, markc, (yl - 1 : U32), c0), Bool.pick(U32, F.ge(tm, yl), tm, (yl - 1 : U32))))
      +bm = F.max(F.sar((low + 4095 : U32), 12n), (c1 + 1 : U32))
      +f1 = Bool.pick(U32, hasmid, 4294967295, Bool.pick(U32, U32.is_eq(bt, 0), Bool.pick(U32, markf, (yh + 1 : U32), f0), Bool.pick(U32, F.le(bm, yh), bm, (yh + 1 : U32))))
      fb1 = plane(markc, fb, x, (c0 + 1 : U32), F.min((yl - 1 : U32), (f0 - 1 : U32)), pc)
      fb2 = plane(markf, fb1, x, F.max((yh + 1 : U32), (c0 + 1 : U32)), (f0 - 1 : U32), pf)
      fb3 = column(Bool.and(Bool.not(hasmid), Bool.and(Bool.not(U32.is_eq(tt, 0)), F.ge(tm, yl))), fb2, w, tt, tc, x, yl, tm, tmid, isc, cm)
      fb4 = column(Bool.and(Bool.not(hasmid), Bool.and(Bool.not(U32.is_eq(bt, 0)), F.le(bm, yh))), fb3, w, bt, tc, x, bm, yh, bmid, isc, cm)
      fb5 = column(hasmid, fb4, w, mt, tc, x, yl, yh, mmid, isc, cm)
      Frame{fb5, T.set(U32, ceil, x, c1), T.set(U32, floor, x, f1), solid}

def wcol(fr: Frame, +tb: Tabs, +w: R.World, +wl: Wall, +cl: Cols) -> Frame:
  match fr:
    case Frame{fb, ceil, floor, solid}:
      wcol.a(fb, ceil, floor, solid, tb, w, wl, cl)

def next(+wl: Wall, +cl: Cols) -> Cols:
  match wl cl:
    case Wall{mt, tt, bt, mmid, tmid, bmid, center, offset, dist, light, markc, markf, sky, sstep, tstep, bstep, hstep, lstep} Cols{x, scale, topf, botf, high, low}:
      Cols{(x + 1 : U32), (scale + sstep : U32), (topf + tstep : U32), (botf + bstep : U32), (high + hstep : U32), (low + lstep : U32)}

def segloop(n: Nat, fr: Frame, +tb: Tabs, +w: R.World, +wl: Wall, +cl: Cols) -> Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      segloop(p, wcol(fr, tb, w, wl, cl), tb, w, wl, next(wl, cl))

def store.sec(fr: Frame, +tb: Tabs, +w: R.World, +vx: U32, +vy: U32, +vz: U32, +va: U32, +ex: U32, +x1: U32, +y1: U32, +x2: U32, +y2: U32, +an: U32, +of: U32, +fl: U32, +bk: U32, +xoff: U32, +yoff: U32, +top: U32, +bot: U32, +mid: U32, +a1: U32, +start: U32, +stop: U32, +fs: L.Sector, +bs: L.Sector) -> Frame:
  match fs bs:
    case L.Sector{ff0, fc0, fp, fq, fli, fsp, ftg} L.Sector{bf0, bc0, bp, bq, bli, bsp, btg}:
      +ff = (ff0 << 16n : U32)
      +fc = (fc0 << 16n : U32)
      +bf = (bf0 << 16n : U32)
      +bc = (bc0 << 16n : U32)
      +normal = (an + ang90() : U32)
      +oa0 = F.abs((normal - a1 : U32))
      +oa = Bool.pick(U32, U32.is_gt(oa0, ang90()), ang90(), oa0)
      +hyp = dist(tb, (x1 - vx : U32), (y1 - vy : U32))
      +rwd = F.mul(hyp, sine(tb, ((ang90() - oa) >> 19n : U32)))
      +s1 = scale(tb, (va + x2a(tb, start) : U32), va, normal, rwd)
      +s2 = scale(tb, (va + x2a(tb, stop) : U32), va, normal, rwd)
      +sstep = Bool.pick(U32, F.gt(stop, start), F.quot((s2 - s1 : U32), (stop - start : U32)), 0)
      +one = U32.is_eq(bk, 65535)
      +fsky = String.eq(fq, sky())
      +bsky = String.eq(bq, sky())
      +wtop0 = (fc - vz : U32)
      +wbot = (ff - vz : U32)
      +whigh = (bc - vz : U32)
      +wlow = (bf - vz : U32)
      +wtop = Bool.pick(U32, Bool.and(Bool.not(one), Bool.and(fsky, bsky)), whigh, wtop0)
      +closed = Bool.or(F.le(bc, ff), F.ge(bf, fc))
      +ldiff = Bool.not(U32.is_eq(fli, bli))
      +markf0 = Bool.or(Bool.or(one, closed), Bool.or(Bool.or(Bool.not(U32.is_eq(wlow, wbot)), Bool.not(String.eq(fp, bp))), ldiff))
      +markc0 = Bool.or(Bool.or(one, closed), Bool.or(Bool.or(Bool.not(U32.is_eq(whigh, wtop)), Bool.not(String.eq(fq, bq))), ldiff))
      +mt = Bool.pick(U32, one, mid, 0)
      +tt = Bool.pick(U32, Bool.and(Bool.not(one), F.lt(whigh, wtop)), top, 0)
      +bt = Bool.pick(U32, Bool.and(Bool.not(one), F.gt(wlow, wbot)), bot, 0)
      +peglo = Bool.not(U32.is_eq((fl .&. 16 : U32), 0))
      +peghi = Bool.not(U32.is_eq((fl .&. 8 : U32), 0))
      +mmid = (Bool.pick(U32, peglo, (ff + texh(w, mid) - vz : U32), wtop) + yoff : U32)
      +tmid = (Bool.pick(U32, peghi, wtop, (bc + texh(w, top) - vz : U32)) + yoff : U32)
      +bmid = (Bool.pick(U32, peglo, wtop, wlow) + yoff : U32)
      +ro = (normal - a1 : U32)
      +ra = Bool.pick(U32, U32.is_gt(ro, ang180()), (0 - ro : U32), ro)
      +rb = Bool.pick(U32, U32.is_gt(ra, ang90()), ang90(), ra)
      +off0 = F.mul(hyp, sine(tb, (rb >> 19n : U32)))
      +off = (Bool.pick(U32, U32.is_lt(ro, ang180()), (0 - off0 : U32), off0) + xoff + of : U32)
      +center = (ang90() + va - normal : U32)
      +ln0 = ((fli >> 4n) + ex : U32)
      +ln = Bool.pick(U32, U32.is_eq(y1, y2), (ln0 - 1 : U32), Bool.pick(U32, U32.is_eq(x1, x2), (ln0 + 1 : U32), ln0))
      +light = Bool.pick(U32, F.lt(ln, 0), 0, Bool.pick(U32, F.ge(ln, 16), 15, ln))
      +markf = Bool.and(markf0, F.lt(ff, vz))
      +markc = Bool.and(markc0, Bool.or(F.gt(fc, vz), fsky))
      +wt = F.sar(wtop, 4n)
      +wb = F.sar(wbot, 4n)
      +wh = F.sar(whigh, 4n)
      +wl = F.sar(wlow, 4n)
      segloop(U32.to_nat((stop - start + 1 : U32)), fr, tb, w,
        Wall{mt, tt, bt, mmid, tmid, bmid, center, off, rwd, light, markc, markf, fsky, sstep,
          F.neg(F.mul(sstep, wt)), F.neg(F.mul(sstep, wb)),
          Bool.pick(U32, U32.is_eq(tt, 0), 0, F.neg(F.mul(sstep, wh))),
          Bool.pick(U32, U32.is_eq(bt, 0), 0, F.neg(F.mul(sstep, wl)))},
        Cols{start, s1, (409600 - F.mul(wt, s1) : U32), (409600 - F.mul(wb, s1) : U32), (409600 - F.mul(wh, s1) : U32), (409600 - F.mul(wl, s1) : U32)})

def store.side(fr: Frame, +tb: Tabs, +w: R.World, +vx: U32, +vy: U32, +vz: U32, +va: U32, +ex: U32, +x1: U32, +y1: U32, +x2: U32, +y2: U32, +an: U32, +of: U32, +fl: U32, +bk: U32, +sd: R.RSide, +a1: U32, +start: U32, +stop: U32) -> Frame:
  match sd:
    case R.RSide{xo, yo, t, b, m, sec}:
      store.sec(fr, tb, w, vx, vy, vz, va, ex, x1, y1, x2, y2, an, of, fl, bk, xo, yo, t, b, m, a1, start, stop, sector(w, sec), sector(w, bk))

def store(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +sg: R.RSeg, +a1: U32, +start: U32, +stop: U32) -> Frame:
  match v sg:
    case View{vx, vy, vz, va, ex} R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      store.side(fr, tb, w, vx, vy, vz, va, ex, x1, y1, x2, y2, an, of, fl, bk, rside(w, sd), a1, start, stop)

def stores(gs: List<&2, Range>, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +sg: R.RSeg, +a1: U32) -> Frame:
  match gs:
    case Range{f, l} <> t:
      stores(t, store(fr, tb, w, v, sg, a1, f, l), tb, w, v, sg, a1)
    case []:
      fr

def clip(solid: Bool, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +sg: R.RSeg, +a1: U32, +first: U32, +last: U32) -> Frame:
  match fr:
    case Frame{fb, c, f, +rs}:
      stores(gaps(rs, first, last), Frame{fb, c, f, Bool.pick(List<&2, Range>, solid, merge(rs, first, last), rs)}, tb, w, v, sg, a1)

def kind.of(+fs: L.Sector, +bs: L.Sector, +sd: R.RSide) -> U32:
  match fs bs sd:
    case L.Sector{ff, fc, fp, fq, fli, fsp, ftg} L.Sector{bf, bc, bp, bq, bli, bsp, btg} R.RSide{xo, yo, t, b, m, s}:
      Bool.pick(U32, Bool.or(F.le(bc, ff), F.ge(bf, fc)), 1,
        Bool.pick(U32, Bool.or(Bool.not(U32.is_eq(bc, fc)), Bool.not(U32.is_eq(bf, ff))), 2,
          Bool.pick(U32, Bool.and(Bool.and(String.eq(bq, fq), String.eq(bp, fp)), Bool.and(U32.is_eq(bli, fli), U32.is_eq(m, 0))), 0, 2)))

def kind(+w: R.World, +fs: L.Sector, +sg: R.RSeg) -> U32:
  match sg:
    case R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      Bool.pick(U32, U32.is_eq(bk, 65535), 1, kind.of(fs, sector(w, bk), rside(w, sd)))

def addline.go(go: Bool, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +sg: R.RSeg, +a1: U32, +k: U32, +sx1: U32, +sx2: U32) -> Frame:
  match go:
    case True{}:
      clip(U32.is_eq(k, 1), fr, tb, w, v, sg, a1, sx1, (sx2 - 1 : U32))
    case False{}:
      fr

def addline.cut(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +fs: L.Sector, +sg: R.RSeg, +a1: U32, +front: Bool, +c: Cut) -> Frame:
  match c:
    case Cut{ok, c1, c2}:
      +sx1 = v2x(tb, ((c1 + ang90()) >> 19n : U32))
      +sx2 = v2x(tb, ((c2 + ang90()) >> 19n : U32))
      +k = kind(w, fs, sg)
      addline.go(Bool.and(Bool.and(front, ok), Bool.and(Bool.not(U32.is_eq(sx1, sx2)), Bool.not(U32.is_eq(k, 0)))), fr, tb, w, v, sg, a1, k, sx1, sx2)

def addline(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +fs: L.Sector, +sg: R.RSeg) -> Frame:
  match v sg:
    case View{vx, vy, vz, va, ex} R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      +a1 = angle(tb, (x1 - vx : U32), (y1 - vy : U32))
      +a2 = angle(tb, (x2 - vx : U32), (y2 - vy : U32))
      addline.cut(fr, tb, w, v, fs, sg, a1, U32.is_lt((a1 - a2 : U32), ang180()), cut(clipangle(tb), (a1 - va : U32), (a2 - va : U32), (a1 - a2 : U32)))

def lines(n: Nat, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +fs: L.Sector, +i: U32) -> Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      lines(p, addline(fr, tb, w, v, fs, seg(w, i)), tb, w, v, fs, (i + 1 : U32))

def subsector.of(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +s: L.Sub) -> Frame:
  match s:
    case L.Sub{n, f}:
      lines(U32.to_nat(n), fr, tb, w, v, sector(w, seg.front(w, seg(w, f))), f)

def subsector(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +num: U32) -> Frame:
  subsector.of(fr, tb, w, v, sub(w, Bool.pick(U32, U32.is_eq(num, 65535), 0, (num .&. 32767 : U32))))

def children(+back: Bool, +n: L.Node, rest: List<&2, Item>) -> List<&2, Item>:
  match n:
    case L.Node{x, y, dx, dy, rb, lb, r, l}:
      Visit{Bool.pick(U32, back, l, r)} <> Check{Bool.pick(U32, back, r, l), Bool.pick(L.Box, back, rb, lb)} <> rest

def visit(leaf: Bool, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +num: U32, rest: List<&2, Item>) -> St:
  match leaf:
    case True{}:
      St{subsector(fr, tb, w, v, num), rest}
    case False{}:
      St{fr, children(side(v, node(w, num)), node(w, num), rest)}

def walk(n: Nat, st: St, +tb: Tabs, +w: R.World, +v: View) -> St:
  match n st:
    case 1n+p St{fr, Visit{+num} <> rest}:
      walk(p, visit(Bool.not(U32.is_eq((num .&. 32768 : U32), 0)), fr, tb, w, v, num, rest), tb, w, v)
    case 1n+p St{Frame{fb, c, f, +rs}, Check{num, +b} <> +rest}:
      walk(p, St{Frame{fb, c, f, rs}, Bool.pick(List<&2, Item>, bbox(tb, v, rs, b), Visit{num} <> rest, rest)}, tb, w, v)
    case _ s:
      s

def screen(st: St) -> Array<U32>:
  match st:
    case St{Frame{fb, c, f, rs}, items}:
      fb

def render(+tb: Tabs, +w: R.World, +v: View) -> Array<U32>:
  screen(walk(U32.to_nat(65536), St{Frame{S.blank(), T.from_list(U32, List.replicate(U32, 320n, 4294967295)), T.from_list(U32, List.replicate(U32, 320n, 200)), [Range{2147483649, 4294967295}, Range{320, 2147483647}]}, [Visit{(T.size(L.Node, nodes(w)) - 1 : U32)}]}, tb, w, v))

def locate.child(+back: Bool, +n: L.Node) -> U32:
  match n:
    case L.Node{nx, ny, dx, dy, rb, lb, r, l}:
      Bool.pick(U32, back, l, r)

def locate(n: Nat, +w: R.World, +x: U32, +y: U32, +num: U32) -> U32:
  match n:
    case 0n:
      num
    case 1n+p:
      Bool.pick(U32, U32.is_eq((num .&. 32768 : U32), 0), locate(p, w, x, y, locate.child(side(View{x, y, 0, 0, 0}, node(w, num)), node(w, num))), num)

def sector.floor(+s: L.Sector) -> U32:
  match s:
    case L.Sector{f, c, fp, cp, li, sp, tg}:
      (f << 16n : U32)

def sub.first(+s: L.Sub) -> U32:
  match s:
    case L.Sub{n, f}:
      f

def locate.first(+w: R.World, +num: U32) -> U32:
  sub.first(sub(w, Bool.pick(U32, U32.is_eq(num, 65535), 0, (num .&. 32767 : U32))))

def floor.at(+w: R.World, +x: U32, +y: U32) -> U32:
  sector.floor(sector(w, seg.front(w, seg(w, locate.first(w, locate(64n, w, x, y, (T.size(L.Node, nodes(w)) - 1 : U32)))))))
