import io
import vga

proc kernel_main(): void {.exportc.} =
  init()
  println("Hello, NIM Kernel!")
  println("Version 0.0.1", vgaColorMix(VGABlue, VGABlack))
