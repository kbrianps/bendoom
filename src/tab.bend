import Base

type Tab<-A: Data> is Data:
  TNone{}
  TLeaf{value: A}
  TNode{lo: Tab<A>, hi: Tab<A>}

type Vec<-A: Data> is Data:
  Vec{size: U32, tab: Tab<A>}

def evens.go(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case a <> b <> t:
      evens.go(A, t, a <> acc)
    case a <> []:
      List.reverse(&2, A, a <> acc)
    case []:
      List.reverse(&2, A, acc)

def evens(-A: Data, xs: List<&2, A>) -> List<&2, A>:
  evens.go(A, xs, [])

def odds.go(-A: Data, xs: List<&2, A>, acc: List<&2, A>) -> List<&2, A>:
  match xs:
    case a <> b <> t:
      odds.go(A, t, b <> acc)
    case _:
      List.reverse(&2, A, acc)

def odds(-A: Data, xs: List<&2, A>) -> List<&2, A>:
  odds.go(A, xs, [])

def leaf(-A: Data, xs: List<&2, A>) -> Tab<A>:
  match xs:
    case a <> t:
      TLeaf{a}
    case []:
      TNone{}

def build(-A: Data, +d: Nat, +xs: List<&2, A>) -> Tab<A>:
  match d:
    case 0n:
      leaf(A, xs)
    case 1n+p:
      TNode{build(A, p, evens(A, xs)), build(A, p, odds(A, xs))}

def odd(+i: U32) -> Bool:
  U32.is_eq((i .&. 1 : U32), 1)

def get.go(-A: Data, +t: Tab<A>, b: Bool, +i: U32, +z: A) -> A:
  match t b:
    case TLeaf{v} _:
      v
    case TNone{} _:
      z
    case TNode{l, h} False{}:
      get.go(A, l, odd((i >> 1n : U32)), (i >> 1n : U32), z)
    case TNode{l, h} True{}:
      get.go(A, h, odd((i >> 1n : U32)), (i >> 1n : U32), z)

def get(-A: Data, +v: Vec<A>, +i: U32, +z: A) -> A:
  match v:
    case Vec{n, t}:
      get.go(A, t, odd(i), i, z)

def size(-A: Data, +v: Vec<A>) -> U32:
  match v:
    case Vec{n, t}:
      n

def depth(+n: U32) -> Nat:
  Bool.pick(Nat, U32.is_le(n, 1), 0n, 1n+U32.log2((n - 1 : U32)))

def count(-A: Data, xs: List<&2, A>, +n: U32) -> U32:
  match xs:
    case h <> t:
      count(A, t, (n + 1 : U32))
    case []:
      n

def onto(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  match xs:
    case x <> t:
      onto(A, t, x <> ys)
    case []:
      ys

def cat(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  onto(A, List.reverse(&2, A, xs), ys)

def flat.go(-A: Data, xss: List<&2, List<&2, A>>, acc: List<&2, A>) -> List<&2, A>:
  match xss:
    case xs <> t:
      flat.go(A, t, onto(A, xs, acc))
    case []:
      List.reverse(&2, A, acc)

def flat(-A: Data, xss: List<&2, List<&2, A>>) -> List<&2, A>:
  flat.go(A, xss, [])

def len(-A: Data, xs: List<&2, A>) -> U32:
  count(A, xs, 0)

def from_list(-A: Data, +xs: List<&2, A>) -> Vec<A>:
  +n = count(A, xs, 0)
  Vec{n, build(A, depth(n), xs)}

def set.go(-A: Data, t: Tab<A>, b: Bool, +i: U32, v: A) -> Tab<A>:
  match t b:
    case TNode{l, h} False{}:
      TNode{set.go(A, l, odd((i >> 1n : U32)), (i >> 1n : U32), v), h}
    case TNode{l, h} True{}:
      TNode{l, set.go(A, h, odd((i >> 1n : U32)), (i >> 1n : U32), v)}
    case _ _:
      TLeaf{v}

def set(-A: Data, v: Vec<A>, +i: U32, x: A) -> Vec<A>:
  match v:
    case Vec{n, t}:
      Vec{n, set.go(A, t, odd(i), i, x)}

def zeros(-A: Data, d: Nat, +z: A) -> Tab<A>:
  match d:
    case 0n:
      TLeaf{z}
    case 1n+p:
      +t = zeros(A, p, z)
      TNode{t, t}

def new(-A: Data, +n: U32, +z: A) -> Vec<A>:
  Vec{n, zeros(A, depth(n), z)}
