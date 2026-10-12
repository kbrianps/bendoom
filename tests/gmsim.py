import sys, struct

import numpy as np


def load(p, secs):
    d = open(p, 'rb').read()
    i = 12
    ch = 2
    data = None
    while i + 8 <= len(d):
        cid = d[i:i + 4]
        sz = struct.unpack('<I', d[i + 4:i + 8])[0]
        if cid == b'fmt ':
            ch = struct.unpack('<H', d[i + 10:i + 12])[0]
        if cid == b'data':
            data = d[i + 8:]
            break
        i += 8 + sz
    a = np.frombuffer(data[:len(data) // (2 * ch) * 2 * ch], dtype='<i2').astype(np.float64).reshape(-1, ch) / 32768
    if ch == 1:
        a = np.hstack([a, a])
    return a[:int(secs * 22050)]


def bands(x, n=1024, hop=512, nb=48):
    w = np.hanning(n)
    fr = np.array([x[i:i + n] * w for i in range(0, len(x) - n, hop)])
    S = np.abs(np.fft.rfft(fr, axis=1)) ** 2
    edges = np.unique(np.geomspace(2, n // 2, nb + 1).astype(int))
    return np.array([S[:, a:b].sum(1) for a, b in zip(edges[:-1], edges[1:])]).T


def score(x, y):
    mx, sx = bands((x[:, 0] + x[:, 1]) / 2), bands((x[:, 0] - x[:, 1]) / 2)
    my, sy = bands((y[:, 0] + y[:, 1]) / 2), bands((y[:, 0] - y[:, 1]) / 2)
    n = min(len(mx), len(my))
    mx, my, sx, sy = mx[:n], my[:n], sx[:n], sy[:n]
    a = 10 * np.log10(mx / mx.mean() + 1e-6).ravel()
    b = 10 * np.log10(my / my.mean() + 1e-6).ravel()
    spec = np.corrcoef(a, b)[0, 1]
    env = np.corrcoef(np.log10(mx.sum(1) + 1e-12), np.log10(my.sum(1) + 1e-12))[0, 1]
    return spec, env, sx.sum() / mx.sum(), sy.sum() / my.sum()


def lump(wad, name, out):
    w = open(wad, 'rb').read()
    n, off = struct.unpack('<II', w[4:12])
    for i in range(n):
        o, sz, entry = struct.unpack('<II8s', w[off + 16 * i:off + 16 * i + 16])
        if entry.rstrip(b'\0').decode() == name:
            open(out, 'wb').write(w[o:o + sz])
            return
    sys.exit('no lump ' + name)


def main():
    if sys.argv[1] == 'lump':
        lump(*sys.argv[2:5])
        return
    secs = float(sys.argv[2])
    ref = load(sys.argv[3], secs)
    plain = score(load(sys.argv[4], secs), ref)
    fx = score(load(sys.argv[5], secs), ref)
    print('plain %.4f effects %.4f' % (plain[0], fx[0]))
    sys.exit(0 if fx[0] >= 0.9 and fx[0] > plain[0] else 1)


if __name__ == '__main__':
    main()
