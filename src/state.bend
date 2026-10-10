import Base
import ./tab.bend as T
import ./level.bend as L
import ./world.bend as R
import ./render.bend as V
import ./mem.bend as M

type RLine is Data:
  RLine{x1: U32, y1: U32, x2: U32, y2: U32, dx: U32, dy: U32, flags: U32, slope: U32, top: U32, bottom: U32, left: U32, right: U32, side0: U32, side1: U32, fsec: U32, bsec: U32, tag: U32}

def ln.x1(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x0

def ln.y1(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x1

def ln.x2(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x2

def ln.y2(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x3

def ln.dx(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x4

def ln.dy(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x5

def ln.flags(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x6

def ln.slope(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x7

def ln.top(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x8

def ln.bottom(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x9

def ln.left(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x10

def ln.right(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x11

def ln.side0(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x12

def ln.side1(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x13

def ln.fsec(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x14

def ln.bsec(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x15

def ln.tag(+r: RLine) -> U32:
  match r:
    case RLine{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16}:
      x16

type Icpt is Data:
  Icpt{frac: U32, line: Bool, id: U32}

type Th is Data:
  TNone{}
  TMo{}
  TDoor{sec: U32, kind: U32, top: U32, speed: U32, dir: U32, wait: U32, count: U32}
  TPlat{sec: U32, speed: U32, low: U32, high: U32, wait: U32, count: U32, status: U32, old: U32, crush: U32, tag: U32, kind: U32}
  TCeil{sec: U32, kind: U32, bottom: U32, top: U32, speed: U32, crush: U32, dir: U32, tag: U32, old: U32}
  TFloor{sec: U32, kind: U32, crush: U32, dir: U32, special: U32, texture: U32, dest: U32, speed: U32}
  TFlicker{sec: U32, count: U32, max: U32, min: U32}
  TFlash{sec: U32, count: U32, max: U32, min: U32, maxtime: U32, mintime: U32}
  TStrobe{sec: U32, count: U32, min: U32, max: U32, dark: U32, bright: U32}
  TGlow{sec: U32, min: U32, max: U32, dir: U32}
  TDead{}

type P2 is Data:
  P2{a: U32, b: U32}

type Anim is Data:
  Anim{tex: Bool, ids: List<&2, U32>, base: U32, speed: U32}

type Tm is Data:
  Tm{thing: U32, flags: U32, x: U32, y: U32, top: U32, bottom: U32, left: U32, right: U32, floorz: U32, ceilz: U32, dropoff: U32, floatok: U32, ceilline: U32, spechit: List<&2,U32>, mo: U32, best: U32, second: U32, bestline: U32, secondline: U32, xmove: U32, ymove: U32, crush: U32, nofit: U32, trx: U32, try: U32, trdx: U32, trdy: U32, ins: List<&2,Icpt>, otop: U32, obottom: U32, orange: U32, olow: U32, ok: U32, sz: U32, tops: U32, bots: U32, t2x: U32, t2y: U32, range: U32, aim: U32, shootz: U32, shooter: U32, ltarget: U32, ladmg: U32, bspot: U32, bsrc: U32, bdmg: U32, corpse: U32, vx: U32, vy: U32, sx: U32, sy: U32, sdx: U32, sdy: U32, nil: List<&2,Tm>}

type Lvl is Data:
  Lvl{lines: T.Vec<RLine>, seclines: T.Vec<List<&2,U32>>, secbox: T.Vec<U32>, bmap: T.Vec<U32>, ox: U32, oy: U32, bw: U32, bh: U32, mi: T.Vec<U32>, st: T.Vec<U32>, tb: V.Tabs, anims: List<&2,Anim>, switches: T.Vec<U32>, nswitch: U32, scrolls: List<&2,U32>, tex0: T.Vec<M.Info>, flat0: T.Vec<U32>, theights: T.Vec<U32>, nsec: U32, nlines: U32, commercial: Bool, episode: U32, map: U32, things: T.Vec<L.Thing>, rndt: T.Vec<U32>, skill: U32, subsec: T.Vec<U32>, xtab: T.Vec<U32>, utab: T.Vec<U32>, reject: T.Vec<U32>, segline: T.Vec<U32>, hud: T.Vec<U32>, nil: List<&2,Lvl>}

type Sim is Data:
  Sim{w: R.World, mp: Lvl, lspec: T.Vec<U32>, links: T.Vec<U32>, valid: T.Vec<U32>, vc: U32, ths: T.Vec<Th>, tn: T.Vec<U32>, tp: T.Vec<U32>, free: List<&2,U32>, next: U32, pl: T.Vec<U32>, time: U32, rnd: U32, plats: T.Vec<U32>, ceils: T.Vec<U32>, buttons: T.Vec<U32>, exit: U32, tm: Tm, kills: U32, items: U32, secrets: U32, halt: U32, ret: U32, secv: T.Vec<U32>, sndt: T.Vec<U32>, sndn: T.Vec<U32>, brains: T.Vec<U32>, nbrain: U32, brainon: U32, easy: U32, snd: List<&2,U32>, tic: U32, mrnd: U32, wipe: U32, stface: U32, stcount: U32, stprio: U32, stlad: U32, stold: U32, stpainh: U32, stpainc: U32, stweap: U32, strnd: U32, hmsg: U32, hcount: U32, nil: List<&2,Sim>}

def tmr.thing(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x0

def tmr.thing.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{v, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.flags(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x1

def tmr.flags.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, v, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.x(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x2

def tmr.x.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, v, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.y(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x3

def tmr.y.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, v, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.top(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x4

def tmr.top.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, v, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.bottom(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x5

def tmr.bottom.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, v, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.left(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x6

def tmr.left.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, v, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.right(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x7

def tmr.right.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, v, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.floorz(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x8

def tmr.floorz.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, v, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.ceilz(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x9

def tmr.ceilz.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, v, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.dropoff(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x10

def tmr.dropoff.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, v, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.floatok(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x11

def tmr.floatok.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, v, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.ceilline(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x12

def tmr.ceilline.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, v, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.spechit(+r: Tm) -> List<&2,U32>:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x13

def tmr.spechit.set(r: Tm, v: List<&2,U32>) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, v, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.mo(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x14

def tmr.mo.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, v, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.best(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x15

def tmr.best.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, v, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.second(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x16

def tmr.second.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, v, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.bestline(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x17

def tmr.bestline.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, v, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.secondline(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x18

def tmr.secondline.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, v, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.xmove(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x19

def tmr.xmove.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, v, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.ymove(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x20

def tmr.ymove.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, v, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.crush(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x21

def tmr.crush.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, v, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.nofit(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x22

def tmr.nofit.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, v, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.trx(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x23

def tmr.trx.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, v, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.try(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x24

def tmr.try.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, v, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.trdx(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x25

def tmr.trdx.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, v, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.trdy(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x26

def tmr.trdy.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, v, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.ins(+r: Tm) -> List<&2,Icpt>:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x27

def tmr.ins.set(r: Tm, v: List<&2,Icpt>) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, v, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.otop(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x28

def tmr.otop.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, v, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.obottom(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x29

def tmr.obottom.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, v, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.orange(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x30

def tmr.orange.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, v, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.olow(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x31

def tmr.olow.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, v, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.ok(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x32

def tmr.ok.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, v, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.sz(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x33

def tmr.sz.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, v, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.tops(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x34

def tmr.tops.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, v, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.bots(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x35

def tmr.bots.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, v, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.t2x(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x36

def tmr.t2x.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, v, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.t2y(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x37

def tmr.t2y.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, v, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.range(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x38

def tmr.range.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, v, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.aim(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x39

def tmr.aim.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, v, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.shootz(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x40

def tmr.shootz.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, v, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.shooter(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x41

def tmr.shooter.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, v, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.ltarget(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x42

def tmr.ltarget.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, v, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.ladmg(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x43

def tmr.ladmg.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, v, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.bspot(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x44

def tmr.bspot.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, v, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.bsrc(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x45

def tmr.bsrc.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, v, x46, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.bdmg(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x46

def tmr.bdmg.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, v, x47, x48, x49, x50, x51, x52, x53, x54}

def tmr.corpse(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x47

def tmr.corpse.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, v, x48, x49, x50, x51, x52, x53, x54}

def tmr.vx(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x48

def tmr.vx.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, v, x49, x50, x51, x52, x53, x54}

def tmr.vy(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x49

def tmr.vy.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, v, x50, x51, x52, x53, x54}

def tmr.sx(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x50

def tmr.sx.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, v, x51, x52, x53, x54}

def tmr.sy(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x51

def tmr.sy.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, v, x52, x53, x54}

def tmr.sdx(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x52

def tmr.sdx.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, v, x53, x54}

def tmr.sdy(+r: Tm) -> U32:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x53

def tmr.sdy.set(r: Tm, +v: U32) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, v, x54}

def tmr.nil(+r: Tm) -> List<&2,Tm>:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      x54

def tmr.nil.set(r: Tm, v: List<&2,Tm>) -> Tm:
  match r:
    case Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, x54}:
      Tm{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46, x47, x48, x49, x50, x51, x52, x53, v}

def mpr.lines(+r: Lvl) -> T.Vec<RLine>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x0

def mpr.seclines(+r: Lvl) -> T.Vec<List<&2,U32>>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x1

def mpr.secbox(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x2

def mpr.bmap(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x3

def mpr.ox(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x4

def mpr.oy(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x5

def mpr.bw(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x6

def mpr.bh(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x7

def mpr.mi(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x8

def mpr.st(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x9

def mpr.tb(+r: Lvl) -> V.Tabs:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x10

def mpr.anims(+r: Lvl) -> List<&2,Anim>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x11

def mpr.switches(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x12

def mpr.nswitch(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x13

def mpr.scrolls(+r: Lvl) -> List<&2,U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x14

def mpr.tex0(+r: Lvl) -> T.Vec<M.Info>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x15

def mpr.flat0(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x16

def mpr.theights(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x17

def mpr.nsec(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x18

def mpr.nlines(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x19

def mpr.commercial(+r: Lvl) -> Bool:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x20

def mpr.episode(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x21

def mpr.map(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x22

def mpr.things(+r: Lvl) -> T.Vec<L.Thing>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x23

def mpr.rndt(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x24

def mpr.skill(+r: Lvl) -> U32:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x25

def mpr.subsec(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x26

def mpr.xtab(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x27

def mpr.utab(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x28

def mpr.reject(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x29

def mpr.segline(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x30

def mpr.hud(+r: Lvl) -> T.Vec<U32>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x31

def mpr.nil(+r: Lvl) -> List<&2,Lvl>:
  match r:
    case Lvl{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32}:
      x32

def sim.w(+r: Sim) -> R.World:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x0

def sim.w.set(r: Sim, v: R.World) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{v, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.mp(+r: Sim) -> Lvl:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x1

def sim.mp.set(r: Sim, v: Lvl) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, v, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.lspec(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x2

def sim.lspec.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, v, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.links(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x3

def sim.links.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, v, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.valid(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x4

def sim.valid.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, v, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.vc(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x5

def sim.vc.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, v, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.ths(+r: Sim) -> T.Vec<Th>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x6

def sim.ths.set(r: Sim, v: T.Vec<Th>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, v, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.tn(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x7

def sim.tn.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, v, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.tp(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x8

def sim.tp.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, v, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.free(+r: Sim) -> List<&2,U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x9

def sim.free.set(r: Sim, v: List<&2,U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, v, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.next(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x10

def sim.next.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, v, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.pl(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x11

def sim.pl.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, v, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.time(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x12

def sim.time.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, v, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.rnd(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x13

def sim.rnd.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, v, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.plats(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x14

def sim.plats.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, v, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.ceils(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x15

def sim.ceils.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, v, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.buttons(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x16

def sim.buttons.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, v, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.exit(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x17

def sim.exit.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, v, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.tm(+r: Sim) -> Tm:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x18

def sim.tm.set(r: Sim, v: Tm) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, v, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.kills(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x19

def sim.kills.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, v, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.items(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x20

def sim.items.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, v, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.secrets(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x21

def sim.secrets.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, v, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.halt(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x22

def sim.halt.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, v, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.ret(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x23

def sim.ret.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, v, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.secv(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x24

def sim.secv.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, v, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.sndt(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x25

def sim.sndt.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, v, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.sndn(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x26

def sim.sndn.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, v, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.brains(+r: Sim) -> T.Vec<U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x27

def sim.brains.set(r: Sim, v: T.Vec<U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, v, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.nbrain(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x28

def sim.nbrain.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, v, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.brainon(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x29

def sim.brainon.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, v, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.easy(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x30

def sim.easy.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, v, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.snd(+r: Sim) -> List<&2,U32>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x31

def sim.snd.set(r: Sim, v: List<&2,U32>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, v, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.tic(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x32

def sim.tic.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, v, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.mrnd(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x33

def sim.mrnd.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, v, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.wipe(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x34

def sim.wipe.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, v, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.stface(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x35

def sim.stface.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, v, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.stcount(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x36

def sim.stcount.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, v, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.stprio(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x37

def sim.stprio.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, v, x38, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.stlad(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x38

def sim.stlad.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, v, x39, x40, x41, x42, x43, x44, x45, x46}

def sim.stold(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x39

def sim.stold.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, v, x40, x41, x42, x43, x44, x45, x46}

def sim.stpainh(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x40

def sim.stpainh.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, v, x41, x42, x43, x44, x45, x46}

def sim.stpainc(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x41

def sim.stpainc.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, v, x42, x43, x44, x45, x46}

def sim.stweap(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x42

def sim.stweap.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, v, x43, x44, x45, x46}

def sim.strnd(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x43

def sim.strnd.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, v, x44, x45, x46}

def sim.hmsg(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x44

def sim.hmsg.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, v, x45, x46}

def sim.hcount(+r: Sim) -> U32:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x45

def sim.hcount.set(r: Sim, +v: U32) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, v, x46}

def sim.nil(+r: Sim) -> List<&2,Sim>:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      x46

def sim.nil.set(r: Sim, v: List<&2,Sim>) -> Sim:
  match r:
    case Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, x46}:
      Sim{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x30, x31, x32, x33, x34, x35, x36, x37, x38, x39, x40, x41, x42, x43, x44, x45, v}

def tm.thing(+g: Sim) -> U32:
  tmr.thing(sim.tm(g))

def tm.thing.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.thing.set(sim.tm(g), v))

def tm.flags(+g: Sim) -> U32:
  tmr.flags(sim.tm(g))

def tm.flags.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.flags.set(sim.tm(g), v))

def tm.x(+g: Sim) -> U32:
  tmr.x(sim.tm(g))

def tm.x.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.x.set(sim.tm(g), v))

def tm.y(+g: Sim) -> U32:
  tmr.y(sim.tm(g))

def tm.y.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.y.set(sim.tm(g), v))

def tm.top(+g: Sim) -> U32:
  tmr.top(sim.tm(g))

def tm.top.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.top.set(sim.tm(g), v))

def tm.bottom(+g: Sim) -> U32:
  tmr.bottom(sim.tm(g))

def tm.bottom.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.bottom.set(sim.tm(g), v))

def tm.left(+g: Sim) -> U32:
  tmr.left(sim.tm(g))

def tm.left.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.left.set(sim.tm(g), v))

def tm.right(+g: Sim) -> U32:
  tmr.right(sim.tm(g))

def tm.right.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.right.set(sim.tm(g), v))

def tm.floorz(+g: Sim) -> U32:
  tmr.floorz(sim.tm(g))

def tm.floorz.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.floorz.set(sim.tm(g), v))

def tm.ceilz(+g: Sim) -> U32:
  tmr.ceilz(sim.tm(g))

def tm.ceilz.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.ceilz.set(sim.tm(g), v))

def tm.dropoff(+g: Sim) -> U32:
  tmr.dropoff(sim.tm(g))

def tm.dropoff.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.dropoff.set(sim.tm(g), v))

def tm.floatok(+g: Sim) -> U32:
  tmr.floatok(sim.tm(g))

def tm.floatok.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.floatok.set(sim.tm(g), v))

def tm.ceilline(+g: Sim) -> U32:
  tmr.ceilline(sim.tm(g))

def tm.ceilline.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.ceilline.set(sim.tm(g), v))

def tm.spechit(+g: Sim) -> List<&2,U32>:
  tmr.spechit(sim.tm(g))

def tm.spechit.set(+g: Sim, v: List<&2,U32>) -> Sim:
  sim.tm.set(g, tmr.spechit.set(sim.tm(g), v))

def tm.mo(+g: Sim) -> U32:
  tmr.mo(sim.tm(g))

def tm.mo.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.mo.set(sim.tm(g), v))

def tm.best(+g: Sim) -> U32:
  tmr.best(sim.tm(g))

def tm.best.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.best.set(sim.tm(g), v))

def tm.second(+g: Sim) -> U32:
  tmr.second(sim.tm(g))

def tm.second.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.second.set(sim.tm(g), v))

def tm.bestline(+g: Sim) -> U32:
  tmr.bestline(sim.tm(g))

def tm.bestline.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.bestline.set(sim.tm(g), v))

def tm.secondline(+g: Sim) -> U32:
  tmr.secondline(sim.tm(g))

def tm.secondline.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.secondline.set(sim.tm(g), v))

def tm.xmove(+g: Sim) -> U32:
  tmr.xmove(sim.tm(g))

def tm.xmove.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.xmove.set(sim.tm(g), v))

def tm.ymove(+g: Sim) -> U32:
  tmr.ymove(sim.tm(g))

def tm.ymove.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.ymove.set(sim.tm(g), v))

def tm.crush(+g: Sim) -> U32:
  tmr.crush(sim.tm(g))

def tm.crush.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.crush.set(sim.tm(g), v))

def tm.nofit(+g: Sim) -> U32:
  tmr.nofit(sim.tm(g))

def tm.nofit.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.nofit.set(sim.tm(g), v))

def tm.trx(+g: Sim) -> U32:
  tmr.trx(sim.tm(g))

def tm.trx.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.trx.set(sim.tm(g), v))

def tm.try(+g: Sim) -> U32:
  tmr.try(sim.tm(g))

def tm.try.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.try.set(sim.tm(g), v))

def tm.trdx(+g: Sim) -> U32:
  tmr.trdx(sim.tm(g))

def tm.trdx.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.trdx.set(sim.tm(g), v))

def tm.trdy(+g: Sim) -> U32:
  tmr.trdy(sim.tm(g))

def tm.trdy.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.trdy.set(sim.tm(g), v))

def tm.ins(+g: Sim) -> List<&2,Icpt>:
  tmr.ins(sim.tm(g))

def tm.ins.set(+g: Sim, v: List<&2,Icpt>) -> Sim:
  sim.tm.set(g, tmr.ins.set(sim.tm(g), v))

def tm.otop(+g: Sim) -> U32:
  tmr.otop(sim.tm(g))

def tm.otop.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.otop.set(sim.tm(g), v))

def tm.obottom(+g: Sim) -> U32:
  tmr.obottom(sim.tm(g))

def tm.obottom.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.obottom.set(sim.tm(g), v))

def tm.orange(+g: Sim) -> U32:
  tmr.orange(sim.tm(g))

def tm.orange.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.orange.set(sim.tm(g), v))

def tm.olow(+g: Sim) -> U32:
  tmr.olow(sim.tm(g))

def tm.olow.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.olow.set(sim.tm(g), v))

def tm.ok(+g: Sim) -> U32:
  tmr.ok(sim.tm(g))

def tm.ok.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.ok.set(sim.tm(g), v))

def tm.sz(+g: Sim) -> U32:
  tmr.sz(sim.tm(g))

def tm.sz.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.sz.set(sim.tm(g), v))

def tm.tops(+g: Sim) -> U32:
  tmr.tops(sim.tm(g))

def tm.tops.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.tops.set(sim.tm(g), v))

def tm.bots(+g: Sim) -> U32:
  tmr.bots(sim.tm(g))

def tm.bots.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.bots.set(sim.tm(g), v))

def tm.t2x(+g: Sim) -> U32:
  tmr.t2x(sim.tm(g))

def tm.t2x.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.t2x.set(sim.tm(g), v))

def tm.t2y(+g: Sim) -> U32:
  tmr.t2y(sim.tm(g))

def tm.t2y.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.t2y.set(sim.tm(g), v))

def tm.range(+g: Sim) -> U32:
  tmr.range(sim.tm(g))

def tm.range.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.range.set(sim.tm(g), v))

def tm.aim(+g: Sim) -> U32:
  tmr.aim(sim.tm(g))

def tm.aim.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.aim.set(sim.tm(g), v))

def tm.shootz(+g: Sim) -> U32:
  tmr.shootz(sim.tm(g))

def tm.shootz.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.shootz.set(sim.tm(g), v))

def tm.shooter(+g: Sim) -> U32:
  tmr.shooter(sim.tm(g))

def tm.shooter.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.shooter.set(sim.tm(g), v))

def tm.ltarget(+g: Sim) -> U32:
  tmr.ltarget(sim.tm(g))

def tm.ltarget.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.ltarget.set(sim.tm(g), v))

def tm.ladmg(+g: Sim) -> U32:
  tmr.ladmg(sim.tm(g))

def tm.ladmg.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.ladmg.set(sim.tm(g), v))

def tm.bspot(+g: Sim) -> U32:
  tmr.bspot(sim.tm(g))

def tm.bspot.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.bspot.set(sim.tm(g), v))

def tm.bsrc(+g: Sim) -> U32:
  tmr.bsrc(sim.tm(g))

def tm.bsrc.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.bsrc.set(sim.tm(g), v))

def tm.bdmg(+g: Sim) -> U32:
  tmr.bdmg(sim.tm(g))

def tm.bdmg.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.bdmg.set(sim.tm(g), v))

def tm.corpse(+g: Sim) -> U32:
  tmr.corpse(sim.tm(g))

def tm.corpse.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.corpse.set(sim.tm(g), v))

def tm.vx(+g: Sim) -> U32:
  tmr.vx(sim.tm(g))

def tm.vx.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.vx.set(sim.tm(g), v))

def tm.vy(+g: Sim) -> U32:
  tmr.vy(sim.tm(g))

def tm.vy.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.vy.set(sim.tm(g), v))

def tm.sx(+g: Sim) -> U32:
  tmr.sx(sim.tm(g))

def tm.sx.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.sx.set(sim.tm(g), v))

def tm.sy(+g: Sim) -> U32:
  tmr.sy(sim.tm(g))

def tm.sy.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.sy.set(sim.tm(g), v))

def tm.sdx(+g: Sim) -> U32:
  tmr.sdx(sim.tm(g))

def tm.sdx.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.sdx.set(sim.tm(g), v))

def tm.sdy(+g: Sim) -> U32:
  tmr.sdy(sim.tm(g))

def tm.sdy.set(+g: Sim, +v: U32) -> Sim:
  sim.tm.set(g, tmr.sdy.set(sim.tm(g), v))

def tm.nil(+g: Sim) -> List<&2,Tm>:
  tmr.nil(sim.tm(g))

def tm.nil.set(+g: Sim, v: List<&2,Tm>) -> Sim:
  sim.tm.set(g, tmr.nil.set(sim.tm(g), v))

def mp.lines(+g: Sim) -> T.Vec<RLine>:
  mpr.lines(sim.mp(g))

def mp.seclines(+g: Sim) -> T.Vec<List<&2,U32>>:
  mpr.seclines(sim.mp(g))

def mp.secbox(+g: Sim) -> T.Vec<U32>:
  mpr.secbox(sim.mp(g))

def mp.bmap(+g: Sim) -> T.Vec<U32>:
  mpr.bmap(sim.mp(g))

def mp.ox(+g: Sim) -> U32:
  mpr.ox(sim.mp(g))

def mp.oy(+g: Sim) -> U32:
  mpr.oy(sim.mp(g))

def mp.bw(+g: Sim) -> U32:
  mpr.bw(sim.mp(g))

def mp.bh(+g: Sim) -> U32:
  mpr.bh(sim.mp(g))

def mp.mi(+g: Sim) -> T.Vec<U32>:
  mpr.mi(sim.mp(g))

def mp.st(+g: Sim) -> T.Vec<U32>:
  mpr.st(sim.mp(g))

def mp.tb(+g: Sim) -> V.Tabs:
  mpr.tb(sim.mp(g))

def mp.anims(+g: Sim) -> List<&2,Anim>:
  mpr.anims(sim.mp(g))

def mp.switches(+g: Sim) -> T.Vec<U32>:
  mpr.switches(sim.mp(g))

def mp.nswitch(+g: Sim) -> U32:
  mpr.nswitch(sim.mp(g))

def mp.scrolls(+g: Sim) -> List<&2,U32>:
  mpr.scrolls(sim.mp(g))

def mp.tex0(+g: Sim) -> T.Vec<M.Info>:
  mpr.tex0(sim.mp(g))

def mp.flat0(+g: Sim) -> T.Vec<U32>:
  mpr.flat0(sim.mp(g))

def mp.theights(+g: Sim) -> T.Vec<U32>:
  mpr.theights(sim.mp(g))

def mp.nsec(+g: Sim) -> U32:
  mpr.nsec(sim.mp(g))

def mp.nlines(+g: Sim) -> U32:
  mpr.nlines(sim.mp(g))

def mp.commercial(+g: Sim) -> Bool:
  mpr.commercial(sim.mp(g))

def mp.episode(+g: Sim) -> U32:
  mpr.episode(sim.mp(g))

def mp.map(+g: Sim) -> U32:
  mpr.map(sim.mp(g))

def mp.things(+g: Sim) -> T.Vec<L.Thing>:
  mpr.things(sim.mp(g))

def mp.rndt(+g: Sim) -> T.Vec<U32>:
  mpr.rndt(sim.mp(g))

def mp.skill(+g: Sim) -> U32:
  mpr.skill(sim.mp(g))

def mp.subsec(+g: Sim) -> T.Vec<U32>:
  mpr.subsec(sim.mp(g))

def mp.xtab(+g: Sim) -> T.Vec<U32>:
  mpr.xtab(sim.mp(g))

def mp.utab(+g: Sim) -> T.Vec<U32>:
  mpr.utab(sim.mp(g))

def mp.reject(+g: Sim) -> T.Vec<U32>:
  mpr.reject(sim.mp(g))

def mp.segline(+g: Sim) -> T.Vec<U32>:
  mpr.segline(sim.mp(g))

def mp.hud(+g: Sim) -> T.Vec<U32>:
  mpr.hud(sim.mp(g))

def mp.nil(+g: Sim) -> List<&2,Lvl>:
  mpr.nil(sim.mp(g))

def mget(+g: Sim, +m: U32, +f: U32) -> U32:
  R.mo(sim.w(g), m, f)

def mput(+g: Sim, +m: U32, +f: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.mo(sim.w(g), m, f, v))

def pget(+g: Sim, +f: U32) -> U32:
  T.get(U32, sim.pl(g), f, 0)

def pput(+g: Sim, +f: U32, +v: U32) -> Sim:
  sim.pl.set(g, T.set(U32, sim.pl(g), f, v))

def line(+g: Sim, +l: U32) -> RLine:
  T.get(RLine, mp.lines(g), l, RLine{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65535, 65535, 0, 65535, 0})

def sec(+g: Sim, +s: U32) -> R.RSector:
  R.sector(sim.w(g), s)

def side(+g: Sim, +s: U32) -> R.RSide:
  R.side(sim.w(g), s)

def m.x(+g: Sim, +m: U32) -> U32:
  mget(g, m, 0)

def m.x.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 0, v)

def m.y(+g: Sim, +m: U32) -> U32:
  mget(g, m, 1)

def m.y.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 1, v)

def m.z(+g: Sim, +m: U32) -> U32:
  mget(g, m, 2)

def m.z.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 2, v)

def m.angle(+g: Sim, +m: U32) -> U32:
  mget(g, m, 3)

def m.angle.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 3, v)

def m.sprite(+g: Sim, +m: U32) -> U32:
  mget(g, m, 4)

def m.sprite.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 4, v)

def m.frame(+g: Sim, +m: U32) -> U32:
  mget(g, m, 5)

def m.frame.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 5, v)

def m.flags(+g: Sim, +m: U32) -> U32:
  mget(g, m, 6)

def m.flags.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 6, v)

def m.type(+g: Sim, +m: U32) -> U32:
  mget(g, m, 7)

def m.type.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 7, v)

def m.radius(+g: Sim, +m: U32) -> U32:
  mget(g, m, 8)

def m.radius.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 8, v)

def m.height(+g: Sim, +m: U32) -> U32:
  mget(g, m, 9)

def m.height.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 9, v)

def m.momx(+g: Sim, +m: U32) -> U32:
  mget(g, m, 10)

def m.momx.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 10, v)

def m.momy(+g: Sim, +m: U32) -> U32:
  mget(g, m, 11)

def m.momy.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 11, v)

def m.momz(+g: Sim, +m: U32) -> U32:
  mget(g, m, 12)

def m.momz.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 12, v)

def m.floorz(+g: Sim, +m: U32) -> U32:
  mget(g, m, 13)

def m.floorz.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 13, v)

def m.ceilz(+g: Sim, +m: U32) -> U32:
  mget(g, m, 14)

def m.ceilz.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 14, v)

def m.sub(+g: Sim, +m: U32) -> U32:
  mget(g, m, 15)

def m.sub.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 15, v)

def m.state(+g: Sim, +m: U32) -> U32:
  mget(g, m, 16)

def m.state.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 16, v)

def m.tics(+g: Sim, +m: U32) -> U32:
  mget(g, m, 17)

def m.tics.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 17, v)

def m.health(+g: Sim, +m: U32) -> U32:
  mget(g, m, 18)

def m.health.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 18, v)

def m.movedir(+g: Sim, +m: U32) -> U32:
  mget(g, m, 19)

def m.movedir.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 19, v)

def m.movecount(+g: Sim, +m: U32) -> U32:
  mget(g, m, 20)

def m.movecount.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 20, v)

def m.target(+g: Sim, +m: U32) -> U32:
  mget(g, m, 21)

def m.target.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 21, v)

def m.reaction(+g: Sim, +m: U32) -> U32:
  mget(g, m, 22)

def m.reaction.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 22, v)

def m.threshold(+g: Sim, +m: U32) -> U32:
  mget(g, m, 23)

def m.threshold.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 23, v)

def m.lastlook(+g: Sim, +m: U32) -> U32:
  mget(g, m, 24)

def m.lastlook.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 24, v)

def m.tracer(+g: Sim, +m: U32) -> U32:
  mget(g, m, 25)

def m.tracer.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 25, v)

def m.snext(+g: Sim, +m: U32) -> U32:
  mget(g, m, 26)

def m.snext.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 26, v)

def m.sprev(+g: Sim, +m: U32) -> U32:
  mget(g, m, 27)

def m.sprev.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 27, v)

def m.bnext(+g: Sim, +m: U32) -> U32:
  mget(g, m, 28)

def m.bnext.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 28, v)

def m.bprev(+g: Sim, +m: U32) -> U32:
  mget(g, m, 29)

def m.bprev.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 29, v)

def m.spawn(+g: Sim, +m: U32) -> U32:
  mget(g, m, 30)

def m.spawn.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 30, v)

def m.player(+g: Sim, +m: U32) -> U32:
  mget(g, m, 31)

def m.player.set(+g: Sim, +m: U32, +v: U32) -> Sim:
  mput(g, m, 31, v)

def p.mo(+g: Sim) -> U32:
  pget(g, 0)

def p.mo.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 0, v)

def p.state(+g: Sim) -> U32:
  pget(g, 1)

def p.state.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 1, v)

def p.viewz(+g: Sim) -> U32:
  pget(g, 2)

def p.viewz.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 2, v)

def p.viewheight(+g: Sim) -> U32:
  pget(g, 3)

def p.viewheight.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 3, v)

def p.dvh(+g: Sim) -> U32:
  pget(g, 4)

def p.dvh.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 4, v)

def p.bob(+g: Sim) -> U32:
  pget(g, 5)

def p.bob.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 5, v)

def p.health(+g: Sim) -> U32:
  pget(g, 6)

def p.health.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 6, v)

def p.armor(+g: Sim) -> U32:
  pget(g, 7)

def p.armor.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 7, v)

def p.armortype(+g: Sim) -> U32:
  pget(g, 8)

def p.armortype.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 8, v)

def p.cards(+g: Sim) -> U32:
  pget(g, 9)

def p.cards.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 9, v)

def p.usedown(+g: Sim) -> U32:
  pget(g, 10)

def p.usedown.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 10, v)

def p.attacker(+g: Sim) -> U32:
  pget(g, 11)

def p.attacker.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 11, v)

def p.damagecount(+g: Sim) -> U32:
  pget(g, 12)

def p.damagecount.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 12, v)

def p.bonuscount(+g: Sim) -> U32:
  pget(g, 13)

def p.bonuscount.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 13, v)

def p.extralight(+g: Sim) -> U32:
  pget(g, 14)

def p.extralight.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 14, v)

def p.fixedcm(+g: Sim) -> U32:
  pget(g, 15)

def p.fixedcm.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 15, v)

def p.cheats(+g: Sim) -> U32:
  pget(g, 16)

def p.cheats.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 16, v)

def p.secrets(+g: Sim) -> U32:
  pget(g, 17)

def p.secrets.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 17, v)

def p.kills(+g: Sim) -> U32:
  pget(g, 18)

def p.kills.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 18, v)

def p.items(+g: Sim) -> U32:
  pget(g, 19)

def p.items.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 19, v)

def p.fwd(+g: Sim) -> U32:
  pget(g, 20)

def p.fwd.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 20, v)

def p.side(+g: Sim) -> U32:
  pget(g, 21)

def p.side.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 21, v)

def p.turn(+g: Sim) -> U32:
  pget(g, 22)

def p.turn.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 22, v)

def p.buttons(+g: Sim) -> U32:
  pget(g, 23)

def p.buttons.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 23, v)

def p.pw0(+g: Sim) -> U32:
  pget(g, 24)

def p.pw0.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 24, v)

def p.pw1(+g: Sim) -> U32:
  pget(g, 25)

def p.pw1.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 25, v)

def p.pw2(+g: Sim) -> U32:
  pget(g, 26)

def p.pw2.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 26, v)

def p.pw3(+g: Sim) -> U32:
  pget(g, 27)

def p.pw3.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 27, v)

def p.pw4(+g: Sim) -> U32:
  pget(g, 28)

def p.pw4.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 28, v)

def p.pw5(+g: Sim) -> U32:
  pget(g, 29)

def p.pw5.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 29, v)

def p.refire(+g: Sim) -> U32:
  pget(g, 30)

def p.refire.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 30, v)

def p.ready(+g: Sim) -> U32:
  pget(g, 31)

def p.ready.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 31, v)

def p.pending(+g: Sim) -> U32:
  pget(g, 32)

def p.pending.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 32, v)

def p.own0(+g: Sim) -> U32:
  pget(g, 33)

def p.own0.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 33, v)

def p.own1(+g: Sim) -> U32:
  pget(g, 34)

def p.own1.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 34, v)

def p.own2(+g: Sim) -> U32:
  pget(g, 35)

def p.own2.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 35, v)

def p.own3(+g: Sim) -> U32:
  pget(g, 36)

def p.own3.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 36, v)

def p.own4(+g: Sim) -> U32:
  pget(g, 37)

def p.own4.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 37, v)

def p.own5(+g: Sim) -> U32:
  pget(g, 38)

def p.own5.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 38, v)

def p.own6(+g: Sim) -> U32:
  pget(g, 39)

def p.own6.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 39, v)

def p.own7(+g: Sim) -> U32:
  pget(g, 40)

def p.own7.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 40, v)

def p.own8(+g: Sim) -> U32:
  pget(g, 41)

def p.own8.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 41, v)

def p.ammo0(+g: Sim) -> U32:
  pget(g, 42)

def p.ammo0.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 42, v)

def p.ammo1(+g: Sim) -> U32:
  pget(g, 43)

def p.ammo1.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 43, v)

def p.ammo2(+g: Sim) -> U32:
  pget(g, 44)

def p.ammo2.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 44, v)

def p.ammo3(+g: Sim) -> U32:
  pget(g, 45)

def p.ammo3.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 45, v)

def p.max0(+g: Sim) -> U32:
  pget(g, 46)

def p.max0.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 46, v)

def p.max1(+g: Sim) -> U32:
  pget(g, 47)

def p.max1.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 47, v)

def p.max2(+g: Sim) -> U32:
  pget(g, 48)

def p.max2.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 48, v)

def p.max3(+g: Sim) -> U32:
  pget(g, 49)

def p.max3.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 49, v)

def p.backpack(+g: Sim) -> U32:
  pget(g, 50)

def p.backpack.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 50, v)

def p.attackdown(+g: Sim) -> U32:
  pget(g, 51)

def p.attackdown.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 51, v)

def p.message(+g: Sim) -> U32:
  pget(g, 52)

def p.message.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 52, v)

def p.psp0st(+g: Sim) -> U32:
  pget(g, 53)

def p.psp0st.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 53, v)

def p.psp0tics(+g: Sim) -> U32:
  pget(g, 54)

def p.psp0tics.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 54, v)

def p.psp0sx(+g: Sim) -> U32:
  pget(g, 55)

def p.psp0sx.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 55, v)

def p.psp0sy(+g: Sim) -> U32:
  pget(g, 56)

def p.psp0sy.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 56, v)

def p.psp1st(+g: Sim) -> U32:
  pget(g, 57)

def p.psp1st.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 57, v)

def p.psp1tics(+g: Sim) -> U32:
  pget(g, 58)

def p.psp1tics.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 58, v)

def p.psp1sx(+g: Sim) -> U32:
  pget(g, 59)

def p.psp1sx.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 59, v)

def p.psp1sy(+g: Sim) -> U32:
  pget(g, 60)

def p.psp1sy.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 60, v)

def p.onground(+g: Sim) -> U32:
  pget(g, 61)

def p.onground.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 61, v)

def p.didsecret(+g: Sim) -> U32:
  pget(g, 62)

def p.didsecret.set(+g: Sim, +v: U32) -> Sim:
  pput(g, 62, v)

def sc.floor(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x0

def sc.floor.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{v, x1, x2, x3, x4, x5, x6, x7, x8}

def s.floor(+g: Sim, +s: U32) -> U32:
  sc.floor(sec(g, s))

def s.floor.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.floor.set(sec(g, s), v)))

def sc.ceil(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x1

def sc.ceil.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{x0, v, x2, x3, x4, x5, x6, x7, x8}

def s.ceil(+g: Sim, +s: U32) -> U32:
  sc.ceil(sec(g, s))

def s.ceil.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.ceil.set(sec(g, s), v)))

def sc.fpic(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x2

def sc.fpic.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{x0, x1, v, x3, x4, x5, x6, x7, x8}

def s.fpic(+g: Sim, +s: U32) -> U32:
  sc.fpic(sec(g, s))

def s.fpic.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.fpic.set(sec(g, s), v)))

def sc.cpic(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x3

def sc.cpic.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{x0, x1, x2, v, x4, x5, x6, x7, x8}

def s.cpic(+g: Sim, +s: U32) -> U32:
  sc.cpic(sec(g, s))

def s.cpic.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.cpic.set(sec(g, s), v)))

def sc.light(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x4

def sc.light.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{x0, x1, x2, x3, v, x5, x6, x7, x8}

def s.light(+g: Sim, +s: U32) -> U32:
  sc.light(sec(g, s))

def s.light.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.light.set(sec(g, s), v)))

def sc.special(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x5

def sc.special.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{x0, x1, x2, x3, x4, v, x6, x7, x8}

def s.special(+g: Sim, +s: U32) -> U32:
  sc.special(sec(g, s))

def s.special.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.special.set(sec(g, s), v)))

def sc.tag(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x6

def sc.tag.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{x0, x1, x2, x3, x4, x5, v, x7, x8}

def s.tag(+g: Sim, +s: U32) -> U32:
  sc.tag(sec(g, s))

def s.tag.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.tag.set(sec(g, s), v)))

def sc.data(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x7

def sc.data.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{x0, x1, x2, x3, x4, x5, x6, v, x8}

def s.data(+g: Sim, +s: U32) -> U32:
  sc.data(sec(g, s))

def s.data.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.data.set(sec(g, s), v)))

def sc.things(+r: R.RSector) -> U32:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      x8

def sc.things.set(r: R.RSector, +v: U32) -> R.RSector:
  match r:
    case R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, x8}:
      R.RSector{x0, x1, x2, x3, x4, x5, x6, x7, v}

def s.things(+g: Sim, +s: U32) -> U32:
  sc.things(sec(g, s))

def s.things.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.sector(sim.w(g), s, sc.things.set(sec(g, s), v)))

def sdr.xoff(+r: R.RSide) -> U32:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      x0

def sdr.xoff.set(r: R.RSide, +v: U32) -> R.RSide:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      R.RSide{v, x1, x2, x3, x4, x5}

def sd.xoff(+g: Sim, +s: U32) -> U32:
  sdr.xoff(side(g, s))

def sd.xoff.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.side(sim.w(g), s, sdr.xoff.set(side(g, s), v)))

def sdr.yoff(+r: R.RSide) -> U32:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      x1

def sdr.yoff.set(r: R.RSide, +v: U32) -> R.RSide:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      R.RSide{x0, v, x2, x3, x4, x5}

def sd.yoff(+g: Sim, +s: U32) -> U32:
  sdr.yoff(side(g, s))

def sd.yoff.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.side(sim.w(g), s, sdr.yoff.set(side(g, s), v)))

def sdr.top(+r: R.RSide) -> U32:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      x2

def sdr.top.set(r: R.RSide, +v: U32) -> R.RSide:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      R.RSide{x0, x1, v, x3, x4, x5}

def sd.top(+g: Sim, +s: U32) -> U32:
  sdr.top(side(g, s))

def sd.top.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.side(sim.w(g), s, sdr.top.set(side(g, s), v)))

def sdr.bottom(+r: R.RSide) -> U32:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      x3

def sdr.bottom.set(r: R.RSide, +v: U32) -> R.RSide:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      R.RSide{x0, x1, x2, v, x4, x5}

def sd.bottom(+g: Sim, +s: U32) -> U32:
  sdr.bottom(side(g, s))

def sd.bottom.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.side(sim.w(g), s, sdr.bottom.set(side(g, s), v)))

def sdr.mid(+r: R.RSide) -> U32:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      x4

def sdr.mid.set(r: R.RSide, +v: U32) -> R.RSide:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      R.RSide{x0, x1, x2, x3, v, x5}

def sd.mid(+g: Sim, +s: U32) -> U32:
  sdr.mid(side(g, s))

def sd.mid.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.side(sim.w(g), s, sdr.mid.set(side(g, s), v)))

def sdr.sector(+r: R.RSide) -> U32:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      x5

def sdr.sector.set(r: R.RSide, +v: U32) -> R.RSide:
  match r:
    case R.RSide{x0, x1, x2, x3, x4, x5}:
      R.RSide{x0, x1, x2, x3, x4, v}

def sd.sector(+g: Sim, +s: U32) -> U32:
  sdr.sector(side(g, s))

def sd.sector.set(+g: Sim, +s: U32, +v: U32) -> Sim:
  sim.w.set(g, R.set.side(sim.w(g), s, sdr.sector.set(side(g, s), v)))

def l.x1(+g: Sim, +l: U32) -> U32:
  ln.x1(line(g, l))

def l.y1(+g: Sim, +l: U32) -> U32:
  ln.y1(line(g, l))

def l.x2(+g: Sim, +l: U32) -> U32:
  ln.x2(line(g, l))

def l.y2(+g: Sim, +l: U32) -> U32:
  ln.y2(line(g, l))

def l.dx(+g: Sim, +l: U32) -> U32:
  ln.dx(line(g, l))

def l.dy(+g: Sim, +l: U32) -> U32:
  ln.dy(line(g, l))

def l.flags(+g: Sim, +l: U32) -> U32:
  ln.flags(line(g, l))

def l.slope(+g: Sim, +l: U32) -> U32:
  ln.slope(line(g, l))

def l.top(+g: Sim, +l: U32) -> U32:
  ln.top(line(g, l))

def l.bottom(+g: Sim, +l: U32) -> U32:
  ln.bottom(line(g, l))

def l.left(+g: Sim, +l: U32) -> U32:
  ln.left(line(g, l))

def l.right(+g: Sim, +l: U32) -> U32:
  ln.right(line(g, l))

def l.side0(+g: Sim, +l: U32) -> U32:
  ln.side0(line(g, l))

def l.side1(+g: Sim, +l: U32) -> U32:
  ln.side1(line(g, l))

def l.fsec(+g: Sim, +l: U32) -> U32:
  ln.fsec(line(g, l))

def l.bsec(+g: Sim, +l: U32) -> U32:
  ln.bsec(line(g, l))

def l.tag(+g: Sim, +l: U32) -> U32:
  ln.tag(line(g, l))
