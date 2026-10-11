import struct
import sys

CONTROLLERS = {0: 1, 7: 3, 10: 4, 11: 5, 91: 6, 93: 7, 64: 8, 67: 9}
SYSTEM = {120: 10, 123: 11, 126: 12, 127: 13, 121: 14}


def lump(path, name):
    w = open(path, 'rb').read()
    n, o = struct.unpack('<II', w[4:12])
    found = None
    for i in range(n):
        p, size, nm = struct.unpack('<II8s', w[o + 16 * i:o + 16 * i + 16])
        if nm.rstrip(b'\0').decode() == name:
            found = w[p:p + size]
    return found


def varlen(d, p):
    v = 0
    while True:
        b = d[p]
        p += 1
        v = (v << 7) | (b & 127)
        if not b & 128:
            return v, p


def events(d):
    ntr, div = struct.unpack('>HH', d[10:14])
    p, evs, tempo = 14, [], []
    for t in range(ntr):
        size = struct.unpack('>I', d[p + 4:p + 8])[0]
        q, end, tick, run, seq = p + 8, p + 8 + size, 0, 0, 0
        while q < end:
            dt, q = varlen(d, q)
            tick += dt
            b = d[q]
            if b == 0xff:
                kind = d[q + 1]
                n, q = varlen(d, q + 2)
                if kind == 0x51:
                    tempo.append((tick, int.from_bytes(d[q:q + 3], 'big')))
                q += n
                if kind == 0x2f:
                    break
                continue
            if b in (0xf0, 0xf7):
                n, q = varlen(d, q + 1)
                q += n
                continue
            if b & 0x80:
                run = b
                q += 1
            a, c = d[q], 0
            q += 1
            if run & 0xf0 not in (0xc0, 0xd0):
                c = d[q]
                q += 1
            evs.append((tick, t, seq, run, a, c))
            seq += 1
        p = end
    return div, sorted(evs), sorted(tempo)


def seconds(tick, div, tempo):
    s, last, upb = 0.0, 0, 500000
    for t, u in tempo:
        if t > tick:
            break
        s += (t - last) * upb / div / 1e6
        last, upb = t, u
    return s + (tick - last) * upb / div / 1e6


def mus(midi):
    div, evs, tempo = events(midi)
    chans, items = {9: 15}, []
    for tick, _, _, st, a, c in evs:
        ch, hi = st & 15, st & 0xf0
        if ch not in chans:
            chans[ch] = min(len([k for k in chans if k != 9]), 14)
        m = chans[ch]
        if hi == 0x80 or (hi == 0x90 and c == 0):
            items.append((tick, [m, a]))
        elif hi == 0x90:
            items.append((tick, [0x10 | m, a | 0x80, c]))
        elif hi == 0xe0:
            items.append((tick, [0x20 | m, ((c << 7) | a) >> 6]))
        elif hi == 0xc0:
            items.append((tick, [0x40 | m, 0, a]))
        elif hi == 0xb0 and a in CONTROLLERS:
            items.append((tick, [0x40 | m, CONTROLLERS[a], c]))
        elif hi == 0xb0 and a in SYSTEM:
            items.append((tick, [0x30 | m, SYSTEM[a]]))
    out = bytearray()
    times = [round(seconds(t, div, tempo) * 140) for t, _ in items]
    for i, (_, b) in enumerate(items):
        delay = times[i + 1] - times[i] if i + 1 < len(items) else 0
        if delay > 0:
            b[0] |= 0x80
            v = [delay & 127]
            delay >>= 7
            while delay:
                v.append((delay & 127) | 128)
                delay >>= 7
            b += reversed(v)
        out += bytes(b)
    out.append(0x60)
    head = b'MUS\x1a' + struct.pack('<HHHHHH', len(out), 16, len(set(chans.values())), 0, 0, 0)
    return head + out


def main():
    if len(sys.argv) != 4:
        sys.exit('usage: mkmus.py IWAD LUMP OUT.wad')
    data = mus(lump(sys.argv[1], sys.argv[2]))
    name = sys.argv[2].encode().ljust(8, b'\0')
    wad = b'PWAD' + struct.pack('<II', 1, 12 + len(data)) + data + struct.pack('<II8s', 12, len(data), name)
    open(sys.argv[3], 'wb').write(wad)


main()
