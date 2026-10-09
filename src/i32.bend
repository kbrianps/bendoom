import Base

def from_s16(+w: U32) -> U32:
  Bool.pick(U32, U32.is_ge(w, 32768), (w .|. 4294901760 : U32), w)

def flip(x: U32) -> U32:
  (x .^. 2147483648 : U32)

def lt(a: U32, b: U32) -> Bool:
  U32.is_lt(flip(a), flip(b))

def min(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, lt(a, b), a, b)

def max(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, lt(a, b), b, a)
