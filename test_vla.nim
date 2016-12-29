import vla, times

let 
  s = "Warning: unknown magic 'DeepCopy' might crash the compiler [UnknownMagic]"

var count = 0

proc test_oa(n : int, a: openarray[char]) = 
  count += len(a)

proc test_vla(n : int) = 
  var vla = newVLA(char, n)
  for i in countup(0,n-1):
    vla[i] = s[i]
  test_oa(n, asOpenArray(vla))

proc test_seq(n : int) = 
  var seqVal : seq[char] = @[]
  for i in countup(0,n-1):
    seqVal.add(s[i])
  test_oa(n, seqVal)

# Time the VLA
var t0 = cpuTime()
for n in 0..100000:
  for i in 0..len(s):
    test_vla(i)
var t1 = cpuTime()
echo("alloca time = ", (t1 - t0))

# Time Nim's built in seq
for n in 0..100000:
  for i in 0..len(s):
    test_seq(i)
var t2 = cpuTime()
echo("seq time = ", (t2 - t1))
echo("count = ", count)

discard r"""
proc test_ragged_vla(nrows:int, ncols:int) = 
  var mat = newVLA(VarLengthArray[int], nrows)
  for i in countup(0, nrows-1):
    mat[i] = newVLA(int, ncols)
  for i in countup(0,nrows-1):
    for j in countup(0,ncols-1):
      echo("mat[$i][$j]=", mat[i][j])

test_ragged_vla(8, 4)
"""
