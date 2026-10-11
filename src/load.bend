import Base
import ./bytes.bend as B
import ./tab.bend as T
import ./wad.bend as W
import ./level.bend as L
import ./gfx.bend as G

type Texs is Data:
  Texs{names: List<&2, String>, texs: List<&2, G.Tex>, sky: String, flats: List<&2, String>, flatdata: List<&2, List<&2, U32>>, heights: List<&2, U32>, tanims: List<&2, List<&2, String>>, fanims: List<&2, List<&2, String>>, switches: List<&2, String>, tbases: List<&2, U32>, fbases: List<&2, U32>}

def has(xs: List<&2, String>, +s: String) -> Bool:
  match xs:
    case x <> t:
      Bool.or(String.eq(x, s), has(t, s))
    case []:
      False{}

def add(+skip: String, +xs: List<&2, String>, +s: String) -> List<&2, String>:
  Bool.pick(List<&2, String>, Bool.or(Bool.or(has(xs, s), String.eq(s, "-")), Bool.or(String.eq(s, skip), String.is_empty(s))), xs, s <> xs)

def needed.side(+skip: String, acc: List<&2, String>, d: L.Side) -> List<&2, String>:
  match d:
    case L.Side{x, y, u, l, m, s}:
      add(skip, add(skip, add(skip, acc, u), l), m)

def needed(n: Nat, +sides: T.Vec<L.Side>, +i: U32, +skip: String, acc: List<&2, String>) -> List<&2, String>:
  match n:
    case 0n:
      acc
    case 1n+p:
      needed(p, sides, (i + 1 : U32), skip, needed.side(skip, acc, T.get(L.Side, sides, i, L.Side{0, 0, "", "", "", 0})))

def first(ds: List<&2, G.TexDef>) -> String:
  match ds:
    case G.TexDef{n, w, h, ps} <> t:
      n
    case []:
      ""

def tdef.named(+d: G.TexDef, +name: String) -> Bool:
  match d:
    case G.TexDef{n, w, h, ps}:
      String.eq(n, name)

def tdef(ds: List<&2, G.TexDef>, +name: String, z: G.TexDef) -> G.TexDef:
  match ds:
    case +d <> t:
      tdef(t, name, Bool.pick(G.TexDef, tdef.named(d, name), d, z))
    case []:
      z

def lumpnames(+pn: T.Vec<String>, rs: List<&2, G.PRef>) -> List<&2, String>:
  match rs:
    case G.PRef{x, y, k} <> t:
      T.get(String, pn, k, "") <> lumpnames(pn, t)
    case []:
      []

def refs(+d: G.TexDef) -> List<&2, G.PRef>:
  match d:
    case G.TexDef{n, w, h, ps}:
      ps

def built.cons(t: G.Tex, r: W.Wad & List<&2, G.Tex>) -> IO(W.Wad & List<&2, G.Tex>):
  (w, ts) = r
  IO.pure(W.Wad & List<&2, G.Tex>, (w, t <> ts))

def built.one(+d: G.TexDef, +masked: Bool, p: W.Wad & List<&2, List<&2, U32>>, k: W.Wad -> IO(W.Wad & List<&2, G.Tex>)) -> IO(W.Wad & List<&2, G.Tex>):
  (w, bss) = p
  IO.bind(W.Wad & List<&2, G.Tex>, W.Wad & List<&2, G.Tex>, k(w), r => built.cons(G.tex(d, bss, masked), r))

def built.def(+d: G.TexDef, +masked: Bool, w: W.Wad, k: W.Wad -> IO(W.Wad & List<&2, G.Tex>), +pn: T.Vec<String>) -> IO(W.Wad & List<&2, G.Tex>):
  IO.bind(W.Wad & List<&2, List<&2, U32>>, W.Wad & List<&2, G.Tex>, W.get(w, lumpnames(pn, refs(d))), p => built.one(d, masked, p, k))

def built(names: List<&2, String>, w: W.Wad, +defs: List<&2, G.TexDef>, +pn: T.Vec<String>, +mk: List<&2, String>) -> IO(W.Wad & List<&2, G.Tex>):
  match names:
    case +n <> t:
      built.def(tdef(defs, n, G.TexDef{"", 0, 0, []}), has(mk, n), w, k => built(t, k, defs, pn, mk), pn)
    case []:
      IO.pure(W.Wad & List<&2, G.Tex>, (w, []))

def mid.of(+d: L.Side) -> String:
  match d:
    case L.Side{x, y, u, l, m, s}:
      m

def masked.line(+sides: T.Vec<L.Side>, +acc: List<&2, String>, l: L.Line) -> List<&2, String>:
  match l:
    case L.Line{a, b, +fl, sp, tg, +fr, +bk}:
      Bool.pick(List<&2, String>, U32.is_eq((fl .&. 4 : U32), 0), acc,
        mid.of(T.get(L.Side, sides, fr, L.Side{0, 0, "", "", "-", 0})) <> mid.of(T.get(L.Side, sides, bk, L.Side{0, 0, "", "", "-", 0})) <> acc)

def masked(n: Nat, +lines: T.Vec<L.Line>, +sides: T.Vec<L.Side>, +i: U32, acc: List<&2, String>) -> List<&2, String>:
  match n:
    case 0n:
      acc
    case 1n+p:
      masked(p, lines, sides, (i + 1 : U32), masked.line(sides, acc, T.get(L.Line, lines, i, L.Line{0, 0, 0, 0, 0, 0, 0})))

def skyname(+map: String) -> String:
  Bool.pick(String, String.starts_with(map, "MAP"),
    Bool.pick(String, String.is_lt(map, "MAP12"), "SKY1", Bool.pick(String, String.is_lt(map, "MAP21"), "SKY2", "SKY3")),
    String.append("SKY", String.take(String.drop(map, 1n), 1n)))

def flatname.add(+xs: List<&2, String>, +s: String) -> List<&2, String>:
  Bool.pick(List<&2, String>, Bool.or(has(xs, s), String.eq(s, "F_SKY1")), xs, s <> xs)

def flatnames.of(acc: List<&2, String>, d: L.Sector) -> List<&2, String>:
  match d:
    case L.Sector{f, c, fp, cp, li, sp, tg}:
      flatname.add(flatname.add(acc, fp), cp)

def flatnames(n: Nat, +secs: T.Vec<L.Sector>, +i: U32, acc: List<&2, String>) -> List<&2, String>:
  match n:
    case 0n:
      acc
    case 1n+p:
      flatnames(p, secs, (i + 1 : U32), flatnames.of(acc, T.get(L.Sector, secs, i, L.Sector{0, 0, "F_SKY1", "F_SKY1", 0, 0, 0})))

def tanimdefs() -> List<&2, String>:
  ["BLODGR1", "BLODGR4", "SLADRIP1", "SLADRIP3", "BLODRIP1", "BLODRIP4", "FIREWALA", "FIREWALL", "GSTFONT1", "GSTFONT3", "FIRELAV3", "FIRELAVA",
   "FIREMAG1", "FIREMAG3", "FIREBLU1", "FIREBLU2", "ROCKRED1", "ROCKRED3", "BFALL1", "BFALL4", "SFALL1", "SFALL4", "WFALL1", "WFALL4", "DBRAIN1", "DBRAIN4"]

def fanimdefs() -> List<&2, String>:
  ["NUKAGE1", "NUKAGE3", "FWATER1", "FWATER4", "SWATER1", "SWATER4", "LAVA1", "LAVA4", "BLOOD1", "BLOOD3",
   "RROCK05", "RROCK08", "SLIME01", "SLIME04", "SLIME05", "SLIME08", "SLIME09", "SLIME12"]

def switchdefs1() -> List<&2, String>:
  ["SW1BRCOM", "SW2BRCOM", "SW1BRN1", "SW2BRN1", "SW1BRN2", "SW2BRN2", "SW1BRNGN", "SW2BRNGN", "SW1BROWN", "SW2BROWN",
   "SW1COMM", "SW2COMM", "SW1COMP", "SW2COMP", "SW1DIRT", "SW2DIRT", "SW1EXIT", "SW2EXIT", "SW1GRAY", "SW2GRAY",
   "SW1GRAY1", "SW2GRAY1", "SW1METAL", "SW2METAL", "SW1PIPE", "SW2PIPE", "SW1SLAD", "SW2SLAD", "SW1STARG", "SW2STARG",
   "SW1STON1", "SW2STON1", "SW1STON2", "SW2STON2", "SW1STONE", "SW2STONE", "SW1STRTN", "SW2STRTN"]

def switchdefs2() -> List<&2, String>:
  ["SW1BLUE", "SW2BLUE", "SW1CMT", "SW2CMT", "SW1GARG", "SW2GARG", "SW1GSTON", "SW2GSTON", "SW1HOT", "SW2HOT",
   "SW1LION", "SW2LION", "SW1SATYR", "SW2SATYR", "SW1SKIN", "SW2SKIN", "SW1VINE", "SW2VINE", "SW1WOOD", "SW2WOOD"]

def switchdefs3() -> List<&2, String>:
  ["SW1PANEL", "SW2PANEL", "SW1ROCK", "SW2ROCK", "SW1MET2", "SW2MET2", "SW1WDMET", "SW2WDMET", "SW1BRIK", "SW2BRIK",
   "SW1MOD1", "SW2MOD1", "SW1ZIM", "SW2ZIM", "SW1STON6", "SW2STON6", "SW1TEK", "SW2TEK", "SW1MARB", "SW2MARB", "SW1SKULL", "SW2SKULL"]

def switchdefs(+commercial: Bool) -> List<&2, String>:
  List.append(&2, String, List.append(&2, String, switchdefs1(), switchdefs2()), Bool.pick(List<&2, String>, commercial, switchdefs3(), []))

def defnames(ds: List<&2, G.TexDef>) -> List<&2, String>:
  match ds:
    case G.TexDef{n, w, h, ps} <> t:
      n <> defnames(t)
    case []:
      []

def lumpnames.of(ls: List<&2, W.Lump>) -> List<&2, String>:
  match ls:
    case W.Lump{n, p, z, k} <> t:
      n <> lumpnames.of(t)
    case []:
      []

def upto.go(xs: List<&2, String>, stop: Bool, +b: String) -> List<&2, String>:
  match xs stop:
    case +x <> +t False{}:
      x <> upto.go(t, String.eq(x, b), b)
    case _ _:
      []

def upto(xs: List<&2, String>, +b: String) -> List<&2, String>:
  upto.go(xs, False{}, b)

def ends(xs: List<&2, String>, +b: String) -> Bool:
  match xs:
    case +x <> +t:
      Bool.pick(Bool, List.is_empty(&2, String, t), String.eq(x, b), ends(t, b))
    case []:
      False{}

def slice.hit?(hit: Bool, +x: String, t: List<&2, String>, +a: String) -> List<&2, String>:
  match hit:
    case True{}:
      x <> t
    case False{}:
      slice.go(t, a)

def slice.go?(xs: List<&2, String>, +a: String) -> List<&2, String>:
  match xs:
    case +x <> t:
      slice.hit(String.eq(x, a), x, t, a)
    case []:
      []

def slice(xs: List<&2, String>, +a: String, +b: String) -> List<&2, String>:
  +r = slice.go(xs, a)
  upto(r, b)

def range(+order: List<&2, String>, +a: String, +b: String) -> List<&2, String>:
  +r = slice(order, a, b)
  Bool.pick(List<&2, String>, ends(r, b), r, [])

def any(xs: List<&2, String>, +have: List<&2, String>) -> Bool:
  match xs:
    case +x <> +t:
      Bool.or(has(have, x), any(t, have))
    case []:
      False{}

def ranges(ps: List<&2, String>, +order: List<&2, String>, +have: List<&2, String>) -> List<&2, List<&2, String>>:
  match ps:
    case +a <> +b <> +t:
      +r = range(order, a, b)
      +rest = ranges(t, order, have)
      Bool.pick(List<&2, List<&2, String>>, Bool.and(U32.is_gt(U32.from_nat(List.length(&2, String, r)), 1), any(r, have)), r <> rest, rest)
    case _:
      []

def pos(xs: List<&2, String>, +s: String, +i: U32) -> U32:
  match xs:
    case x <> t:
      Bool.pick(U32, String.eq(x, s), i, pos(t, s, (i + 1 : U32)))
    case []:
      0

def bases(ps: List<&2, String>, +order: List<&2, String>, +have: List<&2, String>) -> List<&2, U32>:
  match ps:
    case +a <> +b <> +t:
      +r = range(order, a, b)
      +rest = bases(t, order, have)
      Bool.pick(List<&2, U32>, Bool.and(U32.is_gt(U32.from_nat(List.length(&2, String, r)), 1), any(r, have)), pos(order, a, 0) <> rest, rest)
    case _:
      []

def pairs(ps: List<&2, String>, +order: List<&2, String>, +have: List<&2, String>) -> List<&2, String>:
  match ps:
    case +a <> +b <> +t:
      +rest = pairs(t, order, have)
      Bool.pick(List<&2, String>, Bool.and(Bool.and(has(order, a), has(order, b)), Bool.or(has(have, a), has(have, b))), a <> b <> rest, rest)
    case _:
      []

def concat(xss: List<&2, List<&2, String>>) -> List<&2, String>:
  match xss:
    case xs <> t:
      List.append(&2, String, xs, concat(t))
    case []:
      []

def extend.go(+skip: String, xs: List<&2, String>, acc: List<&2, String>) -> List<&2, String>:
  match xs:
    case +x <> t:
      extend.go(skip, t, add(skip, acc, x))
    case []:
      acc

def extend(+skip: String, +base: List<&2, String>, xs: List<&2, String>) -> List<&2, String>:
  List.reverse(&2, String, extend.go(skip, xs, List.reverse(&2, String, base)))

def tdef.height(+d: G.TexDef) -> U32:
  match d:
    case G.TexDef{n, w, h, ps}:
      h

def heights(+defs: List<&2, G.TexDef>, names: List<&2, String>) -> List<&2, U32>:
  match names:
    case +n <> t:
      (tdef.height(tdef(defs, n, G.TexDef{"", 0, 0, []})) << 16n : U32) <> heights(defs, t)
    case []:
      []

def textures.flats(+names: List<&2, String>, +sky: String, +fl: List<&2, String>, +hs: List<&2, U32>, +tr: List<&2, List<&2, String>>, +fr: List<&2, List<&2, String>>, +sw: List<&2, String>, +tb: List<&2, U32>, +fb: List<&2, U32>, ts: List<&2, G.Tex>, p: W.Wad & List<&2, List<&2, U32>>) -> IO(W.Wad & Texs):
  (w, fds) = p
  IO.pure(W.Wad & Texs, (w, Texs{names, ts, sky, fl, fds, hs, tr, fr, sw, tb, fb}))

def textures.fin(+names: List<&2, String>, +sky: String, +fl: List<&2, String>, +hs: List<&2, U32>, +tr: List<&2, List<&2, String>>, +fr: List<&2, List<&2, String>>, +sw: List<&2, String>, +tb: List<&2, U32>, +fb: List<&2, U32>, r: W.Wad & List<&2, G.Tex>) -> IO(W.Wad & Texs):
  (w, ts) = r
  IO.bind(W.Wad & List<&2, List<&2, U32>>, W.Wad & Texs, W.get(w, fl), p => textures.flats(names, sky, fl, hs, tr, fr, sw, tb, fb, ts, p))

def textures.with(+sides: T.Vec<L.Side>, +mk: List<&2, String>, +sky: String, +fl: List<&2, String>, +fr: List<&2, List<&2, String>>, +fb: List<&2, U32>, +com: Bool, w: W.Wad, +pn: T.Vec<String>, +defs: List<&2, G.TexDef>) -> IO(W.Wad & Texs):
  +skip = first(defs)
  +names0 = List.reverse(&2, String, add(skip, needed(U32.to_nat(T.size(L.Side, sides)), sides, 0, skip, []), sky))
  +order = defnames(defs)
  +tr = ranges(tanimdefs(), order, names0)
  +tb = bases(tanimdefs(), order, names0)
  +sw = pairs(switchdefs(com), order, names0)
  +names = extend(skip, names0, List.append(&2, String, concat(tr), sw))
  +hs = heights(defs, skip <> names)
  IO.bind(W.Wad & List<&2, G.Tex>, W.Wad & Texs, built(names, w, defs, pn, mk), r => textures.fin(names, sky, fl, hs, tr, fr, sw, tb, fb, r))

def textures.parts(+sides: T.Vec<L.Side>, +mk: List<&2, String>, +sky: String, +fl: List<&2, String>, +fr: List<&2, List<&2, String>>, +fb: List<&2, U32>, +com: Bool, w: W.Wad, bss: List<&2, List<&2, U32>>) -> IO(W.Wad & Texs):
  match bss:
    case pn <> t1 <> t2 <> t:
      textures.with(sides, mk, sky, fl, fr, fb, com, w, T.from_list(String, G.pnames(List.drop(&2, U32, B.words(pn), 2n))), List.append(&2, G.TexDef, G.texdefs(t1), G.texdefs(t2)))
    case _:
      IO.die(W.Wad & Texs, 1, "no PNAMES or TEXTURE1")

def textures.got(+sides: T.Vec<L.Side>, +mk: List<&2, String>, +sky: String, +fl: List<&2, String>, +fr: List<&2, List<&2, String>>, +fb: List<&2, U32>, +com: Bool, p: W.Wad & List<&2, List<&2, U32>>) -> IO(W.Wad & Texs):
  (w, bss) = p
  textures.parts(sides, mk, sky, fl, fr, fb, com, w, bss)

def textures.of(+si: T.Vec<L.Side>, +mk: List<&2, String>, +sky: String, +fl0: List<&2, String>, +com: Bool, r: W.Wad & List<&2, W.Lump>) -> IO(W.Wad & Texs):
  (w, fls) = r
  +lns = lumpnames.of(fls)
  +fr = ranges(fanimdefs(), lns, fl0)
  +fb = bases(fanimdefs(), lns, fl0)
  +fl = extend("F_SKY1", fl0, concat(fr))
  IO.bind(W.Wad & List<&2, List<&2, U32>>, W.Wad & Texs, W.get(w, ["PNAMES", "TEXTURE1", "TEXTURE2"]), p => textures.got(si, mk, sky, fl, fr, fb, com, p))

def textures(w: W.Wad, +lv: L.Level, +skyn: U32) -> IO(W.Wad & Texs):
  match lv:
    case L.Level{n, th, +li, +si, ve, se, ss, no, +sc, rj, bm}:
      +mk = masked(U32.to_nat(T.size(L.Line, li)), li, si, 0, [])
      +sky = Bool.pick(String, U32.is_eq(skyn, 0), skyname(n), String.append("SKY", U32.show(skyn)))
      +fl0 = List.reverse(&2, String, flatnames(U32.to_nat(T.size(L.Sector, sc)), sc, 0, []))
      textures.of(si, mk, sky, fl0, String.starts_with(n, "MAP"), W.section(w, "F_START", "F_END", "FF_START", "FF_END"))
