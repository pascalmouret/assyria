import vga

const defaultColor: VGAColorMix = vgaColorMix(VGAWhite, VGABlack)

var currentRow = 0
var currentCol = 0
var currentColor: VGAColorMix = defaultColor

proc print(c: char): void
proc scroll(rows: int): void

proc setColor*(color: VGAColorMix): void =
  currentColor = color

proc init*(): void =
  setColor(defaultColor)
  var i = 0
  while (i < VRAM_LENGTH):
    vram[i] = vgaEntry(' ', currentColor)
    inc(i)

proc println*(s: string): void =
  for c in 0 .. s.len - 1:
    print(s[c])
  print('\n')

proc println*(s: string, color: VGAColorMix): void =
  let tmpColor = currentColor
  setColor(color)
  println(s)
  currentColor = tmpColor

proc scroll(rows: int): void =
  for i in 0 .. (VRAM_LENGTH - VGA_WIDTH * rows) - 1:
    vram[i] = vram[i + VGA_WIDTH]
  for i in (VRAM_LENGTH - VGA_WIDTH * rows) - 1 .. VRAM_LENGTH - 1:
    vram[i] = vgaEntry(' ', defaultColor)

proc print(c: char): void =
  if (c != '\n'):
    vram[VGA_WIDTH * currentRow + currentCol] = vgaEntry(c, currentColor)
    inc(currentCol)
  if (currentCol >= VGA_WIDTH or c == '\n'):
    inc(currentRow)
    if (currentRow >= VGA_HEIGHT):
      scroll(1)
      dec(currentRow)
    currentCol = 0
