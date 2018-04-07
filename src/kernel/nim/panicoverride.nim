import io
import kernel.arch.vga

{.push stack_trace: off, profiler:off.}

proc rawoutput(s: string) =
  println(s, vgaColorMix(VGARed, VGAWhite))

proc panic(s: string) =
  rawoutput(s)

{.pop.}
