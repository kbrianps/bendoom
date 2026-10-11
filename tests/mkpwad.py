import struct
import sys
import zlib


def read_wad(path):
    data = open(path, 'rb').read()
    n, at = struct.unpack_from('<II', data, 4)
    lumps = []
    for i in range(n):
        pos, size, name = struct.unpack_from('<II8s', data, at + 16 * i)
        lumps.append((name.rstrip(b'\0').decode(), data[pos:pos + size]))
    return lumps


def write_wad(path, lumps):
    body = b''
    entries = []
    for name, data in lumps:
        entries.append((12 + len(body), len(data), name))
        body += data
    head = b'PWAD' + struct.pack('<II', len(lumps), 12 + len(body))
    dir_ = b''.join(struct.pack('<II8s', p, s, n.encode()) for p, s, n in entries)
    open(path, 'wb').write(head + body + dir_)


PARTS = ['THINGS', 'LINEDEFS', 'SIDEDEFS', 'VERTEXES', 'SEGS', 'SSECTORS', 'NODES', 'SECTORS', 'REJECT', 'BLOCKMAP']


def level(lumps, name):
    i = max(k for k, (n, _) in enumerate(lumps) if n == name)
    return dict(lumps[i + 1:i + 11])


def extended(parts, compressed):
    verts = parts['VERTEXES']
    lines = parts['LINEDEFS']
    used = max(max(struct.unpack_from('<HH', lines, i)) for i in range(0, len(lines), 14)) + 1
    total = len(verts) // 4
    out = struct.pack('<II', used, total - used)
    for i in range(used, total):
        x, y = struct.unpack_from('<hh', verts, 4 * i)
        out += struct.pack('<ii', x << 16, y << 16)
    subs = parts['SSECTORS']
    out += struct.pack('<I', len(subs) // 4)
    for i in range(0, len(subs), 4):
        out += struct.pack('<I', struct.unpack_from('<H', subs, i)[0])
    segs = parts['SEGS']
    out += struct.pack('<I', len(segs) // 12)
    for i in range(0, len(segs), 12):
        v1, v2, ang, line, side, off = struct.unpack_from('<HHHHHh', segs, i)
        out += struct.pack('<IIHB', v1, v2, line, side)
    nodes = parts['NODES']
    out += struct.pack('<I', len(nodes) // 28)
    for i in range(0, len(nodes), 28):
        vals = struct.unpack_from('<12h2H', nodes, i)
        kids = [(c & 0x7fff) | 0x80000000 if c & 0x8000 else c for c in vals[12:]]
        out += struct.pack('<12h2I', *vals[:12], *kids)
    nodes = b'ZNOD' + zlib.compress(out, 9) if compressed else b'XNOD' + out
    parts = dict(parts, VERTEXES=verts[:4 * used], SEGS=b'', SSECTORS=b'', NODES=nodes)
    return parts


def main():
    iwad, out, kind, src, dst = sys.argv[1:6]
    parts = level(read_wad(iwad), src)
    if kind in ('xnod', 'znod'):
        parts = extended(parts, kind == 'znod')
    write_wad(out, [(dst, b'')] + [(p, parts[p]) for p in PARTS])


main()
