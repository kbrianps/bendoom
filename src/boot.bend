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
import ./state.bend as S
import ./setup.bend as U
import ./hudtext.bend as H

def view(+g: S.Sim) -> V.View:
  +m = S.p.mo(g)
  V.View{S.m.x(g, m), S.m.y(g, m), S.p.viewz(g), S.m.angle(g, m), S.p.extralight(g)}

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

def eyes(+g: S.Sim) -> S.Sim:
  S.p.viewz.set(g, (S.m.z(g, S.p.mo(g)) + S.p.viewheight(g) : U32))

def hudaddrs(hbs: List<&2, List<&2, U32>>, +at: U32) -> List<&2, U32>:
  match hbs:
    case bs <> t:
      at <> hudaddrs(t, (at + U32.from_nat(List.length(&2, U32, bs)) : U32))
    case []:
      []

def assemble(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +sp: P.Sprites, +base: U32, sbs: List<&2, List<&2, U32>>, +hbs: List<&2, List<&2, U32>>, +pl: T.Vec<U32>, +rnd: U32) -> S.Sim & Array<U32>:
  match t:
    case D.Texs{n, +ts, s, f, +fd, hs, ta, fa, sw}:
      +tb = V.tabs()
      +ly = O.layout(ts, fd)
      +w0 = R.build(lv, t, ly, frames(sp))
      +sbytes = blobs(sbs)
      +pb = (base + U32.from_nat(List.length(&2, U32, sbytes)) : U32)
      +pals = List.take(&2, U32, A.rgb(pal), 3584n)
      +hbytes = blobs(hbs)
      +hud = T.from_list(U32, pb <> hudaddrs(hbs, (pb + 3584 : U32)))
      +all = List.append(&2, U32, sbytes, List.append(&2, U32, pals, hbytes))
      (eyes(U.sim(lv, t, w0, tb, hud, pl, rnd)),
        M.fill(all, O.build(tb, A.palette(pal), cm, ts, fd, (pb + 3584 + U32.from_nat(List.length(&2, U32, hbytes)) : U32), O.texs.end(ts, M.texbase())), base))

def spritebase(+t: D.Texs) -> U32:
  match t:
    case D.Texs{n, +ts, s, f, +fd, hs, ta, fa, sw}:
      (O.texs.end(ts, M.texbase()) + 4096 * U32.from_nat(List.length(&2, List<&2, U32>, fd)) : U32)

def hudded(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +sp: P.Sprites, +base: U32, sbs: List<&2, List<&2, U32>>, +pl: T.Vec<U32>, +rnd: U32, p: W.Wad & List<&2, List<&2, U32>>) -> IO(S.Sim & Array<U32>):
  (w, hbs) = p
  do IO<S.Sim & Array<U32>>:
    W.close(w)
    IO.pure(S.Sim & Array<U32>, assemble(lv, pal, cm, t, sp, base, sbs, hbs, pl, rnd))

def loaded(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +sp: P.Sprites, +base: U32, +pl: T.Vec<U32>, +rnd: U32, p: W.Wad & List<&2, List<&2, U32>>) -> IO(S.Sim & Array<U32>):
  (w, sbs) = p
  IO.bind(W.Wad & List<&2, List<&2, U32>>, S.Sim & Array<U32>, W.get(w, H.hudnames()), q => hudded(lv, pal, cm, t, sp, base, sbs, pl, rnd, q))

def sprite.lumps(+sp: P.Sprites) -> List<&2, W.Lump>:
  match sp:
    case P.Sprites{ls, fs}:
      ls

def level.things(+lv: L.Level) -> T.Vec<L.Thing>:
  match lv:
    case L.Level{n, +th, li, si, ve, se, ss, no, sc, rj, bm}:
      th

def sprited(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +pl: T.Vec<U32>, +rnd: U32, r: W.Wad & List<&2, W.Lump>) -> IO(S.Sim & Array<U32>):
  (w, all) = r
  +cs = P.needed(T.from_list(U32, I.mobjinfo()), T.from_list(U32, I.states()), level.things(lv))
  +base = spritebase(t)
  +sp = P.sprites.of(all, cs, base)
  IO.bind(W.Wad & List<&2, List<&2, U32>>, S.Sim & Array<U32>, W.lumps(sprite.lumps(sp), w), q => loaded(lv, pal, cm, t, sp, base, pl, rnd, q))

def textured(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +pl: T.Vec<U32>, +rnd: U32, p: W.Wad & D.Texs) -> IO(S.Sim & Array<U32>):
  (w, ts) = p
  sprited(lv, pal, cm, ts, pl, rnd, W.between(w, "S_START", "S_END"))

def level(+pal: List<&2, U32>, cm: List<&2, U32>, +pl: T.Vec<U32>, +rnd: U32, p: W.Wad & L.Level) -> IO(S.Sim & Array<U32>):
  (w, +lv) = p
  IO.bind(W.Wad & D.Texs, S.Sim & Array<U32>, D.textures(w, lv), q => textured(lv, pal, cm, pl, rnd, q))

def got(+name: String, +pl: T.Vec<U32>, +rnd: U32, p: W.Wad & List<&2, List<&2, U32>>) -> IO(S.Sim & Array<U32>):
  (w, bss) = p
  match bss:
    case pal <> cm <> t:
      IO.bind(W.Wad & L.Level, S.Sim & Array<U32>, L.load(w, name), q => level(pal, cm, pl, rnd, q))
    case _:
      IO.die(S.Sim & Array<U32>, 1, "no PLAYPAL or COLORMAP")

def boot(path: String, +name: String, +pl: T.Vec<U32>, +rnd: U32) -> IO(S.Sim & Array<U32>):
  do IO<S.Sim & Array<U32>>:
    w : W.Wad <- W.open(path)
    p : W.Wad & List<&2, List<&2, U32>> <- W.get(w, ["PLAYPAL", "COLORMAP"])
    got(name, pl, rnd, p)

def new(path: String, +name: String) -> IO(S.Sim & Array<U32>):
  boot(path, name, U.newplayer(), 0)
