import Base
import ./src/music.bend as M

def le(n: Nat, +v: U32) -> List<&2, U32>:
  match n:
    case 0n:
      []
    case 1n+p:
      (v .&. 255 : U32) <> le(p, (v >> 8n : U32))

def header() -> List<&2, U32>:
  List.append(&2, U32, [82, 73, 70, 70], List.append(&2, U32, le(4n, 2147483647), List.append(&2, U32, [87, 65, 86, 69, 102, 109, 116, 32, 16, 0, 0, 0, 1, 0, 1, 0],
    List.append(&2, U32, le(4n, 11025), List.append(&2, U32, le(4n, 22050), List.append(&2, U32, [2, 0, 16, 0, 100, 97, 116, 97], le(4n, 2147483647)))))))

def bytes(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +v <> t:
      (v .&. 255 : U32) <> ((v >> 8n) .&. 255 : U32) <> bytes(t)
    case []:
      []

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

def go(m: M.Mu, +id: U32, +tics: U32, +out: String) -> IO(Unit):
  do IO<Unit>:
    f : File <- IO.try(File, File.open(out, "w"))
    f1 : File <- put(f, header())
    loop(U32.to_nat(tics), f1, M.start(m, id, 1))

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
      IO.die(Unit, 2, "usage: song FILE.wad LUMP SECONDS OUT.wav")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
