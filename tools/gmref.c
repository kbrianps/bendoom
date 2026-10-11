#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>

#define TSF_POWF(a, b) ((float)pow((double)(a), (double)(b)))
#define TSF_EXPF(x) ((float)exp((double)(x)))
#define TSF_SQRTF(x) ((float)sqrt((double)(x)))
#define TSF_POW pow
#define TSF_LOG log
#define TSF_TAN tan
#define TSF_LOG10 log10
#define TSF_SQRT sqrt
#define TSF_IMPLEMENTATION
#include "tsf.h"

typedef uint32_t u32;
#define SEQRATE 11025
#define RATE 22050
#define NV 32
#define BLOCK 64

static float pw(float a, float b) { return (float)pow((double)a, (double)b); }
static float ex(float x) { return (float)exp((double)x); }
static float lg(float x) { return (float)log((double)x); }
static float lg10(float x) { return (float)log10((double)x); }
static float tn(float x) { return (float)tan((double)x); }
static float sq(float x) { return (float)sqrt((double)x); }

static float tc2s(float tc) { return pw(2.0f, tc / 1200.0f); }
static float c2hz(float c) { return 8.176f * pw(2.0f, c / 1200.0f); }
static float db2g(float db) { return db > -100.0f ? pw(10.0f, db * 0.05f) : 0.0f; }
static float g2db(float g) { return g <= 0.00001f ? -100.0f : 20.0f * lg10(g); }

static unsigned char *wad; static long wadlen;
static unsigned char *lump(const char *name, u32 *len) {
  u32 n = *(u32*)(wad+4), off = *(u32*)(wad+8);
  for (u32 i = 0; i < n; i++) {
    unsigned char *d = wad + off + 16*i;
    if (strncmp((char*)d+8, name, 8) == 0) { *len = *(u32*)(d+4); return wad + *(u32*)d; }
  }
  return NULL;
}

typedef struct { u32 t; u32 ev; } Ev;
static Ev evs[200000]; static int nev;
static u32 song_end;

static void addt(u32 *w, u32 *f, u32 ticks, u32 spt) {
  while (ticks > 0) {
    u32 c = ticks > 4096 ? 4096 : ticks;
    u32 a = (spt & 0xffff) * c;
    *f += a & 0xffff;
    *w += (spt >> 16) * c + (a >> 16) + (*f >> 16);
    *f &= 0xffff;
    ticks -= c;
  }
}

static u32 spt_of(u32 upb, u32 div) {
  u32 a = upb * 441u / 625u;
  return (a / div) * 1024u + ((a % div) * 1024u) / div;
}

static u32 varlen(unsigned char *d, u32 *p) {
  u32 v = 0; unsigned char b;
  do { b = d[(*p)++]; v = (v << 7) | (b & 0x7f); } while (b & 0x80);
  return v;
}

typedef struct { u32 tick; u32 upb; } Tempo;
static Tempo tempos[4096]; static int ntempo;

static void tick2time(u32 tick, u32 div, u32 *w) {
  u32 tw = 0, tf = 0, last = 0, upb = 500000;
  for (int i = 0; i < ntempo && tempos[i].tick <= tick; i++) {
    addt(&tw, &tf, tempos[i].tick - last, spt_of(upb, div));
    last = tempos[i].tick; upb = tempos[i].upb;
  }
  addt(&tw, &tf, tick - last, spt_of(upb, div));
  *w = tw;
}

static u32 pack(u32 st, u32 a, u32 b) { return (st << 16) | (a << 8) | b; }

static void parse_midi(unsigned char *d, u32 len) {
  u32 ntr = (d[10] << 8) | d[11], div = (d[12] << 8) | d[13];
  u32 p = 14;
  typedef struct { u32 tick, ev; } TE;
  static TE tev[200000]; int ntev = 0; u32 endtick = 0;
  ntempo = 0;
  for (u32 t = 0; t < ntr && p + 8 <= len; t++) {
    u32 tl = (d[p+4]<<24)|(d[p+5]<<16)|(d[p+6]<<8)|d[p+7];
    u32 q = p + 8, e = q + tl, tick = 0, run = 0;
    while (q < e) {
      tick += varlen(d, &q);
      u32 b = d[q];
      if (b == 0xff) {
        u32 ty = d[q+1]; q += 2; u32 l = varlen(d, &q);
        if (ty == 0x51) { tempos[ntempo].tick = tick; tempos[ntempo].upb = (d[q]<<16)|(d[q+1]<<8)|d[q+2]; ntempo++; }
        q += l;
        if (ty == 0x2f) break;
        continue;
      }
      if (b == 0xf0 || b == 0xf7) { q++; u32 l = varlen(d, &q); q += l; continue; }
      if (b & 0x80) { run = b; q++; }
      u32 hi = run & 0xf0, a = d[q++], c = 0;
      if (hi != 0xc0 && hi != 0xd0) c = d[q++];
      tev[ntev].tick = tick; tev[ntev].ev = pack(run, a, c); ntev++;
    }
    if (tick > endtick) endtick = tick;
    p = e;
  }
  for (int i = 1; i < ntempo; i++) for (int j = i; j > 0 && tempos[j].tick < tempos[j-1].tick; j--) { Tempo t = tempos[j]; tempos[j] = tempos[j-1]; tempos[j-1] = t; }
  nev = 0;
  for (int i = 0; i < ntev; i++) { tick2time(tev[i].tick, div, &evs[nev].t); evs[nev].ev = tev[i].ev; nev++; }
  tick2time(endtick, div, &song_end);
  for (int i = 1; i < nev; i++) for (int j = i; j > 0 && evs[j].t < evs[j-1].t; j--) { Ev t = evs[j]; evs[j] = evs[j-1]; evs[j-1] = t; }
}

static void parse_mus(unsigned char *d, u32 len) {
  static const u32 ctl[10] = { 0, 0, 1, 7, 10, 11, 91, 93, 64, 67 };
  static const u32 sys[15] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 120, 123, 126, 127, 121 };
  u32 start = d[6] | (d[7] << 8), p = start, w = 0, f = 0;
  int map[16]; u32 vel[16];
  for (int i = 0; i < 16; i++) { map[i] = -1; vel[i] = 127; }
  nev = 0;
  for (;;) {
    u32 b = d[p++], ty = (b >> 4) & 7, mc = b & 15, ch;
    if (ty == 6) break;
    if (mc == 15) ch = 9;
    else {
      if (map[mc] < 0) {
        int mx = -1; for (int i = 0; i < 16; i++) if (map[i] > mx) mx = map[i];
        int r = mx + 1; if (r == 9) r++;
        map[mc] = r;
        evs[nev].t = w; evs[nev].ev = pack(0xb0 | r, 0x7b, 0); nev++;
      }
      ch = map[mc];
    }
    switch (ty) {
      case 0: { u32 k = d[p++]; evs[nev].t = w; evs[nev].ev = pack(0x80|ch, k & 0x7f, 0); nev++; break; }
      case 1: { u32 k = d[p++]; if (k & 0x80) vel[mc] = d[p++] & 0x7f; evs[nev].t = w; evs[nev].ev = pack(0x90|ch, k & 0x7f, vel[mc]); nev++; break; }
      case 2: { u32 k = d[p++]; evs[nev].t = w; evs[nev].ev = pack(0xe0|ch, (k*64) & 0x7f, ((k*64) >> 7) & 0x7f); nev++; break; }
      case 3: { u32 k = d[p++]; if (k >= 10 && k <= 14) { evs[nev].t = w; evs[nev].ev = pack(0xb0|ch, sys[k], 0); nev++; } break; }
      case 4: { u32 k = d[p++], v = d[p++]; if (v & 0x80) v = 0x7f;
        if (k == 0) { evs[nev].t = w; evs[nev].ev = pack(0xc0|ch, v, 0); nev++; }
        else if (k <= 9) { evs[nev].t = w; evs[nev].ev = pack(0xb0|ch, ctl[k], v); nev++; }
        break; }
      default: break;
    }
    if (b & 0x80) addt(&w, &f, varlen(d, &p), 5160960u);
  }
  song_end = w;
}

typedef struct { int seg; int expo; int amp; int vel; float level, slope; int until; struct tsf_envelope p; } Env;
typedef struct { float qinv, a0, a1, b1, b2, z1, z2; int active; } Lp;
typedef struct { int until; float level, delta; } Lfo;
typedef struct {
  int preset, key, chan, held; struct tsf_region *r;
  float pin, pout; u32 pos, frac;
  float gaindb, pl, pr; u32 play, lstart, lend;
  Env amp, mod; Lp lp; Lfo mlfo, vlfo;
} Voice;
typedef struct { int preset, bank, wheel, mpan, mvol, mexp, rpn, data, sustain; float panoff, gaindb, range, tuning; } Chan;

static tsf *font;
static short *smp; static u32 nsmp;
static Voice vs[NV];
static Chan cs[16];
static u32 playidx;

enum { S_NONE, S_DELAY, S_ATTACK, S_HOLD, S_DECAY, S_SUSTAIN, S_RELEASE, S_DONE };

static int relsamples(Env *e) { return (int)((e->p.release <= 0 ? 0.01f : e->p.release) * (float)RATE); }

static void nextseg(Env *e, int s) {
  float R = (float)RATE;
  switch (s) {
    case S_NONE:
      e->until = (int)(e->p.delay * R);
      if (e->until > 0) { e->seg = S_DELAY; e->expo = 0; e->level = 0.0f; e->slope = 0.0f; return; }
    case S_DELAY:
      e->until = (int)(e->p.attack * R);
      if (e->until > 0) {
        if (!e->amp) e->until = (int)(e->p.attack * ((float)(145 - e->vel) / 144.0f) * R);
        e->seg = S_ATTACK; e->expo = 0; e->level = 0.0f; e->slope = 1.0f / (float)e->until; return;
      }
    case S_ATTACK:
      e->until = (int)(e->p.hold * R);
      if (e->until > 0) { e->seg = S_HOLD; e->expo = 0; e->level = 1.0f; e->slope = 0.0f; return; }
    case S_HOLD:
      e->until = (int)(e->p.decay * R);
      if (e->until > 0) {
        e->seg = S_DECAY; e->level = 1.0f;
        if (e->amp) {
          float m = -9.226f / (float)e->until;
          e->slope = ex(m); e->expo = 1;
          if (e->p.sustain > 0.0f) e->until = (int)(lg(e->p.sustain) / m);
        } else {
          e->slope = -1.0f / (float)e->until;
          e->until = (int)(e->p.decay * (1.0f - e->p.sustain) * R);
          e->expo = 0;
        }
        return;
      }
    case S_DECAY:
      e->seg = S_SUSTAIN; e->level = e->p.sustain; e->slope = 0.0f; e->until = 0x7FFFFFFF; e->expo = 0; return;
    case S_SUSTAIN:
      e->seg = S_RELEASE; e->until = relsamples(e);
      if (e->amp) { float m = -9.226f / (float)e->until; e->slope = ex(m); e->expo = 1; }
      else { e->slope = -e->level / (float)e->until; e->expo = 0; }
      return;
    default:
      e->seg = S_DONE; e->expo = 0; e->level = 0.0f; e->slope = 0.0f; e->until = 0x7FFFFFF;
  }
}

static void envsetup(Env *e, struct tsf_envelope *p, int key, int vel, int amp) {
  e->p = *p;
  if (e->p.keynumToHold != 0.0f) {
    e->p.hold = e->p.hold + e->p.keynumToHold * (60.0f - (float)key);
    e->p.hold = e->p.hold < -10000.0f ? 0.0f : tc2s(e->p.hold);
  }
  if (e->p.keynumToDecay != 0.0f) {
    e->p.decay = e->p.decay + e->p.keynumToDecay * (60.0f - (float)key);
    e->p.decay = e->p.decay < -10000.0f ? 0.0f : tc2s(e->p.decay);
  }
  e->vel = vel; e->amp = amp;
  nextseg(e, S_NONE);
}

static void envproc(Env *e, int n) {
  if (e->slope != 0.0f) {
    if (e->expo) e->level = e->level * pw(e->slope, (float)n);
    else e->level = e->level + e->slope * (float)n;
  }
  e->until -= n;
  if (e->until <= 0) nextseg(e, e->seg);
}

static void lpsetup(Lp *l, float fc) {
  float k = tn(3.14159265f * fc), kk = k * k;
  float norm = 1.0f / (1.0f + k * l->qinv + kk);
  l->a0 = kk * norm; l->a1 = 2.0f * l->a0;
  l->b1 = 2.0f * (kk - 1.0f) * norm;
  l->b2 = (1.0f - k * l->qinv + kk) * norm;
}

static float lpproc(Lp *l, float in) {
  float out = in * l->a0 + l->z1;
  l->z1 = in * l->a1 + l->z2 - l->b1 * out;
  l->z2 = in * l->a0 - l->b2 * out;
  return out;
}

static void lfosetup(Lfo *f, float delay, int fc) {
  f->until = (int)(delay * (float)RATE);
  f->delta = 4.0f * c2hz((float)fc) / (float)RATE;
  f->level = 0.0f;
}

static void lfoproc(Lfo *f, int n) {
  if (f->until > n) { f->until -= n; return; }
  f->level = f->level + f->delta * (float)n;
  if (f->level > 1.0f) { f->delta = -f->delta; f->level = 2.0f - f->level; }
  else if (f->level < -1.0f) { f->delta = -f->delta; f->level = -2.0f - f->level; }
}

static void vend(Voice *v) {
  nextseg(&v->amp, S_SUSTAIN);
  nextseg(&v->mod, S_SUSTAIN);
  if (v->r->loop_mode == TSF_LOOPMODE_SUSTAIN) v->lend = v->lstart;
}

static void vquick(Voice *v) {
  v->amp.p.release = 0.0f; nextseg(&v->amp, S_SUSTAIN);
  v->mod.p.release = 0.0f; nextseg(&v->mod, S_SUSTAIN);
}

static float shift(Chan *c) {
  return c->wheel == 8192 ? c->tuning : ((float)c->wheel / 16383.0f * c->range * 2.0f) - c->range + c->tuning;
}

static void pitch(Voice *v, float sh) {
  struct tsf_region *r = v->r;
  float note = (float)(v->key + r->transpose) + (float)r->tune / 100.0f;
  float adj = (float)r->pitch_keycenter + (note - (float)r->pitch_keycenter) * ((float)r->pitch_keytrack / 100.0f);
  if (sh != 0.0f) adj = adj + sh;
  v->pin = adj * 100.0f;
  v->pout = (float)r->sample_rate / (tc2s((float)r->pitch_keycenter * 100.0f) * (float)RATE);
}

static void setpan(Voice *v, float np) {
  if (np <= -0.5f) { v->pl = 1.0f; v->pr = 0.0f; }
  else if (np >= 0.5f) { v->pl = 0.0f; v->pr = 1.0f; }
  else { v->pl = sq(0.5f - np); v->pr = sq(0.5f + np); }
}

static int presetindex(int bank, int num) {
  for (int i = 0; i < font->presetNum; i++) if (font->presets[i].preset == num && font->presets[i].bank == bank) return i;
  return -1;
}

static void noteon(int ch, int key, int velb) {
  Chan *c = &cs[ch];
  int pi = c->preset;
  float vel = (float)velb / 127.0f;
  int mv = (int)(vel * 127.0f);
  if (pi < 0 || pi >= font->presetNum) return;
  u32 idx = playidx++;
  struct tsf_preset *p = &font->presets[pi];
  for (int ri = 0; ri < p->regionNum; ri++) {
    struct tsf_region *r = &p->regions[ri];
    if (key < r->lokey || key > r->hikey || mv < r->lovel || mv > r->hivel) continue;
    Voice *voice = NULL;
    if (r->group) {
      for (int i = 0; i < NV; i++) {
        Voice *v = &vs[i];
        if (v->preset == pi && v->r->group == r->group) vquick(v);
        else if (v->preset == -1 && !voice) voice = v;
      }
    } else for (int i = 0; i < NV; i++) if (vs[i].preset == -1) { voice = &vs[i]; break; }
    if (!voice) {
      int best = -999999999;
      for (int i = 0; i < NV; i++) {
        Voice *v = &vs[i];
        if (v->amp.seg == S_RELEASE) {
          int done = relsamples(&v->amp) - v->amp.until;
          if (done > best) { best = done; voice = v; }
        }
      }
      if (!voice) continue;
      voice->preset = -1;
    }
    voice->r = r; voice->preset = pi; voice->key = key; voice->play = idx; voice->held = 0;
    voice->gaindb = 0.0f - r->attenuation - g2db(1.0f / vel);
    voice->chan = ch;
    voice->gaindb = voice->gaindb + c->gaindb;
    pitch(voice, shift(c));
    setpan(voice, r->pan + c->panoff);
    voice->pos = r->offset; voice->frac = 0;
    int loop = r->loop_mode != TSF_LOOPMODE_NONE && r->loop_start < r->loop_end;
    voice->lstart = loop ? r->loop_start : 0;
    voice->lend = loop ? r->loop_end : 0;
    envsetup(&voice->amp, &r->ampenv, key, mv, 1);
    envsetup(&voice->mod, &r->modenv, key, mv, 0);
    float fc = r->initialFilterFc <= 13500 ? c2hz((float)r->initialFilterFc) / (float)RATE : 1.0f;
    float qdb = (float)r->initialFilterQ / 10.0f;
    voice->lp.qinv = 1.0f / pw(10.0f, qdb / 20.0f);
    voice->lp.z1 = voice->lp.z2 = 0.0f;
    voice->lp.active = fc < 0.499f;
    if (voice->lp.active) lpsetup(&voice->lp, fc);
    lfosetup(&voice->mlfo, r->delayModLFO, r->freqModLFO);
    lfosetup(&voice->vlfo, r->delayVibLFO, r->freqVibLFO);
  }
}

static void noteoff(int ch, int key) {
  int first = -1, last = -1;
  for (int i = 0; i < NV; i++) {
    Voice *v = &vs[i];
    if (v->preset == -1 || v->chan != ch || v->key != key || v->amp.seg >= S_RELEASE || v->held) continue;
    if (first < 0 || v->play < vs[first].play) first = last = i;
    else if (v->play == vs[first].play) last = i;
  }
  if (first < 0) return;
  for (int i = first; i <= last; i++) {
    Voice *v = &vs[i];
    if (i != first && i != last && (v->play != vs[first].play || v->preset == -1 || v->chan != ch || v->key != key || v->amp.seg >= S_RELEASE)) continue;
    if (cs[ch].sustain) v->held = 1; else vend(v);
  }
}

static void chan_reset(int i) {
  Chan *c = &cs[i];
  c->preset = 0; c->bank = 0; c->wheel = 8192; c->mpan = 8192; c->mvol = 16383; c->mexp = 16383;
  c->rpn = 0xFFFF; c->data = 0; c->sustain = 0; c->panoff = 0.0f; c->gaindb = 0.0f; c->range = 2.0f; c->tuning = 0.0f;
}

static void setprog(int ch, int num) {
  Chan *c = &cs[ch];
  int pi;
  if (ch == 9) {
    pi = presetindex(128 | (c->bank & 0x7FFF), num);
    if (pi == -1) pi = presetindex(128, num);
    if (pi == -1) pi = presetindex(128, 0);
    if (pi == -1) pi = presetindex(c->bank & 0x7FFF, num);
  } else pi = presetindex(c->bank & 0x7FFF, num);
  if (pi == -1) pi = presetindex(0, num);
  if (pi != -1) c->preset = pi;
}

static void applypitch(int ch) {
  float sh = shift(&cs[ch]);
  for (int i = 0; i < NV; i++) if (vs[i].preset != -1 && vs[i].chan == ch) pitch(&vs[i], sh);
}

static void setvolume(int ch, float vol) {
  Chan *c = &cs[ch];
  float db = g2db(vol);
  if (db == c->gaindb) return;
  float d = db - c->gaindb;
  for (int i = 0; i < NV; i++) if (vs[i].preset != -1 && vs[i].chan == ch) vs[i].gaindb = vs[i].gaindb + d;
  c->gaindb = db;
}

static void setpanc(int ch, float pan) {
  for (int i = 0; i < NV; i++) if (vs[i].preset != -1 && vs[i].chan == ch) setpan(&vs[i], vs[i].r->pan + pan - 0.5f);
  cs[ch].panoff = pan - 0.5f;
}

static void setrange(int ch, float r) {
  Chan *c = &cs[ch];
  if (c->range == r) return;
  c->range = r;
  if (c->wheel != 8192) applypitch(ch);
}

static void settuning(int ch, float t) {
  Chan *c = &cs[ch];
  if (c->tuning == t) return;
  c->tuning = t;
  applypitch(ch);
}

static void setsustain(int ch, int on) {
  Chan *c = &cs[ch];
  if (!c->sustain == !on) return;
  c->sustain = on != 0;
  if (on) return;
  for (int i = 0; i < NV; i++) if (vs[i].preset != -1 && vs[i].chan == ch && vs[i].amp.seg < S_RELEASE && vs[i].held) vend(&vs[i]);
}

static void control(int ch, int ctl, int val) {
  Chan *c = &cs[ch];
  switch (ctl) {
    case 7: c->mvol = (c->mvol & 0x7F) | (val << 7); goto vol;
    case 39: c->mvol = (c->mvol & 0x3F80) | val; goto vol;
    case 11: c->mexp = (c->mexp & 0x7F) | (val << 7); goto vol;
    case 43: c->mexp = (c->mexp & 0x3F80) | val; goto vol;
    case 10: c->mpan = (c->mpan & 0x7F) | (val << 7); goto pan;
    case 42: c->mpan = (c->mpan & 0x3F80) | val; goto pan;
    case 6: c->data = (c->data & 0x7F) | (val << 7); goto data;
    case 38: c->data = (c->data & 0x3F80) | val; goto data;
    case 0: c->bank = 0x8000 | val; return;
    case 32: c->bank = ((c->bank & 0x8000) ? ((c->bank & 0x7F) << 7) : 0) | val; return;
    case 101: c->rpn = (((c->rpn == 0xFFFF ? 0 : c->rpn) & 0x7F) | (val << 7)); return;
    case 100: c->rpn = (((c->rpn == 0xFFFF ? 0 : c->rpn) & 0x3F80) | val); return;
    case 98: case 99: c->rpn = 0xFFFF; return;
    case 64: setsustain(ch, val >= 64); return;
    case 120:
      for (int i = 0; i < NV; i++) if (vs[i].preset != -1 && vs[i].chan == ch && (vs[i].amp.seg < S_RELEASE || vs[i].amp.p.release != 0.0f)) vquick(&vs[i]);
      return;
    case 123:
      for (int i = 0; i < NV; i++) if (vs[i].preset != -1 && vs[i].chan == ch && vs[i].amp.seg < S_RELEASE) vend(&vs[i]);
      return;
    case 121:
      c->mvol = c->mexp = 16383; c->mpan = 8192; c->bank = 0; c->rpn = 0xFFFF; c->data = 0;
      setvolume(ch, 1.0f); setpanc(ch, 0.5f); setrange(ch, 2.0f); settuning(ch, 0.0f);
      return;
  }
  return;
vol: {
    float a = (float)c->mvol / 16383.0f, b = (float)c->mexp / 16383.0f;
    setvolume(ch, pw(a * b, 3.0f));
    return;
  }
pan:
  setpanc(ch, (float)c->mpan / 16383.0f);
  return;
data:
  if (c->rpn == 0) setrange(ch, (float)(c->data >> 7) + 0.01f * (float)(c->data & 0x7F));
  else if (c->rpn == 1) settuning(ch, (float)(int)c->tuning + ((float)c->data - 8192.0f) / 8192.0f);
  else if (c->rpn == 2 && ctl == 6) settuning(ch, ((float)val - 64.0f) + (c->tuning - (float)(int)c->tuning));
}

static void event(u32 e) {
  u32 st = e >> 16, a = (e >> 8) & 0xff, b = e & 0xff, ch = st & 15;
  switch (st & 0xf0) {
    case 0x80: noteoff(ch, a); break;
    case 0x90: if (b == 0) noteoff(ch, a); else noteon(ch, a, b); break;
    case 0xb0: control(ch, a, b); break;
    case 0xc0: setprog(ch, a); break;
    case 0xe0: { int w = (int)((b << 7) | a); if (cs[ch].wheel != w) { cs[ch].wheel = w; applypitch(ch); } break; }
  }
}

static float smpf(u32 i) { return (float)smp[i] / 32767.0f; }

static void vrender(Voice *v, float *buf, int n) {
  struct tsf_region *r = v->r;
  int upmod = r->modEnvToPitch || r->modEnvToFilterFc;
  int upmlfo = v->mlfo.delta != 0.0f && (r->modLfoToPitch || r->modLfoToFilterFc || r->modLfoToVolume);
  int upvlfo = v->vlfo.delta != 0.0f && r->vibLfoToPitch;
  int looping = v->lstart < v->lend;
  u32 ls = v->lstart, le = v->lend, end = r->end;
  int dynlp = r->modLfoToFilterFc || r->modEnvToFilterFc;
  int dynpitch = r->modLfoToPitch || r->modEnvToPitch || r->vibLfoToPitch;
  int dyngain = r->modLfoToVolume != 0;
  float ratio = 0.0f, gain = 0.0f;
  if (!dynpitch) ratio = tc2s(v->pin) * v->pout;
  if (!dyngain) gain = db2g(v->gaindb);
  float *out = buf;
  while (n) {
    int bs = n > BLOCK ? BLOCK : n;
    n -= bs;
    if (dynlp) {
      float fres = (float)r->initialFilterFc + v->mlfo.level * (float)r->modLfoToFilterFc + v->mod.level * (float)r->modEnvToFilterFc;
      float fc = fres <= 13500.0f ? c2hz(fres) / (float)RATE : 1.0f;
      v->lp.active = fc < 0.499f;
      if (v->lp.active) lpsetup(&v->lp, fc);
    }
    if (dynpitch) ratio = tc2s(v->pin + (v->mlfo.level * (float)r->modLfoToPitch + v->vlfo.level * (float)r->vibLfoToPitch + v->mod.level * (float)r->modEnvToPitch)) * v->pout;
    if (dyngain) gain = db2g(v->gaindb + v->mlfo.level * ((float)r->modLfoToVolume * 0.1f));
    float gm = gain * v->amp.level;
    envproc(&v->amp, bs);
    if (upmod) envproc(&v->mod, bs);
    if (upmlfo) lfoproc(&v->mlfo, bs);
    if (upvlfo) lfoproc(&v->vlfo, bs);
    float gl = gm * v->pl, gr = gm * v->pr;
    u32 whole = ratio >= 0.0f && ratio < 4294967296.0f ? (u32)ratio : 0;
    float fr = (ratio - (float)whole) * 65536.0f;
    u32 step = fr >= 0.0f && fr < 4294967296.0f ? (u32)fr : 0;
    while (bs-- && v->pos < end) {
      u32 pos = v->pos, nx = (pos >= le && looping) ? ls : pos + 1;
      float al = (float)v->frac / 65536.0f;
      float val = smpf(pos) * (1.0f - al) + smpf(nx) * al;
      if (v->lp.active) val = lpproc(&v->lp, val);
      out[0] = out[0] + val * gl;
      out[1] = out[1] + val * gr;
      out += 2;
      v->frac += step;
      v->pos += whole + (v->frac >> 16);
      v->frac &= 0xffff;
      if (v->pos >= le + 1 && looping) v->pos -= le - ls + 1;
    }
    if (bs > 0) out += 2 * bs;
    if (v->pos >= end || v->amp.seg == S_DONE) { v->preset = -1; return; }
  }
}

static void render(float *buf, int n) {
  memset(buf, 0, sizeof(float) * 2 * n);
  for (int i = 0; i < NV; i++) if (vs[i].preset != -1) vrender(&vs[i], buf, n);
}

static short toshort(float v) {
  return v < -1.00004566f ? (short)-32768 : (v > 1.00001514f ? (short)32767 : (short)(v * 32767.5f));
}

static void restart(void) {
  for (int i = 0; i < NV; i++) if (vs[i].preset != -1 && (vs[i].amp.seg < S_RELEASE || vs[i].amp.p.release != 0.0f)) vquick(&vs[i]);
  for (int i = 0; i < 16; i++) chan_reset(i);
  setprog(9, 0);
}

static u32 rd32(unsigned char *p) { return p[0] | (p[1] << 8) | (p[2] << 16) | ((u32)p[3] << 24); }

int main(int argc, char **argv) {
  if (argc < 6) { fprintf(stderr, "gmref WAD LUMP SECONDS SF2 OUT [musvol]\n"); return 2; }
  FILE *f = fopen(argv[1], "rb"); fseek(f, 0, SEEK_END); wadlen = ftell(f); fseek(f, 0, SEEK_SET);
  wad = malloc(wadlen); fread(wad, 1, wadlen, f); fclose(f);
  u32 sl;
  unsigned char *s = lump(argv[2], &sl);
  if (!s) { fprintf(stderr, "no lump\n"); return 1; }
  if (memcmp(s, "MThd", 4) == 0) parse_midi(s, sl); else parse_mus(s, sl);
  font = tsf_load_filename(argv[4]);
  if (!font) { fprintf(stderr, "no sf2\n"); return 1; }
  FILE *sf = fopen(argv[4], "rb"); fseek(sf, 0, SEEK_END); long sfl = ftell(sf); fseek(sf, 0, SEEK_SET);
  unsigned char *sb = malloc(sfl); fread(sb, 1, sfl, sf); fclose(sf);
  for (long p = 12; p + 8 <= sfl;) {
    u32 sz = rd32(sb + p + 4);
    if (!memcmp(sb + p, "LIST", 4) && !memcmp(sb + p + 8, "sdta", 4)) {
      for (long q = p + 12; q + 8 <= p + 8 + sz;) {
        u32 z = rd32(sb + q + 4);
        if (!memcmp(sb + q, "smpl", 4)) { smp = (short*)(sb + q + 8); nsmp = z / 2; }
        q += 8 + z + (z & 1);
      }
    }
    p += 8 + sz + (sz & 1);
  }
  fprintf(stderr, "%d events end %u presets %d samples %u\n", nev, song_end, font->presetNum, nsmp);
  int musvol = argc > 6 ? atoi(argv[6]) * 8 : 64;
  float mv = (float)musvol / 127.0f;
  for (int i = 0; i < NV; i++) vs[i].preset = -1;
  restart();
  u32 total = (u32)(atof(argv[3]) * SEQRATE), n = 0, base = 0;
  int ei = 0;
  FILE *o = fopen(argv[5], "wb");
  static float buf[2 * 2 * 315];
  u32 ticend = 0;
  while (n < total) {
    if (n == ticend) ticend += 315;
    while (ei < nev && evs[ei].t + base <= n) { event(evs[ei].ev); ei++; }
    if (ei >= nev && song_end + 55 + base <= n) { base = n; ei = 0; restart(); continue; }
    u32 lim = ticend;
    u32 ne = ei < nev ? evs[ei].t + base : song_end + 55 + base;
    if (ne < lim) lim = ne;
    u32 k = lim - n;
    if (k == 0) k = 1;
    render(buf, 2 * k);
    for (u32 i = 0; i < 4 * k; i++) { short v = toshort(buf[i] * mv); fwrite(&v, 2, 1, o); }
    n += k;
  }
  fclose(o);
  return 0;
}
