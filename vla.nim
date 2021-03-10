include system/ansi_c

proc alloca(n: int): pointer {.importc, header: "<alloca.h>".}

type
  VarLengthArray*[T] =
    ptr object
      len: int
      data: UncheckedArray[T]

proc `[]`*[T](a: VarLengthArray[T], i: int): T {.inline.} =
  assert i >= 0 and i < a.len
  result = a.data[i]

proc `[]=`*[T](a: VarLengthArray[T], i: int, x: T) {.inline.} =
  assert i >= 0 and i < a.len
  a.data[i] = x

proc len*[T](a: VarLengthArray[T]): int =
  a.len

template newVLA*(T: typedesc, n: int): untyped =
  let bytes = sizeof(int) + sizeof(T)*n
  var vla = cast[VarLengthArray[T]](alloca(bytes))
  c_memset(vla, cast[cint](0), cast[csize_t](bytes))
  vla.len = n
  vla

# Untested code
template asOpenArray*[T](a: VarLengthArray[T]): openarray[T] =
  toOpenArray(addr a.data[0],0,a.len)

proc toSeq*[T](a: VarLengthArray[T]): seq[T] =
  result = newSeq[T](len(a))
  for i in 0..len(a)-1:
    result[i] = a[i]
