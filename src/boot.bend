import Base
import ./wad.bend as W
import ./level.bend as L
import ./load.bend as D
import ./tab.bend as T
import ./world.bend as R
import ./render.bend as V
import ./automap.bend as A
import ./rom.bend as O
import ./mem.bend as M
import ./sprite.bend as P
import ./info.bend as I

type Scene is Data:
  Scene{tabs: V.Tabs, world: R.World}

def start(ts: List<&2, L.Thing>) -> L.Thing:
  match ts:
    case L.Thing{x, y, a, +k, f} <> t:
      Bool.pick(L.Thing, U32.is_eq(k, 1), L.Thing{x, y, a, k, f}, start(t))
    case []:
      L.Thing{0, 0, 0, 1, 0}

def things(n: Nat, +v: T.Vec<L.Thing>, +i: U32) -> List<&2, L.Thing>:
  match n:
    case 0n:
      []
    case 1n+p:
      T.get(L.Thing, v, i, L.Thing{0, 0, 0, 0, 0}) <> things(p, v, (i + 1 : U32))

def eye() -> U32:
  2686976

def view(+w: R.World, t: L.Thing) -> V.View:
  match t:
    case L.Thing{+x, +y, a, k, f}:
      V.View{(x << 16n : U32), (y << 16n : U32), (V.floor.at(w, (x << 16n : U32), (y << 16n : U32)) + eye() : U32), (536870912 * (a / 45) : U32), 0}

def spawned(+lv: L.Level) -> List<&2, P.Spawn>:
  match lv:
    case L.Level{n, +th, li, si, ve, se, ss, no, sc, rj, bm}:
      P.spawns(U32.to_nat(T.size(L.Thing, th)), T.from_list(U32, I.mobjinfo()), T.from_list(U32, I.states()), th, 0)

def spawn(+w: R.World) -> V.View:
  match w:
    case R.World{si, sg, su, no, sc, tx, +th, sk, mo, sth, frm}:
      view(w, start(things(U32.to_nat(T.size(L.Thing, th)), th, 0)))

def mobj(+w: R.World, +s: P.Spawn) -> R.RThing:
  match s:
    case P.Spawn{+x, +y, a, k, spr, fr, +fl, +h}:
      +sec = V.sector(w, V.sector.at(w, x, y))
      +z = Bool.pick(U32, U32.is_eq((fl .&. 256 : U32), 0), V.sector.floor(sec), (V.sec.ceil(sec) - h : U32))
      R.RThing{x, y, z, a, spr, fr, fl, V.sector.at(w, x, y)}

def mobjs(ss: List<&2, P.Spawn>, +w: R.World) -> List<&2, R.RThing>:
  match ss:
    case +s <> t:
      mobj(w, s) <> mobjs(t, w)
    case []:
      []

def blobs(bss: List<&2, List<&2, U32>>) -> List<&2, U32>:
  match bss:
    case bs <> t:
      List.append(&2, U32, bs, blobs(t))
    case []:
      []

def frames(+sp: P.Sprites) -> T.Vec<P.SFrame>:
  match sp:
    case P.Sprites{ls, fs}:
      fs

def assemble(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +ss: List<&2, P.Spawn>, +sp: P.Sprites, +base: U32, sbs: List<&2, List<&2, U32>>) -> Scene & Array<U32>:
  match t:
    case D.Texs{n, +ts, s, f, +fd}:
      +tb = V.tabs()
      +ly = O.layout(ts, fd)
      +w0 = R.build(lv, t, ly)
      +sbytes = blobs(sbs)
      (Scene{tb, R.with.things(w0, mobjs(ss, w0), frames(sp))},
        M.fill(sbytes, O.build(tb, A.palette(pal), cm, ts, fd, (base + U32.from_nat(List.length(&2, U32, sbytes)) : U32), O.texs.end(ts, M.texbase())), base))

def spritebase(+t: D.Texs) -> U32:
  match t:
    case D.Texs{n, +ts, s, f, +fd}:
      (O.texs.end(ts, M.texbase()) + 4096 * U32.from_nat(List.length(&2, List<&2, U32>, fd)) : U32)

def loaded(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +ss: List<&2, P.Spawn>, +sp: P.Sprites, +base: U32, p: W.Wad & List<&2, List<&2, U32>>) -> IO(Scene & Array<U32>):
  (w, sbs) = p
  do IO<Scene & Array<U32>>:
    W.close(w)
    IO.pure(Scene & Array<U32>, assemble(lv, pal, cm, t, ss, sp, base, sbs))

def sprite.lumps(+sp: P.Sprites) -> List<&2, W.Lump>:
  match sp:
    case P.Sprites{ls, fs}:
      ls

def sprited(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, r: W.Wad & List<&2, W.Lump>) -> IO(Scene & Array<U32>):
  (w, all) = r
  +ss = spawned(lv)
  +base = spritebase(t)
  +sp = P.sprites(all, ss, base)
  IO.bind(W.Wad & List<&2, List<&2, U32>>, Scene & Array<U32>, W.lumps(sprite.lumps(sp), w), q => loaded(lv, pal, cm, t, ss, sp, base, q))

def textured(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, p: W.Wad & D.Texs) -> IO(Scene & Array<U32>):
  (w, ts) = p
  sprited(lv, pal, cm, ts, W.between(w, "S_START", "S_END"))

def level(+pal: List<&2, U32>, cm: List<&2, U32>, p: W.Wad & L.Level) -> IO(Scene & Array<U32>):
  (w, +lv) = p
  IO.bind(W.Wad & D.Texs, Scene & Array<U32>, D.textures(w, lv), q => textured(lv, pal, cm, q))

def got(+name: String, p: W.Wad & List<&2, List<&2, U32>>) -> IO(Scene & Array<U32>):
  (w, bss) = p
  match bss:
    case pal <> cm <> t:
      IO.bind(W.Wad & L.Level, Scene & Array<U32>, L.load(w, name), q => level(pal, cm, q))
    case _:
      IO.die(Scene & Array<U32>, 1, "no PLAYPAL or COLORMAP")

def boot(path: String, +name: String) -> IO(Scene & Array<U32>):
  do IO<Scene & Array<U32>>:
    w : W.Wad <- W.open(path)
    p : W.Wad & List<&2, List<&2, U32>> <- W.get(w, ["PLAYPAL", "COLORMAP"])
    got(name, p)
