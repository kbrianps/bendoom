import sys
out, ep, mp = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
segs = [s for s in sys.argv[4:] if not s.startswith('skill=')]
sk = int(([s for s in sys.argv[4:] if s.startswith('skill=')] or ['skill=2'])[0][6:])
b = bytearray([109, sk, ep, mp, 0, 0, 0, 0, 0, 1, 0, 0, 0])
for s in segs:
    n, f, sd, t, bt = map(int, s.split(','))
    for _ in range(n):
        b += bytes([f & 255, sd & 255, t & 255, bt & 255])
b.append(0x80)
open(out, 'wb').write(b)
