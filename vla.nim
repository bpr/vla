include system/ansi_c

proc alloca(n: int): pointer {.importc, header: "<alloca.h>".}

type
  UncheckedArray{.unchecked.}[T] =
    array[1, T]
  VarLengthArray*[T] =
    ptr object
      len: int
      reserved: int
      data: UncheckedArray[T]

proc `[]`*[T](a: VarLengthArray[T], i: int): T =
  assert i >= 0 and i < a.len
  result = a.data[i]

proc `[]=`*[T](a: VarLengthArray[T], i: int, x: T) =
  assert i >= 0 and i < a.len
  a.data[i] = x

proc len*[T](a: VarLengthArray[T]): int =
  a.len

template newVLA*(T: typedesc, n: int): expr =
  let bytes = 2 * sizeof(int) + sizeof(T)*n
  var vla = cast[VarLengthArray[T]](alloca(bytes))
  c_memset(vla, 0, bytes)
  vla.len = n
  vla.reserved = n
  vla

# Untested code
template asOpenArray*[T](a: VarLengthArray[T]): openarray[T] =
  cast[seq[type(a[0])]](a)

proc toSeq*[T](a: VarLengthArray[T]): seq[T] =
  result = newSeq[T](len(a))
  for i in 0..len(a)-1:
    result[i] = a[i]
