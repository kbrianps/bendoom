import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./gfx.bend as G
import ./render.bend as V
import ./mem.bend as M

def lit(+pal: T.Vec<U32>, bs: List<&2, U32>) -> List<&2, U32>:
  match bs:
    case b <> t:
      T.get(U32, pal, b, 0) <> lit(pal, t)
    case []:
      []

def pal.list(n: Nat, +pal: T.Vec<U32>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      T.get(U32, pal, i, 0) <> pal.list(p, pal, (i + 1 : U32))

def fuzztab() -> List<&2, U32>:
  [1, 4294967295, 1, 4294967295, 1, 1, 4294967295, 1, 1, 4294967295, 1, 1, 1, 4294967295, 1, 1, 1, 4294967295, 4294967295, 4294967295, 4294967295, 1, 4294967295, 4294967295, 1, 1, 1, 1, 4294967295, 1, 4294967295, 1, 1, 4294967295, 4294967295, 1, 1, 4294967295, 4294967295, 4294967295, 4294967295, 1, 1, 1, 1, 4294967295, 1, 1, 4294967295, 1]

def zlevel(+i: U32, +j: U32) -> U32:
  +lv = ((15 - i) * 4 - ((655360 / (j + 1) : U32) >> 12n) / 2 : U32)
  (Bool.pick(U32, F.lt(lv, 0), 0, Bool.pick(U32, F.gt(lv, 31), 31, lv)) * 256 : U32)

def zrow(n: Nat, +i: U32, +j: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      zlevel(i, j) <> zrow(p, i, (j + 1 : U32))

def zlights(n: Nat, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      List.append(&2, U32, zrow(128n, i, 0), zlights(p, (i + 1 : U32)))

def tex.info(+at: U32, +t: G.Tex) -> M.Info:
  match t:
    case G.Tex{+m, h, xs, ps, bl}:
      M.Info{m, h, at, Bool.pick(U32, List.is_empty(&2, U32, ps), 4294967295, (at + (m + 1) * 128 : U32))}

def tex.size(+t: G.Tex) -> U32:
  match t:
    case G.Tex{m, h, xs, +ps, +bl}:
      ((m + 1) * 128 + U32.from_nat(List.length(&2, U32, ps)) + U32.from_nat(List.length(&2, U32, bl)) : U32)

def infos(ts: List<&2, G.Tex>, +at: U32) -> List<&2, M.Info>:
  match ts:
    case +t <> r:
      tex.info(at, t) <> infos(r, (at + tex.size(t) : U32))
    case []:
      []

def texs.end(ts: List<&2, G.Tex>, +at: U32) -> U32:
  match ts:
    case +t <> r:
      texs.end(r, (at + tex.size(t) : U32))
    case []:
      at

def flat.bases(fs: List<&2, List<&2, U32>>, +at: U32) -> List<&2, U32>:
  match fs:
    case f <> r:
      at <> flat.bases(r, (at + 4096 : U32))
    case []:
      []

def layout(+ts: List<&2, G.Tex>, +fs: List<&2, List<&2, U32>>) -> M.Layout:
  +fb = texs.end(ts, M.texbase())
  M.Layout{infos(ts, M.texbase()), flat.bases(fs, fb), (fb + 4096 * U32.from_nat(List.length(&2, List<&2, U32>, fs)) : U32)}

def rebase(xs: List<&2, U32>, +b: U32) -> List<&2, U32>:
  match xs:
    case +x <> t:
      Bool.pick(U32, U32.is_eq(x, 4294967295), x, (x + b : U32)) <> rebase(t, b)
    case []:
      []

def put.tex(+t: G.Tex, a: Array<U32>, +at: U32) -> Array<U32>:
  match t:
    case G.Tex{+m, h, xs, +ps, bl}:
      +p0 = (at + (m + 1) * 128 : U32)
      +b0 = (p0 + U32.from_nat(List.length(&2, U32, ps)) : U32)
      M.fill(bl, M.fill(rebase(ps, b0), M.fill(xs, a, at), p0), b0)

def put.texs(ts: List<&2, G.Tex>, a: Array<U32>, +at: U32) -> Array<U32>:
  match ts:
    case +t <> r:
      put.texs(r, put.tex(t, a, at), (at + tex.size(t) : U32))
    case []:
      a

def put.flats(fs: List<&2, List<&2, U32>>, a: Array<U32>, +at: U32) -> Array<U32>:
  match fs:
    case f <> r:
      put.flats(r, M.fill(List.take(&2, U32, f, 4096n), a, at), (at + 4096 : U32))
    case []:
      a

def build(+tb: V.Tabs, +pal: T.Vec<U32>, cmaps: List<&2, U32>, ts: List<&2, G.Tex>, +fs: List<&2, List<&2, U32>>, +unused: U32, +flat0: U32) -> Array<U32>:
  a0 = Array.new(U32, M.depth(U32.max(unused, (flat0 + 4096 * U32.from_nat(List.length(&2, List<&2, U32>, fs)) : U32))), 0)
  a1 = M.fill(List.take(&2, U32, pal.list(256n, pal, 0), 256n), M.fill(List.take(&2, U32, cmaps, 8704n), a0, M.cmap()), M.pal())
  a2 = M.fill(fuzztab(), M.fill(zlights(16n, 0), a1, M.zlight()), M.fuzz())
  a5 = put.texs(ts, a2, M.texbase())
  put.flats(fs, a5, flat0)
