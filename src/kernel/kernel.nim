import io
import vga
import gdt

import str

type
  MultibootHeader = object
  MultibootHeaderPtr = ptr MultibootHeader

proc kernel_main(multibootHeader: ptr MultibootHeader, magic: int): void {.exportc.} =
  init()
  println(parseInt(magic, 10))
  println("Hello, NIM Kernel!")
  println("Version 0.0.1", vgaColorMix(VGABlue, VGABlack))
