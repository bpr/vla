import vla, times

let 
  s = "Warning: unknown magic 'DeepCopy' might crash the compiler [UnknownMagic]"

var 
  vla_count = 0
  seq_count = 0

proc test_oa(count : var int, a: openarray[char]) =
  count += len(a)

proc test_vla(n : int) =
  var vla = newVLA(char, n)
  for i in countup(0,n-1):
    vla[i] = s[i]
  test_oa(vla_count, asOpenArray(vla))

proc test_seq(n : int) =
  var seqVal = new_seq[char](n)
  for i in countup(0,n-1):
    seqVal[i] = s[i]
  test_oa(seq_count, seqVal)

# Time the VLA
var t0 = cpuTime()
for n in 0..100000:
  for i in 0..len(s):
    test_vla(i)

var vla_time = cpuTime() - t0
echo("alloca time = ", vla_time)
echo("vla count = ", vla_count)

# Time Nim's built in seq
t0 = cpuTime()
for n in 0..100000:
  for i in 0..len(s):
    test_seq(i)

var seq_time = cpuTime() - t0
echo("seq time = ", seq_time)
echo("seq count = ", seq_count)

echo("speedup = ", float64(seq_time) / float64(vla_time))

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
