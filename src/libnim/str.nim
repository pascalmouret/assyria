import math

proc length(i: int, base: int): int =
  result = 1
  var remove = 10
  while (i - (base^result) > 0):
    inc(result)
  return result

proc parseInt*(i: int, base: int): string =
  var
    tmp: int
    len: int
    negative: bool = i < 0

  if (negative):
    tmp = i * -1
  else:
    tmp = i

  len = length(tmp, base)
  result = newString(len + (if negative: 1 else: 0))

  while (len > 0):
    let digit = tmp %% base
    result[len - (if negative: 0 else: 1)] = char(ord('0') + digit)
    tmp = ((tmp - digit) / base).int
    dec(len)

  if negative:
    result[0] = '-'

  return result
