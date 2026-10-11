import Base
import ./mem.bend as M
import ./tab.bend as X

def lcnt() -> U32:
  0

def lsym() -> U32:
  16

def dcnt() -> U32:
  320

def dsym() -> U32:
  336

def lens() -> U32:
  384

def pos() -> U32:
  720

def outn() -> U32:
  721

def offs() -> U32:
  724

def lbase() -> U32:
  744

def lext() -> U32:
  776

def dbase() -> U32:
  808

def dext() -> U32:
  840

def order() -> U32:
  872

def bad() -> U32:
  892

def inp() -> U32:
  1024

def consts() -> List<&2, U32>:
  List.append(&2, U32, [3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0, 0],
  List.append(&2, U32, [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 0, 0, 0],
  List.append(&2, U32, [1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577, 0, 0],
  List.append(&2, U32, [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 0, 0],
    [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]))))

def bump(a: Array<U32>, +i: U32, +d: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(a, i), a1 => +v => M.wr(a1, i, (v + d : U32)))

def bits.go(n: Nat, a: Array<U32>, +p: U32, +k: U32, +acc: U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (M.wr(a, pos(), p), acc)
    case 1n+q:
      M.let(Array<U32> & U32, M.rd(a, (inp() + (p >> 3n) : U32)), a1 => +b =>
        bits.go(q, a1, (p + 1 : U32), (k + 1 : U32), (acc .|. (((b >> U32.to_nat((p .&. 7 : U32))) .&. 1 : U32) << U32.to_nat(k)) : U32)))

def bits(a: Array<U32>, +n: U32) -> Array<U32> & U32:
  M.let(Array<U32> & U32, M.rd(a, pos()), a1 => +p => bits.go(U32.to_nat(n), a1, p, 0, 0))

def fill(n: Nat, a: Array<U32>, +i: U32, +v: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      fill(q, M.wr(a, i, v), (i + 1 : U32), v)

def count(n: Nat, a: Array<U32>, +src: U32, +cnt: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      M.let(Array<U32>, M.rd(a, src), a1 => +l => count(q, bump(a1, (cnt + l : U32), 1), (src + 1 : U32), cnt))

def starts(n: Nat, a: Array<U32>, +cnt: U32, +l: U32, +acc: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      M.let(Array<U32>, M.rd(a, (cnt + l : U32)), a1 => +c =>
        starts(q, M.wr(a1, (offs() + l + 1 : U32), (acc + c : U32)), cnt, (l + 1 : U32), (acc + c : U32)))

def place.go(zero: Bool, a: Array<U32>, +l: U32, +sym: U32, +s: U32) -> Array<U32>:
  match zero:
    case True{}:
      a
    case False{}:
      M.let(Array<U32>, M.rd(a, (offs() + l : U32)), a1 => +o => bump(M.wr(a1, (sym + o : U32), s), (offs() + l : U32), 1))

def syms(n: Nat, a: Array<U32>, +src: U32, +sym: U32, +s: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      M.let(Array<U32>, M.rd(a, (src + s : U32)), a1 => +l => syms(q, place.go(U32.is_eq(l, 0), a1, l, sym, s), src, sym, (s + 1 : U32)))

def build(a: Array<U32>, +src: U32, +n: U32, +cnt: U32, +sym: U32) -> Array<U32>:
  a1 = count(U32.to_nat(n), fill(16n, a, cnt, 0), src, cnt)
  a2 = starts(15n, fill(17n, a1, offs(), 0), cnt, 1, 0)
  syms(U32.to_nat(n), a2, src, sym, 0)

def decode.hit?(hit: Bool, n: Nat, a: Array<U32>, +cnt: U32, +sym: U32, +code: U32, +first: U32, +index: U32, +l: U32, +c: U32) -> Array<U32> & U32:
  match hit:
    case True{}:
      M.rd(a, (sym + index + code - first : U32))
    case False{}:
      decode.go(n, a, cnt, sym, (code << 1n : U32), ((first + c) << 1n : U32), (index + c : U32), (l + 1 : U32))

def decode.go?(n: Nat, a: Array<U32>, +cnt: U32, +sym: U32, +code: U32, +first: U32, +index: U32, +l: U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (M.wr(a, bad(), 1), 256)
    case 1n+q:
      M.let(Array<U32> & U32, bits(a, 1), a1 => +b =>
        M.let(Array<U32> & U32, M.rd(a1, (cnt + l : U32)), a2 => +c =>
          decode.hit(U32.is_lt((code .|. b : U32), (first + c : U32)), q, a2, cnt, sym, (code .|. b : U32), first, index, l, c)))

def decode(a: Array<U32>, +cnt: U32, +sym: U32) -> Array<U32> & U32:
  decode.go(15n, a, cnt, sym, 0, 0, 0, 1)

def put.w(wr: Bool, a: Array<U32>, +i: U32, +v: U32) -> Array<U32>:
  match wr:
    case True{}:
      M.wr(a, i, v)
    case False{}:
      a

def put(+wr: Bool, a: Array<U32>, +ob: U32, +v: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(a, outn()), a1 => +o => M.wr(put.w(wr, a1, (ob + o : U32), v), outn(), (o + 1 : U32)))

def copy(n: Nat, +wr: Bool, a: Array<U32>, +ob: U32, +d: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      M.let(Array<U32>, M.rd(a, outn()), a1 => +o =>
        M.let(Array<U32>, M.rd(a1, Bool.pick(U32, wr, (ob + o - d : U32), 0)), a2 => +v => copy(q, wr, put(wr, a2, ob, v), ob, d)))

def stored.copy(n: Nat, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      M.let(Array<U32>, bits(a, 8), a1 => +v => stored.copy(q, wr, put(wr, a1, ob, v), ob))

def stored(+wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(a, pos()), a1 => +p =>
    M.let(Array<U32>, bits(M.wr(a1, pos(), ((p + 7) .&. 4294967288 : U32)), 16), a2 => +len =>
      M.let(Array<U32>, bits(a2, 16), a3 => +nl => stored.copy(U32.to_nat(len), wr, a3, ob))))

def extra(a: Array<U32>, +tb: U32, +te: U32, +i: U32) -> Array<U32> & U32:
  M.let(Array<U32> & U32, M.rd(a, (tb + i : U32)), a1 => +b =>
    M.let(Array<U32> & U32, M.rd(a1, (te + i : U32)), a2 => +e =>
      M.let(Array<U32> & U32, bits(a2, e), a3 => +x => (a3, (b + x : U32)))))

def codes.lit?(lit: Bool, n: Nat, +s: U32, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match lit:
    case True{}:
      codes(n, wr, put(wr, a, ob, s), ob)
    case False{}:
      codes.len(n, wr, a, ob, (s - 257 : U32))

def codes.end?(end: Bool, n: Nat, +s: U32, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match end:
    case True{}:
      a
    case False{}:
      codes.lit(U32.is_lt(s, 256), n, s, wr, a, ob)

def codes.ok?(ok: Bool, n: Nat, +s: U32, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match ok:
    case True{}:
      codes.go(n, s, wr, a, ob)
    case False{}:
      a

def codes.go?(n: Nat, +s: U32, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      codes.end(U32.is_eq(s, 256), q, s, wr, a, ob)

def codes.len?(n: Nat, +wr: Bool, a: Array<U32>, +ob: U32, +i: U32) -> Array<U32>:
  M.let(Array<U32>, extra(a, lbase(), lext(), U32.min(i, 29)), a1 => +len =>
    M.let(Array<U32>, decode(a1, dcnt(), dsym()), a2 => +ds =>
      M.let(Array<U32>, extra(a2, dbase(), dext(), U32.min(ds, 29)), a3 => +d =>
        codes(n, wr, copy(U32.to_nat(len), wr, a3, ob, d), ob))))

def codes?(n: Nat, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  M.let(Array<U32>, decode(a, lcnt(), lsym()), a1 => +s =>
    M.let(Array<U32>, M.rd(a1, bad()), a2 => +e => codes.ok(U32.is_eq(e, 0), n, s, wr, a2, ob)))

def fixed(a: Array<U32>) -> Array<U32>:
  a1 = fill(8n, fill(24n, fill(112n, fill(144n, a, lens(), 8), (lens() + 144 : U32), 9), (lens() + 256 : U32), 7), (lens() + 280 : U32), 8)
  a2 = build(a1, lens(), 288, lcnt(), lsym())
  build(fill(30n, a2, lens(), 5), lens(), 30, dcnt(), dsym())

def clens(n: Nat, a: Array<U32>, +i: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      M.let(Array<U32>, M.rd(a, (order() + i : U32)), a1 => +o =>
        M.let(Array<U32>, bits(a1, 3), a2 => +l => clens(q, M.wr(a2, (lens() + o : U32), l), (i + 1 : U32))))

def lengths.rep?(n: Nat, a: Array<U32>, +at: U32, +v: U32, +r: U32, +total: U32) -> Array<U32>:
  lengths(n, fill(U32.to_nat(r), a, (lens() + at : U32), v), (at + r : U32), total)

def lengths.prev?(n: Nat, a: Array<U32>, +at: U32, +total: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(a, (lens() + at - 1 : U32)), a1 => +v =>
    M.let(Array<U32>, bits(a1, 2), a2 => +r => lengths.rep(n, a2, at, v, U32.min((r + 3 : U32), (total - at : U32)), total)))

def lengths.zero?(n: Nat, a: Array<U32>, +at: U32, +total: U32, +nb: U32, +base: U32) -> Array<U32>:
  M.let(Array<U32>, bits(a, nb), a1 => +r => lengths.rep(n, a1, at, 0, U32.min((r + base : U32), (total - at : U32)), total))

def lengths.rp?(prev: Bool, n: Nat, a: Array<U32>, +at: U32, +s: U32, +total: U32) -> Array<U32>:
  match prev:
    case True{}:
      lengths.prev(n, a, at, total)
    case False{}:
      lengths.zero(n, a, at, total, Bool.pick(U32, U32.is_eq(s, 17), 3, 7), Bool.pick(U32, U32.is_eq(s, 17), 3, 11))

def lengths.sym?(lit: Bool, n: Nat, a: Array<U32>, +at: U32, +s: U32, +total: U32) -> Array<U32>:
  match lit:
    case True{}:
      lengths(n, M.wr(a, (lens() + at : U32), s), (at + 1 : U32), total)
    case False{}:
      lengths.rp(U32.is_eq(s, 16), n, a, at, s, total)

def lengths.more?(more: Bool, n: Nat, a: Array<U32>, +at: U32, +total: U32) -> Array<U32>:
  match more:
    case True{}:
      M.let(Array<U32>, decode(a, dcnt(), dsym()), a1 => +s => lengths.sym(U32.is_lt(s, 16), n, a1, at, s, total))
    case False{}:
      a

def lengths?(n: Nat, a: Array<U32>, +at: U32, +total: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      lengths.more(U32.is_lt(at, total), q, a, at, total)

def dynamic.go(a: Array<U32>, +nl: U32, +nd: U32) -> Array<U32>:
  a1 = lengths(320n, build(a, lens(), 19, dcnt(), dsym()), 0, (nl + nd : U32))
  build(build(a1, lens(), nl, lcnt(), lsym()), (lens() + nl : U32), nd, dcnt(), dsym())

def dynamic(a: Array<U32>) -> Array<U32>:
  M.let(Array<U32>, bits(a, 5), a1 => +nl =>
    M.let(Array<U32>, bits(a1, 5), a2 => +nd =>
      M.let(Array<U32>, bits(a2, 4), a3 => +nc =>
        dynamic.go(clens(U32.to_nat((nc + 4 : U32)), fill(19n, a3, lens(), 0), 0), (nl + 257 : U32), (nd + 1 : U32)))))

def block.dyn(dyn: Bool, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match dyn:
    case True{}:
      codes(U32.to_nat(4294967295), wr, dynamic(a), ob)
    case False{}:
      M.wr(a, bad(), 1)

def block.fix(fix: Bool, +t: U32, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match fix:
    case True{}:
      codes(U32.to_nat(4294967295), wr, fixed(a), ob)
    case False{}:
      block.dyn(U32.is_eq(t, 2), wr, a, ob)

def block(raw: Bool, +t: U32, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match raw:
    case True{}:
      stored(wr, a, ob)
    case False{}:
      block.fix(U32.is_eq(t, 1), t, wr, a, ob)

def blocks.next?(stop: Bool, n: Nat, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match stop:
    case True{}:
      a
    case False{}:
      blocks(n, wr, a, ob)

def blocks.end?(n: Nat, +last: Bool, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  M.let(Array<U32>, M.rd(a, bad()), a1 => +e => blocks.next(Bool.or(last, U32.is_ne(e, 0)), n, wr, a1, ob))

def blocks?(n: Nat, +wr: Bool, a: Array<U32>, +ob: U32) -> Array<U32>:
  match n:
    case 0n:
      a
    case 1n+q:
      M.let(Array<U32>, bits(a, 1), a1 => +last =>
        M.let(Array<U32>, bits(a1, 2), a2 => +t =>
          blocks.end(q, U32.is_ne(last, 0), wr, block(U32.is_eq(t, 0), t, wr, a2, ob), ob)))

def load(xs: List<&2, U32>, +n: U32, +extra: U32) -> Array<U32>:
  M.fill(consts(), M.fill(xs, Array.new(U32, M.depth((inp() + n + extra + 1 : U32)), 0), inp()), lbase())

def run(+wr: Bool, a: Array<U32>, +n: U32, +skip: U32) -> Array<U32>:
  blocks(U32.to_nat(4294967295), wr, M.wr(a, pos(), (skip * 8 : U32)), (inp() + n : U32))

def out(n: Nat, a: Array<U32>, +i: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      acc
    case 1n+q:
      M.let(List<&2, U32>, M.rd(a, (i - 1 : U32)), a1 => +v => out(q, a1, (i - 1 : U32), v <> acc))

def size(a: Array<U32>) -> U32:
  M.let(U32, M.rd(a, outn()), a1 => +o => o)

def inflate.go(+xs: List<&2, U32>, +n: U32, +skip: U32, +total: U32) -> List<&2, U32>:
  a = run(True{}, load(xs, n, total), n, skip)
  M.let(List<&2, U32>, M.rd(a, outn()), a1 => +o => out(U32.to_nat(o), a1, (inp() + n + o : U32), []))

def inflate(+xs: List<&2, U32>, +skip: U32) -> List<&2, U32>:
  +n = X.len(U32, xs)
  inflate.go(xs, n, skip, size(run(False{}, load(xs, n, 0), n, skip)))
