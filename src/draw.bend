import Base
import ./tab.bend as T
import ./fixed.bend as F
import ./world.bend as R
import ./render.bend as V
import ./screen.bend as S
import ./mem.bend as M

type VS is Data:
  VS{scale: U32, idx: U32}

type PSp is Data:
  PSp{spr: U32, frm: U32, sx: U32, sy: U32, cm: U32}

def fuzzpaint(n: Nat, fr: V.Frame, +x: U32, +y: U32) -> V.Frame:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, M.fuzzpos()), r1 => +pos =>
        M.let(V.Frame, M.rd(r1, (M.fuzz() + pos : U32)), r2 => +d =>
          M.let(V.Frame, M.rd(fb, S.at(x, (y + d : U32))), f1 => +src =>
            M.let(V.Frame, M.rd(r2, (1536 + src : U32)), r3 => +c =>
              fuzzpaint(p, V.Frame{M.wr(f1, S.at(x, y), c), M.wr(r3, M.fuzzpos(), Bool.pick(U32, U32.is_eq(pos, 49), 0, (pos + 1 : U32))), ram, sd}, x, (y + 1 : U32))))))
    case _ f:
      f

def tpaint(n: Nat, fr: V.Frame, +x: U32, +y: U32, +frac: U32, +step: U32, +col: U32, +cm: U32, +tb: U32) -> V.Frame:
  match n fr:
    case 1n+p V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, (col + ((frac >> 16n) .&. 127) : U32)), rom1 => +t =>
        M.let(V.Frame, M.rd(rom1, (cm + Bool.pick(U32, U32.is_eq((t .&. 240 : U32), 112), (tb + (t .&. 15) : U32), t) : U32)), rom2 => c =>
          tpaint(p, V.Frame{S.put(fb, x, y, c), rom2, ram, sd}, x, (y + 1 : U32), (frac + step : U32), step, col, cm, tb)))
    case _ f:
      f

def mcol.tr(plain: Bool, fr: V.Frame, +x: U32, +src: U32, +yl: U32, +yh: U32, +mid: U32, +iscale: U32, +cm: U32) -> V.Frame:
  match plain:
    case True{}:
      V.paint(V.count(yl, yh), fr, x, yl, (mid + (yl - M.cy()) * iscale : U32), iscale, src, cm)
    case False{}:
      tpaint(V.count(yl, yh), fr, x, yl, (mid + (yl - M.cy()) * iscale : U32), iscale, src, (cm .&. 268435455 : U32), (128 - 32 * ((cm >> 28n) .&. 3) : U32))

def mcol.pick(fz: Bool, fr: V.Frame, +x: U32, +src: U32, +yl: U32, +yh: U32, +mid: U32, +iscale: U32, +cm: U32) -> V.Frame:
  match fz:
    case True{}:
      fuzzpaint(V.count(yl, yh), fr, x, yl)
    case False{}:
      mcol.tr(U32.is_eq((cm >> 28n : U32), 0), fr, x, src, yl, yh, mid, iscale, cm)

def mcol(fr: V.Frame, +x: U32, +src: U32, +yl: U32, +yh: U32, +mid: U32, +iscale: U32, +cm: U32) -> V.Frame:
  +fz = U32.is_eq(cm, M.none())
  +fyl = Bool.pick(U32, Bool.and(fz, U32.is_eq(yl, 0)), 1, yl)
  +fyh = Bool.pick(U32, Bool.and(fz, U32.is_eq(yh, (M.vh() - 1 : U32))), (M.vh() - 2 : U32), yh)
  mcol.pick(fz, fr, x, src, fyl, fyh, mid, iscale, cm)

def posts(n: Nat, go: Bool, fr: V.Frame, +x: U32, +col: U32, +td: U32, +top: U32, +scale: U32, +mid: U32, +iscale: U32, +cm: U32, +fc: U32, +cc: U32) -> V.Frame:
  match n go fr:
    case 1n+p True{} V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, (col + 1 : U32)), r1 => +len =>
        M.let(V.Frame, M.rd(r1, (col + len + 4 : U32)), r2 => +td2 =>
          +ts = (top + scale * td : U32)
          +bs = (ts + scale * len : U32)
          +yl = F.max(F.sar((ts + 65535 : U32), 16n), (cc + 1 : U32))
          +yh = F.min(F.sar((bs - 1 : U32), 16n), (fc - 1 : U32))
          posts(p, Bool.not(U32.is_eq(td2, 255)), mcol(V.Frame{fb, r2, ram, sd}, x, (col + 3 : U32), yl, yh, (mid - (td << 16n) : U32), iscale, cm), x, (col + len + 4 : U32), td2, top, scale, mid, iscale, cm, fc, cc)))
    case _ _ f:
      f

def masked.column(fr: V.Frame, +x: U32, +col: U32, +top: U32, +scale: U32, +mid: U32, +iscale: U32, +cm: U32, +fclip: U32, +cclip: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, col), r1 => +td =>
        M.let(V.Frame, M.rd(ram, (fclip + x : U32)), a1 => +fc =>
          M.let(V.Frame, M.rd(a1, (cclip + x : U32)), a2 => +cc =>
            posts(128n, Bool.not(U32.is_eq(td, 255)), V.Frame{fb, r1, a2, sd}, x, col, td, top, scale, mid, iscale, cm, fc, cc))))

def seg.col(go: Bool, fr: V.Frame, +x: U32, +post: U32, +top: U32, +scale: U32, +mid: U32, +cm: U32, +fclip: U32, +cclip: U32) -> V.Frame:
  match go:
    case True{}:
      masked.column(fr, x, post, top, scale, mid, (4294967295 / scale : U32), cm, fclip, cclip)
    case False{}:
      fr

def seg.x(fr: V.Frame, +t: M.Info, +x: U32, +mc: U32, +scale: U32, +mid: U32, +light: U32, +fclip: U32, +cclip: U32) -> V.Frame:
  match fr t:
    case V.Frame{fb, rom, ram, sd} M.Info{m, h, b, ps}:
      M.let(V.Frame, M.rd(ram, (mc + x : U32)), a1 => +tc =>
        M.let(V.Frame, M.rd(rom, (ps + (tc .&. m) : U32)), r1 => +post =>
          +go = Bool.and(Bool.not(U32.is_eq(tc, 32767)), Bool.and(Bool.not(U32.is_eq(ps, M.none())), Bool.not(U32.is_eq(post, M.none()))))
          seg.col(go, V.Frame{fb, r1, M.wr(a1, (mc + x : U32), 32767), sd}, x, post, ((M.cy() << 16n) - F.mul(mid, scale) : U32), scale, mid, (V.lightmap(light, scale) * 256 : U32), fclip, cclip)))

def seg.loop(n: Nat, fr: V.Frame, +t: M.Info, +x: U32, +mc: U32, +scale: U32, +step: U32, +mid: U32, +light: U32, +fclip: U32, +cclip: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      seg.loop(p, seg.x(fr, t, x, mc, scale, mid, light, fclip, cclip), t, (x + 1 : U32), mc, (scale + step : U32), step, mid, light, fclip, cclip)

def seg.mid(+d: R.RSide) -> U32:
  match d:
    case R.RSide{xo, yo, t, b, m, s}:
      m

def seg.rowoff(+d: R.RSide) -> U32:
  match d:
    case R.RSide{xo, yo, t, b, m, s}:
      yo

def seg.range(fr: V.Frame, +w: R.World, +v: V.View, +r1: U32, +r2: U32, +x1: U32, +s1: U32, +step: U32, +tclip: U32, +bclip: U32, +mc: U32, +sg: R.RSeg) -> V.Frame:
  match v sg:
    case V.View{vx, vy, vz, va, ex, fx} R.RSeg{x1s, y1s, x2s, y2s, an, of, +fl, sd, +bk}:
      +side = V.rside(w, sd)
      +fs = V.sector(w, V.side.sector(side))
      +bs = V.sector(w, bk)
      +t = V.tex(w, seg.mid(side))
      +ln0 = ((V.sec.light(fs) >> 4n) + ex : U32)
      +ln = Bool.pick(U32, U32.is_eq(y1s, y2s), (ln0 - 1 : U32), Bool.pick(U32, U32.is_eq(x1s, x2s), (ln0 + 1 : U32), ln0))
      +light = V.lit(fx, ln)
      +mid = (Bool.pick(U32, U32.is_eq((fl .&. 16 : U32), 0), (F.min(V.sec.ceil(fs), V.sec.ceil(bs)) - vz : U32), (F.max(V.sec.floor(fs), V.sec.floor(bs)) + V.info.height(t) - vz : U32)) + seg.rowoff(side) : U32)
      seg.loop(V.count(r1, r2), fr, t, r1, mc, (s1 + (r1 - x1) * step : U32), step, mid, light, bclip, tclip)

def rendermasked(fr: V.Frame, +w: R.World, +v: V.View, +d: U32, +r1: U32, +r2: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(ram, M.ds(d, 0)), a1 => +x1 =>
        M.let(V.Frame, M.rd(a1, M.ds(d, 2)), a2 => +s1 =>
          M.let(V.Frame, M.rd(a2, M.ds(d, 4)), a3 => +step =>
            M.let(V.Frame, M.rd(a3, M.ds(d, 8)), a4 => +tclip =>
              M.let(V.Frame, M.rd(a4, M.ds(d, 9)), a5 => +bclip =>
                M.let(V.Frame, M.rd(a5, M.ds(d, 10)), a6 => +mc =>
                  M.let(V.Frame, M.rd(a6, M.ds(d, 11)), a7 => +si =>
                    seg.range(V.Frame{fb, rom, a7, sd}, w, v, r1, r2, x1, s1, step, tclip, bclip, mc, V.seg(w, si)))))))))

def setclip(n: Nat, ram: Array<U32>, +i: U32, +src: U32, +bot: Bool, +top: Bool, +sb: U32, +st: U32) -> Array<U32>:
  match n:
    case 0n:
      ram
    case 1n+p:
      M.let(Array<U32>, M.rd(ram, (M.clipbot() + i : U32)), r1 => +cb =>
        M.let(Array<U32>, M.rd(r1, (M.cliptop() + i : U32)), r2 => +ct =>
          M.let(Array<U32>, M.rd(r2, (sb + i : U32)), r3 => +vb =>
            M.let(Array<U32>, M.rd(r3, (st + i : U32)), r4 => +vt =>
              r5 = M.wr(r4, (M.clipbot() + i : U32), Bool.pick(U32, Bool.and(bot, U32.is_eq(cb, 4294967294)), vb, cb))
              r6 = M.wr(r5, (M.cliptop() + i : U32), Bool.pick(U32, Bool.and(top, U32.is_eq(ct, 4294967294)), vt, ct))
              setclip(p, r6, (i + 1 : U32), src, bot, top, sb, st)))))

def ds.masked(go: Bool, fr: V.Frame, +w: R.World, +v: V.View, +d: U32, +r1: U32, +r2: U32) -> V.Frame:
  match go:
    case True{}:
      rendermasked(fr, w, v, d, r1, r2)
    case False{}:
      fr

def ds.clip.pick(skip: Bool, behind: Bool, fr: V.Frame, +w: R.World, +v: V.View, +d: U32, +r1: U32, +r2: U32, +mc: U32, +s: U32, +tclip: U32, +bclip: U32) -> V.Frame:
  match skip behind fr:
    case True{} _ f:
      f
    case False{} True{} f:
      ds.masked(Bool.not(U32.is_eq(mc, M.none())), f, w, v, d, r1, r2)
    case False{} False{} V.Frame{fb, rom, ram, sd}:
      V.Frame{fb, rom, setclip(V.count(r1, r2), ram, r1, 0, Bool.not(U32.is_eq((s .&. 1 : U32), 0)), Bool.not(U32.is_eq((s .&. 2 : U32), 0)), bclip, tclip), sd}

def seg.side.of(+x: U32, +y: U32, +sg: R.RSeg) -> Bool:
  match sg:
    case R.RSeg{x1, y1, x2, y2, an, of, fl, sd, bk}:
      V.side.of(x, y, x1, y1, (x2 - x1 : U32), (y2 - y1 : U32))

def seg.side(+w: R.World, +x: U32, +y: U32, +si: U32) -> Bool:
  seg.side.of(x, y, V.seg(w, si))

def ds.clip(fr: V.Frame, +w: R.World, +v: V.View, +d: U32, +sx1: U32, +sx2: U32, +sscale: U32, +gx: U32, +gy: U32, +gz: U32, +gzt: U32, +dx1: U32, +dx2: U32, +sil: U32, +mc: U32, +s1: U32, +s2: U32, +si: U32, +bsil: U32, +tsil: U32, +tclip: U32, +bclip: U32) -> V.Frame:
  +r1 = F.max(dx1, sx1)
  +r2 = F.min(dx2, sx2)
  +lo = F.min(s1, s2)
  +hi = F.max(s1, s2)
  +skip = Bool.or(Bool.or(F.gt(dx1, sx2), F.lt(dx2, sx1)), Bool.and(U32.is_eq(sil, 0), U32.is_eq(mc, M.none())))
  +behind = Bool.or(F.lt(hi, sscale), Bool.and(F.lt(lo, sscale), Bool.not(seg.side(w, gx, gy, si))))
  +s = (sil .&. Bool.pick(U32, F.ge(gz, bsil), 2, 3) .&. Bool.pick(U32, F.le(gzt, tsil), 1, 3) : U32)
  ds.clip.pick(skip, behind, fr, w, v, d, r1, r2, mc, s, tclip, bclip)

def ds.one(fr: V.Frame, +w: R.World, +v: V.View, +d: U32, +sx1: U32, +sx2: U32, +sscale: U32, +gx: U32, +gy: U32, +gz: U32, +gzt: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(ram, M.ds(d, 0)), a0 => +dx1 =>
        M.let(V.Frame, M.rd(a0, M.ds(d, 1)), a1 => +dx2 =>
          M.let(V.Frame, M.rd(a1, M.ds(d, 2)), a2 => +s1 =>
            M.let(V.Frame, M.rd(a2, M.ds(d, 3)), a3 => +s2 =>
              M.let(V.Frame, M.rd(a3, M.ds(d, 5)), a4 => +sil =>
                M.let(V.Frame, M.rd(a4, M.ds(d, 6)), a5 => +bsil =>
                  M.let(V.Frame, M.rd(a5, M.ds(d, 7)), a6 => +tsil =>
                    M.let(V.Frame, M.rd(a6, M.ds(d, 8)), a7 => +tclip =>
                      M.let(V.Frame, M.rd(a7, M.ds(d, 9)), a8 => +bclip =>
                        M.let(V.Frame, M.rd(a8, M.ds(d, 10)), a9 => +mc =>
                          M.let(V.Frame, M.rd(a9, M.ds(d, 11)), a10 => +si =>
                            ds.clip(V.Frame{fb, rom, a10, sd}, w, v, d, sx1, sx2, sscale, gx, gy, gz, gzt, dx1, dx2, sil, mc, s1, s2, si, bsil, tsil, tclip, bclip))))))))))))

def ds.all(n: Nat, fr: V.Frame, +w: R.World, +v: V.View, +d: U32, +sx1: U32, +sx2: U32, +sscale: U32, +gx: U32, +gy: U32, +gz: U32, +gzt: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      ds.all(p, ds.one(fr, w, v, d, sx1, sx2, sscale, gx, gy, gz, gzt), w, v, (d - 1 : U32), sx1, sx2, sscale, gx, gy, gz, gzt)

def setn(n: Nat, ram: Array<U32>, +i: U32, +v: U32) -> Array<U32>:
  match n:
    case 0n:
      ram
    case 1n+p:
      setn(p, M.wr(ram, i, v), (i + 1 : U32), v)

def defaults(n: Nat, ram: Array<U32>, +i: U32) -> Array<U32>:
  match n:
    case 0n:
      ram
    case 1n+p:
      M.let(Array<U32>, M.rd(ram, (M.clipbot() + i : U32)), r1 => +cb =>
        M.let(Array<U32>, M.rd(r1, (M.cliptop() + i : U32)), r2 => +ct =>
          r3 = M.wr(r2, (M.clipbot() + i : U32), Bool.pick(U32, U32.is_eq(cb, 4294967294), M.vh(), cb))
          defaults(p, M.wr(r3, (M.cliptop() + i : U32), Bool.pick(U32, U32.is_eq(ct, 4294967294), 4294967295, ct)), (i + 1 : U32))))

def vis.col(fr: V.Frame, +x: U32, +frac: U32, +patch: U32, +top: U32, +scale: U32, +mid: U32, +iscale: U32, +cm: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      +tc = F.sar(frac, 16n)
      +o = (patch + 8 + 4 * tc : U32)
      M.let(V.Frame, M.rd(rom, o), r1 => +b0 =>
        M.let(V.Frame, M.rd(r1, (o + 1 : U32)), r2 => +b1 =>
          M.let(V.Frame, M.rd(r2, (o + 2 : U32)), r3 => +b2 =>
            M.let(V.Frame, M.rd(r3, (o + 3 : U32)), r4 => +b3 =>
              masked.column(V.Frame{fb, r4, ram, sd}, x, (patch + (b0 .|. (b1 << 8n) .|. (b2 << 16n) .|. (b3 << 24n)) : U32), top, scale, mid, iscale, cm, M.clipbot(), M.cliptop())))))

def vis.cols(n: Nat, fr: V.Frame, +x: U32, +frac: U32, +step: U32, +patch: U32, +top: U32, +scale: U32, +mid: U32, +iscale: U32, +cm: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      vis.cols(p, vis.col(fr, x, frac, patch, top, scale, mid, iscale, cm), (x + 1 : U32), (frac + step : U32), step, patch, top, scale, mid, iscale, cm)

def vis.draw(fr: V.Frame, +x1: U32, +x2: U32, +scale: U32, +mid: U32, +start: U32, +step: U32, +patch: U32, +cm: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      vis.cols(V.count(x1, x2), V.Frame{fb, rom, defaults(V.count(x1, x2), ram, x1), sd}, x1, start, step, patch, ((M.cy() << 16n) - F.mul(mid, scale) : U32), scale, mid, F.abs(step), cm)

def sprite.go(fr: V.Frame, +w: R.World, +v: V.View, +x1: U32, +x2: U32, +scale: U32, +gx: U32, +gy: U32, +gz: U32, +gzt: U32, +mid: U32, +start: U32, +step: U32, +patch: U32, +cm: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      +n = V.count(x1, x2)
      r1 = setn(n, setn(n, ram, (M.clipbot() + x1 : U32), 4294967294), (M.cliptop() + x1 : U32), 4294967294)
      M.let(V.Frame, M.rd(r1, M.ndrawsegs()), r2 => +nd =>
        vis.draw(ds.all(U32.to_nat(nd), V.Frame{fb, rom, r2, sd}, w, v, (nd - 1 : U32), x1, x2, scale, gx, gy, gz, gzt), x1, x2, scale, mid, start, step, patch, cm))

def sprite(fr: V.Frame, +w: R.World, +v: V.View, +s: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(ram, M.vs(s, 0)), a0 => +x1 =>
        M.let(V.Frame, M.rd(a0, M.vs(s, 1)), a1 => +x2 =>
          M.let(V.Frame, M.rd(a1, M.vs(s, 2)), a2 => +scale =>
            M.let(V.Frame, M.rd(a2, M.vs(s, 3)), a3 => +gx =>
              M.let(V.Frame, M.rd(a3, M.vs(s, 4)), a4 => +gy =>
                M.let(V.Frame, M.rd(a4, M.vs(s, 5)), a5 => +gz =>
                  M.let(V.Frame, M.rd(a5, M.vs(s, 6)), a6 => +gzt =>
                    M.let(V.Frame, M.rd(a6, M.vs(s, 7)), a7 => +mid =>
                      M.let(V.Frame, M.rd(a7, M.vs(s, 8)), a8 => +start =>
                        M.let(V.Frame, M.rd(a8, M.vs(s, 9)), a9 => +step =>
                          M.let(V.Frame, M.rd(a9, M.vs(s, 10)), a10 => +patch =>
                            M.let(V.Frame, M.rd(a10, M.vs(s, 11)), a11 => +cm =>
                              sprite.go(V.Frame{fb, rom, a11, sd}, w, v, x1, x2, scale, gx, gy, gz, gzt, mid, start, step, patch, cm)))))))))))))

def vs.scale(+v: VS) -> U32:
  match v:
    case VS{s, i}:
      s

def insert(+x: VS, +xs: U32, ys: List<&2, VS>) -> List<&2, VS>:
  match ys:
    case +y <> +t:
      Bool.pick(List<&2, VS>, F.lt(xs, vs.scale(y)), x <> y <> t, y <> insert(x, xs, t))
    case []:
      [x]

def sort(xs: List<&2, VS>, acc: List<&2, VS>) -> List<&2, VS>:
  match xs:
    case +x <> t:
      sort(t, insert(x, vs.scale(x), acc))
    case []:
      acc

def collect(n: Nat, ram: Array<U32>, +i: U32, acc: List<&2, VS>) -> Array<U32> & List<&2, VS>:
  match n:
    case 0n:
      (ram, acc)
    case 1n+p:
      M.let(Array<U32> & List<&2, VS>, M.rd(ram, M.vs(i, 2)), r1 => +sc =>
        collect(p, r1, (i - 1 : U32), VS{sc, i} <> acc))

def sprites(order: List<&2, VS>, fr: V.Frame, +w: R.World, +v: V.View) -> V.Frame:
  match order:
    case VS{sc, i} <> t:
      sprites(t, sprite(fr, w, v, i), w, v)
    case []:
      fr

def segs.one(fr: V.Frame, +w: R.World, +v: V.View, +d: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(ram, M.ds(d, 0)), a0 => +x1 =>
        M.let(V.Frame, M.rd(a0, M.ds(d, 1)), a1 => +x2 =>
          M.let(V.Frame, M.rd(a1, M.ds(d, 10)), a2 => +mc =>
            ds.masked(Bool.not(U32.is_eq(mc, M.none())), V.Frame{fb, rom, a2, sd}, w, v, d, x1, x2))))

def segs(n: Nat, fr: V.Frame, +w: R.World, +v: V.View, +d: U32) -> V.Frame:
  match n:
    case 0n:
      fr
    case 1n+p:
      segs(p, segs.one(fr, w, v, d), w, v, (d - 1 : U32))

def masked.sorted(r: Array<U32> & List<&2, VS>, fb: Array<U32>, rom: Array<U32>, sd: List<&2, V.Range>, +w: R.World, +v: V.View) -> V.Frame:
  (ram, vs) = r
  sprites(sort(vs, []), V.Frame{fb, rom, ram, sd}, w, v)

def masked.segs(fr: V.Frame, +w: R.World, +v: V.View) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(ram, M.ndrawsegs()), r1 => +nd =>
        segs(U32.to_nat(nd), V.Frame{fb, rom, r1, sd}, w, v, (nd - 1 : U32)))

def drawmasked(fr: V.Frame, +w: R.World, +v: V.View) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(ram, M.nvis()), r1 => +n =>
        masked.segs(masked.sorted(collect(U32.to_nat(n), r1, (n - 1 : U32), []), fb, rom, sd, w, v), w, v))

def topal.row(n: Nat, fb: Array<U32>, rom: Array<U32>, +x: U32, +y: U32, +pb: U32) -> Array<U32> & Array<U32>:
  match n:
    case 0n:
      (fb, rom)
    case 1n+p:
      M.let(Array<U32> & Array<U32>, M.rd(fb, S.at(x, y)), f1 => +i =>
        M.let(Array<U32> & Array<U32>, M.rd(rom, (pb + i : U32)), r1 => +c =>
          topal.row(p, M.wr(f1, S.at(x, y), c), r1, (x + 1 : U32), y, pb)))

def topal.rows(n: Nat, r: Array<U32> & Array<U32>, +y: U32, +pb: U32) -> Array<U32> & Array<U32>:
  match n:
    case 0n:
      r
    case 1n+p:
      (fb, rom) = r
      topal.rows(p, topal.row(320n, fb, rom, 0, y, pb), (y + 1 : U32), pb)

def out.at(fr: V.Frame, +pb: U32) -> Array<U32> & Array<U32>:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      topal.rows(200n, (fb, rom), 0, pb)

def out(fr: V.Frame) -> Array<U32> & Array<U32>:
  out.at(fr, M.pal())

def psp.draw(go: Bool, fr: V.Frame, +x1: U32, +x2: U32, +mid: U32, +start: U32, +step: U32, +patch: U32, +cm: U32) -> V.Frame:
  match go:
    case True{}:
      vis.draw(fr, x1, x2, 65536, mid, start, step, patch, cm)
    case False{}:
      fr

def psp.at(fr: V.Frame, +sx: U32, +sy: U32, +patch: U32, +flip: Bool, +width: U32, +left: U32, +top: U32, +cm: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      +tx = (sx - 10485760 - (left << 16n) : U32)
      +x1 = F.sar((10485760 + tx : U32), 16n)
      +x2 = (F.sar((10485760 + tx + (width << 16n) : U32), 16n) - 1 : U32)
      +vx1 = F.max(x1, 0)
      +vx2 = F.min(x2, 319)
      +step = Bool.pick(U32, flip, 4294901760, 65536)
      +start = (Bool.pick(U32, flip, ((width << 16n) - 1 : U32), 0) + Bool.pick(U32, F.gt(vx1, x1), (step * (vx1 - x1) : U32), 0) : U32)
      +mid = (6553600 + 32768 - (sy - (top << 16n)) : U32)
      +go = Bool.and(Bool.not(F.gt(x1, 320)), Bool.not(F.lt(x2, 0)))
      +n = Bool.pick(Nat, go, V.count(vx1, vx2), 0n)
      r1 = setn(n, setn(n, ram, (M.clipbot() + vx1 : U32), 4294967294), (M.cliptop() + vx1 : U32), 4294967294)
      psp.draw(go, V.Frame{fb, rom, r1, sd}, vx1, vx2, mid, start, step, patch, cm)

def psp.hdr(fr: V.Frame, +sx: U32, +sy: U32, +patch: U32, +flip: Bool, +cm: U32) -> V.Frame:
  match fr:
    case V.Frame{fb, rom, ram, sd}:
      M.let(V.Frame, M.rd(rom, patch), r1 => +w0 =>
        M.let(V.Frame, M.rd(r1, (patch + 1 : U32)), r2 => +w1 =>
          M.let(V.Frame, M.rd(r2, (patch + 4 : U32)), r3 => +l0 =>
            M.let(V.Frame, M.rd(r3, (patch + 5 : U32)), r4 => +l1 =>
              M.let(V.Frame, M.rd(r4, (patch + 6 : U32)), r5 => +t0 =>
                M.let(V.Frame, M.rd(r5, (patch + 7 : U32)), r6 => +t1 =>
                  psp.at(V.Frame{fb, r6, ram, sd}, sx, sy, patch, flip, (w0 .|. (w1 << 8n) : U32), V.s16((l0 .|. (l1 << 8n) : U32)), V.s16((t0 .|. (t1 << 8n) : U32)), cm)))))))

def psp.one(fr: V.Frame, +w: R.World, +p: PSp) -> V.Frame:
  match p:
    case PSp{+spr, +frm, +sx, +sy, +cm}:
      +sf = R.sframe(w, (spr * 32 + (frm .&. 31) : U32))
      psp.hdr(fr, sx, sy, V.sf.lump(sf, 0), V.sf.flip(sf, 0), cm)

def psprites(ps: List<&2, PSp>, fr: V.Frame, +w: R.World) -> V.Frame:
  match ps:
    case +p <> t:
      psprites(t, psp.one(fr, w, p), w)
    case []:
      fr

def render.with(+tb: V.Tabs, +w: R.World, +v: V.View, ps: List<&2, PSp>, rom: Array<U32>) -> V.Frame:
  psprites(ps, drawmasked(V.scene(tb, w, v, rom), w, v), w)

def render(+tb: V.Tabs, +w: R.World, +v: V.View, rom: Array<U32>) -> Array<U32> & Array<U32>:
  out(drawmasked(V.scene(tb, w, v, rom), w, v))
