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

type Game is Type:
  Game{sim: S.Sim, rom: Array<U32>, path: String, keys: U32, t0: U32, tics: U32, held: U32}

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

def event(+e: Event, +r: Run) -> Run:
  match e r:
    case Key{+c, +d} Run{+g, +k}:
      +g1 = Q.respond(g, c, d)
      Run{g1, Bool.pick(U32, Q.eaten(g1), k, press(k, c, d))}
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

def cmd(+g: S.Sim, +keys: U32, +turnheld: U32) -> S.Sim:
  +run = held(keys, 64)
  +tspeed = Bool.pick(U32, U32.is_lt(turnheld, 6), 320, Bool.pick(U32, run, 1280, 640))
  +turn = amount(keys, 4, 8, tspeed)
  +fwd = amount(keys, 1, 2, Bool.pick(U32, run, 50, 25))
  +side = amount(keys, 32, 16, Bool.pick(U32, run, 40, 24))
  +bt = (Bool.pick(U32, held(keys, 65536), 1, 0) .|. Bool.pick(U32, held(keys, 128), 2, 0) .|. weapon(7n, keys, 0) : U32)
  S.p.buttons.set(S.p.side.set(S.p.fwd.set(S.p.turn.set(g, turn), fwd), side), bt)

def done(+g: S.Sim) -> Bool:
  Bool.or(U32.is_ne(S.sim.exit(g), 0), U32.is_eq(S.p.state(g), 2))

def steps(n: Nat, more: Bool, +g: S.Sim, +keys: U32, +h: U32) -> S.Sim:
  match n more:
    case 1n+p True{}:
      +h1 = Bool.pick(U32, held(keys, 12), (h + 1 : U32), 0)
      +g1 = K.ticker(cmd(g, keys, h1))
      steps(p, Bool.not(done(g1)), g1, keys, h1)
    case _ _:
      g

def stopped(+g: S.Sim) -> Bool:
  Bool.or(U32.is_ne(Q.pending(g), 0), Q.quit(g))

def runs(n: Nat, more: Bool, +g: S.Sim, +keys: U32, +h: U32) -> Run:
  match n more:
    case 1n+p True{}:
      +h1 = Bool.pick(U32, held(keys, 12), (h + 1 : U32), 0)
      +g1 = Q.tick(cmd(g, keys, h1))
      runs(p, Bool.not(stopped(g1)), g1, keys, h1)
    case _ _:
      Run{g, h}

def reload(+old: S.Sim, +path: String, +keys: U32, +t0: U32, +tics: U32, p: S.Sim & Array<U32>) -> IO(Maybe<Game>):
  (+g, rom) = p
  IO.pure(Maybe<Game>, Some{Game{Q.adopt(old, g), rom, path, keys, t0, tics, 0}})

def settle.go(quit: Bool, load: Bool, +g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32) -> IO(Maybe<Game>):
  match quit load:
    case True{} _:
      IO.pure(Maybe<Game>, None{})
    case False{} True{}:
      IO.bind(S.Sim & Array<U32>, Maybe<Game>, B.boot(path, Q.target(g), Q.player(g), Q.carry(g)), p => reload(g, path, keys, t0, tics, p))
    case False{} False{}:
      IO.pure(Maybe<Game>, Some{Game{g, rom, path, keys, t0, tics, h}})

def settle(+g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32) -> IO(Maybe<Game>):
  settle.go(Q.quit(g), U32.is_ne(Q.pending(g), 0), g, rom, path, keys, t0, tics, h)

def ran(r: Run, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32) -> IO(Maybe<Game>):
  match r:
    case Run{+g, +h}:
      settle(g, rom, path, keys, t0, tics, h)

def step(+g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, +now: U32) -> IO(Maybe<Game>):
  +due = (((now - t0) * 35) / 1000 : U32)
  +lag = Bool.pick(U32, U32.is_gt(due, tics), (due - tics : U32), 0)
  +n = U32.min(lag, 4)
  ran(runs(U32.to_nat(n), Bool.not(stopped(g)), g, keys, h), rom, path, keys, t0, Bool.pick(U32, U32.is_gt(lag, 4), due, (tics + n : U32)))

def advance(r: Run, g: Game) -> IO(Maybe<Game>):
  match r g:
    case Run{+s, +k} Game{old, rom, +path, ok, +t0, +tics, +h}:
      IO.bind(Nat, Maybe<Game>, IO.now(), now => step(s, rom, path, k, t0, tics, h, U32.from_nat(now)))

def tick(es: List<Event>, g: Game) -> IO(Maybe<Game>):
  match g:
    case Game{+s, rom, +path, +k, +t0, +tics, +h}:
      advance(events(es, Run{s, k}), Game{s, rom, path, k, t0, tics, h})

def frame.fb(+s: S.Sim, +path: String, +k: U32, +t0: U32, +tics: U32, +h: U32, r: Array<U32> & Array<U32>) -> Game & Array<U32>:
  (fb, rom) = r
  (Game{s, rom, path, k, t0, tics, h}, fb)

def frame.out(+path: String, +k: U32, +t0: U32, +tics: U32, +h: U32, r: S.Sim & (Array<U32> & Array<U32>)) -> Game & Array<U32>:
  (+s, p) = r
  frame.fb(s, path, k, t0, tics, h, p)

def frame(g: Game) -> Game & Array<U32>:
  match g:
    case Game{+s, rom, +path, +k, +t0, +tics, +h}:
      frame.out(path, k, t0, tics, h, Q.render(s, rom))

def start(+s: S.Sim, rom: Array<U32>, +path: String, +now: U32) -> Game:
  Game{s, rom, path, 0, now, 0, 0}
