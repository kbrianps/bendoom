import Base

def neg(x: U32) -> U32:
  (0 - x : U32)

def is_neg(x: U32) -> Bool:
  U32.is_ge(x, 2147483648)

def abs(+x: U32) -> U32:
  Bool.pick(U32, is_neg(x), neg(x), x)

def flip(x: U32) -> U32:
  (x .^. 2147483648 : U32)

def lt(a: U32, b: U32) -> Bool:
  U32.is_lt(flip(a), flip(b))

def le(a: U32, b: U32) -> Bool:
  U32.is_le(flip(a), flip(b))

def gt(a: U32, b: U32) -> Bool:
  lt(b, a)

def ge(a: U32, b: U32) -> Bool:
  le(b, a)

def min(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, lt(a, b), a, b)

def max(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, lt(a, b), b, a)

def sar(+x: U32, +n: Nat) -> U32:
  ((x >> n) .|. Bool.pick(U32, is_neg(x), U32.not((4294967295 >> n : U32)), 0) : U32)

def quot(+a: U32, +n: U32) -> U32:
  Bool.pick(U32, is_neg(a), neg((neg(a) / n : U32)), (a / n : U32))

def mul.u(+a: U32, +b: U32) -> U32:
  +al = (a .&. 65535 : U32)
  +ah = (a >> 16n : U32)
  +bl = (b .&. 65535 : U32)
  +bh = (b >> 16n : U32)
  (((ah * bh : U32) << 16n) + al * bh + ah * bl + ((al * bl : U32) >> 16n) : U32)

def mul.fix(+n: Bool, +other: U32) -> U32:
  Bool.pick(U32, n, (other << 16n : U32), 0)

def mul(+a: U32, +b: U32) -> U32:
  (mul.u(a, b) - mul.fix(is_neg(a), b) - mul.fix(is_neg(b), a) : U32)

def ge2(+r: U32, +d: U32) -> Bool:
  U32.is_ge((r << 1n : U32), d)

def div.go(n: Nat, hit: Bool, +d: U32, +q: U32, +r: U32) -> U32:
  match n hit:
    case 0n _:
      q
    case 1n+p True{}:
      div.go(p, ge2((r - d : U32), d), d, ((q << 1n) + 1 : U32), ((r - d) << 1n : U32))
    case 1n+p False{}:
      div.go(p, ge2(r, d), d, (q << 1n : U32), (r << 1n : U32))

def div.mag(+a: U32, +d: U32) -> U32:
  div.go(16n, ge2((a % d : U32), d), d, (a / d : U32), ((a % d) << 1n : U32))

def sign(+n: Bool, +x: U32) -> U32:
  Bool.pick(U32, n, neg(x), x)

def div.ok(+a: U32, +b: U32) -> U32:
  sign(is_neg((a .^. b : U32)), div.mag(abs(a), abs(b)))

def div.over(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, is_neg((a .^. b : U32)), 2147483648, 2147483647)

def div.if(over: Bool, +a: U32, +b: U32) -> U32:
  match over:
    case True{}:
      div.over(a, b)
    case False{}:
      div.ok(a, b)

def div(+a: U32, +b: U32) -> U32:
  div.if(U32.is_ge((abs(a) >> 14n : U32), abs(b)), a, b)
