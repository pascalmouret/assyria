import kernel.arch.vga

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
