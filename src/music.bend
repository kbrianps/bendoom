import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./hud.bend as U
import ./mem.bend as M
import ./wad.bend as W
import ./opltab.bend as O
import ./sf2.bend as G
import ./gm.bend as Y

type St is Data:
  St{ph: U32, eg: U32, gen: U32, out: U32}

type Op is Data:
  Op{r20: U32, r40: U32, r60: U32, r80: U32, re0: U32}

type P is Data:
  P{ra: U32, rd: U32, rr: U32, sl: U32, egt: U32, att0: U32, am: U32, vib: U32, io: U32, mtv: U32, fnum: U32, block: U32, wfo: U32}

type V is Data:
  V{ins: U32, iv: U32, ch: U32, mk: U32, note: U32, freq: U32, nvol: U32, carv: U32, modv: U32, a0: U32, b0: U32, c0: U32, m: Op, c: Op, sm: St, sc: St, pr: U32}

type Cn is Data:
  Cn{ins: U32, vol: U32, base: U32, bend: U32, pan: U32}

type Dr is Data:
  Dr{vs: List<&2, V>, fr: List<&2, U32>, al: List<&2, U32>, cs: List<&2, Cn>, cur: U32, st: U32}

type Lk is Data:
  Lk{gm: T.Vec<U32>, fq: T.Vec<U32>, vm: T.Vec<U32>, ps: G.Bank, o3: U32}

type E is Data:
  E{t: U32, e: U32}

def none() -> U32:
  4294967295

def bias() -> U32:
  1048576

def k16() -> U32:
  295525

def sx(+x: U32) -> U32:
  Bool.pick(U32, U32.is_ge(x, 32768), (x - 65536 : U32), x)

def neg(+x: U32) -> Bool:
  U32.is_ge(x, 2147483648)

def st.out(+s: St) -> U32:
  match s:
    case St{ph, eg, gen, +out}:
      out

def st.idle(+s: St) -> Bool:
  match s:
    case St{ph, +eg, +gen, out}:
      Bool.and(U32.is_ge((eg >> 16n : U32), 511), U32.is_eq(gen, 3))

def ksshift(+k: U32) -> U32:
  Bool.pick(U32, U32.is_eq(k, 0), 8, Bool.pick(U32, U32.is_eq(k, 3), 0, k))

def rix(+reg: U32, +ks: U32) -> U32:
  Bool.pick(U32, U32.is_eq(reg, 0), 0, U32.min((ks + reg * 4 : U32), 63))

def scale(+inc: U32) -> U32:
  ((((inc >> 8n) * k16()) >> 8n) + (((inc .&. 255) * k16()) >> 16n) : U32)

def pinc(+fnum: U32, +block: U32, +mtv: U32) -> U32:
  (((((fnum << U32.to_nat(block)) >> 1n) * mtv) >> 1n) : U32)

def pre.go(+fnum: U32, +block: U32, +o: Op, +kr: U32, +mtv: U32) -> P:
  match o:
    case Op{+r20, +r40, +r60, +r80, +re0}:
      +ksv = ((block << 1n) .|. ((fnum >> 8n) .&. 1) : U32)
      +ks = Bool.pick(U32, U32.is_eq(((r20 >> 4n) .&. 1 : U32), 1), ksv, (ksv >> 2n : U32))
      +kl = (kr * 4 - (8 - block) * 32 : U32)
      +klv = Bool.pick(U32, neg(kl), 0, (kl >> U32.to_nat(ksshift((r40 >> 6n : U32))) : U32))
      +sl = (r80 >> 4n : U32)
      P{rix((r60 >> 4n : U32), ks), rix((r60 .&. 15 : U32), ks), rix((r80 .&. 15 : U32), ks), Bool.pick(U32, U32.is_eq(sl, 15), 31, sl), ((r20 >> 5n) .&. 1 : U32), ((r40 .&. 63) * 4 + klv : U32), (r20 >> 7n : U32), ((r20 >> 6n) .&. 1 : U32), scale(pinc(fnum, block, mtv)), mtv, fnum, block, (re0 * 1024 + Bool.pick(U32, U32.is_ge(re0, 4), 416, 0) : U32)}

def pre(tb: Array<U32>, +fnum: U32, +block: U32, +o: Op) -> Array<U32> & P:
  match o:
    case Op{+r20, +r40, +r60, +r80, +re0}:
      M.let(Array<U32> & P, M.rd(tb, (4480 + (fnum >> 6n) : U32)), t1 => +kr =>
        M.let(Array<U32> & P, M.rd(t1, (4496 + (r20 .&. 15) : U32)), t2 => +mtv =>
          (t2, pre.go(fnum, block, Op{r20, r40, r60, r80, re0}, kr, mtv))))

def vinc(+p: P, +vp: U32) -> U32:
  match p:
    case P{ra, rd, rr, sl, egt, att0, am, vib, io, +mtv, +fnum, +block, wfo}:
      +r0 = ((fnum >> 7n) .&. 7 : U32)
      +r1 = Bool.pick(U32, U32.is_eq((vp .&. 3 : U32), 0), 0, Bool.pick(U32, U32.is_eq((vp .&. 1 : U32), 1), (r0 >> 1n : U32), r0))
      +r2 = (r1 >> 1n : U32)
      +fn = Bool.pick(U32, U32.is_eq((vp .&. 4 : U32), 4), (fnum - r2 : U32), (fnum + r2 : U32))
      scale(pinc(fn, block, mtv))

def eg.att(+eg: U32, +a: U32) -> U32:
  +d = ((((((eg >> 8n) + 256) >> 4n) * a) >> 4n) : U32)
  Bool.pick(U32, U32.is_ge(d, eg), 0, (eg - d : U32))

def eg.next(+gen: U32, +eg1: U32, +off: Bool, +sl: U32, +egt: U32, +av: U32, +dv: U32, +rv: U32) -> U32:
  +a = Bool.pick(U32, U32.is_lt(eg1, 65536), 0, eg.att(eg1, av))
  +d = Bool.pick(U32, U32.is_ge((eg1 >> 20n : U32), sl), eg1, Bool.pick(U32, off, eg1, (eg1 + dv : U32)))
  +r = Bool.pick(U32, Bool.and(Bool.not(off), Bool.or(U32.is_eq(gen, 3), U32.is_eq(egt, 0))), (eg1 + rv : U32), eg1)
  U32.min(Bool.pick(U32, U32.is_eq(gen, 0), a, Bool.pick(U32, U32.is_eq(gen, 1), d, r)), 33488896)

def gen.next(+gen: U32, +eg1: U32, +sl: U32) -> U32:
  Bool.pick(U32, U32.is_eq(gen, 0), Bool.pick(U32, U32.is_lt(eg1, 65536), 1, 0),
    Bool.pick(U32, U32.is_eq(gen, 1), Bool.pick(U32, U32.is_ge((eg1 >> 20n : U32), sl), 2, 1), gen))

def step.out(+w: U32, +e: U32, +lv: U32) -> U32:
  +o = (e >> U32.to_nat((lv >> 8n : U32)) : U32)
  Bool.pick(U32, U32.is_eq((w .&. 32768 : U32), 0), o, ((4294967295 - o) .&. 65535 : U32))

def step.lv(+w: U32, +egout: U32) -> U32:
  U32.min(((w .&. 32767) + (egout << 3n) : U32), 8191)

def step.go(tb: Array<U32>, +p: P, +ph: U32, +eg: U32, +gen: U32, +key: U32, +mod: U32, +tv: U32, +av: U32, +dv: U32, +rv: U32) -> Array<U32> & St:
  match p:
    case P{+ra, rd, rr, +sl, +egt, +att0, +am, +vib, +io, mtv, fnum, block, +wfo}:
      +reset = Bool.and(U32.is_eq(key, 1), U32.is_eq(gen, 3))
      +egi = (eg >> 16n : U32)
      +off = U32.is_eq((egi .&. 504 : U32), 504)
      +inst = U32.is_ge(ra, 60)
      +eg1 = Bool.pick(U32, Bool.and(U32.is_ne(gen, 0), off), 33488896, eg)
      +egn = Bool.pick(U32, reset, Bool.pick(U32, inst, 0, eg), eg.next(gen, eg1, off, sl, egt, av, dv, rv))
      +gn = Bool.pick(U32, U32.is_eq(key, 0), 3, Bool.pick(U32, reset, 0, gen.next(gen, eg1, sl)))
      +ego = Bool.pick(U32, reset, Bool.pick(U32, inst, 0, egi), (eg1 >> 16n : U32))
      +egout = (ego + att0 + Bool.pick(U32, U32.is_eq(am, 1), (tv >> 3n : U32), 0) : U32)
      +inc = Bool.pick(U32, U32.is_eq(vib, 1), vinc(p, (tv .&. 7 : U32)), io)
      +ph0 = Bool.pick(U32, reset, 0, ph)
      +idx = ((ph0 >> 9n) + mod : U32)
      M.let(Array<U32> & St, M.rd(tb, (wfo + (idx .&. 1023) : U32)), t1 => +w =>
        M.let(Array<U32> & St, M.rd(t1, (4096 + (step.lv(w, egout) .&. 255) : U32)), t2 => +e =>
          (t2, St{(ph0 + inc : U32), egn, gn, step.out(w, e, step.lv(w, egout))})))

def step(tb: Array<U32>, +p: P, +s: St, +key: U32, +mod: U32, +tv: U32) -> Array<U32> & St:
  match p s:
    case P{+ra, +rd, +rr, +sl, +egt, +att0, +am, +vib, +io, +mtv, +fnum, +block, +wfo} St{+ph, +eg, +gen, out}:
      M.let(Array<U32> & St, M.rd(tb, (4416 + ra : U32)), t1 => +av =>
        M.let(Array<U32> & St, M.rd(t1, (4352 + rd : U32)), t2 => +dv =>
          M.let(Array<U32> & St, M.rd(t2, (4352 + rr : U32)), t3 => +rv =>
            step.go(t3, P{ra, rd, rr, sl, egt, att0, am, vib, io, mtv, fnum, block, wfo}, ph, eg, gen, key, mod, tv, av, dv, rv))))

def vcons(+x: U32, r: (List<&2, U32> & Array<U32>) & ((St & St) & U32)) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  (p, s) = r
  (l, tb) = p
  ((x <> l, tb), s)

def vrun?(acc: List<&2, U32>, tb: Array<U32>, ck: List<&2, U32>, +pm: P, +pc: P, +key: U32, +fb: U32, +con: U32, +sm: St, +sc: St, +pr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  match acc ck:
    case +x <> t +k <> kt:
      vpick(Bool.and(U32.is_eq(key, 0), Bool.and(st.idle(sm), st.idle(sc))), x, t, tb, k, kt, pm, pc, key, fb, con, sm, sc, pr)
    case a _:
      ((a, tb), ((sm, sc), pr))

def vpick?(idle: Bool, +x: U32, t: List<&2, U32>, tb: Array<U32>, +k: U32, kt: List<&2, U32>, +pm: P, +pc: P, +key: U32, +fb: U32, +con: U32, +sm: St, +sc: St, +pr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  match idle:
    case True{}:
      ((x <> t, tb), ((sm, sc), pr))
    case False{}:
      +mo0 = st.out(sm)
      +fbm = Bool.pick(U32, U32.is_eq(fb, 0), 0, F.sar((sx(pr) + sx(mo0) : U32), U32.to_nat((9 - fb : U32))))
      vmod(step(tb, pm, sm, key, fbm, k), x, t, k, kt, pm, pc, key, fb, con, sc, mo0)

def vmod?(r: Array<U32> & St, +x: U32, t: List<&2, U32>, +k: U32, kt: List<&2, U32>, +pm: P, +pc: P, +key: U32, +fb: U32, +con: U32, +sc: St, +npr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  (tb, +sm1) = r
  +mo = st.out(sm1)
  vcar(step(tb, pc, sc, key, Bool.pick(U32, U32.is_eq(con, 1), 0, sx(mo)), k), x, t, kt, pm, pc, key, fb, con, sm1, mo, npr)

def vcar?(r: Array<U32> & St, +x: U32, t: List<&2, U32>, kt: List<&2, U32>, +pm: P, +pc: P, +key: U32, +fb: U32, +con: U32, +sm1: St, +mo: U32, +npr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  (tb, +sc1) = r
  +x1 = (x + sx(st.out(sc1)) + Bool.pick(U32, U32.is_eq(con, 1), sx(mo), 0) : U32)
  vcons(x1, vrun(t, tb, kt, pm, pc, key, fb, con, sm1, sc1, npr))

def vcons2(+x: U32, +y: U32, r: (List<&2, U32> & Array<U32>) & ((St & St) & U32)) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  (p, s) = r
  (l, tb) = p
  ((x <> y <> l, tb), s)

def vrun2?(acc: List<&2, U32>, tb: Array<U32>, ck: List<&2, U32>, +pm: P, +pc: P, +key: U32, +fb: U32, +con: U32, +ca: U32, +cb: U32, +sm: St, +sc: St, +pr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  match acc ck:
    case +x <> +y <> t +k <> kt:
      vpick2(Bool.and(U32.is_eq(key, 0), Bool.and(st.idle(sm), st.idle(sc))), x, y, t, tb, k, kt, pm, pc, key, fb, con, ca, cb, sm, sc, pr)
    case a _:
      ((a, tb), ((sm, sc), pr))

def vpick2?(idle: Bool, +x: U32, +y: U32, t: List<&2, U32>, tb: Array<U32>, +k: U32, kt: List<&2, U32>, +pm: P, +pc: P, +key: U32, +fb: U32, +con: U32, +ca: U32, +cb: U32, +sm: St, +sc: St, +pr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  match idle:
    case True{}:
      ((x <> y <> t, tb), ((sm, sc), pr))
    case False{}:
      +mo0 = st.out(sm)
      +fbm = Bool.pick(U32, U32.is_eq(fb, 0), 0, F.sar((sx(pr) + sx(mo0) : U32), U32.to_nat((9 - fb : U32))))
      vmod2(step(tb, pm, sm, key, fbm, k), x, y, t, k, kt, pm, pc, key, fb, con, ca, cb, sc, mo0)

def vmod2?(r: Array<U32> & St, +x: U32, +y: U32, t: List<&2, U32>, +k: U32, kt: List<&2, U32>, +pm: P, +pc: P, +key: U32, +fb: U32, +con: U32, +ca: U32, +cb: U32, +sc: St, +npr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  (tb, +sm1) = r
  +mo = st.out(sm1)
  vcar2(step(tb, pc, sc, key, Bool.pick(U32, U32.is_eq(con, 1), 0, sx(mo)), k), x, y, t, kt, pm, pc, key, fb, con, ca, cb, sm1, mo, npr)

def vcar2?(r: Array<U32> & St, +x: U32, +y: U32, t: List<&2, U32>, kt: List<&2, U32>, +pm: P, +pc: P, +key: U32, +fb: U32, +con: U32, +ca: U32, +cb: U32, +sm1: St, +mo: U32, +npr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  (tb, +sc1) = r
  +o = (sx(st.out(sc1)) + Bool.pick(U32, U32.is_eq(con, 1), sx(mo), 0) : U32)
  vcons2((x + o * ca : U32), (y + o * cb : U32), vrun2(t, tb, kt, pm, pc, key, fb, con, ca, cb, sm1, sc1, npr))

def clocks.go(n: Nat, +clk: U32, +cfr: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      +f = (cfr + 33381 : U32)
      +c = (clk + 4 + (f >> 16n) : U32)
      +tp = ((c >> 6n) % 210 : U32)
      +tr = (Bool.pick(U32, U32.is_lt(tp, 105), tp, (210 - tp : U32)) >> 4n : U32)
      clocks.go(p, c, (f .&. 65535 : U32), (tr * 8 + ((c >> 10n) .&. 7) : U32) <> acc)

def clocks(n: Nat, +clk: U32, +cfr: U32) -> List<&2, U32>:
  clocks.go(n, clk, cfr, [])

def clock.at(n: Nat, +clk: U32, +cfr: U32) -> U32 & U32:
  match n:
    case 0n:
      (clk, cfr)
    case 1n+p:
      +f = (cfr + 33381 : U32)
      clock.at(p, (clk + 4 + (f >> 16n) : U32), (f .&. 65535 : U32))

def zeros.go(n: Nat, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      zeros.go(p, bias() <> acc)

def zeros(n: Nat) -> List<&2, U32>:
  zeros.go(n, [])

def v.idle(+v: V) -> Bool:
  match v:
    case V{ins, iv, ch, mk, note, freq, nvol, carv, modv, a0, +b0, c0, m, c, +sm, +sc, pr}:
      Bool.and(U32.is_eq((b0 .&. 32 : U32), 0), Bool.and(st.idle(sm), st.idle(sc)))

def v.ran3(+v: V, p: List<&2, U32> & Array<U32>, ss: St & St, +npr: U32) -> (List<&2, U32> & Array<U32>) & V:
  match v:
    case V{+ins, +iv, +ch, +mk, +note, +freq, +nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, sm, sc, pr}:
      (+nsm, +nsc) = ss
      (p, V{ins, iv, ch, mk, note, freq, nvol, carv, modv, a0, b0, c0, m, c, nsm, nsc, npr})

def v.ran2(+v: V, p: List<&2, U32> & Array<U32>, q: (St & St) & U32) -> (List<&2, U32> & Array<U32>) & V:
  (ss, +npr) = q
  v.ran3(v, p, ss, npr)

def v.ran(+v: V, r: (List<&2, U32> & Array<U32>) & ((St & St) & U32)) -> (List<&2, U32> & Array<U32>) & V:
  (p, q) = r
  v.ran2(v, p, q)

def vgo(st2: Bool, acc: List<&2, U32>, tb: Array<U32>, ck: List<&2, U32>, +pm: P, +pc: P, +key: U32, +c0: U32, +sm: St, +sc: St, +pr: U32) -> (List<&2, U32> & Array<U32>) & ((St & St) & U32):
  match st2:
    case True{}:
      vrun2(acc, tb, ck, pm, pc, key, ((c0 >> 1n) .&. 7 : U32), (c0 .&. 1 : U32), ((c0 >> 4n) .&. 1 : U32), ((c0 >> 5n) .&. 1 : U32), sm, sc, pr)
    case False{}:
      vrun(acc, tb, ck, pm, pc, key, ((c0 >> 1n) .&. 7 : U32), (c0 .&. 1 : U32), sm, sc, pr)

def v.run2(+v: V, +o3: U32, acc: List<&2, U32>, ck: List<&2, U32>, +pm: P, r: Array<U32> & P) -> (List<&2, U32> & Array<U32>) & V:
  match v:
    case V{+ins, +iv, +ch, +mk, +note, +freq, +nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, +sm, +sc, +pr}:
      (tb, +pc) = r
      v.ran(V{ins, iv, ch, mk, note, freq, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}, vgo(U32.is_eq(o3, 1), acc, tb, ck, pm, pc, ((b0 >> 5n) .&. 1 : U32), c0, sm, sc, pr))

def v.run1(+v: V, +o3: U32, acc: List<&2, U32>, ck: List<&2, U32>, r: Array<U32> & P) -> (List<&2, U32> & Array<U32>) & V:
  match v:
    case V{+ins, +iv, +ch, +mk, +note, +freq, +nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, +sm, +sc, +pr}:
      (tb, +pm) = r
      v.run2(V{ins, iv, ch, mk, note, freq, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}, o3, acc, ck, pm, pre(tb, (a0 .|. ((b0 .&. 3) << 8n) : U32), ((b0 >> 2n) .&. 7 : U32), c))

def v.run(+v: V, +o3: U32, acc: List<&2, U32>, tb: Array<U32>, ck: List<&2, U32>) -> (List<&2, U32> & Array<U32>) & V:
  match v:
    case V{+ins, +iv, +ch, +mk, +note, +freq, +nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, +sm, +sc, +pr}:
      v.run1(V{ins, iv, ch, mk, note, freq, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}, o3, acc, ck, pre(tb, (a0 .|. ((b0 .&. 3) << 8n) : U32), ((b0 >> 2n) .&. 7 : U32), m))

def seg.cons(+v: V, r: (List<&2, U32> & Array<U32>) & List<&2, V>) -> (List<&2, U32> & Array<U32>) & List<&2, V>:
  (p, vs) = r
  (p, v <> vs)

def seg?(vs: List<&2, V>, +o3: U32, acc: List<&2, U32>, tb: Array<U32>, +ck: List<&2, U32>) -> (List<&2, U32> & Array<U32>) & List<&2, V>:
  match vs:
    case +v <> t:
      seg.pick(v.idle(v), v, t, o3, acc, tb, ck)
    case []:
      ((acc, tb), [])

def seg.pick?(idle: Bool, +v: V, t: List<&2, V>, +o3: U32, acc: List<&2, U32>, tb: Array<U32>, +ck: List<&2, U32>) -> (List<&2, U32> & Array<U32>) & List<&2, V>:
  match idle:
    case True{}:
      seg.cons(v, seg(t, o3, acc, tb, ck))
    case False{}:
      seg.next(v.run(v, o3, acc, tb, ck), o3, ck, t)

def seg.next?(r: (List<&2, U32> & Array<U32>) & V, +o3: U32, +ck: List<&2, U32>, t: List<&2, V>) -> (List<&2, U32> & Array<U32>) & List<&2, V>:
  (p, +v) = r
  (acc, tb) = p
  seg.cons(v, seg(t, o3, acc, tb, ck))

def gb(+lk: Lk, +ins: U32, +off: U32) -> U32:
  match lk:
    case Lk{+gm, fq, vm, ps, o3}:
      T.get(U32, gm, (8 + ins * 36 + off : U32), 0)

def vmt(+lk: Lk, +i: U32) -> U32:
  match lk:
    case Lk{gm, fq, +vm, ps, o3}:
      T.get(U32, vm, i, 0)

def fqc(+lk: Lk, +i: U32) -> U32:
  match lk:
    case Lk{gm, +fq, vm, ps, o3}:
      T.get(U32, fq, i, 0)

def lps(+lk: Lk) -> G.Bank:
  match lk:
    case Lk{gm, fq, vm, +ps, o3}:
      ps

def o3(+lk: Lk) -> U32:
  match lk:
    case Lk{gm, fq, vm, ps, +o3}:
      o3

def isgm(+lk: Lk) -> Bool:
  Bool.not(Y.empty(lps(lk)))

def lget(+xs: List<&2, U32>, +i: U32) -> U32:
  match xs:
    case +x <> t:
      Bool.pick(U32, U32.is_eq(i, 0), x, lget(t, (i - 1 : U32)))
    case []:
      0

def ldrop(+xs: List<&2, U32>, +i: U32) -> List<&2, U32>:
  match xs:
    case +x <> +t:
      Bool.pick(List<&2, U32>, U32.is_eq(i, 0), t, x <> ldrop(t, (i - 1 : U32)))
    case []:
      []

def nov() -> V:
  V{none(), none(), none(), 0, 0, 0, 0, 0, 0, 0, 0, 0, Op{0, 63, 0, 0, 0}, Op{0, 63, 0, 0, 0}, St{0, 33488896, 3, 0}, St{0, 33488896, 3, 0}, 0}

def vget(+vs: List<&2, V>, +i: U32) -> V:
  match vs:
    case +v <> t:
      Bool.pick(V, U32.is_eq(i, 0), v, vget(t, (i - 1 : U32)))
    case []:
      nov()

def vset(+vs: List<&2, V>, +i: U32, +n: V) -> List<&2, V>:
  match vs:
    case +v <> +t:
      Bool.pick(List<&2, V>, U32.is_eq(i, 0), n <> t, v <> vset(t, (i - 1 : U32), n))
    case []:
      []

def cget(+cs: List<&2, Cn>, +i: U32) -> Cn:
  match cs:
    case +c <> t:
      Bool.pick(Cn, U32.is_eq(i, 0), c, cget(t, (i - 1 : U32)))
    case []:
      Cn{0, 0, 100, 0, 48}

def cset(+cs: List<&2, Cn>, +i: U32, +n: Cn) -> List<&2, Cn>:
  match cs:
    case +c <> +t:
      Bool.pick(List<&2, Cn>, U32.is_eq(i, 0), n <> t, c <> cset(t, (i - 1 : U32), n))
    case []:
      []

def cn.ins(+c: Cn) -> U32:
  match c:
    case Cn{+ins, vol, base, bend, pan}:
      ins

def cn.vol(+c: Cn) -> U32:
  match c:
    case Cn{ins, +vol, base, bend, pan}:
      vol

def cn.base(+c: Cn) -> U32:
  match c:
    case Cn{ins, vol, +base, bend, pan}:
      base

def cn.bend(+c: Cn) -> U32:
  match c:
    case Cn{ins, vol, base, +bend, pan}:
      bend

def cn.pan(+c: Cn) -> U32:
  match c:
    case Cn{ins, vol, base, bend, +pan}:
      pan

def v.ch(+v: V) -> U32:
  match v:
    case V{ins, iv, +ch, mk, note, freq, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}:
      ch

def v.mk(+v: V) -> U32:
  match v:
    case V{ins, iv, ch, +mk, note, freq, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}:
      mk

def v.iv(+v: V) -> U32:
  match v:
    case V{ins, +iv, ch, mk, note, freq, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}:
      iv

def v.nvol(+v: V) -> U32:
  match v:
    case V{ins, iv, ch, mk, note, freq, +nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}:
      nvol

def op.lv(+o: Op, +l: U32) -> Op:
  match o:
    case Op{+r20, r40, +r60, +r80, +re0}:
      Op{r20, l, r60, r80, re0}

def gop(+lk: Lk, +ins: U32, +b: U32, +lv: U32) -> Op:
  Op{gb(lk, ins, b), lv, gb(lk, ins, (b + 1 : U32)), gb(lk, ins, (b + 2 : U32)), (gb(lk, ins, (b + 3 : U32)) .&. Bool.pick(U32, U32.is_eq(o3(lk), 1), 7, 3) : U32)}

def instr.load(+lk: Lk, +v: V, +ins: U32, +iv: U32, +pan: U32) -> V:
  match v:
    case V{oi, ov, +ch, +mk, +note, +freq, +nvol, carv, modv, +a0, +b0, c0, m, c, +sm, +sc, +pr}:
      +b = (4 + iv * 16 : U32)
      +fbk = gb(lk, ins, (b + 6 : U32))
      +cl = (gb(lk, ins, (b + 11 : U32)) .|. 63 : U32)
      +ml = (gb(lk, ins, (b + 4 : U32)) .|. Bool.pick(U32, U32.is_eq((fbk .&. 1 : U32), 0), gb(lk, ins, (b + 5 : U32)), 63) : U32)
      V{ins, iv, ch, mk, note, freq, nvol, cl, ml, a0, b0, (fbk .|. pan : U32), gop(lk, ins, b, ml), gop(lk, ins, (b + 7 : U32), cl), sm, sc, pr}

def instr.same(+v: V, +ins: U32, +iv: U32) -> Bool:
  match v:
    case V{+oi, +ov, ch, mk, note, freq, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}:
      Bool.and(U32.is_eq(oi, ins), U32.is_eq(ov, iv))

def instr.go(same: Bool, +lk: Lk, +v: V, +ins: U32, +iv: U32, +pan: U32) -> V:
  match same:
    case True{}:
      v
    case False{}:
      instr.load(lk, v, ins, iv, pan)

def instr(+lk: Lk, +v: V, +ins: U32, +iv: U32, +pan: U32) -> V:
  instr.go(instr.same(v, ins, iv), lk, v, ins, iv, pan)

def volume(+lk: Lk, +v: V, +vol: U32, +chvol: U32) -> V:
  match v:
    case V{+ins, +iv, +ch, +mk, +note, +freq, nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, +sm, +sc, +pr}:
      +b = (4 + iv * 16 : U32)
      +midi = (2 * (vmt(lk, chvol) + 1) : U32)
      +car = (63 - ((vmt(lk, vol) * midi) >> 9n) : U32)
      +changed = U32.is_ne(car, (carv .&. 63 : U32))
      +ncv = (car .|. (carv .&. 192) : U32)
      +ml = gb(lk, ins, (b + 5 : U32))
      +addm = Bool.and(changed, Bool.and(U32.is_eq((gb(lk, ins, (b + 6 : U32)) .&. 1 : U32), 1), U32.is_ne(ml, 63)))
      +md = (U32.max(ml, car) .|. (modv .&. 192) : U32)
      +setm = Bool.and(addm, U32.is_ne(md, modv))
      V{ins, iv, ch, mk, note, freq, vol, Bool.pick(U32, changed, ncv, carv), Bool.pick(U32, setm, md, modv), a0, b0, c0,
        Bool.pick(Op, setm, op.lv(m, (md .|. (gb(lk, ins, (b + 4 : U32)) .&. 192) : U32)), m), Bool.pick(Op, changed, op.lv(c, ncv), c), sm, sc, pr}

def nlow(n: Nat, +x: U32) -> U32:
  match n:
    case 0n:
      x
    case 1n+p:
      Bool.pick(U32, neg(x), nlow(p, (x + 12 : U32)), x)

def nhigh(n: Nat, +x: U32) -> U32:
  match n:
    case 0n:
      x
    case 1n+p:
      Bool.pick(U32, U32.is_gt(x, 95), nhigh(p, (x - 12 : U32)), x)

def freq.of(+lk: Lk, +ins: U32, +iv: U32, +note: U32, +bend: U32) -> U32:
  +b = (4 + iv * 16 : U32)
  +off = (gb(lk, ins, (b + 14 : U32)) + 256 * gb(lk, ins, (b + 15 : U32)) : U32)
  +so = Bool.pick(U32, U32.is_ge(off, 32768), (off - 65536 : U32), off)
  +n0 = Bool.pick(U32, U32.is_eq((gb(lk, ins, 0) .&. 1 : U32), 1), note, (note + so : U32))
  +n1 = nhigh(16n, nlow(16n, n0))
  +f0 = (64 + 32 * n1 + bend : U32)
  +f1 = Bool.pick(U32, U32.is_ne(iv, 0), (f0 + gb(lk, ins, 2) / 2 - 64 : U32), f0)
  +fi = Bool.pick(U32, neg(f1), 0, f1)
  +k = (fi - 284 : U32)
  Bool.pick(U32, U32.is_lt(fi, 284), fqc(lk, fi), (fqc(lk, (k % 384 + 284 : U32)) .|. (U32.min((k / 384 : U32), 7) << 10n) : U32))

def freq.set(+lk: Lk, +v: V, +bend: U32) -> V:
  match v:
    case V{+ins, +iv, +ch, +mk, +note, +freq, +nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, +sm, +sc, +pr}:
      +f = freq.of(lk, ins, iv, note, bend)
      +ch2 = U32.is_ne(f, freq)
      V{ins, iv, ch, mk, note, f, nvol, carv, modv, Bool.pick(U32, ch2, (f .&. 255 : U32), a0), Bool.pick(U32, ch2, ((f >> 8n) .|. 32 : U32), b0), c0, m, c, sm, sc, pr}

def keyoff(+v: V) -> V:
  match v:
    case V{+ins, +iv, ch, +mk, note, +freq, +nvol, +carv, +modv, +a0, b0, +c0, +m, +c, +sm, +sc, +pr}:
      V{ins, iv, none(), mk, 0, freq, nvol, carv, modv, a0, (freq >> 8n : U32), c0, m, c, sm, sc, pr}

def offs(ids: List<&2, U32>, +vs: List<&2, V>) -> List<&2, V>:
  match ids:
    case +i <> t:
      offs(t, vset(vs, i, keyoff(vget(vs, i))))
    case []:
      vs

def hits(+vs: List<&2, V>, +ch: U32, +any: Bool, +k: U32, +id: U32) -> Bool:
  Bool.and(U32.is_eq(v.ch(vget(vs, id)), ch), Bool.or(any, U32.is_eq(v.mk(vget(vs, id)), k)))

def kg.pick(hit: Bool, want: Bool, +i: U32, xs: List<&2, U32>) -> List<&2, U32>:
  match hit want:
    case True{} True{}:
      i <> xs
    case False{} False{}:
      i <> xs
    case _ _:
      xs

def kg(+vs: List<&2, V>, al: List<&2, U32>, +ch: U32, +any: Bool, +k: U32, +want: Bool) -> List<&2, U32>:
  match al:
    case +i <> t:
      kg.pick(hits(vs, ch, any, k, i), want, i, kg(vs, t, ch, any, k, want))
    case []:
      []

def keep(+vs: List<&2, V>, +al: List<&2, U32>, +ch: U32, +any: Bool, +k: U32) -> List<&2, U32>:
  kg(vs, al, ch, any, k, False{})

def gone(+vs: List<&2, V>, +al: List<&2, U32>, +ch: U32, +any: Bool, +k: U32) -> List<&2, U32>:
  kg(vs, al, ch, any, k, True{})

def release(+d: Dr, +ch: U32, +any: Bool, +k: U32) -> Dr:
  match d:
    case Dr{+vs, +fr, +al, +cs, +cur, +st}:
      +g = gone(vs, al, ch, any, k)
      Dr{offs(g, vs), List.append(&2, U32, fr, g), keep(vs, al, ch, any, k), cs, cur, st}

def rpick(al: List<&2, U32>, +vs: List<&2, V>, +i: U32, +r: U32, +rch: U32) -> U32:
  match al:
    case +id <> t:
      +v = vget(vs, id)
      +hit = Bool.or(U32.is_ne(v.iv(v), 0), U32.is_ge(v.ch(v), rch))
      rpick(t, vs, (i + 1 : U32), Bool.pick(U32, hit, i, r), Bool.pick(U32, hit, v.ch(v), rch))
    case []:
      r

def replace(+d: Dr) -> Dr:
  match d:
    case Dr{+vs, +fr, +al, +cs, +cur, +st}:
      +r = rpick(al, vs, 0, 0, v.ch(vget(vs, lget(al, 0))))
      +id = lget(al, r)
      Dr{vset(vs, id, keyoff(vget(vs, id))), List.append(&2, U32, fr, [id]), ldrop(al, r), cs, cur, st}

def note.set(+v: V, +ch: U32, +mk: U32, +note: U32) -> V:
  match v:
    case V{+ins, +iv, c0h, mk0, n0, freq, +nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, +sm, +sc, +pr}:
      V{ins, iv, ch, mk, note, 0, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}

def note.set0(+v: V) -> V:
  match v:
    case V{+ins, +iv, +ch, +mk, +note, freq, +nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, +sm, +sc, +pr}:
      V{ins, iv, ch, mk, note, 0, nvol, carv, modv, a0, b0, c0, m, c, sm, sc, pr}

def voice.take(fr: List<&2, U32>, +lk: Lk, +vs: List<&2, V>, +al: List<&2, U32>, +cs: List<&2, Cn>, +cur: U32, +st: U32, +ch: U32, +ins: U32, +iv: U32, +note: U32, +mk: U32, +vol: U32) -> Dr:
  match fr:
    case +id <> rest:
      +cn = cget(cs, ch)
      +nt = Bool.pick(U32, U32.is_eq((gb(lk, ins, 0) .&. 1 : U32), 1), gb(lk, ins, 3), note)
      +v = freq.set(lk, note.set0(volume(lk, instr(lk, note.set(vget(vs, id), ch, mk, nt), ins, iv, cn.pan(cn)), vol, cn.vol(cn))), cn.bend(cn))
      Dr{vset(vs, id, v), rest, List.append(&2, U32, al, [id]), cs, cur, st}
    case []:
      Dr{vs, [], al, cs, cur, st}

def voice.on(+lk: Lk, +d: Dr, +ch: U32, +ins: U32, +iv: U32, +note: U32, +mk: U32, +vol: U32) -> Dr:
  match d:
    case Dr{+vs, fr, +al, +cs, +cur, +st}:
      voice.take(fr, lk, vs, al, cs, cur, st, ch, ins, iv, note, mk, vol)

def dr.free(+d: Dr) -> Bool:
  match d:
    case Dr{vs, +fr, al, cs, cur, st}:
      U32.is_ne(T.len(U32, fr), 0)

def dr.cn(+d: Dr, +ch: U32) -> Cn:
  match d:
    case Dr{vs, fr, al, +cs, cur, st}:
      cget(cs, ch)

def need(free: Bool, +d: Dr) -> Dr:
  match free:
    case True{}:
      d
    case False{}:
      replace(d)

def two(dbl: Bool, +lk: Lk, +d: Dr, +ch: U32, +ins: U32, +note: U32, +mk: U32, +vol: U32) -> Dr:
  match dbl:
    case True{}:
      voice.on(lk, d, ch, ins, 1, note, mk, vol)
    case False{}:
      d

def note.on(ok: Bool, +lk: Lk, +d: Dr, +ch: U32, +ins: U32, +note: U32, +mk: U32, +vol: U32) -> Dr:
  match ok:
    case True{}:
      two(U32.is_eq((gb(lk, ins, 0) .&. 4 : U32), 4), lk, voice.on(lk, need(dr.free(d), d), ch, ins, 0, note, mk, vol), ch, ins, note, mk, vol)
    case False{}:
      d

def vols.go(vs: List<&2, V>, +lk: Lk, +ch: U32, +vol: U32, acc: List<&2, V>) -> List<&2, V>:
  match vs:
    case +v <> t:
      vols.go(t, lk, ch, vol, Bool.pick(V, U32.is_eq(v.ch(v), ch), volume(lk, v, v.nvol(v), vol), v) <> acc)
    case []:
      List.reverse(&2, V, acc)

def vols(vs: List<&2, V>, +lk: Lk, +ch: U32, +vol: U32) -> List<&2, V>:
  vols.go(vs, lk, ch, vol, [])

def chvol(+lk: Lk, +d: Dr, +ch: U32, +b: U32, +clip: Bool) -> Dr:
  match d:
    case Dr{+vs, +fr, +al, +cs, +cur, +st}:
      +c = cget(cs, ch)
      +v = U32.min(U32.min(b, cur), Bool.pick(U32, clip, st, 4294967295))
      Dr{vols(vs, lk, ch, v), fr, al, cset(cs, ch, Cn{cn.ins(c), v, b, cn.bend(c), cn.pan(c)}), cur, st}

def prog(+d: Dr, +ch: U32, +a: U32) -> Dr:
  match d:
    case Dr{+vs, +fr, +al, +cs, +cur, +st}:
      +c = cget(cs, ch)
      Dr{vs, fr, al, cset(cs, ch, Cn{a, cn.vol(c), cn.base(c), cn.bend(c), cn.pan(c)}), cur, st}

def bends(ids: List<&2, U32>, +lk: Lk, +vs: List<&2, V>, +bend: U32) -> List<&2, V>:
  match ids:
    case +i <> t:
      bends(t, lk, vset(vs, i, freq.set(lk, vget(vs, i), bend)), bend)
    case []:
      vs

def pitch(+lk: Lk, +d: Dr, +ch: U32, +b: U32) -> Dr:
  match d:
    case Dr{+vs, +fr, +al, +cs, +cur, +st}:
      +c = cget(cs, ch)
      +bend = (b - 64 : U32)
      +g = gone(vs, al, ch, True{}, 0)
      Dr{bends(g, lk, vs, bend), fr, List.append(&2, U32, keep(vs, al, ch, True{}, 0), g), cset(cs, ch, Cn{cn.ins(c), cn.vol(c), cn.base(c), bend, cn.pan(c)}), cur, st}

def v.pan(+lk: Lk, +v: V, +ch: U32, +pan: U32) -> V:
  match v:
    case V{+ins, +iv, +vch, +mk, +note, +freq, +nvol, +carv, +modv, +a0, +b0, +c0, +m, +c, +sm, +sc, +pr}:
      +nc = (gb(lk, ins, (4 + iv * 16 + 6 : U32)) .|. pan : U32)
      V{ins, iv, vch, mk, note, freq, nvol, carv, modv, a0, b0, Bool.pick(U32, U32.is_eq(vch, ch), nc, c0), m, c, sm, sc, pr}

def pans.go(vs: List<&2, V>, +lk: Lk, +ch: U32, +pan: U32, acc: List<&2, V>) -> List<&2, V>:
  match vs:
    case +v <> t:
      pans.go(t, lk, ch, pan, v.pan(lk, v, ch, pan) <> acc)
    case []:
      List.reverse(&2, V, acc)

def pans(vs: List<&2, V>, +lk: Lk, +ch: U32, +pan: U32) -> List<&2, V>:
  pans.go(vs, lk, ch, pan, [])

def regpan(+b: U32) -> U32:
  Bool.pick(U32, U32.is_ge(b, 96), 16, Bool.pick(U32, U32.is_le(b, 48), 32, 48))

def chpan.go(same: Bool, +lk: Lk, +d: Dr, +ch: U32, +rp: U32) -> Dr:
  match same d:
    case False{} Dr{+vs, +fr, +al, +cs, +cur, +st}:
      +c = cget(cs, ch)
      Dr{pans(vs, lk, ch, rp), fr, al, cset(cs, ch, Cn{cn.ins(c), cn.vol(c), cn.base(c), cn.bend(c), rp}), cur, st}
    case _ e:
      e

def chpan(+lk: Lk, +d: Dr, +ch: U32, +b: U32) -> Dr:
  +rp = regpan(b)
  chpan.go(Bool.or(U32.is_eq(o3(lk), 0), U32.is_eq(cn.pan(dr.cn(d, ch)), rp)), lk, d, ch, rp)

def chans.go(n: Nat, +cur: U32, acc: List<&2, Cn>) -> List<&2, Cn>:
  match n:
    case 0n:
      List.reverse(&2, Cn, acc)
    case 1n+p:
      chans.go(p, cur, Cn{0, U32.min(cur, 100), 100, 0, 48} <> acc)

def chans(n: Nat, +cur: U32) -> List<&2, Cn>:
  chans.go(n, cur, [])

def restart(+d: Dr) -> Dr:
  match d:
    case Dr{+vs, +fr, +al, cs, +cur, st}:
      Dr{vs, fr, al, chans(16n, cur), cur, cur}

def dr.cur(+d: Dr) -> U32:
  match d:
    case Dr{vs, fr, al, cs, +cur, st}:
      cur

def dr.withcur(+d: Dr, +v: U32) -> Dr:
  match d:
    case Dr{+vs, +fr, +al, +cs, cur, +st}:
      Dr{vs, fr, al, cs, v, st}

def setvol.go(n: Nat, +lk: Lk, +d: Dr, +i: U32) -> Dr:
  match n:
    case 0n:
      d
    case 1n+p:
      +b = Bool.pick(U32, U32.is_eq(i, 15), dr.cur(d), cn.base(dr.cn(d, i)))
      setvol.go(p, lk, chvol(lk, d, i, b, False{}), (i + 1 : U32))

def setvol.pick(same: Bool, +lk: Lk, +d: Dr, +v: U32) -> Dr:
  match same:
    case True{}:
      d
    case False{}:
      setvol.go(16n, lk, dr.withcur(d, v), 0)

def setvol(+lk: Lk, +d: Dr, +v: U32) -> Dr:
  setvol.pick(U32.is_eq(v, dr.cur(d)), lk, d, v)

def chan.of(+mc: U32) -> U32:
  Bool.pick(U32, U32.is_eq(mc, 9), 15, Bool.pick(U32, U32.is_eq(mc, 15), 9, mc))

def ev.on(+lk: Lk, +d: Dr, +mc: U32, +a: U32, +b: U32) -> Dr:
  +ch = chan.of(mc)
  +perc = U32.is_eq(mc, 9)
  +ok = Bool.or(Bool.not(perc), Bool.and(U32.is_ge(a, 35), U32.is_le(a, 81)))
  +ins = Bool.pick(U32, perc, (a + 93 : U32), cn.ins(dr.cn(d, ch)))
  note.on(ok, lk, d, ch, ins, Bool.pick(U32, perc, 60, a), a, b)

def ev.p(pn: Bool, +lk: Lk, +d: Dr, +ch: U32, +b: U32) -> Dr:
  match pn:
    case True{}:
      chpan(lk, d, ch, b)
    case False{}:
      d

def ev.f(f: Bool, pn: Bool, +lk: Lk, +d: Dr, +ch: U32, +a: U32, +b: U32) -> Dr:
  match f:
    case True{}:
      pitch(lk, d, ch, b)
    case False{}:
      ev.p(pn, lk, d, ch, b)

def ev.e(e: Bool, f: Bool, pn: Bool, +lk: Lk, +d: Dr, +ch: U32, +a: U32, +b: U32) -> Dr:
  match e:
    case True{}:
      prog(d, ch, a)
    case False{}:
      ev.f(f, pn, lk, d, ch, a, b)

def ev.d(c: Bool, e: Bool, f: Bool, pn: Bool, +lk: Lk, +d: Dr, +ch: U32, +a: U32, +b: U32) -> Dr:
  match c:
    case True{}:
      release(d, ch, True{}, 0)
    case False{}:
      ev.e(e, f, pn, lk, d, ch, a, b)

def ev.c(c: Bool, d7: Bool, e: Bool, f: Bool, pn: Bool, +lk: Lk, +d: Dr, +ch: U32, +a: U32, +b: U32) -> Dr:
  match d7:
    case True{}:
      chvol(lk, d, ch, b, True{})
    case False{}:
      ev.d(c, e, f, pn, lk, d, ch, a, b)

def ev.b(on: Bool, c: Bool, d7: Bool, e: Bool, f: Bool, pn: Bool, +lk: Lk, +d: Dr, +mc: U32, +a: U32, +b: U32) -> Dr:
  match on:
    case True{}:
      ev.on(lk, d, mc, a, b)
    case False{}:
      ev.c(c, d7, e, f, pn, lk, d, chan.of(mc), a, b)

def ev.a(off: Bool, on: Bool, c: Bool, d7: Bool, e: Bool, f: Bool, pn: Bool, +lk: Lk, +d: Dr, +mc: U32, +a: U32, +b: U32) -> Dr:
  match off:
    case True{}:
      release(d, chan.of(mc), False{}, a)
    case False{}:
      ev.b(on, c, d7, e, f, pn, lk, d, mc, a, b)

def ev(+lk: Lk, +d: Dr, +x: U32) -> Dr:
  +st = (x >> 16n : U32)
  +hi = (st .&. 240 : U32)
  +a = ((x >> 8n) .&. 255 : U32)
  +b = (x .&. 255 : U32)
  +cc = U32.is_eq(hi, 176)
  ev.a(Bool.or(U32.is_eq(hi, 128), Bool.and(U32.is_eq(hi, 144), U32.is_eq(b, 0))), U32.is_eq(hi, 144), Bool.and(cc, U32.is_eq(a, 123)), Bool.and(cc, U32.is_eq(a, 7)), U32.is_eq(hi, 192), U32.is_eq(hi, 224), Bool.and(cc, U32.is_eq(a, 10)), lk, d, (st .&. 15 : U32), a, b)

type Tm is Data:
  Tm{w: U32, f: U32}

def tm.w(+t: Tm) -> U32:
  match t:
    case Tm{+w, f}:
      w

def addt?(+t: Tm, +ticks: U32, +spt: U32) -> Tm:
  match t:
    case Tm{+w, +f}:
      +c = U32.min(ticks, 4096)
      +a = ((spt .&. 65535) * c : U32)
      +f1 = (f + (a .&. 65535) : U32)
      +w2 = (w + (spt >> 16n) * c + (a >> 16n) + (f1 >> 16n) : U32)
      addt.more(U32.is_gt(ticks, 4096), Tm{w2, (f1 .&. 65535 : U32)}, (ticks - c : U32), spt)

def addt.more?(more: Bool, +t: Tm, +ticks: U32, +spt: U32) -> Tm:
  match more:
    case True{}:
      addt(t, ticks, spt)
    case False{}:
      t

def spt(+upb: U32, +div: U32) -> U32:
  +a = ((upb * 441) / 625 : U32)
  ((a / div) * 1024 + ((a % div) * 1024) / div : U32)

def by(+bs: T.Vec<U32>, +p: U32) -> U32:
  T.get(U32, bs, p, 0)

def var.go(n: Nat, +bs: T.Vec<U32>, +p: U32, +v: U32) -> U32 & U32:
  match n:
    case 0n:
      (v, p)
    case 1n+k:
      +b = by(bs, p)
      +v1 = ((v << 7n) .|. (b .&. 127) : U32)
      Bool.pick(U32 & U32, U32.is_ge(b, 128), var.go(k, bs, (p + 1 : U32), v1), (v1, (p + 1 : U32)))

def var(+bs: T.Vec<U32>, +p: U32) -> U32 & U32:
  var.go(4n, bs, p, 0)

def pack(+st: U32, +a: U32, +b: U32) -> U32:
  ((st << 16n) .|. (a << 8n) .|. b : U32)

def tr?(+bs: T.Vec<U32>, +q: U32, +e: U32, +tick: U32, +run: U32, evs: List<&2, E>, tps: List<&2, E>) -> (List<&2, E> & List<&2, E>) & U32:
  tr.go(U32.is_ge(q, e), bs, q, e, tick, run, evs, tps)

def tr.go?(stop: Bool, +bs: T.Vec<U32>, +q: U32, +e: U32, +tick: U32, +run: U32, evs: List<&2, E>, tps: List<&2, E>) -> (List<&2, E> & List<&2, E>) & U32:
  match stop:
    case True{}:
      ((evs, tps), tick)
    case False{}:
      tr.dt(var(bs, q), bs, e, tick, run, evs, tps)

def tr.dt?(r: U32 & U32, +bs: T.Vec<U32>, +e: U32, +tick: U32, +run: U32, evs: List<&2, E>, tps: List<&2, E>) -> (List<&2, E> & List<&2, E>) & U32:
  (+d, +q) = r
  +b = by(bs, q)
  tr.kind(U32.is_eq(b, 255), Bool.or(U32.is_eq(b, 240), U32.is_eq(b, 247)), bs, q, e, (tick + d : U32), run, evs, tps)

def tr.kind?(meta: Bool, sys: Bool, +bs: T.Vec<U32>, +q: U32, +e: U32, +tick: U32, +run: U32, evs: List<&2, E>, tps: List<&2, E>) -> (List<&2, E> & List<&2, E>) & U32:
  match meta sys:
    case True{} _:
      tr.meta(var(bs, (q + 2 : U32)), by(bs, (q + 1 : U32)), bs, e, tick, run, evs, tps)
    case False{} True{}:
      tr.skip(var(bs, (q + 1 : U32)), bs, e, tick, run, evs, tps)
    case False{} False{}:
      +b = by(bs, q)
      +st = Bool.pick(U32, U32.is_ge(b, 128), b, run)
      +qa = Bool.pick(U32, U32.is_ge(b, 128), (q + 1 : U32), q)
      +hi = (st .&. 240 : U32)
      +two = Bool.and(U32.is_ne(hi, 192), U32.is_ne(hi, 208))
      +c = Bool.pick(U32, two, by(bs, (qa + 1 : U32)), 0)
      tr(bs, (qa + Bool.pick(U32, two, 2, 1) : U32), e, tick, st, E{tick, pack(st, by(bs, qa), c)} <> evs, tps)

def tr.skip?(r: U32 & U32, +bs: T.Vec<U32>, +e: U32, +tick: U32, +run: U32, evs: List<&2, E>, tps: List<&2, E>) -> (List<&2, E> & List<&2, E>) & U32:
  (+l, +q) = r
  tr(bs, (q + l : U32), e, tick, run, evs, tps)

def tr.meta?(r: U32 & U32, +ty: U32, +bs: T.Vec<U32>, +e: U32, +tick: U32, +run: U32, evs: List<&2, E>, +tps: List<&2, E>) -> (List<&2, E> & List<&2, E>) & U32:
  (+l, +q) = r
  +tps1 = Bool.pick(List<&2, E>, U32.is_eq(ty, 81), E{tick, ((by(bs, q) << 16n) .|. (by(bs, (q + 1 : U32)) << 8n) .|. by(bs, (q + 2 : U32)) : U32)} <> tps, tps)
  tr.end(U32.is_eq(ty, 47), bs, (q + l : U32), e, tick, run, evs, tps1)

def tr.end?(fin: Bool, +bs: T.Vec<U32>, +q: U32, +e: U32, +tick: U32, +run: U32, evs: List<&2, E>, tps: List<&2, E>) -> (List<&2, E> & List<&2, E>) & U32:
  match fin:
    case True{}:
      ((evs, tps), tick)
    case False{}:
      tr(bs, q, e, tick, run, evs, tps)

def be32(+bs: T.Vec<U32>, +p: U32) -> U32:
  ((by(bs, p) << 24n) .|. (by(bs, (p + 1 : U32)) << 16n) .|. (by(bs, (p + 2 : U32)) << 8n) .|. by(bs, (p + 3 : U32)) : U32)

def rev(xs: List<&2, E>, acc: List<&2, E>) -> List<&2, E>:
  match xs:
    case x <> t:
      rev(t, x <> acc)
    case []:
      acc

type Tk is Data:
  Tk{evs: List<&2, E>, tps: List<&2, E>, end: U32}

def tracks.next?(n: Nat, +bs: T.Vec<U32>, +p: U32, +e: U32, r: (List<&2, E> & List<&2, E>) & U32, ks: List<&2, List<&2, E>>, tps: List<&2, E>, +endt: U32) -> Tk & List<&2, List<&2, E>>:
  (q, +tick) = r
  (evs, tp) = q
  tracks(n, bs, e, List.append(&2, List<&2, E>, ks, [rev(evs, [])]), List.append(&2, E, tps, rev(tp, [])), U32.max(endt, tick))

def tracks?(n: Nat, +bs: T.Vec<U32>, +p: U32, ks: List<&2, List<&2, E>>, tps: List<&2, E>, +endt: U32) -> Tk & List<&2, List<&2, E>>:
  match n:
    case 0n:
      (Tk{[], tps, endt}, ks)
    case 1n+k:
      +len = be32(bs, (p + 4 : U32))
      tracks.next(k, bs, p, (p + 8 + len : U32), tr(bs, (p + 8 : U32), (p + 8 + len : U32), 0, 0, [], []), ks, tps, endt)

def e.t(+x: E) -> U32:
  match x:
    case E{+t, v}:
      t

def e.v(+x: E) -> U32:
  match x:
    case E{t, +v}:
      v

def ins.tp(+x: E, ys: List<&2, E>) -> List<&2, E>:
  match ys:
    case +y <> +yt:
      Bool.pick(List<&2, E>, U32.is_lt(e.t(x), e.t(y)), x <> y <> yt, y <> ins.tp(x, yt))
    case []:
      [x]

def isort(xs: List<&2, E>, acc: List<&2, E>) -> List<&2, E>:
  match xs:
    case +x <> t:
      isort(t, ins.tp(x, acc))
    case []:
      acc

def tp.due(+tps: List<&2, E>, +tick: U32) -> Bool:
  match tps:
    case +x <> t:
      U32.is_le(e.t(x), tick)
    case []:
      False{}

def conv.run?(evs: List<&2, E>, +tps: List<&2, E>, +div: U32, +t: Tm, +last: U32, +upb: U32, acc: List<&2, E>) -> List<&2, E>:
  match evs:
    case E{+tick, +v} <> rest:
      conv.go(tp.due(tps, tick), tick, v, rest, tps, div, t, last, upb, acc)
    case []:
      List.reverse(&2, E, acc)

def conv.go?(due: Bool, +tick: U32, +v: U32, rest: List<&2, E>, +tps: List<&2, E>, +div: U32, +t: Tm, +last: U32, +upb: U32, acc: List<&2, E>) -> List<&2, E>:
  match due:
    case True{}:
      conv.adv(tps, tick, v, rest, div, t, last, upb, acc)
    case False{}:
      conv.run(rest, tps, div, t, last, upb, E{tm.w(addt(t, (tick - last : U32), spt(upb, div))), v} <> acc)

def conv.adv?(+tps: List<&2, E>, +tick: U32, +v: U32, rest: List<&2, E>, +div: U32, +t: Tm, +last: U32, +upb: U32, acc: List<&2, E>) -> List<&2, E>:
  match tps:
    case +x <> tt:
      conv.run(E{tick, v} <> rest, tt, div, addt(t, (e.t(x) - last : U32), spt(upb, div)), e.t(x), e.v(x), acc)
    case []:
      conv.run(E{tick, v} <> rest, [], div, t, last, upb, acc)

def conv(evs: List<&2, E>, +tps: List<&2, E>, +div: U32, +t: Tm, +last: U32, +upb: U32) -> List<&2, E>:
  conv.run(evs, tps, div, t, last, upb, [])

def merge.run?(xs: List<&2, E>, ys: List<&2, E>, acc: List<&2, E>) -> List<&2, E>:
  match xs ys:
    case +x <> xt +y <> yt:
      merge.pick(U32.is_lt(e.t(y), e.t(x)), x, xt, y, yt, acc)
    case [] b:
      T.onto(E, acc, b)
    case a _:
      T.onto(E, acc, a)

def merge.pick?(ylt: Bool, +x: E, xt: List<&2, E>, +y: E, yt: List<&2, E>, acc: List<&2, E>) -> List<&2, E>:
  match ylt:
    case True{}:
      merge.run(x <> xt, yt, y <> acc)
    case False{}:
      merge.run(xt, y <> yt, x <> acc)

def merge(xs: List<&2, E>, ys: List<&2, E>) -> List<&2, E>:
  merge.run(xs, ys, [])

def merges?(ks: List<&2, List<&2, E>>, +tps: List<&2, E>, +div: U32, acc: List<&2, E>) -> List<&2, E>:
  match ks:
    case k <> t:
      merges(t, tps, div, merge(acc, conv(k, tps, div, Tm{0, 0}, 0, 500000)))
    case []:
      acc

def first(xs: List<&2, E>) -> U32:
  match xs:
    case +x <> t:
      e.t(x)
    case []:
      0

def endt(+tps: List<&2, E>, +div: U32, +tick: U32) -> U32:
  first(conv([E{tick, 0}], tps, div, Tm{0, 0}, 0, 500000))

def midi.tk(+tk: Tk, ks: List<&2, List<&2, E>>, +bs: T.Vec<U32>, +div: U32) -> List<&2, E> & U32:
  match tk:
    case Tk{x, +tps, +end}:
      +sorted = isort(tps, [])
      (merges(ks, sorted, div, []), endt(sorted, div, end))

def midi.go(+bs: T.Vec<U32>, +div: U32, r: Tk & List<&2, List<&2, E>>) -> List<&2, E> & U32:
  (tk, ks) = r
  midi.tk(tk, ks, bs, div)

def midi(+bs: T.Vec<U32>) -> List<&2, E> & U32:
  +ntr = ((by(bs, 10) << 8n) .|. by(bs, 11) : U32)
  +div = U32.max(((by(bs, 12) << 8n) .|. by(bs, 13) : U32), 1)
  midi.go(bs, div, tracks(U32.to_nat(ntr), bs, 14, [], [], 0))

def l16get(+xs: List<&2, U32>, +i: U32) -> U32:
  lget(xs, i)

def lset(+xs: List<&2, U32>, +i: U32, +v: U32) -> List<&2, U32>:
  match xs:
    case +x <> +t:
      Bool.pick(List<&2, U32>, U32.is_eq(i, 0), v <> t, x <> lset(t, (i - 1 : U32), v))
    case []:
      []

def lmax(xs: List<&2, U32>, +m: U32) -> U32:
  match xs:
    case +x <> t:
      lmax(t, Bool.pick(U32, Bool.and(U32.is_ne(x, none()), Bool.or(U32.is_eq(m, none()), U32.is_gt(x, m))), x, m))
    case []:
      m

def nones.go(n: Nat, +v: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      nones.go(p, v, v <> acc)

def nones(n: Nat, +v: U32) -> List<&2, U32>:
  nones.go(n, v, [])

def mus.alloc(+map: List<&2, U32>) -> U32:
  +r = (lmax(map, none()) + 1 : U32)
  Bool.pick(U32, U32.is_eq(r, 9), 10, r)

def mus.ev(+ty: U32, +ch: U32, +mc: U32, +bs: T.Vec<U32>, +p: U32, +w: U32, +vel: List<&2, U32>) -> List<&2, E>:
  +k = by(bs, p)
  +v = by(bs, (p + 1 : U32))
  +nv = Bool.pick(U32, U32.is_ge(k, 128), (v .&. 127 : U32), lget(vel, mc))
  +kw = (k * 64 : U32)
  +cv = Bool.pick(U32, U32.is_ge(v, 128), 127, v)
  Bool.pick(List<&2, E>, U32.is_eq(ty, 0), [E{w, pack((128 .|. ch : U32), (k .&. 127 : U32), 0)}],
    Bool.pick(List<&2, E>, U32.is_eq(ty, 1), [E{w, pack((144 .|. ch : U32), (k .&. 127 : U32), nv)}],
      Bool.pick(List<&2, E>, U32.is_eq(ty, 2), [E{w, pack((224 .|. ch : U32), (kw .&. 127 : U32), ((kw >> 7n) .&. 127 : U32))}],
        Bool.pick(List<&2, E>, Bool.and(U32.is_eq(ty, 3), Bool.and(U32.is_ge(k, 10), U32.is_le(k, 14))), [E{w, pack((176 .|. ch : U32), T.get(U32, T.from_list(U32, [120, 123, 126, 127, 121]), (k - 10 : U32), 0), 0)}],
          Bool.pick(List<&2, E>, U32.is_eq(ty, 4), Bool.pick(List<&2, E>, U32.is_eq(k, 0), [E{w, pack((192 .|. ch : U32), cv, 0)}],
            Bool.pick(List<&2, E>, U32.is_le(k, 9), [E{w, pack((176 .|. ch : U32), T.get(U32, T.from_list(U32, [0, 0, 1, 7, 10, 11, 91, 93, 64, 67]), k, 0), cv)}], [])), [])))))

def mus.len(+ty: U32, +k: U32) -> U32:
  Bool.pick(U32, U32.is_eq(ty, 1), Bool.pick(U32, U32.is_ge(k, 128), 2, 1), Bool.pick(U32, U32.is_eq(ty, 4), 2, Bool.pick(U32, Bool.or(U32.is_eq(ty, 0), Bool.or(U32.is_eq(ty, 2), U32.is_eq(ty, 3))), 1, 0)))

def mus.cat(xs: List<&2, E>, acc: List<&2, E>) -> List<&2, E>:
  match xs:
    case x <> t:
      mus.cat(t, x <> acc)
    case []:
      acc

def mus?(+bs: T.Vec<U32>, +p: U32, +n: U32, +t: Tm, +map: List<&2, U32>, +vel: List<&2, U32>, evs: List<&2, E>) -> List<&2, E> & U32:
  +b = by(bs, p)
  mus.go(Bool.or(U32.is_ge(p, n), U32.is_eq(((b >> 4n) .&. 7 : U32), 6)), bs, p, n, t, map, vel, evs)

def mus.go?(stop: Bool, +bs: T.Vec<U32>, +p: U32, +n: U32, +t: Tm, +map: List<&2, U32>, +vel: List<&2, U32>, +evs: List<&2, E>) -> List<&2, E> & U32:
  match stop:
    case True{}:
      (rev(evs, []), tm.w(t))
    case False{}:
      +b = by(bs, p)
      +ty = ((b >> 4n) .&. 7 : U32)
      +mc = (b .&. 15 : U32)
      +fresh = Bool.and(U32.is_ne(mc, 15), U32.is_eq(lget(map, mc), none()))
      +map1 = Bool.pick(List<&2, U32>, fresh, lset(map, mc, mus.alloc(map)), map)
      +ch = Bool.pick(U32, U32.is_eq(mc, 15), 9, lget(map1, mc))
      +w = tm.w(t)
      +evs1 = Bool.pick(List<&2, E>, fresh, E{w, pack((176 .|. ch : U32), 123, 0)} <> evs, evs)
      +k = by(bs, (p + 1 : U32))
      +vel1 = Bool.pick(List<&2, U32>, Bool.and(U32.is_eq(ty, 1), U32.is_ge(k, 128)), lset(vel, mc, (by(bs, (p + 2 : U32)) .&. 127 : U32)), vel)
      +evs2 = mus.cat(mus.ev(ty, ch, mc, bs, (p + 1 : U32), w, vel), evs1)
      +q = (p + 1 + mus.len(ty, k) : U32)
      mus.delay(U32.is_ge(b, 128), bs, q, n, t, map1, vel1, evs2)

def mus.delay?(last: Bool, +bs: T.Vec<U32>, +q: U32, +n: U32, +t: Tm, +map: List<&2, U32>, +vel: List<&2, U32>, evs: List<&2, E>) -> List<&2, E> & U32:
  match last:
    case True{}:
      mus.after(var.mus(bs, q), bs, n, t, map, vel, evs)
    case False{}:
      mus(bs, q, n, t, map, vel, evs)

def mus.after?(r: U32 & U32, +bs: T.Vec<U32>, +n: U32, +t: Tm, +map: List<&2, U32>, +vel: List<&2, U32>, evs: List<&2, E>) -> List<&2, E> & U32:
  (+d, +q) = r
  mus(bs, q, n, addt(t, d, 5160960), map, vel, evs)

def var.mus(+bs: T.Vec<U32>, +p: U32) -> U32 & U32:
  var.go(5n, bs, p, 0)

def song.pick(ismus: Bool, ismidi: Bool, +bs: T.Vec<U32>) -> List<&2, E> & U32:
  match ismus ismidi:
    case True{} _:
      mus(bs, (by(bs, 6) + 256 * by(bs, 7) : U32), T.size(U32, bs), Tm{0, 0}, nones(16n, none()), nones(16n, 127), [])
    case False{} True{}:
      midi(bs)
    case False{} False{}:
      ([], 0)

def song(+bs: T.Vec<U32>) -> List<&2, E> & U32:
  +m = by(bs, 0)
  +ismidi = Bool.and(U32.is_eq(m, 77), U32.is_eq(by(bs, 1), 84))
  +ismus = Bool.and(U32.is_eq(m, 77), Bool.and(U32.is_eq(by(bs, 1), 85), U32.is_eq(by(bs, 3), 26)))
  song.pick(ismus, ismidi, bs)

type Sq is Data:
  Sq{dr: Dr, evs: List<&2, E>, all: List<&2, E>, lp: U32, end: U32, base: U32, now: U32, clk: U32, cfr: U32, gs: Y.Syn}

def empty(+evs: List<&2, E>) -> Bool:
  match evs:
    case x <> t:
      False{}
    case []:
      True{}

def due(+evs: List<&2, E>, +base: U32, +now: U32) -> Bool:
  match evs:
    case +x <> t:
      U32.is_le((e.t(x) + base : U32), now)
    case []:
      False{}

def again(+sq: Sq) -> Bool:
  match sq:
    case Sq{dr, +evs, all, +lp, +end, +base, +now, clk, cfr, gs}:
      Bool.and(empty(evs), Bool.and(U32.is_eq(lp, 1), U32.is_le((base + end + 55 : U32), now)))

def drain?(+lk: Lk, +sq: Sq) -> Sq:
  match sq:
    case Sq{+dr, +evs, +all, +lp, +end, +base, +now, +clk, +cfr, +gs}:
      drain.go(due(evs, base, now), again(sq), lk, dr, evs, all, lp, end, base, now, clk, cfr, gs)

def drain.go?(d: Bool, r: Bool, +lk: Lk, +dr: Dr, evs: List<&2, E>, +all: List<&2, E>, +lp: U32, +end: U32, +base: U32, +now: U32, +clk: U32, +cfr: U32, +gs: Y.Syn) -> Sq:
  match d r evs:
    case True{} _ +x <> t:
      drain(lk, Sq{ev(lk, dr, e.v(x)), t, all, lp, end, base, now, clk, cfr, Y.ev(lps(lk), gs, e.v(x))})
    case False{} True{} xs:
      drain(lk, Sq{restart(dr), all, all, lp, end, now, now, clk, cfr, Y.restart(lps(lk), gs)})
    case _ _ xs:
      Sq{dr, xs, all, lp, end, base, now, clk, cfr, gs}

def bound(+sq: Sq, +n: U32) -> U32:
  match sq:
    case Sq{dr, +evs, all, +lp, +end, +base, +now, clk, cfr, gs}:
      +lim = (now + n : U32)
      +ne = Bool.pick(U32, empty(evs), Bool.pick(U32, U32.is_eq(lp, 1), (base + end + 55 : U32), lim), (first(evs) + base : U32))
      (U32.min(lim, ne) - now : U32)

def dr.vs(+d: Dr) -> List<&2, V>:
  match d:
    case Dr{+vs, fr, al, cs, cur, st}:
      vs

def sq.vs(+sq: Sq) -> List<&2, V>:
  match sq:
    case Sq{+dr, evs, all, lp, end, base, now, clk, cfr, gs}:
      dr.vs(dr)

def dr.setvs(+d: Dr, vs: List<&2, V>) -> Dr:
  match d:
    case Dr{ovs, +fr, +al, +cs, +cur, +st}:
      Dr{vs, fr, al, cs, cur, st}

def sq.clock(+sq: Sq, c: U32 & U32) -> Sq:
  match sq:
    case Sq{+dr, +evs, +all, +lp, +end, +base, +now, clk, cfr, +gs}:
      (+a, +b) = c
      Sq{dr, evs, all, lp, end, base, now, a, b, gs}

def sq.ran(+sq: Sq, +k: U32, vs: List<&2, V>) -> Sq:
  match sq:
    case Sq{+dr, +evs, +all, +lp, +end, +base, +now, +clk, +cfr, +gs}:
      sq.clock(Sq{dr.setvs(dr, vs), evs, all, lp, end, base, (now + k : U32), clk, cfr, gs}, clock.at(U32.to_nat(k), clk, cfr))

def sq.gs(+sq: Sq) -> Y.Syn:
  match sq:
    case Sq{dr, evs, all, lp, end, base, now, clk, cfr, +gs}:
      gs

def sq.gran(+sq: Sq, +k: U32, +gs: Y.Syn) -> Sq:
  match sq:
    case Sq{+dr, +evs, +all, +lp, +end, +base, +now, +clk, +cfr, g0}:
      Sq{dr, evs, all, lp, end, base, (now + k : U32), clk, cfr, gs}

def sq.ck(+sq: Sq, +k: U32) -> List<&2, U32>:
  match sq:
    case Sq{dr, evs, all, lp, end, base, now, +clk, +cfr, gs}:
      clocks(U32.to_nat(k), clk, cfr)

def run.seg?(+n: U32, +k: U32, +lk: Lk, +sq: Sq, out: List<&2, U32>, r: (List<&2, U32> & Array<U32>) & List<&2, V>) -> (Array<U32> & Sq) & List<&2, U32>:
  (p, vs) = r
  (acc, tb) = p
  run(tb, (n - k : U32), lk, sq.ran(sq, k, vs), List.append(&2, U32, out, acc))

def run?(tb: Array<U32>, +n: U32, +lk: Lk, +sq: Sq, out: List<&2, U32>) -> (Array<U32> & Sq) & List<&2, U32>:
  run.go(U32.is_eq(n, 0), tb, n, lk, drain(lk, sq), out)

def run.go?(stop: Bool, tb: Array<U32>, +n: U32, +lk: Lk, +sq: Sq, out: List<&2, U32>) -> (Array<U32> & Sq) & List<&2, U32>:
  match stop:
    case True{}:
      ((tb, sq), out)
    case False{}:
      +k = U32.max(bound(sq, n), 1)
      run.seg(n, k, lk, sq, out, seg(sq.vs(sq), o3(lk), zeros(U32.to_nat((k * (1 + o3(lk)) : U32))), tb, sq.ck(sq, k)))

def grun.seg2?(+n: U32, +k: U32, +lk: Lk, +sq: Sq, out: List<&2, U32>, acc: List<&2, U32>, p: Array<F32> & Y.Syn) -> (Array<F32> & Sq) & List<&2, U32>:
  (smp, +gs) = p
  grun(smp, (n - k : U32), lk, sq.gran(sq, k, gs), List.append(&2, U32, out, acc))

def grun.seg?(+n: U32, +k: U32, +lk: Lk, +sq: Sq, out: List<&2, U32>, r: (Array<F32> & Y.Syn) & List<&2, U32>) -> (Array<F32> & Sq) & List<&2, U32>:
  (p, acc) = r
  grun.seg2(n, k, lk, sq, out, acc, p)

def grun?(smp: Array<F32>, +n: U32, +lk: Lk, +sq: Sq, out: List<&2, U32>) -> (Array<F32> & Sq) & List<&2, U32>:
  grun.go(U32.is_eq(n, 0), smp, n, lk, drain(lk, sq), out)

def grun.go?(stop: Bool, smp: Array<F32>, +n: U32, +lk: Lk, +sq: Sq, out: List<&2, U32>) -> (Array<F32> & Sq) & List<&2, U32>:
  match stop:
    case True{}:
      ((smp, sq), out)
    case False{}:
      +k = U32.max(bound(sq, n), 1)
      grun.seg(n, k, lk, sq, out, Y.render(sq.gs(sq), smp, k))

type Mu is Type:
  Mu{tb: Array<U32>, lib: Array<U32>, ix: T.Vec<U32>, lk: Lk, sq: Sq, song: U32, last: U32, smp: Array<F32>}

def names() -> List<&2, String>:
  ["D_E1M1", "D_E1M2", "D_E1M3", "D_E1M4", "D_E1M5", "D_E1M6", "D_E1M7", "D_E1M8", "D_E1M9",
   "D_E2M1", "D_E2M2", "D_E2M3", "D_E2M4", "D_E2M5", "D_E2M6", "D_E2M7", "D_E2M8", "D_E2M9",
   "D_E3M1", "D_E3M2", "D_E3M3", "D_E3M4", "D_E3M5", "D_E3M6", "D_E3M7", "D_E3M8", "D_E3M9",
   "D_INTER", "D_INTRO", "D_BUNNY", "D_VICTOR", "D_INTROA",
   "D_RUNNIN", "D_STALKS", "D_COUNTD", "D_BETWEE", "D_DOOM", "D_THE_DA", "D_SHAWN", "D_DDTBLU",
   "D_IN_CIT", "D_DEAD", "D_STLKS2", "D_THEDA2", "D_DOOM2", "D_DDTBL2", "D_RUNNI2", "D_DEAD2",
   "D_STLKS3", "D_ROMERO", "D_SHAWN2", "D_MESSAG", "D_COUNT2", "D_DDTBL3", "D_AMPIE", "D_THEDA3",
   "D_ADRIAN", "D_MESSG2", "D_ROMER2", "D_TENSE", "D_SHAWN3", "D_OPENIN", "D_EVIL", "D_ULTIMA",
   "D_READ_M", "D_DM2TTL", "D_DM2INT"]

def spmus(+map: U32) -> U32:
  T.get(U32, T.from_list(U32, [22, 20, 21, 5, 16, 13, 15, 14, 9]), (map - 1 : U32), 0)

def level(+c: Bool, +ep: U32, +map: U32) -> U32:
  Bool.pick(U32, c, Bool.pick(U32, Bool.and(U32.is_ge(map, 1), U32.is_le(map, 32)), (32 + map : U32), 0),
    Bool.pick(U32, Bool.or(Bool.or(U32.is_lt(ep, 1), U32.is_gt(ep, 4)), Bool.or(U32.is_lt(map, 1), U32.is_gt(map, 9))), 0,
      Bool.pick(U32, U32.is_eq(ep, 4), spmus(map), ((ep - 1) * 9 + map : U32))))

def want(+g: S.Sim) -> U32:
  +gs = S.sim.gs(g)
  +c = U.com(g)
  +stage = U.ui(g, 50)
  +lv = level(c, S.mp.episode(g), S.mp.map(g))
  +fin = Bool.pick(U32, U32.is_eq(stage, 2), 127, Bool.pick(U32, c, 131, Bool.pick(U32, Bool.and(U32.is_eq(stage, 1), U32.is_eq(U.ui(g, 26), 3)), 60, 63)))
  +page = Bool.pick(U32, U32.is_eq(U.ui(g, 123), 247), Bool.pick(U32, c, 132, 58), 0)
  Bool.pick(U32, U32.is_eq(gs, 0), Bool.pick(U32, U32.is_eq(lv, 0), 0, (lv * 2 + 1 : U32)),
    Bool.pick(U32, U32.is_eq(gs, 1), Bool.pick(U32, c, 135, 57), Bool.pick(U32, U32.is_eq(gs, 2), fin, page)))

def take.go(n: Nat, a: Array<U32>, +i: U32, acc: List<&2, U32>) -> Array<U32> & List<&2, U32>:
  match n:
    case 0n:
      (a, List.reverse(&2, U32, acc))
    case 1n+p:
      M.let(Array<U32> & List<&2, U32>, M.rd(a, i), a1 => +v => take.go(p, a1, (i + 1 : U32), v <> acc))

def take(n: Nat, a: Array<U32>, +i: U32) -> Array<U32> & List<&2, U32>:
  take.go(n, a, i, [])

def offall(n: Nat, +d: Dr, +i: U32) -> Dr:
  match n:
    case 0n:
      d
    case 1n+p:
      offall(p, release(d, i, True{}, 0), (i + 1 : U32))

def sq.start(+lk: Lk, +sq: Sq, +lp: U32, r: List<&2, E> & U32) -> Sq:
  match sq:
    case Sq{+dr, evs, all, olp, end, base, +now, +clk, +cfr, +gs}:
      (+es, +e) = r
      +on = U32.is_ne(T.len(E, es), 0)
      Sq{restart(offall(16n, dr, 0)), es, es, Bool.pick(U32, on, lp, 0), e, now, now, clk, cfr, Y.restart(lps(lk), gs)}

def started(tb: Array<U32>, smp: Array<F32>, +ix: T.Vec<U32>, +lk: Lk, +sq: Sq, +id: U32, +lp: U32, +last: U32, r: Array<U32> & List<&2, U32>) -> Mu:
  (lib, +bs) = r
  Mu{tb, lib, ix, lk, sq.start(lk, sq, lp, song(T.from_list(U32, bs))), id, last, smp}

def start(m: Mu, +id: U32, +lp: U32) -> Mu:
  match m:
    case Mu{tb, lib, +ix, +lk, +sq, song, +last, smp}:
      +k = ((id - 1) * 2 : U32)
      started(tb, smp, ix, lk, sq, id, lp, last, take(U32.to_nat(T.get(U32, ix, (k + 1 : U32), 0)), lib, T.get(U32, ix, k, 0)))

def mu.song(m: Mu) -> Mu & U32:
  match m:
    case Mu{tb, lib, +ix, +lk, +sq, +song, +last, smp}:
      (Mu{tb, lib, ix, lk, sq, song, last, smp}, song)

def sq.vol(+lk: Lk, +sq: Sq, +v: U32) -> Sq:
  match sq:
    case Sq{+dr, +evs, +all, +lp, +end, +base, +now, +clk, +cfr, +gs}:
      Sq{setvol(lk, dr, v), evs, all, lp, end, base, now, clk, cfr, Y.syn.vol.set(gs, v)}

def mu.vol(m: Mu, +v: U32) -> Mu:
  match m:
    case Mu{tb, lib, +ix, +lk, +sq, +song, +last, smp}:
      Mu{tb, lib, ix, lk, sq.vol(lk, sq, v), song, last, smp}

def switch(go: Bool, m: Mu, +w: U32) -> Mu:
  match go:
    case True{}:
      start(m, (w >> 1n : U32), (w .&. 1 : U32))
    case False{}:
      m

def switched(+w: U32, r: Mu & U32) -> Mu:
  (m, +cur) = r
  switch(Bool.and(U32.is_ne(w, 0), U32.is_ne((w >> 1n : U32), cur)), m, w)

def tic(m: Mu, +g: S.Sim) -> Mu:
  switched(want(g), mu.song(mu.vol(m, (U.ui(g, 114) * 8 : U32))))

def clip(+x: U32) -> U32:
  +v = (x - bias() : U32)
  Bool.pick(U32, neg(v), U32.max(v, 4294934528), U32.min(v, 32767))

def frames.go(xs: List<&2, U32>, +last: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      +m = clip(x)
      +a = F.sar((last + m : U32), 1n)
      frames.go(t, m, m <> m <> a <> a <> acc)
    case []:
      List.reverse(&2, U32, acc)

def frames(xs: List<&2, U32>, +last: U32) -> List<&2, U32>:
  frames.go(xs, last, [])

def final(xs: List<&2, U32>, +last: U32) -> U32:
  match xs:
    case +x <> t:
      final(t, clip(x))
    case []:
      last

def frames2.go(xs: List<&2, U32>, +ll: U32, +lr: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> +y <> t:
      +ml = clip(x)
      +mr = clip(y)
      frames2.go(t, ml, mr, mr <> ml <> F.sar((lr + mr : U32), 1n) <> F.sar((ll + ml : U32), 1n) <> acc)
    case _:
      List.reverse(&2, U32, acc)

def frames2(xs: List<&2, U32>, +ll: U32, +lr: U32) -> List<&2, U32>:
  frames2.go(xs, ll, lr, [])

def final2(xs: List<&2, U32>, +last: U32) -> U32:
  match xs:
    case +x <> +y <> t:
      final2(t, ((clip(x) .&. 65535) .|. (clip(y) << 16n) : U32))
    case _:
      last

def frames.of(st2: Bool, xs: List<&2, U32>, +last: U32) -> List<&2, U32>:
  match st2:
    case False{}:
      frames(xs, last)
    case True{}:
      frames2(xs, sx((last .&. 65535 : U32)), sx((last >> 16n : U32)))

def final.of(st2: Bool, xs: List<&2, U32>, +last: U32) -> U32:
  match st2:
    case False{}:
      final(xs, last)
    case True{}:
      final2(xs, last)

def rendered2(+ix: T.Vec<U32>, +lk: Lk, lib: Array<U32>, smp: Array<F32>, +song: U32, +last: U32, p: Array<U32> & Sq, +out: List<&2, U32>) -> Mu & List<&2, U32>:
  (tb, +sq) = p
  (Mu{tb, lib, ix, lk, sq, song, final.of(U32.is_eq(o3(lk), 1), out, last), smp}, frames.of(U32.is_eq(o3(lk), 1), out, last))

def rendered(+ix: T.Vec<U32>, +lk: Lk, lib: Array<U32>, smp: Array<F32>, +song: U32, +last: U32, r: (Array<U32> & Sq) & List<&2, U32>) -> Mu & List<&2, U32>:
  (p, +out) = r
  rendered2(ix, lk, lib, smp, song, last, p, out)

def grendered2(tb: Array<U32>, +ix: T.Vec<U32>, +lk: Lk, lib: Array<U32>, +song: U32, +last: U32, +out: List<&2, U32>, p: Array<F32> & Sq) -> Mu & List<&2, U32>:
  (smp, +sq) = p
  (Mu{tb, lib, ix, lk, sq, song, last, smp}, out)

def grendered(tb: Array<U32>, +ix: T.Vec<U32>, +lk: Lk, lib: Array<U32>, +song: U32, +last: U32, r: (Array<F32> & Sq) & List<&2, U32>) -> Mu & List<&2, U32>:
  (p, +out) = r
  grendered2(tb, ix, lk, lib, song, last, out, p)

def render.pick(gm: Bool, tb: Array<U32>, lib: Array<U32>, smp: Array<F32>, +ix: T.Vec<U32>, +lk: Lk, +sq: Sq, +song: U32, +last: U32) -> Mu & List<&2, U32>:
  match gm:
    case True{}:
      grendered(tb, ix, lk, lib, song, last, grun(smp, 315, lk, sq, []))
    case False{}:
      rendered(ix, lk, lib, smp, song, last, run(tb, 315, lk, sq, []))

def render(m: Mu) -> Mu & List<&2, U32>:
  match m:
    case Mu{tb, lib, +ix, +lk, +sq, +song, +last, smp}:
      render.pick(isgm(lk), tb, lib, smp, ix, lk, sq, song, last)

def mt() -> List<&2, U32>:
  [1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 20, 24, 24, 30, 30]

def kslrom() -> List<&2, U32>:
  [0, 32, 40, 45, 48, 51, 53, 55, 56, 58, 59, 60, 61, 62, 63, 64]

def tables() -> Array<U32>:
  M.fill(T.flat(U32, [O.wave(), O.expo(), O.dec(), O.att(), kslrom(), mt(), O.wave2()]), Array.new(U32, 14n, 0), 0)

def ids.go(n: Nat, +i: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      ids.go(p, (i + 1 : U32), i <> acc)

def ids(n: Nat, +i: U32) -> List<&2, U32>:
  ids.go(n, i, [])

def novs.go(n: Nat, acc: List<&2, V>) -> List<&2, V>:
  match n:
    case 0n:
      List.reverse(&2, V, acc)
    case 1n+p:
      novs.go(p, nov() <> acc)

def novs(n: Nat) -> List<&2, V>:
  novs.go(n, [])

def driver(+cur: U32, +nv: U32) -> Dr:
  Dr{novs(U32.to_nat(nv)), ids(U32.to_nat(nv), 0), [], chans(16n, cur), cur, cur}

def idle(+o3: U32) -> Sq:
  Sq{driver(64, (9 + 9 * o3 : U32)), [], [], 0, 0, 0, 0, 0, 0, Y.new()}

def fill(bss: List<&2, List<&2, U32>>, a: Array<U32>, +at: U32, +idx: List<&2, U32>) -> Array<U32> & List<&2, U32>:
  match bss:
    case +bs <> t:
      +n = T.len(U32, bs)
      fill(t, M.fill(bs, a, at), (at + n : U32), List.append(&2, U32, idx, [at, n]))
    case []:
      (a, idx)

def total(+bss: List<&2, List<&2, U32>>) -> U32:
  match bss:
    case +bs <> t:
      (T.len(U32, bs) + total(t) : U32)
    case []:
      0

def lk(+gm: List<&2, U32>, +ps: G.Bank, +o3: U32) -> Lk:
  Lk{T.from_list(U32, gm), T.from_list(U32, O.freq()), T.from_list(U32, O.vmt()), ps, o3}

def built.font(+gm: List<&2, U32>, lib: Array<U32>, +idx: List<&2, U32>, f: G.Font, +o3: U32) -> Mu:
  match f:
    case G.Font{smp, +bk, n}:
      +o = Bool.pick(U32, Y.empty(bk), o3, 0)
      Mu{tables(), lib, T.from_list(U32, idx), lk(gm, bk, o), idle(o), 0, 0, smp}

def built(+gm: List<&2, U32>, f: G.Font, +o3: U32, r: Array<U32> & List<&2, U32>) -> Mu:
  (lib, +idx) = r
  built.font(gm, lib, idx, f, o3)

def build(+gm: List<&2, U32>, f: G.Font, +o3: U32, +bss: List<&2, List<&2, U32>>) -> Mu:
  built(gm, f, o3, fill(bss, Array.new(U32, M.depth((total(bss) + 1 : U32)), 0), 0, []))

def got.split(f: G.Font, +o3: U32, +bss: List<&2, List<&2, U32>>) -> Mu:
  match bss:
    case +gm <> t:
      build(gm, f, o3, t)
    case []:
      build([], f, o3, [])

def got(f: G.Font, +o3: U32, p: W.Wad & List<&2, List<&2, U32>>) -> IO(Mu):
  (w, bss) = p
  do IO<Mu>:
    W.close(w)
    return got.split(f, o3, bss)

def dmx(r: Result<&1, &1, U32 & String, String>) -> U32:
  match r:
    case Done{+v}:
      Bool.pick(U32, String.contains(v, "-opl3"), 1, 0)
    case Fail{e}:
      0

def font.pick(+none: Bool, +path: String) -> IO(G.Font):
  match none:
    case True{}:
      IO.pure(G.Font, G.empty())
    case False{}:
      G.load(path)

def font(+path: String) -> IO(G.Font):
  +p = W.font(path)
  font.pick(String.eq(p, ""), p)

def load(+path: String) -> IO(Mu):
  do IO<Mu>:
    f : G.Font <- font(path)
    w : W.Wad <- W.open(path)
    p : W.Wad & List<&2, List<&2, U32>> <- W.get(w, "GENMIDI" <> names())
    o : Result<&1, &1, U32 & String, String> <- IO.get_env("DMXOPTION")
    got(f, dmx(o), p)

def silent() -> Mu:
  Mu{tables(), Array.new(U32, 0n, 0), T.from_list(U32, []), lk([], G.bank([]), 0), idle(0), 0, 0, Array.new(F32, 0n, 0.0)}

def gm(m: Mu) -> Mu & Bool:
  match m:
    case Mu{tb, lib, +ix, +lk, +sq, +song, +last, smp}:
      (Mu{tb, lib, ix, lk, sq, song, last, smp}, isgm(lk))

def form(m: Mu) -> Mu & U32:
  match m:
    case Mu{tb, lib, +ix, +lk, +sq, +song, +last, smp}:
      (Mu{tb, lib, ix, lk, sq, song, last, smp}, Bool.pick(U32, isgm(lk), 2, o3(lk)))

def clips.go(xs: List<&2, U32>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      clips.go(t, clip(x) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def clips(xs: List<&2, U32>) -> List<&2, U32>:
  clips.go(xs, [])

def raw.out(+ix: T.Vec<U32>, +lk: Lk, lib: Array<U32>, smp: Array<F32>, +song: U32, +last: U32, p: Array<U32> & Sq, +out: List<&2, U32>) -> Mu & List<&2, U32>:
  (tb, +sq) = p
  (Mu{tb, lib, ix, lk, sq, song, last, smp}, clips(out))

def raw.got(+ix: T.Vec<U32>, +lk: Lk, lib: Array<U32>, smp: Array<F32>, +song: U32, +last: U32, r: (Array<U32> & Sq) & List<&2, U32>) -> Mu & List<&2, U32>:
  (p, +out) = r
  raw.out(ix, lk, lib, smp, song, last, p, out)

def raw.pick(gm: Bool, tb: Array<U32>, lib: Array<U32>, smp: Array<F32>, +ix: T.Vec<U32>, +lk: Lk, +sq: Sq, +song: U32, +last: U32) -> Mu & List<&2, U32>:
  match gm:
    case True{}:
      grendered(tb, ix, lk, lib, song, last, grun(smp, 315, lk, sq, []))
    case False{}:
      raw.got(ix, lk, lib, smp, song, last, run(tb, 315, lk, sq, []))

def raw(m: Mu) -> Mu & List<&2, U32>:
  match m:
    case Mu{tb, lib, +ix, +lk, +sq, +song, +last, smp}:
      raw.pick(isgm(lk), tb, lib, smp, ix, lk, sq, song, last)

def find(xs: List<&2, String>, +name: String, +i: U32) -> U32:
  match xs:
    case +x <> t:
      Bool.pick(U32, String.eq(x, name), i, find(t, name, (i + 1 : U32)))
    case []:
      0
