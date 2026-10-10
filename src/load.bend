import Base
import ./bytes.bend as B
import ./tab.bend as T
import ./wad.bend as W
import ./level.bend as L
import ./gfx.bend as G

type Texs is Data:
  Texs{names: List<&2, String>, texs: T.Vec<G.Tex>}

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

def built.one(+d: G.TexDef, p: W.Wad & List<&2, List<&2, U32>>, k: W.Wad -> IO(W.Wad & List<&2, G.Tex>)) -> IO(W.Wad & List<&2, G.Tex>):
  (w, bss) = p
  IO.bind(W.Wad & List<&2, G.Tex>, W.Wad & List<&2, G.Tex>, k(w), r => built.cons(G.tex(d, bss), r))

def built.def(+d: G.TexDef, w: W.Wad, k: W.Wad -> IO(W.Wad & List<&2, G.Tex>), +pn: T.Vec<String>) -> IO(W.Wad & List<&2, G.Tex>):
  IO.bind(W.Wad & List<&2, List<&2, U32>>, W.Wad & List<&2, G.Tex>, W.get(w, lumpnames(pn, refs(d))), p => built.one(d, p, k))

def built(names: List<&2, String>, w: W.Wad, +defs: List<&2, G.TexDef>, +pn: T.Vec<String>) -> IO(W.Wad & List<&2, G.Tex>):
  match names:
    case n <> t:
      built.def(tdef(defs, n, G.TexDef{"", 0, 0, []}), w, k => built(t, k, defs, pn), pn)
    case []:
      IO.pure(W.Wad & List<&2, G.Tex>, (w, []))

def textures.fin(names: List<&2, String>, r: W.Wad & List<&2, G.Tex>) -> IO(W.Wad & Texs):
  (w, ts) = r
  IO.pure(W.Wad & Texs, (w, Texs{names, T.from_list(G.Tex, ts)}))

def textures.with(+sides: T.Vec<L.Side>, w: W.Wad, +pn: T.Vec<String>, +defs: List<&2, G.TexDef>) -> IO(W.Wad & Texs):
  +names = List.reverse(&2, String, needed(U32.to_nat(T.size(L.Side, sides)), sides, 0, first(defs), []))
  IO.bind(W.Wad & List<&2, G.Tex>, W.Wad & Texs, built(names, w, defs, pn), r => textures.fin(names, r))

def textures.parts(+sides: T.Vec<L.Side>, w: W.Wad, bss: List<&2, List<&2, U32>>) -> IO(W.Wad & Texs):
  match bss:
    case pn <> t1 <> t2 <> t:
      textures.with(sides, w, T.from_list(String, G.pnames(List.drop(&2, U32, B.words(pn), 2n))), List.append(&2, G.TexDef, G.texdefs(t1), G.texdefs(t2)))
    case _:
      IO.die(W.Wad & Texs, 1, "no PNAMES or TEXTURE1")

def textures.got(+sides: T.Vec<L.Side>, p: W.Wad & List<&2, List<&2, U32>>) -> IO(W.Wad & Texs):
  (w, bss) = p
  textures.parts(sides, w, bss)

def textures(w: W.Wad, +sides: T.Vec<L.Side>) -> IO(W.Wad & Texs):
  IO.bind(W.Wad & List<&2, List<&2, U32>>, W.Wad & Texs, W.get(w, ["PNAMES", "TEXTURE1", "TEXTURE2"]), p => textures.got(sides, p))
