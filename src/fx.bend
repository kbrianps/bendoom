import Base

type Ml is Data:
  Ml{lin: U32, lout: U32, size: U32, off: U32, db: F32, b0: F32, a1: F32, ph: F32, m: U32, cp: F32, ir: U32, fr: F32, buf: F32}

type Cb is Data:
  Cb{lout: U32, ph: F32, m: U32, fr: F32, buf: F32}

type Fx is Data:
  Fx{on: U32, tone: F32, b1: F32, b2: F32, wet1: F32, wet2: F32, ls: List<&2, Ml>, clin: U32, ccp: F32, cir: U32, coff: U32, cbs: List<&2, Cb>}

type Ps is Data:
  Ps{lout: U32, fr: F32}

type Mo is Type:
  Mo{a: Array<F32>, m: Ml, d: F32}

type Lo is Type:
  Lo{a: Array<F32>, ls: List<&2, Ml>, ds: List<&2, F32>, mf: F32, l: F32, r: F32}

type Pu is Type:
  Pu{a: Array<F32>, ls: List<&2, Ml>}

type Co is Type:
  Co{a: Array<F32>, b: Cb, d: F32}

type Cs is Type:
  Cs{a: Array<F32>, bs: List<&2, Cb>, ds: List<&2, F32>}

type Rt is Type:
  Rt{a: Array<F32>, fx: Fx, l: F32, r: F32}

def rate() -> F32:
  22050.0

def size() -> U32:
  32637

def noms() -> List<&2, U32>:
  [2616, 3008, 3365, 3652, 4001, 4340, 4619, 4915]

def neg1() -> F32:
  (0.0 - 1.0 : F32)

def sinus(+ph: F32, +j: U32, +n: U32) -> F32:
  F32.sin((ph + (((2.0 * F32.pi() : F32) * U32.to_f32(j) : F32) / U32.to_f32(n) : F32) : F32))

def posit(+x: F32, +n: U32) -> Ps:
  +t = F32.to_u32(Bool.pick(F32, F32.is_ge(x, 0.0), x, 0.0))
  +w = Bool.pick(U32, U32.is_ge(t, n), (t - n : U32), t)
  +g = F32.to_u32(Bool.pick(F32, F32.is_ge(x, 0.0), 0.0, (1.0 - x : F32)))
  Bool.pick(Ps, F32.is_ge(x, 0.0), Ps{w, (x - U32.to_f32(t) : F32)}, Ps{(n - g : U32), (x + U32.to_f32(g) : F32)})

def ps.lout(+p: Ps) -> U32:
  match p:
    case Ps{+lout, fr}:
      lout

def ps.fr(+p: Ps) -> F32:
  match p:
    case Ps{lout, +fr}:
      fr

def wrap(+i: U32, +n: U32) -> U32:
  Bool.pick(U32, U32.is_ge(i, n), (i - n : U32), i)

def fwrap(+x: F32, +n: U32) -> F32:
  Bool.pick(F32, F32.is_ge(x, U32.to_f32(n)), (x - U32.to_f32(n) : F32), x)

def ml.out(+lin: U32, +lo: U32, +size: U32, +off: U32, +db: F32, +b0: F32, +a1: F32, +ph: F32, +m: U32, +cp: F32, +ir: U32, +fr: F32, +buf: F32, +v0: F32, r: Array<F32> & F32) -> Mo:
  (a, +v1) = r
  +o = (v0 + (fr * (v1 - buf : F32) : F32) : F32)
  +d = ((o * b0 : F32) - (db * a1 : F32) : F32)
  Mo{a, Ml{lin, lo, size, off, d, b0, a1, ph, m, cp, ir, fr, o}, d}

def ml.read(+lin: U32, +lo: U32, +size: U32, +off: U32, +db: F32, +b0: F32, +a1: F32, +ph: F32, +m: U32, +cp: F32, +ir: U32, +fr: F32, +buf: F32, r: Array<F32> & F32) -> Mo:
  (a, +v0) = r
  +lo2 = wrap((lo + 1 : U32), size)
  ml.out(lin, lo2, size, off, db, b0, a1, ph, m, cp, ir, fr, buf, v0, Array.get(F32, a, (off + lo2 : U32)))

def ml.step(a: Array<F32>, +ml: Ml) -> Mo:
  match ml:
    case Ml{+lin, +lout, +size, +off, +db, +b0, +a1, +ph, +m, +cp, +ir, +fr, +buf}:
      +ir1 = (ir + 1 : U32)
      +upd = U32.is_ge(ir1, 50)
      +j = (m + 1 : U32)
      +p = posit((cp + (sinus(ph, j, 441) * 4.0 : F32) : F32), size)
      +lo = Bool.pick(U32, upd, ps.lout(p), lout)
      +nfr = Bool.pick(F32, upd, ps.fr(p), fr)
      +ncp = Bool.pick(F32, upd, fwrap((cp + 50.0 : F32), size), cp)
      +nir = Bool.pick(U32, upd, 0, ir1)
      +nm = Bool.pick(U32, upd, wrap(j, 441), m)
      ml.read(lin, lo, size, off, db, b0, a1, ph, nm, ncp, nir, nfr, buf, Array.get(F32, a, (off + lo : U32)))

def lines.next?(+i: U32, t: List<&2, Ml>, +w1: F32, +ms: List<&2, Ml>, +ds: List<&2, F32>, +mf: F32, +l: F32, +r: F32, o: Mo) -> Lo:
  match o:
    case Mo{a, +m, +d}:
      +gl = Bool.pick(F32, U32.is_eq((i .&. 1 : U32), 0), w1, (0.0 - w1 : F32))
      +gr = Bool.pick(F32, U32.is_eq((i .&. 2 : U32), 0), w1, (0.0 - w1 : F32))
      lines(a, t, (i + 1 : U32), w1, m <> ms, d <> ds, (mf + d : F32), (l + (gl * d : F32) : F32), (r + (gr * d : F32) : F32))

def lines?(a: Array<F32>, ls: List<&2, Ml>, +i: U32, +w1: F32, +ms: List<&2, Ml>, +ds: List<&2, F32>, +mf: F32, +l: F32, +r: F32) -> Lo:
  match ls:
    case +m <> t:
      lines.next(i, t, w1, ms, ds, mf, l, r, ml.step(a, m))
    case []:
      Lo{a, List.reverse(&2, Ml, ms), List.reverse(&2, F32, ds), mf, l, r}

def push(a: Array<F32>, +ml: Ml, +v: F32) -> Array<F32> & Ml:
  match ml:
    case Ml{+lin, +lout, +size, +off, +db, +b0, +a1, +ph, +m, +cp, +ir, +fr, +buf}:
      (Array.set(F32, a, (off + lin : U32), v), Ml{wrap((lin + 1 : U32), size), lout, size, off, db, b0, a1, ph, m, cp, ir, fr, buf})

def pushes.next?(t: List<&2, Ml>, vs: List<&2, F32>, +mf: F32, +acc: List<&2, Ml>, r: Array<F32> & Ml) -> Pu:
  (a, +m) = r
  pushes(a, t, vs, mf, m <> acc)

def pushes?(a: Array<F32>, ls: List<&2, Ml>, vs: List<&2, F32>, +mf: F32, +acc: List<&2, Ml>) -> Pu:
  match ls vs:
    case +m <> t +v <> u:
      pushes.next(t, u, mf, acc, push(a, m, (v + mf : F32)))
    case _ _:
      Pu{a, List.reverse(&2, Ml, acc)}

def rot(xs: List<&2, F32>) -> List<&2, F32>:
  match xs:
    case +x <> t:
      List.append(&2, F32, t, [x])
    case []:
      []

def rev.done(+tone: F32, +b1: F32, +b2: F32, +w1: F32, +w2: F32, +clin: U32, +ccp: F32, +cir: U32, +coff: U32, +cbs: List<&2, Cb>, +l: F32, +r: F32, p: Pu) -> Rt:
  match p:
    case Pu{a, +ls}:
      +l1 = (l - 0.00000001 : F32)
      +r1 = (r - 0.00000001 : F32)
      Rt{a, Fx{1, tone, b1, b2, w1, w2, ls, clin, ccp, cir, coff, cbs}, (l1 + (r1 * w2 : F32) : F32), (r1 + (l1 * w2 : F32) : F32)}

def rev.fin(+xn: F32, +t: F32, +b1: F32, +b2: F32, +w1: F32, +w2: F32, +clin: U32, +ccp: F32, +cir: U32, +coff: U32, +cbs: List<&2, Cb>, o: Lo) -> Rt:
  match o:
    case Lo{a, +ls, +ds, +mf, +l, +r}:
      +mf2 = ((mf * (0.0 - 0.25 : F32) : F32) + t : F32)
      rev.done(xn, b1, b2, w1, w2, clin, ccp, cir, coff, cbs, l, r, pushes(a, ls, rot(ds), mf2, []))

def rev.tick(a: Array<F32>, +f: Fx, +x: F32) -> Rt:
  match f:
    case Fx{on, +tone, +b1, +b2, +w1, +w2, +ls, +clin, +ccp, +cir, +coff, +cbs}:
      +xn = ((x * 0.1 : F32) + 0.00000001 : F32)
      +t = ((xn * b1 : F32) - (b2 * tone : F32) : F32)
      rev.fin(xn, t, b1, b2, w1, w2, clin, ccp, cir, coff, cbs, lines(a, ls, 0, w1, [], [], 0.0, 0.0, 0.0))

def cw() -> F32:
  (2.0 / 3.0 : F32)

def cw1() -> F32:
  (cw() * 5.5 : F32)

def cw2() -> F32:
  (cw() * (0.0 - 4.5 : F32) : F32)

def cb.out(+lo: U32, +ph: F32, +m: U32, +fr: F32, +buf: F32, +v0: F32, r: Array<F32> & F32) -> Co:
  (a, +v1) = r
  +o = (v0 + (fr * (v1 - buf : F32) : F32) : F32)
  Co{a, Cb{lo, ph, m, fr, o}, o}

def cb.read(+coff: U32, +lo: U32, +ph: F32, +m: U32, +fr: F32, +buf: F32, r: Array<F32> & F32) -> Co:
  (a, +v0) = r
  +lo2 = wrap((lo + 1 : U32), 2049)
  cb.out(lo2, ph, m, fr, buf, v0, Array.get(F32, a, (coff + lo2 : U32)))

def cb.step(a: Array<F32>, +b: Cb, +upd: Bool, +ccp: F32, +coff: U32) -> Co:
  match b:
    case Cb{+lout, +ph, +m, +fr, +buf}:
      +j = (m + 1 : U32)
      +p = posit((ccp + (sinus(ph, j, 14700) * 88.0 : F32) : F32), 2049)
      +lo = Bool.pick(U32, upd, ps.lout(p), lout)
      +nfr = Bool.pick(F32, upd, ps.fr(p), fr)
      +nm = Bool.pick(U32, upd, wrap(j, 14700), m)
      cb.read(coff, lo, ph, nm, nfr, buf, Array.get(F32, a, (coff + lo : U32)))

def blocks.next?(t: List<&2, Cb>, +upd: Bool, +ccp: F32, +coff: U32, +bs: List<&2, Cb>, +ds: List<&2, F32>, o: Co) -> Cs:
  match o:
    case Co{a, +b, +d}:
      blocks(a, t, upd, ccp, coff, b <> bs, d <> ds)

def blocks?(a: Array<F32>, cbs: List<&2, Cb>, +upd: Bool, +ccp: F32, +coff: U32, +bs: List<&2, Cb>, +ds: List<&2, F32>) -> Cs:
  match cbs:
    case +b <> t:
      blocks.next(t, upd, ccp, coff, bs, ds, cb.step(a, b, upd, ccp, coff))
    case []:
      Cs{a, List.reverse(&2, Cb, bs), ds}

def lat(+xs: List<&2, F32>, +i: Nat) -> F32:
  Maybe.default(&2, F32, List.get(&2, F32, xs, i), 0.0)

def cho.done(+tone: F32, +b1: F32, +b2: F32, +w1: F32, +w2: F32, +ls: List<&2, Ml>, +clin: U32, +ccp: F32, +cir: U32, +coff: U32, +x: F32, c: Cs) -> Rt:
  match c:
    case Cs{a, +bs, +ds}:
      +last = lat(ds, 0n)
      +d0 = (lat(ds, 2n) + last : F32)
      +d1 = (lat(ds, 1n) + last : F32)
      Rt{Array.set(F32, a, (coff + clin : U32), x), Fx{1, tone, b1, b2, w1, w2, ls, wrap((clin + 1 : U32), 2049), ccp, cir, coff, bs}, ((d0 * cw1() : F32) + (d1 * cw2() : F32) : F32), ((d1 * cw1() : F32) + (d0 * cw2() : F32) : F32)}

def cho.tick(a: Array<F32>, +f: Fx, +x: F32) -> Rt:
  match f:
    case Fx{on, +tone, +b1, +b2, +w1, +w2, +ls, +clin, +ccp, +cir, +coff, +cbs}:
      +ir1 = (cir + 1 : U32)
      +upd = U32.is_ge(ir1, 5)
      +ncp = Bool.pick(F32, upd, fwrap((ccp + 5.0 : F32), 2049), ccp)
      cho.done(tone, b1, b2, w1, w2, ls, clin, ncp, Bool.pick(U32, upd, 0, ir1), coff, x, blocks(a, cbs, upd, ccp, coff, [], []))

type Fo is Type:
  Fo{a: Array<F32>, fx: Fx, out: List<&2, F32>}

def run.cho?(+l: F32, +r: F32, +rl: F32, +rr: F32, t: List<&2, F32>, +out: List<&2, F32>, o: Rt) -> Fo:
  match o:
    case Rt{a, +f, +cl, +cr}:
      run(a, f, t, ((r + rr : F32) + cr : F32) <> ((l + rl : F32) + cl : F32) <> out)

def run.rev?(+l: F32, +r: F32, +c: F32, t: List<&2, F32>, +out: List<&2, F32>, o: Rt) -> Fo:
  match o:
    case Rt{a, +f, +rl, +rr}:
      run.cho(l, r, rl, rr, t, out, cho.tick(a, f, c))

def run?(a: Array<F32>, +f: Fx, xs: List<&2, F32>, +out: List<&2, F32>) -> Fo:
  match xs:
    case +l <> +r <> +v <> +c <> t:
      run.rev(l, r, c, t, out, rev.tick(a, f, v))
    case _:
      Fo{a, f, List.reverse(&2, F32, out)}

def phase(+deg: F32) -> F32:
  (((2.0 * F32.pi() : F32) / 360.0 : F32) * deg : F32)

def gimax() -> F32:
  F32.pow(10.0, ((((0.0 - 3.0 : F32) * 4919.0 : F32) / 12.5 : F32) / rate() : F32))

def gimin() -> F32:
  F32.pow(10.0, ((((0.0 - 3.0 : F32) * 4919.0 : F32) / 0.7 : F32) / rate() : F32))

def dcrev() -> F32:
  +gi = (gimin() + (0.2 * (gimax() - gimin() : F32) : F32) : F32)
  ((((0.0 - 3.0 : F32) * F32.log(10.0) : F32) * (4919.0 / rate() : F32) : F32) / F32.log(gi) : F32)

def line(+i: U32, +len: U32, +off: U32) -> Ml:
  +gi = F32.pow(10.0, ((((0.0 - 3.0 : F32) * U32.to_f32((len + 4 : U32)) : F32) / rate() : F32) / dcrev() : F32))
  Ml{0, 1, (len + 9 : U32), off, 0.0, gi, 0.0, phase((45.0 * U32.to_f32(i) : F32)), 0, 5.0, 50, 0.0, 0.0}

def mklines(ns: List<&2, U32>, +i: U32, +off: U32, +acc: List<&2, Ml>) -> List<&2, Ml>:
  match ns:
    case +n <> t:
      mklines(t, (i + 1 : U32), (off + n + 9 : U32), line(i, n, off) <> acc)
    case []:
      List.reverse(&2, Ml, acc)

def block(+i: U32) -> Cb:
  Cb{0, phase((120.0 * U32.to_f32(i) : F32)), 0, 0.0, 0.0}

def new(+base: U32) -> Fx:
  +w = (4.5 / 1.1 : F32)
  +w1 = (w * 0.75 : F32)
  Fx{1, 0.0, 1.0, 0.0, w1, ((w * 0.25 : F32) / w1 : F32), mklines(noms(), 0, base, []), 0, 1960.0, 5, (base + 30588 : U32), [block(0), block(1), block(2)]}

def off() -> Fx:
  Fx{0, 0.0, 0.0, 0.0, 0.0, 0.0, [], 0, 0.0, 0, 0, []}

def on(+f: Fx) -> Bool:
  match f:
    case Fx{+on, tone, b1, b2, w1, w2, ls, clin, ccp, cir, coff, cbs}:
      U32.is_eq(on, 1)
