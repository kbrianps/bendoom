import Base
import ./tab.bend as T
import ./bmp.bend as P

def spread(+v: U32) -> U32:
  +a = ((v .|. (v << 8n)) .&. 16711935 : U32)
  +b = ((a .|. (a << 4n)) .&. 252645135 : U32)
  +c = ((b .|. (b << 2n)) .&. 858993459 : U32)
  ((c .|. (c << 1n)) .&. 1431655765 : U32)

def at(+x: U32, +y: U32) -> U32:
  (spread(x) .|. (spread(y) << 1n) : U32)

def put(a: Array<U32>, +x: U32, +y: U32, v: U32) -> Array<U32>:
  Array.set(U32, a, at(x, y), v)

def blank() -> Array<U32>:
  [0 : U32^18n]

def image(a: Array<U32>) -> Image:
  match a:
    case ANode{ANode{p, q}, ANode{r, s}}:
      Qua{image(p), image(q), image(r), image(s)}
    case ALeaf{v}:
      Pix{v}
    case _:
      Pix{0}

def row(n: Nat, +v: T.Vec<U32>, +x: U32, +y: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      acc
    case 1n+p:
      row(p, v, (x - 1 : U32), y, T.get(U32, v, at(x, y), 0) <> acc)

def rows(n: Nat, +v: T.Vec<U32>, +y: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      acc
    case 1n+p:
      rows(p, v, (y + 1 : U32), row(320n, v, 319, y, acc))

def bmp(a: Array<U32>) -> List<&2, U32>:
  P.encode(320, 200, rows(200n, T.from_list(U32, P.own(Array.to_list(~U32, a))), 0, []))

def sum.go(xs: List<U32>, +acc: U32) -> U32:
  match xs:
    case +x <> t:
      sum.go(t, (acc + x : U32))
    case []:
      acc

def sum(a: Array<U32>) -> U32:
  sum.go(Array.to_list(~U32, a), 0)
