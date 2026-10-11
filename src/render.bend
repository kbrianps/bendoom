import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./tables.bend as X
import ./level.bend as L
import ./gfx.bend as G
import ./world.bend as R
import ./screen.bend as S
import ./mem.bend as M
import ./sprite.bend as P

type Tabs is Data:
  Tabs{sine: T.Vec<U32>, tangent: T.Vec<U32>, tanto: T.Vec<U32>, v2x: T.Vec<U32>, x2a: T.Vec<U32>, clip: U32, win: U32}

type View is Data:
  View{x: U32, y: U32, z: U32, angle: U32, extra: U32, fixed: U32}

type Range is Data:
  Range{first: U32, last: U32}

type Cut is Data:
  Cut{ok: Bool, a1: U32, a2: U32}

type Frame is Type:
  Frame{fb: Array<U32>, rom: Array<U32>, ram: Array<U32>, solid: List<&2, Range>}

type Wall is Data:
  Wall{mt: M.Info, tt: M.Info, bt: M.Info, hm: Bool, ht: Bool, hb: Bool, mmid: U32, tmid: U32, bmid: U32, center: U32, offset: U32, dist: U32, light: U32,
    markc: Bool, markf: Bool, cp: U32, fp: U32, sstep: U32, tstep: U32, bstep: U32, hstep: U32, lstep: U32, mk: Bool, mtc: U32}

type Ctx is Data:
  Ctx{vx: U32, vy: U32, va: U32, bxs: U32, bys: U32, ph: U32, zl: U32, pic: U32}

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

def blocks(+wn: U32) -> U32:
  (wn >> 1n : U32)

def svw(+wn: U32) -> U32:
  Bool.pick(U32, U32.is_ge(blocks(wn), 11), 320, (blocks(wn) * 32 : U32))

def vh(+wn: U32) -> U32:
  Bool.pick(U32, U32.is_ge(blocks(wn), 11), 200, ((blocks(wn) * 168 / 10) .&. 4294967288 : U32))

def low(+wn: U32) -> Bool:
  U32.is_ne((wn .&. 1 : U32), 0)

def dshift(+wn: U32, +v: U32) -> U32:
  Bool.pick(U32, low(wn), (v >> 1n : U32), v)

def dup(+wn: U32, +v: U32) -> U32:
  Bool.pick(U32, low(wn), (v << 1n : U32), v)

def vw(+wn: U32) -> U32:
  dshift(wn, svw(wn))

def cy(+wn: U32) -> U32:
  (vh(wn) / 2 : U32)

def cxf(+wn: U32) -> U32:
  ((vw(wn) / 2) << 16n : U32)

def pscale(+wn: U32) -> U32:
  (vw(wn) * 65536 / 320 : U32)

def pis(+wn: U32) -> U32:
  (20971520 / vw(wn) : U32)

def wx(+wn: U32) -> U32:
  ((320 - svw(wn)) / 2 : U32)

def wy(+wn: U32) -> U32:
  Bool.pick(U32, U32.is_eq(svw(wn), 320), 0, ((168 - vh(wn)) / 2 : U32))

def sine(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, wn}:
      T.get(U32, s, i, 0)

def tangent(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, wn}:
      T.get(U32, t, i, 0)

def tanto(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, wn}:
      T.get(U32, a, i, 0)

def v2x(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, wn}:
      T.get(U32, v, i, 0)

def x2a(+tb: Tabs, +i: U32) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, wn}:
      T.get(U32, x, i, 0)

def clipangle(+tb: Tabs) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, wn}:
      c

def win(+tb: Tabs) -> U32:
  match tb:
    case Tabs{s, t, a, v, x, c, wn}:
      wn

def raw(+t: U32, +focal: U32, +cx: U32, +w: U32) -> U32:
  Bool.pick(U32, F.gt(t, 131072), 4294967295,
    Bool.pick(U32, F.lt(t, 4294836224), (w + 1 : U32),
      F.max(F.min(F.sar((cx - F.mul(t, focal) + 65535 : U32), 16n), (w + 1 : U32)), 4294967295)))

def raws(+n: Nat, +tan: T.Vec<U32>, +i: U32, +focal: U32, +cx: U32, +w: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      raw(T.get(U32, tan, i, 0), focal, cx, w) <> raws(p, tan, (i + 1 : U32), focal, cx, w)

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

def v2xs(+rs: List<&2, U32>, +w: U32) -> List<&2, U32>:
  match rs:
    case +r <> t:
      Bool.pick(U32, U32.is_eq(r, 4294967295), 0, Bool.pick(U32, U32.is_eq(r, (w + 1 : U32)), w, r)) <> v2xs(t, w)
    case []:
      []

def tabs.rs(+sine: T.Vec<U32>, +tan: T.Vec<U32>, +ta: T.Vec<U32>, +wn: U32, +rs: List<&2, U32>) -> Tabs:
  +x2 = T.from_list(U32, x2as(U32.to_nat((vw(wn) + 1 : U32)), rs, 0))
  Tabs{sine, tan, ta, T.from_list(U32, v2xs(rs, vw(wn))), x2, T.get(U32, x2, 0, 0), wn}

def tabs.of(+sine: T.Vec<U32>, +tan: T.Vec<U32>, +ta: T.Vec<U32>, +wn: U32) -> Tabs:
  tabs.rs(sine, tan, ta, wn, raws(4096n, tan, 0, F.div(cxf(wn), T.get(U32, tan, 3072, 0)), cxf(wn), vw(wn)))

def tabs() -> Tabs:
  tabs.of(X.finesine(), X.finetangent(), X.tantoangle(), 20)

def tabs.sized(+tb: Tabs, +wn: U32) -> Tabs:
  match tb:
    case Tabs{s, t, a, v, x, c, w0}:
      tabs.of(s, t, a, wn)

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
  scale.of(F.mul(dup(win(tb), cxf(win(tb))), sine(tb, ((ang90() + vis - normal) >> 19n : U32))), F.mul(dist, sine(tb, ((ang90() + vis - va) >> 19n : U32))))

def side.of(+x: U32, +y: U32, +nx: U32, +ny: U32, +ndx: U32, +ndy: U32) -> Bool:
  +dx = (x - nx : U32)
  +dy = (y - ny : U32)
  Bool.pick(Bool, U32.is_eq(ndx, 0), Bool.pick(Bool, F.le(x, nx), F.gt(ndy, 0), F.lt(ndy, 0)),
    Bool.pick(Bool, U32.is_eq(ndy, 0), Bool.pick(Bool, F.le(y, ny), F.lt(ndx, 0), F.gt(ndx, 0)),
      Bool.pick(Bool, F.is_neg((ndy .^. ndx .^. dx .^. dy : U32)), F.is_neg((ndy .^. dx : U32)),
        Bool.not(F.lt(F.mul(dy, F.sar(ndx, 16n)), F.mul(F.sar(ndy, 16n), dx))))))

def side(+v: View, +n: L.Node) -> Bool:
  match v n:
    case View{x, y, z, a, e, fx} L.Node{nx, ny, ndx, ndy, rb, lb, r, l}:
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
    case View{x, y, z, a, e, fx}:
      bbox.angles(tb, rs,
        (angle(tb, (coord(b, T.get(U32, checkcoord(), (pos * 4 : U32), 0)) - x : U32), (coord(b, T.get(U32, checkcoord(), (pos * 4 + 1 : U32), 0)) - y : U32)) - a : U32),
        (angle(tb, (coord(b, T.get(U32, checkcoord(), (pos * 4 + 2 : U32), 0)) - x : U32), (coord(b, T.get(U32, checkcoord(), (pos * 4 + 3 : U32), 0)) - y : U32)) - a : U32))

def bbox.pos(+v: View, +b: L.Box) -> U32:
  match v b:
    case View{x, y, z, a, e, fx} L.Box{t, bo, le, r}:
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
  R.nodes(w)

def seg(+w: R.World, +i: U32) -> R.RSeg:
  R.seg(w, i)

def rside(+w: R.World, +i: U32) -> R.RSide:
  R.side(w, i)

def sector(+w: R.World, +i: U32) -> R.RSector:
  R.sector(w, i)

def sub(+w: R.World, +i: U32) -> L.Sub:
  R.sub(w, i)

def node(+w: R.World, +i: U32) -> L.Node:
  R.node(w, i)

def tex(+w: R.World, +id: U32) -> M.Info:
  R.info(w, id)

def skyinfo(+w: R.World) -> M.Info:
  R.sky(w)

def info.height(+t: M.Info) -> U32:
  match t:
    case M.Info{m, h, b, ps}:
      h

def colbase(+t: M.Info, +c: U32) -> U32:
  match t:
    case M.Info{m, h, b, ps}:
      (b + (c .&. m) * 128 : U32)

def side.sector(+d: R.RSide) -> U32:
  match d:
    case R.RSide{xo, yo, t, b, m, s}:
      s

def seg.front(+w: R.World, +s: R.RSeg) -> U32:
  match s:
    case R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      side.sector(rside(w, sd))

def lightmap(+lw: U32, +light: U32, +scale: U32) -> U32:
  +lv = (((15 - light) * 4 : U32) - (U32.min((scale >> 12n : U32), 47) * 320 / lw) / 2 : U32)
  Bool.pick(U32, U32.is_ge(light, 256), (light - 256 : U32), Bool.pick(U32, F.lt(lv, 0), 0, Bool.pick(U32, F.gt(lv, 31), 31, lv)))

def lit(+fx: U32, +ln: U32) -> U32:
  Bool.pick(U32, U32.is_ne(fx, 0), (fx + 256 : U32), Bool.pick(U32, F.lt(ln, 0), 0, Bool.pick(U32, F.ge(ln, 16), 15, ln)))

def paint(n: Nat, fr: Frame, +x: U32, +y: U32, +frac: U32, +step: U32, +col: U32, +cm: U32) -> Frame:
  match n fr:
    case 1n+p Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(rom, (col + ((frac >> 16n) .&. 127) : U32)), rom1 => t =>
        M.let(Frame, M.rd(rom1, (cm + t : U32)), rom2 => c =>
          paint(p, Frame{S.put(fb, x, y, c), rom2, ram, sd}, x, (y + 1 : U32), (frac + step : U32), step, col, cm)))
    case _ f:
      f

def count(+yl: U32, +yh: U32) -> Nat:
  Bool.pick(Nat, F.lt(yh, yl), 0n, U32.to_nat((yh - yl + 1 : U32)))

def column(go: Bool, fr: Frame, +t: M.Info, +tc: U32, +x: U32, +yl: U32, +yh: U32, +mid: U32, +step: U32, +cm: U32, +cy: U32) -> Frame:
  match go:
    case True{}:
      paint(count(yl, yh), fr, x, yl, (mid + (yl - cy) * step : U32), step, colbase(t, tc), cm)
    case False{}:
      fr

def mark(go: Bool, ram: Array<U32>, +p: U32, +x: U32, +t: U32, +b: U32) -> Array<U32>:
  match go:
    case True{}:
      M.wr(M.wr(ram, M.top(p, x), t), M.bot(p, x), b)
    case False{}:
      ram

def maskcol(go: Bool, ram: Array<U32>, +i: U32, +v: U32) -> Array<U32>:
  match go:
    case True{}:
      M.wr(ram, i, v)
    case False{}:
      ram

def wcol.a(fb: Array<U32>, rom: Array<U32>, ram: Array<U32>, sd: List<&2, Range>, +tb: Tabs, +wl: Wall, +cl: Cols) -> Frame:
  match wl cl:
    case Wall{mt, tt, bt, hm, ht, hb, mmid, tmid, bmid, center, offset, dist, light, markc, markf, cp, fp, sstep, tstep, bstep, hstep, lstep, mk, mtc} Cols{x, scale, topf, botf, high, low}:
      M.let(Frame, M.rd(ram, (M.ceilclip() + x : U32)), ram1 => +c0 =>
        M.let(Frame, M.rd(ram1, (M.floorclip() + x : U32)), ram2 => +f0 =>
          +yl = F.max(F.sar((topf + 4095 : U32), 12n), (c0 + 1 : U32))
          +yh = F.min(F.sar(botf, 12n), (f0 - 1 : U32))
          +cbot = F.min((yl - 1 : U32), (f0 - 1 : U32))
          +ftop = F.max((yh + 1 : U32), (c0 + 1 : U32))
          ram3 = mark(Bool.and(markc, F.le((c0 + 1 : U32), cbot)), ram2, cp, x, (c0 + 1 : U32), cbot)
          ram4 = mark(Bool.and(markf, F.le(ftop, (f0 - 1 : U32))), ram3, fp, x, ftop, (f0 - 1 : U32))
          +tc = F.sar((offset - F.mul(tangent(tb, ((center + x2a(tb, x)) >> 19n : U32)), dist) : U32), 16n)
          +cm = (lightmap(svw(win(tb)), light, scale) * 256 : U32)
          +isc = (4294967295 / scale : U32)
          +tm = F.min(F.sar(high, 12n), (f0 - 1 : U32))
          +c1 = Bool.pick(U32, hm, vh(win(tb)), Bool.pick(U32, Bool.not(ht), Bool.pick(U32, markc, (yl - 1 : U32), c0), Bool.pick(U32, F.ge(tm, yl), tm, (yl - 1 : U32))))
          +bm = F.max(F.sar((low + 4095 : U32), 12n), (c1 + 1 : U32))
          +f1 = Bool.pick(U32, hm, 4294967295, Bool.pick(U32, Bool.not(hb), Bool.pick(U32, markf, (yh + 1 : U32), f0), Bool.pick(U32, F.le(bm, yh), bm, (yh + 1 : U32))))
          ram5 = M.wr(M.wr(ram4, (M.ceilclip() + x : U32), c1), (M.floorclip() + x : U32), f1)
          ram6 = maskcol(mk, ram5, (mtc + x : U32), tc)
          fr1 = column(Bool.and(Bool.not(hm), Bool.and(ht, F.ge(tm, yl))), Frame{fb, rom, ram6, sd}, tt, tc, x, yl, tm, tmid, isc, cm, cy(win(tb)))
          fr2 = column(Bool.and(Bool.not(hm), Bool.and(hb, F.le(bm, yh))), fr1, bt, tc, x, bm, yh, bmid, isc, cm, cy(win(tb)))
          column(hm, fr2, mt, tc, x, yl, yh, mmid, isc, cm, cy(win(tb)))))

def wcol(fr: Frame, +tb: Tabs, +wl: Wall, +cl: Cols) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      wcol.a(fb, rom, ram, sd, tb, wl, cl)

def next(+wl: Wall, +cl: Cols) -> Cols:
  match wl cl:
    case Wall{mt, tt, bt, hm, ht, hb, mmid, tmid, bmid, center, offset, dist, light, markc, markf, cp, fp, sstep, tstep, bstep, hstep, lstep, mk, mtc} Cols{x, scale, topf, botf, high, low}:
      Cols{(x + 1 : U32), (scale + sstep : U32), (topf + tstep : U32), (botf + bstep : U32), (high + hstep : U32), (low + lstep : U32)}

def segloop(n: Nat, fr: Frame, +tb: Tabs, +wl: Wall, +cl: Cols) -> Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      segloop(p, wcol(fr, tb, wl, cl), tb, wl, next(wl, cl))

def with.planes(+wl: Wall, +ncp: U32, +nfp: U32, +nmtc: U32) -> Wall:
  match wl:
    case Wall{mt, tt, bt, hm, ht, hb, mmid, tmid, bmid, center, offset, dist, light, markc, markf, cp, fp, sstep, tstep, bstep, hstep, lstep, mk, mtc}:
      Wall{mt, tt, bt, hm, ht, hb, mmid, tmid, bmid, center, offset, dist, light, markc, markf, ncp, nfp, sstep, tstep, bstep, hstep, lstep, mk, nmtc}

def scan(n: Nat, ram: Array<U32>, +p: U32, +x: U32, +busy: Bool) -> Array<U32> & Bool:
  match n:
    case 0n:
      (ram, busy)
    case 1n+q:
      M.let(Array<U32> & Bool, M.rd(ram, M.top(p, x)), ram1 => +t =>
        scan(q, ram1, p, (x + 1 : U32), Bool.or(busy, Bool.not(U32.is_eq(t, 255)))))

def clear(n: Nat, ram: Array<U32>, +i: U32) -> Array<U32>:
  match n:
    case 0n:
      ram
    case 1n+q:
      clear(q, M.wr(ram, i, 255), (i + 1 : U32))

def newplane(ram: Array<U32>, +n: U32, +h: U32, +pic: U32, +light: U32, +mn: U32, +mx: U32) -> Array<U32>:
  r1 = M.wr(ram, M.head(n, 0), h)
  r2 = M.wr(r1, M.head(n, 1), pic)
  r3 = M.wr(r2, M.head(n, 2), light)
  r4 = M.wr(r3, M.head(n, 3), mn)
  r5 = M.wr(r4, M.head(n, 4), mx)
  r6 = clear(322n, r5, M.top(n, 4294967295))
  M.wr(r6, M.nplanes(), U32.min((n + 1 : U32), (M.maxplanes() - 1 : U32)))

def split(ram: Array<U32>, +slot: U32, +pl: U32, +start: U32, +stop: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(ram, M.head(pl, 0)), r1 => +h =>
    M.let(Array<U32>, M.rd(r1, M.head(pl, 1)), r2 => +pic =>
      M.let(Array<U32>, M.rd(r2, M.head(pl, 2)), r3 => +light =>
        M.let(Array<U32>, M.rd(r3, M.nplanes()), r4 => +n =>
          M.wr(newplane(r4, n, h, pic, light, start, stop), slot, n)))))

def widen(ram: Array<U32>, +pl: U32, +ul: U32, +uh: U32) -> Array<U32>:
  M.wr(M.wr(ram, M.head(pl, 3), ul), M.head(pl, 4), uh)

def checkp.pick(busy: Bool, ram: Array<U32>, +slot: U32, +pl: U32, +ul: U32, +uh: U32, +start: U32, +stop: U32) -> Array<U32>:
  match busy:
    case True{}:
      split(ram, slot, pl, start, stop)
    case False{}:
      widen(ram, pl, ul, uh)

def checkp.fin(r: Array<U32> & Bool, +slot: U32, +pl: U32, +ul: U32, +uh: U32, +start: U32, +stop: U32) -> Array<U32>:
  (ram, busy) = r
  checkp.pick(busy, ram, slot, pl, ul, uh, start, stop)

def checkp.ram(ram: Array<U32>, +slot: U32, +start: U32, +stop: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(ram, slot), r1 => +pl =>
    M.let(Array<U32>, M.rd(r1, M.head(pl, 3)), r2 => +mn =>
      M.let(Array<U32>, M.rd(r2, M.head(pl, 4)), r3 => +mx =>
        +il = Bool.pick(U32, F.lt(start, mn), mn, start)
        +ih = Bool.pick(U32, F.gt(stop, mx), mx, stop)
        checkp.fin(scan(count(il, ih), r3, pl, il, False{}), slot, pl, Bool.pick(U32, F.lt(start, mn), start, mn), Bool.pick(U32, F.gt(stop, mx), stop, mx), start, stop))))

def checkp(go: Bool, fr: Frame, +slot: U32, +start: U32, +stop: U32) -> Frame:
  match go fr:
    case True{} Frame{fb, rom, ram, sd}:
      Frame{fb, rom, checkp.ram(ram, slot, start, stop), sd}
    case _ f:
      f

def search(n: Nat, ram: Array<U32>, +i: U32, +h: U32, +pic: U32, +light: U32, +found: U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (ram, found)
    case 1n+q:
      M.let(Array<U32> & U32, M.rd(ram, M.head(i, 0)), r1 => +a =>
        M.let(Array<U32> & U32, M.rd(r1, M.head(i, 1)), r2 => +b =>
          M.let(Array<U32> & U32, M.rd(r2, M.head(i, 2)), r3 => +c =>
            +hit = Bool.and(U32.is_eq(found, 65535), Bool.and(U32.is_eq(a, h), Bool.and(U32.is_eq(b, pic), U32.is_eq(c, light))))
            search(q, r3, (i + 1 : U32), h, pic, light, Bool.pick(U32, hit, i, found)))))

def findp.pick(fresh: Bool, ram: Array<U32>, +slot: U32, +n: U32, +h: U32, +pic: U32, +light: U32, +found: U32) -> Array<U32>:
  match fresh:
    case True{}:
      M.wr(newplane(ram, n, h, pic, light, 320, 4294967295), slot, n)
    case False{}:
      M.wr(ram, slot, found)

def findp.got(r: Array<U32> & U32, +slot: U32, +n: U32, +h: U32, +pic: U32, +light: U32) -> Array<U32>:
  (ram, +found) = r
  findp.pick(U32.is_eq(found, 65535), ram, slot, n, h, pic, light, found)

def findp.ram(ram: Array<U32>, +slot: U32, +h: U32, +pic: U32, +light: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(ram, M.nplanes()), r1 => +n =>
    findp.got(search(U32.to_nat(n), r1, 0, h, pic, light, 65535), slot, n, h, pic, light))

def findp(go: Bool, fr: Frame, +slot: U32, +h: U32, +pic: U32, +light: U32) -> Frame:
  match go fr:
    case True{} Frame{fb, rom, ram, sd}:
      +sky = U32.is_eq(pic, M.sky())
      Frame{fb, rom, findp.ram(ram, slot, Bool.pick(U32, sky, 0, h), pic, Bool.pick(U32, sky, 0, light)), sd}
    case False{} Frame{fb, rom, ram, sd}:
      Frame{fb, rom, M.wr(ram, slot, 65535), sd}

def copyn(n: Nat, ram: Array<U32>, +src: U32, +dst: U32) -> Array<U32>:
  match n:
    case 0n:
      ram
    case 1n+p:
      M.let(Array<U32>, M.rd(ram, src), r1 => v =>
        copyn(p, M.wr(r1, dst, v), (src + 1 : U32), (dst + 1 : U32)))

def dsclip(go: Bool, ram: Array<U32>, +d: U32, +k: U32, +src: U32, +start: U32, +stop: U32) -> Array<U32>:
  match go:
    case True{}:
      M.let(Array<U32>, M.rd(ram, M.lastopening()), r1 => +lo =>
        r2 = copyn(U32.to_nat((stop - start + 1 : U32)), r1, (src + start : U32), lo)
        r3 = M.wr(r2, M.ds(d, k), (lo - start : U32))
        M.wr(r3, M.lastopening(), (lo + stop - start + 1 : U32)))
    case False{}:
      ram

def dsfix(ram: Array<U32>, +d: U32, +masked: Bool) -> Array<U32>:
  M.let(Array<U32>, M.rd(ram, M.ds(d, 5)), r1 => +sil =>
    +addt = Bool.and(masked, U32.is_eq((sil .&. 2 : U32), 0))
    +addb = Bool.and(masked, U32.is_eq((sil .&. 1 : U32), 0))
    r2 = M.wr(r1, M.ds(d, 5), (sil .|. Bool.pick(U32, addt, 2, 0) .|. Bool.pick(U32, addb, 1, 0) : U32))
    M.let(Array<U32>, M.rd(r2, M.ds(d, 7)), r3 => +ts =>
      M.let(Array<U32>, M.rd(r3, M.ds(d, 6)), r4 => +bs =>
        M.wr(M.wr(r4, M.ds(d, 7), Bool.pick(U32, addt, 2147483648, ts)), M.ds(d, 6), Bool.pick(U32, addb, 2147483647, bs)))))

def dsend(ram: Array<U32>, +d: U32, +start: U32, +stop: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(ram, M.ds(d, 5)), r1 => +sil =>
    M.let(Array<U32>, M.rd(r1, M.ds(d, 8)), r2 => +tc =>
      M.let(Array<U32>, M.rd(r2, M.ds(d, 9)), r3 => +bc =>
        M.let(Array<U32>, M.rd(r3, M.ds(d, 10)), r4 => +mc =>
          +masked = Bool.not(U32.is_eq(mc, M.none()))
          r5 = dsclip(Bool.and(Bool.or(Bool.not(U32.is_eq((sil .&. 2 : U32), 0)), masked), U32.is_eq(tc, M.none())), r4, d, 8, M.ceilclip(), start, stop)
          r6 = dsclip(Bool.and(Bool.or(Bool.not(U32.is_eq((sil .&. 1 : U32), 0)), masked), U32.is_eq(bc, M.none())), r5, d, 9, M.floorclip(), start, stop)
          r7 = dsfix(r6, d, masked)
          M.wr(r7, M.ndrawsegs(), U32.min((d + 1 : U32), (M.maxdrawsegs() - 1 : U32)))))))

def dsmask(go: Bool, ram: Array<U32>, +d: U32, +start: U32, +stop: U32) -> Array<U32>:
  match go:
    case True{}:
      M.let(Array<U32>, M.rd(ram, M.lastopening()), r1 => +lo =>
        M.wr(M.wr(r1, M.ds(d, 10), (lo - start : U32)), M.lastopening(), (lo + stop - start + 1 : U32)))
    case False{}:
      M.wr(ram, M.ds(d, 10), M.none())

def dsbegin(ram: Array<U32>, +si: U32, +start: U32, +stop: U32, +s1: U32, +s2: U32, +step: U32, +sil: U32, +bsil: U32, +tsil: U32, +tclip: U32, +bclip: U32, +masked: Bool) -> Array<U32>:
  M.let(Array<U32>, M.rd(ram, M.ndrawsegs()), r1 => +d =>
    r2 = M.wr(M.wr(M.wr(M.wr(r1, M.ds(d, 0), start), M.ds(d, 1), stop), M.ds(d, 2), s1), M.ds(d, 3), s2)
    r3 = M.wr(M.wr(M.wr(M.wr(r2, M.ds(d, 4), step), M.ds(d, 5), sil), M.ds(d, 6), bsil), M.ds(d, 7), tsil)
    r4 = M.wr(M.wr(M.wr(r3, M.ds(d, 8), tclip), M.ds(d, 9), bclip), M.ds(d, 11), si)
    dsmask(masked, r4, d, start, stop))

def store.end(fr: Frame, +d: U32, +start: U32, +stop: U32) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      Frame{fb, rom, dsend(ram, d, start, stop), sd}

def store.run(fr: Frame, +tb: Tabs, +wl: Wall, +cl: Cols, +n: Nat, +start: U32, +stop: U32) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(ram, M.curceil()), ram1 => +cp =>
        M.let(Frame, M.rd(ram1, M.curfloor()), ram2 => +fp =>
          M.let(Frame, M.rd(ram2, M.ndrawsegs()), ram3 => +d =>
            M.let(Frame, M.rd(ram3, M.ds(d, 10)), ram4 => +mc =>
              store.end(segloop(n, Frame{fb, rom, ram4, sd}, tb, with.planes(wl, cp, fp, mc), cl), d, start, stop)))))

def store.begin(fr: Frame, +si: U32, +start: U32, +stop: U32, +s1: U32, +s2: U32, +step: U32, +sil: U32, +bsil: U32, +tsil: U32, +tclip: U32, +bclip: U32, +masked: Bool) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      Frame{fb, rom, dsbegin(ram, si, start, stop, s1, s2, step, sil, bsil, tsil, tclip, bclip, masked), sd}

def store.sec(fr: Frame, +si: U32, +tb: Tabs, +w: R.World, +vx: U32, +vy: U32, +vz: U32, +va: U32, +ex: U32, +fx: U32, +x1: U32, +y1: U32, +x2: U32, +y2: U32, +an: U32, +of: U32, +fl: U32, +bk: U32, +xoff: U32, +yoff: U32, +top: U32, +bot: U32, +mid: U32, +a1: U32, +start: U32, +stop: U32, +fs: R.RSector, +bs: R.RSector) -> Frame:
  match fs bs:
    case R.RSector{ff, fc, fp, fq, fli, fsp, ftg, _, _} R.RSector{bf, bc, bp, bq, bli, bsp, btg, _, _}:
      +normal = (an + ang90() : U32)
      +oa0 = F.abs((normal - a1 : U32))
      +oa = Bool.pick(U32, U32.is_gt(oa0, ang90()), ang90(), oa0)
      +hyp = dist(tb, (x1 - vx : U32), (y1 - vy : U32))
      +rwd = F.mul(hyp, sine(tb, ((ang90() - oa) >> 19n : U32)))
      +s1 = scale(tb, (va + x2a(tb, start) : U32), va, normal, rwd)
      +s2 = scale(tb, (va + x2a(tb, stop) : U32), va, normal, rwd)
      +sstep = Bool.pick(U32, F.gt(stop, start), F.quot((s2 - s1 : U32), (stop - start : U32)), 0)
      +one = U32.is_eq(bk, 65535)
      +fsky = U32.is_eq(fq, M.sky())
      +bsky = U32.is_eq(bq, M.sky())
      +wtop0 = (fc - vz : U32)
      +wbot = (ff - vz : U32)
      +whigh = (bc - vz : U32)
      +wlow = (bf - vz : U32)
      +wtop = Bool.pick(U32, Bool.and(Bool.not(one), Bool.and(fsky, bsky)), whigh, wtop0)
      +closed = Bool.or(F.le(bc, ff), F.ge(bf, fc))
      +ldiff = Bool.not(U32.is_eq(fli, bli))
      +markf0 = Bool.or(Bool.or(one, closed), Bool.or(Bool.or(Bool.not(U32.is_eq(wlow, wbot)), Bool.not(U32.is_eq(fp, bp))), ldiff))
      +markc0 = Bool.or(Bool.or(one, closed), Bool.or(Bool.or(Bool.not(U32.is_eq(whigh, wtop)), Bool.not(U32.is_eq(fq, bq))), ldiff))
      +hm = Bool.and(one, Bool.not(U32.is_eq(mid, 0)))
      +ht = Bool.and(Bool.not(one), Bool.and(F.lt(whigh, wtop), Bool.not(U32.is_eq(top, 0))))
      +hb = Bool.and(Bool.not(one), Bool.and(F.gt(wlow, wbot), Bool.not(U32.is_eq(bot, 0))))
      +mt = tex(w, mid)
      +tt = tex(w, top)
      +bt = tex(w, bot)
      +peglo = Bool.not(U32.is_eq((fl .&. 16 : U32), 0))
      +peghi = Bool.not(U32.is_eq((fl .&. 8 : U32), 0))
      +mmid = (Bool.pick(U32, peglo, (ff + info.height(mt) - vz : U32), wtop) + yoff : U32)
      +tmid = (Bool.pick(U32, peghi, wtop, (bc + info.height(tt) - vz : U32)) + yoff : U32)
      +bmid = (Bool.pick(U32, peglo, wtop, wlow) + yoff : U32)
      +ro = (normal - a1 : U32)
      +ra = Bool.pick(U32, U32.is_gt(ro, ang180()), (0 - ro : U32), ro)
      +rb = Bool.pick(U32, U32.is_gt(ra, ang90()), ang90(), ra)
      +off0 = F.mul(hyp, sine(tb, (rb >> 19n : U32)))
      +off = (Bool.pick(U32, U32.is_lt(ro, ang180()), (0 - off0 : U32), off0) + xoff + of : U32)
      +center = (ang90() + va - normal : U32)
      +ln0 = ((fli >> 4n) + ex : U32)
      +ln = Bool.pick(U32, U32.is_eq(y1, y2), (ln0 - 1 : U32), Bool.pick(U32, U32.is_eq(x1, x2), (ln0 + 1 : U32), ln0))
      +light = lit(fx, ln)
      +markf = Bool.and(markf0, F.lt(ff, vz))
      +markc = Bool.and(markc0, Bool.or(F.gt(fc, vz), fsky))
      +wt = F.sar(wtop, 4n)
      +wb = F.sar(wbot, 4n)
      +wh = F.sar(whigh, 4n)
      +wl = F.sar(wlow, 4n)
      +masked = Bool.and(Bool.not(one), Bool.not(U32.is_eq(mid, 0)))
      +b1 = Bool.or(F.gt(ff, bf), F.gt(bf, vz))
      +t1 = Bool.or(F.lt(fc, bc), F.lt(bc, vz))
      +bcl = F.le(bc, ff)
      +tcl = F.ge(bf, fc)
      +sil = Bool.pick(U32, one, 3, (Bool.pick(U32, Bool.or(b1, bcl), 1, 0) .|. Bool.pick(U32, Bool.or(t1, tcl), 2, 0) : U32))
      +bsil = Bool.pick(U32, Bool.or(one, bcl), 2147483647, Bool.pick(U32, F.gt(ff, bf), ff, 2147483647))
      +tsil = Bool.pick(U32, Bool.or(one, tcl), 2147483648, Bool.pick(U32, F.lt(fc, bc), fc, 2147483648))
      +tclip = Bool.pick(U32, Bool.or(one, tcl), M.screenh(), M.none())
      +bclip = Bool.pick(U32, Bool.or(one, bcl), M.negone(), M.none())
      fr1 = checkp(markc, fr, M.curceil(), start, stop)
      fr2 = checkp(markf, fr1, M.curfloor(), start, stop)
      fr3 = store.begin(fr2, si, start, stop, s1, Bool.pick(U32, F.gt(stop, start), s2, s1), sstep, sil, bsil, tsil, tclip, bclip, masked)
      store.run(fr3, tb,
        Wall{mt, tt, bt, hm, ht, hb, mmid, tmid, bmid, center, off, rwd, light, markc, markf, 0, 0, sstep,
          F.neg(F.mul(sstep, wt)), F.neg(F.mul(sstep, wb)),
          Bool.pick(U32, ht, F.neg(F.mul(sstep, wh)), 0),
          Bool.pick(U32, hb, F.neg(F.mul(sstep, wl)), 0), masked, 0},
        Cols{start, s1, ((cy(win(tb)) << 12n) - F.mul(wt, s1) : U32), ((cy(win(tb)) << 12n) - F.mul(wb, s1) : U32), ((cy(win(tb)) << 12n) - F.mul(wh, s1) : U32), ((cy(win(tb)) << 12n) - F.mul(wl, s1) : U32)},
        U32.to_nat((stop - start + 1 : U32)), start, stop)

def store.side(fr: Frame, +si: U32, +tb: Tabs, +w: R.World, +vx: U32, +vy: U32, +vz: U32, +va: U32, +ex: U32, +fx: U32, +x1: U32, +y1: U32, +x2: U32, +y2: U32, +an: U32, +of: U32, +fl: U32, +bk: U32, +sd: R.RSide, +a1: U32, +start: U32, +stop: U32) -> Frame:
  match sd:
    case R.RSide{xo, yo, t, b, m, sec}:
      store.sec(fr, si, tb, w, vx, vy, vz, va, ex, fx, x1, y1, x2, y2, an, of, fl, bk, xo, yo, t, b, m, a1, start, stop, sector(w, sec), sector(w, bk))

def store(fr: Frame, +si: U32, +tb: Tabs, +w: R.World, +v: View, +sg: R.RSeg, +a1: U32, +start: U32, +stop: U32) -> Frame:
  match v sg:
    case View{vx, vy, vz, va, ex, fx} R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      store.side(fr, si, tb, w, vx, vy, vz, va, ex, fx, x1, y1, x2, y2, an, of, fl, bk, rside(w, sd), a1, start, stop)

def stores(gs: List<&2, Range>, fr: Frame, +si: U32, +tb: Tabs, +w: R.World, +v: View, +sg: R.RSeg, +a1: U32) -> Frame:
  match gs:
    case Range{f, l} <> t:
      stores(t, store(fr, si, tb, w, v, sg, a1, f, l), si, tb, w, v, sg, a1)
    case []:
      fr

def clip(solid: Bool, fr: Frame, +si: U32, +tb: Tabs, +w: R.World, +v: View, +sg: R.RSeg, +a1: U32, +first: U32, +last: U32) -> Frame:
  match fr:
    case Frame{fb, rom, ram, +rs}:
      stores(gaps(rs, first, last), Frame{fb, rom, ram, Bool.pick(List<&2, Range>, solid, merge(rs, first, last), rs)}, si, tb, w, v, sg, a1)

def kind.of(+fs: R.RSector, +bs: R.RSector, +sd: R.RSide) -> U32:
  match fs bs sd:
    case R.RSector{ff, fc, fp, fq, fli, fsp, ftg, _, _} R.RSector{bf, bc, bp, bq, bli, bsp, btg, _, _} R.RSide{xo, yo, t, b, m, s}:
      Bool.pick(U32, Bool.or(F.le(bc, ff), F.ge(bf, fc)), 1,
        Bool.pick(U32, Bool.or(Bool.not(U32.is_eq(bc, fc)), Bool.not(U32.is_eq(bf, ff))), 2,
          Bool.pick(U32, Bool.and(Bool.and(U32.is_eq(bq, fq), U32.is_eq(bp, fp)), Bool.and(U32.is_eq(bli, fli), U32.is_eq(m, 0))), 0, 2)))

def kind(+w: R.World, +fs: R.RSector, +sg: R.RSeg) -> U32:
  match sg:
    case R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      Bool.pick(U32, U32.is_eq(bk, 65535), 1, kind.of(fs, sector(w, bk), rside(w, sd)))

def addline.go(go: Bool, fr: Frame, +si: U32, +tb: Tabs, +w: R.World, +v: View, +sg: R.RSeg, +a1: U32, +k: U32, +sx1: U32, +sx2: U32) -> Frame:
  match go:
    case True{}:
      clip(U32.is_eq(k, 1), fr, si, tb, w, v, sg, a1, sx1, (sx2 - 1 : U32))
    case False{}:
      fr

def addline.cut(fr: Frame, +si: U32, +tb: Tabs, +w: R.World, +v: View, +fs: R.RSector, +sg: R.RSeg, +a1: U32, +front: Bool, +c: Cut) -> Frame:
  match c:
    case Cut{ok, c1, c2}:
      +sx1 = v2x(tb, ((c1 + ang90()) >> 19n : U32))
      +sx2 = v2x(tb, ((c2 + ang90()) >> 19n : U32))
      +k = kind(w, fs, sg)
      addline.go(Bool.and(Bool.and(front, ok), Bool.and(Bool.not(U32.is_eq(sx1, sx2)), Bool.not(U32.is_eq(k, 0)))), fr, si, tb, w, v, sg, a1, k, sx1, sx2)

def addline(fr: Frame, +si: U32, +tb: Tabs, +w: R.World, +v: View, +fs: R.RSector, +sg: R.RSeg) -> Frame:
  match v sg:
    case View{vx, vy, vz, va, ex, fx} R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      +a1 = angle(tb, (x1 - vx : U32), (y1 - vy : U32))
      +a2 = angle(tb, (x2 - vx : U32), (y2 - vy : U32))
      addline.cut(fr, si, tb, w, v, fs, sg, a1, U32.is_lt((a1 - a2 : U32), ang180()), cut(clipangle(tb), (a1 - va : U32), (a2 - va : U32), (a1 - a2 : U32)))

def lines(n: Nat, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +fs: R.RSector, +i: U32) -> Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      lines(p, addline(fr, i, tb, w, v, fs, seg(w, i)), tb, w, v, fs, (i + 1 : U32))

def subsector.planes(fr: Frame, +v: View, +fs: R.RSector) -> Frame:
  match v fs:
    case View{vx, vy, +vz, va, ex, fx} R.RSector{+f, +c, +fp, +cp, +li, sp, tg, _, _}:
      fr1 = findp(F.lt(f, vz), fr, M.curfloor(), f, fp, li)
      findp(Bool.or(F.gt(c, vz), U32.is_eq(cp, M.sky())), fr1, M.curceil(), c, cp, li)

def mobj(+w: R.World, +i: U32) -> R.RThing:
  R.thing(w, i)

def secthings(+w: R.World, +i: U32) -> List<&2, U32>:
  R.secthings(w, i)

def sframe(+w: R.World, +c: U32) -> P.SFrame:
  R.sframe(w, c)

def pick8(+r: U32, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32) -> U32:
  Bool.pick(U32, U32.is_lt(r, 4),
    Bool.pick(U32, U32.is_lt(r, 2), Bool.pick(U32, U32.is_eq(r, 0), a, b), Bool.pick(U32, U32.is_eq(r, 2), c, d)),
    Bool.pick(U32, U32.is_lt(r, 6), Bool.pick(U32, U32.is_eq(r, 4), e, f), Bool.pick(U32, U32.is_eq(r, 6), g, h)))

def sf.lump(+f: P.SFrame, +rot: U32) -> U32:
  match f:
    case P.SFrame{r, a, b, c, d, e, g, h, i, fl}:
      Bool.pick(U32, r, pick8(rot, a, b, c, d, e, g, h, i), a)

def sf.flip(+f: P.SFrame, +rot: U32) -> Bool:
  match f:
    case P.SFrame{r, a, b, c, d, e, g, h, i, +fl}:
      Bool.not(U32.is_eq(((fl >> U32.to_nat(Bool.pick(U32, r, rot, 0))) .&. 1 : U32), 0))

def s16(+v: U32) -> U32:
  Bool.pick(U32, U32.is_ge(v, 32768), (v - 65536 : U32), v)

def vis.put(go: Bool, ram: Array<U32>, +x1: U32, +x2: U32, +scale: U32, +gx: U32, +gy: U32, +gz: U32, +gzt: U32, +mid: U32, +start: U32, +step: U32, +patch: U32, +cm: U32, +fl: U32) -> Array<U32>:
  match go:
    case True{}:
      M.let(Array<U32>, M.rd(ram, M.nvis()), r1 => +n =>
        r2 = M.wr(M.wr(M.wr(M.wr(r1, M.vs(n, 0), x1), M.vs(n, 1), x2), M.vs(n, 2), scale), M.vs(n, 3), gx)
        r3 = M.wr(M.wr(M.wr(M.wr(r2, M.vs(n, 4), gy), M.vs(n, 5), gz), M.vs(n, 6), gzt), M.vs(n, 7), mid)
        r4 = M.wr(M.wr(M.wr(M.wr(r3, M.vs(n, 8), start), M.vs(n, 9), step), M.vs(n, 10), patch), M.vs(n, 11), cm)
        M.wr(M.wr(r4, M.vs(n, 12), fl), M.nvis(), U32.min((n + 1 : U32), (M.maxvis() - 1 : U32))))
    case False{}:
      ram

def project.at(ram: Array<U32>, +tb: Tabs, +vz: U32, +light: U32, +t: R.RThing, +tx: U32, +xscale: U32, +ok: Bool, +patch: U32, +flip: Bool, +width: U32, +left: U32, +top: U32) -> Array<U32>:
  match t:
    case R.RThing{x, y, z, an, spr, frm, fl}:
      +tx1 = (tx - (left << 16n) : U32)
      +wn = win(tb)
      +x1 = F.sar((cxf(wn) + F.mul(tx1, xscale) : U32), 16n)
      +x2 = (F.sar((cxf(wn) + F.mul((tx1 + (width << 16n) : U32), xscale) : U32), 16n) - 1 : U32)
      +vx1 = F.max(x1, 0)
      +iscale = F.div(65536, xscale)
      +step = Bool.pick(U32, flip, F.neg(iscale), iscale)
      +start = (Bool.pick(U32, flip, ((width << 16n) - 1 : U32), 0) + Bool.pick(U32, F.gt(vx1, x1), (step * (vx1 - x1) : U32), 0) : U32)
      +gzt = (z + (top << 16n) : U32)
      +cm = Bool.pick(U32, Bool.not(U32.is_eq((fl .&. 262144 : U32), 0)), M.none(), Bool.pick(U32, Bool.and(U32.is_lt(light, 256), Bool.not(U32.is_eq((frm .&. 32768 : U32), 0))), 0, (lightmap(svw(wn), light, dup(wn, xscale)) * 256 : U32)))
      +tr = ((fl >> 26n) .&. 3 : U32)
      +cmt = Bool.pick(U32, U32.is_eq(cm, M.none()), cm, (cm .|. (tr << 28n) : U32))
      vis.put(Bool.and(ok, Bool.and(Bool.not(F.gt(x1, vw(wn))), Bool.not(F.lt(x2, 0)))), ram, vx1, F.min(x2, (vw(wn) - 1 : U32)), dup(wn, xscale), x, y, z, gzt, (gzt - vz : U32), start, step, patch, cmt, fl)

def project.hdr(fr: Frame, +tb: Tabs, +vz: U32, +light: U32, +t: R.RThing, +tx: U32, +xscale: U32, +ok: Bool, +patch: U32, +flip: Bool) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(rom, patch), r1 => +w0 =>
        M.let(Frame, M.rd(r1, (patch + 1 : U32)), r2 => +w1 =>
          M.let(Frame, M.rd(r2, (patch + 4 : U32)), r3 => +l0 =>
            M.let(Frame, M.rd(r3, (patch + 5 : U32)), r4 => +l1 =>
              M.let(Frame, M.rd(r4, (patch + 6 : U32)), r5 => +t0 =>
                M.let(Frame, M.rd(r5, (patch + 7 : U32)), r6 => +t1 =>
                  Frame{fb, r6, project.at(ram, tb, vz, light, t, tx, xscale, ok, patch, flip, (w0 .|. (w1 << 8n) : U32), s16((l0 .|. (l1 << 8n) : U32)), s16((t0 .|. (t1 << 8n) : U32))), sd}))))))

def project(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +light: U32, +t: R.RThing) -> Frame:
  match v t:
    case View{vx, vy, vz, va, ex, fx} R.RThing{x, y, z, an, spr, frm, fl}:
      +vs = sine(tb, (va >> 19n : U32))
      +vc = sine(tb, ((va >> 19n) + 2048 : U32))
      +trx = (x - vx : U32)
      +try = (y - vy : U32)
      +tz = (F.mul(trx, vc) + F.mul(try, vs) : U32)
      +tx = F.neg((F.mul(try, vc) - F.mul(trx, vs) : U32))
      +ok = Bool.and(F.ge(tz, 262144), Bool.not(F.gt(F.abs(tx), (tz << 2n : U32))))
      +xscale = F.div(cxf(win(tb)), F.max(tz, 262144))
      +sf = sframe(w, (spr * 32 + (frm .&. 31) : U32))
      +rot = ((angle(tb, trx, try) - an + 2415919104) >> 29n : U32)
      project.hdr(fr, tb, vz, light, t, tx, xscale, ok, sf.lump(sf, rot), sf.flip(sf, rot))

def sprites.list(ts: List<&2, U32>, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +light: U32) -> Frame:
  match ts:
    case +i <> r:
      sprites.list(r, project(fr, tb, w, v, light, mobj(w, i)), tb, w, v, light)
    case []:
      fr

def sprites.if(go: Bool, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +sec: U32, +light: U32) -> Frame:
  match go fr v:
    case True{} Frame{fb, rom, ram, sd} View{vx, vy, vz, va, ex, fx}:
      +ll = ((light >> 4n) + ex : U32)
      sprites.list(secthings(w, sec), Frame{fb, rom, M.wr(ram, (M.secseen() + sec : U32), 1), sd}, tb, w, v, lit(fx, ll))
    case _ f _:
      f

def addsprites(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +sec: U32, +light: U32) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(ram, (M.secseen() + sec : U32)), r1 => +seen =>
        sprites.if(U32.is_eq(seen, 0), Frame{fb, rom, r1, sd}, tb, w, v, sec, light))

def sec.ceil(+s: R.RSector) -> U32:
  match s:
    case R.RSector{f, c, fp, cp, li, sp, tg, _, _}:
      c

def sec.floor(+s: R.RSector) -> U32:
  match s:
    case R.RSector{f, c, fp, cp, li, sp, tg, _, _}:
      f

def sec.light(+s: R.RSector) -> U32:
  match s:
    case R.RSector{f, c, fp, cp, li, sp, tg, _, _}:
      li

def subsector.of(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +s: L.Sub) -> Frame:
  match s:
    case L.Sub{n, f}:
      +fi = seg.front(w, seg(w, f))
      +fs = sector(w, fi)
      lines(U32.to_nat(n), addsprites(subsector.planes(fr, v, fs), tb, w, v, fi, sec.light(fs)), tb, w, v, fs, f)

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
    case 1n+p St{Frame{fb, rom, ram, +rs}, Check{num, +b} <> +rest}:
      walk(p, St{Frame{fb, rom, ram, rs}, Bool.pick(List<&2, Item>, bbox(tb, v, rs, b), Visit{num} <> rest, rest)}, tb, w, v)
    case _ s:
      s

def frame(st: St) -> Frame:
  match st:
    case St{fr, items}:
      fr

def skycol(fr: Frame, +tb: Tabs, +sk: M.Info, +va: U32, +p: U32, +x: U32) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(ram, M.top(p, x)), r1 => +t =>
        M.let(Frame, M.rd(r1, M.bot(p, x)), r2 => +b =>
          +wn = win(tb)
          +isc = dshift(wn, pis(wn))
          paint(count(t, b), Frame{fb, rom, r2, sd}, x, t, (6553600 + (t - cy(wn)) * isc : U32), isc, colbase(sk, ((va + x2a(tb, x)) >> 22n : U32)), M.cmap())))

def skycols(n: Nat, fr: Frame, +tb: Tabs, +sk: M.Info, +va: U32, +p: U32, +x: U32) -> Frame:
  match n:
    case 0n:
      fr
    case 1n+q:
      skycols(q, skycol(fr, tb, sk, va, p, x), tb, sk, va, p, (x + 1 : U32))

def spanpaint.go(n: Nat, fr: Frame, +x: U32, +y: U32, +pos: U32, +step: U32, +pic: U32, +cm: U32) -> Frame:
  match n fr:
    case 1n+p Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(rom, (pic + ((pos >> 4n) .&. 4032) + (pos >> 26n) : U32)), rom1 => +t =>
        M.let(Frame, M.rd(rom1, (cm + t : U32)), rom2 => +c =>
          spanpaint.go(p, Frame{S.put(fb, x, y, c), rom2, ram, sd}, (x + 1 : U32), y, (pos + step : U32), step, pic, cm)))
    case _ f:
      f

def pack(+xf: U32, +yf: U32) -> U32:
  (((xf << 10n) .&. 4294901760) .|. ((yf >> 6n) .&. 65535) : U32)

def spanpaint(n: Nat, fr: Frame, +x: U32, +y: U32, +xf: U32, +yf: U32, +xs: U32, +ys: U32, +pic: U32, +cm: U32) -> Frame:
  spanpaint.go(n, fr, x, y, pack(xf, yf), pack(xs, ys), pic, cm)

def mapplane(fr: Frame, +tb: Tabs, +cx: Ctx, +y: U32, +x1: U32, +x2: U32) -> Frame:
  match fr cx:
    case Frame{fb, rom, ram, sd} Ctx{vx, vy, va, bxs, bys, ph, zl, pic}:
      M.let(Frame, M.rd(rom, (M.yslope() + y : U32)), rom1 => +ys =>
        M.let(Frame, M.rd(rom1, (M.distscale() + x1 : U32)), rom2 => +ds =>
          +dist = F.mul(ph, ys)
          +len = F.mul(dist, ds)
          +an = ((va + x2a(tb, x1)) >> 19n : U32)
          +fixed = U32.is_ge(zl, 2147483648)
          M.let(Frame, M.rd(rom2, (Bool.pick(U32, fixed, M.zlight(), zl) + U32.min((dist >> 20n : U32), 127) : U32)), rom3 => +cm0 =>
            +cm = Bool.pick(U32, fixed, ((zl - 2147483648 : U32) * 256 : U32), cm0)
            spanpaint(count(x1, x2), Frame{fb, rom3, ram, sd}, x1, y,
              (vx + F.mul(sine(tb, (an + 2048 : U32)), len) : U32),
              ((0 - vy : U32) - F.mul(sine(tb, an), len) : U32),
              F.mul(dist, bxs), F.mul(dist, bys), pic, cm))))

def span.start(fr: Frame, +y: U32) -> Frame & U32:
  match fr:
    case Frame{fb, rom, ram, sd}:
      M.let(Frame & U32, M.rd(ram, (M.spanstart() + y : U32)), r1 => +s =>
        (Frame{fb, rom, r1, sd}, s))

def span.map(r: Frame & U32, +tb: Tabs, +cx: Ctx, +y: U32, +x: U32) -> Frame:
  (fr, +s) = r
  mapplane(fr, tb, cx, y, s, (x - 1 : U32))

def span.set(fr: Frame, +y: U32, +x: U32) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      Frame{fb, rom, M.wr(ram, (M.spanstart() + y : U32), x), sd}

def loop1(n: Nat, go: Bool, fr: Frame, +tb: Tabs, +cx: Ctx, +x: U32, +t1: U32, +b1: U32, +t2: U32) -> Frame & U32:
  match n go:
    case 1n+p True{}:
      loop1(p, Bool.and(U32.is_lt((t1 + 1 : U32), t2), U32.is_le((t1 + 1 : U32), b1)), span.map(span.start(fr, t1), tb, cx, t1, x), tb, cx, x, (t1 + 1 : U32), b1, t2)
    case _ _:
      (fr, t1)

def loop2(n: Nat, go: Bool, fr: Frame, +tb: Tabs, +cx: Ctx, +x: U32, +t1: U32, +b1: U32, +b2: U32) -> Frame & U32:
  match n go:
    case 1n+p True{}:
      loop2(p, Bool.and(U32.is_gt((b1 - 1 : U32), b2), Bool.and(U32.is_ge((b1 - 1 : U32), t1), U32.is_gt(b1, 0))), span.map(span.start(fr, b1), tb, cx, b1, x), tb, cx, x, t1, (b1 - 1 : U32), b2)
    case _ _:
      (fr, b1)

def loop3(n: Nat, go: Bool, fr: Frame, +x: U32, +t1: U32, +t2: U32, +b2: U32) -> Frame & U32:
  match n go:
    case 1n+p True{}:
      loop3(p, Bool.and(U32.is_lt((t2 + 1 : U32), t1), U32.is_le((t2 + 1 : U32), b2)), span.set(fr, t2, x), x, t1, (t2 + 1 : U32), b2)
    case _ _:
      (fr, t2)

def loop4(n: Nat, go: Bool, fr: Frame, +x: U32, +b1: U32, +t2: U32, +b2: U32) -> Frame:
  match n go:
    case 1n+p True{}:
      loop4(p, Bool.and(U32.is_gt((b2 - 1 : U32), b1), Bool.and(U32.is_ge((b2 - 1 : U32), t2), U32.is_gt(b2, 0))), span.set(fr, b2, x), x, b1, t2, (b2 - 1 : U32))
    case _ _:
      fr

def spans.d(r: Frame & U32, +x: U32, +b1: U32, +b2: U32) -> Frame:
  (fr, +t2) = r
  loop4(256n, Bool.and(U32.is_gt(b2, b1), U32.is_ge(b2, t2)), fr, x, b1, t2, b2)

def spans.c(r: Frame & U32, +x: U32, +t1: U32, +t2: U32, +b2: U32) -> Frame:
  (fr, +b1) = r
  spans.d(loop3(256n, Bool.and(U32.is_lt(t2, t1), U32.is_le(t2, b2)), fr, x, t1, t2, b2), x, b1, b2)

def spans.b(r: Frame & U32, +tb: Tabs, +cx: Ctx, +x: U32, +b1: U32, +t2: U32, +b2: U32) -> Frame:
  (fr, +t1) = r
  spans.c(loop2(256n, Bool.and(U32.is_gt(b1, b2), U32.is_ge(b1, t1)), fr, tb, cx, x, t1, b1, b2), x, t1, t2, b2)

def makespans(fr: Frame, +tb: Tabs, +cx: Ctx, +x: U32, +t1: U32, +b1: U32, +t2: U32, +b2: U32) -> Frame:
  spans.b(loop1(256n, Bool.and(U32.is_lt(t1, t2), U32.is_le(t1, b1)), fr, tb, cx, x, t1, b1, t2), tb, cx, x, b1, t2, b2)

def flatcol(fr: Frame, +tb: Tabs, +cx: Ctx, +p: U32, +x: U32) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(ram, M.top(p, (x - 1 : U32))), r1 => +t1 =>
        M.let(Frame, M.rd(r1, M.bot(p, (x - 1 : U32))), r2 => +b1 =>
          M.let(Frame, M.rd(r2, M.top(p, x)), r3 => +t2 =>
            M.let(Frame, M.rd(r3, M.bot(p, x)), r4 => +b2 =>
              makespans(Frame{fb, rom, r4, sd}, tb, cx, x, t1, b1, t2, b2)))))

def flatcols(n: Nat, fr: Frame, +tb: Tabs, +cx: Ctx, +p: U32, +x: U32) -> Frame:
  match n:
    case 0n:
      fr
    case 1n+q:
      flatcols(q, flatcol(fr, tb, cx, p, x), tb, cx, p, (x + 1 : U32))

def flatplane(fr: Frame, +tb: Tabs, +v: View, +p: U32, +h: U32, +pic: U32, +light: U32, +mn: U32, +mx: U32) -> Frame:
  match fr v:
    case Frame{fb, rom, ram, sd} View{vx, vy, vz, va, ex, fx}:
      +ll0 = ((light >> 4n) + ex : U32)
      +ll = Bool.pick(U32, F.lt(ll0, 0), 0, Bool.pick(U32, F.gt(ll0, 15), 15, ll0))
      +zl = Bool.pick(U32, U32.is_ne(fx, 0), (fx + 2147483648 : U32), (M.zlight() + ll * 128 : U32))
      +ba = ((va - ang90()) >> 19n : U32)
      r1 = M.wr(M.wr(ram, M.top(p, (mx + 1 : U32)), 255), M.top(p, (mn - 1 : U32)), 255)
      flatcols(count(mn, (mx + 1 : U32)), Frame{fb, rom, r1, sd}, tb, Ctx{vx, vy, va, F.div(sine(tb, (ba + 2048 : U32)), cxf(win(tb))), F.neg(F.div(sine(tb, ba), cxf(win(tb)))), F.abs((h - vz : U32)), zl, pic}, p, mn)

def drawplane.pick(+sky: Bool, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +p: U32, +h: U32, +pic: U32, +light: U32, +mn: U32, +mx: U32) -> Frame:
  match sky v:
    case True{} View{vx, vy, vz, va, ex, fx}:
      skycols(count(mn, mx), fr, tb, skyinfo(w), va, p, mn)
    case False{} _:
      flatplane(fr, tb, v, p, h, R.flatbase(w, pic), light, mn, mx)

def drawplane(fr: Frame, +tb: Tabs, +w: R.World, +v: View, +p: U32) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(ram, M.head(p, 0)), r1 => +h =>
        M.let(Frame, M.rd(r1, M.head(p, 1)), r2 => +pic =>
          M.let(Frame, M.rd(r2, M.head(p, 2)), r3 => +light =>
            M.let(Frame, M.rd(r3, M.head(p, 3)), r4 => +mn =>
              M.let(Frame, M.rd(r4, M.head(p, 4)), r5 => +mx =>
                drawplane.pick(U32.is_eq(pic, M.sky()), Frame{fb, rom, r5, sd}, tb, w, v, p, h, pic, light, mn, mx))))))

def drawplanes(n: Nat, fr: Frame, +tb: Tabs, +w: R.World, +v: View, +p: U32) -> Frame:
  match n:
    case 0n:
      fr
    case 1n+q:
      drawplanes(q, drawplane(fr, tb, w, v, p), tb, w, v, (p + 1 : U32))

def planes(fr: Frame, +tb: Tabs, +w: R.World, +v: View) -> Frame:
  match fr:
    case Frame{fb, rom, ram, sd}:
      M.let(Frame, M.rd(ram, M.nplanes()), r1 => +n =>
        drawplanes(U32.to_nat(n), Frame{fb, rom, r1, sd}, tb, w, v, 0))

def setn(n: Nat, ram: Array<U32>, +i: U32, +v: U32) -> Array<U32>:
  match n:
    case 0n:
      ram
    case 1n+p:
      setn(p, M.wr(ram, i, v), (i + 1 : U32), v)

def fresh(+wn: U32) -> Array<U32>:
  r1 = setn(320n, Array.new(U32, M.ramdepth(), 0), M.ceilclip(), 4294967295)
  r2 = setn(320n, r1, M.floorclip(), vh(wn))
  r3 = setn(320n, r2, M.negone(), 4294967295)
  r4 = setn(320n, r3, M.screenh(), vh(wn))
  M.wr(M.wr(r4, M.lastopening(), M.openings()), M.geo(), wn)

def yslopes(n: Nat, +wn: U32, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      F.div(((svw(wn) / 2) << 16n : U32), F.abs((((i - cy(wn)) << 16n) + 32768 : U32))) <> yslopes(p, wn, (i + 1 : U32))

def distscales(n: Nat, +tb: Tabs, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      F.div(65536, F.abs(sine(tb, ((x2a(tb, i) >> 19n) + 2048 : U32)))) <> distscales(p, tb, (i + 1 : U32))

def prep.go(same: Bool, rom: Array<U32>, +tb: Tabs) -> Array<U32>:
  match same:
    case True{}:
      rom
    case False{}:
      +wn = win(tb)
      M.wr(M.fill(distscales(U32.to_nat(vw(wn)), tb, 0), M.fill(yslopes(U32.to_nat(vh(wn)), wn, 0), rom, M.yslope()), M.distscale()), M.geokey(), wn)

def prep(+tb: Tabs, rom: Array<U32>) -> Array<U32>:
  M.let(Array<U32>, M.rd(rom, M.geokey()), r => +k => prep.go(U32.is_eq(k, win(tb)), r, tb))

def scene(+tb: Tabs, +w: R.World, +v: View, rom: Array<U32>) -> Frame:
  planes(frame(walk(U32.to_nat(65536), St{Frame{S.blank(), prep(tb, rom), fresh(win(tb)), [Range{2147483649, 4294967295}, Range{vw(win(tb)), 2147483647}]}, [Visit{(T.size(L.Node, nodes(w)) - 1 : U32)}]}, tb, w, v)), tb, w, v)

def locate.child(+back: Bool, +n: L.Node) -> U32:
  match n:
    case L.Node{nx, ny, dx, dy, rb, lb, r, l}:
      Bool.pick(U32, back, l, r)

def locate(n: Nat, +w: R.World, +x: U32, +y: U32, +num: U32) -> U32:
  match n:
    case 0n:
      num
    case 1n+p:
      Bool.pick(U32, U32.is_eq((num .&. 32768 : U32), 0), locate(p, w, x, y, locate.child(side(View{x, y, 0, 0, 0, 0}, node(w, num)), node(w, num))), num)

def sector.floor(+s: R.RSector) -> U32:
  match s:
    case R.RSector{f, c, fp, cp, li, sp, tg, _, _}:
      f

def sub.first(+s: L.Sub) -> U32:
  match s:
    case L.Sub{n, f}:
      f

def locate.first(+w: R.World, +num: U32) -> U32:
  sub.first(sub(w, Bool.pick(U32, U32.is_eq(num, 65535), 0, (num .&. 32767 : U32))))

def floor.at(+w: R.World, +x: U32, +y: U32) -> U32:
  sector.floor(sector(w, seg.front(w, seg(w, locate.first(w, locate(64n, w, x, y, (T.size(L.Node, nodes(w)) - 1 : U32)))))))

def sector.at(+w: R.World, +x: U32, +y: U32) -> U32:
  seg.front(w, seg(w, locate.first(w, locate(64n, w, x, y, (T.size(L.Node, nodes(w)) - 1 : U32)))))
