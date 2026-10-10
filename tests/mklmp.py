import sys
out, ep, mp = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
segs = sys.argv[4:]
b = bytearray([109, 2, ep, mp, 0, 0, 0, 0, 0, 1, 0, 0, 0])
for s in segs:
    n, f, sd, t, bt = map(int, s.split(','))
    for _ in range(n):
        b += bytes([f & 255, sd & 255, t & 255, bt & 255])
b.append(0x80)
open(out, 'wb').write(b)
