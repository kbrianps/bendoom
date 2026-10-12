import Base
import ./hud.bend as U
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./game.bend as K
import ./boot.bend as B
import ./draw.bend as D
import ./flow.bend as Q
import ./disk.bend as Dk
import ./sound.bend as N

type Au is Type:
  Au{dev: Maybe<Audio>, mix: N.Mix}

type Game is Type:
  Game{sim: S.Sim, rom: Array<U32>, path: String, keys: U32, t0: U32, tics: U32, held: U32, au: Au}

type Run is Data:
  Run{sim: S.Sim, held: U32}

def code.bit(+c: U32) -> U32:
  Bool.pick(U32, Bool.or(U32.is_eq(c, 63232), U32.is_eq(c, 119)), 1,
    Bool.pick(U32, Bool.or(U32.is_eq(c, 63233), U32.is_eq(c, 115)), 2,
      Bool.pick(U32, U32.is_eq(c, 63234), 4,
        Bool.pick(U32, U32.is_eq(c, 63235), 8,
          Bool.pick(U32, Bool.or(U32.is_eq(c, 44), U32.is_eq(c, 97)), 16,
            Bool.pick(U32, Bool.or(U32.is_eq(c, 46), U32.is_eq(c, 100)), 32,
              Bool.pick(U32, Bool.or(U32.is_eq(c, 65592), U32.is_eq(c, 65596)), 64,
                Bool.pick(U32, Bool.or(U32.is_eq(c, 32), U32.is_eq(c, 101)), 128,
                  Bool.pick(U32, Bool.and(U32.is_ge(c, 49), U32.is_le(c, 55)), (256 << U32.to_nat((c - 48 : U32)) : U32),
                    Bool.pick(U32, Bool.or(Bool.or(U32.is_eq(c, 65595), U32.is_eq(c, 65598)), U32.is_eq(c, 102)), 65536, 0))))))))))

def press(+keys: U32, +c: U32, +down: Bool) -> U32:
  Bool.pick(U32, down, (keys .|. code.bit(c) : U32), (keys .&. (4294967295 - code.bit(c)) : U32))

def held(+keys: U32, +b: U32) -> Bool:
  U32.is_ne((keys .&. b : U32), 0)

def button.bit(+b: U32) -> U32:
  Bool.pick(U32, U32.is_eq(b, 0), 131072, Bool.pick(U32, U32.is_eq(b, 1), 262144, Bool.pick(U32, U32.is_eq(b, 2), 524288, 0)))

def click(+keys: U32, +b: U32, +down: Bool) -> U32:
  Bool.pick(U32, down, (keys .|. button.bit(b) : U32), (keys .&. (4294967295 - button.bit(b)) : U32))

def signed(+x: F32) -> U32:
  Bool.pick(U32, F32.is_lt(x, 0.0), (0 - F32.to_u32(F32.round((0.0 - x : F32))) : U32), F32.to_u32(F32.round(x)))

def turned(+g: S.Sim, +dx: F32) -> U32:
  +sens = U32.to_f32((U.ui(g, 111) + 5 : U32))
  signed((dx * sens * 0.8 : F32))

def look(+g: S.Sim, +dx: F32) -> S.Sim:
  U.ui.set(g, 250, (U.ui(g, 250) + turned(g, dx) : U32))

def event(+e: Event, +r: Run) -> Run:
  match e r:
    case Key{+c, +d} Run{+g, +k}:
      +g1 = Q.respond(g, c, d)
      Run{g1, Bool.pick(U32, Q.eaten(g1), k, press(k, c, d))}
    case Mouse{+x, +y, +b, +d} Run{+g, +k}:
      Run{g, click(k, b, d)}
    case Look{+dx, +dy} Run{+g, +k}:
      Run{look(g, dx), k}
    case Close{} Run{+g, +k}:
      Run{Q.close(g), k}
    case _ q:
      q

def events(es: List<Event>, +r: Run) -> Run:
  match es:
    case +e <> t:
      events(t, event(e, r))
    case []:
      r

def amount(+keys: U32, +pos: U32, +neg: U32, +v: U32) -> U32:
  (Bool.pick(U32, held(keys, pos), v, 0) - Bool.pick(U32, held(keys, neg), v, 0) : U32)

def weapon(n: Nat, +keys: U32, +i: U32) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      Bool.pick(U32, held(keys, (512 << U32.to_nat(i) : U32)), (4 .|. (i << 3n) : U32), weapon(p, keys, (i + 1 : U32)))

def cmd(+g: S.Sim, +keys: U32, +turnheld: U32, +mouse: U32) -> S.Sim:
  +run = held(keys, 64)
  +tspeed = Bool.pick(U32, U32.is_lt(turnheld, 6), 320, Bool.pick(U32, run, 1280, 640))
  +turn = (amount(keys, 4, 8, tspeed) - mouse : U32)
  +fwd = amount(keys, 524289, 2, Bool.pick(U32, run, 50, 25))
  +side = amount(keys, 32, 16, Bool.pick(U32, run, 40, 24))
  +bt = (Bool.pick(U32, held(keys, 196608), 1, 0) .|. Bool.pick(U32, held(keys, 262272), 2, 0) .|. weapon(7n, keys, 0) : U32)
  S.p.buttons.set(S.p.side.set(S.p.fwd.set(S.p.turn.set(g, turn), fwd), side), bt)

def done(+g: S.Sim) -> Bool:
  Bool.or(U32.is_ne(S.sim.exit(g), 0), U32.is_eq(S.p.state(g), 2))

def steps(n: Nat, more: Bool, +g: S.Sim, +keys: U32, +h: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +h1 = Bool.pick(U32, held(keys, 12), (h + 1 : U32), 0)
      +g1 = K.ticker(cmd(g, keys, h1, 0))
      steps(p, Bool.not(done(g1)), g1, keys, h1)
    case _ _:
      g

def stopped(+g: S.Sim) -> Bool:
  Bool.or(U32.is_ne(Q.pending(g), 0), Q.quit(g))

def quiet(+g: S.Sim) -> S.Sim:
  S.sim.snd.set(g, [])

def heard.out(+out: List<&2, U32>, r: N.Mix & List<&2, U32>) -> N.Mix & List<&2, U32>:
  (m, +acc) = r
  (m, List.append(&2, U32, out, acc))

def heard(on: Bool, m: N.Mix, +g: S.Sim, +out: List<&2, U32>) -> N.Mix & List<&2, U32>:
  match on:
    case True{}:
      heard.out(out, N.render(N.tic(m, g)))
    case False{}:
      (m, out)

def runs.next?(n: Nat, +g: S.Sim, +keys: U32, +h: U32, +on: Bool, r: N.Mix & List<&2, U32>) -> Run & (N.Mix & List<&2, U32>):
  (m, +out) = r
  runs(n, Bool.not(stopped(g)), quiet(g), keys, h, on, m, out)

def runs?(n: Nat, more: Bool, +g: S.Sim, +keys: U32, +h: U32, +on: Bool, m: N.Mix, +out: List<&2, U32>) -> Run & (N.Mix & List<&2, U32>):
  match n more:
    case 1n+p True{}:
      +h1 = Bool.pick(U32, held(keys, 12), (h + 1 : U32), 0)
      +g1 = Q.tick(cmd(U.ui.set(g, 250, 0), keys, h1, U.ui(g, 250)))
      runs.next(p, g1, keys, h1, on, heard(on, m, g1, out))
    case _ _:
      (Run{g, h}, (m, out))

def reload(+old: S.Sim, +path: String, +keys: U32, +t0: U32, +tics: U32, au: Au, p: S.Sim & Array<U32>) -> IO(Maybe<Game>):
  (+g, rom) = p
  +g1 = Q.adopt(old, g)
  IO.pure(Maybe<Game>, Some{Game{g1, Q.fuzz.put(g1, rom), path, keys, t0, tics, 0, au}})

def boot.now(+g: S.Sim, +path: String, +keys: U32, +t0: U32, +tics: U32, au: Au) -> IO(Maybe<Game>):
  IO.bind(S.Sim & Array<U32>, Maybe<Game>, B.boot(path, Q.target(g), Q.player(g), Q.carry(g)), p => reload(g, path, keys, t0, tics, au, p))

def demo.boot(+old: S.Sim, +path: String, +keys: U32, +t0: U32, +tics: U32, au: Au, +bs: List<&2, U32>) -> IO(Maybe<Game>):
  boot.now(Q.demo.loaded(old, bs), path, keys, t0, tics, au)

def kept(+g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, au: Au) -> IO(Maybe<Game>):
  IO.pure(Maybe<Game>, Some{Game{g, rom, path, keys, t0, tics, h, au}})

def restored(+path: String, +keys: U32, +t0: U32, +tics: U32, au: Au, p: S.Sim & Array<U32>) -> IO(Maybe<Game>):
  (+g, rom) = p
  IO.pure(Maybe<Game>, Some{Game{g, Q.fuzz.put(g, rom), path, keys, t0, tics, 0, au}})

def settle.load(c4: Bool, c5: Bool, c6: Bool, c7: Bool, +g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, au: Au) -> IO(Maybe<Game>):
  match c4 c5 c6 c7:
    case True{} _ _ _:
      IO.bind(List<&2, U32>, Maybe<Game>, B.demolump(path, Q.demo.lump(g)), +bs => demo.boot(Q.fuzz.keep(g, rom), path, keys, t0, tics, au, bs))
    case False{} True{} _ _:
      IO.bind(S.Sim, Maybe<Game>, Dk.strings(g), +g1 => kept(g1, rom, path, keys, t0, tics, h, au))
    case False{} False{} True{} _:
      IO.bind(S.Sim & Array<U32>, Maybe<Game>, Dk.load(Q.fuzz.keep(g, rom), path), p => restored(path, keys, t0, tics, au, p))
    case False{} False{} False{} True{}:
      IO.bind(S.Sim, Maybe<Game>, Dk.write(g), +g1 => kept(g1, rom, path, keys, t0, tics, h, au))
    case _ _ _ _:
      boot.now(Q.fuzz.keep(g, rom), path, keys, t0, tics, au)

def closed(u: Unit) -> IO(Maybe<Game>):
  IO.pure(Maybe<Game>, None{})

def shut.dev(dev: Maybe<Audio>) -> IO(Maybe<Game>):
  match dev:
    case Some{a}:
      IO.bind(Unit, Maybe<Game>, Audio.close(a), u => closed(u))
    case None{}:
      closed(Unit{})

def shut(au: Au) -> IO(Maybe<Game>):
  match au:
    case Au{dev, m}:
      shut.dev(dev)

def settle.go(quit: Bool, load: Bool, +g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, au: Au) -> IO(Maybe<Game>):
  match quit load:
    case True{} _:
      shut(au)
    case False{} True{}:
      +c = Q.pending(g)
      settle.load(U32.is_eq(c, 4), U32.is_eq(c, 5), U32.is_eq(c, 6), U32.is_eq(c, 7), g, rom, path, keys, t0, tics, h, au)
    case False{} False{}:
      IO.pure(Maybe<Game>, Some{Game{g, rom, path, keys, t0, tics, h, au}})

def settle(+g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, au: Au) -> IO(Maybe<Game>):
  settle.go(Q.quit(g), U32.is_ne(Q.pending(g), 0), g, rom, path, keys, t0, tics, h, au)

def written(m: N.Mix, r: Audio & U32) -> IO(Au):
  (a, q) = r
  IO.pure(Au, Au{Some{a}, m})

def play.out(dev: Maybe<Audio>, m: N.Mix, +out: List<&2, U32>) -> IO(Au):
  match dev out:
    case Some{a} +x <> +t:
      IO.bind(Audio & U32, Au, Audio.write(a, N.pcm(x <> t)), r => written(m, r))
    case d _:
      IO.pure(Au, Au{d, m})

def ran.out(+g: S.Sim, +h: U32, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, au: Au) -> IO(Maybe<Game>):
  settle(g, rom, path, keys, t0, tics, h, au)

def ran.go(r: Run, q: N.Mix & List<&2, U32>, dev: Maybe<Audio>, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32) -> IO(Maybe<Game>):
  match r:
    case Run{+g, +h}:
      (m, +out) = q
      IO.bind(Au, Maybe<Game>, play.out(dev, m, out), au => ran.out(g, h, rom, path, keys, t0, tics, au))

def ran(p: Run & (N.Mix & List<&2, U32>), dev: Maybe<Audio>, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32) -> IO(Maybe<Game>):
  (r, q) = p
  ran.go(r, q, dev, rom, path, keys, t0, tics)

def live(dev: Maybe<Audio>) -> Maybe<Audio> & Bool:
  match dev:
    case Some{a}:
      (Some{a}, True{})
    case None{}:
      (None{}, False{})

def step.go(+g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, +now: U32, m: N.Mix, d: Maybe<Audio> & Bool) -> IO(Maybe<Game>):
  (dev, +on) = d
  +due = (((now - t0) * 35) / 1000 : U32)
  +lag = Bool.pick(U32, U32.is_gt(due, tics), (due - tics : U32), 0)
  +n = U32.min(lag, 4)
  ran(runs(U32.to_nat(n), Bool.not(stopped(g)), quiet(g), keys, h, on, N.heard(m, g), []), dev, rom, path, keys, t0, Bool.pick(U32, U32.is_gt(lag, 4), due, (tics + n : U32)))

def step(+g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, +now: U32, au: Au) -> IO(Maybe<Game>):
  match au:
    case Au{dev, m}:
      step.go(g, rom, path, keys, t0, tics, h, now, m, live(dev))

def advance(r: Run, g: Game) -> IO(Maybe<Game>):
  match r g:
    case Run{+s, +k} Game{old, rom, +path, ok, +t0, +tics, +h, au}:
      IO.bind(Nat, Maybe<Game>, IO.now(), now => step(s, rom, path, k, t0, tics, h, U32.from_nat(now), au))

def tick(es: List<Event>, g: Game) -> IO(Maybe<Game>):
  match g:
    case Game{+s, rom, +path, +k, +t0, +tics, +h, au}:
      advance(events(es, Run{s, k}), Game{s, rom, path, k, t0, tics, h, au})

def frame.fb(+s: S.Sim, +path: String, +k: U32, +t0: U32, +tics: U32, +h: U32, au: Au, r: Array<U32> & Array<U32>) -> Game & Array<U32>:
  (fb, rom) = r
  (Game{s, rom, path, k, t0, tics, h, au}, fb)

def frame.out(+path: String, +k: U32, +t0: U32, +tics: U32, +h: U32, au: Au, r: S.Sim & (Array<U32> & Array<U32>)) -> Game & Array<U32>:
  (+s, p) = r
  frame.fb(s, path, k, t0, tics, h, au, p)

def frame(g: Game) -> Game & Array<U32>:
  match g:
    case Game{+s, rom, +path, +k, +t0, +tics, +h, au}:
      frame.out(path, k, t0, tics, h, au, Q.render(s, rom))

def start(+s: S.Sim, rom: Array<U32>, +path: String, +now: U32, au: Au) -> Game:
  Game{s, rom, path, 0, now, 0, 0, au}

def wants(g: Game) -> Game & Bool:
  match g:
    case Game{+s, rom, +path, +k, +t0, +tics, +h, au}:
      (Game{s, rom, path, k, t0, tics, h, au}, Bool.and(U32.is_eq(S.sim.gs(s), 0), U32.is_eq(U.ui(s, 100), 0)))
