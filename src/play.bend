import Base
import ./fixed.bend as F
import ./world.bend as R
import ./render.bend as V
import ./boot.bend as B

type Game is Data:
  Game{scene: B.Scene, view: V.View, keys: U32}

def code.bit(+c: U32) -> U32:
  Bool.pick(U32, Bool.or(U32.is_eq(c, 63232), U32.is_eq(c, 119)), 1,
    Bool.pick(U32, Bool.or(U32.is_eq(c, 63233), U32.is_eq(c, 115)), 2,
      Bool.pick(U32, U32.is_eq(c, 63234), 4,
        Bool.pick(U32, U32.is_eq(c, 63235), 8,
          Bool.pick(U32, Bool.or(U32.is_eq(c, 44), U32.is_eq(c, 97)), 16,
            Bool.pick(U32, Bool.or(U32.is_eq(c, 46), U32.is_eq(c, 100)), 32,
              Bool.pick(U32, Bool.or(U32.is_eq(c, 65592), U32.is_eq(c, 65596)), 64, 0)))))))

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

def axis(+keys: U32, +pos: U32, +neg: U32, +amount: U32) -> U32:
  (Bool.pick(U32, held(keys, pos), amount, 0) - Bool.pick(U32, held(keys, neg), amount, 0) : U32)

def speed(+keys: U32, +walk: U32) -> U32:
  Bool.pick(U32, held(keys, 64), (walk * 2 : U32), walk)

def thrust.x(+tb: V.Tabs, +a: U32, +m: U32) -> U32:
  F.mul(m, V.sine(tb, ((a >> 19n) + 2048 : U32)))

def thrust.y(+tb: V.Tabs, +a: U32, +m: U32) -> U32:
  F.mul(m, V.sine(tb, (a >> 19n : U32)))

def moved.to(+w: R.World, +a: U32, +e: U32, +nx: U32, +ny: U32) -> V.View:
  V.View{nx, ny, (V.floor.at(w, nx, ny) + B.eye() : U32), a, e}

def moved(+w: R.World, v: V.View, +dx: U32, +dy: U32) -> V.View:
  match v:
    case V.View{+x, +y, z, +a, +e}:
      moved.to(w, a, e, (x + dx : U32), (y + dy : U32))

def turned(+keys: U32, +v: V.View) -> V.View:
  match v:
    case V.View{x, y, z, a, e}:
      V.View{x, y, z, (a + axis(keys, 4, 8, speed(keys, 41943040)) : U32), e}

def step.go(+tb: V.Tabs, +w: R.World, +keys: U32, +t: V.View, +a: U32) -> V.View:
  +f = axis(keys, 1, 2, speed(keys, 524288))
  +r = axis(keys, 32, 16, speed(keys, 393216))
  +b = (a - 1073741824 : U32)
  moved(w, t, (thrust.x(tb, a, f) + thrust.x(tb, b, r) : U32), (thrust.y(tb, a, f) + thrust.y(tb, b, r) : U32))

def angle.of(+v: V.View) -> U32:
  match v:
    case V.View{x, y, z, a, e}:
      a

def step(+tb: V.Tabs, +w: R.World, +keys: U32, +v: V.View) -> V.View:
  +t = turned(keys, v)
  step.go(tb, w, keys, t, angle.of(t))

def advance(m: Maybe<U32>, +s: B.Scene, +v: V.View) -> Maybe<Game>:
  match m s:
    case Some{+k} B.Scene{+tb, +w}:
      Some{Game{s, step(tb, w, k, v), k}}
    case None{} _:
      None{}

def tick(es: List<Event>, g: Game) -> IO(Maybe<Game>):
  match g:
    case Game{+s, +v, +k}:
      IO.pure(Maybe<Game>, advance(events(es, k), s, v))

def frame(+g: Game) -> Array<U32>:
  match g:
    case Game{B.Scene{+tb, +w}, +v, k}:
      V.render(tb, w, v)

def start(+s: B.Scene) -> Game:
  match s:
    case B.Scene{tb, +w}:
      Game{s, B.spawn(w), 0}
