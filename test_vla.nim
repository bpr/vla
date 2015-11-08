import vla, times

let 
  s = "Warning: unknown magic 'DeepCopy' might crash the compiler [UnknownMagic]"

var count = 0

proc test_oa_foo(n : int, a: openarray[char]) = 
  write(stdout, n)
  write(stdout, ": ")
  for i in 0..len(a)-1:
     write(stdout, a[i])
  write(stdout, "\n")

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
