import Base
import ./tab.bend as T
import ./wad.bend as W
import ./level.bend as L
import ./info.bend as I

type Spawn is Data:
  Spawn{x: U32, y: U32, angle: U32, kind: U32, sprite: U32, frame: U32, flags: U32, height: U32}

type SFrame is Data:
  SFrame{rot: Bool, l0: U32, l1: U32, l2: U32, l3: U32, l4: U32, l5: U32, l6: U32, l7: U32, flip: U32}

type Sprites is Data:
  Sprites{lumps: List<&2, W.Lump>, frames: T.Vec<SFrame>}

def info(+mi: T.Vec<U32>, +k: U32, +f: U32) -> U32:
  T.get(U32, mi, (k * 23 + f : U32), 0)

def state(+st: T.Vec<U32>, +s: U32, +f: U32) -> U32:
  T.get(U32, st, (s * 7 + f : U32), 0)

def kind(n: Nat, +mi: T.Vec<U32>, +ed: U32, +i: U32) -> U32:
  match n:
    case 0n:
      65535
    case 1n+p:
      Bool.pick(U32, U32.is_eq(info(mi, i, 0), ed), i, kind(p, mi, ed, (i + 1 : U32)))

def skip(+ty: U32, +opt: U32, +k: U32) -> Bool:
  Bool.or(Bool.or(U32.is_le(ty, 4), U32.is_eq(ty, 11)), Bool.or(Bool.or(U32.is_eq((opt .&. 2 : U32), 0), Bool.not(U32.is_eq((opt .&. 16 : U32), 0))), U32.is_eq(k, 65535)))

def spawn(+mi: T.Vec<U32>, +st: T.Vec<U32>, +x: U32, +y: U32, +a: U32, +k: U32, +opt: U32) -> Spawn:
  +s = info(mi, k, 1)
  Spawn{(x << 16n : U32), (y << 16n : U32), (536870912 * (a / 45) : U32), k, state(st, s, 0), state(st, s, 1),
    (info(mi, k, 21) .|. Bool.pick(U32, U32.is_eq((opt .&. 8 : U32), 0), 0, 32) : U32), info(mi, k, 17)}

def spawns.one(+mi: T.Vec<U32>, +st: T.Vec<U32>, +t: L.Thing, +rest: List<&2, Spawn>) -> List<&2, Spawn>:
  match t:
    case L.Thing{+x, +y, +a, +ty, +opt}:
      +k = kind(U32.to_nat(I.ntypes()), mi, ty, 0)
      Bool.pick(List<&2, Spawn>, skip(ty, opt, k), rest, spawn(mi, st, x, y, a, k, opt) <> rest)

def spawns(n: Nat, +mi: T.Vec<U32>, +st: T.Vec<U32>, +ths: T.Vec<L.Thing>, +i: U32) -> List<&2, Spawn>:
  match n:
    case 0n:
      []
    case 1n+p:
      spawns.one(mi, st, T.get(L.Thing, ths, i, L.Thing{0, 0, 0, 0, 0}), spawns(p, mi, st, ths, (i + 1 : U32)))

def code(+s: Spawn) -> U32:
  match s:
    case Spawn{x, y, a, k, spr, fr, fl, h}:
      (spr * 32 + (fr .&. 31) : U32)

def has(xs: List<&2, U32>, +c: U32) -> Bool:
  match xs:
    case x <> t:
      Bool.or(U32.is_eq(x, c), has(t, c))
    case []:
      False{}

def codes(ss: List<&2, Spawn>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ss:
    case +s <> t:
      codes(t, Bool.pick(List<&2, U32>, has(acc, code(s)), acc, code(s) <> acc))
    case []:
      acc

def ch(m: Maybe<&2, Char>) -> U32:
  match m:
    case Some{c}:
      Char.to_u32(c)
    case None{}:
      0

def at(+s: String, n: Nat) -> U32:
  ch(String.get(s, n))

def prefix(+names: T.Vec<String>, +c: U32) -> String:
  T.get(String, names, (c >> 5n : U32), "")

def matches(+names: T.Vec<String>, +c: U32, +l: W.Lump) -> Bool:
  match l:
    case W.Lump{+n, p, z}:
      Bool.and(String.eq(String.take(n, 4n), prefix(names, c)),
        Bool.or(U32.is_eq(at(n, 4n), (65 + (c .&. 31) : U32)), U32.is_eq(at(n, 6n), (65 + (c .&. 31) : U32))))

def wanted(+names: T.Vec<String>, +cs: List<&2, U32>, +l: W.Lump) -> Bool:
  match cs:
    case +c <> t:
      Bool.or(matches(names, c, l), wanted(names, t, l))
    case []:
      False{}

def keep.if(hit: Bool, l: W.Lump, rest: List<&2, W.Lump>) -> List<&2, W.Lump>:
  match hit:
    case True{}:
      l <> rest
    case False{}:
      rest

def keep(ls: List<&2, W.Lump>, +names: T.Vec<String>, +cs: List<&2, U32>) -> List<&2, W.Lump>:
  match ls:
    case +l <> t:
      keep.if(wanted(names, cs, l), l, keep(t, names, cs))
    case []:
      []

def slot(+f: SFrame, +r: U32, +lump: U32, +fl: Bool) -> SFrame:
  match f:
    case SFrame{rot, l0, l1, l2, l3, l4, l5, l6, l7, +flip}:
      +bit = (1 << U32.to_nat(r) : U32)
      +nf = Bool.pick(U32, fl, (flip .|. bit : U32), (flip .&. (4294967295 - bit) : U32))
      SFrame{True{},
        Bool.pick(U32, U32.is_eq(r, 0), lump, l0), Bool.pick(U32, U32.is_eq(r, 1), lump, l1),
        Bool.pick(U32, U32.is_eq(r, 2), lump, l2), Bool.pick(U32, U32.is_eq(r, 3), lump, l3),
        Bool.pick(U32, U32.is_eq(r, 4), lump, l4), Bool.pick(U32, U32.is_eq(r, 5), lump, l5),
        Bool.pick(U32, U32.is_eq(r, 6), lump, l6), Bool.pick(U32, U32.is_eq(r, 7), lump, l7), nf}

def install(+f: SFrame, +r: U32, +lump: U32, +fl: Bool) -> SFrame:
  Bool.pick(SFrame, U32.is_eq(r, 48),
    SFrame{False{}, lump, lump, lump, lump, lump, lump, lump, lump, Bool.pick(U32, fl, 255, 0)},
    slot(f, (r - 49 : U32), lump, fl))

def apply(+names: T.Vec<String>, +c: U32, +f: SFrame, +l: W.Lump, +off: U32) -> SFrame:
  match l:
    case W.Lump{+n, p, z}:
      +same = String.eq(String.take(n, 4n), prefix(names, c))
      +a = Bool.and(same, U32.is_eq(at(n, 4n), (65 + (c .&. 31) : U32)))
      +b = Bool.and(same, U32.is_eq(at(n, 6n), (65 + (c .&. 31) : U32)))
      +f1 = Bool.pick(SFrame, a, install(f, at(n, 5n), off, False{}), f)
      Bool.pick(SFrame, b, install(f1, at(n, 7n), off, True{}), f1)

def lsize(+l: W.Lump) -> U32:
  match l:
    case W.Lump{n, p, z}:
      z

def build(ls: List<&2, W.Lump>, +names: T.Vec<String>, +c: U32, +off: U32, f: SFrame) -> SFrame:
  match ls:
    case +l <> t:
      build(t, names, c, (off + lsize(l) : U32), apply(names, c, f, l, off))
    case []:
      f

def blank() -> SFrame:
  SFrame{False{}, 0, 0, 0, 0, 0, 0, 0, 0, 0}

def frame.of(hit: Bool, +ls: List<&2, W.Lump>, +names: T.Vec<String>, +c: U32, +base: U32) -> SFrame:
  match hit:
    case True{}:
      build(ls, names, c, base, blank())
    case False{}:
      blank()

def table(n: Nat, +ls: List<&2, W.Lump>, +names: T.Vec<String>, +cs: List<&2, U32>, +c: U32, +base: U32) -> List<&2, SFrame>:
  match n:
    case 0n:
      []
    case 1n+p:
      frame.of(has(cs, c), ls, names, c, base) <> table(p, ls, names, cs, (c + 1 : U32), base)

def sprites(+all: List<&2, W.Lump>, +ss: List<&2, Spawn>, +base: U32) -> Sprites:
  +names = T.from_list(String, I.sprnames())
  +cs = codes(ss, [])
  +ls = keep(all, names, cs)
  Sprites{ls, T.from_list(SFrame, table(4416n, ls, names, cs, 0, base))}

def addc(+acc: List<&2, U32>, +c: U32) -> List<&2, U32>:
  Bool.pick(List<&2, U32>, has(acc, c), acc, c <> acc)

def chain(n: Nat, stop: Bool, +st: T.Vec<U32>, +s: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  match n stop:
    case 1n+p False{}:
      +nx = state(st, s, 4)
      chain(p, U32.is_eq(nx, 0), st, nx, addc(acc, (state(st, s, 0) * 32 + (state(st, s, 1) .&. 31) : U32)))
    case _ _:
      acc

def chain.from(+st: T.Vec<U32>, +s: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  chain(64n, U32.is_eq(s, 0), st, s, acc)

def typecodes(fs: List<&2, U32>, +mi: T.Vec<U32>, +st: T.Vec<U32>, +k: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  match fs:
    case +f <> t:
      typecodes(t, mi, st, k, chain.from(st, info(mi, k, f), acc))
    case []:
      acc

def reach.one(skip: Bool, +mi: T.Vec<U32>, +st: T.Vec<U32>, +k: U32, +acc: List<&2, U32>) -> List<&2, U32>:
  match skip:
    case True{}:
      acc
    case False{}:
      typecodes([1, 3, 7, 10, 11, 12, 13, 22], mi, st, k, acc)

def reach(ks: List<&2, U32>, +mi: T.Vec<U32>, +st: T.Vec<U32>, +seen: List<&2, U32>, +acc: List<&2, U32>) -> List<&2, U32>:
  match ks:
    case +k <> t:
      +skip = Bool.or(U32.is_eq(k, 65535), has(seen, k))
      reach(t, mi, st, Bool.pick(List<&2, U32>, skip, seen, k <> seen), reach.one(skip, mi, st, k, acc))
    case []:
      acc

def thing.kind(+mi: T.Vec<U32>, +t: L.Thing) -> U32:
  match t:
    case L.Thing{x, y, a, +ty, opt}:
      kind(U32.to_nat(I.ntypes()), mi, ty, 0)

def thingkinds(n: Nat, +mi: T.Vec<U32>, +ths: T.Vec<L.Thing>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      thing.kind(mi, T.get(L.Thing, ths, i, L.Thing{0, 0, 0, 0, 0})) <> thingkinds(p, mi, ths, (i + 1 : U32))

def needed(+mi: T.Vec<U32>, +st: T.Vec<U32>, +ths: T.Vec<L.Thing>) -> List<&2, U32>:
  +ks = List.append(&2, U32, [0, 37, 38, 39, 40, 63, 73, 77], thingkinds(U32.to_nat(T.size(L.Thing, ths)), mi, ths, 0))
  chain.from(st, 895, reach(ks, mi, st, [], []))

def sprites.of(+all: List<&2, W.Lump>, +cs: List<&2, U32>, +base: U32) -> Sprites:
  +names = T.from_list(String, I.sprnames())
  +ls = keep(all, names, cs)
  Sprites{ls, T.from_list(SFrame, table(4416n, ls, names, cs, 0, base))}
