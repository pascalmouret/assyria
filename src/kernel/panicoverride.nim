import io

{.push stack_trace: off, profiler:off.}

proc rawoutput(s: string) =
  while (true):
    var a = 1
  println(s)

proc panic(s: string) =
  while (true):
    var a = 1
  rawoutput(s)

{.pop.}
