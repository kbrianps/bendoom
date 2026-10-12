import Base
import ./src/wad.bend as W
import ./src/screen.bend as S
import ./src/state.bend as M
import ./src/boot.bend as B
import ./src/play.bend as P
import ./src/flow.bend as Q
import ./src/sound.bend as N

def look.out(r: P.Game & Array<U32>) -> P.Game & Image:
  (g, fb) = r
  (g, S.image(fb))

def look(g: P.Game) -> P.Game & Image:
  look.out(P.frame(g))

def loop?(fuel: Nat, win: Window, g: P.Game) -> IO(Unit):
  match fuel:
    case 0n:
      Window.close(win)
    case 1n+f:
      App.step(P.Game, App{s => look(s), P.tick}, win, g, w => s => grabbed(f, w, P.wants(s)))

def grabbed?(fuel: Nat, win: Window, r: P.Game & Bool) -> IO(Unit):
  (g, on) = r
  IO.bind(Window, Unit, Window.grab(win, on), w => loop(fuel, w, g))

def opened(g: P.Game, r: Result<&1, &1, U32 & String, Window>) -> IO(Unit):
  match r:
    case Fail{(code, text)}:
      IO.die(Unit, 1, text)
    case Done{win}:
      loop(U32.to_nat(4294967295), win, g)

def timed(+path: String, au: P.Au, p: M.Sim & Array<U32>, now: Nat) -> IO(Unit):
  (s, rom) = p
  IO.bind(Result<&1, &1, U32 & String, Window>, Unit, Window.open("Doom", 640, 400), r => opened(P.start(s, rom, path, U32.from_nat(now), au), r))

def primed(m: N.Mix, r: Audio & U32) -> IO(P.Au):
  (a, q) = r
  IO.pure(P.Au, P.Au{Some{a}, m})

def device(m: N.Mix, r: Result<&1, &1, U32 & String, Audio>) -> IO(P.Au):
  match r:
    case Done{a}:
      IO.bind(Audio & U32, P.Au, Audio.write(a, N.pcm(N.silence())), q => primed(m, q))
    case Fail{(code, text)}:
      do IO<P.Au>:
        IO.print_err(String.append("sound: ", text))
        IO.pure(P.Au, P.Au{None{}, m})

def audio(+path: String) -> IO(P.Au):
  do IO<P.Au>:
    m : N.Mix <- N.load(path)
    r : Result<&1, &1, U32 & String, Audio> <- Audio.open(N.rate())
    device(m, r)

def play(+path: String, +title: Bool, +comfort: Bool, p: M.Sim & Array<U32>) -> IO(Unit):
  (+s0, rom) = p
  +s = Bool.pick(M.Sim, comfort, Q.comfort.on(s0), s0)
  do IO<Unit>:
    au : P.Au <- audio(path)
    IO.bind(Nat, Unit, IO.now(), now => timed(path, au, (Bool.pick(M.Sim, title, Q.boot.title(s), Q.boot.warp(s)), rom), now))

def args(xs: List<String>, +comfort: Bool) -> IO(Unit):
  match xs:
    case prog <> +path <> name <> t:
      IO.bind(M.Sim & Array<U32>, Unit, B.new(path, name), s => play(path, False{}, comfort, s))
    case prog <> +path <> t:
      IO.bind(M.Sim & Array<U32>, Unit, B.first(path), s => play(path, True{}, comfort, s))
    case _:
      IO.die(Unit, 2, "usage: doom FILE.wad [-file PWAD.wad ...] [-soundfont FONT.sf2] [-comfort] [MAP]")

def strip.keep(x: String, r: List<String> & Bool) -> List<String> & Bool:
  (ys, on) = r
  (x <> ys, on)

def strip.drop(r: List<String> & Bool) -> List<String> & Bool:
  (ys, on) = r
  (ys, True{})

def strip.put(hit: Bool, x: String, r: List<String> & Bool) -> List<String> & Bool:
  match hit:
    case True{}:
      strip.drop(r)
    case False{}:
      strip.keep(x, r)

def strip(xs: List<String>) -> List<String> & Bool:
  match xs:
    case +x <> t:
      strip.put(String.eq(x, "-comfort"), x, strip(t))
    case []:
      ([], False{})

def args.of(r: List<String> & Bool) -> IO(Unit):
  (xs, +on) = r
  args(xs, on)

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args.of(strip(W.cli(xs)))
