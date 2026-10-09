import Base
import ./bytes.bend as B

type Lump is Data:
  Lump{name: String, pos: U32, size: U32}

type Wad is Type:
  Wad{file: File, dir: List<&2, Lump>}

def dir(ws: List<&2, U32>) -> List<&2, Lump>:
  match ws:
    case a <> b <> c <> d <> e <> f <> g <> h <> t:
      Lump{B.name(e, f, g, h), B.u32(a, b), B.u32(c, d)} <> dir(t)
    case _:
      []

def magic(+a: U32, +b: U32) -> Bool:
  Bool.and(Bool.or(U32.is_eq(a, 22345), U32.is_eq(a, 22352)), U32.is_eq(b, 17473))

def head.ok(ok: Bool, n: U32, at: U32) -> Result<&1, &1, U32 & String, U32 & U32>:
  match ok:
    case True{}:
      Done{(n, at)}
    case False{}:
      Fail{(22, "not a WAD file")}

def head(ws: List<&2, U32>) -> Result<&1, &1, U32 & String, U32 & U32>:
  match ws:
    case a <> b <> c <> d <> e <> f <> t:
      head.ok(magic(a, b), B.u32(c, d), B.u32(e, f))
    case _:
      Fail{(22, "not a WAD file")}

def got(p: File & Result<&1, &1, U32 & String, List<&2, U32>>) -> IO(File & List<&2, U32>):
  (file, r) = p
  do IO<File & List<&2, U32>>:
    bs : List<&2, U32> <- IO.pass(List<&2, U32>, r)
    return (file, bs)

def read(file: File, at: U32, size: U32) -> IO(File & List<&2, U32>):
  do IO<File & List<&2, U32>>:
    p : File & Result<&1, &1, U32 & String, List<&2, U32>> <- File.read_at(file, at, size)
    got(p)

def open.dir(p: File & List<&2, U32>) -> IO(Wad):
  (file, bs) = p
  IO.pure(Wad, Wad{file, dir(B.words(bs))})

def open.at(file: File, h: U32 & U32) -> IO(Wad):
  (n, at) = h
  do IO<Wad>:
    q : File & List<&2, U32> <- read(file, at, (n * 16 : U32))
    open.dir(q)

def open.head(p: File & List<&2, U32>) -> IO(Wad):
  (file, bs) = p
  do IO<Wad>:
    h : U32 & U32 <- IO.pass(U32 & U32, head(B.words(bs)))
    open.at(file, h)

def open(path: String) -> IO(Wad):
  do IO<Wad>:
    file : File <- IO.try(File, File.open(path, "r"))
    p : File & List<&2, U32> <- read(file, 0, 12)
    open.head(p)

def close(w: Wad) -> IO(Unit):
  match w:
    case Wad{file, d}:
      File.close(file)

def named(+name: String, +l: Lump) -> Bool:
  match l:
    case Lump{n, at, size}:
      String.eq(n, name)

def find(ls: List<&2, Lump>, +name: String, acc: Lump) -> Lump:
  match ls:
    case +l <> t:
      find(t, name, Bool.pick(Lump, named(name, l), l, acc))
    case []:
      acc

def heads(+name: String, +ls: List<&2, Lump>) -> Bool:
  match ls:
    case l <> t:
      named(name, l)
    case []:
      False{}

def from.go(+ls: List<&2, Lump>, hit: Bool, +name: String) -> List<&2, Lump>:
  match ls hit:
    case l <> t True{}:
      l <> t
    case l <> t False{}:
      from.go(t, heads(name, t), name)
    case [] _:
      []

def from(+name: String, +ls: List<&2, Lump>) -> List<&2, Lump>:
  from.go(ls, heads(name, ls), name)

def lump.got(d: List<&2, Lump>, p: File & List<&2, U32>) -> Wad & List<&2, U32>:
  (file, bs) = p
  (Wad{file, d}, bs)

def lump(w: Wad, l: Lump) -> IO(Wad & List<&2, U32>):
  match w l:
    case Wad{file, d} Lump{n, at, size}:
      do IO<Wad & List<&2, U32>>:
        p : File & List<&2, U32> <- read(file, at, size)
        return lump.got(d, p)

def lumps.cons(bs: List<&2, U32>, r: Wad & List<&2, List<&2, U32>>) -> IO(Wad & List<&2, List<&2, U32>>):
  (w, xs) = r
  IO.pure(Wad & List<&2, List<&2, U32>>, (w, bs <> xs))

def lumps.step(p: Wad & List<&2, U32>, k: Wad -> IO(Wad & List<&2, List<&2, U32>>)) -> IO(Wad & List<&2, List<&2, U32>>):
  (w, bs) = p
  IO.bind(Wad & List<&2, List<&2, U32>>, Wad & List<&2, List<&2, U32>>, k(w), r => lumps.cons(bs, r))

def lumps(ls: List<&2, Lump>, w: Wad) -> IO(Wad & List<&2, List<&2, U32>>):
  match ls:
    case l <> t:
      IO.bind(Wad & List<&2, U32>, Wad & List<&2, List<&2, U32>>, lump(w, l), p => lumps.step(p, v => lumps(t, v)))
    case []:
      IO.pure(Wad & List<&2, List<&2, U32>>, (w, []))

def part(+ls: List<&2, Lump>, name: String) -> Lump:
  find(ls, name, Lump{"", 0, 0})

def maps.put(hit: Bool, l: Lump, rest: List<&2, Lump>) -> List<&2, Lump>:
  match hit:
    case True{}:
      l <> rest
    case False{}:
      rest

def maps(ls: List<&2, Lump>) -> List<&2, Lump>:
  match ls:
    case l <> +t:
      maps.put(heads("THINGS", t), l, maps(t))
    case []:
      []
