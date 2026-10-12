import Base
import ./bytes.bend as B

type Lump is Data:
  Lump{name: String, pos: U32, size: U32, src: U32}

type Wad is Type:
  Wad{file: File, more: List<&2, String>, dir: List<&2, Lump>}

def dir.go(ws: List<&2, U32>, +src: U32, acc: List<&2, Lump>) -> List<&2, Lump>:
  match ws:
    case a <> b <> c <> d <> e <> f <> g <> h <> t:
      dir.go(t, src, Lump{B.name(e, f, g, h), B.u32(a, b), B.u32(c, d), src} <> acc)
    case _:
      List.reverse(&2, Lump, acc)

def dir(ws: List<&2, U32>, +src: U32) -> List<&2, Lump>:
  dir.go(ws, src, [])

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

def add.fin(w: Wad, f: File, bs: List<&2, U32>, +k: U32) -> IO(Wad):
  match w:
    case Wad{file, more, d}:
      do IO<Wad>:
        File.close(f)
        return Wad{file, more, List.append(&2, Lump, d, dir(B.words(bs), k))}

def add.dir(w: Wad, q: File & List<&2, U32>, +k: U32) -> IO(Wad):
  (f, bs) = q
  add.fin(w, f, bs, k)

def add.at(w: Wad, f: File, h: U32 & U32, +k: U32) -> IO(Wad):
  (n, at) = h
  do IO<Wad>:
    q : File & List<&2, U32> <- read(f, at, (n * 16 : U32))
    add.dir(w, q, k)

def add.head(w: Wad, p: File & List<&2, U32>, +k: U32) -> IO(Wad):
  (f, bs) = p
  do IO<Wad>:
    h : U32 & U32 <- IO.pass(U32 & U32, head(B.words(bs)))
    add.at(w, f, h, k)

def add(w: Wad, path: String, +k: U32) -> IO(Wad):
  do IO<Wad>:
    f : File <- IO.try(File, File.open(path, "r"))
    p : File & List<&2, U32> <- read(f, 0, 12)
    add.head(w, p, k)

def adds(ps: List<&2, String>, +k: U32, w: Wad) -> IO(Wad):
  match ps:
    case p <> t:
      IO.bind(Wad, Wad, add(w, p, k), v => adds(t, (k + 1 : U32), v))
    case []:
      IO.pure(Wad, w)

def open.dir(p: File & List<&2, U32>, +more: List<&2, String>) -> IO(Wad):
  (file, bs) = p
  adds(more, 1, Wad{file, more, dir(B.words(bs), 0)})

def open.at(file: File, h: U32 & U32, +more: List<&2, String>) -> IO(Wad):
  (n, at) = h
  do IO<Wad>:
    q : File & List<&2, U32> <- read(file, at, (n * 16 : U32))
    open.dir(q, more)

def open.head(p: File & List<&2, U32>, +more: List<&2, String>) -> IO(Wad):
  (file, bs) = p
  do IO<Wad>:
    h : U32 & U32 <- IO.pass(U32 & U32, head(B.words(bs)))
    open.at(file, h, more)

def open.paths(ps: List<&2, String>) -> IO(Wad):
  match ps:
    case path <> more:
      do IO<Wad>:
        file : File <- IO.try(File, File.open(path, "r"))
        p : File & List<&2, U32> <- read(file, 0, 12)
        open.head(p, more)
    case []:
      IO.die(Wad, 2, "no WAD file")

def sf2(+p: String) -> Bool:
  String.ends_with(String.to_lower(p), ".sf2")

def wads(ps: List<&2, String>) -> List<&2, String>:
  match ps:
    case +p <> +t:
      Bool.pick(List<&2, String>, sf2(p), wads(t), p <> wads(t))
    case []:
      []

def fonts(ps: List<&2, String>) -> String:
  match ps:
    case +p <> +t:
      Bool.pick(String, sf2(p), p, fonts(t))
    case []:
      ""

def font(+path: String) -> String:
  fonts(String.split(path, '\n'))

def open(path: String) -> IO(Wad):
  open.paths(wads(String.split(path, '\n')))

def join(+iwad: String, +pwads: List<&2, String>) -> String:
  String.join(iwad <> pwads, "\n")

def close(w: Wad) -> IO(Unit):
  match w:
    case Wad{file, m, d}:
      File.close(file)

def named(+name: String, +l: Lump) -> Bool:
  match l:
    case Lump{n, at, size, k}:
      String.eq(n, name)

def find(ls: List<&2, Lump>, +name: String, acc: Lump) -> Lump:
  match ls:
    case +l <> t:
      find(t, name, Bool.pick(Lump, named(name, l), l, acc))
    case []:
      acc

def iwad(+l: Lump) -> Bool:
  match l:
    case Lump{n, at, size, k}:
      U32.is_eq(k, 0)

def has.in.go(ls: List<&2, Lump>, +name: String, +acc: Bool) -> Bool:
  match ls:
    case +l <> t:
      has.in.go(t, name, Bool.or(acc, Bool.and(iwad(l), named(name, l))))
    case []:
      acc

def has.in(ls: List<&2, Lump>, +name: String) -> Bool:
  has.in.go(ls, name, False{})

def has(w: Wad, +name: String) -> Wad & Bool:
  match w:
    case Wad{file, m, +d}:
      (Wad{file, m, d}, has.in(d, name))

def heads(+name: String, +ls: List<&2, Lump>) -> Bool:
  match ls:
    case l <> t:
      named(name, l)
    case []:
      False{}

def from.last(+ls: List<&2, Lump>, +name: String, +acc: List<&2, Lump>) -> List<&2, Lump>:
  match ls:
    case +l <> +t:
      from.last(t, name, Bool.pick(List<&2, Lump>, named(name, l), l <> t, acc))
    case []:
      acc

def from(+name: String, +ls: List<&2, Lump>) -> List<&2, Lump>:
  from.last(ls, name, [])

def nth(+ps: List<&2, String>, +i: U32) -> String:
  Maybe.default(&2, String, List.get(&2, String, ps, U32.to_nat(i)), "")

def lump.got(more: List<&2, String>, d: List<&2, Lump>, p: File & List<&2, U32>) -> Wad & List<&2, U32>:
  (file, bs) = p
  (Wad{file, more, d}, bs)

def lump.ext(file: File, more: List<&2, String>, d: List<&2, Lump>, p: File & List<&2, U32>) -> IO(Wad & List<&2, U32>):
  (f, bs) = p
  do IO<Wad & List<&2, U32>>:
    File.close(f)
    return (Wad{file, more, d}, bs)

def lump.src(main: Bool, file: File, +more: List<&2, String>, d: List<&2, Lump>, +at: U32, +size: U32, +src: U32) -> IO(Wad & List<&2, U32>):
  match main:
    case True{}:
      do IO<Wad & List<&2, U32>>:
        p : File & List<&2, U32> <- read(file, at, size)
        return lump.got(more, d, p)
    case False{}:
      do IO<Wad & List<&2, U32>>:
        f : File <- IO.try(File, File.open(nth(more, (src - 1 : U32)), "r"))
        p : File & List<&2, U32> <- read(f, at, size)
        lump.ext(file, more, d, p)

def lump(w: Wad, l: Lump) -> IO(Wad & List<&2, U32>):
  match w l:
    case Wad{file, more, d} Lump{n, at, size, +src}:
      lump.src(U32.is_eq(src, 0), file, more, d, at, size, src)

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
  find(ls, name, Lump{"", 0, 0, 0})

def maps.put(hit: Bool, l: Lump, rest: List<&2, Lump>) -> List<&2, Lump>:
  match hit:
    case True{}:
      l <> rest
    case False{}:
      rest

def maps.go(ls: List<&2, Lump>, acc: List<&2, Lump>) -> List<&2, Lump>:
  match ls:
    case l <> +t:
      maps.go(t, maps.put(heads("THINGS", t), l, acc))
    case []:
      List.reverse(&2, Lump, acc)

def maps(ls: List<&2, Lump>) -> List<&2, Lump>:
  maps.go(ls, [])

def parts.go(+ls: List<&2, Lump>, names: List<&2, String>, acc: List<&2, Lump>) -> List<&2, Lump>:
  match names:
    case n <> t:
      parts.go(ls, t, part(ls, n) <> acc)
    case []:
      List.reverse(&2, Lump, acc)

def parts(+ls: List<&2, Lump>, names: List<&2, String>) -> List<&2, Lump>:
  parts.go(ls, names, [])

def get(w: Wad, names: List<&2, String>) -> IO(Wad & List<&2, List<&2, U32>>):
  match w:
    case Wad{file, m, +d}:
      lumps(parts(d, names), Wad{file, m, d})

def until.head(+ls: List<&2, Lump>, +stop: String) -> Bool:
  match ls:
    case +l <> t:
      named(stop, l)
    case []:
      False{}

def until.go(ls: List<&2, Lump>, +stop: String, acc: List<&2, Lump>, hit: Bool) -> List<&2, Lump>:
  match ls hit:
    case +l <> +t False{}:
      until.go(t, stop, l <> acc, until.head(t, stop))
    case _ _:
      List.reverse(&2, Lump, acc)

def until(+ls: List<&2, Lump>, +stop: String) -> List<&2, Lump>:
  until.go(ls, stop, [], until.head(ls, stop))

def lname(+l: Lump) -> String:
  match l:
    case Lump{n, at, size, k}:
      n

def lsize(+l: Lump) -> U32:
  match l:
    case Lump{n, at, size, k}:
      size

def iwads.head(+ls: List<&2, Lump>) -> Bool:
  match ls:
    case +l <> t:
      iwad(l)
    case []:
      False{}

def iwads.go(ls: List<&2, Lump>, acc: List<&2, Lump>, keep: Bool) -> List<&2, Lump>:
  match ls keep:
    case +l <> +t True{}:
      iwads.go(t, l <> acc, iwads.head(t))
    case _ _:
      List.reverse(&2, Lump, acc)

def iwads(+ls: List<&2, Lump>) -> List<&2, Lump>:
  iwads.go(ls, [], iwads.head(ls))

def marks(+n: String, +a: String, +b: String) -> Bool:
  Bool.or(String.eq(n, a), String.eq(n, b))

def inside.go(ls: List<&2, Lump>, +on: Bool, +a: String, +b: String, +a2: String, +b2: String, +acc: List<&2, Lump>) -> List<&2, Lump>:
  match ls:
    case +l <> t:
      +start = marks(lname(l), a, a2)
      +stop = marks(lname(l), b, b2)
      +keep = Bool.and(Bool.and(on, Bool.not(Bool.or(start, stop))), Bool.and(Bool.not(iwad(l)), U32.is_ne(lsize(l), 0)))
      inside.go(t, Bool.pick(Bool, start, True{}, Bool.pick(Bool, stop, False{}, on)), a, b, a2, b2, Bool.pick(List<&2, Lump>, keep, l <> acc, acc))
    case []:
      List.reverse(&2, Lump, acc)

def inside(ls: List<&2, Lump>, +on: Bool, +a: String, +b: String, +a2: String, +b2: String) -> List<&2, Lump>:
  inside.go(ls, on, a, b, a2, b2, [])

def latest(ls: List<&2, Lump>, +name: String, +l: Lump) -> Lump:
  find(ls, name, l)

def swap.go(iw: List<&2, Lump>, +pw: List<&2, Lump>, acc: List<&2, Lump>) -> List<&2, Lump>:
  match iw:
    case +l <> t:
      swap.go(t, pw, latest(pw, lname(l), l) <> acc)
    case []:
      List.reverse(&2, Lump, acc)

def swap(iw: List<&2, Lump>, +pw: List<&2, Lump>) -> List<&2, Lump>:
  swap.go(iw, pw, [])

def known.go(ls: List<&2, Lump>, +name: String, +acc: Bool) -> Bool:
  match ls:
    case +l <> t:
      known.go(t, name, Bool.or(acc, named(name, l)))
    case []:
      acc

def known(ls: List<&2, Lump>, +name: String) -> Bool:
  known.go(ls, name, False{})

def fresh.go(pw: List<&2, Lump>, +iw: List<&2, Lump>, +acc: List<&2, Lump>) -> List<&2, Lump>:
  match pw:
    case +l <> +t:
      fresh.go(t, iw, Bool.pick(List<&2, Lump>, Bool.or(known(iw, lname(l)), known(t, lname(l))), acc, l <> acc))
    case []:
      List.reverse(&2, Lump, acc)

def fresh(pw: List<&2, Lump>, +iw: List<&2, Lump>) -> List<&2, Lump>:
  fresh.go(pw, iw, [])

def section(w: Wad, +a: String, +b: String, +a2: String, +b2: String) -> Wad & List<&2, Lump>:
  match w:
    case Wad{file, m, +d}:
      +iw = until(List.drop(&2, Lump, from(a, iwads(d)), 1n), b)
      +pw = inside(d, False{}, a, b, a2, b2)
      (Wad{file, m, d}, List.append(&2, Lump, swap(iw, pw), fresh(pw, iw)))

def between(w: Wad, +a: String, +b: String) -> Wad & List<&2, Lump>:
  match w:
    case Wad{file, m, +d}:
      (Wad{file, m, d}, until(List.drop(&2, Lump, from(a, d), 1n), b))

def cli.pw(x: String, r: List<&2, String> & List<String>) -> List<&2, String> & List<String>:
  (ps, rs) = r
  (x <> ps, rs)

def cli.keep(x: String, r: List<&2, String> & List<String>) -> List<&2, String> & List<String>:
  (ps, rs) = r
  (ps, x <> rs)

def cli.two?(pw: Bool, x: String, t: List<String>) -> List<&2, String> & List<String>:
  match pw:
    case True{}:
      cli.pw(x, cli.go(t, True{}))
    case False{}:
      cli.keep(x, cli.go(t, False{}))

def cli.sf?(t: List<String>) -> List<&2, String> & List<String>:
  match t:
    case y <> r:
      cli.pw(y, cli.go(r, False{}))
    case []:
      ([], [])

def cli.one?(flag: Bool, sf: Bool, +pw: Bool, x: String, t: List<String>) -> List<&2, String> & List<String>:
  match flag sf:
    case True{} _:
      cli.go(t, True{})
    case False{} True{}:
      cli.sf(t)
    case False{} False{}:
      cli.two(pw, x, t)

def cli.go?(xs: List<String>, +on: Bool) -> List<&2, String> & List<String>:
  match xs:
    case +x <> t:
      cli.one(String.eq(x, "-file"), String.eq(x, "-soundfont"), Bool.and(on, String.ends_with(String.to_lower(x), ".wad")), x, t)
    case []:
      ([], [])

def cli.fin(prog: String, +path: String, r: List<&2, String> & List<String>) -> List<String>:
  (ps, rs) = r
  prog <> join(path, ps) <> rs

def cli(xs: List<String>) -> List<String>:
  match xs:
    case prog <> +path <> t:
      cli.fin(prog, path, cli.go(t, False{}))
    case _:
      xs
