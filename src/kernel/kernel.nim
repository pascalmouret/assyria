import io
import vga
import gdt

proc kernel_main(): void {.exportc.} =
  loadGDT()
  init()
  println("Hello, NIM Kernel!")
  println("Version 0.0.1", vgaColorMix(VGABlue, VGABlack))
