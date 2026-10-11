import Base
import ./src/wad.bend as W
import ./src/hud.bend as U
import ./src/screen.bend as P
import ./src/sys.bend as Y
import ./src/state.bend as S
import ./src/sim.bend as C
import ./src/boot.bend as B
import ./src/game.bend as K
import ./src/fixed.bend as F
import ./src/flow.bend as Q
import ./src/tab.bend as T
import ./src/disk.bend as Dk

type Opts is Data:
  Opts{all: U32, at: U32, out: String, ex: U32, ks: List<&2, U32>}

type Fk is Data:
  Fk{g: S.Sim, ks: List<&2, U32>}

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

def trace(+g0: S.Sim) -> String:
  +g = S.sim.cp.set(g0, 0)
  +m = S.p.mo(g)
  +f = C.tnext(g, 0)
  String.append("T ", words([U32.show(S.sim.time(g)), U32.show(S.sim.rnd(g)),
    signed(F.sar(S.m.x(g, m), 16n)), signed(F.sar(S.m.y(g, m), 16n)), signed(F.sar(S.m.z(g, m), 16n)),
    U32.show(S.m.angle(g, m)), signed(S.p.health(g)),
    U32.show(count(65536n, U32.is_ne(f, 0), g, f, 0)), U32.show(hash(65536n, U32.is_ne(f, 0), g, f, 0)), U32.show(pl.hash(g))]))

def exits(+g: S.Sim, +ex: U32) -> S.Sim:
  +n = (ex .&. 2147483647 : U32)
  C.when(Bool.and(U32.is_ne(n, 0), Bool.and(U32.is_eq(S.sim.gs(g), 0), U32.is_eq(S.sim.time(g), n))), g,
    +h => S.sim.exit.set(h, Bool.pick(U32, U32.is_ne((ex >> 31n : U32), 0), 2, 1)))

def shot.hit(+gt: U32, +at: U32) -> Bool:
  +every = U32.is_ne((at >> 31n : U32), 0)
  +n = (at .&. 2147483647 : U32)
  Bool.pick(Bool, every, Bool.and(U32.is_ne(n, 0), U32.is_eq((gt % Bool.pick(U32, U32.is_eq(n, 0), 1, n) : U32), 0)), U32.is_eq(gt, at))

def shot.name(+gt: U32, +at: U32, +out: String) -> String:
  Bool.pick(String, U32.is_ne((at >> 31n : U32), 0), String.append(out, String.append("_", String.append(U32.show(gt), ".bmp"))), out)

def stop(+g: S.Sim, +gt: U32, +at: U32) -> S.Sim:
  C.when(Bool.and(U32.is_ne(U.ui(g, 168), 0), U32.is_ge(gt, (at .&. 2147483647 : U32))), g, +h => U.ui.set(h, 119, 1))

def snd.kind(+g: S.Sim, +o: U32) -> String:
  Bool.pick(String, U32.is_eq(o, 0), "-1", Bool.pick(String, U32.is_ge(o, 16777216), U32.show((o - 16777216 + 1000 : U32)), U32.show(S.m.type(g, o))))

def snd.line(+g: S.Sim, +x: U32) -> String:
  String.append("S ", words([U32.show((S.sim.time(g) - 1 : U32)), U32.show((x % 128 : U32)), snd.kind(g, (x / 128 : U32))]))

def snd.print(on: Bool, +s: String) -> IO(Unit):
  match on:
    case True{}:
      IO.print(s)
    case False{}:
      IO.pure(Unit, Unit{})

def snd.lines(+g: S.Sim, xs: List<&2, U32>) -> IO(Unit):
  match xs:
    case +x <> t:
      do IO<Unit>:
        snd.lines(g, t)
        snd.print(U32.is_ne((x % 128 : U32), 0), snd.line(g, x))
    case []:
      IO.pure(Unit, Unit{})

def play.trace(level: Bool, snd: Bool, +g: S.Sim) -> IO(Unit):
  match level snd:
    case True{} True{}:
      snd.lines(g, S.sim.snd(g))
    case True{} False{}:
      IO.print(trace(g))
    case False{} _:
      IO.pure(Unit, Unit{})

def fire.go?(now: Bool, +t: U32, +c: U32, +d: U32, rest: List<&2, U32>, +g: S.Sim, +gt: U32) -> Fk:
  match now:
    case True{}:
      fire(rest, Q.respond(g, c, U32.is_eq(d, 1)), gt)
    case False{}:
      Fk{g, t <> c <> d <> rest}

def fire?(ks: List<&2, U32>, +g: S.Sim, +gt: U32) -> Fk:
  match ks:
    case +t <> +c <> +d <> rest:
      fire.go(U32.is_le(t, gt), t, c, d, rest, g, gt)
    case _:
      Fk{g, []}

def play?(+g: S.Sim, rom: Array<U32>, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32) -> IO(Unit):
  play.go(Q.quit(g), U32.is_ne(Q.pending(g), 0), g, rom, path, gt, at, out, ex, ks, all)

def play.reloaded?(+old: S.Sim, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32, p: S.Sim & Array<U32>) -> IO(Unit):
  (+g, rom) = p
  +g1 = Q.adopt(old, g)
  play(g1, Q.fuzz.put(g1, rom), path, gt, at, out, ex, ks, all)

def play.boot?(+g: S.Sim, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32) -> IO(Unit):
  IO.bind(S.Sim & Array<U32>, Unit, B.boot(path, Q.target(g), Q.player(g), Q.carry(g)),
    p => play.reloaded(g, path, gt, at, out, ex, ks, all, p))

def play.restored?(+path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32, p: S.Sim & Array<U32>) -> IO(Unit):
  (+g, rom) = p
  play(g, Q.fuzz.put(g, rom), path, gt, at, out, ex, ks, all)

def play.load?(c4: Bool, c5: Bool, c6: Bool, c7: Bool, +g: S.Sim, rom: Array<U32>, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32) -> IO(Unit):
  match c4 c5 c6 c7:
    case True{} _ _ _:
      IO.bind(List<&2, U32>, Unit, B.demolump(path, Q.demo.lump(g)), +bs => play.boot(Q.demo.loaded(Q.fuzz.keep(g, rom), bs), path, gt, at, out, ex, ks, all))
    case False{} True{} _ _:
      IO.bind(S.Sim, Unit, Dk.strings(g), +g1 => play(g1, rom, path, gt, at, out, ex, ks, all))
    case False{} False{} True{} _:
      IO.bind(S.Sim & Array<U32>, Unit, Dk.load(Q.fuzz.keep(g, rom), path), p => play.restored(path, gt, at, out, ex, ks, all, p))
    case False{} False{} False{} True{}:
      IO.bind(S.Sim, Unit, Dk.write(g), +g1 => play(g1, rom, path, gt, at, out, ex, ks, all))
    case _ _ _ _:
      play.boot(Q.fuzz.keep(g, rom), path, gt, at, out, ex, ks, all)

def play.go?(quit: Bool, load: Bool, +g: S.Sim, rom: Array<U32>, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32) -> IO(Unit):
  match quit load:
    case True{} _:
      IO.pure(Unit, Unit{})
    case False{} True{}:
      +c = Q.pending(g)
      play.load(U32.is_eq(c, 4), U32.is_eq(c, 5), U32.is_eq(c, 6), U32.is_eq(c, 7), g, rom, path, gt, at, out, ex, ks, all)
    case False{} False{}:
      play.tic(fire(ks, g, gt), rom, path, gt, at, out, ex, all)

def disk.save(+g: S.Sim, +t: U32) -> S.Sim:
  C.when(Bool.and(U32.is_ne(t, 0), Bool.and(U32.is_eq(S.sim.gs(g), 0), U32.is_eq(S.sim.time(g), t))), g, +h => U.ui.set(S.sim.act.set(h, 7), 90, 0))

def play.tic?(fk: Fk, rom: Array<U32>, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, +all: U32) -> IO(Unit):
  match fk:
    case Fk{+g, ks1}:
      +g0 = C.when(Bool.and(U32.is_ne((all .&. 1 : U32), 0), Bool.and(U32.is_eq(S.sim.gs(g), 0), U32.is_eq(S.sim.time(g), 0))), g, +h => give(h))
      +g1 = disk.save(stop(exits(Q.tick(g0), ex), gt, at), (all >> 3n : U32))
      +gt1 = (gt + 1 : U32)
      do IO<Unit>:
        play.trace(Bool.and(U32.is_eq(S.sim.gs(g1), 0), Bool.not(Q.quit(g1))), U32.is_ne((all .&. 2 : U32), 0), g1)
        play.snap(shot.hit(gt1, at), Bool.or(shot.hit(gt1, at), Bool.and(U32.is_ne((at >> 31n : U32), 0), U32.is_ne(gt1, 1))), S.sim.snd.set(g1, []), rom, path, gt1, at, out, ex, ks1, all)

def save.if(hit: Bool, +file: String, fb: Array<U32>) -> IO(Unit):
  match hit:
    case True{}:
      Y.save(file, P.bmp(fb))
    case False{}:
      IO.pure(Unit, Unit{})

def play.saved?(hit: Bool, +g: S.Sim, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32, +file: String, r: Array<U32> & Array<U32>) -> IO(Unit):
  (fb, rom) = r
  do IO<Unit>:
    save.if(hit, file, fb)
    play(g, rom, path, gt, at, out, ex, ks, all)

def play.drawn?(hit: Bool, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32, +file: String, r: S.Sim & (Array<U32> & Array<U32>)) -> IO(Unit):
  (+g, p) = r
  play.saved(hit, g, path, gt, at, out, ex, ks, all, file, p)

def play.snap?(hit: Bool, draw: Bool, +g: S.Sim, rom: Array<U32>, +path: String, +gt: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +all: U32) -> IO(Unit):
  match draw:
    case True{}:
      play.drawn(hit, path, gt, at, out, ex, ks, all, shot.name(gt, at, out), Q.render(g, rom))
    case False{}:
      play(g, rom, path, gt, at, out, ex, ks, all)

def give(+g: S.Sim) -> S.Sim:
  +g1 = S.p.own4.set(S.p.own3.set(S.p.own2.set(S.p.own1.set(S.p.own0.set(g, 1), 1), 1), 1), 1)
  +g2 = S.p.own8.set(S.p.own7.set(S.p.own6.set(S.p.own5.set(g1, 1), 1), 1), 1)
  +g3 = S.p.ammo3.set(S.p.ammo2.set(S.p.ammo1.set(S.p.ammo0.set(g2, S.p.max0(g2)), S.p.max1(g2)), S.p.max2(g2)), S.p.max3(g2))
  S.p.armortype.set(S.p.armor.set(g3, 200), 2)

def start.go?(+all: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +path: String, bs: List<&2, U32>, p: S.Sim & Array<U32>) -> IO(Unit):
  (+g, rom) = p
  play(Q.demo.start(U.ui.set(g, 129, 1), T.from_list(U32, bs)), rom, path, 0, at, out, ex, ks, all)

def start(+o: Opts, +path: String, bs: List<&2, U32>, p: S.Sim & Array<U32>) -> IO(Unit):
  match o:
    case Opts{+all, +at, +out, +ex, ks}:
      start.go(all, at, out, ex, ks, path, bs, p)

def loaded(+all: Opts, +path: String, name: String, r: File & Result<&1, &1, U32 & String, List<&2, U32>>) -> IO(Unit):
  (f, res) = r
  do IO<Unit>:
    File.close(f)
    +bs : List<&2, U32> <- IO.pass(List<&2, U32>, res)
    IO.bind(S.Sim & Array<U32>, Unit, B.skilled(path, name, Maybe.default(&2, U32, List.get(&2, U32, bs, 1n), 2)), p => start(all, path, bs, p))

def titled.go?(+all: U32, +at: U32, +out: String, +ex: U32, ks: List<&2, U32>, +path: String, p: S.Sim & Array<U32>) -> IO(Unit):
  (+g, rom) = p
  +g1 = Q.boot.title(U.ui.set(g, 168, 1))
  play(C.when(U32.is_ne((all .&. 4 : U32), 0), g1, +h => U.ui.set(U.ui.set(S.sim.act.set(h, 6), 90, 0), 125, 0)), rom, path, 0, at, out, ex, ks, all)

def titled?(+o: Opts, +path: String, p: S.Sim & Array<U32>) -> IO(Unit):
  match o:
    case Opts{+all, +at, +out, +ex, ks}:
      titled.go(all, at, out, ex, ks, path, p)

def run.title(+all: Opts, +path: String) -> IO(Unit):
  IO.bind(S.Sim & Array<U32>, Unit, B.first(path), p => titled(all, path, p))

def run.pick?(title: Bool, +all: Opts, +path: String, name: String, lmp: String) -> IO(Unit):
  match title:
    case True{}:
      run.title(all, path)
    case False{}:
      run.lmp(all, path, name, lmp)

def run(+all: Opts, +path: String, name: String, +lmp: String) -> IO(Unit):
  run.pick(String.eq(lmp, "title"), all, path, name, lmp)

def run.lmp(+all: Opts, +path: String, name: String, lmp: String) -> IO(Unit):
  do IO<Unit>:
    f : File <- IO.try(File, File.open(lmp, "r"))
    r : File & Result<&1, &1, U32 & String, List<&2, U32>> <- File.read_at(f, 0, 4194304)
    loaded(all, path, name, r)

def num(+x: String) -> U32:
  Maybe.default(&2, U32, U32.read(x), 0)

def opts?(xs: List<String>, +o: Opts) -> Opts:
  match xs o:
    case +x <> +t Opts{+all, +at, +out, +ex, +ks}:
      opts.disk(String.eq(x, "loadgame"), String.eq(x, "savegame"), x, t, Bool.pick(U32, String.eq(x, "sound"), (all .|. 2 : U32), all), at, out, ex, ks)
    case [] _:
      o

def opts.disk?(load: Bool, save: Bool, +x: String, t: List<String>, +all: U32, +at: U32, +out: String, +ex: U32, +ks: List<&2, U32>) -> Opts:
  match load save t:
    case True{} _ r:
      opts(r, Opts{(all .|. 4 : U32), at, out, ex, ks})
    case False{} True{} n <> r:
      opts(r, Opts{(all .|. (num(n) << 3n) : U32), at, out, ex, ks})
    case False{} False{} r:
      opts.one(String.eq(x, "give"), String.eq(x, "exit"), String.eq(x, "secret"), x, r, all, at, out, ex, ks)
    case _ _ _:
      Opts{all, at, out, ex, ks}

def opts.keys?(xs: List<String>, +o: Opts) -> Opts:
  match xs o:
    case "end" <> t _:
      opts(t, o)
    case +a <> +b <> +c <> t Opts{+all, +at, +out, +ex, +ks}:
      opts.keys(t, Opts{all, at, out, ex, List.append(&2, U32, ks, [num(a), num(b), num(c)])})
    case _ _:
      o

def opts.at?(every: Bool, +x: String, n: String, f: String, r: List<String>, +all: U32, +at: U32, +out: String, +ex: U32, +ks: List<&2, U32>) -> Opts:
  match every:
    case True{}:
      opts(r, Opts{all, (num(n) .|. 2147483648 : U32), f, ex, ks})
    case False{}:
      opts(f <> r, Opts{all, num(x), n, ex, ks})

def opts.one?(give: Bool, ex1: Bool, sec: Bool, +x: String, t: List<String>, +all: U32, +at: U32, +out: String, +ex: U32, +ks: List<&2, U32>) -> Opts:
  match give ex1 sec t:
    case True{} _ _ _:
      opts(t, Opts{(all .|. 1 : U32), at, out, ex, ks})
    case False{} True{} _ n <> r:
      opts(r, Opts{all, at, out, num(n), ks})
    case False{} False{} True{} n <> r:
      opts(r, Opts{all, at, out, (num(n) .|. 2147483648 : U32), ks})
    case False{} False{} False{} r:
      opts.rest(String.eq(x, "keys"), String.eq(x, "sound"), x, r, all, at, out, ex, ks)
    case _ _ _ _:
      Opts{all, at, out, ex, ks}

def opts.rest?(keys: Bool, snd: Bool, +x: String, t: List<String>, +all: U32, +at: U32, +out: String, +ex: U32, +ks: List<&2, U32>) -> Opts:
  match keys snd t:
    case True{} _ r:
      opts.keys(r, Opts{all, at, out, ex, ks})
    case False{} True{} r:
      opts(r, Opts{all, at, out, ex, ks})
    case False{} False{} n <> f <> r:
      opts.at(String.eq(x, "every"), x, n, f, r, all, at, out, ex, ks)
    case False{} False{} f <> r:
      opts(r, Opts{all, num(x), f, ex, ks})
    case _ _ _:
      Opts{all, at, out, ex, ks}

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> lmp <> t:
      run(opts(t, Opts{0, 4294967295, "", 0, []}), path, name, lmp)
    case _:
      IO.die(Unit, 2, "usage: demo FILE.wad [-file PWAD.wad ...] MAP DEMO.lmp [give] [exit TIC] [secret TIC] [every N PREFIX] [keys TIC CODE DOWN ... end] [sound] [savegame TIC] [loadgame] [TIC OUT.bmp]")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(W.cli(xs))
