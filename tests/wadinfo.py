import struct
import sys

M = 0xFFFFFFFF


def mix(h, v):
    return (h * 31 + (v & M)) & M


def text(raw):
    return raw.split(b"\0")[0].decode("latin-1").upper()


def mixs(h, s):
    for c in s:
        h = mix(h, ord(c))
    return mix(h, 0)


def recs(data, fmt, size):
    return [struct.unpack_from(fmt, data, i) for i in range(0, len(data) - size + 1, size)]


def total(items, f):
    h = 0
    for x in items:
        h = f(h, x)
    return "%d:%d" % (len(items), h)


def fields(h, xs):
    for x in xs:
        h = mixs(h, text(x)) if isinstance(x, bytes) else mix(h, x)
    return h


def main(path):
    data = open(path, "rb").read()
    _, n, at = struct.unpack_from("<4sII", data, 0)
    lumps = [struct.unpack_from("<II8s", data, at + 16 * i) for i in range(n)]
    lumps = [(text(name), pos, size) for pos, size, name in lumps]
    for i, (name, _, _) in enumerate(lumps):
        if i + 1 >= len(lumps) or lumps[i + 1][0] != "THINGS":
            continue
        part = {}
        for nm, pos, size in lumps[i + 1:i + 11]:
            part.setdefault(nm, data[pos:pos + size])
        get = lambda k: part.get(k, b"")
        ent = lambda k, fmt, size: total(recs(get(k), fmt, size), fields)
        out = [name]
        out += ["things", ent("THINGS", "<hhHHH", 10)]
        out += ["lines", ent("LINEDEFS", "<HHHHHHH", 14)]
        out += ["sides", ent("SIDEDEFS", "<hh8s8s8sH", 30)]
        out += ["verts", ent("VERTEXES", "<hh", 4)]
        out += ["segs", ent("SEGS", "<HHHHHh", 12)]
        out += ["subs", ent("SSECTORS", "<HH", 4)]
        out += ["nodes", ent("NODES", "<hhhhhhhhhhhhHH", 28)]
        out += ["sectors", ent("SECTORS", "<hh8s8sHHH", 26)]
        out += ["reject", total(list(get("REJECT")), mix)]
        out += ["blockmap", ent("BLOCKMAP", "<H", 2)]
        print(" ".join(out))


main(sys.argv[1])
