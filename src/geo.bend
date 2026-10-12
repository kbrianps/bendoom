import Base
import ./tab.bend as T
import ./level.bend as L
import ./world.bend as R
import ./render.bend as V
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C

def aprox(+dx: U32, +dy: U32) -> U32:
  +ax = F.abs(dx)
  +ay = F.abs(dy)
  Bool.pick(U32, F.lt(ax, ay), (ax + ay - F.sar(ax, 1n) : U32), (ax + ay - F.sar(ay, 1n) : U32))

def ponside(+x: U32, +y: U32, +lx: U32, +ly: U32, +ldx: U32, +ldy: U32) -> U32:
  +dx = (x - lx : U32)
  +dy = (y - ly : U32)
  Bool.pick(U32, U32.is_eq(ldx, 0), C.b2u(Bool.pick(Bool, F.le(x, lx), F.gt(ldy, 0), F.lt(ldy, 0))),
    Bool.pick(U32, U32.is_eq(ldy, 0), C.b2u(Bool.pick(Bool, F.le(y, ly), F.lt(ldx, 0), F.gt(ldx, 0))),
      C.b2u(Bool.not(F.lt(F.mul(dy, F.sar(ldx, 16n)), F.mul(F.sar(ldy, 16n), dx))))))

def pointside(+x: U32, +y: U32, +l: S.RLine) -> U32:
  match l:
    case S.RLine{+x1, +y1, x2, y2, +dx, +dy, fl, sl, t, b, le, ri, s0, s1, fs, bs, tg}:
      ponside(x, y, x1, y1, dx, dy)

def divside(+x: U32, +y: U32, +lx: U32, +ly: U32, +ldx: U32, +ldy: U32) -> U32:
  +dx = (x - lx : U32)
  +dy = (y - ly : U32)
  Bool.pick(U32, U32.is_eq(ldx, 0), C.b2u(Bool.pick(Bool, F.le(x, lx), F.gt(ldy, 0), F.lt(ldy, 0))),
    Bool.pick(U32, U32.is_eq(ldy, 0), C.b2u(Bool.pick(Bool, F.le(y, ly), F.lt(ldx, 0), F.gt(ldx, 0))),
      Bool.pick(U32, F.is_neg((ldy .^. ldx .^. dx .^. dy : U32)), C.b2u(F.is_neg((ldy .^. dx : U32))),
        C.b2u(Bool.not(F.lt(F.mul(F.sar(dy, 8n), F.sar(ldx, 8n)), F.mul(F.sar(ldy, 8n), F.sar(dx, 8n))))))))

def intercept(+tx: U32, +ty: U32, +tdx: U32, +tdy: U32, +lx: U32, +ly: U32, +ldx: U32, +ldy: U32) -> U32:
  +den = (F.mul(F.sar(ldy, 8n), tdx) - F.mul(F.sar(ldx, 8n), tdy) : U32)
  +num = (F.mul(F.sar((lx - tx : U32), 8n), ldy) + F.mul(F.sar((ty - ly : U32), 8n), ldx) : U32)
  Bool.pick(U32, U32.is_eq(den, 0), 0, F.div(num, den))

def flip(+p: U32, +f: Bool) -> U32:
  Bool.pick(U32, f, (p .^. 1 : U32), p)

def boxside.of(+p1: U32, +p2: U32) -> U32:
  Bool.pick(U32, U32.is_eq(p1, p2), p1, 4294967295)

def boxside(+top: U32, +bottom: U32, +left: U32, +right: U32, +l: S.RLine) -> U32:
  match l:
    case S.RLine{+x1, +y1, x2, y2, +dx, +dy, fl, +sl, t, b, le, ri, s0, s1, fs, bs, tg}:
      +hz = U32.is_eq(sl, 0)
      +vt = U32.is_eq(sl, 1)
      +ps = U32.is_eq(sl, 2)
      +p1 = Bool.pick(U32, hz, flip(C.b2u(F.gt(top, y1)), F.lt(dx, 0)),
        Bool.pick(U32, vt, flip(C.b2u(F.lt(right, x1)), F.lt(dy, 0)),
          Bool.pick(U32, ps, ponside(left, top, x1, y1, dx, dy), ponside(right, top, x1, y1, dx, dy))))
      +p2 = Bool.pick(U32, hz, flip(C.b2u(F.gt(bottom, y1)), F.lt(dx, 0)),
        Bool.pick(U32, vt, flip(C.b2u(F.lt(left, x1)), F.lt(dy, 0)),
          Bool.pick(U32, ps, ponside(right, bottom, x1, y1, dx, dy), ponside(left, bottom, x1, y1, dx, dy))))
      boxside.of(p1, p2)

def opening.two(+g: S.Sim, +fsec: U32, +bsec: U32) -> S.Sim:
  +fc = S.s.ceil(g, fsec)
  +bc = S.s.ceil(g, bsec)
  +ff = S.s.floor(g, fsec)
  +bf = S.s.floor(g, bsec)
  +top = Bool.pick(U32, F.lt(fc, bc), fc, bc)
  +bottom = Bool.pick(U32, F.gt(ff, bf), ff, bf)
  +low = Bool.pick(U32, F.gt(ff, bf), bf, ff)
  S.tm.orange.set(S.tm.olow.set(S.tm.obottom.set(S.tm.otop.set(g, top), bottom), low), (top - bottom : U32))

def opening.of(+g: S.Sim, +l: S.RLine) -> S.Sim:
  match l:
    case S.RLine{x1, y1, x2, y2, dx, dy, fl, sl, t, b, le, ri, s0, +s1, +fs, +bs, tg}:
      C.br(U32.is_eq(s1, 65535), g, +h => S.tm.orange.set(h, 0), +h => opening.two(h, fs, bs))

def opening(+g: S.Sim, +l: U32) -> S.Sim:
  opening.of(g, S.line(g, l))

def nodeside(+x: U32, +y: U32, +n: L.Node) -> Bool:
  match n:
    case L.Node{nx, ny, ndx, ndy, rb, lb, r, l}:
      V.side.of(x, y, (nx << 16n : U32), (ny << 16n : U32), (ndx << 16n : U32), (ndy << 16n : U32))

def child(+n: L.Node, +back: Bool) -> U32:
  match n:
    case L.Node{nx, ny, ndx, ndy, rb, lb, r, l}:
      Bool.pick(U32, back, l, r)

def locate(n: Nat, leaf: Bool, +w: R.World, +x: U32, +y: U32, +num: U32) -> U32:
  match n leaf:
    case 1n+p False{}:
      +nd = R.node(w, num)
      +c = child(nd, nodeside(x, y, nd))
      locate(p, C.has(c, 2147483648), w, x, y, c)
    case _ _:
      (num .&. 2147483647 : U32)

def subsector(+g: S.Sim, +x: U32, +y: U32) -> U32:
  +w = S.sim.w(g)
  +n = T.size(L.Node, R.nodes(w))
  Bool.pick(U32, U32.is_eq(n, 0), 0, locate(256n, False{}, w, x, y, (n - 1 : U32)))

def secat(+g: S.Sim, +x: U32, +y: U32) -> U32:
  C.secof(g, subsector(g, x, y))

def bx(+g: S.Sim, +x: U32) -> U32:
  F.sar((x - S.mp.ox(g) : U32), 23n)

def by(+g: S.Sim, +y: U32) -> U32:
  F.sar((y - S.mp.oy(g) : U32), 23n)

def inside(+g: S.Sim, +x: U32, +y: U32) -> Bool:
  Bool.and(Bool.and(F.ge(x, 0), F.lt(x, S.mp.bw(g))), Bool.and(F.ge(y, 0), F.lt(y, S.mp.bh(g))))

def mobsec(+g: S.Sim, +m: U32) -> U32:
  C.secof(g, S.m.sub(g, m))

def unset.sec(+g: S.Sim, +m: U32) -> S.Sim:
  +sn = S.m.snext(g, m)
  +sp = S.m.sprev(g, m)
  +g1 = C.when(U32.is_ne(sn, 0), g, +h => S.m.sprev.set(h, sn, sp))
  C.br(U32.is_ne(sp, 0), g1, +h => S.m.snext.set(h, sp, sn), +h => S.s.things.set(h, mobsec(h, m), sn))

def unset.head(+g: S.Sim, +bx: U32, +by: U32, +v: U32) -> S.Sim:
  C.when(inside(g, bx, by), g, +h => C.link.set(h, (by * S.mp.bw(h) + bx : U32), v))

def unset.block(+g: S.Sim, +m: U32) -> S.Sim:
  +bn = S.m.bnext(g, m)
  +bp = S.m.bprev(g, m)
  +g1 = C.when(U32.is_ne(bn, 0), g, +h => S.m.bprev.set(h, bn, bp))
  C.br(U32.is_ne(bp, 0), g1, +h => S.m.bnext.set(h, bp, bn), +h => unset.head(h, bx(h, S.m.x(h, m)), by(h, S.m.y(h, m)), bn))

def unset(+g: S.Sim, +m: U32) -> S.Sim:
  +fl = S.m.flags(g, m)
  +g1 = C.when(Bool.not(C.has(fl, 8)), g, +h => unset.sec(h, m))
  C.when(Bool.not(C.has(fl, 16)), g1, +h => unset.block(h, m))

def set.sec(+g: S.Sim, +m: U32, +s: U32) -> S.Sim:
  +head = S.s.things(g, s)
  +g1 = S.m.snext.set(S.m.sprev.set(g, m, 0), m, head)
  +g2 = C.when(U32.is_ne(head, 0), g1, +h => S.m.sprev.set(h, head, m))
  S.s.things.set(g2, s, m)

def set.link(+g: S.Sim, +m: U32, +i: U32) -> S.Sim:
  +head = C.link.at(g, i)
  +g1 = S.m.bnext.set(S.m.bprev.set(g, m, 0), m, head)
  +g2 = C.when(U32.is_ne(head, 0), g1, +h => S.m.bprev.set(h, head, m))
  C.link.set(g2, i, m)

def set.block(+g: S.Sim, +m: U32) -> S.Sim:
  +x = bx(g, S.m.x(g, m))
  +y = by(g, S.m.y(g, m))
  C.br(inside(g, x, y), g, +h => set.link(h, m, (y * S.mp.bw(h) + x : U32)), +h => S.m.bprev.set(S.m.bnext.set(h, m, 0), m, 0))

def set(+g: S.Sim, +m: U32) -> S.Sim:
  +ss = subsector(g, S.m.x(g, m), S.m.y(g, m))
  +g1 = S.m.sub.set(g, m, ss)
  +fl = S.m.flags(g1, m)
  +g2 = C.when(Bool.not(C.has(fl, 8)), g1, +h => set.sec(h, m, C.secof(h, ss)))
  C.when(Bool.not(C.has(fl, 16)), g2, +h => set.block(h, m))

def blines.call(~f: S.Sim -> U32 -> S.Sim, fresh: Bool, +g: S.Sim, +ld: U32) -> S.Sim:
  match fresh:
    case True{}:
      f(C.mark(g, ld), ld)
    case False{}:
      g

def blines.go(~f: S.Sim -> U32 -> S.Sim, n: Nat, more: Bool, +g: S.Sim, +i: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +ld = C.bmap(g, i)
      +live = U32.is_ne(ld, 65535)
      +g1 = blines.call(~f, Bool.and(live, Bool.not(C.seen(g, ld))), g, ld)
      blines.go(~f, p, Bool.and(live, Bool.not(C.halted(g1))), g1, (i + 1 : U32))
    case _ _:
      g

def blines(~f: S.Sim -> U32 -> S.Sim, +g: S.Sim, +x: U32, +y: U32) -> S.Sim:
  blines.go(~f, 65536n, inside(g, x, y), g, C.bmap(g, (4 + y * S.mp.bw(g) + x : U32)))

def bthings.go(~f: S.Sim -> U32 -> S.Sim, n: Nat, more: Bool, +g: S.Sim, +m: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = f(g, m)
      +nx = S.m.bnext(g1, m)
      bthings.go(~f, p, Bool.and(U32.is_ne(nx, 0), Bool.not(C.halted(g1))), g1, nx)
    case _ _:
      g

def bthings.from(~f: S.Sim -> U32 -> S.Sim, +g: S.Sim, +m: U32) -> S.Sim:
  bthings.go(~f, 65536n, U32.is_ne(m, 0), g, m)

def bthings(~f: S.Sim -> U32 -> S.Sim, +g: S.Sim, +x: U32, +y: U32) -> S.Sim:
  C.when(inside(g, x, y), g, +h => bthings.from(~f, h, C.link.at(h, (y * S.mp.bw(h) + x : U32))))

def column(~f: S.Sim -> U32 -> U32 -> S.Sim, n: Nat, more: Bool, +g: S.Sim, +x: U32, +y: U32, +yh: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = f(g, x, y)
      column(~f, p, Bool.and(F.lt(y, yh), Bool.not(C.halted(g1))), g1, x, (y + 1 : U32), yh)
    case _ _:
      g

def blocks(~f: S.Sim -> U32 -> U32 -> S.Sim, n: Nat, more: Bool, +g: S.Sim, +x: U32, +xh: U32, +yl: U32, +yh: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = column(~f, 4096n, F.le(yl, yh), g, x, yl, yh)
      blocks(~f, p, Bool.and(F.lt(x, xh), Bool.not(C.halted(g1))), g1, (x + 1 : U32), xh, yl, yh)
    case _ _:
      g

def area(~f: S.Sim -> U32 -> U32 -> S.Sim, +g: S.Sim, +xl: U32, +xh: U32, +yl: U32, +yh: U32) -> S.Sim:
  blocks(~f, 4096n, F.le(xl, xh), g, xl, xh, yl, yh)

def addline.of(+g: S.Sim, +ld: U32, +l: S.RLine) -> S.Sim:
  match l:
    case S.RLine{+x1, +y1, +x2, +y2, +dx, +dy, fl, sl, t, b, le, ri, s0, s1, fs, bs, tg}:
      +tx = S.tm.trx(g)
      +ty = S.tm.try(g)
      +tdx = S.tm.trdx(g)
      +tdy = S.tm.trdy(g)
      +big = Bool.or(Bool.or(F.gt(tdx, 1048576), F.gt(tdy, 1048576)), Bool.or(F.lt(tdx, 4293918720), F.lt(tdy, 4293918720)))
      +s1 = Bool.pick(U32, big, divside(x1, y1, tx, ty, tdx, tdy), ponside(tx, ty, x1, y1, dx, dy))
      +s2 = Bool.pick(U32, big, divside(x2, y2, tx, ty, tdx, tdy), ponside((tx + tdx : U32), (ty + tdy : U32), x1, y1, dx, dy))
      +frac = intercept(tx, ty, tdx, tdy, x1, y1, dx, dy)
      C.when(Bool.and(U32.is_ne(s1, s2), Bool.not(F.lt(frac, 0))), g, +h => S.tm.ins.set(h, S.Icpt{frac, True{}, ld} <> S.tm.ins(h)))

def addline(+g: S.Sim, +ld: U32) -> S.Sim:
  addline.of(g, ld, S.line(g, ld))

def addthing(+g: S.Sim, +m: U32) -> S.Sim:
  +tx = S.tm.trx(g)
  +ty = S.tm.try(g)
  +tdx = S.tm.trdx(g)
  +tdy = S.tm.trdy(g)
  +pos = F.gt((tdx .^. tdy : U32), 0)
  +r = S.m.radius(g, m)
  +x = S.m.x(g, m)
  +y = S.m.y(g, m)
  +x1 = (x - r : U32)
  +x2 = (x + r : U32)
  +y1 = Bool.pick(U32, pos, (y + r : U32), (y - r : U32))
  +y2 = Bool.pick(U32, pos, (y - r : U32), (y + r : U32))
  +s1 = divside(x1, y1, tx, ty, tdx, tdy)
  +s2 = divside(x2, y2, tx, ty, tdx, tdy)
  +frac = intercept(tx, ty, tdx, tdy, x1, y1, (x2 - x1 : U32), (y2 - y1 : U32))
  C.when(Bool.and(U32.is_ne(s1, s2), Bool.not(F.lt(frac, 0))), g, +h => S.tm.ins.set(h, S.Icpt{frac, False{}, m} <> S.tm.ins(h)))

def fr(+i: S.Icpt) -> U32:
  match i:
    case S.Icpt{f, l, d}:
      f

def headle(+ys: List<&2, S.Icpt>, +x: S.Icpt) -> Bool:
  match ys:
    case +y <> t:
      F.le(fr(y), fr(x))
    case []:
      False{}

def insert.go(+x: S.Icpt, ys: List<&2, S.Icpt>, le: Bool, acc: List<&2, S.Icpt>) -> List<&2, S.Icpt>:
  match ys le:
    case +y <> +t True{}:
      insert.go(x, t, headle(t, x), y <> acc)
    case +y <> +t False{}:
      T.onto(S.Icpt, acc, x <> y <> t)
    case [] _:
      T.onto(S.Icpt, acc, [x])

def insert(+x: S.Icpt, ys: List<&2, S.Icpt>, le: Bool) -> List<&2, S.Icpt>:
  insert.go(x, ys, le, [])

def sort(xs: List<&2, S.Icpt>, +acc: List<&2, S.Icpt>) -> List<&2, S.Icpt>:
  match xs:
    case +x <> t:
      sort(t, insert(x, acc, headle(acc, x)))
    case []:
      acc

def headok(+ys: List<&2, S.Icpt>, +maxfrac: U32) -> Bool:
  match ys:
    case +y <> t:
      F.le(fr(y), maxfrac)
    case []:
      False{}

def trav(~f: S.Sim -> S.Icpt -> S.Sim, xs: List<&2, S.Icpt>, go: Bool, +g: S.Sim, +maxfrac: U32) -> S.Sim:
  match xs go:
    case +x <> +t True{}:
      +g1 = f(g, x)
      trav(~f, t, Bool.and(Bool.not(C.halted(g1)), headok(t, maxfrac)), g1, maxfrac)
    case _ _:
      g

def walk(n: Nat, more: Bool, +g: S.Sim, +things: Bool, +mx: U32, +my: U32, +xi: U32, +yi: U32, +xs: U32, +ys: U32, +mxs: U32, +mys: U32, +xt2: U32, +yt2: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +g1 = blines(~(+h => +l => addline(h, l)), g, mx, my)
      +g2 = C.when(things, g1, +h => bthings(~(+k => +m => addthing(k, m)), h, mx, my))
      +done = Bool.and(U32.is_eq(mx, xt2), U32.is_eq(my, yt2))
      +sx = U32.is_eq(F.sar(yi, 16n), my)
      +sy = Bool.and(Bool.not(sx), U32.is_eq(F.sar(xi, 16n), mx))
      walk(p, Bool.not(done), g2, things,
        (mx + Bool.pick(U32, sx, mxs, 0) : U32), (my + Bool.pick(U32, sy, mys, 0) : U32),
        (xi + Bool.pick(U32, sy, xs, 0) : U32), (yi + Bool.pick(U32, sx, ys, 0) : U32),
        xs, ys, mxs, mys, xt2, yt2)
    case _ _:
      g

def nudge(+v: U32, +o: U32) -> U32:
  Bool.pick(U32, U32.is_eq(((v - o) .&. 8388607 : U32), 0), (v + 65536 : U32), v)

def axis.step(+t1: U32, +t2: U32) -> U32:
  Bool.pick(U32, F.gt(t2, t1), 1, Bool.pick(U32, F.lt(t2, t1), 4294967295, 0))

def axis.partial(+t1: U32, +t2: U32, +a1: U32) -> U32:
  Bool.pick(U32, F.gt(t2, t1), (65536 - (F.sar(a1, 7n) .&. 65535) : U32),
    Bool.pick(U32, F.lt(t2, t1), (F.sar(a1, 7n) .&. 65535 : U32), 65536))

def axis.slope(+t1: U32, +t2: U32, +num: U32, +den: U32) -> U32:
  Bool.pick(U32, U32.is_eq(t1, t2), 16777216, F.div(num, F.abs(den)))

def traced(+g: S.Sim, +things: Bool, +ox: U32, +oy: U32, +x1: U32, +y1: U32, +x2: U32, +y2: U32) -> S.Sim:
  +a1 = (x1 - ox : U32)
  +b1 = (y1 - oy : U32)
  +a2 = (x2 - ox : U32)
  +b2 = (y2 - oy : U32)
  +xt1 = F.sar(a1, 23n)
  +yt1 = F.sar(b1, 23n)
  +xt2 = F.sar(a2, 23n)
  +yt2 = F.sar(b2, 23n)
  +ystep = axis.slope(xt1, xt2, (b2 - b1 : U32), (a2 - a1 : U32))
  +xstep = axis.slope(yt1, yt2, (a2 - a1 : U32), (b2 - b1 : U32))
  +yi = (F.sar(b1, 7n) + F.mul(axis.partial(xt1, xt2, a1), ystep) : U32)
  +xi = (F.sar(a1, 7n) + F.mul(axis.partial(yt1, yt2, b1), xstep) : U32)
  walk(64n, True{}, g, things, xt1, yt1, xi, yi, xstep, ystep, axis.step(xt1, xt2), axis.step(yt1, yt2), xt2, yt2)

def trace.set(+g: S.Sim, +x: U32, +y: U32, +dx: U32, +dy: U32) -> S.Sim:
  S.tm.trdy.set(S.tm.trdx.set(S.tm.try.set(S.tm.trx.set(S.tm.ins.set(g, []), x), y), dx), dy)

def collect(+g: S.Sim, +things: Bool, +x1: U32, +y1: U32, +x2: U32, +y2: U32) -> S.Sim:
  +ox = S.mp.ox(g)
  +oy = S.mp.oy(g)
  +sx = nudge(x1, ox)
  +sy = nudge(y1, oy)
  traced(trace.set(C.vc.bump(g), sx, sy, (x2 - sx : U32), (y2 - sy : U32)), things, ox, oy, sx, sy, x2, y2)

def path(~f: S.Sim -> S.Icpt -> S.Sim, +g: S.Sim, +things: Bool, +x1: U32, +y1: U32, +x2: U32, +y2: U32) -> S.Sim:
  +g1 = collect(g, things, x1, y1, x2, y2)
  +xs = sort(List.reverse(&2, S.Icpt, S.tm.ins(g1)), [])
  trav(~f, xs, headok(xs, 65536), g1, 65536)
