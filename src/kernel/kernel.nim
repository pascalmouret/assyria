import io
import vga
import gdt

import str

type
  MultibootHeader = array[15, uint32]
  MultibootHeaderPtr = ptr MultibootHeader

proc kernel_main(multibootHeader: MultibootHeaderPtr, magic: int): void {.exportc.} =
  init()
  printInt(multibootHeader[0].int, 2)
  printInt(magic, 16)
  println("Hello, NIM Kernel!")
  println("Version 0.0.1", vgaColorMix(VGABlue, VGABlack))
