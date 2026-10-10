import Base
import ./src/hud.bend as U
import ./src/screen.bend as P
import ./src/sys.bend as Y
import ./src/state.bend as S
import ./src/sim.bend as C
import ./src/boot.bend as B
import ./src/game.bend as K
import ./src/fixed.bend as F

type Opts is Data:
  Opts{all: Bool, at: U32, out: String}

def sx(+b: U32) -> U32:
  Bool.pick(U32, U32.is_ge(b, 128), (b - 256 : U32), b)

def signed(+v: U32) -> String:
  Bool.pick(String, F.is_neg(v), String.append("-", U32.show(F.neg(v))), U32.show(v))

def mix(+h: U32, +v: U32) -> U32:
  (h * 31 + v : U32)

def mo.hash(+g: S.Sim, +m: U32, +h: U32) -> U32:
  +h1 = mix(mix(mix(mix(h, S.m.x(g, m)), S.m.y(g, m)), S.m.z(g, m)), S.m.angle(g, m))
  mix(mix(mix(mix(h1, S.m.state(g, m)), S.m.tics(g, m)), S.m.health(g, m)), S.m.flags(g, m))

def hash(n: Nat, more: Bool, +g: S.Sim, +i: U32, +h: U32) -> U32:
  match n more:
    case 1n+p True{}:
      +nx = C.tnext(g, i)
      hash(p, U32.is_ne(nx, 0), g, nx, Bool.pick(U32, K.alive(g, i), mo.hash(g, i, h), h))
    case _ _:
      h

def count(n: Nat, more: Bool, +g: S.Sim, +i: U32, +c: U32) -> U32:
  match n more:
    case 1n+p True{}:
      +nx = C.tnext(g, i)
      count(p, U32.is_ne(nx, 0), g, nx, (c + C.b2u(K.alive(g, i)) : U32))
    case _ _:
      c

def words(xs: List<&2, String>) -> String:
  match xs:
    case x <> t:
      match t:
        case []:
          x
        case _:
          String.append(x, String.append(" ", words(t)))
    case []:
      ""

def pl.fold(xs: List<&2, U32>, +h: U32) -> U32:
  match xs:
    case +x <> t:
      pl.fold(t, mix(h, x))
    case []:
      h

def pl.hash(+g: S.Sim) -> U32:
  pl.fold([S.p.ready(g), S.p.pending(g), S.p.ammo0(g), S.p.ammo1(g), S.p.ammo2(g), S.p.ammo3(g),
    S.p.psp0st(g), S.p.psp0tics(g), S.p.psp0sx(g), S.p.psp0sy(g), S.p.psp1st(g), S.p.psp1tics(g), S.p.psp1sx(g), S.p.psp1sy(g),
    S.p.extralight(g), S.p.refire(g), S.p.attackdown(g), S.p.armor(g), S.p.kills(g)], 0)

def trace(+g: S.Sim) -> String:
  +m = S.p.mo(g)
  +f = C.tnext(g, 0)
  String.append("T ", words([U32.show(S.sim.time(g)), U32.show(S.sim.rnd(g)),
    signed(F.sar(S.m.x(g, m), 16n)), signed(F.sar(S.m.y(g, m), 16n)), signed(F.sar(S.m.z(g, m), 16n)),
    U32.show(S.m.angle(g, m)), signed(S.p.health(g)),
    U32.show(count(65536n, U32.is_ne(f, 0), g, f, 0)), U32.show(hash(65536n, U32.is_ne(f, 0), g, f, 0)), U32.show(pl.hash(g))]))

def tic(+g: S.Sim, +f: U32, +s: U32, +t: U32, +b: U32) -> S.Sim:
  K.ticker(S.p.buttons.set(S.p.turn.set(S.p.side.set(S.p.fwd.set(g, sx(f)), sx(s)), (t << 8n : U32)), b))

def play?(xs: List<&2, U32>, +g: S.Sim, rom: Array<U32>, +at: U32, +out: String) -> IO(Unit):
  match xs:
    case +f <> +s <> +t <> +b <> rest:
      play.one(U32.is_eq(f, 128), f, s, t, b, rest, g, rom, at, out)
    case _:
      IO.pure(Unit, Unit{})

def play.one?(end: Bool, +f: U32, +s: U32, +t: U32, +b: U32, rest: List<&2, U32>, +g: S.Sim, rom: Array<U32>, +at: U32, +out: String) -> IO(Unit):
  match end:
    case True{}:
      IO.pure(Unit, Unit{})
    case False{}:
      +g1 = tic(g, f, s, t, b)
      do IO<Unit>:
        IO.print(trace(g1))
        play.snap(U32.is_eq(S.sim.time(g1), at), rest, g1, rom, at, out)

def play.saved?(rest: List<&2, U32>, +g: S.Sim, +at: U32, +out: String, r: Array<U32> & Array<U32>) -> IO(Unit):
  (fb, rom) = r
  do IO<Unit>:
    Y.save(out, P.bmp(fb))
    play(rest, g, rom, at, out)

def play.snap?(hit: Bool, rest: List<&2, U32>, +g: S.Sim, rom: Array<U32>, +at: U32, +out: String) -> IO(Unit):
  match hit:
    case True{}:
      play.saved(rest, g, at, out, U.render(g, rom))
    case False{}:
      play(rest, g, rom, at, out)

def give(+g: S.Sim) -> S.Sim:
  +g1 = S.p.own4.set(S.p.own3.set(S.p.own2.set(S.p.own1.set(S.p.own0.set(g, 1), 1), 1), 1), 1)
  +g2 = S.p.own8.set(S.p.own7.set(S.p.own6.set(S.p.own5.set(g1, 1), 1), 1), 1)
  +g3 = S.p.ammo3.set(S.p.ammo2.set(S.p.ammo1.set(S.p.ammo0.set(g2, S.p.max0(g2)), S.p.max1(g2)), S.p.max2(g2)), S.p.max3(g2))
  S.p.armortype.set(S.p.armor.set(g3, 200), 2)

def start.go?(+all: Bool, +at: U32, +out: String, bs: List<&2, U32>, p: S.Sim & Array<U32>) -> IO(Unit):
  (g, rom) = p
  play(List.drop(&2, U32, bs, 13n), C.when(all, g, +h => give(h)), rom, at, out)

def start(+o: Opts, bs: List<&2, U32>, p: S.Sim & Array<U32>) -> IO(Unit):
  match o:
    case Opts{+all, +at, +out}:
      start.go(all, at, out, bs, p)

def loaded(+all: Opts, path: String, name: String, r: File & Result<&1, &1, U32 & String, List<&2, U32>>) -> IO(Unit):
  (f, res) = r
  do IO<Unit>:
    File.close(f)
    bs : List<&2, U32> <- IO.pass(List<&2, U32>, res)
    IO.bind(S.Sim & Array<U32>, Unit, B.new(path, name), p => start(all, bs, p))

def run(+all: Opts, path: String, name: String, lmp: String) -> IO(Unit):
  do IO<Unit>:
    f : File <- IO.try(File, File.open(lmp, "r"))
    r : File & Result<&1, &1, U32 & String, List<&2, U32>> <- File.read_at(f, 0, 4194304)
    loaded(all, path, name, r)

def opts?(xs: List<String>, +o: Opts) -> Opts:
  match xs o:
    case +x <> t Opts{+all, +at, +out}:
      opts.one(String.eq(x, "give"), x, t, all, at, out)
    case [] _:
      o

def opts.one?(give: Bool, x: String, t: List<String>, +all: Bool, +at: U32, +out: String) -> Opts:
  match give t:
    case True{} _:
      opts(t, Opts{True{}, at, out})
    case False{} f <> r:
      opts(r, Opts{all, Maybe.default(&2, U32, U32.read(x), 0), f})
    case False{} _:
      Opts{all, at, out}

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> lmp <> t:
      run(opts(t, Opts{False{}, 4294967295, ""}), path, name, lmp)
    case _:
      IO.die(Unit, 2, "usage: demo FILE.wad MAP DEMO.lmp [give] [TIC OUT.bmp]")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
