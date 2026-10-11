import Base

def u16(+v: U32, rest: List<&2, U32>) -> List<&2, U32>:
  (v .&. 255 : U32) <> ((v >> 8n) .&. 255 : U32) <> rest

def u32(+v: U32, rest: List<&2, U32>) -> List<&2, U32>:
  u16(v, u16((v >> 16n : U32), rest))

def own.go(xs: List<U32>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +x <> t:
      own.go(t, x <> acc)
    case []:
      List.reverse(&2, U32, acc)

def own(xs: List<U32>) -> List<&2, U32>:
  own.go(xs, [])

def pixels.go(xs: List<&2, U32>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case +c <> t:
      pixels.go(t, ((c >> 16n) .&. 255 : U32) <> ((c >> 8n) .&. 255 : U32) <> (c .&. 255 : U32) <> acc)
    case []:
      List.reverse(&2, U32, acc)

def pixels(xs: List<&2, U32>) -> List<&2, U32>:
  pixels.go(xs, [])

def encode(+w: U32, +h: U32, px: List<&2, U32>) -> List<&2, U32>:
  +size = (w * h * 3 : U32)
  66 <> 77 <> u32((size + 54 : U32), u32(0, u32(54, u32(40, u32(w, u32(h,
    u16(1, u16(24, u32(0, u32(size, u32(2835, u32(2835, u32(0, u32(0,
      pixels(px)))))))))))))))
