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

def opened(g: P.Game, r: Result<&1, &1, U32 & String, Window>) -> IO(Unit):
  match r:
    case Fail{(code, text)}:
      IO.die(Unit, 1, text)
    case Done{win}:
      App.loop(~P.Game, ~App{s => look(s), P.tick}, U32.to_nat(4294967295), win, g)

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

def play(+path: String, +title: Bool, p: M.Sim & Array<U32>) -> IO(Unit):
  (+s, rom) = p
  do IO<Unit>:
    au : P.Au <- audio(path)
    IO.bind(Nat, Unit, IO.now(), now => timed(path, au, (Bool.pick(M.Sim, title, Q.boot.title(s), Q.boot.warp(s)), rom), now))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> +path <> name <> t:
      IO.bind(M.Sim & Array<U32>, Unit, B.new(path, name), s => play(path, False{}, s))
    case prog <> +path <> t:
      IO.bind(M.Sim & Array<U32>, Unit, B.first(path), s => play(path, True{}, s))
    case _:
      IO.die(Unit, 2, "usage: doom FILE.wad [-file PWAD.wad ...] [-soundfont FONT.sf2] [MAP]")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(W.cli(xs))
