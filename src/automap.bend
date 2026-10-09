import Base
import ./i32.bend as I
import ./tab.bend as T
import ./level.bend as L

type View is Data:
  View{left: U32, bottom: U32, span: U32, room: U32, ex: U32, ey: U32}

def size() -> U32:
  1024

def grow(b: L.Box, v: L.Vertex) -> L.Box:
  match b v:
    case L.Box{t, bo, le, r} L.Vertex{+x, +y}:
      L.Box{I.max(t, y), I.min(bo, y), I.min(le, x), I.max(r, x)}

def bounds(n: Nat, +vs: T.Vec<L.Vertex>, +i: U32, b: L.Box) -> L.Box:
  match n:
    case 0n:
      b
    case 1n+p:
      bounds(p, vs, (i + 1 : U32), grow(b, T.get(L.Vertex, vs, i, L.Vertex{0, 0})))

def edge(+ro: U32, +sp: U32, +w: U32) -> U32:
  (16 + (ro - w * ro / sp) / 2 : U32)

def view.fit(+le: U32, +bo: U32, +w: U32, +h: U32, +sp: U32, +ro: U32) -> View:
  View{le, bo, sp, ro, edge(ro, sp, w), edge(ro, sp, h)}

def view.of(+b: L.Box) -> View:
  match b:
    case L.Box{t, bo, le, r}:
      view.fit(le, bo, (r - le : U32), (t - bo : U32), (U32.max((r - le : U32), (t - bo : U32)) + 1 : U32), (size() - 32 : U32))

def view(+vs: T.Vec<L.Vertex>) -> View:
  +b = bounds(U32.to_nat(T.size(L.Vertex, vs)), vs, 0, L.Box{2147483648, 2147483647, 2147483647, 2147483648})
  view.of(b)

def px(+v: View, +x: U32) -> U32:
  match v:
    case View{le, bo, sp, ro, ex, ey}:
      (ex + (x - le) * ro / sp : U32)

def py(+v: View, +y: U32) -> U32:
  match v:
    case View{le, bo, sp, ro, ex, ey}:
      (ey + (y - bo) * ro / sp : U32)

def plot(a: Array<U32>, +x: U32, +y: U32, c: U32) -> Array<U32>:
  Array.set(U32, a, (U32.min(y, 1023) * 1024 + U32.min(x, 1023) : U32), c)

def mid(+a: U32, +b: U32, +i: U32, +n: U32) -> U32:
  (((n - i) * a + i * b + n / 2) / n : U32)

def dot(n: Nat, a: Array<U32>, +i: U32, +k: U32, +x0: U32, +y0: U32, +x1: U32, +y1: U32, +c: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+p:
      dot(p, plot(a, mid(x0, x1, i, k), mid(y0, y1, i, k), c), (i + 1 : U32), k, x0, y0, x1, y1, c)

def dist(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, U32.is_lt(a, b), (b - a : U32), (a - b : U32))

def draw(a: Array<U32>, +x0: U32, +y0: U32, +x1: U32, +y1: U32, +c: U32) -> Array<U32>:
  +k = U32.max(dist(x0, x1), dist(y0, y1))
  dot(U32.to_nat((k + 1 : U32)), a, 0, U32.max(k, 1), x0, y0, x1, y1, c)

def side.sector(+secs: T.Vec<L.Sector>, d: L.Side) -> L.Sector:
  match d:
    case L.Side{x, y, u, l, m, +s}:
      T.get(L.Sector, secs, s, L.Sector{0, 0, "", "", 0, 0, 0})

def sector(+sides: T.Vec<L.Side>, +secs: T.Vec<L.Sector>, +side: U32) -> L.Sector:
  side.sector(secs, T.get(L.Side, sides, side, L.Side{0, 0, "", "", "", 65535}))

def tone(+one: Bool, +flags: U32, f: L.Sector, b: L.Sector) -> U32:
  match f b:
    case L.Sector{+ff, +fc, fp, fq, fl, fs, ft} L.Sector{+bf, +bc, bp, bq, bl, bs, bt}:
      Bool.pick(U32, Bool.or(one, U32.is_ne((flags .&. 32 : U32), 0)), 176,
        Bool.pick(U32, U32.is_ne(ff, bf), 64,
          Bool.pick(U32, U32.is_ne(fc, bc), 231, 96)))

def color(+pal: T.Vec<U32>, +i: U32) -> U32:
  T.get(U32, pal, i, 0)

def vert(+vs: T.Vec<L.Vertex>, +i: U32) -> L.Vertex:
  T.get(L.Vertex, vs, i, L.Vertex{0, 0})

def line.draw(a: Array<U32>, +v: View, p: L.Vertex, q: L.Vertex, +c: U32) -> Array<U32>:
  match p q:
    case L.Vertex{+x0, +y0} L.Vertex{+x1, +y1}:
      draw(a, px(v, x0), py(v, y0), px(v, x1), py(v, y1), c)

def line(a: Array<U32>, +lv: L.Level, +v: View, +pal: T.Vec<U32>, l: L.Line) -> Array<U32>:
  match lv l:
    case L.Level{n, th, li, si, vs, se, ss, no, sc, rj, bm} L.Line{v1, v2, +fl, sp, tg, +fr, +bk}:
      line.draw(a, v, vert(vs, v1), vert(vs, v2),
        color(pal, tone(U32.is_eq(bk, 65535), fl, sector(si, sc, fr), sector(si, sc, bk))))

def nth(+lv: L.Level, +i: U32) -> L.Line:
  match lv:
    case L.Level{n, th, li, si, vs, se, ss, no, sc, rj, bm}:
      T.get(L.Line, li, i, L.Line{0, 0, 0, 0, 0, 0, 0})

def lines(n: Nat, a: Array<U32>, +i: U32, +lv: L.Level, +v: View, +pal: T.Vec<U32>) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+p:
      lines(p, line(a, lv, v, pal, nth(lv, i)), (i + 1 : U32), lv, v, pal)

def cross(a: Array<U32>, +x: U32, +y: U32, +c: U32) -> Array<U32>:
  plot(plot(plot(plot(plot(a, x, y, c), (x + 1 : U32), y, c), (x - 1 : U32), y, c), x, (y + 1 : U32), c), x, (y - 1 : U32), c)

def thing(a: Array<U32>, +v: View, +pal: T.Vec<U32>, t: L.Thing) -> Array<U32>:
  match t:
    case L.Thing{+x, +y, an, +k, fl}:
      cross(a, px(v, x), py(v, y), color(pal, Bool.pick(U32, U32.is_le(k, 4), 209, 112)))

def things(n: Nat, a: Array<U32>, +i: U32, +th: T.Vec<L.Thing>, +v: View, +pal: T.Vec<U32>) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+p:
      things(p, thing(a, v, pal, T.get(L.Thing, th, i, L.Thing{0, 0, 0, 0, 0})), (i + 1 : U32), th, v, pal)

def rgb(bs: List<&2, U32>) -> List<&2, U32>:
  match bs:
    case r <> g <> b <> t:
      ((r << 16n) .|. (g << 8n) .|. b : U32) <> rgb(t)
    case _:
      []

def palette(bs: List<&2, U32>) -> T.Vec<U32>:
  T.from_list(U32, List.take(&2, U32, rgb(bs), 256n))

def render.go(+lv: L.Level, +v: View, +pal: T.Vec<U32>, +th: T.Vec<L.Thing>, +nl: U32, +nt: U32) -> Array<U32>:
  things(U32.to_nat(nt), lines(U32.to_nat(nl), [0 : U32^20n], 0, lv, v, pal), 0, th, v, pal)

def render(+lv: L.Level, +pal: T.Vec<U32>) -> Array<U32>:
  match lv:
    case L.Level{n, +th, +li, si, +vs, se, ss, no, sc, rj, bm}:
      render.go(lv, view(vs), pal, th, T.size(L.Line, li), T.size(L.Thing, th))
