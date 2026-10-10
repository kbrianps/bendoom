import Base
import ./hud.bend as U
import ./tab.bend as T
import ./fixed.bend as F
import ./state.bend as S
import ./sim.bend as C
import ./game.bend as K
import ./boot.bend as B
import ./draw.bend as D

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

def quits(+e: Event) -> Bool:
  match e:
    case Key{+c, +d}:
      Bool.and(U32.is_eq(c, 27), d)
    case Close{}:
      True{}
    case _:
      False{}

def event(+e: Event, +keys: U32) -> U32:
  match e:
    case Key{+c, +d}:
      press(keys, c, d)
    case _:
      keys

def events.go(es: List<Event>, +keys: U32, +quit: Bool) -> U32 & Bool:
  match es:
    case +e <> t:
      events.go(t, event(e, keys), Bool.or(quit, quits(e)))
    case []:
      (keys, quit)

def alive(r: U32 & Bool) -> Maybe<U32>:
  (k, q) = r
  Bool.pick(Maybe<U32>, q, None{}, Some{k})

def events(es: List<Event>, +keys: U32) -> Maybe<U32>:
  alive(events.go(es, keys, False{}))

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

def runs(n: Nat, more: Bool, +g: S.Sim, +keys: U32, +h: U32) -> Run:
  match n more:
    case 1n+p True{}:
      +h1 = Bool.pick(U32, held(keys, 12), (h + 1 : U32), 0)
      +g1 = K.ticker(cmd(g, keys, h1))
      runs(p, Bool.not(done(g1)), g1, keys, h1)
    case _ _:
      Run{g, h}

def digit(+d: U32) -> String:
  T.get(String, T.from_list(String, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]), d, "0")

def mapname(+com: Bool, +ep: U32, +map: U32) -> String:
  Bool.pick(String, com, String.append("MAP", String.append(digit((map / 10 : U32)), digit((map % 10 : U32)))),
    String.append("E", String.append(digit(ep), String.append("M", digit(map)))))

def back9(+ep: U32) -> U32:
  Bool.pick(U32, U32.is_eq(ep, 1), 4, Bool.pick(U32, U32.is_eq(ep, 2), 6, Bool.pick(U32, U32.is_eq(ep, 3), 7, 3)))

def next.doom(+ep: U32, +map: U32, +secret: Bool) -> String:
  +nep = Bool.pick(U32, U32.is_eq(ep, 4), 1, (ep + 1 : U32))
  Bool.pick(String, secret, mapname(False{}, ep, 9),
    Bool.pick(String, U32.is_eq(map, 9), mapname(False{}, ep, back9(ep)),
      Bool.pick(String, U32.is_eq(map, 8), mapname(False{}, nep, 1), mapname(False{}, ep, (map + 1 : U32)))))

def next.doom2(+map: U32, +secret: Bool) -> String:
  +n = Bool.pick(U32, secret, Bool.pick(U32, U32.is_eq(map, 15), 31, 32),
    Bool.pick(U32, Bool.or(U32.is_eq(map, 31), U32.is_eq(map, 32)), 16, Bool.pick(U32, U32.is_eq(map, 30), 1, (map + 1 : U32))))
  mapname(True{}, 1, n)

def next(+g: S.Sim) -> String:
  +secret = U32.is_eq(S.sim.exit(g), 2)
  Bool.pick(String, S.mp.commercial(g), next.doom2(S.mp.map(g), secret), next.doom(S.mp.episode(g), S.mp.map(g), secret))

def finish(+g: S.Sim) -> T.Vec<U32>:
  +g1 = S.p.pw5.set(S.p.pw4.set(S.p.pw3.set(S.p.pw2.set(S.p.pw1.set(S.p.pw0.set(g, 0), 0), 0), 0), 0), 0)
  S.sim.pl(S.p.bonuscount.set(S.p.damagecount.set(S.p.fixedcm.set(S.p.extralight.set(S.p.cards.set(g1, 0), 0), 0), 0), 0))

def here(+g: S.Sim) -> String:
  mapname(S.mp.commercial(g), S.mp.episode(g), S.mp.map(g))

def reload(+path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, p: S.Sim & Array<U32>) -> IO(Maybe<Game>):
  (g, rom) = p
  IO.pure(Maybe<Game>, Some{Game{g, rom, path, keys, t0, tics, h}})

def settle.go(ex: Bool, re: Bool, +g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32) -> IO(Maybe<Game>):
  match ex re:
    case True{} _:
      IO.bind(S.Sim & Array<U32>, Maybe<Game>, B.boot(path, next(g), finish(g), S.sim.rnd(g)), p => reload(path, keys, t0, tics, 0, p))
    case False{} True{}:
      IO.bind(S.Sim & Array<U32>, Maybe<Game>, B.boot(path, here(g), S.sim.pl(g), S.sim.rnd(g)), p => reload(path, keys, t0, tics, 0, p))
    case False{} False{}:
      IO.pure(Maybe<Game>, Some{Game{g, rom, path, keys, t0, tics, h}})

def settle(+g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32) -> IO(Maybe<Game>):
  settle.go(U32.is_ne(S.sim.exit(g), 0), U32.is_eq(S.p.state(g), 2), g, rom, path, keys, t0, tics, h)

def ran(r: Run, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32) -> IO(Maybe<Game>):
  match r:
    case Run{+g, +h}:
      settle(g, rom, path, keys, t0, tics, h)

def step(+g: S.Sim, rom: Array<U32>, +path: String, +keys: U32, +t0: U32, +tics: U32, +h: U32, +now: U32) -> IO(Maybe<Game>):
  +due = (((now - t0) * 35) / 1000 : U32)
  +lag = Bool.pick(U32, U32.is_gt(due, tics), (due - tics : U32), 0)
  +n = U32.min(lag, 4)
  ran(runs(U32.to_nat(n), True{}, g, keys, h), rom, path, keys, t0, Bool.pick(U32, U32.is_gt(lag, 4), due, (tics + n : U32)))

def advance(m: Maybe<U32>, g: Game) -> IO(Maybe<Game>):
  match m g:
    case Some{+k} Game{+s, rom, +path, ok, +t0, +tics, +h}:
      IO.bind(Nat, Maybe<Game>, IO.now(), now => step(s, rom, path, k, t0, tics, h, U32.from_nat(now)))
    case None{} _:
      IO.pure(Maybe<Game>, None{})

def tick(es: List<Event>, g: Game) -> IO(Maybe<Game>):
  match g:
    case Game{+s, rom, +path, +k, +t0, +tics, +h}:
      advance(events(es, k), Game{s, rom, path, k, t0, tics, h})

def frame.out(+s: S.Sim, +path: String, +k: U32, +t0: U32, +tics: U32, +h: U32, r: Array<U32> & Array<U32>) -> Game & Array<U32>:
  (fb, rom) = r
  (Game{s, rom, path, k, t0, tics, h}, fb)

def frame(g: Game) -> Game & Array<U32>:
  match g:
    case Game{+s, rom, +path, +k, +t0, +tics, +h}:
      frame.out(s, path, k, t0, tics, h, U.render(s, rom))

def start(+s: S.Sim, rom: Array<U32>, +path: String, +now: U32) -> Game:
  Game{s, rom, path, 0, now, 0, 0}

def run.of(+r: Run) -> S.Sim:
  match r:
    case Run{+g, h}:
      g
