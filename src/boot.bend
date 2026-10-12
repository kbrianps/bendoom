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
  V.View{S.m.x(g, m), S.m.y(g, m), S.p.viewz(g), S.m.angle(g, m), S.p.extralight(g), S.p.fixedcm(g)}

def blobs(bss: List<&2, List<&2, U32>>) -> List<&2, U32>:
  T.flat(U32, bss)

def frames(+sp: P.Sprites) -> T.Vec<P.SFrame>:
  match sp:
    case P.Sprites{ls, fs}:
      fs

def eyes(+g: S.Sim) -> S.Sim:
  +v = (S.m.z(g, S.p.mo(g)) + S.p.viewheight(g) : U32)
  S.p.cviewz.set(S.p.viewz.set(g, v), v)

def hudaddrs.go(hbs: List<&2, List<&2, U32>>, +at: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match hbs:
    case bs <> t:
      +n = T.len(U32, bs)
      hudaddrs.go(t, (at + n : U32), Bool.pick(U32, U32.is_eq(n, 0), 0, at) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def hudaddrs(hbs: List<&2, List<&2, U32>>, +at: U32) -> List<&2, U32>:
  hudaddrs.go(hbs, at, [])

def assemble(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +sp: P.Sprites, +base: U32, sbs: List<&2, List<&2, U32>>, +hbs: List<&2, List<&2, U32>>, +mode: U32, +pl: T.Vec<U32>, +cv: T.Vec<U32>) -> S.Sim & Array<U32>:
  match t:
    case D.Texs{n, +ts, s, f, +fd, hs, ta, fa, sw, tbs, fbs, gt, gf}:
      +tb = V.tabs()
      +ly = O.layout(ts, fd)
      +w0 = R.build(lv, t, ly, frames(sp))
      +sbytes = blobs(sbs)
      +pb = (base + T.len(U32, sbytes) : U32)
      +pals = List.take(&2, U32, A.rgb(pal), 3584n)
      +hbytes = blobs(hbs)
      +hud = T.from_list(U32, pb <> (mode .&. 15 : U32) <> (mode >> 4n : U32) <> hudaddrs(hbs, (pb + 3584 : U32)))
      +all = T.cat(U32, sbytes, T.cat(U32, pals, hbytes))
      (eyes(U.sim(lv, t, w0, tb, hud, pl, cv)),
        M.fill(all, O.build(tb, A.palette(pal), cm, ts, fd, (pb + 3584 + T.len(U32, hbytes) : U32), O.texs.end(ts, M.texbase())), base))

def spritebase(+t: D.Texs) -> U32:
  match t:
    case D.Texs{n, +ts, s, f, +fd, hs, ta, fa, sw, tbs, fbs, gt, gf}:
      (O.texs.end(ts, M.texbase()) + 4096 * T.len(List<&2, U32>, fd) : U32)

def hudded(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +sp: P.Sprites, +base: U32, sbs: List<&2, List<&2, U32>>, +mode: U32, +pl: T.Vec<U32>, +cv: T.Vec<U32>, p: W.Wad & List<&2, List<&2, U32>>) -> IO(S.Sim & Array<U32>):
  (w, hbs) = p
  do IO<S.Sim & Array<U32>>:
    W.close(w)
    IO.pure(S.Sim & Array<U32>, assemble(lv, pal, cm, t, sp, base, sbs, hbs, mode, pl, cv))

def level.name(+lv: L.Level) -> String:
  match lv:
    case L.Level{+n, th, li, si, ve, se, ss, no, sc, rj, bm}:
      n

def mode.d(+m: U32, r: W.Wad & Bool) -> W.Wad & U32:
  (w, +m31) = r
  (w, (m .|. Bool.pick(U32, m31, 16, 0) : U32))

def mode.c(+d2: Bool, +e4: Bool, r: W.Wad & Bool) -> W.Wad & U32:
  (w, +e3) = r
  mode.d(Bool.pick(U32, d2, 3, Bool.pick(U32, e4, 2, Bool.pick(U32, e3, 1, 0))), W.has(w, "MAP31"))

def mode.b(+d2: Bool, r: W.Wad & Bool) -> W.Wad & U32:
  (w, +e4) = r
  mode.c(d2, e4, W.has(w, "E3M1"))

def mode.a(r: W.Wad & Bool) -> W.Wad & U32:
  (w, +d2) = r
  mode.b(d2, W.has(w, "E4M1"))

def mode.of(w: W.Wad) -> W.Wad & U32:
  mode.a(W.has(w, "MAP01"))

def fin.flat(+com: Bool, +ep: U32, +map: U32) -> String:
  Bool.pick(String, com,
    Bool.pick(String, U32.is_eq(map, 6), "SLIME16", Bool.pick(String, U32.is_eq(map, 11), "RROCK14", Bool.pick(String, U32.is_eq(map, 20), "RROCK07",
      Bool.pick(String, U32.is_eq(map, 30), "RROCK17", Bool.pick(String, U32.is_eq(map, 15), "RROCK13", Bool.pick(String, U32.is_eq(map, 31), "RROCK19", "-")))))),
    Bool.pick(String, U32.is_ne(map, 8), "-", Bool.pick(String, U32.is_eq(ep, 1), "FLOOR4_8", Bool.pick(String, U32.is_eq(ep, 2), "SFLR6_1", Bool.pick(String, U32.is_eq(ep, 3), "MFLR8_4", "MFLR8_3")))))

def fin.art(+com: Bool, +retail: Bool, +ep: U32, +map: U32) -> String:
  Bool.pick(String, Bool.or(com, U32.is_ne(map, 8)), "-",
    Bool.pick(String, U32.is_eq(ep, 1), Bool.pick(String, retail, "CREDIT", "HELP2"), Bool.pick(String, U32.is_eq(ep, 2), "VICTORY2", Bool.pick(String, U32.is_eq(ep, 4), "ENDPIC", "-"))))

def fin.names(+com: Bool, +retail: Bool, +ep: U32, +map: U32) -> List<&2, String>:
  +bunny = Bool.and(Bool.not(com), Bool.and(U32.is_eq(ep, 3), U32.is_eq(map, 8)))
  +ends = Bool.pick(List<&2, String>, bunny, ["PFUB1", "PFUB2", "END0", "END1", "END2", "END3", "END4", "END5", "END6"], ["-", "-", "-", "-", "-", "-", "-", "-", "-"])
  fin.flat(com, ep, map) <> fin.art(com, retail, ep, map) <> List.append(&2, String, ends, [Bool.pick(String, Bool.and(com, U32.is_eq(map, 30)), "BOSSBACK", "-")])

def ui.ep(+com: Bool, +ep: U32) -> List<&2, String>:
  Bool.pick(List<&2, String>, com, H.uiep4(), Bool.pick(List<&2, String>, U32.is_eq(ep, 1), H.uiep0(), Bool.pick(List<&2, String>, U32.is_eq(ep, 2), H.uiep1(), Bool.pick(List<&2, String>, U32.is_eq(ep, 3), H.uiep2(), H.uiep3()))))

def ui.names(+name: String, +mode: U32) -> List<&2, String>:
  +com = String.starts_with(name, "MAP")
  +ep = U.episode(name)
  +map = U.mapnum(name)
  List.append(&2, String, H.hudnames(), List.append(&2, String, H.uifixed(), List.append(&2, String, ui.ep(com, ep),
    List.append(&2, String, fin.names(com, U32.is_eq((mode .&. 15 : U32), 2), ep, map), List.append(&2, String, H.uimenu(),
      [Bool.pick(String, com, "GRNROCK", "FLOOR7_2"), "BRDR_T", "BRDR_B", "BRDR_L", "BRDR_R", "BRDR_TL", "BRDR_TR", "BRDR_BL", "BRDR_BR"])))))

def loaded.go(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +sp: P.Sprites, +base: U32, sbs: List<&2, List<&2, U32>>, +pl: T.Vec<U32>, +cv: T.Vec<U32>, r: W.Wad & U32) -> IO(S.Sim & Array<U32>):
  (w, +mode) = r
  IO.bind(W.Wad & List<&2, List<&2, U32>>, S.Sim & Array<U32>, W.get(w, ui.names(level.name(lv), mode)), q => hudded(lv, pal, cm, t, sp, base, sbs, mode, pl, cv, q))

def loaded(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +sp: P.Sprites, +base: U32, +pl: T.Vec<U32>, +cv: T.Vec<U32>, p: W.Wad & List<&2, List<&2, U32>>) -> IO(S.Sim & Array<U32>):
  (w, sbs) = p
  loaded.go(lv, pal, cm, t, sp, base, sbs, pl, cv, mode.of(w))

def sprite.lumps(+sp: P.Sprites) -> List<&2, W.Lump>:
  match sp:
    case P.Sprites{ls, fs}:
      ls

def level.things(+lv: L.Level) -> T.Vec<L.Thing>:
  match lv:
    case L.Level{n, +th, li, si, ve, se, ss, no, sc, rj, bm}:
      th

def sprited(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +t: D.Texs, +pl: T.Vec<U32>, +cv: T.Vec<U32>, r: W.Wad & List<&2, W.Lump>) -> IO(S.Sim & Array<U32>):
  (w, all) = r
  +cast = Bool.pick(List<&2, U32>, String.eq(level.name(lv), "MAP30"), [1, 2, 10, 11, 12, 18, 14, 17, 15, 20, 22, 5, 8, 3, 19, 21, 0], [])
  +cs = P.needed(T.from_list(U32, I.mobjinfo()), T.from_list(U32, I.states()), level.things(lv), cast)
  +base = spritebase(t)
  +sp = P.sprites.of(all, cs, base)
  IO.bind(W.Wad & List<&2, List<&2, U32>>, S.Sim & Array<U32>, W.lumps(sprite.lumps(sp), w), q => loaded(lv, pal, cm, t, sp, base, pl, cv, q))

def textured(+lv: L.Level, +pal: List<&2, U32>, cm: List<&2, U32>, +pl: T.Vec<U32>, +cv: T.Vec<U32>, p: W.Wad & D.Texs) -> IO(S.Sim & Array<U32>):
  (w, ts) = p
  sprited(lv, pal, cm, ts, pl, cv, W.section(w, "S_START", "S_END", "SS_START", "SS_END"))

def level(+pal: List<&2, U32>, cm: List<&2, U32>, +pl: T.Vec<U32>, +cv: T.Vec<U32>, p: W.Wad & L.Level) -> IO(S.Sim & Array<U32>):
  (w, +lv) = p
  IO.bind(W.Wad & D.Texs, S.Sim & Array<U32>, D.textures(w, lv, T.get(U32, cv, 4, 0)), q => textured(lv, pal, cm, pl, cv, q))

def got(+name: String, +pl: T.Vec<U32>, +cv: T.Vec<U32>, p: W.Wad & List<&2, List<&2, U32>>) -> IO(S.Sim & Array<U32>):
  (w, bss) = p
  match bss:
    case pal <> cm <> t:
      IO.bind(W.Wad & L.Level, S.Sim & Array<U32>, L.load(w, name), q => level(pal, cm, pl, cv, q))
    case _:
      IO.die(S.Sim & Array<U32>, 1, "no PLAYPAL or COLORMAP")

def boot(path: String, +name: String, +pl: T.Vec<U32>, +cv: T.Vec<U32>) -> IO(S.Sim & Array<U32>):
  do IO<S.Sim & Array<U32>>:
    w : W.Wad <- W.open(path)
    p : W.Wad & List<&2, List<&2, U32>> <- W.get(w, ["PLAYPAL", "COLORMAP"])
    got(name, pl, cv, p)

def demolump.first(xs: List<&2, List<&2, U32>>) -> List<&2, U32>:
  match xs:
    case x <> t:
      x
    case []:
      []

def demolump.got(p: W.Wad & List<&2, List<&2, U32>>) -> List<&2, U32>:
  (w, xs) = p
  demolump.first(xs)

def demolump(path: String, +name: String) -> IO(List<&2, U32>):
  do IO<List<&2, U32>>:
    w : W.Wad <- W.open(path)
    p : W.Wad & List<&2, List<&2, U32>> <- W.get(w, [name])
    return demolump.got(p)

def carry(+rnd: U32, +sk: U32, +mrnd: U32, +wipe: U32, +sky: U32) -> T.Vec<U32>:
  T.from_list(U32, [rnd, sk, mrnd, wipe, sky, 0, 0, 4294967295, 4294967295, 0, 0, 1, 0])

def skilled(path: String, +name: String, +sk: U32) -> IO(S.Sim & Array<U32>):
  boot(path, name, U.newplayer(), carry(0, sk, 0, 2, 0))

def new(path: String, +name: String) -> IO(S.Sim & Array<U32>):
  skilled(path, name, 2)

def first.go(+path: String, r: W.Wad & Bool) -> IO(S.Sim & Array<U32>):
  (w, +d2) = r
  do IO<S.Sim & Array<U32>>:
    W.close(w)
    new(path, Bool.pick(String, d2, "MAP01", "E1M1"))

def first(+path: String) -> IO(S.Sim & Array<U32>):
  do IO<S.Sim & Array<U32>>:
    w : W.Wad <- W.open(path)
    first.go(path, W.has(w, "MAP01"))
