import vga

import unsigned

proc print*(s: string): void
proc print*(c: char): void
proc println*(s: string): void

proc clear*(): void = vga.clear()

proc println*(s: string): void =
  print(s)
  print('\n')

proc println*(s: string, color: VGAColorMix): void =
  let tmpColor = getCurrentColor()
  setColor(color)
  println(s)
  setColor(tmpColor)

proc print*(s: string): void =
  for c in 0 .. s.len - 1:
    print(s[c])

proc print*(c: char): void  =
  printChar(c)

proc printUIntRec(i: uint64, base: uint): void =
  if (i != 0):
    let digit = i mod base
    printUIntRec(((i - digit) div base), base)
    print(char((if digit < 10.uint64: ord('0') else: ord('A') - 10) + digit.int))

proc printInt*(i: uint64, base: uint): void =
  if i != 0:
    printUIntRec(i, base)
  else:
    print('0')

proc printInt*(i: int, base: uint): void =
  if i < 0:
    print('-')
    printInt(cast[uint32](i * -1), base)
  else:
    printInt(cast[uint32](i), base)

proc printInt*(i: uint32, base: uint): void =
  printInt(i.uint64, base)

proc printInt*(i: uint8, base: uint): void =
  printInt(i.uint64, base)
