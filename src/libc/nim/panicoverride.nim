# import io
# import vga

{.push stack_trace: off, profiler:off.}

proc rawoutput(s: string) =
  discard
  # println(s, vgaColorMix(VGARed, VGAWhite))

proc panic(s: string) =
  discard
  # rawoutput(s)

{.pop.}
