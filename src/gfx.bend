import Base
import ./bytes.bend as B
import ./fixed.bend as F
import ./tab.bend as T
import ./bmp.bend as P

type PRef is Data:
  PRef{x: U32, y: U32, patch: U32}

type TexDef is Data:
  TexDef{name: String, width: U32, height: U32, patches: List<&2, PRef>}

type Patch is Data:
  Patch{x: U32, y: U32, width: U32, bytes: T.Vec<U32>, at: U32}

type Tex is Data:
  Tex{mask: U32, height: U32, texels: List<&2, U32>, posts: List<&2, U32>, blob: List<&2, U32>}

type Cover is Data:
  Cover{count: U32, patch: Patch}

def s(+w: U32) -> U32:
  B.s16(w)

def pnames(ws: List<&2, U32>) -> List<&2, String>:
  match ws:
    case a <> b <> c <> d <> t:
      B.name(a, b, c, d) <> pnames(t)
    case _:
      []

def prefs(n: Nat, ws: List<&2, U32>) -> List<&2, PRef>:
  match n ws:
    case 1n+p x <> y <> k <> sd <> cm <> t:
      PRef{s(x), s(y), k} <> prefs(p, t)
    case _ _:
      []

def texdef(ws: List<&2, U32>) -> TexDef:
  match ws:
    case a <> b <> c <> d <> m0 <> m1 <> w <> h <> c0 <> c1 <> n <> t:
      TexDef{B.name(a, b, c, d), w, h, prefs(U32.to_nat(n), t)}
    case _:
      TexDef{"", 0, 0, []}

def offsets(n: Nat, ws: List<&2, U32>) -> List<&2, U32>:
  match n ws:
    case 1n+p lo <> hi <> t:
      B.u32(lo, hi) <> offsets(p, t)
    case _ _:
      []

def texdefs.go(+ws: List<&2, U32>, os: List<&2, U32>) -> List<&2, TexDef>:
  match os:
    case +o <> t:
      texdef(List.drop(&2, U32, ws, U32.to_nat((o >> 1n : U32)))) <> texdefs.go(ws, t)
    case []:
      []

def texdefs.of(+ws: List<&2, U32>) -> List<&2, TexDef>:
  match ws:
    case lo <> hi <> t:
      texdefs.go(ws, offsets(U32.to_nat(B.u32(lo, hi)), t))
    case _:
      []

def texdefs(bs: List<&2, U32>) -> List<&2, TexDef>:
  texdefs.of(B.words(bs))

def byte(+bs: T.Vec<U32>, +i: U32) -> U32:
  T.get(U32, bs, i, 0)

def u32at(+bs: T.Vec<U32>, +i: U32) -> U32:
  (byte(bs, i) .|. (byte(bs, (i + 1 : U32)) << 8n) .|. (byte(bs, (i + 2 : U32)) << 16n) .|. (byte(bs, (i + 3 : U32)) << 24n) : U32)

def patch.of(x: U32, y: U32, +v: T.Vec<U32>, +at: U32) -> Patch:
  Patch{x, y, (byte(v, 0) .|. (byte(v, 1) << 8n) : U32), v, at}

def patch(r: PRef, bs: List<&2, U32>, +at: U32) -> Patch:
  match r:
    case PRef{x, y, k}:
      patch.of(x, y, T.from_list(U32, bs), at)

def patches(rs: List<&2, PRef>, bss: List<&2, List<&2, U32>>, +at: U32) -> List<&2, Patch>:
  match rs bss:
    case r <> rt +bs <> bt:
      patch(r, bs, at) <> patches(rt, bt, (at + U32.from_nat(List.length(&2, U32, bs)) : U32))
    case _ _:
      []

def covers(+x: U32, +p: Patch) -> Bool:
  match p:
    case Patch{px, py, w, bs, at}:
      Bool.and(F.le(px, x), F.lt(x, (px + w : U32)))

def cover.add(+hit: Bool, +c: Cover, +p: Patch) -> Cover:
  match c:
    case Cover{n, q}:
      Bool.pick(Cover, hit, Cover{(n + 1 : U32), p}, Cover{n, q})

def cover(ps: List<&2, Patch>, +x: U32, c: Cover) -> Cover:
  match ps:
    case +p <> t:
      cover(t, x, cover.add(covers(x, p), c, p))
    case []:
      c

def empty() -> Patch:
  Patch{0, 0, 0, T.from_list(U32, []), 0}

def cover.all(n: Nat, +ps: List<&2, Patch>, +x: U32) -> List<&2, Cover>:
  match n:
    case 0n:
      []
    case 1n+p:
      cover(ps, x, Cover{0, empty()}) <> cover.all(p, ps, (x + 1 : U32))

def none() -> U32:
  4294967295

def place(cs: List<&2, Cover>, +h: U32, +at: U32) -> List<&2, U32>:
  match cs:
    case Cover{+n, q} <> t:
      Bool.pick(U32, U32.is_gt(n, 1), at, none()) <> place(t, h, Bool.pick(U32, U32.is_gt(n, 1), (at + h : U32), at))
    case []:
      []

def multi(cs: List<&2, Cover>) -> U32:
  match cs:
    case Cover{+n, q} <> t:
      (Bool.pick(U32, U32.is_gt(n, 1), 1, 0) + multi(t) : U32)
    case []:
      0

def copy(n: Nat, blk: Array<U32>, +bs: T.Vec<U32>, +src: U32, +dst: U32) -> Array<U32>:
  match n:
    case 0n:
      blk
    case 1n+p:
      copy(p, Array.set(U32, blk, dst, byte(bs, src)), bs, (src + 1 : U32), (dst + 1 : U32))

def clipped(+len: U32, +pos: U32, +h: U32) -> Nat:
  +c1 = Bool.pick(U32, F.is_neg(pos), (len + pos : U32), len)
  +p1 = F.max(pos, 0)
  +c2 = Bool.pick(U32, F.gt((p1 + c1 : U32), h), (h - p1 : U32), c1)
  Bool.pick(Nat, F.gt(c2, 0), U32.to_nat(c2), 0n)

def posts(n: Nat, stop: Bool, blk: Array<U32>, +bs: T.Vec<U32>, +off: U32, +base: U32, +oy: U32, +h: U32) -> Array<U32>:
  match n stop:
    case 1n+p False{}:
      +len = byte(bs, (off + 1 : U32))
      +pos = (oy + byte(bs, off) : U32)
      +next = (off + len + 4 : U32)
      posts(p, U32.is_eq(byte(bs, next), 255), copy(clipped(len, pos, h), blk, bs, (off + 3 : U32), (base + F.max(pos, 0) : U32)), bs, next, base, oy, h)
    case _ _:
      blk

def column.at(blk: Array<U32>, +bs: T.Vec<U32>, +off: U32, +base: U32, +oy: U32, +h: U32) -> Array<U32>:
  posts(256n, U32.is_eq(byte(bs, off), 255), blk, bs, off, base, oy, h)

def column(blk: Array<U32>, +p: Patch, +x: U32, +base: U32, +h: U32) -> Array<U32>:
  match p:
    case Patch{px, py, w, bs, at}:
      column.at(blk, bs, u32at(bs, (8 + 4 * (x - px) : U32)), base, py, h)

def draw.col(single: Bool, blk: Array<U32>, +p: Patch, +x: U32, +cofs: T.Vec<U32>, +h: U32) -> Array<U32>:
  match single:
    case True{}:
      blk
    case False{}:
      column(blk, p, x, T.get(U32, cofs, x, 0), h)

def draw.cols(n: Nat, blk: Array<U32>, +p: Patch, +x: U32, +cofs: T.Vec<U32>, +h: U32) -> Array<U32>:
  match n:
    case 0n:
      blk
    case 1n+q:
      draw.cols(q, draw.col(U32.is_eq(T.get(U32, cofs, x, none()), none()), blk, p, x, cofs, h), p, (x + 1 : U32), cofs, h)

def span(+p: Patch, +tw: U32) -> U32 & U32:
  match p:
    case Patch{px, py, w, bs, at}:
      (F.max(px, 0), F.min((px + w : U32), tw))

def draw.patch.at(blk: Array<U32>, +p: Patch, r: U32 & U32, +cofs: T.Vec<U32>, +h: U32) -> Array<U32>:
  (+x1, +x2) = r
  draw.cols(Bool.pick(Nat, F.lt(x1, x2), U32.to_nat((x2 - x1 : U32)), 0n), blk, p, x1, cofs, h)

def draw.patch(blk: Array<U32>, +p: Patch, +tw: U32, +cofs: T.Vec<U32>, +h: U32) -> Array<U32>:
  draw.patch.at(blk, p, span(p, tw), cofs, h)

def composite(ps: List<&2, Patch>, blk: Array<U32>, +tw: U32, +cofs: T.Vec<U32>, +h: U32) -> Array<U32>:
  match ps:
    case +p <> t:
      composite(t, draw.patch(blk, p, tw, cofs, h), tw, cofs, h)
    case []:
      blk

def take128.go(n: Nat, +v: T.Vec<U32>, +at: U32, rest: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      rest
    case 1n+p:
      byte(v, at) <> take128.go(p, v, (at + 1 : U32), rest)

def source.of(single: Bool, +bs: T.Vec<U32>, +at: U32, +blk: T.Vec<U32>, +co: U32, rest: List<&2, U32>) -> List<&2, U32>:
  match single:
    case True{}:
      take128.go(128n, bs, (u32at(bs, at) + 3 : U32), rest)
    case False{}:
      take128.go(128n, blk, co, rest)

def source(+c: Cover, +x: U32, +co: U32, +blk: T.Vec<U32>, rest: List<&2, U32>) -> List<&2, U32>:
  match c:
    case Cover{n, Patch{px, py, w, bs, at}}:
      source.of(U32.is_eq(co, none()), bs, (8 + 4 * (x - px) : U32), blk, co, rest)

def sources(n: Nat, cs: List<&2, Cover>, +x: U32, +cofs: T.Vec<U32>, +blk: T.Vec<U32>) -> List<&2, U32>:
  match n cs:
    case 1n+p +c <> t:
      source(c, x, T.get(U32, cofs, x, none()), blk, sources(p, t, (x + 1 : U32), cofs, blk))
    case _ _:
      []

def mask.go(n: Nat, +j: U32, +w: U32) -> U32:
  match n:
    case 0n:
      j
    case 1n+p:
      Bool.pick(U32, U32.is_le((j * 2 : U32), w), mask.go(p, (j * 2 : U32), w), j)

def mask(+w: U32) -> U32:
  (mask.go(16n, 1, w) - 1 : U32)

def post(+c: Cover, +x: U32) -> U32:
  match c:
    case Cover{n, Patch{px, py, w, bs, at}}:
      Bool.pick(U32, U32.is_eq(n, 1), (at + u32at(bs, (8 + 4 * (x - px) : U32)) : U32), none())

def postcols(n: Nat, cs: List<&2, Cover>, +x: U32) -> List<&2, U32>:
  match n cs:
    case 1n+p +c <> t:
      post(c, x) <> postcols(p, t, (x + 1 : U32))
    case _ _:
      []

def blob(bss: List<&2, List<&2, U32>>) -> List<&2, U32>:
  match bss:
    case bs <> t:
      List.append(&2, U32, bs, blob(t))
    case []:
      []

def extra(masked: Bool, +n: Nat, +cs: List<&2, Cover>, bss: List<&2, List<&2, U32>>) -> List<&2, U32> & List<&2, U32>:
  match masked:
    case True{}:
      (postcols(n, cs, 0), blob(bss))
    case False{}:
      ([], [])

def tex.done(+m: U32, +h: U32, ts: List<&2, U32>, r: List<&2, U32> & List<&2, U32>) -> Tex:
  (ps, bl) = r
  Tex{m, h, ts, ps, bl}

def tex.build(+w: U32, +h: U32, +cs: List<&2, Cover>, +cofs: T.Vec<U32>, +ps: List<&2, Patch>, masked: Bool, bss: List<&2, List<&2, U32>>) -> Tex:
  +blk = T.from_list(U32, P.own(Array.to_list(~U32, composite(ps, Array.new(U32, 1n+U32.log2(((multi(cs) + 1) * h + 128 : U32)), 0), w, cofs, h))))
  +n = U32.to_nat((mask(w) + 1 : U32))
  tex.done(mask(w), (h << 16n : U32), sources(n, cs, 0, cofs, blk), extra(masked, n, cs, bss))

def tex.of(+w: U32, +h: U32, +ps: List<&2, Patch>, masked: Bool, bss: List<&2, List<&2, U32>>) -> Tex:
  +cs = cover.all(U32.to_nat(w), ps, 0)
  tex.build(w, h, cs, T.from_list(U32, place(cs, h, 0)), ps, masked, bss)

def tex(d: TexDef, +bss: List<&2, List<&2, U32>>, masked: Bool) -> Tex:
  match d:
    case TexDef{n, +w, +h, rs}:
      tex.of(w, h, patches(rs, bss, 0), masked, bss)
