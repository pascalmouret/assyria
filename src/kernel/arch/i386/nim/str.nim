import math
import io

proc length(i: int, base: int): int =
  result = 1
  while (i - (base^result) > 0):
    inc(result)
  return result

proc printIntRec(i: Natural, base: int): void =
  if (i > 0):
    let digit = i %% base
    printIntRec(((i - digit) div base), base)
    print(char((if digit > 9: ord('A') - 10 else: ord('0')) + digit))

proc printInt*(i: Natural, base: int): void =
  var
    tmp: Natural = i
    negative: bool = i < 0

  if (negative):
    tmp = i * -1
  else:
    tmp = i

  if negative:
    print('-')

  if tmp > 0:
    printIntRec(tmp, base)
  else:
    print('0')
