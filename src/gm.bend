import Base
import ./tab.bend as T
import ./sf2.bend as G

type Env is Data:
  Env{seg: U32, expo: U32, amp: U32, vel: U32, lv: F32, sl: F32, un: U32, dl: F32, at: F32, ho: F32, de: F32, su: F32, re: F32}

type Lp is Data:
  Lp{qi: F32, a0: F32, a1: F32, b1: F32, b2: F32, z1: F32, z2: F32, on: U32}

type Lf is Data:
  Lf{un: U32, lv: F32, dt: F32}

type Rg is Data:
  Rg{mode: U32, group: U32, end: U32, tr: U32, tune: U32, kc: U32, kt: U32, rate: U32, pan: F32, fc: U32, mlf: U32, mef: U32, mlp: U32, vlp: U32, mep: U32, mlv: U32}

type Vc is Data:
  Vc{pi: U32, key: U32, ch: U32, held: U32, play: U32, pin: F32, pout: F32, pos: U32, frac: U32, gdb: F32, pl: F32, pr: F32, ls: U32, le: U32, amp: Env, mod: Env, lp: Lp, ml: Lf, vl: Lf, rg: Rg}

type Cn is Data:
  Cn{pi: U32, bank: U32, wheel: U32, mpan: U32, mvol: U32, mexp: U32, rpn: U32, data: U32, sus: U32, po: F32, gdb: F32, rng: F32, tun: F32}

type Syn is Data:
  Syn{vs: List<&2, Vc>, cs: List<&2, Cn>, play: U32, vol: U32}

def env.seg(+x: Env) -> U32:
  match x:
    case Env{+seg, expo, amp, vel, lv, sl, un, dl, at, ho, de, su, re}:
      seg

def env.expo(+x: Env) -> U32:
  match x:
    case Env{seg, +expo, amp, vel, lv, sl, un, dl, at, ho, de, su, re}:
      expo

def env.amp(+x: Env) -> U32:
  match x:
    case Env{seg, expo, +amp, vel, lv, sl, un, dl, at, ho, de, su, re}:
      amp

def env.vel(+x: Env) -> U32:
  match x:
    case Env{seg, expo, amp, +vel, lv, sl, un, dl, at, ho, de, su, re}:
      vel

def env.lv(+x: Env) -> F32:
  match x:
    case Env{seg, expo, amp, vel, +lv, sl, un, dl, at, ho, de, su, re}:
      lv

def env.lv.set(+x: Env, +v: F32) -> Env:
  match x:
    case Env{+seg, +expo, +amp, +vel, lv, +sl, +un, +dl, +at, +ho, +de, +su, +re}:
      Env{seg, expo, amp, vel, v, sl, un, dl, at, ho, de, su, re}

def env.sl(+x: Env) -> F32:
  match x:
    case Env{seg, expo, amp, vel, lv, +sl, un, dl, at, ho, de, su, re}:
      sl

def env.un(+x: Env) -> U32:
  match x:
    case Env{seg, expo, amp, vel, lv, sl, +un, dl, at, ho, de, su, re}:
      un

def env.un.set(+x: Env, +v: U32) -> Env:
  match x:
    case Env{+seg, +expo, +amp, +vel, +lv, +sl, un, +dl, +at, +ho, +de, +su, +re}:
      Env{seg, expo, amp, vel, lv, sl, v, dl, at, ho, de, su, re}

def env.dl(+x: Env) -> F32:
  match x:
    case Env{seg, expo, amp, vel, lv, sl, un, +dl, at, ho, de, su, re}:
      dl

def env.at(+x: Env) -> F32:
  match x:
    case Env{seg, expo, amp, vel, lv, sl, un, dl, +at, ho, de, su, re}:
      at

def env.ho(+x: Env) -> F32:
  match x:
    case Env{seg, expo, amp, vel, lv, sl, un, dl, at, +ho, de, su, re}:
      ho

def env.de(+x: Env) -> F32:
  match x:
    case Env{seg, expo, amp, vel, lv, sl, un, dl, at, ho, +de, su, re}:
      de

def env.su(+x: Env) -> F32:
  match x:
    case Env{seg, expo, amp, vel, lv, sl, un, dl, at, ho, de, +su, re}:
      su

def env.re(+x: Env) -> F32:
  match x:
    case Env{seg, expo, amp, vel, lv, sl, un, dl, at, ho, de, su, +re}:
      re

def env.re.set(+x: Env, +v: F32) -> Env:
  match x:
    case Env{+seg, +expo, +amp, +vel, +lv, +sl, +un, +dl, +at, +ho, +de, +su, re}:
      Env{seg, expo, amp, vel, lv, sl, un, dl, at, ho, de, su, v}

def lp.qi(+x: Lp) -> F32:
  match x:
    case Lp{+qi, a0, a1, b1, b2, z1, z2, on}:
      qi

def lp.a0(+x: Lp) -> F32:
  match x:
    case Lp{qi, +a0, a1, b1, b2, z1, z2, on}:
      a0

def lp.a1(+x: Lp) -> F32:
  match x:
    case Lp{qi, a0, +a1, b1, b2, z1, z2, on}:
      a1

def lp.b1(+x: Lp) -> F32:
  match x:
    case Lp{qi, a0, a1, +b1, b2, z1, z2, on}:
      b1

def lp.b2(+x: Lp) -> F32:
  match x:
    case Lp{qi, a0, a1, b1, +b2, z1, z2, on}:
      b2

def lp.z1(+x: Lp) -> F32:
  match x:
    case Lp{qi, a0, a1, b1, b2, +z1, z2, on}:
      z1

def lp.z1.set(+x: Lp, +v: F32) -> Lp:
  match x:
    case Lp{+qi, +a0, +a1, +b1, +b2, z1, +z2, +on}:
      Lp{qi, a0, a1, b1, b2, v, z2, on}

def lp.z2(+x: Lp) -> F32:
  match x:
    case Lp{qi, a0, a1, b1, b2, z1, +z2, on}:
      z2

def lp.z2.set(+x: Lp, +v: F32) -> Lp:
  match x:
    case Lp{+qi, +a0, +a1, +b1, +b2, +z1, z2, +on}:
      Lp{qi, a0, a1, b1, b2, z1, v, on}

def lp.on(+x: Lp) -> U32:
  match x:
    case Lp{qi, a0, a1, b1, b2, z1, z2, +on}:
      on

def lp.on.set(+x: Lp, +v: U32) -> Lp:
  match x:
    case Lp{+qi, +a0, +a1, +b1, +b2, +z1, +z2, on}:
      Lp{qi, a0, a1, b1, b2, z1, z2, v}

def lf.un(+x: Lf) -> U32:
  match x:
    case Lf{+un, lv, dt}:
      un

def lf.lv(+x: Lf) -> F32:
  match x:
    case Lf{un, +lv, dt}:
      lv

def lf.dt(+x: Lf) -> F32:
  match x:
    case Lf{un, lv, +dt}:
      dt

def rg.mode(+x: Rg) -> U32:
  match x:
    case Rg{+mode, group, end, tr, tune, kc, kt, rate, pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      mode

def rg.group(+x: Rg) -> U32:
  match x:
    case Rg{mode, +group, end, tr, tune, kc, kt, rate, pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      group

def rg.end(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, +end, tr, tune, kc, kt, rate, pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      end

def rg.tr(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, +tr, tune, kc, kt, rate, pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      tr

def rg.tune(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, +tune, kc, kt, rate, pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      tune

def rg.kc(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, +kc, kt, rate, pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      kc

def rg.kt(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, +kt, rate, pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      kt

def rg.rate(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, +rate, pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      rate

def rg.pan(+x: Rg) -> F32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, rate, +pan, fc, mlf, mef, mlp, vlp, mep, mlv}:
      pan

def rg.fc(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, rate, pan, +fc, mlf, mef, mlp, vlp, mep, mlv}:
      fc

def rg.mlf(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, rate, pan, fc, +mlf, mef, mlp, vlp, mep, mlv}:
      mlf

def rg.mef(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, rate, pan, fc, mlf, +mef, mlp, vlp, mep, mlv}:
      mef

def rg.mlp(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, rate, pan, fc, mlf, mef, +mlp, vlp, mep, mlv}:
      mlp

def rg.vlp(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, rate, pan, fc, mlf, mef, mlp, +vlp, mep, mlv}:
      vlp

def rg.mep(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, rate, pan, fc, mlf, mef, mlp, vlp, +mep, mlv}:
      mep

def rg.mlv(+x: Rg) -> U32:
  match x:
    case Rg{mode, group, end, tr, tune, kc, kt, rate, pan, fc, mlf, mef, mlp, vlp, mep, +mlv}:
      mlv

def vc.pi(+x: Vc) -> U32:
  match x:
    case Vc{+pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      pi

def vc.pi.set(+x: Vc, +v: U32) -> Vc:
  match x:
    case Vc{pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{v, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}

def vc.key(+x: Vc) -> U32:
  match x:
    case Vc{pi, +key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      key

def vc.ch(+x: Vc) -> U32:
  match x:
    case Vc{pi, key, +ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      ch

def vc.held(+x: Vc) -> U32:
  match x:
    case Vc{pi, key, ch, +held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      held

def vc.held.set(+x: Vc, +v: U32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, v, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}

def vc.play(+x: Vc) -> U32:
  match x:
    case Vc{pi, key, ch, held, +play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      play

def vc.pin(+x: Vc) -> F32:
  match x:
    case Vc{pi, key, ch, held, play, +pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      pin

def vc.pin.set(+x: Vc, +v: F32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, v, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}

def vc.pout(+x: Vc) -> F32:
  match x:
    case Vc{pi, key, ch, held, play, pin, +pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      pout

def vc.pout.set(+x: Vc, +v: F32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, v, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}

def vc.pos(+x: Vc) -> U32:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, +pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      pos

def vc.pos.set(+x: Vc, +v: U32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, v, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}

def vc.frac(+x: Vc) -> U32:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, +frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      frac

def vc.frac.set(+x: Vc, +v: U32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, v, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}

def vc.gdb(+x: Vc) -> F32:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, +gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      gdb

def vc.gdb.set(+x: Vc, +v: F32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, v, pl, pr, ls, le, amp, mod, lp, ml, vl, rg}

def vc.pl(+x: Vc) -> F32:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, +pl, pr, ls, le, amp, mod, lp, ml, vl, rg}:
      pl

def vc.pl.set(+x: Vc, +v: F32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, v, pr, ls, le, amp, mod, lp, ml, vl, rg}

def vc.pr(+x: Vc) -> F32:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, +pr, ls, le, amp, mod, lp, ml, vl, rg}:
      pr

def vc.pr.set(+x: Vc, +v: F32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, pr, +ls, +le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, v, ls, le, amp, mod, lp, ml, vl, rg}

def vc.ls(+x: Vc) -> U32:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, +ls, le, amp, mod, lp, ml, vl, rg}:
      ls

def vc.le(+x: Vc) -> U32:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, +le, amp, mod, lp, ml, vl, rg}:
      le

def vc.le.set(+x: Vc, +v: U32) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, le, +amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, v, amp, mod, lp, ml, vl, rg}

def vc.amp(+x: Vc) -> Env:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, +amp, mod, lp, ml, vl, rg}:
      amp

def vc.amp.set(+x: Vc, +v: Env) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, amp, +mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, v, mod, lp, ml, vl, rg}

def vc.mod(+x: Vc) -> Env:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, +mod, lp, ml, vl, rg}:
      mod

def vc.mod.set(+x: Vc, +v: Env) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, mod, +lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, v, lp, ml, vl, rg}

def vc.lp(+x: Vc) -> Lp:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, +lp, ml, vl, rg}:
      lp

def vc.lp.set(+x: Vc, +v: Lp) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, lp, +ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, v, ml, vl, rg}

def vc.ml(+x: Vc) -> Lf:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, +ml, vl, rg}:
      ml

def vc.ml.set(+x: Vc, +v: Lf) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, ml, +vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, v, vl, rg}

def vc.vl(+x: Vc) -> Lf:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, +vl, rg}:
      vl

def vc.vl.set(+x: Vc, +v: Lf) -> Vc:
  match x:
    case Vc{+pi, +key, +ch, +held, +play, +pin, +pout, +pos, +frac, +gdb, +pl, +pr, +ls, +le, +amp, +mod, +lp, +ml, vl, +rg}:
      Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, v, rg}

def vc.rg(+x: Vc) -> Rg:
  match x:
    case Vc{pi, key, ch, held, play, pin, pout, pos, frac, gdb, pl, pr, ls, le, amp, mod, lp, ml, vl, +rg}:
      rg

def cn.pi(+x: Cn) -> U32:
  match x:
    case Cn{+pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, tun}:
      pi

def cn.pi.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{pi, +bank, +wheel, +mpan, +mvol, +mexp, +rpn, +data, +sus, +po, +gdb, +rng, +tun}:
      Cn{v, bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, tun}

def cn.bank(+x: Cn) -> U32:
  match x:
    case Cn{pi, +bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, tun}:
      bank

def cn.bank.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{+pi, bank, +wheel, +mpan, +mvol, +mexp, +rpn, +data, +sus, +po, +gdb, +rng, +tun}:
      Cn{pi, v, wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, tun}

def cn.wheel(+x: Cn) -> U32:
  match x:
    case Cn{pi, bank, +wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, tun}:
      wheel

def cn.wheel.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{+pi, +bank, wheel, +mpan, +mvol, +mexp, +rpn, +data, +sus, +po, +gdb, +rng, +tun}:
      Cn{pi, bank, v, mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, tun}

def cn.mpan(+x: Cn) -> U32:
  match x:
    case Cn{pi, bank, wheel, +mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, tun}:
      mpan

def cn.mpan.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, mpan, +mvol, +mexp, +rpn, +data, +sus, +po, +gdb, +rng, +tun}:
      Cn{pi, bank, wheel, v, mvol, mexp, rpn, data, sus, po, gdb, rng, tun}

def cn.mvol(+x: Cn) -> U32:
  match x:
    case Cn{pi, bank, wheel, mpan, +mvol, mexp, rpn, data, sus, po, gdb, rng, tun}:
      mvol

def cn.mvol.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, mvol, +mexp, +rpn, +data, +sus, +po, +gdb, +rng, +tun}:
      Cn{pi, bank, wheel, mpan, v, mexp, rpn, data, sus, po, gdb, rng, tun}

def cn.mexp(+x: Cn) -> U32:
  match x:
    case Cn{pi, bank, wheel, mpan, mvol, +mexp, rpn, data, sus, po, gdb, rng, tun}:
      mexp

def cn.mexp.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, +mvol, mexp, +rpn, +data, +sus, +po, +gdb, +rng, +tun}:
      Cn{pi, bank, wheel, mpan, mvol, v, rpn, data, sus, po, gdb, rng, tun}

def cn.rpn(+x: Cn) -> U32:
  match x:
    case Cn{pi, bank, wheel, mpan, mvol, mexp, +rpn, data, sus, po, gdb, rng, tun}:
      rpn

def cn.rpn.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, +mvol, +mexp, rpn, +data, +sus, +po, +gdb, +rng, +tun}:
      Cn{pi, bank, wheel, mpan, mvol, mexp, v, data, sus, po, gdb, rng, tun}

def cn.data(+x: Cn) -> U32:
  match x:
    case Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, +data, sus, po, gdb, rng, tun}:
      data

def cn.data.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, +mvol, +mexp, +rpn, data, +sus, +po, +gdb, +rng, +tun}:
      Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, v, sus, po, gdb, rng, tun}

def cn.sus(+x: Cn) -> U32:
  match x:
    case Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, +sus, po, gdb, rng, tun}:
      sus

def cn.sus.set(+x: Cn, +v: U32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, +mvol, +mexp, +rpn, +data, sus, +po, +gdb, +rng, +tun}:
      Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, v, po, gdb, rng, tun}

def cn.po(+x: Cn) -> F32:
  match x:
    case Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, +po, gdb, rng, tun}:
      po

def cn.po.set(+x: Cn, +v: F32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, +mvol, +mexp, +rpn, +data, +sus, po, +gdb, +rng, +tun}:
      Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, v, gdb, rng, tun}

def cn.gdb(+x: Cn) -> F32:
  match x:
    case Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, +gdb, rng, tun}:
      gdb

def cn.gdb.set(+x: Cn, +v: F32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, +mvol, +mexp, +rpn, +data, +sus, +po, gdb, +rng, +tun}:
      Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, v, rng, tun}

def cn.rng(+x: Cn) -> F32:
  match x:
    case Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, +rng, tun}:
      rng

def cn.rng.set(+x: Cn, +v: F32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, +mvol, +mexp, +rpn, +data, +sus, +po, +gdb, rng, +tun}:
      Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, v, tun}

def cn.tun(+x: Cn) -> F32:
  match x:
    case Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, +tun}:
      tun

def cn.tun.set(+x: Cn, +v: F32) -> Cn:
  match x:
    case Cn{+pi, +bank, +wheel, +mpan, +mvol, +mexp, +rpn, +data, +sus, +po, +gdb, +rng, tun}:
      Cn{pi, bank, wheel, mpan, mvol, mexp, rpn, data, sus, po, gdb, rng, v}

def syn.vs(+x: Syn) -> List<&2, Vc>:
  match x:
    case Syn{+vs, cs, play, vol}:
      vs

def syn.vs.set(+x: Syn, +v: List<&2, Vc>) -> Syn:
  match x:
    case Syn{vs, +cs, +play, +vol}:
      Syn{v, cs, play, vol}

def syn.cs(+x: Syn) -> List<&2, Cn>:
  match x:
    case Syn{vs, +cs, play, vol}:
      cs

def syn.cs.set(+x: Syn, +v: List<&2, Cn>) -> Syn:
  match x:
    case Syn{+vs, cs, +play, +vol}:
      Syn{vs, v, play, vol}

def syn.play(+x: Syn) -> U32:
  match x:
    case Syn{vs, cs, +play, vol}:
      play

def syn.play.set(+x: Syn, +v: U32) -> Syn:
  match x:
    case Syn{+vs, +cs, play, +vol}:
      Syn{vs, cs, v, vol}

def syn.vol(+x: Syn) -> U32:
  match x:
    case Syn{vs, cs, play, +vol}:
      vol

def syn.vol.set(+x: Syn, +v: U32) -> Syn:
  match x:
    case Syn{+vs, +cs, +play, vol}:
      Syn{vs, cs, play, v}



def none() -> U32:
  4294967295

def rate() -> F32:
  22050.0

def neg(+x: U32) -> Bool:
  U32.is_ge(x, 2147483648)

def sle0(+x: U32) -> Bool:
  Bool.or(U32.is_eq(x, 0), neg(x))

def toi(+x: F32) -> U32:
  F32.to_u32(x)

def c2hz(+c: F32) -> F32:
  (8.176 * F32.pow(2.0, (c / 1200.0 : F32)) : F32)

def g2db(+g: F32) -> F32:
  Bool.pick(F32, F32.is_le(g, 0.00001), (0.0 - 100.0 : F32), (20.0 * F32.log10(g) : F32))

def env.mk(+e: Env, +seg: U32, +expo: U32, +lv: F32, +sl: F32, +un: U32) -> Env:
  match e:
    case Env{s0, e0, +amp, +vel, l0, s1, u0, +dl, +at, +ho, +de, +su, +re}:
      Env{seg, expo, amp, vel, lv, sl, un, dl, at, ho, de, su, re}

def env.rel(+e: Env) -> U32:
  +re = env.re(e)
  toi((Bool.pick(F32, F32.is_le(re, 0.0), 0.01, re) * rate() : F32))

def env.decay(+e: Env) -> Env:
  +un = toi((env.de(e) * rate() : F32))
  +su = env.su(e)
  +m = ((0.0 - 9.226 : F32) / U32.to_f32(un) : F32)
  Bool.pick(Env, U32.is_eq(env.amp(e), 1),
    env.mk(e, 4, 1, 1.0, F32.exp(m), Bool.pick(U32, F32.is_gt(su, 0.0), toi((F32.log(su) / m : F32)), un)),
    env.mk(e, 4, 0, 1.0, ((0.0 - 1.0 : F32) / U32.to_f32(un) : F32), toi(((env.de(e) * (1.0 - su : F32) : F32) * rate() : F32))))

def env.release(+e: Env) -> Env:
  +un = env.rel(e)
  +m = ((0.0 - 9.226 : F32) / U32.to_f32(un) : F32)
  Bool.pick(Env, U32.is_eq(env.amp(e), 1), env.mk(e, 6, 1, env.lv(e), F32.exp(m), un),
    env.mk(e, 6, 0, env.lv(e), ((0.0 - env.lv(e) : F32) / U32.to_f32(un) : F32), un))

def env.attack(+e: Env) -> Env:
  +u0 = toi((env.at(e) * rate() : F32))
  +un = Bool.pick(U32, U32.is_eq(env.amp(e), 1), u0, toi(((env.at(e) * (U32.to_f32((145 - env.vel(e) : U32)) / 144.0 : F32) : F32) * rate() : F32)))
  env.mk(e, 2, 0, 0.0, (1.0 / U32.to_f32(un) : F32), un)

def env.next(+e: Env, +s: U32) -> Env:
  +d = toi((env.dl(e) * rate() : F32))
  +a = toi((env.at(e) * rate() : F32))
  +h = toi((env.ho(e) * rate() : F32))
  +c = toi((env.de(e) * rate() : F32))
  Bool.pick(Env, Bool.and(U32.is_eq(s, 0), U32.is_gt(d, 0)), env.mk(e, 1, 0, 0.0, 0.0, d),
    Bool.pick(Env, Bool.and(U32.is_le(s, 1), U32.is_gt(a, 0)), env.attack(e),
      Bool.pick(Env, Bool.and(U32.is_le(s, 2), U32.is_gt(h, 0)), env.mk(e, 3, 0, 1.0, 0.0, h),
        Bool.pick(Env, Bool.and(U32.is_le(s, 3), U32.is_gt(c, 0)), env.decay(e),
          Bool.pick(Env, U32.is_le(s, 4), env.mk(e, 5, 0, env.su(e), 0.0, 2147483647),
            Bool.pick(Env, U32.is_eq(s, 5), env.release(e), env.mk(e, 7, 0, 0.0, 0.0, 134217727)))))))

def keyed(+t: F32, +k: F32, +key: U32) -> F32:
  +x = (t + (k * (60.0 - U32.to_f32(key) : F32) : F32) : F32)
  Bool.pick(F32, F32.is_eq(k, 0.0), t, Bool.pick(F32, F32.is_lt(x, (0.0 - 10000.0 : F32)), 0.0, G.tc2s(x)))

def env.setup(+r: T.Vec<U32>, +b: U32, +key: U32, +vel: U32, +amp: U32) -> Env:
  env.next(Env{0, 0, amp, vel, 0.0, 0.0, 0, G.gf(r, b), G.gf(r, (b + 1 : U32)), keyed(G.gf(r, (b + 2 : U32)), G.gf(r, (b + 6 : U32)), key), keyed(G.gf(r, (b + 3 : U32)), G.gf(r, (b + 7 : U32)), key), G.gf(r, (b + 4 : U32)), G.gf(r, (b + 5 : U32))}, 0)

def env.proc(+e: Env, +n: U32) -> Env:
  +sl = env.sl(e)
  +lv = env.lv(e)
  +nf = U32.to_f32(n)
  +l2 = Bool.pick(F32, F32.is_eq(sl, 0.0), lv, Bool.pick(F32, U32.is_eq(env.expo(e), 1), (lv * F32.pow(sl, nf) : F32), (lv + (sl * nf : F32) : F32)))
  +un = (env.un(e) - n : U32)
  +e2 = env.un.set(env.lv.set(e, l2), un)
  Bool.pick(Env, sle0(un), env.next(e2, env.seg(e)), e2)

def lp.setup(+l: Lp, +fc: F32) -> Lp:
  +k = F32.tan((3.14159265 * fc : F32))
  +kk = (k * k : F32)
  +qi = lp.qi(l)
  +norm = (1.0 / (((1.0 + (k * qi : F32) : F32) + kk) : F32) : F32)
  +a0 = (kk * norm : F32)
  Lp{qi, a0, (2.0 * a0 : F32), ((2.0 * (kk - 1.0 : F32) : F32) * norm : F32), ((((1.0 - (k * qi : F32) : F32) + kk) : F32) * norm : F32), lp.z1(l), lp.z2(l), 1}

def lp.at(+l: Lp, +fc: F32) -> Lp:
  Bool.pick(Lp, F32.is_lt(fc, 0.499), lp.setup(l, fc), lp.on.set(l, 0))

def lf.setup(+delay: F32, +fc: U32) -> Lf:
  Lf{toi((delay * rate() : F32)), 0.0, ((4.0 * c2hz(G.sf(fc)) : F32) / rate() : F32)}

def lf.proc(+f: Lf, +n: U32) -> Lf:
  +un = lf.un(f)
  +dt = lf.dt(f)
  +lv = (lf.lv(f) + (dt * U32.to_f32(n) : F32) : F32)
  Bool.pick(Lf, G.slt(n, un), Lf{(un - n : U32), lf.lv(f), dt},
    Bool.pick(Lf, F32.is_gt(lv, 1.0), Lf{un, (2.0 - lv : F32), (0.0 - dt : F32)},
      Bool.pick(Lf, F32.is_lt(lv, (0.0 - 1.0 : F32)), Lf{un, ((0.0 - 2.0 : F32) - lv : F32), (0.0 - dt : F32)}, Lf{un, lv, dt})))

def vend(+v: Vc) -> Vc:
  +v2 = vc.mod.set(vc.amp.set(v, env.next(vc.amp(v), 5)), env.next(vc.mod(v), 5))
  Bool.pick(Vc, U32.is_eq(rg.mode(vc.rg(v)), 2), vc.le.set(v2, vc.ls(v2)), v2)

def vquick(+v: Vc) -> Vc:
  vc.mod.set(vc.amp.set(v, env.next(env.re.set(vc.amp(v), 0.0), 5)), env.next(env.re.set(vc.mod(v), 0.0), 5))

def shift(+c: Cn) -> F32:
  +r = cn.rng(c)
  Bool.pick(F32, U32.is_eq(cn.wheel(c), 8192), cn.tun(c), (((((U32.to_f32(cn.wheel(c)) / 16383.0 : F32) * r : F32) * 2.0 : F32) - r : F32) + cn.tun(c) : F32))

def pitch(+v: Vc, +sh: F32) -> Vc:
  +r = vc.rg(v)
  +kc = G.sf(rg.kc(r))
  +note = (G.sf((vc.key(v) + rg.tr(r) : U32)) + (G.sf(rg.tune(r)) / 100.0 : F32) : F32)
  +adj = (kc + ((note - kc : F32) * (G.sf(rg.kt(r)) / 100.0 : F32) : F32) : F32)
  +adj2 = Bool.pick(F32, F32.is_ne(sh, 0.0), (adj + sh : F32), adj)
  vc.pout.set(vc.pin.set(v, (adj2 * 100.0 : F32)), (U32.to_f32(rg.rate(r)) / (G.tc2s((kc * 100.0 : F32)) * rate() : F32) : F32))

def setpan(+v: Vc, +np: F32) -> Vc:
  Bool.pick(Vc, F32.is_le(np, (0.0 - 0.5 : F32)), vc.pr.set(vc.pl.set(v, 1.0), 0.0),
    Bool.pick(Vc, F32.is_ge(np, 0.5), vc.pr.set(vc.pl.set(v, 0.0), 1.0),
      vc.pr.set(vc.pl.set(v, F32.sqrt((0.5 - np : F32))), F32.sqrt((0.5 + np : F32)))))

def nov() -> Vc:
  +e : Env = Env{0, 0, 0, 0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
  +l : Lf = Lf{0, 0.0, 0.0}
  Vc{none(), 0, 0, 0, 0, 0.0, 0.0, 0, 0, 0.0, 0.0, 0.0, 0, 0, e, e, Lp{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0}, l, l, Rg{0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0, 0, 0, 0, 0, 0, 0}}

def chan() -> Cn:
  Cn{0, 0, 8192, 8192, 16383, 16383, 65535, 0, 0, 0.0, 0.0, 2.0, 0.0}

def vlist.go(n: Nat, acc: List<&2, Vc>) -> List<&2, Vc>:
  match n:
    case 0n:
      List.reverse(&2, Vc, acc)
    case 1n+k:
      vlist.go(k, nov() <> acc)

def vlist(n: Nat) -> List<&2, Vc>:
  vlist.go(n, [])

def clist.go(n: Nat, acc: List<&2, Cn>) -> List<&2, Cn>:
  match n:
    case 0n:
      List.reverse(&2, Cn, acc)
    case 1n+k:
      clist.go(k, chan() <> acc)

def clist(n: Nat) -> List<&2, Cn>:
  clist.go(n, [])

def cget(+cs: List<&2, Cn>, +i: U32) -> Cn:
  Maybe.default(&2, Cn, List.get(&2, Cn, cs, U32.to_nat(i)), chan())

def cset(+cs: List<&2, Cn>, +i: U32, +c: Cn) -> List<&2, Cn>:
  match cs:
    case +x <> +t:
      Bool.pick(List<&2, Cn>, U32.is_eq(i, 0), c <> t, x <> cset(t, (i - 1 : U32), c))
    case []:
      []

def vset(+vs: List<&2, Vc>, +i: U32, +v: Vc) -> List<&2, Vc>:
  match vs:
    case +x <> +t:
      Bool.pick(List<&2, Vc>, U32.is_eq(i, 0), v <> t, x <> vset(t, (i - 1 : U32), v))
    case []:
      []

def on(+v: Vc, +ch: U32) -> Bool:
  Bool.and(U32.is_ne(vc.pi(v), none()), U32.is_eq(vc.ch(v), ch))

def syn.chan(+s: Syn, +ch: U32) -> Cn:
  cget(syn.cs(s), ch)

def syn.setchan(+s: Syn, +ch: U32, +c: Cn) -> Syn:
  syn.cs.set(s, cset(syn.cs(s), ch, c))

def pitched.go(vs: List<&2, Vc>, +ch: U32, +sh: F32, acc: List<&2, Vc>) -> List<&2, Vc>:
  match vs:
    case +v <> t:
      pitched.go(t, ch, sh, Bool.pick(Vc, on(v, ch), pitch(v, sh), v) <> acc)
    case []:
      List.reverse(&2, Vc, acc)

def pitched(vs: List<&2, Vc>, +ch: U32, +sh: F32) -> List<&2, Vc>:
  pitched.go(vs, ch, sh, [])

def applypitch(+s: Syn, +ch: U32) -> Syn:
  syn.vs.set(s, pitched(syn.vs(s), ch, shift(syn.chan(s, ch))))

def gained.go(vs: List<&2, Vc>, +ch: U32, +d: F32, acc: List<&2, Vc>) -> List<&2, Vc>:
  match vs:
    case +v <> t:
      gained.go(t, ch, d, Bool.pick(Vc, on(v, ch), vc.gdb.set(v, (vc.gdb(v) + d : F32)), v) <> acc)
    case []:
      List.reverse(&2, Vc, acc)

def gained(vs: List<&2, Vc>, +ch: U32, +d: F32) -> List<&2, Vc>:
  gained.go(vs, ch, d, [])

def setvolume(+s: Syn, +ch: U32, +vol: F32) -> Syn:
  +c = syn.chan(s, ch)
  +db = g2db(vol)
  Bool.pick(Syn, F32.is_eq(db, cn.gdb(c)), s, syn.setchan(syn.vs.set(s, gained(syn.vs(s), ch, (db - cn.gdb(c) : F32))), ch, cn.gdb.set(c, db)))

def panned.go(vs: List<&2, Vc>, +ch: U32, +pan: F32, acc: List<&2, Vc>) -> List<&2, Vc>:
  match vs:
    case +v <> t:
      panned.go(t, ch, pan, Bool.pick(Vc, on(v, ch), setpan(v, ((rg.pan(vc.rg(v)) + pan : F32) - 0.5 : F32)), v) <> acc)
    case []:
      List.reverse(&2, Vc, acc)

def panned(vs: List<&2, Vc>, +ch: U32, +pan: F32) -> List<&2, Vc>:
  panned.go(vs, ch, pan, [])

def setpanc(+s: Syn, +ch: U32, +pan: F32) -> Syn:
  +c = syn.chan(s, ch)
  syn.setchan(syn.vs.set(s, panned(syn.vs(s), ch, pan)), ch, cn.po.set(c, (pan - 0.5 : F32)))

def setrange(+s: Syn, +ch: U32, +r: F32) -> Syn:
  +c = syn.chan(s, ch)
  +s2 = syn.setchan(s, ch, cn.rng.set(c, r))
  Bool.pick(Syn, F32.is_eq(cn.rng(c), r), s, Bool.pick(Syn, U32.is_ne(cn.wheel(c), 8192), applypitch(s2, ch), s2))

def settuning(+s: Syn, +ch: U32, +t: F32) -> Syn:
  +c = syn.chan(s, ch)
  Bool.pick(Syn, F32.is_eq(cn.tun(c), t), s, applypitch(syn.setchan(s, ch, cn.tun.set(c, t)), ch))

def ended.go(vs: List<&2, Vc>, +ch: U32, +held: Bool, acc: List<&2, Vc>) -> List<&2, Vc>:
  match vs:
    case +v <> t:
      ended.go(t, ch, held, Bool.pick(Vc, Bool.and(Bool.and(on(v, ch), U32.is_lt(env.seg(vc.amp(v)), 6)), Bool.or(Bool.not(held), U32.is_ne(vc.held(v), 0))), vend(v), v) <> acc)
    case []:
      List.reverse(&2, Vc, acc)

def ended(vs: List<&2, Vc>, +ch: U32, +held: Bool) -> List<&2, Vc>:
  ended.go(vs, ch, held, [])

def setsustain(+s: Syn, +ch: U32, +x: U32) -> Syn:
  +c = syn.chan(s, ch)
  +s2 = syn.setchan(s, ch, cn.sus.set(c, x))
  Bool.pick(Syn, U32.is_eq(cn.sus(c), x), s, Bool.pick(Syn, U32.is_eq(x, 1), s2, syn.vs.set(s2, ended(syn.vs(s2), ch, True{}))))

def quicked.go(vs: List<&2, Vc>, +ch: U32, acc: List<&2, Vc>) -> List<&2, Vc>:
  match vs:
    case +v <> t:
      quicked.go(t, ch, Bool.pick(Vc, Bool.and(on(v, ch), Bool.or(U32.is_lt(env.seg(vc.amp(v)), 6), F32.is_ne(env.re(vc.amp(v)), 0.0))), vquick(v), v) <> acc)
    case []:
      List.reverse(&2, Vc, acc)

def quicked(vs: List<&2, Vc>, +ch: U32) -> List<&2, Vc>:
  quicked.go(vs, ch, [])

def kidx(ks: List<&2, U32>, +i: U32, +key: U32) -> U32:
  match ks:
    case +k <> t:
      Bool.pick(U32, U32.is_eq(k, key), i, kidx(t, (i + 1 : U32), key))
    case []:
      none()

def bk.ks(+b: G.Bank) -> List<&2, U32>:
  match b:
    case G.Bank{ps, +ks}:
      ks

def bk.ps(+b: G.Bank) -> T.Vec<G.Pr>:
  match b:
    case G.Bank{+ps, ks}:
      ps

def empty(+bk: G.Bank) -> Bool:
  match bk:
    case G.Bank{ps, +ks}:
      U32.is_eq(T.len(U32, ks), 0)

def pidx(+bk: G.Bank, +bank: U32, +num: U32) -> U32:
  kidx(bk.ks(bk), 0, ((bank << 16n) + num : U32))

def orelse(+a: U32, +b: U32) -> U32:
  Bool.pick(U32, U32.is_eq(a, none()), b, a)

def setprog(+bk: G.Bank, +s: Syn, +ch: U32, +num: U32) -> Syn:
  +c = syn.chan(s, ch)
  +cb = (cn.bank(c) .&. 32767 : U32)
  +d = orelse(orelse(orelse(pidx(bk, (128 .|. cb : U32), num), pidx(bk, 128, num)), pidx(bk, 128, 0)), pidx(bk, cb, num))
  +p0 = Bool.pick(U32, U32.is_eq(ch, 9), d, pidx(bk, cb, num))
  +p = orelse(p0, pidx(bk, 0, num))
  Bool.pick(Syn, U32.is_eq(p, none()), s, syn.setchan(s, ch, cn.pi.set(c, p)))

def volumed(+s: Syn, +ch: U32, +c: Cn) -> Syn:
  +a = (U32.to_f32(cn.mvol(c)) / 16383.0 : F32)
  +b = (U32.to_f32(cn.mexp(c)) / 16383.0 : F32)
  setvolume(syn.setchan(s, ch, c), ch, F32.pow((a * b : F32), 3.0))

def dataed(+s: Syn, +ch: U32, +c: Cn, +ctl: U32, +val: U32) -> Syn:
  +s1 = syn.setchan(s, ch, c)
  +rpn = cn.rpn(c)
  +d = cn.data(c)
  +t = cn.tun(c)
  Bool.pick(Syn, U32.is_eq(rpn, 0), setrange(s1, ch, (U32.to_f32((d >> 7n : U32)) + (0.01 * U32.to_f32((d .&. 127 : U32)) : F32) : F32)),
    Bool.pick(Syn, U32.is_eq(rpn, 1), settuning(s1, ch, (F32.trunc(t) + ((U32.to_f32(d) - 8192.0 : F32) / 8192.0 : F32) : F32)),
      Bool.pick(Syn, Bool.and(U32.is_eq(rpn, 2), U32.is_eq(ctl, 6)), settuning(s1, ch, ((U32.to_f32(val) - 64.0 : F32) + (t - F32.trunc(t) : F32) : F32)), s1)))

def lo7(+x: U32, +v: U32) -> U32:
  ((x .&. 16256) .|. v : U32)

def hi7(+x: U32, +v: U32) -> U32:
  ((x .&. 127) .|. (v << 7n) : U32)

def resetc(+s: Syn, +ch: U32, +c: Cn) -> Syn:
  +c2 = cn.data.set(cn.rpn.set(cn.bank.set(cn.mpan.set(cn.mexp.set(cn.mvol.set(c, 16383), 16383), 8192), 0), 65535), 0)
  settuning(setrange(setpanc(setvolume(syn.setchan(s, ch, c2), ch, 1.0), ch, 0.5), ch, 2.0), ch, 0.0)

def ctl.c16(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      resetc(s, ch, c)
    case False{}:
      s

def ctl.c15(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      syn.vs.set(s, ended(syn.vs(s), ch, False{}))
    case False{}:
      ctl.c16(U32.is_eq(ctl, 121), s, ch, ctl, val, c, rp, bk)

def ctl.c14(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      syn.vs.set(s, quicked(syn.vs(s), ch))
    case False{}:
      ctl.c15(U32.is_eq(ctl, 123), s, ch, ctl, val, c, rp, bk)

def ctl.c13(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      setsustain(s, ch, Bool.pick(U32, U32.is_ge(val, 64), 1, 0))
    case False{}:
      ctl.c14(U32.is_eq(ctl, 120), s, ch, ctl, val, c, rp, bk)

def ctl.c12(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      syn.setchan(s, ch, cn.rpn.set(c, 65535))
    case False{}:
      ctl.c13(U32.is_eq(ctl, 64), s, ch, ctl, val, c, rp, bk)

def ctl.c11(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      syn.setchan(s, ch, cn.rpn.set(c, ((rp .&. 16256) .|. val : U32)))
    case False{}:
      ctl.c12(Bool.or(U32.is_eq(ctl, 98), U32.is_eq(ctl, 99)), s, ch, ctl, val, c, rp, bk)

def ctl.c10(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      syn.setchan(s, ch, cn.rpn.set(c, ((rp .&. 127) .|. (val << 7n) : U32)))
    case False{}:
      ctl.c11(U32.is_eq(ctl, 100), s, ch, ctl, val, c, rp, bk)

def ctl.c9(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      syn.setchan(s, ch, cn.bank.set(c, (Bool.pick(U32, U32.is_ne((bk .&. 32768 : U32), 0), ((bk .&. 127) << 7n : U32), 0) .|. val : U32)))
    case False{}:
      ctl.c10(U32.is_eq(ctl, 101), s, ch, ctl, val, c, rp, bk)

def ctl.c8(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      syn.setchan(s, ch, cn.bank.set(c, (32768 .|. val : U32)))
    case False{}:
      ctl.c9(U32.is_eq(ctl, 32), s, ch, ctl, val, c, rp, bk)

def ctl.c7(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      dataed(s, ch, cn.data.set(c, lo7(cn.data(c), val)), ctl, val)
    case False{}:
      ctl.c8(U32.is_eq(ctl, 0), s, ch, ctl, val, c, rp, bk)

def ctl.c6(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      dataed(s, ch, cn.data.set(c, hi7(cn.data(c), val)), ctl, val)
    case False{}:
      ctl.c7(U32.is_eq(ctl, 38), s, ch, ctl, val, c, rp, bk)

def ctl.c5(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      setpanc(syn.setchan(s, ch, cn.mpan.set(c, lo7(cn.mpan(c), val))), ch, (U32.to_f32(lo7(cn.mpan(c), val)) / 16383.0 : F32))
    case False{}:
      ctl.c6(U32.is_eq(ctl, 6), s, ch, ctl, val, c, rp, bk)

def ctl.c4(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      setpanc(syn.setchan(s, ch, cn.mpan.set(c, hi7(cn.mpan(c), val))), ch, (U32.to_f32(hi7(cn.mpan(c), val)) / 16383.0 : F32))
    case False{}:
      ctl.c5(U32.is_eq(ctl, 42), s, ch, ctl, val, c, rp, bk)

def ctl.c3(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      volumed(s, ch, cn.mexp.set(c, lo7(cn.mexp(c), val)))
    case False{}:
      ctl.c4(U32.is_eq(ctl, 10), s, ch, ctl, val, c, rp, bk)

def ctl.c2(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      volumed(s, ch, cn.mexp.set(c, hi7(cn.mexp(c), val)))
    case False{}:
      ctl.c3(U32.is_eq(ctl, 43), s, ch, ctl, val, c, rp, bk)

def ctl.c1(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      volumed(s, ch, cn.mvol.set(c, lo7(cn.mvol(c), val)))
    case False{}:
      ctl.c2(U32.is_eq(ctl, 11), s, ch, ctl, val, c, rp, bk)

def ctl.c0(hit: Bool, +s: Syn, +ch: U32, +ctl: U32, +val: U32, +c: Cn, +rp: U32, +bk: U32) -> Syn:
  match hit:
    case True{}:
      volumed(s, ch, cn.mvol.set(c, hi7(cn.mvol(c), val)))
    case False{}:
      ctl.c1(U32.is_eq(ctl, 39), s, ch, ctl, val, c, rp, bk)

def control(+s: Syn, +ch: U32, +ctl: U32, +val: U32) -> Syn:
  +c = syn.chan(s, ch)
  +rp = Bool.pick(U32, U32.is_eq(cn.rpn(c), 65535), 0, cn.rpn(c))
  +bk = cn.bank(c)
  ctl.c0(U32.is_eq(ctl, 7), s, ch, ctl, val, c, rp, bk)

type Tr is Data:
  Tr{a: U32, b: U32, c: U32}

def offscan.next?(vs: List<&2, Vc>, +i: U32, +ch: U32, +key: U32, +r: Tr) -> Tr:
  match r:
    case Tr{+a, +b, +c}:
      offscan(vs, i, ch, key, a, b, c)

def offscan?(vs: List<&2, Vc>, +i: U32, +ch: U32, +key: U32, +first: U32, +last: U32, +fp: U32) -> Tr:
  match vs:
    case +v <> t:
      +ok = Bool.and(Bool.and(on(v, ch), U32.is_eq(vc.key(v), key)), Bool.and(U32.is_lt(env.seg(vc.amp(v)), 6), U32.is_eq(vc.held(v), 0)))
      +p = vc.play(v)
      +nb = Bool.pick(Tr, Bool.and(ok, Bool.or(U32.is_eq(first, none()), U32.is_lt(p, fp))), Tr{i, i, p},
        Bool.pick(Tr, Bool.and(ok, U32.is_eq(p, fp)), Tr{first, i, fp}, Tr{first, last, fp}))
      offscan.next(t, (i + 1 : U32), ch, key, nb)
    case []:
      Tr{first, last, fp}

def offed.go(vs: List<&2, Vc>, +i: U32, +ch: U32, +key: U32, +first: U32, +last: U32, +fp: U32, +sus: U32, acc: List<&2, Vc>) -> List<&2, Vc>:
  match vs:
    case +v <> t:
      +inr = Bool.and(U32.is_ge(i, first), U32.is_le(i, last))
      +edge = Bool.or(U32.is_eq(i, first), U32.is_eq(i, last))
      +bad = Bool.or(Bool.or(U32.is_ne(vc.play(v), fp), U32.is_eq(vc.pi(v), none())), Bool.or(Bool.or(U32.is_ne(vc.ch(v), ch), U32.is_ne(vc.key(v), key)), U32.is_ge(env.seg(vc.amp(v)), 6)))
      +hit = Bool.and(inr, Bool.or(edge, Bool.not(bad)))
      offed.go(t, (i + 1 : U32), ch, key, first, last, fp, sus, Bool.pick(Vc, hit, Bool.pick(Vc, U32.is_ne(sus, 0), vc.held.set(v, 1), vend(v)), v) <> acc)
    case []:
      List.reverse(&2, Vc, acc)

def offed(vs: List<&2, Vc>, +i: U32, +ch: U32, +key: U32, +first: U32, +last: U32, +fp: U32, +sus: U32) -> List<&2, Vc>:
  offed.go(vs, i, ch, key, first, last, fp, sus, [])

def noteoff.do(+s: Syn, +ch: U32, +key: U32, +first: U32, +last: U32, +fp: U32) -> Syn:
  Bool.pick(Syn, U32.is_eq(first, none()), s, syn.vs.set(s, offed(syn.vs(s), 0, ch, key, first, last, fp, cn.sus(syn.chan(s, ch)))))

def noteoff.go(+s: Syn, +ch: U32, +key: U32, +r: Tr) -> Syn:
  match r:
    case Tr{+first, +last, +fp}:
      noteoff.do(s, ch, key, first, last, fp)

def noteoff(+s: Syn, +ch: U32, +key: U32) -> Syn:
  noteoff.go(s, ch, key, offscan(syn.vs(s), 0, ch, key, none(), none(), 0))

def grouped.go(vs: List<&2, Vc>, +pi: U32, +grp: U32, acc: List<&2, Vc>) -> List<&2, Vc>:
  match vs:
    case +v <> t:
      grouped.go(t, pi, grp, Bool.pick(Vc, Bool.and(U32.is_eq(vc.pi(v), pi), U32.is_eq(rg.group(vc.rg(v)), grp)), vquick(v), v) <> acc)
    case []:
      List.reverse(&2, Vc, acc)

def grouped(vs: List<&2, Vc>, +pi: U32, +grp: U32) -> List<&2, Vc>:
  grouped.go(vs, pi, grp, [])

def free(vs: List<&2, Vc>, +i: U32) -> U32:
  match vs:
    case +v <> t:
      Bool.pick(U32, U32.is_eq(vc.pi(v), none()), i, free(t, (i + 1 : U32)))
    case []:
      none()

def steal(vs: List<&2, Vc>, +i: U32, +best: U32, +at: U32) -> U32:
  match vs:
    case +v <> t:
      +e = vc.amp(v)
      +done = (env.rel(e) - env.un(e) : U32)
      +take = Bool.and(U32.is_eq(env.seg(e), 6), Bool.or(U32.is_eq(at, none()), G.slt(best, done)))
      steal(t, (i + 1 : U32), Bool.pick(U32, take, done, best), Bool.pick(U32, take, i, at))
    case []:
      at

def voice(+r: T.Vec<U32>, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> Vc:
  +rg : Rg = Rg{G.get(r, 0), G.get(r, 6), G.get(r, 8), G.get(r, 11), G.get(r, 12), G.get(r, 13), G.get(r, 14), G.get(r, 1), G.gf(r, 16), G.get(r, 34), G.get(r, 37), G.get(r, 36), G.get(r, 41), G.get(r, 44), G.get(r, 35), G.get(r, 38)}
  +gdb = (((0.0 - G.gf(r, 15) : F32) - g2db((1.0 / vel : F32)) : F32) + cn.gdb(c) : F32)
  +loop = Bool.and(U32.is_ne(G.get(r, 0), 0), U32.is_lt(G.get(r, 9), G.get(r, 10)))
  +fc = Bool.pick(F32, G.slt(G.get(r, 34), 13501), (c2hz(G.sf(G.get(r, 34))) / rate() : F32), 1.0)
  +qi = (1.0 / F32.pow(10.0, ((G.sf(G.get(r, 33)) / 10.0 : F32) / 20.0 : F32)) : F32)
  +lp = lp.at(Lp{qi, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0}, fc)
  +v0 : Vc = Vc{pi, key, ch, 0, idx, 0.0, 0.0, G.get(r, 7), 0, gdb, 0.0, 0.0, Bool.pick(U32, loop, G.get(r, 9), 0), Bool.pick(U32, loop, G.get(r, 10), 0), env.setup(r, 17, key, mv, 1), env.setup(r, 25, key, mv, 0), lp, lf.setup(G.gf(r, 39), G.get(r, 40)), lf.setup(G.gf(r, 42), G.get(r, 43)), rg}
  setpan(pitch(v0, shift(c)), (rg.pan(rg) + cn.po(c) : F32))

def region.put(+vs: List<&2, Vc>, +at: U32, +r: T.Vec<U32>, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> List<&2, Vc>:
  Bool.pick(List<&2, Vc>, U32.is_eq(at, none()), vs, vset(vs, at, voice(r, c, pi, ch, key, mv, vel, idx)))

def region.free(full: Bool, +f: U32, +vs: List<&2, Vc>, +r: T.Vec<U32>, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> List<&2, Vc>:
  match full:
    case True{}:
      region.put(vs, steal(vs, 0, 0, none()), r, c, pi, ch, key, mv, vel, idx)
    case False{}:
      region.put(vs, f, r, c, pi, ch, key, mv, vel, idx)

def region.at(+vs: List<&2, Vc>, +r: T.Vec<U32>, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> List<&2, Vc>:
  +f = free(vs, 0)
  region.free(U32.is_eq(f, none()), f, vs, r, c, pi, ch, key, mv, vel, idx)

def region.grp(grp: Bool, +vs: List<&2, Vc>, +r: T.Vec<U32>, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> List<&2, Vc>:
  match grp:
    case True{}:
      region.at(grouped(vs, pi, G.get(r, 6)), r, c, pi, ch, key, mv, vel, idx)
    case False{}:
      region.at(vs, r, c, pi, ch, key, mv, vel, idx)

def region.go(out: Bool, +vs: List<&2, Vc>, +r: T.Vec<U32>, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> List<&2, Vc>:
  match out:
    case True{}:
      vs
    case False{}:
      region.grp(U32.is_ne(G.get(r, 6), 0), vs, r, c, pi, ch, key, mv, vel, idx)

def region(+vs: List<&2, Vc>, +r: T.Vec<U32>, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> List<&2, Vc>:
  region.go(Bool.or(Bool.or(U32.is_lt(key, G.get(r, 2)), U32.is_gt(key, G.get(r, 3))), Bool.or(U32.is_lt(mv, G.get(r, 4)), U32.is_gt(mv, G.get(r, 5)))), vs, r, c, pi, ch, key, mv, vel, idx)

def regions(rs: List<&2, T.Vec<U32>>, +vs: List<&2, Vc>, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> List<&2, Vc>:
  match rs:
    case +r <> t:
      regions(t, region(vs, r, c, pi, ch, key, mv, vel, idx), c, pi, ch, key, mv, vel, idx)
    case []:
      vs

def pr.rs(+p: G.Pr) -> List<&2, T.Vec<U32>>:
  match p:
    case G.Pr{b, n, +rs}:
      rs

def noteon.go(skip: Bool, +bk: G.Bank, +s: Syn, +s1: Syn, +c: Cn, +pi: U32, +ch: U32, +key: U32, +mv: U32, +vel: F32, +idx: U32) -> Syn:
  match skip:
    case True{}:
      s
    case False{}:
      syn.vs.set(s1, regions(pr.rs(T.get(G.Pr, bk.ps(bk), pi, G.Pr{0, 0, []})), syn.vs(s1), c, pi, ch, key, mv, vel, idx))

def noteon(+bk: G.Bank, +s: Syn, +ch: U32, +key: U32, +velb: U32) -> Syn:
  +c = syn.chan(s, ch)
  +pi = cn.pi(c)
  +vel = (U32.to_f32(velb) / 127.0 : F32)
  +mv = toi((vel * 127.0 : F32))
  +idx = syn.play(s)
  +s1 = syn.play.set(s, (idx + 1 : U32))
  noteon.go(U32.is_ge(pi, T.size(G.Pr, bk.ps(bk))), bk, s, s1, c, pi, ch, key, mv, vel, idx)

def wheel(+s: Syn, +ch: U32, +w: U32) -> Syn:
  +c = syn.chan(s, ch)
  Bool.pick(Syn, U32.is_eq(cn.wheel(c), w), s, applypitch(syn.setchan(s, ch, cn.wheel.set(c, w)), ch))

def ev.go(off: Bool, on: Bool, cc: Bool, pc: Bool, pw: Bool, +bk: G.Bank, +s: Syn, +ch: U32, +a: U32, +b: U32) -> Syn:
  match off on cc pc pw:
    case True{} _ _ _ _:
      noteoff(s, ch, a)
    case False{} True{} _ _ _:
      noteon(bk, s, ch, a, b)
    case False{} False{} True{} _ _:
      control(s, ch, a, b)
    case False{} False{} False{} True{} _:
      setprog(bk, s, ch, a)
    case False{} False{} False{} False{} True{}:
      wheel(s, ch, ((b << 7n) .|. a : U32))
    case _ _ _ _ _:
      s

def ev(+bk: G.Bank, +s: Syn, +x: U32) -> Syn:
  +st = (x >> 16n : U32)
  +hi = (st .&. 240 : U32)
  +ch = (st .&. 15 : U32)
  +a = ((x >> 8n) .&. 255 : U32)
  +b = (x .&. 255 : U32)
  ev.go(Bool.or(U32.is_eq(hi, 128), Bool.and(U32.is_eq(hi, 144), U32.is_eq(b, 0))), U32.is_eq(hi, 144), U32.is_eq(hi, 176), U32.is_eq(hi, 192), U32.is_eq(hi, 224), bk, s, ch, a, b)

def quickall.go(vs: List<&2, Vc>, acc: List<&2, Vc>) -> List<&2, Vc>:
  match vs:
    case +v <> t:
      quickall.go(t, Bool.pick(Vc, Bool.and(U32.is_ne(vc.pi(v), none()), Bool.or(U32.is_lt(env.seg(vc.amp(v)), 6), F32.is_ne(env.re(vc.amp(v)), 0.0))), vquick(v), v) <> acc)
    case []:
      List.reverse(&2, Vc, acc)

def quickall(vs: List<&2, Vc>) -> List<&2, Vc>:
  quickall.go(vs, [])

def restart(+bk: G.Bank, +s: Syn) -> Syn:
  match s:
    case Syn{+vs, cs, +play, +vol}:
      setprog(bk, Syn{quickall(vs), clist(16n), play, vol}, 9, 0)

def new() -> Syn:
  Syn{vlist(32n), clist(16n), 0, 64}

type Q is Data:
  Q{gl: F32, gr: F32, a0: F32, a1: F32, b1: F32, b2: F32, on: U32, ls: U32, le: U32, end: U32, whole: U32, step: U32}

type Sm is Type:
  Sm{smp: Array<F32>, pos: U32, frac: U32, z1: F32, z2: F32, out: List<&2, F32>}

def q.end(+q: Q) -> U32:
  match q:
    case Q{gl, gr, a0, a1, b1, b2, on, ls, le, +end, whole, step}:
      end

def q.next(+q: Q, +pos: U32) -> U32:
  match q:
    case Q{gl, gr, a0, a1, b1, b2, on, +ls, +le, end, whole, step}:
      Bool.pick(U32, Bool.and(U32.is_ge(pos, le), U32.is_lt(ls, le)), ls, (pos + 1 : U32))

def sm.cons(+a: F32, +b: F32, r: Sm) -> Sm:
  match r:
    case Sm{smp, +pos, +frac, +z1, +z2, out}:
      Sm{smp, pos, frac, z1, z2, a <> b <> out}

def samp.go?(go: Bool, smp: Array<F32>, +pos: U32, +frac: U32, +z1: F32, +z2: F32, +q: Q, +a: F32, +b: F32, t: List<&2, F32>) -> Sm:
  match go:
    case False{}:
      Sm{smp, pos, frac, z1, z2, a <> b <> t}
    case True{}:
      samp.read(Array.get(F32, smp, pos), pos, frac, z1, z2, q, a, b, t)

def samp?(smp: Array<F32>, +pos: U32, +frac: U32, +z1: F32, +z2: F32, +q: Q, acc: List<&2, F32>) -> Sm:
  match acc:
    case +a <> +b <> t:
      samp.go(U32.is_lt(pos, q.end(q)), smp, pos, frac, z1, z2, q, a, b, t)
    case _:
      Sm{smp, pos, frac, z1, z2, []}

def samp.mix?(r: Array<F32> & F32, +s0: F32, +pos: U32, +frac: U32, +z1: F32, +z2: F32, +q: Q, +a: F32, +b: F32, t: List<&2, F32>) -> Sm:
  (smp, +s1) = r
  match q:
    case Q{+gl, +gr, +a0, +a1, +b1, +b2, +on, +ls, +le, +end, +whole, +step}:
      +al = (U32.to_f32(frac) / 65536.0 : F32)
      +v0 = ((s0 * (1.0 - al : F32) : F32) + (s1 * al : F32) : F32)
      +lpon = U32.is_eq(on, 1)
      +o = ((v0 * a0 : F32) + z1 : F32)
      +nz1 = Bool.pick(F32, lpon, (((v0 * a1 : F32) + z2 : F32) - (b1 * o : F32) : F32), z1)
      +nz2 = Bool.pick(F32, lpon, ((v0 * a0 : F32) - (b2 * o : F32) : F32), z2)
      +val = Bool.pick(F32, lpon, o, v0)
      +f1 = (frac + step : U32)
      +p1 = (pos + whole + (f1 >> 16n) : U32)
      +p2 = Bool.pick(U32, Bool.and(U32.is_ge(p1, (le + 1 : U32)), U32.is_lt(ls, le)), (p1 - ((le - ls : U32) + 1 : U32) : U32), p1)
      sm.cons((a + (val * gl : F32) : F32), (b + (val * gr : F32) : F32), samp(smp, p2, (f1 .&. 65535 : U32), nz1, nz2, Q{gl, gr, a0, a1, b1, b2, on, ls, le, end, whole, step}, t))

def samp.read?(r: Array<F32> & F32, +pos: U32, +frac: U32, +z1: F32, +z2: F32, +q: Q, +a: F32, +b: F32, t: List<&2, F32>) -> Sm:
  (smp, +s0) = r
  samp.mix(Array.get(F32, smp, q.next(q, pos)), s0, pos, frac, z1, z2, q, a, b, t)

type Vo is Type:
  Vo{smp: Array<F32>, v: Vc, out: List<&2, F32>}

def vo.cat(+xs: List<&2, F32>, r: Vo) -> Vo:
  match r:
    case Vo{smp, +v, out}:
      Vo{smp, v, List.append(&2, F32, xs, out)}

def nz(+x: U32) -> Bool:
  U32.is_ne(x, 0)

def vr.next?(dead: Bool, +v: Vc, +n: U32, smp: Array<F32>, +out: List<&2, F32>, rest: List<&2, F32>) -> Vo:
  match dead:
    case True{}:
      Vo{smp, vc.pi.set(v, none()), List.append(&2, F32, out, rest)}
    case False{}:
      vo.cat(out, vr(v, n, smp, rest))

def vr.after?(+v: Vc, +n: U32, +bs: U32, rest: List<&2, F32>, r: Sm) -> Vo:
  match r:
    case Sm{smp, +pos, +frac, +z1, +z2, +out}:
      +v2 = vc.lp.set(vc.frac.set(vc.pos.set(v, pos), frac), lp.z2.set(lp.z1.set(vc.lp(v), z1), z2))
      +dead = Bool.or(U32.is_ge(pos, rg.end(vc.rg(v))), U32.is_eq(env.seg(vc.amp(v)), 7))
      vr.next(dead, v2, (n - bs : U32), smp, out, rest)

def vr.go?(stop: Bool, +v: Vc, +n: U32, smp: Array<F32>, +acc: List<&2, F32>) -> Vo:
  match stop:
    case True{}:
      Vo{smp, v, acc}
    case False{}:
      +bs = U32.min(n, 64)
      +r = vc.rg(v)
      +ml = vc.ml(v)
      +vl = vc.vl(v)
      +md = vc.mod(v)
      +am = vc.amp(v)
      +upmod = Bool.or(nz(rg.mep(r)), nz(rg.mef(r)))
      +upml = Bool.and(F32.is_ne(lf.dt(ml), 0.0), Bool.or(Bool.or(nz(rg.mlp(r)), nz(rg.mlf(r))), nz(rg.mlv(r))))
      +upvl = Bool.and(F32.is_ne(lf.dt(vl), 0.0), nz(rg.vlp(r)))
      +dynlp = Bool.or(nz(rg.mlf(r)), nz(rg.mef(r)))
      +dynpitch = Bool.or(Bool.or(nz(rg.mlp(r)), nz(rg.mep(r))), nz(rg.vlp(r)))
      +dyngain = nz(rg.mlv(r))
      +fres = ((G.sf(rg.fc(r)) + (lf.lv(ml) * G.sf(rg.mlf(r)) : F32) : F32) + (env.lv(md) * G.sf(rg.mef(r)) : F32) : F32)
      +lp = Bool.pick(Lp, dynlp, lp.at(vc.lp(v), Bool.pick(F32, F32.is_le(fres, 13500.0), (c2hz(fres) / rate() : F32), 1.0)), vc.lp(v))
      +pin = Bool.pick(F32, dynpitch, (vc.pin(v) + (((lf.lv(ml) * G.sf(rg.mlp(r)) : F32) + (lf.lv(vl) * G.sf(rg.vlp(r)) : F32) : F32) + (env.lv(md) * G.sf(rg.mep(r)) : F32) : F32) : F32), vc.pin(v))
      +ratio = (G.tc2s(pin) * vc.pout(v) : F32)
      +gain = G.db2g(Bool.pick(F32, dyngain, (vc.gdb(v) + (lf.lv(ml) * (G.sf(rg.mlv(r)) * 0.1 : F32) : F32) : F32), vc.gdb(v)))
      +gm = (gain * env.lv(am) : F32)
      +v1 = vc.vl.set(vc.ml.set(vc.mod.set(vc.amp.set(vc.lp.set(v, lp), env.proc(am, bs)), Bool.pick(Env, upmod, env.proc(md, bs), md)), Bool.pick(Lf, upml, lf.proc(ml, bs), ml)), Bool.pick(Lf, upvl, lf.proc(vl, bs), vl))
      +whole = toi(ratio)
      +step = toi(((ratio - U32.to_f32(whole) : F32) * 65536.0 : F32))
      +q : Q = Q{(gm * vc.pl(v) : F32), (gm * vc.pr(v) : F32), lp.a0(lp), lp.a1(lp), lp.b1(lp), lp.b2(lp), lp.on(lp), vc.ls(v), vc.le(v), rg.end(r), whole, step}
      +k = U32.to_nat((bs * 2 : U32))
      vr.after(v1, n, bs, List.drop(&2, F32, acc, k), samp(smp, vc.pos(v), vc.frac(v), lp.z1(lp), lp.z2(lp), q, List.take(&2, F32, acc, k)))

def vr?(+v: Vc, +n: U32, smp: Array<F32>, acc: List<&2, F32>) -> Vo:
  vr.go(U32.is_eq(n, 0), v, n, smp, acc)

type Rv is Type:
  Rv{smp: Array<F32>, vs: List<&2, Vc>, acc: List<&2, F32>}

def rv.cons(+v: Vc, r: Rv) -> Rv:
  match r:
    case Rv{smp, +vs, acc}:
      Rv{smp, v <> vs, acc}

def voices.on?(+v: Vc, t: List<&2, Vc>, +n: U32, r: Vo) -> Rv:
  match r:
    case Vo{smp, +v2, acc}:
      rv.cons(v2, voices(t, n, smp, acc))

def voices.pick?(act: Bool, +v: Vc, t: List<&2, Vc>, +n: U32, smp: Array<F32>, acc: List<&2, F32>) -> Rv:
  match act:
    case True{}:
      voices.on(v, t, n, vr(v, n, smp, acc))
    case False{}:
      rv.cons(v, voices(t, n, smp, acc))

def voices?(vs: List<&2, Vc>, +n: U32, smp: Array<F32>, acc: List<&2, F32>) -> Rv:
  match vs:
    case +v <> t:
      voices.pick(U32.is_ne(vc.pi(v), none()), v, t, n, smp, acc)
    case []:
      Rv{smp, [], acc}

def toshort(+x: F32) -> U32:
  +t = (G.fs((x * 32767.5 : F32)) .&. 65535 : U32)
  Bool.pick(U32, F32.is_lt(x, (0.0 - 1.00004566 : F32)), 4294934528, Bool.pick(U32, F32.is_gt(x, 1.00001514), 32767, Bool.pick(U32, U32.is_ge(t, 32768), (t - 65536 : U32), t)))

def shorts.go(xs: List<&2, F32>, +mv: F32, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      shorts.go(t, mv, toshort((x * mv : F32)) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def shorts(xs: List<&2, F32>, +mv: F32) -> List<&2, U32>:
  shorts.go(xs, mv, [])

def zeros.go(n: Nat, acc: List<&2, F32>) -> List<&2, F32>:
  match n:
    case 0n:
      List.reverse(&2, F32, acc)
    case 1n+k:
      zeros.go(k, 0.0 <> acc)

def zeros(n: Nat) -> List<&2, F32>:
  zeros.go(n, [])

def rendered(+s: Syn, r: Rv) -> (Array<F32> & Syn) & List<&2, U32>:
  match r:
    case Rv{smp, +vs, +acc}:
      ((smp, syn.vs.set(s, vs)), shorts(acc, (U32.to_f32(syn.vol(s)) / 127.0 : F32)))

def render(+s: Syn, smp: Array<F32>, +k: U32) -> (Array<F32> & Syn) & List<&2, U32>:
  rendered(s, voices(syn.vs(s), (k * 2 : U32), smp, zeros(U32.to_nat((k * 4 : U32)))))
