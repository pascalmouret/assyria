const VGA_WIDTH = 80
const VGA_HEIGHT = 25
const VRAM_LENGTH = VGA_WIDTH * VGA_HEIGHT

type VGAColor* = enum
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
type VGAColorMix* = distinct uint8
type VGABuffer = ptr array[VRAM_LENGTH, VGAEntry]

const vram = cast[VGABuffer](0xB8000)

proc vgaColorMix*(front: VGAColor, back: VGAColor): VGAColorMix =
  return cast[VGAColorMix](ord(front).uint8 or (ord(back).uint8 shl 4))

proc vgaEntry(c: char, color: VGAColorMix): VGAEntry =
  return cast[VGAEntry](c.uint16 or (color.uint16 shl 8))

var currentRow = 0
var currentCol = 0
const defaultColor: VGAColorMix = vgaColorMix(VGAWhite, VGABlack)
var currentColor: VGAColorMix = defaultColor

proc scroll(rows: int): void =
  for i in 0 .. (VRAM_LENGTH - VGA_WIDTH * rows) - 1:
    vram[i] = vram[i + VGA_WIDTH]
  for i in (VRAM_LENGTH - VGA_WIDTH * rows) - 1 .. VRAM_LENGTH - 1:
    vram[i] = vgaEntry(' ', defaultColor)

proc setColor*(color: VGAColorMix): void =
  currentColor = color

proc getCurrentColor*(): VGAColorMix =
  return currentColor

proc printChar*(c: char): void =
  if (c != '\n'):
    vram[VGA_WIDTH * currentRow + currentCol] = vgaEntry(c, currentColor)
    inc(currentCol)
  if (currentCol >= VGA_WIDTH or c == '\n'):
    inc(currentRow)
    if (currentRow >= VGA_HEIGHT):
      scroll(1)
      dec(currentRow)
    currentCol = 0

proc clear*(): void =
  setColor(defaultColor)
  var i = 0
  while (i < VRAM_LENGTH):
    vram[i] = vgaEntry(' ', currentColor)
    inc(i)
