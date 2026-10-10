import Base

def saved(p: File & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (f, r) = p
  do IO<Unit>:
    IO.pass(Unit, r)
    File.close(f)

def save(path: String, bytes: List<&2, U32>) -> IO(Unit):
  do IO<Unit>:
    f : File <- IO.try(File, File.open(path, "w"))
    p : File & Result<&1, &1, U32 & String, Unit> <- File.write_bytes(f, bytes)
    saved(p)
