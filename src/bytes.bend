import Base

def words(xs: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case a <> b <> t:
      (a .|. (b << 8n) : U32) <> words(t)
    case _:
      []

def u32(lo: U32, hi: U32) -> U32:
  (lo .|. (hi << 16n) : U32)

def upper(+c: U32) -> U32:
  Bool.pick(U32, Bool.and(U32.is_ge(c, 97), U32.is_le(c, 122)), (c - 32 : U32), c)

def text.put(+c: U32, s: String) -> String:
  Bool.pick(String, U32.is_eq(c, 0), "", SCon{Chr{upper(c)}, s})

def text(cs: List<&2, U32>) -> String:
  match cs:
    case c <> t:
      text.put(c, text(t))
    case []:
      ""

def lo(+w: U32) -> U32:
  (w .&. 255 : U32)

def hi(w: U32) -> U32:
  (w >> 8n : U32)

def name(+a: U32, +b: U32, +c: U32, +d: U32) -> String:
  text([lo(a), hi(a), lo(b), hi(b), lo(c), hi(c), lo(d), hi(d)])
