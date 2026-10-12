import Base
import ./src/music.bend as M
import ./src/wad.bend as W

def le.go(n: Nat, +v: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      List.reverse(&2, U32, acc)
    case 1n+p:
      le.go(p, (v >> 8n : U32), (v .&. 255 : U32) <> acc)

def le(n: Nat, +v: U32) -> List<&2, U32>:
  le.go(n, v, [])

def header(+ch: U32, +rate: U32) -> List<&2, U32>:
  List.append(&2, U32, [82, 73, 70, 70], List.append(&2, U32, le(4n, 2147483647), List.append(&2, U32, [87, 65, 86, 69, 102, 109, 116, 32, 16, 0, 0, 0, 1, 0, ch, 0],
    List.append(&2, U32, le(4n, rate), List.append(&2, U32, le(4n, (rate * ch * 2 : U32)), List.append(&2, U32, [(ch * 2 : U32), 0, 16, 0, 100, 97, 116, 97], le(4n, 2147483647)))))))

def bytes.go(xs: List<&2, U32>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +v <> t:
      bytes.go(t, ((v >> 8n) .&. 255 : U32) <> (v .&. 255 : U32) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def bytes(xs: List<&2, U32>) -> List<&2, U32>:
  bytes.go(xs, [])

def wrote(p: File & Result<&1, &1, U32 & String, Unit>) -> IO(File):
  (f, r) = p
  IO.pure(File, f)

def put(f: File, bs: List<&2, U32>) -> IO(File):
  IO.bind(File & Result<&1, &1, U32 & String, Unit>, File, File.write_bytes(f, bs), p => wrote(p))

def loop?(n: Nat, f: File, m: M.Mu) -> IO(Unit):
  match n:
    case 0n:
      File.close(f)
    case 1n+p:
      loop.out(p, f, M.raw(m))

def loop.out?(n: Nat, f: File, r: M.Mu & List<&2, U32>) -> IO(Unit):
  (m, xs) = r
  IO.bind(File, Unit, put(f, bytes(xs)), f1 => loop(n, f1, m))

def go.with(+id: U32, +tics: U32, +out: String, r: M.Mu & U32) -> IO(Unit):
  (m, +k) = r
  do IO<Unit>:
    f : File <- IO.try(File, File.open(out, "w"))
    f1 : File <- put(f, header(Bool.pick(U32, U32.is_eq(k, 0), 1, 2), Bool.pick(U32, U32.is_eq(k, 2), 22050, 11025)))
    loop(U32.to_nat(tics), f1, M.start(m, id, 1))

def go(m: M.Mu, +id: U32, +tics: U32, +out: String) -> IO(Unit):
  go.with(id, tics, out, M.form(m))

def pick(known: Bool, m: M.Mu, +id: U32, +tics: U32, +out: String) -> IO(Unit):
  match known:
    case True{}:
      go(m, id, tics, out)
    case False{}:
      IO.die(Unit, 1, "song: not a Doom music lump")

def named(+name: String, +secs: U32, +out: String, m: M.Mu) -> IO(Unit):
  +id = M.find(M.names(), name, 1)
  pick(U32.is_ne(id, 0), m, id, (secs * 35 : U32), out)

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case prog <> path <> +name <> secs <> +out <> t:
      IO.bind(M.Mu, Unit, M.load(path), m => named(name, Maybe.default(&2, U32, U32.read(secs), 10), out, m))
    case _:
      IO.die(Unit, 2, "usage: song FILE.wad [-file PWAD.wad ...] [-soundfont FONT.sf2] LUMP SECONDS OUT.wav")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(W.cli(xs))
