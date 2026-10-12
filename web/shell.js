
const WEB = {
  files: new Map(),
  args: [],
  env: {},
  keys: [],
  canvas: null,
  ctx: null,
  pix: null,
  order: null,
  audio: null,
  started: false,
  report: (text) => console.error(text),
};

function $src$047screen$058image$(a) {
  return { $: "Pix", color: 0, fb: a };
}

function array_new(d, v) {
  if (d > 31) {
    throw "bend: an array past the deepest block class 31";
  }
  const a = new Float64Array(2 ** d);
  return v === 0 ? a : a.fill(v);
}

function array_node(a, b) {
  if (a.length !== b.length) {
    throw "bend: runtime fail-stop";
  }
  const c = new Float64Array(a.length * 2);
  c.set(a);
  c.set(b, a.length);
  return c;
}

function $List$append$(xs, ys) {
  const hs = [];
  for (; xs.$ === "Con"; xs = xs.tail) {
    hs.push(xs.head);
  }
  for (let i = hs.length - 1; i >= 0; i -= 1) {
    ys = { $: "Con", head: hs[i], tail: ys };
  }
  return ys;
}

function $List$take$(xs, n) {
  const hs = [];
  for (; xs.$ === "Con" && hs.length < n; xs = xs.tail) {
    hs.push(xs.head);
  }
  let ys = { $: "Nil" };
  for (let i = hs.length - 1; i >= 0; i -= 1) {
    ys = { $: "Con", head: hs[i], tail: ys };
  }
  return ys;
}

function web_at(x, y) {
  return (web_spread(x) | (web_spread(y) << 1)) >>> 0;
}

function $src$047draw$058topal$row$(n, fb, rom, x, y, pb) {
  const fl = fb.length;
  const rl = rom.length;
  const sy = web_spread(y) << 1;
  for (; n > 0; n -= 1, x = (x + 1) >>> 0) {
    const at = ((web_spread(x) | sy) >>> 0) % fl;
    fb[at] = rom[((pb + fb[at]) >>> 0) % rl];
  }
  return { $: "Tuple", fst: fb, snd: rom };
}

function $src$047render$058paint$(n, fr, x, y, frac, step, col, cm) {
  const fb = fr.fb;
  const rom = fr.rom;
  const fl = fb.length;
  const rl = rom.length;
  const sx = web_spread(x);
  for (; n > 0; n -= 1, y = (y + 1) >>> 0, frac = (frac + step) >>> 0) {
    const t = rom[((col + ((frac >>> 16) & 127)) >>> 0) % rl];
    fb[((sx | (web_spread(y) << 1)) >>> 0) % fl] = rom[((cm + t) >>> 0) % rl];
  }
  return fr;
}

function $src$047render$058spanpaint$go$(n, fr, x, y, pos, step, pic, cm) {
  const fb = fr.fb;
  const rom = fr.rom;
  const fl = fb.length;
  const rl = rom.length;
  const sy = web_spread(y) << 1;
  for (; n > 0; n -= 1, x = (x + 1) >>> 0, pos = (pos + step) >>> 0) {
    const t = rom[((pic + ((pos >>> 4) & 4032) + (pos >>> 26)) >>> 0) % rl];
    fb[((web_spread(x) | sy) >>> 0) % fl] = rom[((cm + t) >>> 0) % rl];
  }
  return fr;
}

function $src$047hud$058pix$(n, fr, x, y, q) {
  const fb = fr.fb;
  const rom = fr.rom;
  const fl = fb.length;
  const rl = rom.length;
  const sx = web_spread(x);
  for (; n > 0; n -= 1, y = (y + 1) >>> 0, q = (q + 1) >>> 0) {
    const c = rom[q % rl];
    if (x < 320 && y < 200) {
      fb[((sx | (web_spread(y) << 1)) >>> 0) % fl] = c;
    }
  }
  return fr;
}

function web_spread(v) {
  let a = (v | (v << 8)) & 0x00ff00ff;
  a = (a | (a << 4)) & 0x0f0f0f0f;
  a = (a | (a << 2)) & 0x33333333;
  return (a | (a << 1)) & 0x55555555;
}

function web_store(name, data) {
  WEB.files.set(name, data);
  if (/\.dsg$/i.test(name)) {
    try {
      let s = "";
      for (let i = 0; i < data.length; i += 1) {
        s += String.fromCharCode(data[i]);
      }
      localStorage.setItem("bendoom:" + name, btoa(s));
    } catch (e) {
    }
  }
}

function web_stored(name) {
  if (WEB.files.has(name)) {
    return WEB.files.get(name);
  }
  try {
    const s = localStorage.getItem("bendoom:" + name);
    if (s !== null) {
      const b = atob(s);
      const data = new Uint8Array(b.length);
      for (let i = 0; i < b.length; i += 1) {
        data[i] = b.charCodeAt(i);
      }
      WEB.files.set(name, data);
      return data;
    }
  } catch (e) {
  }
  return undefined;
}

function web_list(items) {
  let xs = { $: "Nil" };
  for (let i = items.length - 1; i >= 0; i -= 1) {
    xs = { $: "Con", head: items[i], tail: xs };
  }
  return xs;
}

$0eff["File.open"] = (path, mode) => {
  const name = String(path).replace(/^.*\//, "");
  if (mode === "r") {
    const data = web_stored(name);
    return data === undefined ? io_fail(2) : io_done({ name, mode, data, pos: 0 });
  }
  if (mode === "w") {
    return io_done({ name, mode, data: new Uint8Array(0), pos: 0 });
  }
  if (mode === "a") {
    const data = web_stored(name) ?? new Uint8Array(0);
    return io_done({ name, mode, data, pos: data.length });
  }
  return io_fail(22);
};

function web_take(f, at, max) {
  const end = Math.min(f.data.length, at + max);
  return f.data.subarray(Math.min(at, end), end);
}

$0eff["File.read"] = (f, max) => {
  const b = web_take(f, f.pos, max);
  f.pos += b.length;
  return io_tup(f, io_done(new TextDecoder().decode(b)));
};

$0eff["File.read_bytes"] = (f, max) => {
  const b = web_take(f, f.pos, max);
  f.pos += b.length;
  return io_tup(f, io_done(io_list(b, b.length)));
};

$0eff["File.read_at"] = (f, at, max) => {
  const b = web_take(f, Number(at), max);
  return io_tup(f, io_done(io_list(b, b.length)));
};

$0eff["File.size"] = (f) => io_tup(f, io_done(f.data.length));

function web_write(f, b) {
  const data = new Uint8Array(f.data.length + b.length);
  data.set(f.data);
  data.set(b, f.data.length);
  f.data = data;
  f.pos = data.length;
  return io_tup(f, io_done({ $: "Unit" }));
}

$0eff["File.write"] = (f, text) => web_write(f, new TextEncoder().encode(text));

$0eff["File.write_bytes"] = (f, xs) => {
  const b = io_unlist(xs);
  return b === null ? io_tup(f, io_fail(22)) : web_write(f, b);
};

$0eff["File.close"] = (f) => {
  if (f.mode !== "r") {
    web_store(f.name, f.data);
  }
  return { $: "Unit" };
};

$0eff["IO.args"] = () => web_list(WEB.args);

$0eff["IO.get_env"] = (name) => Object.hasOwn(WEB.env, name) ? io_done(WEB.env[name]) : io_fail(2);

$0eff["IO.now"] = () => BigInt(Math.floor(performance.now()));

$0eff["IO.print"] = (text) => {
  console.log(text);
  return { $: "Unit" };
};

$0eff["IO.print_err"] = (text) => {
  WEB.report(text);
  return { $: "Unit" };
};

$0eff["Window.open"] = (title, width, height) => {
  const c = WEB.canvas;
  c.width = 320;
  c.height = 200;
  WEB.ctx = c.getContext("2d");
  WEB.pix = WEB.ctx.createImageData(320, 200);
  WEB.order = new Int32Array(320 * 200);
  for (let y = 0; y < 200; y += 1) {
    for (let x = 0; x < 320; x += 1) {
      WEB.order[y * 320 + x] = web_spread(x) | (web_spread(y) << 1);
    }
  }
  document.title = title;
  return io_done({ title });
};

function web_tree(img, out, s, x, y) {
  if (x >= 320 || y >= 200) {
    return;
  }
  if (img.$ === "Qua" && s > 1) {
    const h = s >> 1;
    web_tree(img.tl, out, h, x, y);
    web_tree(img.tr, out, h, x + h, y);
    web_tree(img.bl, out, h, x, y + h);
    web_tree(img.br, out, h, x + h, y + h);
    return;
  }
  let c = img;
  while (c.$ === "Qua") {
    c = c.tl;
  }
  for (let j = y; j < Math.min(200, y + s); j += 1) {
    for (let i = x; i < Math.min(320, x + s); i += 1) {
      out[j * 320 + i] = c.color;
    }
  }
}

function web_show(img) {
  const px = WEB.pix.data;
  if (img.fb !== undefined) {
    const fb = img.fb;
    const order = WEB.order;
    for (let i = 0, o = 0; i < 64000; i += 1, o += 4) {
      const c = fb[order[i]];
      px[o] = (c >> 16) & 255;
      px[o + 1] = (c >> 8) & 255;
      px[o + 2] = c & 255;
      px[o + 3] = 255;
    }
  } else {
    const out = new Uint32Array(64000);
    web_tree(img, out, 512, 0, 0);
    for (let i = 0, o = 0; i < 64000; i += 1, o += 4) {
      const c = out[i];
      px[o] = (c >> 16) & 255;
      px[o + 1] = (c >> 8) & 255;
      px[o + 2] = c & 255;
      px[o + 3] = 255;
    }
  }
  WEB.ctx.putImageData(WEB.pix, 0, 0);
}

$0eff["Window.frame"] = (win, img, k) => {
  web_show(img);
  requestAnimationFrame(() => {
    const evs = WEB.keys.map(([code, down]) => ({ $: "Key", code, down }));
    WEB.keys = [];
    io_push(k, io_tup(win, img, web_list(evs)), false);
    web_pump();
  });
  return undefined;
};

$0eff["Window.grab"] = (win, on) => win;
$0eff["Window.set_title"] = (win, title) => {
  document.title = title;
  return win;
};
$0eff["Window.close"] = (win) => {
  WEB.report("The game has quit.");
  return { $: "Unit" };
};

$0eff["Audio.open"] = (rate) => {
  try {
    const ctx = new AudioContext({ sampleRate: rate });
    ctx.resume();
    WEB.audio = { ctx, rate, next: 0 };
    return io_done(WEB.audio);
  } catch (e) {
    return io_fail(19);
  }
};

$0eff["Audio.write"] = (a, xs) => {
  const vs = [];
  for (let p = xs; p.$ === "Con"; p = p.tail) {
    vs.push(p.head);
  }
  const n = vs.length >> 1;
  const now = a.ctx.currentTime;
  if (n > 0) {
    const buf = a.ctx.createBuffer(2, n, a.rate);
    const l = buf.getChannelData(0);
    const r = buf.getChannelData(1);
    for (let i = 0; i < n; i += 1) {
      l[i] = vs[2 * i];
      r[i] = vs[2 * i + 1];
    }
    const src = a.ctx.createBufferSource();
    src.buffer = buf;
    src.connect(a.ctx.destination);
    if (a.next < now + 0.02 || a.next > now + 0.5) {
      a.next = now + 0.05;
    }
    src.start(a.next);
    a.next += n / a.rate;
  }
  return io_tup(a, Math.max(0, Math.floor((a.next - now) * a.rate)));
};

$0eff["Audio.close"] = (a) => {
  a.ctx.close();
  return { $: "Unit" };
};

function web_pump() {
  const io = globalThis.BEND_IO;
  try {
    while (io.runs.length > 0) {
      const s = io.runs.shift();
      let op = s.fun(s.arg);
      while (op !== undefined) {
        if (op.$ === "Emit") {
          io.live -= 1;
          break;
        }
        if (op.$ === "Halt") {
          WEB.report(String(op.message));
          return;
        }
        const run = $0eff[op.$];
        if (run === undefined) {
          throw "bend: no effect registers " + op.$;
        }
        const x = run(...op.args, op.kont);
        if (x === undefined) {
          break;
        }
        op = op.kont(x);
      }
    }
  } catch (e) {
    WEB.report(e instanceof RangeError ? "bend: the browser's stack overflowed" : String(e));
    throw e;
  }
}

const WEB_KEYS = {
  ArrowUp: 63232, ArrowDown: 63233, ArrowLeft: 63234, ArrowRight: 63235,
  Backspace: 127, Escape: 27, Enter: 13, Tab: 9, Insert: 63271, Delete: 63272,
  Home: 63273, End: 63275, PageUp: 63276, PageDown: 63277,
  ShiftLeft: 65592, ShiftRight: 65596, ControlLeft: 65595, ControlRight: 65598,
  AltLeft: 65594, AltRight: 65597, MetaLeft: 65591, MetaRight: 65590, CapsLock: 65593,
};

function web_key(e) {
  if (Object.hasOwn(WEB_KEYS, e.code)) {
    return WEB_KEYS[e.code];
  }
  const f = /^F(\d+)$/.exec(e.code);
  if (f !== null) {
    return 63236 + Number(f[1]) - 1;
  }
  if (e.key.length === 1) {
    return e.key.toLowerCase().codePointAt(0);
  }
  return null;
}

function web_listen(target) {
  const on = (down) => (e) => {
    const code = web_key(e);
    if (code === null) {
      return;
    }
    e.preventDefault();
    if (WEB.audio !== null && WEB.audio.ctx.state === "suspended") {
      WEB.audio.ctx.resume();
    }
    if (down && e.repeat) {
      return;
    }
    WEB.keys.push([code, down]);
  };
  target.addEventListener("keydown", on(true));
  target.addEventListener("keyup", on(false));
}

function web_start(opts) {
  WEB.canvas = opts.canvas;
  WEB.report = opts.report;
  WEB.args = ["doom", ...opts.args];
  WEB.env = opts.env;
  for (const [name, data] of opts.files) {
    WEB.files.set(name, data);
  }
  web_listen(opts.keys ?? window);
  const io = { runs: [], live: 0, waits: [] };
  globalThis.BEND_IO = io;
  io_push(run_loop($main$()), (x) => ({ $: "Emit", value: x }), true);
  web_pump();
}

globalThis.web_start = web_start;
