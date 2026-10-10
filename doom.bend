import Base
import ./src/screen.bend as S
import ./src/boot.bend as B
import ./src/play.bend as P

def look(+g: P.Game) -> P.Game & Image:
  (g, S.image(P.frame(g)))

def opened(+g: P.Game, r: Result<&1, &1, U32 & String, Window>) -> IO(Unit):
  match r:
    case Fail{(code, text)}:
      IO.die(Unit, 1, text)
    case Done{win}:
      App.loop(~P.Game, ~App{s => look(s), P.tick}, U32.to_nat(4294967295), win, g)

def play(s: B.Scene) -> IO(Unit):
  +g = P.start(s)
  IO.bind(Result<&1, &1, U32 & String, Window>, Unit, Window.open("Doom", 640, 400), r => opened(g, r))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> name <> t:
      IO.bind(B.Scene, Unit, B.boot(path, name), s => play(s))
    case prog <> path <> t:
      IO.bind(B.Scene, Unit, B.boot(path, "E1M1"), s => play(s))
    case _:
      IO.die(Unit, 2, "usage: doom FILE.wad [MAP]")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
