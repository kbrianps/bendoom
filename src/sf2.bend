import Base
import ./tab.bend as T
import ./mem.bend as M
import ./wad.bend as W

type Pr is Data:
  Pr{bank: U32, num: U32, rs: List<&2, T.Vec<U32>>}

type Zs is Data:
  Zs{r: T.Vec<U32>, had: Bool, acc: List<&2, T.Vec<U32>>}

type Bank is Data:
  Bank{ps: T.Vec<Pr>, ks: List<&2, U32>}

type Font is Type:
  Font{smp: Array<F32>, bk: Bank, n: U32}

def by(+bs: T.Vec<U32>, +i: U32) -> U32:
  T.get(U32, bs, i, 0)

def u16(+bs: T.Vec<U32>, +i: U32) -> U32:
  (by(bs, i) + by(bs, (i + 1 : U32)) * 256 : U32)

def u32(+bs: T.Vec<U32>, +i: U32) -> U32:
  (u16(bs, i) + u16(bs, (i + 2 : U32)) * 65536 : U32)

def sx16(+v: U32) -> U32:
  Bool.pick(U32, U32.is_ge(v, 32768), (v - 65536 : U32), v)

def sx8(+v: U32) -> U32:
  Bool.pick(U32, U32.is_ge(v, 128), (v - 256 : U32), v)

def neg(+x: U32) -> Bool:
  U32.is_ge(x, 2147483648)

def slt(+a: U32, +b: U32) -> Bool:
  U32.is_lt((a .^. 2147483648 : U32), (b .^. 2147483648 : U32))

def fb(+u: U32) -> F32:
  match u:
    case U32{+d}:
      F32{d}

def sf(+x: U32) -> F32:
  Bool.pick(F32, neg(x), (0.0 - U32.to_f32((0 - x : U32)) : F32), U32.to_f32(x))

def fs(+x: F32) -> U32:
  Bool.pick(U32, F32.is_lt(x, 0.0), (0 - F32.to_u32((0.0 - x : F32)) : U32), F32.to_u32(x))

def tc2s(+tc: F32) -> F32:
  F32.pow(2.0, (tc / 1200.0 : F32))

def db2g(+db: F32) -> F32:
  Bool.pick(F32, F32.is_gt(db, (0.0 - 100.0 : F32)), F32.pow(10.0, (db * 0.05 : F32)), 0.0)

def metas() -> List<&2, U32>:
  [115, 131, 147, 163, 116, 4754, 4802, 4658, 8738, 12818, 4690, 4674, 132, 16994, 0, 0, 0, 16641, 0, 0, 0, 4721, 21122, 4769, 21170, 4497, 8609, 4529, 8641, 25041, 8673, 12785, 12801, 4369, 8481, 4401, 8513, 29009, 8545, 12657, 12673, 0, 0, 5, 6, 148, 0, 0, 20721, 0, 164, 178, 194, 0, 7, 0, 226, 104, 217]

def meta(+h: T.Vec<U32>, +op: U32) -> U32:
  Bool.pick(U32, U32.is_lt(op, 59), T.get(U32, h, (op + 16 : U32), 0), 0)

def tcneg() -> U32:
  F32.bits((0.0 - 12000.0 : F32))

def clear(+rel: Bool) -> T.Vec<U32>:
  +t = tcneg()
  +a : List<&2, U32> = [0, 0, 0, 127, 0, 127, 0, 0, 0, 0, 0, 0, 0, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  +b : List<&2, U32> = [0, 0, 0, 127, 0, 127, 0, 0, 0, 0, 0, 0, 0, 4294967295, 100, 0, 0, t, t, t, t, 0, t, 0, 0, t, t, t, t, 0, t, 0, 0, 0, 13500, 0, 0, 0, 0, t, 0, 0, t, 0, 0]
  T.from_list(U32, Bool.pick(List<&2, U32>, rel, a, b))

def get(+r: T.Vec<U32>, +i: U32) -> U32:
  T.get(U32, r, i, 0)

def put(+r: T.Vec<U32>, +i: U32, +v: U32) -> T.Vec<U32>:
  T.set(U32, r, i, v)

def gf(+r: T.Vec<U32>, +i: U32) -> F32:
  fb(get(r, i))

def pf(+r: T.Vec<U32>, +i: U32, +v: F32) -> T.Vec<U32>:
  put(r, i, F32.bits(v))

def loopmode(+w: U32) -> U32:
  +m = (w .&. 3 : U32)
  Bool.pick(U32, U32.is_eq(m, 3), 2, Bool.pick(U32, U32.is_eq(m, 1), 1, 0))

def oper(+h: T.Vec<U32>, +r: T.Vec<U32>, +op: U32, +amt: U32) -> T.Vec<U32>:
  +m = meta(h, op)
  +ty = (m .&. 15 : U32)
  +sl = ((m >> 4n) .&. 255 : U32)
  +sh = sx16(amt)
  +lo = (amt .&. 255 : U32)
  +hi = (amt >> 8n : U32)
  Bool.pick(T.Vec<U32>, U32.is_eq(ty, 1), pf(r, sl, sf(sh)),
    Bool.pick(T.Vec<U32>, U32.is_eq(ty, 2), put(r, sl, sh),
      Bool.pick(T.Vec<U32>, U32.is_eq(ty, 3), put(r, sl, (get(r, sl) + sh : U32)),
        Bool.pick(T.Vec<U32>, U32.is_eq(ty, 4), put(r, sl, (get(r, sl) + (sh << 15n) : U32)),
          Bool.pick(T.Vec<U32>, U32.is_eq(ty, 5), put(put(r, 2, lo), 3, hi),
            Bool.pick(T.Vec<U32>, U32.is_eq(ty, 6), put(put(r, 4, lo), 5, hi),
              Bool.pick(T.Vec<U32>, U32.is_eq(ty, 7), put(r, 0, loopmode(amt)),
                Bool.pick(T.Vec<U32>, U32.is_eq(ty, 8), put(r, 6, amt),
                  Bool.pick(T.Vec<U32>, U32.is_eq(ty, 9), put(r, 13, sh), r)))))))))

def flim.f(+lim: U32) -> F32:
  Bool.pick(F32, U32.is_eq(lim, 4), 0.001, Bool.pick(F32, U32.is_eq(lim, 5), 0.01, 1.0))

def flim.lo(+lim: U32) -> F32:
  Bool.pick(F32, U32.is_eq(lim, 3), (0.0 - 1200.0 : F32), Bool.pick(F32, U32.is_eq(lim, 4), (0.0 - 0.5 : F32), Bool.pick(F32, U32.is_ge(lim, 5), 0.0, (0.0 - 12000.0 : F32))))

def flim.hi(+lim: U32) -> F32:
  Bool.pick(F32, U32.is_eq(lim, 1), 5000.0, Bool.pick(F32, U32.is_eq(lim, 2), 8000.0, Bool.pick(F32, U32.is_eq(lim, 3), 1200.0,
    Bool.pick(F32, U32.is_eq(lim, 4), 0.5, Bool.pick(F32, U32.is_eq(lim, 5), 14.4, Bool.pick(F32, U32.is_eq(lim, 6), 1000.0, 1440.0))))))

def fclamp(+v: F32, +lo: F32, +hi: F32) -> F32:
  Bool.pick(F32, F32.is_lt(v, lo), lo, Bool.pick(F32, F32.is_gt(v, hi), hi, v))

def ilim.lo(+lim: U32) -> U32:
  Bool.pick(U32, U32.is_eq(lim, 1), 4294955296, Bool.pick(U32, U32.is_eq(lim, 2), 1500, Bool.pick(U32, U32.is_eq(lim, 3), 0, Bool.pick(U32, U32.is_eq(lim, 4), 4294966336, 4294951296))))

def ilim.hi(+lim: U32) -> U32:
  Bool.pick(U32, U32.is_eq(lim, 1), 12000, Bool.pick(U32, U32.is_eq(lim, 2), 13500, Bool.pick(U32, U32.is_eq(lim, 5), 4500, 960)))

def iclamp(+v: U32, +lo: U32, +hi: U32) -> U32:
  Bool.pick(U32, slt(v, lo), lo, Bool.pick(U32, slt(hi, v), hi, v))

def merge1(+r: T.Vec<U32>, +m: T.Vec<U32>, +x: U32) -> T.Vec<U32>:
  +ty = (x .&. 15 : U32)
  +sl = ((x >> 4n) .&. 255 : U32)
  +lim = (x >> 12n : U32)
  +fv = (gf(r, sl) + gf(m, sl) : F32)
  +iv = (get(r, sl) + get(m, sl) : U32)
  +fl = Bool.pick(F32, U32.is_eq(lim, 0), fv, fclamp((fv * flim.f(lim) : F32), flim.lo(lim), flim.hi(lim)))
  +il = Bool.pick(U32, U32.is_eq(lim, 0), iv, iclamp(iv, ilim.lo(lim), ilim.hi(lim)))
  Bool.pick(T.Vec<U32>, U32.is_eq(ty, 1), pf(r, sl, fl), Bool.pick(T.Vec<U32>, U32.is_eq(ty, 2), put(r, sl, il), Bool.pick(T.Vec<U32>, U32.is_eq(ty, 3), put(r, sl, iv), r)))

def merge.go(xs: List<&2, U32>, +r: T.Vec<U32>, +m: T.Vec<U32>) -> T.Vec<U32>:
  match xs:
    case +x <> t:
      merge.go(t, merge1(r, m, x), m)
    case []:
      r

def merge(+r: T.Vec<U32>, +m: T.Vec<U32>) -> T.Vec<U32>:
  merge.go(metas(), r, m)

def secs(+tc: F32) -> F32:
  Bool.pick(F32, F32.is_lt(tc, (0.0 - 11950.0 : F32)), 0.0, tc2s(tc))

def envsecs(+r: T.Vec<U32>, +b: U32, +gain: Bool) -> T.Vec<U32>:
  +s = gf(r, (b + 4 : U32))
  +sus = Bool.pick(F32, F32.is_lt(s, 0.0), 0.0, Bool.pick(F32, gain, db2g(((0.0 - s : F32) / 10.0 : F32)), (1.0 - (s / 1000.0 : F32) : F32)))
  +hold = Bool.pick(F32, F32.is_eq(gf(r, (b + 6 : U32)), 0.0), secs(gf(r, (b + 2 : U32))), gf(r, (b + 2 : U32)))
  +decay = Bool.pick(F32, F32.is_eq(gf(r, (b + 7 : U32)), 0.0), secs(gf(r, (b + 3 : U32))), gf(r, (b + 3 : U32)))
  pf(pf(pf(pf(pf(pf(r, b, secs(gf(r, b))), (b + 1 : U32), secs(gf(r, (b + 1 : U32)))), (b + 5 : U32), secs(gf(r, (b + 5 : U32)))), (b + 2 : U32), hold), (b + 3 : U32), decay), (b + 4 : U32), sus)

def hv(+h: T.Vec<U32>, +k: U32) -> U32:
  T.get(U32, h, k, 0)

def ranged(+z: T.Vec<U32>, +p: T.Vec<U32>) -> T.Vec<U32>:
  +a = put(z, 2, Bool.pick(U32, U32.is_gt(get(p, 2), get(z, 2)), get(p, 2), get(z, 2)))
  +b = put(a, 3, Bool.pick(U32, U32.is_lt(get(p, 3), get(z, 3)), get(p, 3), get(z, 3)))
  +c = put(b, 4, Bool.pick(U32, U32.is_gt(get(p, 4), get(z, 4)), get(p, 4), get(z, 4)))
  put(c, 5, Bool.pick(U32, U32.is_lt(get(p, 5), get(z, 5)), get(p, 5), get(z, 5)))

def outside(+z: T.Vec<U32>, +p: T.Vec<U32>) -> Bool:
  Bool.or(Bool.or(U32.is_lt(get(z, 3), get(p, 2)), U32.is_gt(get(z, 2), get(p, 3))), Bool.or(U32.is_lt(get(z, 5), get(p, 4)), U32.is_gt(get(z, 4), get(p, 5))))

def fixup(+bs: T.Vec<U32>, +h: T.Vec<U32>, +z: T.Vec<U32>, +s: U32) -> T.Vec<U32>:
  +at = (hv(h, 6) + s * 46 : U32)
  +n = hv(h, 9)
  +el = u32(bs, (at + 32 : U32))
  +le0 = (get(z, 10) + el - Bool.pick(U32, U32.is_gt(el, 0), 1, 0) : U32)
  +le = Bool.pick(U32, U32.is_gt(le0, n), n, le0)
  +kc = Bool.pick(U32, U32.is_eq(get(z, 13), 4294967295), by(bs, (at + 40 : U32)), get(z, 13))
  +en = (get(z, 8) + u32(bs, (at + 24 : U32)) : U32)
  +en2 = Bool.pick(U32, Bool.and(U32.is_ne(en, 0), U32.is_lt(en, n)), (en + 1 : U32), n)
  +a = put(put(put(z, 7, (get(z, 7) + u32(bs, (at + 20 : U32)) : U32)), 9, (get(z, 9) + u32(bs, (at + 28 : U32)) : U32)), 10, le)
  put(put(put(put(a, 13, kc), 12, (get(z, 12) + sx8(by(bs, (at + 41 : U32))) : U32)), 1, u32(bs, (at + 36 : U32))), 8, en2)

def finish(+bs: T.Vec<U32>, +h: T.Vec<U32>, +z: T.Vec<U32>, +p: T.Vec<U32>, +s: U32) -> T.Vec<U32>:
  +m = envsecs(envsecs(merge(ranged(z, p), p), 17, True{}), 25, False{})
  +l = pf(pf(m, 39, secs(gf(m, 39))), 42, secs(gf(m, 42)))
  fixup(bs, h, l, s)

def gop(+bs: T.Vec<U32>, +base: U32, +g: U32) -> U32:
  u16(bs, (base + g * 4 : U32))

def gamt(+bs: T.Vec<U32>, +base: U32, +g: U32) -> U32:
  u16(bs, (base + g * 4 + 2 : U32))

def igens?(+bs: T.Vec<U32>, +h: T.Vec<U32>, +g: U32, +ge: U32, +z: T.Vec<U32>, +had: Bool, +p: T.Vec<U32>, +acc: List<&2, T.Vec<U32>>) -> Zs:
  igens.go(U32.is_ge(g, ge), bs, h, g, ge, z, had, p, acc)

def igens.go?(stop: Bool, +bs: T.Vec<U32>, +h: T.Vec<U32>, +g: U32, +ge: U32, +z: T.Vec<U32>, +had: Bool, +p: T.Vec<U32>, +acc: List<&2, T.Vec<U32>>) -> Zs:
  match stop:
    case True{}:
      Zs{z, had, acc}
    case False{}:
      +op = gop(bs, hv(h, 5), g)
      +amt = gamt(bs, hv(h, 5), g)
      igens.op(U32.is_eq(op, 53), outside(z, p), bs, h, g, ge, z, had, p, acc, op, amt)

def igens.op?(smp: Bool, out: Bool, +bs: T.Vec<U32>, +h: T.Vec<U32>, +g: U32, +ge: U32, +z: T.Vec<U32>, +had: Bool, +p: T.Vec<U32>, +acc: List<&2, T.Vec<U32>>, +op: U32, +amt: U32) -> Zs:
  match smp out:
    case True{} True{}:
      igens(bs, h, (g + 1 : U32), ge, z, had, p, acc)
    case True{} False{}:
      +z2 = finish(bs, h, z, p, amt)
      igens(bs, h, (g + 1 : U32), ge, z2, True{}, p, z2 <> acc)
    case False{} _:
      igens(bs, h, (g + 1 : U32), ge, oper(h, z, op, amt), had, p, acc)

def ibag(+bs: T.Vec<U32>, +h: T.Vec<U32>, +b: U32) -> U32:
  u16(bs, (hv(h, 4) + b * 4 : U32))

def zs.r(+x: Zs) -> T.Vec<U32>:
  match x:
    case Zs{+r, had, acc}:
      r

def zs.had(+x: Zs) -> Bool:
  match x:
    case Zs{r, +had, acc}:
      had

def zs.acc(+x: Zs) -> List<&2, T.Vec<U32>>:
  match x:
    case Zs{r, had, +acc}:
      acc

def izones?(+bs: T.Vec<U32>, +h: T.Vec<U32>, +b: U32, +be: U32, +first: U32, +inst: T.Vec<U32>, +p: T.Vec<U32>, +acc: List<&2, T.Vec<U32>>) -> List<&2, T.Vec<U32>>:
  izones.go(U32.is_ge(b, be), bs, h, b, be, first, inst, p, acc)

def izones.go?(stop: Bool, +bs: T.Vec<U32>, +h: T.Vec<U32>, +b: U32, +be: U32, +first: U32, +inst: T.Vec<U32>, +p: T.Vec<U32>, +acc: List<&2, T.Vec<U32>>) -> List<&2, T.Vec<U32>>:
  match stop:
    case True{}:
      acc
    case False{}:
      +x = igens(bs, h, ibag(bs, h, b), ibag(bs, h, (b + 1 : U32)), inst, False{}, p, acc)
      +keep = Bool.and(U32.is_eq(b, first), Bool.not(zs.had(x)))
      izones(bs, h, (b + 1 : U32), be, first, Bool.pick(T.Vec<U32>, keep, zs.r(x), inst), p, zs.acc(x))

def instbag(+bs: T.Vec<U32>, +h: T.Vec<U32>, +w: U32) -> U32:
  u16(bs, (hv(h, 3) + w * 22 + 20 : U32))

def pgens?(+bs: T.Vec<U32>, +h: T.Vec<U32>, +g: U32, +ge: U32, +p: T.Vec<U32>, +had: Bool, +acc: List<&2, T.Vec<U32>>) -> Zs:
  pgens.go(U32.is_ge(g, ge), bs, h, g, ge, p, had, acc)

def pgens.go?(stop: Bool, +bs: T.Vec<U32>, +h: T.Vec<U32>, +g: U32, +ge: U32, +p: T.Vec<U32>, +had: Bool, +acc: List<&2, T.Vec<U32>>) -> Zs:
  match stop:
    case True{}:
      Zs{p, had, acc}
    case False{}:
      +op = gop(bs, hv(h, 2), g)
      +amt = gamt(bs, hv(h, 2), g)
      pgens.op(U32.is_eq(op, 41), U32.is_ge(amt, hv(h, 8)), bs, h, g, ge, p, had, acc, op, amt)

def pgens.op?(ins: Bool, bad: Bool, +bs: T.Vec<U32>, +h: T.Vec<U32>, +g: U32, +ge: U32, +p: T.Vec<U32>, +had: Bool, +acc: List<&2, T.Vec<U32>>, +op: U32, +amt: U32) -> Zs:
  match ins bad:
    case True{} True{}:
      pgens(bs, h, (g + 1 : U32), ge, p, had, acc)
    case True{} False{}:
      +b0 = instbag(bs, h, amt)
      pgens(bs, h, (g + 1 : U32), ge, p, True{}, izones(bs, h, b0, instbag(bs, h, (amt + 1 : U32)), b0, clear(False{}), p, acc))
    case False{} _:
      pgens(bs, h, (g + 1 : U32), ge, oper(h, p, op, amt), had, acc)

def pbag(+bs: T.Vec<U32>, +h: T.Vec<U32>, +b: U32) -> U32:
  u16(bs, (hv(h, 1) + b * 4 : U32))

def pzones?(+bs: T.Vec<U32>, +h: T.Vec<U32>, +b: U32, +be: U32, +first: U32, +glob: T.Vec<U32>, +acc: List<&2, T.Vec<U32>>) -> List<&2, T.Vec<U32>>:
  pzones.go(U32.is_ge(b, be), bs, h, b, be, first, glob, acc)

def pzones.go?(stop: Bool, +bs: T.Vec<U32>, +h: T.Vec<U32>, +b: U32, +be: U32, +first: U32, +glob: T.Vec<U32>, +acc: List<&2, T.Vec<U32>>) -> List<&2, T.Vec<U32>>:
  match stop:
    case True{}:
      acc
    case False{}:
      +x = pgens(bs, h, pbag(bs, h, b), pbag(bs, h, (b + 1 : U32)), glob, False{}, acc)
      +keep = Bool.and(U32.is_eq(b, first), Bool.not(zs.had(x)))
      pzones(bs, h, (b + 1 : U32), be, first, Bool.pick(T.Vec<U32>, keep, zs.r(x), glob), zs.acc(x))

def rev(xs: List<&2, T.Vec<U32>>, acc: List<&2, T.Vec<U32>>) -> List<&2, T.Vec<U32>>:
  match xs:
    case x <> t:
      rev(t, x <> acc)
    case []:
      acc

def phbag(+bs: T.Vec<U32>, +h: T.Vec<U32>, +i: U32) -> U32:
  u16(bs, (hv(h, 0) + i * 38 + 24 : U32))

def preset(+bs: T.Vec<U32>, +h: T.Vec<U32>, +i: U32) -> Pr:
  +at = (hv(h, 0) + i * 38 : U32)
  +b0 = phbag(bs, h, i)
  Pr{u16(bs, (at + 22 : U32)), u16(bs, (at + 20 : U32)), rev(pzones(bs, h, b0, phbag(bs, h, (i + 1 : U32)), b0, clear(True{}), []), [])}

def pr.key(+p: Pr) -> U32:
  match p:
    case Pr{+bank, +num, rs}:
      ((bank << 16n) + num : U32)

def insert(+p: Pr, xs: List<&2, Pr>) -> List<&2, Pr>:
  match xs:
    case +x <> +t:
      Bool.pick(List<&2, Pr>, U32.is_lt(pr.key(p), pr.key(x)), p <> x <> t, x <> insert(p, t))
    case []:
      [p]

def presets(+bs: T.Vec<U32>, +h: T.Vec<U32>, n: Nat, +i: U32, acc: List<&2, Pr>) -> List<&2, Pr>:
  match n:
    case 0n:
      acc
    case 1n+k:
      presets(bs, h, k, (i + 1 : U32), insert(preset(bs, h, i), acc))

def lput(+xs: List<&2, U32>, +i: U32, +v: U32) -> List<&2, U32>:
  match xs:
    case +x <> +t:
      Bool.pick(List<&2, U32>, U32.is_eq(i, 0), v <> t, x <> lput(t, (i - 1 : U32), v))
    case []:
      []

def set.hdr(+h: List<&2, U32>, +k: U32, +at: U32, +sz: U32) -> List<&2, U32>:
  +h1 = lput(h, k, at)
  Bool.pick(List<&2, U32>, U32.is_eq(k, 0), lput(h1, 7, (sz / 38 : U32)), Bool.pick(List<&2, U32>, U32.is_eq(k, 3), lput(h1, 8, (sz / 22 : U32)), h1))

def set.ids(ids: List<&2, U32>, +h: List<&2, U32>, +k: U32, +id: U32, +at: U32, +sz: U32) -> List<&2, U32>:
  match ids:
    case +x <> t:
      Bool.pick(List<&2, U32>, U32.is_eq(x, id), set.hdr(h, k, at, sz), set.ids(t, h, (k + 1 : U32), id, at, sz))
    case []:
      h

def chunks?(+bs: T.Vec<U32>, +q: U32, +n: U32, +h: List<&2, U32>) -> List<&2, U32>:
  chunks.go(U32.is_gt((q + 8 : U32), n), bs, q, n, h)

def chunks.go?(stop: Bool, +bs: T.Vec<U32>, +q: U32, +n: U32, +h: List<&2, U32>) -> List<&2, U32>:
  match stop:
    case True{}:
      h
    case False{}:
      +id = u32(bs, q)
      +sz = u32(bs, (q + 4 : U32))
      +at = (q + 8 : U32)
      +ids : List<&2, U32> = [1919182960, 1734435440, 1852139376, 1953721961, 1734435433, 1852139369, 1919182963]
      chunks(bs, (at + sz + (sz .&. 1) : U32), n, set.ids(ids, h, 0, id, at, sz))

def keys.go(ps: List<&2, Pr>, acc: List<&2, U32>) -> List<&2, U32>:
  match ps:
    case +p <> t:
      keys.go(t, pr.key(p) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def keys(ps: List<&2, Pr>) -> List<&2, U32>:
  keys.go(ps, [])

def bank(+ps: List<&2, Pr>) -> Bank:
  Bank{T.from_list(Pr, ps), keys(ps)}

def font(+bs: T.Vec<U32>, +nsmp: U32) -> Bank:
  +h = T.from_list(U32, List.append(&2, U32, lput(chunks(bs, 0, T.size(U32, bs), [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), 9, nsmp), metas()))
  +n = hv(h, 7)
  bank(presets(bs, h, U32.to_nat(Bool.pick(U32, U32.is_eq(n, 0), 0, (n - 1 : U32))), 0, []))

def sample(+lo: U32, +hi: U32) -> F32:
  (sf(sx16((lo + hi * 256 : U32))) / 32767.0 : F32)

def fill(xs: List<&2, U32>, a: Array<F32>, +i: U32) -> Array<F32>:
  match xs:
    case +lo <> +hi <> t:
      fill(t, Array.set(F32, a, i, sample(lo, hi)), (i + 1 : U32))
    case _:
      a

def load.fill.got?(+p: U32, +left: U32, a: Array<F32>, +i: U32, q: File & List<&2, U32>) -> IO(File & Array<F32>):
  (f, bs) = q
  +k = U32.min(left, 65536)
  load.fill(f, (p + k : U32), (left - k : U32), fill(bs, a, i), (i + (k >> 1n) : U32))

def load.fill?(f: File, +p: U32, +left: U32, a: Array<F32>, +i: U32) -> IO(File & Array<F32>):
  load.fill.go(U32.is_eq(left, 0), f, p, left, a, i)

def load.fill.go?(done: Bool, f: File, +p: U32, +left: U32, a: Array<F32>, +i: U32) -> IO(File & Array<F32>):
  match done:
    case True{}:
      IO.pure(File & Array<F32>, (f, a))
    case False{}:
      IO.bind(File & List<&2, U32>, File & Array<F32>, W.read(f, p, U32.min(left, 65536)), q => load.fill.got(p, left, a, i, q))

def walk.list?(+p: U32, +sz: U32, +nx: U32, +end: U32, q: File & List<&2, U32>) -> IO(File & List<&2, U32>):
  (f, ck) = q
  walk(f, nx, end, ck)

def walk.got?(+p: U32, +end: U32, +ck: List<&2, U32>, q: File & List<&2, U32>) -> IO(File & List<&2, U32>):
  (f, xs) = q
  +bs = T.from_list(U32, xs)
  +id = u32(bs, 0)
  +sz = u32(bs, 4)
  +ty = u32(bs, 8)
  +nx = (p + 8 + sz + (sz .&. 1) : U32)
  walk.kind(U32.is_eq(id, 1414744396), U32.is_eq(ty, 1635017840), U32.is_eq(id, 1819307379), f, p, sz, nx, end, ck)

def walk.kind?(list: Bool, pdta: Bool, smpl: Bool, f: File, +p: U32, +sz: U32, +nx: U32, +end: U32, +ck: List<&2, U32>) -> IO(File & List<&2, U32>):
  match list pdta smpl:
    case True{} True{} _:
      walk(f, nx, end, lput(lput(ck, 2, (p + 12 : U32)), 3, (sz - 4 : U32)))
    case True{} False{} _:
      IO.bind(File & List<&2, U32>, File & List<&2, U32>, walk(f, (p + 12 : U32), (p + 8 + sz : U32), ck), q => walk.list(p, sz, nx, end, q))
    case False{} _ True{}:
      walk(f, nx, end, lput(lput(ck, 0, (p + 8 : U32)), 1, sz))
    case False{} _ False{}:
      walk(f, nx, end, ck)

def walk?(f: File, +p: U32, +end: U32, +ck: List<&2, U32>) -> IO(File & List<&2, U32>):
  walk.go(U32.is_gt((p + 8 : U32), end), f, p, end, ck)

def walk.go?(done: Bool, f: File, +p: U32, +end: U32, +ck: List<&2, U32>) -> IO(File & List<&2, U32>):
  match done:
    case True{}:
      IO.pure(File & List<&2, U32>, (f, ck))
    case False{}:
      IO.bind(File & List<&2, U32>, File & List<&2, U32>, W.read(f, p, 12), q => walk.got(p, end, ck, q))

def lat(+xs: List<&2, U32>, +i: Nat) -> U32:
  Maybe.default(&2, U32, List.get(&2, U32, xs, i), 0)

def loaded(+ck: List<&2, U32>, +pd: List<&2, U32>, q: File & Array<F32>) -> IO(Font):
  (f, a) = q
  +n = (lat(ck, 1n) >> 1n : U32)
  do IO<Font>:
    File.close(f)
    return Font{a, font(T.from_list(U32, pd), n), n}

def load.pd(+ck: List<&2, U32>, q: File & List<&2, U32>) -> IO(Font):
  (f, pd) = q
  +n = (lat(ck, 1n) >> 1n : U32)
  IO.bind(File & Array<F32>, Font, load.fill(f, lat(ck, 0n), lat(ck, 1n), Array.new(F32, M.depth((n + 1 : U32)), 0.0), 0), r => loaded(ck, pd, r))

def load.ck(q: File & List<&2, U32>) -> IO(Font):
  (f, +ck) = q
  IO.bind(File & List<&2, U32>, Font, W.read(f, lat(ck, 2n), lat(ck, 3n)), r => load.pd(ck, r))

def load.head(q: File & List<&2, U32>) -> IO(Font):
  (f, xs) = q
  +bs = T.from_list(U32, xs)
  IO.bind(File & List<&2, U32>, Font, walk(f, 12, (u32(bs, 4) + 8 : U32), [0, 0, 0, 0]), r => load.ck(r))

def load(path: String) -> IO(Font):
  do IO<Font>:
    f : File <- IO.try(File, File.open(path, "r"))
    q : File & List<&2, U32> <- W.read(f, 0, 12)
    load.head(q)

def empty() -> Font:
  Font{Array.new(F32, 0n, 0.0), bank([]), 0}
