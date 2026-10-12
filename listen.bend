import Base
import ./src/hud.bend as U
import ./src/state.bend as S
import ./src/boot.bend as B
import ./src/flow.bend as Q
import ./src/tab.bend as T
import ./src/sound.bend as N
import ./src/wad.bend as W

def s16(+x: U32) -> U32:
  +v = (x - 1048576 : U32)
  +c = Bool.pick(U32, U32.is_lt((v + 32768 : U32), 65536), v, Bool.pick(U32, U32.is_ge(v, 2147483648), 32768, 32767))
  (c .&. 65535 : U32)

def bytes.go(xs: List<&2, U32>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      +v = s16(x)
      bytes.go(t, (v >> 8n : U32) <> (v .&. 255 : U32) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def bytes(xs: List<&2, U32>) -> List<&2, U32>:
  bytes.go(xs, [])

def le(+v: U32) -> List<&2, U32>:
  [(v .&. 255 : U32), ((v >> 8n) .&. 255 : U32), ((v >> 16n) .&. 255 : U32), (v >> 24n : U32)]

def header() -> List<&2, U32>:
  List.append(&2, U32, [82, 73, 70, 70], List.append(&2, U32, le(2147483647), List.append(&2, U32, [87, 65, 86, 69, 102, 109, 116, 32, 16, 0, 0, 0, 1, 0, 2, 0],
    List.append(&2, U32, le(N.rate()), List.append(&2, U32, le((N.rate() * 4 : U32)), List.append(&2, U32, [4, 0, 16, 0, 100, 97, 116, 97], le(2147483647)))))))

def wrote(p: File & Result<&1, &1, U32 & String, Unit>) -> IO(File):
  (f, r) = p
  IO.pure(File, f)

def put(f: File, bs: List<&2, U32>) -> IO(File):
  IO.bind(File & Result<&1, &1, U32 & String, Unit>, File, File.write_bytes(f, bs), p => wrote(p))

def quiet(+g: S.Sim) -> S.Sim:
  S.sim.snd.set(g, [])

def tic.out?(f: File, +g: S.Sim, rom: Array<U32>, +path: String, +n: U32, r: N.Mix & List<&2, U32>) -> IO(Unit):
  (m, acc) = r
  IO.bind(File, Unit, put(f, bytes(acc)), f1 => go(f1, quiet(g), rom, m, path, (n + 1 : U32)))

def tic?(f: File, +g: S.Sim, rom: Array<U32>, m: N.Mix, +path: String, +n: U32) -> IO(Unit):
  +g1 = Q.tick(g)
  tic.out(f, g1, rom, path, n, N.render(N.tic(m, g1)))

def booted?(f: File, +old: S.Sim, m: N.Mix, +path: String, +n: U32, p: S.Sim & Array<U32>) -> IO(Unit):
  (+g, rom) = p
  go(f, Q.adopt(old, g), rom, m, path, n)

def go.pick?(stop: Bool, boot: Bool, f: File, +g: S.Sim, rom: Array<U32>, m: N.Mix, +path: String, +n: U32) -> IO(Unit):
  match stop boot:
    case True{} _:
      File.close(f)
    case False{} True{}:
      IO.bind(S.Sim & Array<U32>, Unit, B.boot(path, Q.target(g), Q.player(g), Q.carry(g)), p => booted(f, g, m, path, n, p))
    case False{} False{}:
      tic(f, g, rom, m, path, n)

def go?(f: File, +g: S.Sim, rom: Array<U32>, m: N.Mix, +path: String, +n: U32) -> IO(Unit):
  +c = Q.pending(g)
  go.pick(Bool.or(Q.quit(g), U32.is_ge(c, 4)), U32.is_ne(c, 0), f, g, rom, m, path, n)

def begin?(f: File, m: N.Mix, +path: String, +bs: List<&2, U32>, p: S.Sim & Array<U32>) -> IO(Unit):
  (+g, rom) = p
  go(f, Q.demo.start(U.ui.set(g, 129, 1), T.from_list(U32, bs)), rom, m, path, 0)

def opened?(m: N.Mix, +path: String, name: String, +out: String, +bs: List<&2, U32>) -> IO(Unit):
  do IO<Unit>:
    f : File <- IO.try(File, File.open(out, "w"))
    f1 : File <- put(f, header())
    IO.bind(S.Sim & Array<U32>, Unit, B.skilled(path, name, Maybe.default(&2, U32, List.get(&2, U32, bs, 1n), 2)), p => begin(f1, m, path, bs, p))

def loaded?(+path: String, name: String, +out: String, r: File & Result<&1, &1, U32 & String, List<&2, U32>>) -> IO(Unit):
  (f, res) = r
  do IO<Unit>:
    File.close(f)
    +bs : List<&2, U32> <- IO.pass(List<&2, U32>, res)
    m : N.Mix <- N.load(path)
    opened(m, path, name, out, bs)

def args?(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> +path <> name <> lmp <> +out <> t:
      do IO<Unit>:
        f : File <- IO.try(File, File.open(lmp, "r"))
        r : File & Result<&1, &1, U32 & String, List<&2, U32>> <- File.read_at(f, 0, 4194304)
        loaded(path, name, out, r)
    case _:
      IO.die(Unit, 2, "usage: listen FILE.wad [-file PWAD.wad ...] [-soundfont FONT.sf2] MAP DEMO.lmp OUT.wav")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(W.cli(xs))
