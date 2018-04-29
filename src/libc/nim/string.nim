proc memset*(str: pointer, value: cint, length: csize): pointer {.exportc.} =
  return str
