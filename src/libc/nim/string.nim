proc memset*(str: pointer, value: cint, length: csize): pointer {.exportc, discardable.} =
  var buf = cast[ptr UncheckedArray[char]](str)
  for i in 0 .. length - 1:
    buf[i] = cast[char](value)
  return str
