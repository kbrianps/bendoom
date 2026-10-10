import Base

type Info is Data:
  Info{mask: U32, height: U32, base: U32, posts: U32}

type Layout is Data:
  Layout{texs: List<&2, Info>, flats: List<&2, U32>, size: U32}

def cmap() -> U32:
  0

def zlight() -> U32:
  8704

def yslope() -> U32:
  10752

def distscale() -> U32:
  10952

def pal() -> U32:
  11520

def texbase() -> U32:
  12288

def sky() -> U32:
  4294967295

def rd(a: Array<U32>, +i: U32) -> Array<U32> & U32:
  Array.get(U32, a, i)

def wr(a: Array<U32>, +i: U32, v: U32) -> Array<U32>:
  Array.set(U32, a, i, v)

def fill(xs: List<&2, U32>, a: Array<U32>, +i: U32) -> Array<U32>:
  match xs:
    case x <> t:
      fill(t, Array.set(U32, a, i, x), (i + 1 : U32))
    case []:
      a

def depth(+n: U32) -> Nat:
  Bool.pick(Nat, U32.is_le(n, 1), 0n, 1n+U32.log2((n - 1 : U32)))

def ceilclip() -> U32:
  0

def floorclip() -> U32:
  320

def nplanes() -> U32:
  640

def curfloor() -> U32:
  641

def curceil() -> U32:
  642

def planehead() -> U32:
  1024

def spanstart() -> U32:
  4096

def planetop() -> U32:
  16384

def planebot() -> U32:
  99328

def maxplanes() -> U32:
  256

def ramdepth() -> Nat:
  18n

def head(+p: U32, +k: U32) -> U32:
  (planehead() + p * 8 + k : U32)

def top(+p: U32, +x: U32) -> U32:
  (planetop() + p * 322 + 1 + x : U32)

def bot(+p: U32, +x: U32) -> U32:
  (planebot() + p * 322 + 1 + x : U32)

def let(-R: Type, r: Array<U32> & U32, k: Array<U32> -> U32 -> R) -> R:
  (a, v) = r
  k(a, v)

def lastopening() -> U32:
  643

def ndrawsegs() -> U32:
  644

def nvis() -> U32:
  645

def openings() -> U32:
  182272

def drawsegs() -> U32:
  223232

def maxdrawsegs() -> U32:
  1024

def vissprites() -> U32:
  239616

def maxvis() -> U32:
  256

def clipbot() -> U32:
  243712

def cliptop() -> U32:
  244032

def negone() -> U32:
  244352

def vh() -> U32:
  168

def cy() -> U32:
  84

def screenh() -> U32:
  244672

def secseen() -> U32:
  245760

def visorder() -> U32:
  253952

def ds(+d: U32, +k: U32) -> U32:
  (drawsegs() + d * 16 + k : U32)

def vs(+s: U32, +k: U32) -> U32:
  (vissprites() + s * 16 + k : U32)

def fuzz() -> U32:
  11776

def fuzzpos() -> U32:
  11830

def none() -> U32:
  4294967295
