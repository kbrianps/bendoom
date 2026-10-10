import Base
import ./src/screen.bend as S
import ./src/state.bend as M
import ./src/boot.bend as B
import ./src/play.bend as P
import ./src/flow.bend as Q

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

def timed(+path: String, p: M.Sim & Array<U32>, now: Nat) -> IO(Unit):
  (s, rom) = p
  IO.bind(Result<&1, &1, U32 & String, Window>, Unit, Window.open("Doom", 640, 400), r => opened(P.start(s, rom, path, U32.from_nat(now)), r))

def play(+path: String, +title: Bool, p: M.Sim & Array<U32>) -> IO(Unit):
  (+s, rom) = p
  IO.bind(Nat, Unit, IO.now(), now => timed(path, (Bool.pick(M.Sim, title, Q.boot.title(s), Q.boot.warp(s)), rom), now))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> +path <> name <> t:
      IO.bind(M.Sim & Array<U32>, Unit, B.new(path, name), s => play(path, False{}, s))
    case prog <> +path <> t:
      IO.bind(M.Sim & Array<U32>, Unit, B.first(path), s => play(path, True{}, s))
    case _:
      IO.die(Unit, 2, "usage: doom FILE.wad [MAP]")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
