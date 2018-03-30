const VGA_WIDTH = 80
const VGA_HEIGHT = 25

type VGAColor = enum
  VGABlack,
  VGABlue,
  VGAGreen,
  VGACyan,
  VGARed,
  VGAMagenta,
  VGABrown,
  VGALightGrey,
  VGADarkGrey,
  VGALightBlue,
  VGALightGreen,
  VGALightCyan,
  VGALightRed,
  VGALightMagenta,
  VGALightBrown,
  VGAWhite

type VGAEntry = distinct uint16
type VGAColorMix = distinct uint8
type VGABuffer = ptr array[VGA_WIDTH*VGA_HEIGHT, VGAEntry]

var currentRow = 0

proc vgaColorMix(front: VGAColor, back: VGAColor): VGAColorMix =
  return cast[VGAColorMix](ord(front).uint8 or (ord(back).uint8 shl 4))

proc vgaEntry(c: char, color: VGAColorMix): VGAEntry =
  return cast[VGAEntry](c.uint16 or (color.uint16 shl 8))

proc initTerminal(vram: VGABuffer): void =
  var i = 0
  while (i < VGAWidth*VGAHeight):
    vram[i] = vgaEntry(' ', vgaColorMix(VGABlack, VGAWhite))
    inc(i)

proc writeString(vram: VGABuffer, s: string, color: VGAColorMix) =
  var col = 0
  for c in s:
    vram[VGA_WIDTH * currentRow + col] = vgaEntry(c, color)
    inc(col)

proc kernel_main() {.exportc.} =
  let vram = cast[VGABuffer](0xB8000)
  initTerminal(vram)
  writeString(vram, "Hello, NIM Kernel!", vgaColorMix(VGABlack, VGAWhite))
