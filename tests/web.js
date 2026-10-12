const fs = require("fs");
const vm = require("vm");
const path = require("path");
const crypto = require("crypto");

const [bundle, count, keys, ...rest] = process.argv.slice(2);
const frames = Number(count);
const presses = keys.split(",").filter(Boolean).map((k) => k.split(":").map(Number));
let n = 0;
let image = null;

globalThis.document = { title: "" };
globalThis.localStorage = { getItem: () => null, setItem: () => {} };
globalThis.requestAnimationFrame = (f) => {
  n += 1;
  if (n >= frames) {
    process.stdout.write(crypto.createHash("sha256").update(image.data).digest("hex") + "\n");
    process.exit(0);
  }
  for (const [at, code, down] of presses) {
    if (at === n) {
      WEB.keys.push([code, down === 1]);
    }
  }
  setImmediate(f);
};
globalThis.AudioContext = class {
  constructor() {
    this.state = "running";
    this.destination = {};
  }
  get currentTime() {
    return n / 35;
  }
  resume() {}
  close() {}
  createBuffer(c, len) {
    const ch = [new Float32Array(len), new Float32Array(len)];
    return { getChannelData: (i) => ch[i] };
  }
  createBufferSource() {
    return { connect() {}, start() {} };
  }
};

vm.runInThisContext(fs.readFileSync(bundle, "utf8"), { filename: bundle });
$0eff["IO.now"] = () => BigInt(Math.floor(n * 1000 / 35));

const canvas = {
  getContext: () => ({
    createImageData: (w, h) => ({ data: new Uint8ClampedArray(w * h * 4) }),
    putImageData: (p) => {
      image = p;
    },
  }),
};
const files = [];
const args = [];
for (const a of rest) {
  if (fs.existsSync(a)) {
    files.push([path.basename(a), new Uint8Array(fs.readFileSync(a))]);
    args.push(path.basename(a));
  } else {
    args.push(a);
  }
}
web_start({
  canvas,
  report: (text) => {
    process.stderr.write(text + "\n");
    process.exit(1);
  },
  args,
  env: {},
  files,
  keys: { addEventListener() {} },
});
