import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./geo.bend as G
import ./render.bend as V
import ./hud.bend as U
import ./wad.bend as W
import ./sfxinfo.bend as X

type Ch is Data:
  Ch{sfx: U32, org: U32, pos: U32, lv: U32, rv: U32}

type Mix is Type:
  Mix{bank: Array<U32>, idx: T.Vec<U32>, pri: T.Vec<U32>, chans: List<&2, Ch>}

def rate() -> U32:
  22050

def frames() -> U32:
  630

def nochan() -> Ch:
  Ch{0, 0, 0, 0, 0}

def nochans() -> List<&2, Ch>:
  [nochan(), nochan(), nochan(), nochan(), nochan(), nochan(), nochan(), nochan()]

def u16(+bs: List<&2, U32>, +i: Nat) -> U32:
  (Maybe.default(&2, U32, List.get(&2, U32, bs, i), 0) + 256 * Maybe.default(&2, U32, List.get(&2, U32, bs, 1n+i), 0) : U32)

def u32(+bs: List<&2, U32>, +i: Nat) -> U32:
  (u16(bs, i) + 65536 * u16(bs, 2n+i) : U32)

def ok(+bs: List<&2, U32>) -> Bool:
  +n = U32.from_nat(List.length(&2, U32, bs))
  Bool.and(U32.is_eq(u16(bs, 0n), 3), Bool.and(U32.is_gt(n, 40), U32.is_ge(n, (u32(bs, 4n) + 8 : U32))))

def put(xs: List<&2, U32>, n: Nat, a: Array<U32>, +i: U32) -> Array<U32>:
  match xs n:
    case x <> t 1n+p:
      put(t, p, Array.set(U32, a, i, x), (i + 1 : U32))
    case _ _:
      a

def samples(+bs: List<&2, U32>) -> U32:
  Bool.pick(U32, ok(bs), (u32(bs, 4n) - 32 : U32), 0)

def step(+bs: List<&2, U32>) -> U32:
  U32.min(((u16(bs, 2n) << 16n) / rate() : U32), 1048576)

def fill(bss: List<&2, List<&2, U32>>, a: Array<U32>, +at: U32, +idx: List<&2, U32>) -> Array<U32> & List<&2, U32>:
  match bss:
    case +bs <> t:
      +n = samples(bs)
      fill(t, put(List.drop(&2, U32, bs, 24n), U32.to_nat(n), a, at), (at + n : U32), List.append(&2, U32, idx, [at, n, step(bs)]))
    case []:
      (a, idx)

def total(+bss: List<&2, List<&2, U32>>) -> U32:
  match bss:
    case +bs <> t:
      (samples(bs) + total(t) : U32)
    case []:
      0

def depth(+n: U32) -> Nat:
  Bool.pick(Nat, U32.is_le(n, 1), 0n, 1n+U32.log2((n - 1 : U32)))

def built(r: Array<U32> & List<&2, U32>) -> Mix:
  (a, idx) = r
  Mix{a, T.from_list(U32, List.append(&2, U32, [0, 0, 65536], idx)), T.from_list(U32, X.prios()), nochans()}

def build(+bss: List<&2, List<&2, U32>>) -> Mix:
  +n = total(bss)
  built(fill(bss, Array.new(U32, depth((n + 1 : U32)), 128), 0, []))

def got(p: W.Wad & List<&2, List<&2, U32>>) -> IO(Mix):
  (w, bss) = p
  do IO<Mix>:
    W.close(w)
    return build(bss)

def load(path: String) -> IO(Mix):
  do IO<Mix>:
    w : W.Wad <- W.open(path)
    p : W.Wad & List<&2, List<&2, U32>> <- W.get(w, X.lumps())
    got(p)

def silent() -> Mix:
  Mix{Array.new(U32, 0n, 128), T.from_list(U32, [0, 0, 65536]), T.from_list(U32, X.prios()), nochans()}

def volume(+g: S.Sim) -> U32:
  (U.ui(g, 113) * 8 : U32)

def listener(+g: S.Sim) -> U32:
  S.pi.mo(g, C.me(g))

def ox(+g: S.Sim, +o: U32) -> U32:
  Bool.pick(U32, U32.is_ge(o, 16777216), C.sorg(g, (o - 16777216 : U32), 0), S.m.x(g, o))

def oy(+g: S.Sim, +o: U32) -> U32:
  Bool.pick(U32, U32.is_ge(o, 16777216), C.sorg(g, (o - 16777216 : U32), 1), S.m.y(g, o))

def clip() -> U32:
  78643200

def far(+g: S.Sim, +d: U32) -> U32:
  +v = volume(g)
  +room = ((clip() - d) >> 16n : U32)
  Bool.pick(U32, U32.is_ge(v, 15), (15 + ((v - 15) * room) / 1000 : U32), (15 - ((15 - v) * room) / 1000 : U32))

def level(+g: S.Sim, +d: U32, +m8: Bool) -> U32:
  Bool.pick(U32, F.lt(d, 13107200), volume(g),
    Bool.pick(U32, m8, far(g, Bool.pick(U32, F.gt(d, clip()), clip(), d)), ((volume(g) * ((clip() - d) >> 16n)) / 1000 : U32)))

def turn(+a: U32, +la: U32) -> U32:
  Bool.pick(U32, U32.is_gt(a, la), (a - la : U32), (a + (4294967295 - la) : U32))

def sep(+g: S.Sim, +lx: U32, +ly: U32, +la: U32, +sx: U32, +sy: U32) -> U32:
  +a = (turn(V.angle(S.mp.tb(g), (sx - lx : U32), (sy - ly : U32)), la) >> 19n : U32)
  (128 - F.sar(F.mul(6291456, V.sine(S.mp.tb(g), a)), 16n) : U32)

def gains(+v: U32, +s: U32) -> U32 & U32:
  ((((254 - s) * v) / 127 : U32), ((s * v) / 127 : U32))

def params(+g: S.Sim, +o: U32) -> Bool & (U32 & U32):
  +l = listener(g)
  +near = Bool.or(U32.is_eq(o, 0), U32.is_eq(o, l))
  +lx = S.m.x(g, l)
  +ly = S.m.y(g, l)
  +sx = ox(g, o)
  +sy = oy(g, o)
  +d = G.aprox((lx - sx : U32), (ly - sy : U32))
  +m8 = U32.is_eq(S.mp.map(g), 8)
  +v = level(g, d, m8)
  +s = Bool.pick(U32, Bool.and(U32.is_eq(lx, sx), U32.is_eq(ly, sy)), 128, sep(g, lx, ly, S.m.angle(g, l), sx, sy))
  +audible = Bool.and(Bool.or(m8, Bool.not(F.gt(d, clip()))), F.gt(v, 0))
  Bool.pick(Bool & (U32 & U32), near, (True{}, gains(volume(g), 128)), (audible, gains(v, s)))

def stop.first(+cs: List<&2, Ch>, +o: U32) -> List<&2, Ch>:
  match cs:
    case Ch{+sfx, +org, +pos, +lv, +rv} <> +t:
      Bool.pick(List<&2, Ch>, Bool.and(U32.is_ne(sfx, 0), U32.is_eq(org, o)), nochan() <> t, Ch{sfx, org, pos, lv, rv} <> stop.first(t, o))
    case []:
      []

def slot.free(+cs: List<&2, Ch>, +o: U32, +i: U32) -> U32:
  match cs:
    case Ch{+sfx, +org, pos, lv, rv} <> t:
      Bool.pick(U32, Bool.or(U32.is_eq(sfx, 0), Bool.and(U32.is_ne(o, 0), U32.is_eq(org, o))), i, slot.free(t, o, (i + 1 : U32)))
    case []:
      8

def slot.low(+cs: List<&2, Ch>, +pri: T.Vec<U32>, +p: U32, +i: U32) -> U32:
  match cs:
    case Ch{+sfx, org, pos, lv, rv} <> t:
      Bool.pick(U32, U32.is_ge(T.get(U32, pri, sfx, 0), p), i, slot.low(t, pri, p, (i + 1 : U32)))
    case []:
      8

def slot.put(+cs: List<&2, Ch>, +i: U32, +c: Ch) -> List<&2, Ch>:
  match cs:
    case +x <> +t:
      Bool.pick(List<&2, Ch>, U32.is_eq(i, 0), c <> t, x <> slot.put(t, (i - 1 : U32), c))
    case []:
      []

def started(+cs: List<&2, Ch>, +pri: T.Vec<U32>, +sfx: U32, +o: U32, +lv: U32, +rv: U32) -> List<&2, Ch>:
  +f = slot.free(cs, o, 0)
  +i = Bool.pick(U32, U32.is_lt(f, 8), f, slot.low(cs, pri, T.get(U32, pri, sfx, 0), 0))
  Bool.pick(List<&2, Ch>, U32.is_lt(i, 8), slot.put(cs, i, Ch{sfx, o, 0, lv, rv}), cs)

def start.ok(ok: Bool, +cs: List<&2, Ch>, +pri: T.Vec<U32>, +sfx: U32, +o: U32, q: U32 & U32) -> List<&2, Ch>:
  match ok:
    case True{}:
      (+lv, +rv) = q
      started(stop.first(cs, o), pri, sfx, o, lv, rv)
    case False{}:
      cs

def start.go(+cs: List<&2, Ch>, +pri: T.Vec<U32>, +sfx: U32, +o: U32, p: Bool & (U32 & U32)) -> List<&2, Ch>:
  (ok, q) = p
  start.ok(ok, cs, pri, sfx, o, q)

def start(+cs: List<&2, Ch>, +pri: T.Vec<U32>, +g: S.Sim, +sfx: U32, +o: U32) -> List<&2, Ch>:
  Bool.pick(List<&2, Ch>, U32.is_eq(sfx, 0), stop.first(cs, o), start.go(cs, pri, sfx, o, params(g, o)))

def events(xs: List<&2, U32>, +cs: List<&2, Ch>, +pri: T.Vec<U32>, +g: S.Sim) -> List<&2, Ch>:
  match xs:
    case +x <> t:
      start(events(t, cs, pri, g), pri, g, (x % 128 : U32), (x / 128 : U32))
    case []:
      cs

def update.ok(ok: Bool, +c: Ch, q: U32 & U32) -> Ch:
  match ok c:
    case True{} Ch{+sfx, +org, +pos, lv, rv}:
      (+l, +r) = q
      Ch{sfx, org, pos, l, r}
    case _ _:
      nochan()

def update.go(+c: Ch, p: Bool & (U32 & U32)) -> Ch:
  (ok, q) = p
  update.ok(ok, c, q)

def update(+cs: List<&2, Ch>, +g: S.Sim) -> List<&2, Ch>:
  match cs:
    case Ch{+sfx, +org, +pos, +lv, +rv} <> t:
      +keep = Bool.or(U32.is_eq(sfx, 0), Bool.or(U32.is_eq(org, 0), U32.is_eq(org, listener(g))))
      Bool.pick(Ch, keep, Ch{sfx, org, pos, lv, rv}, update.go(Ch{sfx, org, pos, lv, rv}, params(g, org))) <> update(t, g)
    case []:
      []

def acc0(n: Nat) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      1048576 <> 1048576 <> acc0(p)

def add.out(+l: U32, +r: U32, +s: U32, +lv: U32, +rv: U32, p: List<&2, U32> & (Array<U32> & U32)) -> List<&2, U32> & (Array<U32> & U32):
  (t, q) = p
  ((l + (s - 128) * lv : U32) <> (r + (s - 128) * rv : U32) <> t, q)

def add.go?(acc: List<&2, U32>, a: Array<U32>, +base: U32, +len: U32, +pos: U32, +st: U32, +lv: U32, +rv: U32) -> List<&2, U32> & (Array<U32> & U32):
  match acc:
    case +l <> t:
      add.pair(l, t, a, base, len, pos, st, lv, rv)
    case []:
      ([], (a, pos))

def add.pair?(+l: U32, acc: List<&2, U32>, a: Array<U32>, +base: U32, +len: U32, +pos: U32, +st: U32, +lv: U32, +rv: U32) -> List<&2, U32> & (Array<U32> & U32):
  match acc:
    case +r <> t:
      add.at(U32.is_lt((pos >> 16n : U32), len), l, r, t, a, base, len, pos, st, lv, rv)
    case []:
      ([l], (a, pos))

def add.at?(more: Bool, +l: U32, +r: U32, t: List<&2, U32>, a: Array<U32>, +base: U32, +len: U32, +pos: U32, +st: U32, +lv: U32, +rv: U32) -> List<&2, U32> & (Array<U32> & U32):
  match more:
    case True{}:
      add.sample(l, r, t, Array.get(U32, a, (base + (pos >> 16n) : U32)), base, len, pos, st, lv, rv)
    case False{}:
      (l <> r <> t, (a, 4294967295))

def add.sample?(+l: U32, +r: U32, t: List<&2, U32>, q: Array<U32> & U32, +base: U32, +len: U32, +pos: U32, +st: U32, +lv: U32, +rv: U32) -> List<&2, U32> & (Array<U32> & U32):
  (a, +s) = q
  add.out(l, r, s, lv, rv, add.go(t, a, base, len, (pos + st : U32), st, lv, rv))

def chan.pack(+c: Ch, acc: List<&2, U32>, a: Array<U32>) -> (List<&2, U32> & Array<U32>) & Ch:
  ((acc, a), c)

def chan.done(+c: Ch, acc: List<&2, U32>, q: Array<U32> & U32) -> (List<&2, U32> & Array<U32>) & Ch:
  match c:
    case Ch{+sfx, +org, pos, +lv, +rv}:
      (a, +np) = q
      chan.pack(Bool.pick(Ch, U32.is_eq(np, 4294967295), nochan(), Ch{sfx, org, np, lv, rv}), acc, a)

def chan.after(+c: Ch, p: List<&2, U32> & (Array<U32> & U32)) -> (List<&2, U32> & Array<U32>) & Ch:
  (acc, q) = p
  chan.done(c, acc, q)

def chan.mix?(+c: Ch, acc: List<&2, U32>, a: Array<U32>, +idx: T.Vec<U32>) -> (List<&2, U32> & Array<U32>) & Ch:
  match c:
    case Ch{+sfx, +org, +pos, +lv, +rv}:
      +k = (sfx * 3 : U32)
      chan.pick(U32.is_eq(sfx, 0), Ch{sfx, org, pos, lv, rv}, acc, a, T.get(U32, idx, k, 0), T.get(U32, idx, (k + 1 : U32), 0), T.get(U32, idx, (k + 2 : U32), 65536))

def chan.pick(idle: Bool, +c: Ch, acc: List<&2, U32>, a: Array<U32>, +base: U32, +len: U32, +st: U32) -> (List<&2, U32> & Array<U32>) & Ch:
  match idle c:
    case True{} _:
      ((acc, a), c)
    case False{} Ch{+sfx, +org, +pos, +lv, +rv}:
      chan.after(Ch{sfx, org, pos, lv, rv}, add.go(acc, a, base, len, pos, st, lv, rv))

def mix.next(+c: Ch, r: (List<&2, U32> & Array<U32>) & List<&2, Ch>) -> (List<&2, U32> & Array<U32>) & List<&2, Ch>:
  (p, cs) = r
  (p, c <> cs)

def mix.all?(+cs: List<&2, Ch>, acc: List<&2, U32>, a: Array<U32>, +idx: T.Vec<U32>) -> (List<&2, U32> & Array<U32>) & List<&2, Ch>:
  match cs:
    case +c <> t:
      mix.step(t, chan.mix(c, acc, a, idx), idx)
    case []:
      ((acc, a), [])

def mix.step?(t: List<&2, Ch>, r: (List<&2, U32> & Array<U32>) & Ch, +idx: T.Vec<U32>) -> (List<&2, U32> & Array<U32>) & List<&2, Ch>:
  (p, +c) = r
  (acc, a) = p
  mix.next(c, mix.all(t, acc, a, idx))

def silence() -> List<&2, U32>:
  acc0(1260n)

def pcm(xs: List<&2, U32>) -> List<&2, F32>:
  match xs:
    case +x <> t:
      F32.clamp(((U32.to_f32(x) - 1048576.0) / 32640.0 : F32), (0.0 - 1.0 : F32), 1.0) <> pcm(t)
    case []:
      []

def rendered(+pri: T.Vec<U32>, +idx: T.Vec<U32>, r: (List<&2, U32> & Array<U32>) & List<&2, Ch>) -> Mix & List<&2, U32>:
  (p, cs) = r
  (acc, a) = p
  (Mix{a, idx, pri, cs}, acc)

def render(m: Mix) -> Mix & List<&2, U32>:
  match m:
    case Mix{a, +idx, +pri, cs}:
      rendered(pri, idx, mix.all(cs, acc0(U32.to_nat(frames())), a, idx))

def tic(m: Mix, +g: S.Sim) -> Mix:
  match m:
    case Mix{a, +idx, +pri, cs}:
      Mix{a, idx, pri, update(events(S.sim.snd(g), cs, pri, g), g)}

def heard(m: Mix, +g: S.Sim) -> Mix:
  match m:
    case Mix{a, +idx, +pri, cs}:
      Mix{a, idx, pri, events(S.sim.snd(g), cs, pri, g)}
