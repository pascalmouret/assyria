const VGA_WIDTH* = 80
const VGA_HEIGHT* = 25
const VRAM_LENGTH* = VGA_WIDTH * VGA_HEIGHT

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

type VGAEntry* = distinct uint16
type VGAColorMix* = distinct uint8
type VGABuffer* = ptr array[VRAM_LENGTH, VGAEntry]

const vram* = cast[VGABuffer](0xB8000)

proc vgaColorMix*(front: VGAColor, back: VGAColor): VGAColorMix =
  return cast[VGAColorMix](ord(front).uint8 or (ord(back).uint8 shl 4))

proc vgaEntry*(c: char, color: VGAColorMix): VGAEntry =
  return cast[VGAEntry](c.uint16 or (color.uint16 shl 8))
