import Base
import ./tab.bend as T
import ./state.bend as S
import ./world.bend as R
import ./sim.bend as C

def magic() -> U32:
  1112360241

def flat(n: Nat, +v: T.Vec<U32>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      T.get(U32, v, i, 0) <> flat(p, v, (i + 1 : U32))

def vflat(+v: T.Vec<U32>) -> List<&2, U32>:
  flat(U32.to_nat(T.size(U32, v)), v, 0)

def zeros(n: Nat) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      0 <> zeros(p)

def rle.flush(+z: U32) -> List<&2, U32>:
  Bool.pick(List<&2, U32>, U32.is_eq(z, 0), [], [0, z])

def rle?(n: Nat, xs: List<&2, U32>, +z: U32) -> List<&2, U32>:
  match n xs:
    case 1n+p +x <> t:
      rle.step(p, U32.is_eq(x, 0), x, t, z)
    case _ _:
      rle.flush(z)

def rle.step?(n: Nat, zero: Bool, +x: U32, t: List<&2, U32>, +z: U32) -> List<&2, U32>:
  match zero:
    case True{}:
      rle(n, t, (z + 1 : U32))
    case False{}:
      List.append(&2, U32, rle.flush(z), x <> rle(n, t, 0))

def section.of(+ts: List<&2, U32>) -> List<&2, U32>:
  U32.from_nat(List.length(&2, U32, ts)) <> ts

def section(+xs: List<&2, U32>) -> List<&2, U32>:
  section.of(rle(List.length(&2, U32, xs), xs, 0))

def unrle?(n: Nat, +ws: T.Vec<U32>, +at: U32, +end: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      unrle.go(p, U32.is_ge(at, end), ws, at, end)

def unrle.go?(n: Nat, stop: Bool, +ws: T.Vec<U32>, +at: U32, +end: U32) -> List<&2, U32>:
  match stop:
    case True{}:
      []
    case False{}:
      +x = T.get(U32, ws, at, 0)
      unrle.tok(n, U32.is_eq(x, 0), x, ws, at, end)

def unrle.tok?(n: Nat, zero: Bool, +x: U32, +ws: T.Vec<U32>, +at: U32, +end: U32) -> List<&2, U32>:
  match zero:
    case True{}:
      List.append(&2, U32, zeros(U32.to_nat(T.get(U32, ws, (at + 1 : U32), 0))), unrle(n, ws, (at + 2 : U32), end))
    case False{}:
      x <> unrle(n, ws, (at + 1 : U32), end)

def sec.list(+ws: T.Vec<U32>, +at: U32) -> List<&2, U32>:
  +n = T.get(U32, ws, at, 0)
  unrle(U32.to_nat(n), ws, (at + 1 : U32), (at + 1 + n : U32))

def sec.vec(+ws: T.Vec<U32>, +at: U32) -> T.Vec<U32>:
  T.from_list(U32, sec.list(ws, at))

def sec.next(+ws: T.Vec<U32>, +at: U32) -> U32:
  (at + 1 + T.get(U32, ws, at, 0) : U32)

def side.words(+s: R.RSide) -> List<&2, U32>:
  match s:
    case R.RSide{+a, +b, +c, +d, +e, +f}:
      [a, b, c, d, e, f]

def sides.words(n: Nat, +v: T.Vec<R.RSide>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      List.append(&2, U32, side.words(T.get(R.RSide, v, i, R.RSide{0, 0, 0, 0, 0, 0})), sides.words(p, v, (i + 1 : U32)))

def sector.words(+s: R.RSector) -> List<&2, U32>:
  match s:
    case R.RSector{+a, +b, +c, +d, +e, +f, +h, +i, +j}:
      [a, b, c, d, e, f, h, i, j]

def sectors.words(n: Nat, +v: T.Vec<R.RSector>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      List.append(&2, U32, sector.words(T.get(R.RSector, v, i, R.RSector{0, 0, 0, 0, 0, 0, 0, 0, 0})), sectors.words(p, v, (i + 1 : U32)))

def pad(n: Nat, +xs: List<&2, U32>) -> List<&2, U32>:
  List.append(&2, U32, xs, zeros(n))

def th.words(+t: S.Th) -> List<&2, U32>:
  match t:
    case S.TNone{}:
      pad(11n, [0])
    case S.TMo{}:
      pad(11n, [1])
    case S.TDoor{+a, +b, +c, +d, +e, +f, +h}:
      pad(4n, [2, a, b, c, d, e, f, h])
    case S.TPlat{+a, +b, +c, +d, +e, +f, +h, +i, +j, +k, +l}:
      [3, a, b, c, d, e, f, h, i, j, k, l]
    case S.TCeil{+a, +b, +c, +d, +e, +f, +h, +i, +j}:
      pad(2n, [4, a, b, c, d, e, f, h, i, j])
    case S.TFloor{+a, +b, +c, +d, +e, +f, +h, +i}:
      pad(3n, [5, a, b, c, d, e, f, h, i])
    case S.TFlicker{+a, +b, +c, +d}:
      pad(7n, [6, a, b, c, d])
    case S.TFlash{+a, +b, +c, +d, +e, +f}:
      pad(5n, [7, a, b, c, d, e, f])
    case S.TStrobe{+a, +b, +c, +d, +e, +f}:
      pad(5n, [8, a, b, c, d, e, f])
    case S.TGlow{+a, +b, +c, +d}:
      pad(7n, [9, a, b, c, d])
    case S.TDead{}:
      pad(11n, [10])

def ths.words(n: Nat, +v: T.Vec<S.Th>, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      List.append(&2, U32, th.words(T.get(S.Th, v, i, S.TNone{})), ths.words(p, v, (i + 1 : U32)))

def scalars(+g: S.Sim) -> List<&2, U32>:
  [S.sim.vc(g), S.sim.next(g), S.sim.time(g), S.sim.rnd(g), S.sim.kills(g), S.sim.items(g), S.sim.secrets(g),
    S.sim.nbrain(g), S.sim.brainon(g), S.sim.easy(g), S.sim.tic(g), S.sim.mrnd(g), S.sim.stface(g), S.sim.stcount(g),
    S.sim.stprio(g), S.sim.stlad(g), S.sim.stold(g), S.sim.stpainh(g), S.sim.stpainc(g), S.sim.stweap(g), S.sim.strnd(g),
    S.sim.hmsg(g), S.sim.hcount(g), S.sim.cp(g), S.sim.ingame(g), S.sim.net(g), S.sim.bodyn(g)]

def concat(xss: List<&2, List<&2, U32>>) -> List<&2, U32>:
  match xss:
    case +xs <> t:
      List.append(&2, U32, xs, concat(t))
    case []:
      []

def header(+g: S.Sim, +desc: List<&2, U32>) -> List<&2, U32>:
  List.append(&2, U32, [magic(), 1, S.mp.episode(g), S.mp.map(g), S.mp.skill(g), S.sim.ingame(g), S.sim.net(g), 0], desc)

def words(+g: S.Sim, +desc: List<&2, U32>) -> List<&2, U32>:
  +w = S.sim.w(g)
  +sd = R.sides(w)
  +sc = R.sectors(w)
  +th = S.sim.ths(g)
  +mo = R.mobjs(w)
  +secs : List<&2, List<&2, U32>> = [section(scalars(g)), section(vflat(S.sim.lspec(g))), section(vflat(S.sim.links(g))),
    section(ths.words(U32.to_nat(T.size(S.Th, th)), th, 0)), section(vflat(S.sim.tn(g))), section(vflat(S.sim.tp(g))),
    section(S.sim.free(g)), section(vflat(S.sim.pl(g))), section(vflat(S.sim.plats(g))), section(vflat(S.sim.ceils(g))),
    section(vflat(S.sim.buttons(g))), section(vflat(S.sim.secv(g))), section(vflat(S.sim.sndt(g))), section(vflat(S.sim.sndn(g))),
    section(vflat(S.sim.brains(g))), section(vflat(S.sim.seen(g))), section(vflat(S.sim.starts(g))), section(vflat(S.sim.bodyq(g))),
    section(sides.words(U32.to_nat(T.size(R.RSide, sd)), sd, 0)), section(sectors.words(U32.to_nat(T.size(R.RSector, sc)), sc, 0)),
    section(flat(U32.to_nat((S.sim.next(g) * R.stride() : U32)), mo, 0))]
  List.append(&2, U32, header(g, desc), concat(secs))

def bytes(ws: List<&2, U32>) -> List<&2, U32>:
  match ws:
    case +w <> t:
      (w .&. 255 : U32) <> ((w >> 8n) .&. 255 : U32) <> ((w >> 16n) .&. 255 : U32) <> (w >> 24n : U32) <> bytes(t)
    case []:
      []

def unbytes(bs: List<&2, U32>) -> List<&2, U32>:
  match bs:
    case +a <> +b <> +c <> +d <> t:
      (a .|. (b << 8n) .|. (c << 16n) .|. (d << 24n) : U32) <> unbytes(t)
    case _:
      []

def ok(+ws: T.Vec<U32>) -> Bool:
  Bool.and(U32.is_eq(T.get(U32, ws, 0, 0), magic()), U32.is_eq(T.get(U32, ws, 1, 0), 1))

def episode(+ws: T.Vec<U32>) -> U32:
  T.get(U32, ws, 2, 1)

def map(+ws: T.Vec<U32>) -> U32:
  T.get(U32, ws, 3, 1)

def skill(+ws: T.Vec<U32>) -> U32:
  T.get(U32, ws, 4, 2)

def ingame(+ws: T.Vec<U32>) -> U32:
  T.get(U32, ws, 5, 1)

def net(+ws: T.Vec<U32>) -> U32:
  T.get(U32, ws, 6, 0)

def desc(+ws: T.Vec<U32>) -> List<&2, U32>:
  flat(24n, ws, 8)

def at(+ws: T.Vec<U32>, n: Nat, +o: U32) -> U32:
  match n:
    case 0n:
      o
    case 1n+p:
      at(ws, p, sec.next(ws, o))

def sec(+ws: T.Vec<U32>, +k: U32) -> U32:
  at(ws, U32.to_nat(k), 32)

def sides.of(n: Nat, +v: T.Vec<U32>, +i: U32) -> List<&2, R.RSide>:
  match n:
    case 0n:
      []
    case 1n+p:
      +b = (i * 6 : U32)
      R.RSide{T.get(U32, v, b, 0), T.get(U32, v, (b + 1 : U32), 0), T.get(U32, v, (b + 2 : U32), 0), T.get(U32, v, (b + 3 : U32), 0), T.get(U32, v, (b + 4 : U32), 0), T.get(U32, v, (b + 5 : U32), 0)} <> sides.of(p, v, (i + 1 : U32))

def sectors.of(n: Nat, +v: T.Vec<U32>, +i: U32) -> List<&2, R.RSector>:
  match n:
    case 0n:
      []
    case 1n+p:
      +b = (i * 9 : U32)
      R.RSector{T.get(U32, v, b, 0), T.get(U32, v, (b + 1 : U32), 0), T.get(U32, v, (b + 2 : U32), 0), T.get(U32, v, (b + 3 : U32), 0), T.get(U32, v, (b + 4 : U32), 0), T.get(U32, v, (b + 5 : U32), 0), T.get(U32, v, (b + 6 : U32), 0), T.get(U32, v, (b + 7 : U32), 0), T.get(U32, v, (b + 8 : U32), 0)} <> sectors.of(p, v, (i + 1 : U32))

def f(+v: T.Vec<U32>, +b: U32, +x: U32) -> U32:
  T.get(U32, v, (b + x : U32), 0)

def th.of(+v: T.Vec<U32>, +b: U32) -> S.Th:
  +k = T.get(U32, v, b, 0)
  Bool.pick(S.Th, U32.is_eq(k, 1), S.TMo{},
  Bool.pick(S.Th, U32.is_eq(k, 2), S.TDoor{f(v, b, 1), f(v, b, 2), f(v, b, 3), f(v, b, 4), f(v, b, 5), f(v, b, 6), f(v, b, 7)},
  Bool.pick(S.Th, U32.is_eq(k, 3), S.TPlat{f(v, b, 1), f(v, b, 2), f(v, b, 3), f(v, b, 4), f(v, b, 5), f(v, b, 6), f(v, b, 7), f(v, b, 8), f(v, b, 9), f(v, b, 10), f(v, b, 11)},
  Bool.pick(S.Th, U32.is_eq(k, 4), S.TCeil{f(v, b, 1), f(v, b, 2), f(v, b, 3), f(v, b, 4), f(v, b, 5), f(v, b, 6), f(v, b, 7), f(v, b, 8), f(v, b, 9)},
  Bool.pick(S.Th, U32.is_eq(k, 5), S.TFloor{f(v, b, 1), f(v, b, 2), f(v, b, 3), f(v, b, 4), f(v, b, 5), f(v, b, 6), f(v, b, 7), f(v, b, 8)},
  Bool.pick(S.Th, U32.is_eq(k, 6), S.TFlicker{f(v, b, 1), f(v, b, 2), f(v, b, 3), f(v, b, 4)},
  Bool.pick(S.Th, U32.is_eq(k, 7), S.TFlash{f(v, b, 1), f(v, b, 2), f(v, b, 3), f(v, b, 4), f(v, b, 5), f(v, b, 6)},
  Bool.pick(S.Th, U32.is_eq(k, 8), S.TStrobe{f(v, b, 1), f(v, b, 2), f(v, b, 3), f(v, b, 4), f(v, b, 5), f(v, b, 6)},
  Bool.pick(S.Th, U32.is_eq(k, 9), S.TGlow{f(v, b, 1), f(v, b, 2), f(v, b, 3), f(v, b, 4)},
  Bool.pick(S.Th, U32.is_eq(k, 10), S.TDead{}, S.TNone{}))))))))))

def ths.of(n: Nat, +v: T.Vec<U32>, +i: U32) -> List<&2, S.Th>:
  match n:
    case 0n:
      []
    case 1n+p:
      th.of(v, (i * 12 : U32)) <> ths.of(p, v, (i + 1 : U32))

def mo.of(+old: T.Vec<U32>, +ws: T.Vec<U32>, +at: U32) -> T.Vec<U32>:
  +xs = sec.list(ws, at)
  +n = U32.from_nat(List.length(&2, U32, xs))
  T.from_list(U32, List.append(&2, U32, xs, zeros(U32.to_nat((T.size(U32, old) - n : U32)))))

def sc(+v: T.Vec<U32>, +i: U32) -> U32:
  T.get(U32, v, i, 0)

def restore.scalars(+g: S.Sim, +v: T.Vec<U32>) -> S.Sim:
  +g1 = S.sim.secrets.set(S.sim.items.set(S.sim.kills.set(S.sim.rnd.set(S.sim.time.set(S.sim.next.set(S.sim.vc.set(g, sc(v, 0)), sc(v, 1)), sc(v, 2)), sc(v, 3)), sc(v, 4)), sc(v, 5)), sc(v, 6))
  +g2 = S.sim.stface.set(S.sim.mrnd.set(S.sim.tic.set(S.sim.easy.set(S.sim.brainon.set(S.sim.nbrain.set(g1, sc(v, 7)), sc(v, 8)), sc(v, 9)), sc(v, 10)), sc(v, 11)), sc(v, 12))
  +g3 = S.sim.stpainc.set(S.sim.stpainh.set(S.sim.stold.set(S.sim.stlad.set(S.sim.stprio.set(S.sim.stcount.set(g2, sc(v, 13)), sc(v, 14)), sc(v, 15)), sc(v, 16)), sc(v, 17)), sc(v, 18))
  +g4 = S.sim.cp.set(S.sim.hcount.set(S.sim.hmsg.set(S.sim.strnd.set(S.sim.stweap.set(g3, sc(v, 19)), sc(v, 20)), sc(v, 21)), sc(v, 22)), sc(v, 23))
  S.sim.bodyn.set(S.sim.net.set(S.sim.ingame.set(g4, sc(v, 24)), sc(v, 25)), sc(v, 26))

def restore.world(+w: R.World, +ws: T.Vec<U32>) -> R.World:
  +sd = sec.vec(ws, sec(ws, 18))
  +sv = sec.vec(ws, sec(ws, 19))
  +w1 = R.with.sides(w, T.from_list(R.RSide, sides.of(U32.to_nat((T.size(U32, sd) / 6 : U32)), sd, 0)))
  +w2 = R.with.sectors(w1, T.from_list(R.RSector, sectors.of(U32.to_nat((T.size(U32, sv) / 9 : U32)), sv, 0)))
  R.with.mobjs(w2, mo.of(R.mobjs(w2), ws, sec(ws, 20)))

def restore(+g: S.Sim, +ws: T.Vec<U32>) -> S.Sim:
  +g1 = restore.scalars(g, sec.vec(ws, sec(ws, 0)))
  +tv = sec.vec(ws, sec(ws, 3))
  +g2 = S.sim.ths.set(S.sim.links.set(S.sim.lspec.set(g1, sec.vec(ws, sec(ws, 1))), sec.vec(ws, sec(ws, 2))), T.from_list(S.Th, ths.of(U32.to_nat((T.size(U32, tv) / 12 : U32)), tv, 0)))
  +g3 = S.sim.pl.set(S.sim.free.set(S.sim.tp.set(S.sim.tn.set(g2, sec.vec(ws, sec(ws, 4))), sec.vec(ws, sec(ws, 5))), sec.list(ws, sec(ws, 6))), sec.vec(ws, sec(ws, 7)))
  +g4 = S.sim.secv.set(S.sim.buttons.set(S.sim.ceils.set(S.sim.plats.set(g3, sec.vec(ws, sec(ws, 8))), sec.vec(ws, sec(ws, 9))), sec.vec(ws, sec(ws, 10))), sec.vec(ws, sec(ws, 11)))
  +g5 = S.sim.seen.set(S.sim.brains.set(S.sim.sndn.set(S.sim.sndt.set(g4, sec.vec(ws, sec(ws, 12))), sec.vec(ws, sec(ws, 13))), sec.vec(ws, sec(ws, 14))), sec.vec(ws, sec(ws, 15)))
  +g6 = S.sim.bodyq.set(S.sim.starts.set(g5, sec.vec(ws, sec(ws, 16))), sec.vec(ws, sec(ws, 17)))
  S.sim.w.set(g6, restore.world(S.sim.w(g6), ws))
